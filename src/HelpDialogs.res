/* 
  Copyright (c) 2022 John Jackson.

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

module BaseDialog = {
  @react.component
  let make = (~state as {Hooks.state: state, setFalse, _}, ~ariaLabel, ~children) =>
    <Externals.Dialog isOpen=state onDismiss=setFalse ariaLabel className="">
      <button className="button-micro" onClick={_ => setFalse()}> {React.string("Fertig")} </button>
      children
    </Externals.Dialog>
}

module Pairing = {
  @react.component
  let make = (~state, ~ariaLabel) =>
    <BaseDialog state ariaLabel>
      <p>
        {`Ein schweizer Turniersystem ist nur effektiv, wenn man die Spieler nach bestimmten Regeln paarweise zusammentut. Diese per Hand zu bestimmen ist möglich, aber das kann der Computer besser.`->React.string}
      </p>
      <p> {`Das sind die Regeln:`->React.string} </p>
      <ol>
        <li> {`Zwei Spieler sollten sich nie doppelt begegnen.`->React.string} </li>
        <li> {`Spieler sollen Gegner mit der gleichen Punktanzahl erhalten.`->React.string} </li>
        <li>
          {`Innerhalb einer Punktegruppe sollte die obere Hälfte der Spieler mit der unteren Hälfte zusammengepaart werden.`->React.string}
        </li>
        <li>
          {`Spieler sollten alternierend schwarz und weiß spielen, und niemals eine Farbe drei Mal hintereinander spielen.`->React.string}
        </li>
      </ol>
      <p>
        {`Die ersten beiden Regeln sind wichtig, damit das schweizer System funktioniert. Regeln 3 und 4 sorgen für fairere Spiele, sind jedoch nicht zwingend notwendig.`->React.string}
      </p>
      <p>
        {`Man kann nie alle Regeln genau befolgen. Der Algorithmus versucht jedoch, so viele wie möglich zu realisieren. Es kann auch sein, dass der Algorithmus eine scheinbar 'offensichtliche' Lösung nicht wählt, weil eine andere im Gesamtbild besser ist.`->React.string}
      </p>
      <p>
        {`Wenn man Spieler manuell gegeneinander paart, wird angezeigt, wie 'ideal' die Paarung ist. Nehme diesen Wert als Vorschlag.`->React.string}
      </p>
    </BaseDialog>
}

module SwissTournament = {
  @react.component
  let make = (~state, ~ariaLabel) =>
    <BaseDialog state ariaLabel>
      <p>
        {`RistSchach verwendet `->React.string}
        <a href="https://de.wikipedia.org/wiki/Schweizer_System">
          {`das schweizer System `->React.string}
          <Icons.ExternalLink />
        </a>
        {`. Es werden eine festgelegte Menge an Runden gespielt, wobei die Rundenmenge kleiner als die Spielermenge sein muss. Spieler werden je nach ihrem Punktestand zusammengepaart, aber können sich nie doppelt treffen.`->React.string}
      </p>
      <p>
        {`Es werden verschiedene Tiebreak-Strategien verwendet, um Gleichstand zu klären.`->React.string}
      </p>
      <p>
        {`Die nötige Rundenanzahl kann mit dem `->React.string}
        <Router.Link to_=TimeCalculator> {`Rundenrechner`->React.string} </Router.Link>
        {` bestimmt werden.`->React.string}
      </p>
    </BaseDialog>
}

module TieBreaks = {
  let s = x => Data.Scoring.TieBreak.toPrettyString(x)->React.string

  @react.component
  let make = (~state, ~ariaLabel) =>
    <BaseDialog state ariaLabel>
      <p>
        {`Ein schweizer System wird immer unentschiedene Ergebnisse hervorbringen. Hier sind verschiedene Tiebreak-Strategien aus dem `->React.string}
        <a href="http://www.uschess.org/content/view/7752/369/">
          {`USCF Rulebook `->React.string}
        </a>
        {`aufgezählt. Sie können für jedes Turnier deaktiviert oder eine andere Priorität zugewiesen bekommen.`->React.string}
      </p>
      <dl>
        <dt className="title-20">
          {`§ 34E1 `->React.string}
          {s(Median)}
        </dt>
        <dd>
          {`Summe der Punkte der Gegner, ohne den jeweils höchsten und niedrigsten Wert.`->React.string}
        </dd>
        <dt className="title-20">
          {`§ 34E2 `->React.string}
          {s(Solkoff)}
        </dt>
        <dd>
          {`Wie 'modified median', aber mit dem jeweils höchsten und niedrigsten Wert.`->React.string}
        </dd>
        <dt className="title-20">
          {`§ 34E3 `->React.string}
          {s(Cumulative)}
        </dt>
        <dd>
          {`Die Summe der Punkte nach jeder Runde für einen bestimmten Spieler. Bevorzugt Spieler, die früher im Turnier gewonnen haben (mit der Annahme, dass sie später stärkere Gegner hatten).`->React.string}
        </dd>
        <dt className="title-20">
          {`§ 34E9 `->React.string}
          {s(CumulativeOfOpposition)}
        </dt>
        <dd> {`Summe des 'Cumulative'-Wertes der Gegner eines Spielers.`->React.string} </dd>
        <dt className="title-20">
          {`§ 34E6 `->React.string}
          {s(MostBlack)}
        </dt>
        <dd>
          {`Die Anzahl der mit schwarz gespielten Spiele - mit weiß gespielten Spiele. Geht davon aus, dass weiß stärker als schwarz ist.`->React.string}
        </dd>
      </dl>
    </BaseDialog>
}
