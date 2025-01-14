/* 
  Copyright (c) 2022 John Jackson.

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
open Belt
open Router
open LoadTournament
open Data

module Footer = {
  @react.component
  let make = (~tournament) => {
    let {roundCount, tourney, isItOver, isNewRoundReady, activePlayers, _} = tournament
    let {roundList, _} = tourney
    let (tooltipText, tooltipKind: Utils.Notification.t) = switch (isNewRoundReady, isItOver) {
    | (true, false) => (HtmlEntities.nbsp ++ " Bereit, eine neue Runde zu beginnen.  ", Success)
    | (false, false) | (false, true) => (HtmlEntities.nbsp ++ "Runde läuft.  ", Generic)
    | (true, true) => (HtmlEntities.nbsp ++ " Alle Runden sind abgeschlossen.  ", Warning)
    }
    <>
      <div className="win__footer-block">
        {React.string("Runde ")}
        {roundList->Rounds.size->React.int}
        <small> {React.string(" von ")} </small>
        {roundCount->React.int}
      </div>
      <hr className="win__footer-divider" />
      <div className="win__footer-block">
        {React.string("Spieler: ")}
        {activePlayers->Map.size->React.int}
      </div>
      <hr className="win__footer-divider" />
      <Utils.Notification
        kind=tooltipKind
        tooltip=tooltipText
        className="win__footer-block"
        style={ReactDOM.Style.make(
          ~backgroundColor="transparent",
          ~color="initial",
          ~display="inline-flex",
          ~margin="0",
          ~minHeight="initial",
          (),
        )}>
        {React.string(tooltipText)}
      </Utils.Notification>
      <div
        className="win__footer-block"
        style={ReactDOM.Style.make(~position="absolute", ~right="0", ())}>
        <p>
          <a href=Utils.github_url>
            {React.string("Quellcode ")}
            <Icons.ExternalLink />
          </a>
          {React.string(" ist unter der ")}
          <a href=Utils.license_url>
            {React.string("Mozilla Public License 2.0 ")}
            <Icons.ExternalLink />
          </a>
          {React.string(" verfügbar.")}
        </p>
      </div>
    </>
  }
}

let footerFunc = (tournament, ()) => <Footer tournament />

let noDraggy = e => ReactEvent.Mouse.preventDefault(e)

module Sidebar = {
  @react.component
  let make = (~tournament, ~windowDispatch) => {
    let {
      tourney,
      isItOver,
      isNewRoundReady,
      activePlayers,
      players,
      playersDispatch,
      setTourney,
      _,
    } = tournament
    let {roundList, _} = tourney
    let isRoundComplete = Rounds.isRoundComplete(roundList, activePlayers)
    let newRound = event => {
      ReactEvent.Mouse.preventDefault(event)
      let confirmText = "Alle Runden sind abgeschlossen. Bist du sicher, dass du eine Neue beginnen möchtest?"
      let confirmed = if isItOver {
        if Webapi.Dom.Window.confirm(Webapi.Dom.window, confirmText) {
          true
        } else {
          false
        }
      } else {
        true
      }
      if confirmed {
        setTourney({...tourney, roundList: Rounds.addRound(roundList)})
      }
    }

    let delLastRound = event => {
      ReactEvent.Mouse.preventDefault(event)
      let message = "Bist du dir sicher, dass du die letzte Runde löschen möchtest?"
      if Webapi.Dom.Window.confirm(Webapi.Dom.window, message) {
        RescriptReactRouter.push("#/tourneys/" ++ tourney.id->Data.Id.toString)
        /* If a match has been scored, then reset it.
         Should this logic be somewhere else? */
        let lastRoundId = Rounds.getLastKey(roundList)
        switch roundList->Rounds.get(lastRoundId) {
        | None => ()
        | Some(round) =>
          round
          ->Rounds.Round.toArray
          ->Array.forEach(match_ => {
            let {result, whiteId, blackId, whiteOrigRating, blackOrigRating, _} = match_
            if result != NotSet && !Match.isBye(match_) {
              /* Don't change players who haven't scored. */
              let reset = (id, rating) =>
                switch players->Map.get(id) {
                | Some(player) =>
                  playersDispatch(
                    Set(player.id, player->Player.setRating(rating)->Player.predMatchCount),
                  )
                | None => () /* Don't try to set dummy or deleted players */
                }
              reset(whiteId, whiteOrigRating)
              reset(blackId, blackOrigRating)
            }
          })
        }
        setTourney({...tourney, roundList: Rounds.delLastRound(roundList)})
        if Rounds.size(roundList) == 0 {
          /* Automatically remake round 1. */
          setTourney({
            ...tourney,
            roundList: Rounds.addRound(roundList),
          })
        }
      }
    }
    <div>
      <nav>
        <ul style={ReactDOM.Style.make(~marginTop="0", ())}>
          <li>
            <Link
              to_=TournamentList
              onDragStart=noDraggy
              onClick={_ => windowDispatch(Window.SetSidebar(false))}>
              <Icons.ChevronLeft />
              <span className="sidebar__hide-on-close"> {React.string(" Zurück")} </span>
            </Link>
          </li>
        </ul>
        <hr />
        <ul>
          <li>
            <Link
              to_=Tournament(tourney.id, Setup)
              onDragStart=noDraggy
              onClick={_ => windowDispatch(Window.SetSidebar(false))}>
              <Icons.Settings />
              <span className="sidebar__hide-on-close"> {React.string(" Setup")} </span>
            </Link>
          </li>
          <li>
            <Link
              to_=Tournament(tourney.id, Players)
              onDragStart=noDraggy
              onClick={_ => windowDispatch(Window.SetSidebar(false))}>
              <Icons.Users />
              <span className="sidebar__hide-on-close"> {React.string(" Spieler")} </span>
            </Link>
          </li>
          <li>
            <Link
              to_=Tournament(tourney.id, Status)
              onDragStart=noDraggy
              onClick={_ => windowDispatch(Window.SetSidebar(false))}>
              <Icons.Activity />
              <span className="sidebar__hide-on-close"> {React.string(" Status")} </span>
            </Link>
          </li>
          <li>
            <Link
              to_=Tournament(tourney.id, Crosstable)
              onDragStart=noDraggy
              onClick={_ => windowDispatch(Window.SetSidebar(false))}>
              <Icons.Layers />
              <span className="sidebar__hide-on-close"> {React.string(" Crosstable")} </span>
            </Link>
          </li>
          <li>
            <Link
              to_=Tournament(tourney.id, Scores)
              onDragStart=noDraggy
              onClick={_ => windowDispatch(Window.SetSidebar(false))}>
              <Icons.List />
              <span className="sidebar__hide-on-close"> {React.string(" Punktestand")} </span>
            </Link>
          </li>
        </ul>
        <hr />
        <h5 className="sidebar__hide-on-close sidebar__header"> {React.string("Runden")} </h5>
        <ul className="center-on-close">
          {roundList
          ->Rounds.toArray
          ->Array.mapWithIndex((id, _) =>
            <li key={Int.toString(id)}>
              <Link
                to_=Tournament(tourney.id, Round(id))
                onDragStart=noDraggy
                onClick={_ => windowDispatch(Window.SetSidebar(false))}>
                {React.int(id + 1)}
                {if isRoundComplete(id) {
                  <span className={"sidebar__hide-on-close caption-20"}>
                    {React.string(" Abgeschlossen ")}
                    <Icons.Check />
                  </span>
                } else {
                  <span className={"sidebar__hide-on-close caption-20"}>
                    {React.string(" Steht aus ")}
                    <Icons.Alert />
                  </span>
                }}
              </Link>
            </li>
          )
          ->React.array}
        </ul>
      </nav>
      <hr />
      <ul>
        <li>
          <button
            className="sidebar-button"
            disabled={!isNewRoundReady}
            onClick=newRound
            style={ReactDOM.Style.make(~width="100%", ())}>
            <Icons.Plus />
            <span className="sidebar__hide-on-close"> {React.string(" Neue Runde")} </span>
          </button>
        </li>
        <li style={ReactDOM.Style.make(~textAlign="center", ())}>
          <button
            disabled={Rounds.size(roundList) == 0}
            onClick=delLastRound
            className="button-micro sidebar-button"
            style={ReactDOM.Style.make(~marginTop="8px", ~height="fit-content",())}>
            <Icons.Trash />
            <span className="sidebar__hide-on-close">
              {React.string(" Letzte Runde löschen")}
            </span>
          </button>
        </li>
      </ul>
    </div>
  }
}

let sidebarFunc = (tournament, windowDispatch) => <Sidebar windowDispatch tournament />

@react.component
let make = (~tourneyId, ~subPage: TourneyPage.t, ~windowDispatch) =>
  <LoadTournament tourneyId windowDispatch>
    {tournament =>
      <Window.Body
        windowDispatch footerFunc={footerFunc(tournament)} sidebarFunc={sidebarFunc(tournament)}>
        {switch subPage {
        | Players => <PageTourneyPlayers tournament />
        | Scores => <PageTourneyScores tournament />
        | Crosstable => <PageTourneyScores.Crosstable tournament />
        | Setup => <PageTourneySetup tournament />
        | Status => <PageTournamentStatus tournament />
        | Round(roundId) => <PageRound tournament roundId />
        }}
      </Window.Body>}
  </LoadTournament>
