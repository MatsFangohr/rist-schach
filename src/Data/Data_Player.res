/* 
  Copyright (c) 2022 John Jackson.

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
module Option = Belt.Option

module Type = {
  type t = Person | Dummy | Missing

  let toString = data =>
    switch data {
    | Person => "person"
    | Dummy => "dummy"
    | Missing => "missing"
    }

  let fromString = str =>
    switch str {
    | "person" => Person
    | "dummy" => Dummy
    | "missing" => Missing
    | _ => Person
    }

  let encode = data => data->toString->Js.Json.string

  let decode = data => Js.Json.decodeString(data)->Option.getExn->fromString
}

module NatInt = {
  type t = int

  let fromInt = x =>
    if x < 0 {
      0
    } else {
      x
    }

  let toInt = x => x
  let toString = string_of_int

  let succ = x =>
    if x < 0 {
      0
    } else {
      succ(x)
    }

  let pred = x =>
    if x < 1 {
      0
    } else {
      pred(x)
    }
}

type t = {
  firstName: string,
  id: Data_Id.t,
  lastName: string,
  matchCount: NatInt.t,
  rating: int,
  type_: Type.t,
}

let fullName = t => t.firstName ++ " " ++ t.lastName

let compareName = (a, b) =>
  switch compare(a.firstName, b.firstName) {
  | 0 => compare(a.lastName, b.lastName)
  | i => i
  }

let succMatchCount = t => {...t, matchCount: NatInt.succ(t.matchCount)}
let predMatchCount = t => {...t, matchCount: NatInt.pred(t.matchCount)}

let setRating = (t, rating) => {...t, rating}

let decode = json => {
  let d = Js.Json.decodeObject(json)
  {
    id: d->Option.flatMap(d => Js.Dict.get(d, "id"))->Option.getExn->Data_Id.decode,
    firstName: d
    ->Option.flatMap(d => Js.Dict.get(d, "firstName"))
    ->Option.flatMap(Js.Json.decodeString)
    ->Option.getExn,
    lastName: d
    ->Option.flatMap(d => Js.Dict.get(d, "lastName"))
    ->Option.flatMap(Js.Json.decodeString)
    ->Option.getExn,
    matchCount: d
    ->Option.flatMap(d => Js.Dict.get(d, "matchCount"))
    ->Option.flatMap(Js.Json.decodeNumber)
    ->Option.getExn
    ->Belt.Float.toInt,
    rating: d
    ->Option.flatMap(d => Js.Dict.get(d, "rating"))
    ->Option.flatMap(Js.Json.decodeNumber)
    ->Option.getExn
    ->Belt.Float.toInt,
    type_: d->Option.flatMap(d => Js.Dict.get(d, "type_"))->Option.getExn->Type.decode,
  }
}

let encode = data =>
  Js.Dict.fromArray([
    ("firstName", data.firstName->Js.Json.string),
    ("id", data.id->Data_Id.encode),
    ("lastName", data.lastName->Js.Json.string),
    ("matchCount", data.matchCount->Belt.Float.fromInt->Js.Json.number),
    ("rating", data.rating->Belt.Float.fromInt->Js.Json.number),
    ("type_", data.type_->Type.encode),
  ])->Js.Json.object_

let dummy = {
  id: Data_Id.dummy,
  firstName: "[Bye]",
  lastName: "",
  type_: Dummy,
  matchCount: 0,
  rating: 0,
}

/**
 * If `getMaybe` can't find a profile (e.g. if it was deleted) then it
 * outputs this instead. The ID will be the same as missing player's ID.
 */
let makeMissing = id => {
  id,
  firstName: "Anonymous",
  lastName: "Player",
  type_: Missing,
  matchCount: 0,
  rating: 0,
}

let getMaybe = (playerMap, id) =>
  if Data_Id.isDummy(id) {
    dummy
  } else {
    Belt.Map.getWithDefault(playerMap, id, makeMissing(id))
  }
