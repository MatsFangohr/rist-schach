/* 
  Copyright (c) 2022 John Jackson.

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
open Belt
open Data
module Id = Data.Id

module PlayerMatchInfo = {
  @react.component
  let make = (~player, ~origRating, ~newRating, ~getPlayer, ~scoreData, ~players, ~avoidPairs) => {
    let {
      player,
      hasBye,
      colorBalance,
      score,
      rating,
      opponentResults,
      avoidListHtml,
    } = TournamentUtils.getScoreInfo(
      ~player,
      ~scoreData,
      ~getPlayer,
      ~players,
      ~origRating,
      ~newRating,
      ~avoidPairs,
    )
    <dl className="player-card">
      <h3> {player->Player.fullName->React.string} </h3>
      <dt> {"Punkte"->React.string} </dt>
      <dd> {score->React.float} </dd>
      <dt> {"Rating"->React.string} </dt>
      <Utils.TestId testId={"rating-" ++ player.id->Data.Id.toString}>
        <dd ariaLabel={"Rating for " ++ Player.fullName(player)}> rating </dd>
      </Utils.TestId>
      <dt> {"Farbbilanz"->React.string} </dt>
      <dd> {colorBalance->React.string} </dd>
      <dt> {"Hat ein Bye erhalten"->React.string} </dt>
      <dd> {React.string(hasBye ? "Ja" : "Nein")} </dd>
      <dt> {"Alte Gegner"->React.string} </dt>
      <dd>
        <ol> opponentResults </ol>
      </dd>
      <dt> {"Blacklist"->React.string} </dt>
      <dd>
        <ul> avoidListHtml </ul>
      </dd>
    </dl>
  }
}

module MatchRow = {
  @react.component
  let make = (
    ~isCompact=false,
    ~pos,
    ~m: Match.t,
    ~roundId,
    ~selectedMatch=?,
    ~setSelectedMatch,
    ~scoreData,
    ~tournament: LoadTournament.t,
    ~className="",
    ~avoidPairs,
  ) => {
    let {tourney, setTourney, players, getPlayer, playersDispatch, _} = tournament
    let {roundList, _} = tourney
    let dialog = Hooks.useBool(false)
    let whitePlayer = getPlayer(m.whiteId)
    let blackPlayer = getPlayer(m.blackId)

    let resultDisplay = (playerColor: Scoring.Color.t) => {
      let won = <Icons.Award className="pageround__wonicon" />
      let lost = <Externals.VisuallyHidden> {React.string("Verloren")} </Externals.VisuallyHidden>
      let aborted =
        <span
          ariaLabel="Unentschieden"
          role="img"
          style={ReactDOM.Style.make(~filter="grayscale(60%)", ())}>
          {React.string("❌")}
        </span>
      switch m.result {
      | NotSet => <Externals.VisuallyHidden> {React.string("unset")} </Externals.VisuallyHidden>
      | Draw =>
        <span
          ariaLabel="Unentschieden"
          role="img"
          style={ReactDOM.Style.make(~filter="grayscale(70%)", ())}>
          {React.string("🤝")}
        </span>
      | BlackWon =>
        switch playerColor {
        | White => lost
        | Black => won
        }
      | WhiteWon =>
        switch playerColor {
        | White => won
        | Black => lost
        }
      | Aborted => aborted
      | WhiteAborted =>
        switch playerColor {
        | White => aborted
        | Black => won
        }
      | BlackAborted =>
        switch playerColor {
        | White => won
        | Black => aborted
        }
      }
    }

    let setMatchResult = jsResultCode => {
      let newResult = Match.Result.fromString(jsResultCode)
      let {whiteId, blackId, _} = m

      /* if it hasn't changed, then do nothing */
      if m.result != newResult {
        let whiteOpt = players->Map.get(whiteId)
        let blackOpt = players->Map.get(blackId)
        let (whiteNewRating, blackNewRating) = switch (newResult, whiteOpt, blackOpt) {
        | (_, None, _)
        | (_, _, None)
        | (Aborted | WhiteAborted | BlackAborted | NotSet, _, _) => (
            m.whiteOrigRating,
            m.blackOrigRating,
          )
        | (BlackWon | WhiteWon | Draw, Some(white), Some(black)) =>
          Ratings.calcNewRatings(
            ~whiteRating=m.whiteOrigRating,
            ~blackRating=m.blackOrigRating,
            ~whiteMatchCount=white.matchCount,
            ~blackMatchCount=black.matchCount,
            ~result=newResult,
          )
        }
        let whiteOpt = Option.map(whiteOpt, white => Player.setRating(white, whiteNewRating))
        let blackOpt = Option.map(blackOpt, black => Player.setRating(black, blackNewRating))
        if !Match.isBye(m) {
          switch m.result {
          /* If the result hasn't been scored yet, increment the matchCounts */
          | NotSet =>
            Option.forEach(whiteOpt, white =>
              playersDispatch(Set(whiteId, Player.succMatchCount(white)))
            )
            Option.forEach(blackOpt, black =>
              playersDispatch(Set(blackId, Player.succMatchCount(black)))
            )
          /* If the result is being un-scored, decrement the matchCounts */
          | WhiteWon | BlackWon | Draw | Aborted | WhiteAborted | BlackAborted
            if newResult == NotSet =>
            Option.forEach(whiteOpt, white =>
              playersDispatch(Set(whiteId, Player.predMatchCount(white)))
            )
            Option.forEach(blackOpt, black =>
              playersDispatch(Set(blackId, Player.predMatchCount(black)))
            )
          /* Simply update the players with new ratings. */
          | WhiteWon | BlackWon | Draw | Aborted | WhiteAborted | BlackAborted =>
            Option.forEach(whiteOpt, white => playersDispatch(Set(whiteId, white)))
            Option.forEach(blackOpt, black => playersDispatch(Set(blackId, black)))
          }
        }
        let newMatch = {...m, result: newResult, whiteNewRating, blackNewRating}
        roundList
        ->Rounds.setMatch(roundId, newMatch)
        ->Option.map(roundList => setTourney({...tourney, roundList}))
        ->ignore
      }
    }
    let setMatchResultBlur = event => setMatchResult(ReactEvent.Focus.target(event)["value"])
    let setMatchResultChange = event => setMatchResult(ReactEvent.Form.target(event)["value"])
    <tr
      className={Cn.append(
        className,
        Cn.mapSome(selectedMatch, id => Id.eq(m.id, id) ? "selected" : ""),
      )}>
      <th className={"pageround__row-id table__number"} scope="row">
        {string_of_int(pos + 1)->React.string}
      </th>
      <td className="pageround__playerresult"> {resultDisplay(White)} </td>
      <Utils.TestId testId={"match-" ++ (string_of_int(pos) ++ "-white")}>
        <td
          className={"table__player row__player " ++ Player.Type.toString(whitePlayer.type_)}
          id={"match-" ++ (string_of_int(pos) ++ "-white")}>
          {whitePlayer->Player.fullName->React.string}
        </td>
      </Utils.TestId>
      <td className="pageround__playerresult"> {resultDisplay(Black)} </td>
      <Utils.TestId testId={"match-" ++ (string_of_int(pos) ++ "-black")}>
        <td
          className={"table__player row__player " ++ Player.Type.toString(blackPlayer.type_)}
          id={"match-" ++ (string_of_int(pos) ++ "-black")}>
          {blackPlayer->Player.fullName->React.string}
        </td>
      </Utils.TestId>
      <td className={"pageround__matchresult data__input row__controls"}>
        <Utils.TestId testId={`match-${Int.toString(pos)}-select`}>
          <select
            className="pageround__winnerSelect"
            value={Match.Result.toString(m.result)}
            onBlur=setMatchResultBlur
            onChange=setMatchResultChange>
            <option value={Match.Result.toString(NotSet)}>
              {React.string("Sieger auswählen")}
            </option>
            <option value={Match.Result.toString(WhiteWon)}>
              {React.string("Weiß gewinnt")}
            </option>
            <option value={Match.Result.toString(BlackWon)}>
              {React.string("Schwarz gewinnt")}
            </option>
            <option value={Match.Result.toString(Draw)}> {React.string("Unentschieden")} </option>
            <option value={Match.Result.toString(Aborted)}> {React.string("Abgebrochen")} </option>
            <option value={Match.Result.toString(WhiteAborted)}>
              {React.string("Weiß abgebrochen")}
            </option>
            <option value={Match.Result.toString(BlackAborted)}>
              {React.string("Schwarz abgebrochen")}
            </option>
          </select>
        </Utils.TestId>
      </td>
      {switch (isCompact, setSelectedMatch) {
      | (false, None)
      | (true, _) => React.null
      | (false, Some(setSelectedMatch)) =>
        <td className={"pageround__controls data__input"}>
          {if selectedMatch->Option.mapWithDefault(true, id => !Id.eq(id, m.id)) {
            <button
              className="button-ghost"
              title="Spiel bearbeiten"
              onClick={_ => setSelectedMatch(_ => Some(m.id))}>
              <Icons.Circle />
              <Externals.VisuallyHidden>
                {`Edit match for ${Player.fullName(whitePlayer)} vs ${Player.fullName(
                    blackPlayer,
                  )}`->React.string}
              </Externals.VisuallyHidden>
            </button>
          } else {
            <button
              className="button-ghost button-pressed"
              title="Bearbeitung beenden"
              onClick={_ => setSelectedMatch(_ => None)}>
              <Icons.CheckCircle />
            </button>
          }}
          <button
            className="button-ghost" title="Spiel-Infos öffnen." onClick={_ => dialog.setTrue()}>
            <Icons.Info />
            <Externals.VisuallyHidden>
              {`Informationen für: ${Player.fullName(whitePlayer)} vs ${Player.fullName(
                  blackPlayer,
                )}`->React.string}
            </Externals.VisuallyHidden>
          </button>
          {switch scoreData {
          | None => React.null
          | Some(scoreData) =>
            <Externals.Dialog
              isOpen=dialog.state
              onDismiss={_ => dialog.setFalse()}
              ariaLabel="Spielinformationen"
              className="">
              <button className="button-micro button-primary" onClick={_ => dialog.setFalse()}>
                {React.string("Fertig")}
              </button>
              <p> {React.string(tourney.name)} </p>
              <p>
                {`Runde ${Int.toString(roundId + 1)} Spiel ${Int.toString(pos + 1)}`->React.string}
              </p>
              <Utils.PanelContainer>
                <Utils.Panel>
                  <PlayerMatchInfo
                    player={whitePlayer}
                    origRating=m.whiteOrigRating
                    newRating=Some(m.whiteNewRating)
                    getPlayer
                    scoreData
                    players
                    avoidPairs
                  />
                </Utils.Panel>
                <Utils.Panel>
                  <PlayerMatchInfo
                    player={blackPlayer}
                    origRating=m.blackOrigRating
                    newRating=Some(m.blackNewRating)
                    getPlayer
                    scoreData
                    players
                    avoidPairs
                  />
                </Utils.Panel>
              </Utils.PanelContainer>
            </Externals.Dialog>
          }}
        </td>
      }}
    </tr>
  }
}

