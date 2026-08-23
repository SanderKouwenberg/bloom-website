# BLOOM — Sterker in Balans

De website van BLOOM, een online begeleidingsprogramma over de overgang van Anouk de Veen (diëtist) en Shirley Sniekers (bekkenfysiotherapeut).

**Live:** https://sanderkouwenberg.github.io/bloom-website/

## Hoe dit in elkaar zit

Eén pagina, geen framework, geen build-stap. Drie bestanden die ertoe doen:

| Bestand | Wat erin staat |
| --- | --- |
| `index.html` | De hele pagina, met alle tekst |
| `styles.css` | De vormgeving; bovenaan staan de design tokens |
| `assets/` | Logo, favicon en de lettertypen |

Er komt geen enkele externe aanvraag aan te pas: de lettertypen staan in `assets/fonts/` in plaats van bij Google. De site verzamelt geen bezoekersgegevens en gebruikt geen cookies — vandaar dat er geen cookiebanner is.

## Zelf iets wijzigen

**Tekst** staat gewoon in `index.html`. Zoek de zin, pas hem aan, klaar.

**Kleuren, lettergroottes en witruimte** veranderen via de tokens bovenaan `styles.css` (`:root { … }`). Eén waarde daar aanpassen verandert de hele pagina consistent mee — dat is waarvoor ze bestaan. Wijzig kleuren dus daar, niet halverwege de stylesheet.

**Lokaal bekijken:**

```bash
npx serve -l 4321 .
```

Daarna open je http://localhost:4321 in je browser.

## Foto's toevoegen

De pagina heeft vier plekken waar nog een foto moet komen. Ze zijn nu ingevuld met een zichtbaar voorlopig vlak dat vermeldt welke foto er hoort. In `index.html` staat boven elk vlak een regel als:

```html
<!-- Foto volgt: plaats het bestand als assets/img/hero-klaprozen.jpg en vervang dit blok -->
```

Zet het bestand op dat pad en vervang het `<figure>`-blok eronder door een gewone afbeelding met een `alt`-tekst die beschrijft wat er te zien is.

## Publiceren

Elke push naar `main` zet de site binnen een paar minuten live. Er is geen aparte bouwstap of deploy-commando.

```bash
git add -A && git commit -m "beschrijving" && git push
```

## Nog te doen

- **Het e-mailadres bij de contactknop.** Staat nu als placeholder in `index.html`; zoek op `EMAILADRES-NOG-INVULLEN` en verwijder daarna de melding eronder.
- De vier foto's.
- Prijs en duur van het programma, en idealiter één quote van een deelnemer.

## Verantwoording van de teksten

In [`COPY-NOTES.md`](COPY-NOTES.md) staat per sectie welke zinnen letterlijk van Anouk en Shirley komen en welke zijn bijgeschreven. Handig bij het nalezen.

## De map `design/`

Daar staan de werkbestanden van het ontwerpcanvas waarmee de visuele richting is vastgesteld. Ze horen niet bij de website zelf en hebben geen invloed op wat bezoekers zien.
