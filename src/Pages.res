/* 
  Copyright (c) 2022 John Jackson.

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
open Belt

module Splash = {
  @react.component
  let make = () =>
    <div className="pages__container">
      <aside className="pages__hint" />
      <div className="pages__title">
        <div className="pages__title-icon">
          <img src=Utils.WebpackAssets.logo alt="" height="96" width="96" />
        </div>
        <div className="pages__title-text">
          <h1 className="title" style={ReactDOM.Style.make(~fontSize="40px", ())}>
            {React.string("RistSchach")}
          </h1>
        </div>
      </div>
      <footer className={"pages__footer body-20"}>
        <div className="pages__footer-left" />
        <div className="pages__footer-right">
          <p>
            <a className="pages__footer-link" href=Utils.github_url>
              {React.string("Quellcode")}
            </a>
            {React.string(" ist unter der ")}
            <a className="pages__footer-link" href=Utils.license_url>
              {React.string("Mozilla Public License 2.0")}
            </a>
            {React.string(" verfügbar.")}
          </p>
        </div>
      </footer>
    </div>
}

let log2 = num => log(num) /. log(2.0)

let fixNumber = num =>
  if num < 0.0 || num == infinity || num == neg_infinity {
    0.0
  } else {
    num
  }

module TimeCalculator = {
  let updateFloat = (dispatch, minimum, event) => {
    ReactEvent.Form.preventDefault(event)
    let value =
      ReactEvent.Form.currentTarget(event)["value"]
      ->Float.fromString
      ->Option.getWithDefault(minimum)
    let safeValue = value < minimum ? minimum : value
    dispatch(_ => safeValue)
  }

  let updateInt = (dispatch, minimum, event) => {
    ReactEvent.Form.preventDefault(event)
    let value =
      ReactEvent.Form.currentTarget(event)["value"]->Int.fromString->Option.getWithDefault(minimum)
    let safeValue = value < minimum ? minimum : value
    dispatch(_ => safeValue)
  }

  let title = "Rundenrechner"

  @react.component
  let make = () => {
    let minPlayers = 0
    let minBreakTime = 0
    let minTotalTime = 0.5
    let (players, setPlayers) = React.useState(() => 2)
    let (breakTime, setBreakTime) = React.useState(() => 5)
    let (totalTime, setTotalTime) = React.useState(() => 4.0)
    <div className="content-area">
      <h1> {title->React.string} </h1>
      <p className="caption-30">
        {"Bestimme optimale Rundenanzahl und Zeit pro Runde für dein Schachturnier."->React.string}
      </p>
      <form>
        <table style={ReactDOM.Style.make(~margin="0", ())}>
          <tbody>
            <tr>
              <td>
                <label htmlFor="playerCount"> {React.string("Spieleranzahl ")} </label>
              </td>
              <td>
                <input
                  id="playerCount"
                  type_="number"
                  value={Int.toString(players)}
                  onChange={updateInt(setPlayers, minPlayers)}
                  min={Int.toString(minPlayers)}
                  style={ReactDOM.Style.make(~width="40px", ())}
                />
              </td>
            </tr>
            <tr>
              <td>
                <label htmlFor="breakTime"> {React.string("Pausen zwischen Runden ")} </label>
              </td>
              <td>
                <input
                  id="breakTime"
                  type_="number"
                  value={Int.toString(breakTime)}
                  onChange={updateInt(setBreakTime, minBreakTime)}
                  step=5.0
                  min={Int.toString(minBreakTime)}
                  style={ReactDOM.Style.make(~width="40px", ())}
                />
                {React.string(" Minuten")}
              </td>
            </tr>
            <tr>
              <td>
                <label htmlFor="totalTime"> {React.string("Gesamtzeit ")} </label>
              </td>
              <td>
                <input
                  id="totalTime"
                  type_="number"
                  value={Float.toString(totalTime)}
                  onChange={updateFloat(setTotalTime, minTotalTime)}
                  step=0.5
                  min={Float.toString(minTotalTime)}
                  style={ReactDOM.Style.make(~width="40px", ())}
                />
                {React.string(" Stunden")}
              </td>
            </tr>
          </tbody>
        </table>
      </form>
      <dl>
        <dt className="title-20"> {React.string("Optimale Rundenanzahl")} </dt>
        <dd> {players->Int.toFloat->log2->ceil->fixNumber->React.float} </dd>
        <dt className="title-20"> {React.string("Zeit pro Spieler pro Runde")} </dt>
        <dd>
          <span className="title-20">
            {((totalTime *. 60.0 /. players->Int.toFloat->log2->ceil -.
              Int.toFloat(breakTime)) /. 2.0)
            ->ceil
            ->fixNumber
            ->React.float}
            {React.string(" Minuten")}
          </span>
          <span className="caption-20">
            {React.string(" = ((")}
            <strong className="monospace"> {totalTime->React.float} </strong>
            {React.string(" × 60 ÷ ⌈log₂(")}
            <strong className="monospace"> {players->React.int} </strong>
            {React.string(")⌉) - ")}
            <strong className="monospace"> {breakTime->React.int} </strong>
            {React.string(") ÷ 2")}
          </span>
        </dd>
      </dl>
    </div>
  }
}

module NotFound = {
  @react.component
  let make = () => <p className="content-area"> {React.string("Seite nicht gefunden.")} </p>
}