module RoundTable = {
  @react.component
  let make = (
    ~isCompact=false,
    ~roundId,
    ~matches,
    ~selectedMatch=?,
    ~setSelectedMatch=?,
    ~tournament,
    ~scoreData=?,
  ) => {
    let ({Config.avoidPairs: avoidPairs, _}, _) = Db.useConfig()
    <table className="pageround__table">
      {if Js.Array.length(matches) == 0 {
        React.null
      } else {
        <>
          <caption className={isCompact ? "title-30" : "title-40"}>
            {React.string("Runde ")}
            {React.int(roundId + 1)}
          </caption>
          <thead>
            <tr>
              <th className="pageround__row-id" scope="col"> {React.string("#")} </th>
              <th scope="col">
                <Externals.VisuallyHidden>
                  {React.string("Ergebnis weiß")}
                </Externals.VisuallyHidden>
              </th>
              <th className="row__player" scope="col"> {React.string("Weiß")} </th>
              <th scope="col">
                <Externals.VisuallyHidden>
                  {React.string("Ergebnis schwarz")}
                </Externals.VisuallyHidden>
              </th>
              <th className="row__player" scope="col"> {React.string("Schwarz")} </th>
              <th className="row__result" scope="col"> {React.string("Ergebnis")} </th>
              {if isCompact {
                React.null
              } else {
                <th className="row__controls" scope="col">
                  <Externals.VisuallyHidden> {React.string("Steuerung")} </Externals.VisuallyHidden>
                </th>
              }}
            </tr>
          </thead>
        </>
      }}
      <tbody className="content">
        {Array.mapWithIndex(matches, (pos, m: Match.t) =>
          <MatchRow
            key={m.id->Data.Id.toString}
            isCompact
            m
            pos
            roundId
            ?selectedMatch
            setSelectedMatch
            scoreData
            tournament
            className="pageround__td"
            avoidPairs
          />
        )->React.array}
      </tbody>
    </table>
  }
}

