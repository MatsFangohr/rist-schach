// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Curry from "rescript/lib/es6/curry.js";
import * as React from "react";
import * as Belt_Map from "rescript/lib/es6/belt_Map.js";
import * as Belt_Set from "rescript/lib/es6/belt_Set.js";
import * as Pervasives from "rescript/lib/es6/pervasives.js";
import * as Db$RistSchach from "../../Db.bs.js";
import * as TestData$RistSchach from "../../testdata/TestData.bs.js";
import * as Data_Player$RistSchach from "../../Data/Data_Player.bs.js";
import * as Data_Rounds$RistSchach from "../../Data/Data_Rounds.bs.js";

function log2(num) {
  return Math.log(num) / Math.log(2.0);
}

function calcNumOfRounds(playerCount) {
  var roundCount = Math.ceil(log2(playerCount));
  if (roundCount !== Pervasives.neg_infinity) {
    return roundCount | 0;
  } else {
    return 0;
  }
}

function tournamentReducer(param, action) {
  return action;
}

function LoadTournament_mock(Props) {
  var children = Props.children;
  var tourneyId = Props.tourneyId;
  var match = React.useReducer(tournamentReducer, Belt_Map.getExn(TestData$RistSchach.tournaments, tourneyId));
  var tourney = match[0];
  var roundList = tourney.roundList;
  var playerIds = tourney.playerIds;
  var match$1 = Db$RistSchach.useAllPlayers(undefined);
  var players = match$1.items;
  var activePlayers = Belt_Map.keep(players, (function (id, param) {
          return Belt_Set.has(playerIds, id);
        }));
  var roundCount = calcNumOfRounds(Belt_Map.size(activePlayers));
  var isItOver = Data_Rounds$RistSchach.size(roundList) >= roundCount;
  var isNewRoundReady = Data_Rounds$RistSchach.size(roundList) === 0 ? true : Data_Rounds$RistSchach.isRoundComplete(roundList, activePlayers, Data_Rounds$RistSchach.size(roundList) - 1 | 0);
  return Curry._1(children, {
              activePlayers: activePlayers,
              getPlayer: (function (param) {
                  return Data_Player$RistSchach.getMaybe(players, param);
                }),
              isItOver: isItOver,
              isNewRoundReady: isNewRoundReady,
              players: players,
              playersDispatch: match$1.dispatch,
              roundCount: roundCount,
              tourney: tourney,
              setTourney: match[1]
            });
}

var make = LoadTournament_mock;

export {
  make ,
}
/* react Not a pure module */
