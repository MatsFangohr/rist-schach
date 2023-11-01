// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Belt_Map from "rescript/lib/es6/belt_Map.js";
import * as Belt_Set from "rescript/lib/es6/belt_Set.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Data_Id$RistSchach from "../Data/Data_Id.bs.js";
import * as TestData$RistSchach from "../testdata/TestData.bs.js";
import * as Data_Auth$RistSchach from "../Data/Data_Auth.bs.js";
import * as Data_Config$RistSchach from "../Data/Data_Config.bs.js";
import * as Data_Player$RistSchach from "../Data/Data_Player.bs.js";
import * as LocalForage_Id$RistSchach from "../Externals/LocalForage_Id.bs.js";
import * as Data_Tournament$RistSchach from "../Data/Data_Tournament.bs.js";
import * as LocalForage_Map$RistSchach from "../Externals/LocalForage_Map.bs.js";

function func(prim0, prim1, prim2, prim3, prim4, prim5, prim6) {
  var tmp = {
    name: prim2,
    storeName: prim4
  };
  if (prim0 !== undefined) {
    tmp.description = prim0;
  }
  if (prim1 !== undefined) {
    tmp.driver = Caml_option.valFromOption(prim1);
  }
  if (prim3 !== undefined) {
    tmp.size = prim3;
  }
  if (prim5 !== undefined) {
    tmp.version = prim5;
  }
  return tmp;
}

var Config = LocalForage_Id$RistSchach.MakeEncodable({
      encode: Data_Config$RistSchach.encode,
      decode: Data_Config$RistSchach.decode
    });

var Player = LocalForage_Id$RistSchach.MakeEncodable({
      encode: Data_Player$RistSchach.encode,
      decode: Data_Player$RistSchach.decode
    });

var Tournament = LocalForage_Id$RistSchach.MakeEncodable({
      encode: Data_Tournament$RistSchach.encode,
      decode: Data_Tournament$RistSchach.decode
    });

var tournaments = LocalForage_Map$RistSchach.make(func(undefined, undefined, "RistSchach", undefined, "Tournaments", undefined, undefined), Tournament);

function loadDemoDB(param) {
  
}

function genericDbReducer(state, action) {
  switch (action.TAG | 0) {
    case /* Del */0 :
        return Belt_Map.remove(state, action._0);
    case /* Set */1 :
        return Belt_Map.set(state, action._0, action._1);
    case /* SetAll */2 :
        return action._0;
    
  }
}

function configReducer(state, action) {
  switch (action.TAG | 0) {
    case /* AddAvoidPair */0 :
        return {
                avoidPairs: Belt_Set.add(state.avoidPairs, action._0),
                byeValue: state.byeValue,
                lastBackup: state.lastBackup
              };
    case /* DelAvoidPair */1 :
        return {
                avoidPairs: Belt_Set.remove(state.avoidPairs, action._0),
                byeValue: state.byeValue,
                lastBackup: state.lastBackup
              };
    case /* DelAvoidSingle */2 :
        var id = action._0;
        return {
                avoidPairs: Belt_Set.keep(state.avoidPairs, (function (pair) {
                        return !Data_Id$RistSchach.Pair.has(pair, id);
                      })),
                byeValue: state.byeValue,
                lastBackup: state.lastBackup
              };
    case /* SetAvoidPairs */3 :
        return {
                avoidPairs: action._0,
                byeValue: state.byeValue,
                lastBackup: state.lastBackup
              };
    case /* SetByeValue */4 :
        return {
                avoidPairs: state.avoidPairs,
                byeValue: action._0,
                lastBackup: state.lastBackup
              };
    case /* SetState */5 :
        return action._0;
    case /* SetLastBackup */6 :
        return {
                avoidPairs: state.avoidPairs,
                byeValue: state.byeValue,
                lastBackup: action._0
              };
    
  }
}

function useAllItemsFromDb(data) {
  var match = React.useReducer(genericDbReducer, data);
  return {
          items: match[0],
          dispatch: match[1],
          loaded: true
        };
}

function useAllPlayers(param) {
  return useAllItemsFromDb(TestData$RistSchach.players);
}

function useAllTournaments(param) {
  return useAllItemsFromDb(TestData$RistSchach.tournaments);
}

function useConfig(param) {
  return React.useReducer(configReducer, TestData$RistSchach.config);
}

function useAuth(param) {
  return [
          Data_Auth$RistSchach.$$default,
          (function (param) {
              
            })
        ];
}

export {
  loadDemoDB ,
  Config ,
  Tournament ,
  Player ,
  tournaments ,
  useAllPlayers ,
  useAllTournaments ,
  useConfig ,
  useAuth ,
}
/* Config Not a pure module */