module Round = {
  @react.component
  let make = (~roundId, ~tournament: LoadTournament.t, ~scoreData) => {
    let {tourney, players, setTourney, playersDispatch, _} = tournament
    let {roundList, _} = tourney
    let (selectedMatch, setSelectedMatch) = React.useState(() => None)

    let unMatch = (matchId, round) => {
      switch round->Rounds.Round.getMatchById(matchId) {
      /* checks if the match has been scored yet & resets the players' records */
      | Some(match) if match.result != NotSet && !Match.isBye(match) =>
        let reset = (id, rating) =>
          switch players->Map.get(id) {
          | Some(player) =>
            playersDispatch(Set(player.id, player->Player.setRating(rating)->Player.predMatchCount))
          | None => () /* Don't try to set dummy or deleted players */
          }
        reset(match.whiteId, match.whiteOrigRating)
        reset(match.blackId, match.blackOrigRating)
      | None | Some(_) => ()
      }
      let newRound = round->Rounds.Round.removeMatchById(matchId)
      switch roundList->Rounds.set(roundId, newRound) {
      | Some(roundList) => setTourney({...tourney, roundList})
      | None => ()
      }
      setSelectedMatch(_ => None)
    }

    let swapColors = (matchId, round) =>
      switch round->Rounds.Round.getMatchById(matchId) {
      | Some(match_) =>
        let newMatch = Match.swapColors(match_)
        roundList
        ->Rounds.setMatch(roundId, newMatch)
        ->Option.map(roundList => setTourney({...tourney, roundList}))
        ->ignore
      | None => ()
      }

    let moveMatch = (matchId, direction, round) =>
      switch Rounds.Round.moveMatch(round, matchId, direction) {
      | None => ()
      | Some(newRound) =>
        switch Rounds.set(roundList, roundId, newRound) {
        | Some(roundList) => setTourney({...tourney, roundList})
        | None => ()
        }
      }

    switch Rounds.get(tourney.roundList, roundId) {
    | None => <Pages.NotFound />
    | Some(matches) =>
      <div className="content-area">
        <div className="toolbar">
          <button
            className="button-micro"
            disabled={selectedMatch == None}
            onClick={_ => selectedMatch->Option.map(unMatch(_, matches))->ignore}>
            <Icons.Trash />
            {React.string(" Entpaaren")}
          </button>
          {React.string(" ")}
          <button
            className="button-micro"
            disabled={selectedMatch == None}
            onClick={_ => selectedMatch->Option.map(swapColors(_, matches))->ignore}>
            <Icons.Repeat />
            {React.string(" Farben tauschen")}
          </button>
          {React.string(" ")}
          <button
            className="button-micro"
            disabled={selectedMatch == None}
            onClick={_ => selectedMatch->Option.map(moveMatch(_, -1, matches))->ignore}>
            <Icons.ArrowUp />
            {React.string(" Nach oben")}
          </button>
          {React.string(" ")}
          <button
            className="button-micro"
            disabled={selectedMatch == None}
            onClick={_ => selectedMatch->Option.map(moveMatch(_, 1, matches))->ignore}>
            <Icons.ArrowDown />
            {React.string(" Nach unten")}
          </button>
        </div>
        {if Rounds.Round.size(matches) == 0 {
          <p> {React.string("Bisher wurden keine Spieler zusammengepaart.")} </p>
        } else {
          React.null
        }}
        <RoundTable
          roundId
          ?selectedMatch
          setSelectedMatch
          tournament
          scoreData
          matches={Rounds.Round.toArray(matches)}
        />
      </div>
    }
  }
}

