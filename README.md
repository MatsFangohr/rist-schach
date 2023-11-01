<div align="center">
<img alt="Logo" src="graphics/logo.svg" height="128" width="128" />
<h1>RistSchach</h1>
<p>RistSchach ist eine Web-App für Turniere im Schweizersystem.</p>
</div>

## About

RistSchach ist ein kostenloser Schachturniermanager.

## Acknowledgments

RistSchach ist ein Fork von [Coronate](https://github.com/johnridesabike/coronate).

## Algorithmus

Alle Paragraf-Referenzen beziehen sich auf das [USCF Rulebook](http://www.uschess.org/content/view/7752/369/).

### Tiebreak-Regeln

Die folgenden Regeln sind implementiert:

- [x] § 34E1. Modified Median.
- [x] § 34E2. Solkoff.
- [x] § 34E3. Cumulative.
- [x] § 34E9. Cumulative scores of opposition.
- [x] § 34E6. Most blacks.

### Pairings

RistSchach verwendet den [Blossom-Algorithmus](https://en.wikipedia.org/wiki/Blossom_algorithm), um Spieler paarweise zusammenzubringen.

Die implementierten Regeln, die verwendet werden, um die Pairings zu schaffen, sind wie folgt:

- [x] § 27A1. Avoid players meeting twice.
- [x] § 27A2. Equal scores.
- [x] § 27A3. Upper half vs. lower half.
- [x] § 27A4. Equalizing colors.
- [ ] § 27A5. Alternating colors.
- [x] § 29A. Score groups and rank.
- [x] § 29C1. Upper half vs. lower half.
- [x] § 29D. The odd player.
- [ ] § 29E3. Due Colors in succeeding rounds.
- [ ] § 29E4. Equalization, alternation, and priority of color. (teilweise implementiert)
- [ ] § Variation 29E4a. Priority based on plus, even, and minus score groups.
  - [ ] § Variation 29E4b. Alternating priority.
  - [ ] § Variation 29E4c. Priority based on lot.
  - [ ] § Variation 29E4d. Priority based on rank.
- [ ] § 29E5. Colors vs. ratings.
  - [ ] 29E5a. The 80-point rule.
  - [ ] 29E5b. The 200-point rule.
- [ ] § 29E6. Color adjustment technique.
