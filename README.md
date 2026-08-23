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

## Het Instagram-blok

Onderaan de pagina, vlak boven Contact, staat een blok met de laatste Instagram-posts. Dat werkt anders dan de gebruikelijke Instagram-embed, en met opzet: **de posts worden opgehaald bij het bouwen, niet in de browser van de bezoeker.** Een dagelijkse GitHub Action haalt ze op, zet de afbeeldingen in deze repo en schrijft het blok in `index.html`. De bezoeker krijgt dus gewone afbeeldingen van ons eigen adres.

Dat scheelt: geen scripts van Meta, geen tracking-cookies, geen cookiebanner, en het blok ziet eruit als de rest van de site in plaats van als een ingeplakt Instagram-raster. Hashtags en emoji worden uit de bijschriften gehaald; de link gaat naar de originele post.

**Zolang er geen token is ingesteld, staat er een korte tekst met een link naar het profiel.** Die blijft gewoon staan; er breekt niets.

### Eenmalig instellen

1. **Zet @bloom_swf om naar een Creator- of Business-account.** In de Instagram-app onder Instellingen → Accounttype en tools. Dit is niet optioneel: persoonlijke accounts kunnen sinds december 2024 via geen enkele officiële weg meer worden uitgelezen.
2. Maak op [developers.facebook.com](https://developers.facebook.com/) een app aan en voeg het product **Instagram** toe (de "Instagram API with Instagram Login"). Koppel daar het account.
3. Genereer een access token en wissel het in voor een **long-lived token** — die is 60 dagen geldig. Meta's documentatie beschrijft deze stap onder "Long-Lived Access Tokens".
4. Zet het token in deze repo onder Settings → Secrets and variables → Actions als **`IG_TOKEN`**.
5. Optioneel maar aan te raden: zet ook een **`GH_PAT`** klaar — een fine-grained token met schrijfrechten op de secrets van deze repo. Dan verlengt de Action het Instagram-token elke dag automatisch en hoef je er nooit meer naar om te kijken. Zonder dit moet `IG_TOKEN` elke twee maanden met de hand worden vervangen; de Action waarschuwt daarover in het logboek.
6. Start de workflow één keer handmatig via het tabblad **Actions → Instagram-posts bijwerken → Run workflow**.

### Aantal posts wijzigen

In `.github/workflows/instagram.yml` staat `IG_LIMIT: '3'`. De vormgeving is op drie afgestemd.

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
