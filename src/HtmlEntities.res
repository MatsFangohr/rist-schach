/* 
  Copyright (c) 2022 John Jackson.

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
// Adapted from
// https://github.com/babel/babel/blob/2ae19d01b132f5222e1d5bee2c83921e2f107d70/packages/babel-parser/src/plugins/jsx/xhtml.js

// Removed @inline attributes until v10.1 fixes them.

let quot = "\u0022"
let amp = "&" // Included for completeness.
let apos = "\u0027"
let lt = "<" // Included for completeness.
let gt = ">" // Included for completeness.
let nbsp = "\u00A0"
let iexcl = "\u00A1"
let cent = "\u00A2"
let pound = "\u00A3"
let curren = "\u00A4"
let yen = "\u00A5"
let brvbar = "\u00A6"
let sect = "\u00A7"
let uml = "\u00A8"
let copy = "\u00A9"
let ordf = "\u00AA"
let laquo = "\u00AB"
let not = "\u00AC"
let shy = "\u00AD"
let reg = "\u00AE"
let macr = "\u00AF"
let deg = "\u00B0"
let plusmn = "\u00B1"
let sup2 = "\u00B2"
let sup3 = "\u00B3"
let acute = "\u00B4"
let micro = "\u00B5"
let para = "\u00B6"
let middot = "\u00B7"
let cedil = "\u00B8"
let sup1 = "\u00B9"
let ordm = "\u00BA"
let raquo = "\u00BB"
let frac14 = "\u00BC"
let frac12 = "\u00BD"
let frac34 = "\u00BE"
let iquest = "\u00BF"
let _Agrave = "\u00C0"
let _Aacute = "\u00C1"
let _Acirc = "\u00C2"
let _Atilde = "\u00C3"
let _Auml = "\u00C4"
let _Aring = "\u00C5"
let _AElig = "\u00C6"
let _Ccedil = "\u00C7"
let _Egrave = "\u00C8"
let _Eacute = "\u00C9"
let _Ecirc = "\u00CA"
let _Euml = "\u00CB"
let _Igrave = "\u00CC"
let _Iacute = "\u00CD"
let _Icirc = "\u00CE"
let _Iuml = "\u00CF"
let _ETH = "\u00D0"
let _Ntilde = "\u00D1"
let _Ograve = "\u00D2"
let _Oacute = "\u00D3"
let _Ocirc = "\u00D4"
let _Otilde = "\u00D5"
let _Ouml = "\u00D6"
let times = "\u00D7"
let _Oslash = "\u00D8"
let _Ugrave = "\u00D9"
let _Uacute = "\u00DA"
let _Ucirc = "\u00DB"
let _Uuml = "\u00DC"
let _Yacute = "\u00DD"
let _THORN = "\u00DE"
let szlig = "\u00DF"
let agrave = "\u00E0"
let aacute = "\u00E1"
let acirc = "\u00E2"
let atilde = "\u00E3"
let auml = "\u00E4"
let aring = "\u00E5"
let aelig = "\u00E6"
let ccedil = "\u00E7"
let egrave = "\u00E8"
let eacute = "\u00E9"
let ecirc = "\u00EA"
let euml = "\u00EB"
let igrave = "\u00EC"
let iacute = "\u00ED"
let icirc = "\u00EE"
let iuml = "\u00EF"
let eth = "\u00F0"
let ntilde = "\u00F1"
let ograve = "\u00F2"
let oacute = "\u00F3"
let ocirc = "\u00F4"
let otilde = "\u00F5"
let ouml = "\u00F6"
let divide = "\u00F7"
let oslash = "\u00F8"
let ugrave = "\u00F9"
let uacute = "\u00FA"
let ucirc = "\u00FB"
let uuml = "\u00FC"
let yacute = "\u00FD"
let thorn = "\u00FE"
let yuml = "\u00FF"
let _OElig = "\u0152"
let oelig = "\u0153"
let _Scaron = "\u0160"
let scaron = "\u0161"
let _Yuml = "\u0178"
let fnof = "\u0192"
let circ = "\u02C6"
let tilde = "\u02DC"
let _Alpha = "\u0391"
let _Beta = "\u0392"
let _Gamma = "\u0393"
let _Delta = "\u0394"
let _Epsilon = "\u0395"
let _Zeta = "\u0396"
let _Eta = "\u0397"
let _Theta = "\u0398"
let _Iota = "\u0399"
let _Kappa = "\u039A"
let _Lambda = "\u039B"
let _Mu = "\u039C"
let _Nu = "\u039D"
let _Xi = "\u039E"
let _Omicron = "\u039F"
let _Pi = "\u03A0"
let _Rho = "\u03A1"
let _Sigma = "\u03A3"
let _Tau = "\u03A4"
let _Upsilon = "\u03A5"
let _Phi = "\u03A6"
let _Chi = "\u03A7"
let _Psi = "\u03A8"
let _Omega = "\u03A9"
let alpha = "\u03B1"
let beta = "\u03B2"
let gamma = "\u03B3"
let delta = "\u03B4"
let epsilon = "\u03B5"
let zeta = "\u03B6"
let eta = "\u03B7"
let theta = "\u03B8"
let iota = "\u03B9"
let kappa = "\u03BA"
let lambda = "\u03BB"
let mu = "\u03BC"
let nu = "\u03BD"
let xi = "\u03BE"
let omicron = "\u03BF"
let pi = "\u03C0"
let rho = "\u03C1"
let sigmaf = "\u03C2"
let sigma = "\u03C3"
let tau = "\u03C4"
let upsilon = "\u03C5"
let phi = "\u03C6"
let chi = "\u03C7"
let psi = "\u03C8"
let omega = "\u03C9"
let thetasym = "\u03D1"
let upsih = "\u03D2"
let piv = "\u03D6"
let ensp = "\u2002"
let emsp = "\u2003"
let thinsp = "\u2009"
let zwnj = "\u200C"
let zwj = "\u200D"
let lrm = "\u200E"
let rlm = "\u200F"
let ndash = "\u2013"
let mdash = "\u2014"
let lsquo = "\u2018"
let rsquo = "\u2019"
let sbquo = "\u201A"
let ldquo = "\u201C"
let rdquo = "\u201D"
let bdquo = "\u201E"
let dagger = "\u2020"
let _Dagger = "\u2021"
let bull = "\u2022"
let hellip = "\u2026"
let permil = "\u2030"
let prime = "\u2032"
let _Prime = "\u2033"
let lsaquo = "\u2039"
let rsaquo = "\u203A"
let oline = "\u203E"
let frasl = "\u2044"
let euro = "\u20AC"
let image = "\u2111"
let weierp = "\u2118"
let real = "\u211C"
let trade = "\u2122"
let alefsym = "\u2135"
let larr = "\u2190"
let uarr = "\u2191"
let rarr = "\u2192"
let darr = "\u2193"
let harr = "\u2194"
let crarr = "\u21B5"
let lArr = "\u21D0"
let uArr = "\u21D1"
let rArr = "\u21D2"
let dArr = "\u21D3"
let hArr = "\u21D4"
let forall = "\u2200"
let part = "\u2202"
let exist = "\u2203"
let empty = "\u2205"
let nabla = "\u2207"
let isin = "\u2208"
let notin = "\u2209"
let ni = "\u220B"
let prod = "\u220F"
let sum = "\u2211"
let minus = "\u2212"
let lowast = "\u2217"
let radic = "\u221A"
let prop = "\u221D"
let infin = "\u221E"
let ang = "\u2220"
let and_ = "\u2227"
let or_ = "\u2228"
let cap = "\u2229"
let cup = "\u222A"
let int = "\u222B"
let there4 = "\u2234"
let sim = "\u223C"
let cong = "\u2245"
let asymp = "\u2248"
let ne = "\u2260"
let equiv = "\u2261"
let le = "\u2264"
let ge = "\u2265"
let sub = "\u2282"
let sup = "\u2283"
let nsub = "\u2284"
let sube = "\u2286"
let supe = "\u2287"
let oplus = "\u2295"
let otimes = "\u2297"
let perp = "\u22A5"
let sdot = "\u22C5"
let lceil = "\u2308"
let rceil = "\u2309"
let lfloor = "\u230A"
let rfloor = "\u230B"
let lang = "\u2329"
let rang = "\u232A"
let loz = "\u25CA"
let spades = "\u2660"
let clubs = "\u2663"
let hearts = "\u2665"
let diams = "\u2666"
