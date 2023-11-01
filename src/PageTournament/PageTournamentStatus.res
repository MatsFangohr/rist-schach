/* 
  Copyright (c) 2022 John Jackson.

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
open Data

@react.component
let make = (~tournament: LoadTournament.t) => {
  let {tourney, getPlayer, _} = tournament
  let {roundList, _} = tourney
  let lastRoundId = Rounds.getLastKey(tourney.roundList)
  let lastRound = Rounds.get(roundList, lastRoundId)
  <>
    <h2 style={ReactDOM.Style.make(~textAlign="center", ())}> {React.string("Turnierstatus")} </h2>
    <div className="content-area">
      <Utils.PanelContainer style={ReactDOM.Style.make(~justifyContent="center", ())}>
        <Utils.Panel>
          {switch lastRound {
          | None => <p> {React.string("Bisher wurden keine Runden gespielt.")} </p>
          | Some(matches) =>
            if Rounds.Round.size(matches) == 0 {
              <p>
                {React.string(
                  "Gepaarten Spieler der aktuellen Runde werden hier angezeigt werden.",
                )}
              </p>
            } else {
              <PageRound.RoundTable
                roundId=lastRoundId
                tournament
                isCompact=true
                matches={Rounds.Round.toArray(matches)}
              />
            }
          }}
        </Utils.Panel>
        <Utils.Panel>
          <PageTourneyScores.ScoreTable getPlayer title="Rankings" tourney size=Compact />
        </Utils.Panel>
      </Utils.PanelContainer>
    </div>
  </>
}