@react.component
let make = (~roundId, ~tournament) => {
  let {scoreData, unmatched, unmatchedWithDummy, _} = TournamentUtils.useRoundData(
    roundId,
    tournament,
  )
  let unmatchedCount = Map.size(unmatched)
  let activePlayersCount = Map.size(tournament.activePlayers)
  let initialTab = unmatchedCount == activePlayersCount ? 1 : 0
  let (openTab, setOpenTab) = React.useState(() => initialTab)
  /* Auto-switch the tab */
  React.useEffect3(() => {
    if unmatchedCount == activePlayersCount {
      setOpenTab(_ => 1)
    }
    if unmatchedCount == 0 {
      setOpenTab(_ => 0)
    }
    None
  }, (unmatchedCount, activePlayersCount, setOpenTab))
  open Externals.ReachTabs
  <Tabs index=openTab onChange={index => setOpenTab(_ => index)}>
    <TabList>
      <Tab disabled={unmatchedCount == activePlayersCount}>
        <Icons.List />
        {React.string(" Gepaarte Spiele")}
      </Tab>
      <Tab disabled={unmatchedCount == 0}>
        <Icons.Users />
        {` Ungepaarte Spieler (${Int.toString(unmatchedCount)})`->React.string}
      </Tab>
    </TabList>
    <TabPanels>
      <TabPanel>
        <Round roundId tournament scoreData />
      </TabPanel>
      <TabPanel>
        <div>
          {if unmatchedCount != 0 {
            <PairPicker roundId tournament unmatched unmatchedWithDummy scoreData />
          } else {
            React.null
          }}
        </div>
      </TabPanel>
    </TabPanels>
  </Tabs>
}
