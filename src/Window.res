/* 
  Copyright (c) 2022 John Jackson.

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
open Belt
open Router

let global_title = "RistSchach"

let formatTitle = x =>
  switch x {
  | "" => global_title
  | title => title ++ " - " ++ global_title
  }

type windowState = {
  isDialogOpen: bool,
  isMobileSidebarOpen: bool,
  title: string,
}

let initialWinState = {isDialogOpen: false, isMobileSidebarOpen: false, title: ""}

type action =
  | SetDialog(bool)
  | SetSidebar(bool)
  | SetTitle(string)

let windowReducer = (state, action) =>
  switch action {
  | SetTitle(title) =>
    Webapi.Dom.document
    ->Webapi.Dom.Document.asHtmlDocument
    ->Option.forEach(Webapi.Dom.HtmlDocument.setTitle(_, formatTitle(title)))
    {...state, title}
  | SetDialog(isDialogOpen) => {...state, isDialogOpen}
  | SetSidebar(isMobileSidebarOpen) => {...state, isMobileSidebarOpen}
  }

module About = {
  @val
  external gitModified: string = "process.env.GIT_MODIFIED"
  @react.component
  let make = () =>
    <article className="win__about">
      <div style={ReactDOM.Style.make(~flex="0 0 48%", ~textAlign="center", ())}>
        <img src=Utils.WebpackAssets.logo height="196" width="196" alt="" />
      </div>
      <div style={ReactDOM.Style.make(~flex="0 0 48%", ())}>
        <h1 className="title" style={ReactDOM.Style.make(~textAlign="left", ())}>
          {React.string("RistSchach")}
        </h1>
        <p> {React.string(`Zuletzt geupdatet am ${gitModified}.`)} </p>
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
    </article>
}

module TitleBar = {
  let toolbarClasses = "win__titlebar-button button-ghost button-ghost-large"
  @react.component
  let make = (~isMobileSidebarOpen, ~title, ~dispatch) =>
    <header className="app__header">
      <button
        className={`mobile-only ${toolbarClasses}`}
        onClick={_ => dispatch(SetSidebar(!isMobileSidebarOpen))}>
        <Icons.Menu />
        <Externals.VisuallyHidden> {React.string("Toggle sidebar")} </Externals.VisuallyHidden>
      </button>
      <div
        className="body-20"
        style={ReactDOM.Style.make(
          ~marginLeft="auto",
          ~marginRight="auto",
          ~textAlign="center",
          ~whiteSpace="nowrap",
          ~overflow="hidden",
          (),
        )}>
        {title->formatTitle->React.string}
      </div>
      <button className=toolbarClasses onClick={_ => dispatch(SetDialog(true))}>
        <Icons.Help />
        <Externals.VisuallyHidden> {React.string("About RistSchach")} </Externals.VisuallyHidden>
      </button>
      <div
        className="pages__title-icon"
        style={ReactDOM.Style.make(~marginTop="auto", ~margin="5px", ())}>
        <img src=Utils.WebpackAssets.logo alt="" height="30" width="30" />
      </div>
    </header>
}

@react.component
let make = (~children, ~className) => {
  let (state, dispatch) = React.useReducer(windowReducer, initialWinState)
  let {isMobileSidebarOpen, isDialogOpen, title} = state
  <div
    className={Cn.append(
      className,
      isMobileSidebarOpen ? "mobile-sidebar-open" : "mobile-sidebar-closed",
    )}>
    <TitleBar isMobileSidebarOpen title dispatch />
    {children(dispatch)}
    <Externals.Dialog
      isOpen=isDialogOpen
      onDismiss={() => dispatch(SetDialog(false))}
      className="win__about-dialog"
      ariaLabel="Über RistSchach">
      <button className="button-micro" onClick={_ => dispatch(SetDialog(false))}>
        {React.string("Fertig")}
      </button>
      <About />
    </Externals.Dialog>
  </div>
}

let noDraggy = e => ReactEvent.Mouse.preventDefault(e)

module DefaultSidebar = {
  @react.component
  let make = (~dispatch) =>
    <nav>
      <ul style={ReactDOM.Style.make(~margin="0", ())}>
        <li>
          <Link to_=Index onDragStart=noDraggy onClick={_ => dispatch(SetSidebar(false))}>
            <Icons.Home />
            <span className="sidebar__hide-on-close">
              {React.string(HtmlEntities.nbsp ++ "Startseite")}
            </span>
          </Link>
        </li>
        <li>
          <Link to_=TournamentList onDragStart=noDraggy onClick={_ => dispatch(SetSidebar(false))}>
            <Icons.Award />
            <span className="sidebar__hide-on-close">
              {React.string(HtmlEntities.nbsp ++ "Turniere")}
            </span>
          </Link>
        </li>
        <li>
          <Link to_=PlayerList onDragStart=noDraggy onClick={_ => dispatch(SetSidebar(false))}>
            <Icons.Users />
            <span className="sidebar__hide-on-close">
              {React.string(HtmlEntities.nbsp ++ "Spieler")}
            </span>
          </Link>
        </li>
        <li>
          <Link to_=TimeCalculator onDragStart=noDraggy onClick={_ => dispatch(SetSidebar(false))}>
            <Icons.Clock />
            <span className="sidebar__hide-on-close">
              {React.string(HtmlEntities.nbsp ++ "Rundenrechner")}
            </span>
          </Link>
        </li>
        <li>
          <Link to_=Options onDragStart=noDraggy onClick={_ => dispatch(SetSidebar(false))}>
            <Icons.Settings />
            <span className="sidebar__hide-on-close">
              {React.string(HtmlEntities.nbsp ++ "Einstellungen")}
            </span>
          </Link>
        </li>
      </ul>
    </nav>
}

let sidebarCallback = dispatch => <DefaultSidebar dispatch />

module Body = {
  @react.component
  let make = (~children, ~windowDispatch, ~footerFunc=?, ~sidebarFunc=sidebarCallback) =>
    <div className={Cn.append("winBody", "winBody-hasFooter"->Cn.onSome(footerFunc))}>
      <div className="win__sidebar"> {sidebarFunc(windowDispatch)} </div>
      <div className="win__content"> children </div>
      {switch footerFunc {
      | Some(footer) => <footer className="win__footer"> {footer()} </footer>
      | None => React.null
      }}
    </div>
}
