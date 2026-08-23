# Werkafspraken voor dit project

Lees eerst `README.md` voor de opbouw van het project. Hieronder staat alleen wat je daaruit niet kunt afleiden.

## Taal

De site en alle documentatie zijn Nederlands. Commitberichten ook.

## Vormgeving: vastgelegde afspraken

Deze zijn niet vrijblijvend — ze zijn het resultaat van meerdere correctierondes met de opdrachtgever en de expliciete eis dat de site niet als AI-werk mag lezen.

- **Het roze-naar-gele logoverloop komt alleen voor in het logo en als haarlijn van 2 px boven een bovenkop.** Nooit als achtergrondvlak, nooit als knopvulling.
- **De interactiekleur is de groene steel uit het logo** (`--accent: #12655A`), niet het roze.
- **De zware condensed grotesk is exclusief van het logo.** Koppen zijn Cormorant Garamond Light, lopende tekst is Karla.
- **Alle kleuren zijn gemeten uit `sources/bloom-logo.png`, niet geschat.** Voeg geen kleuren toe die daar niet uit komen; leid ze af van de bestaande tokens.
- **Structuurbeelden komen één keer voor.** De twee samenkomende lijnen bij "Onze aanpak" zijn eenmalig; herhaal het patroon niet elders, dan wordt het een trucje.
- **Geen genummerde 01/02/03-kaartjes, geen kaartenrasters met afgeronde hoeken en accentrand.** Die zijn expliciet afgekeurd.

Wijzig kleuren, groottes en witruimte via de tokens bovenaan `styles.css`. Dat is het afgesproken controlemechanisme; hardgecodeerde waarden halverwege de stylesheet ondermijnen het.

## Harde technische randvoorwaarden

- **Geen build-stap, geen framework, geen dependencies.** De opdrachtgever moet een tekst kunnen wijzigen zonder toolchain.
- **Nul externe requests.** Geen CDN, geen Google Fonts, geen analytics, geen embeds. Dit is een gezondheidsgerichte site voor Nederlandse bezoekers; externe aanvragen lekken IP-adressen. Controleer dit na elke wijziging (zie hieronder).
- **Geen cookies**, dus ook geen cookiebanner.
- Beweging blijft beperkt tot de bestaande fade-in, met respect voor `prefers-reduced-motion`. Geen scroll-jacking, pinning of parallax.
- Het verbergen voor de fade-in hangt aan de `js`-class op `<html>`. Haal die koppeling niet weg: zonder JavaScript moet de pagina volledig leesbaar blijven.

## Het Instagram-blok is gegenereerd

Alles tussen `<!-- instagram:start -->` en `<!-- instagram:end -->` in `index.html` wordt overschreven door `scripts/fetch-instagram.mjs`. Bewerk het daar niet met de hand, tenzij er nog geen posts worden opgehaald — pas anders het script aan.

De regel "nul externe requests" geldt hier onverkort: het ophalen gebeurt in de GitHub Action, de afbeeldingen worden in de repo gezet en de bezoeker laadt ze van ons eigen adres. Vervang dit nooit door een Instagram-embed of een widget van derden; dat zou tracking-cookies introduceren en een cookiebanner nodig maken.

Het script stopt zonder foutmelding als er geen token is, en laat de pagina ongewijzigd als het ophalen mislukt. Houd dat gedrag intact: een verlopen token mag nooit een lege sectie opleveren.

## Teksten

Schrijf normaal en overtuigend; de opdrachtgevers lezen alles zelf na, dus ingebouwde slagen om de arm zijn niet gewenst. Maar: verzin geen feiten. Prijzen, aantallen deelnemers, duur en testimonials staan niet vast — laat ze weg of markeer ze zichtbaar als placeholder in plaats van iets aannemelijks in te vullen.

Werk je aan de copy, werk dan `COPY-NOTES.md` bij, zodat het onderscheid tussen hun woorden en bijgeschreven tekst blijft kloppen.

Bronmateriaal staat in `sources/` (buiten de repo): de platforminventarisatie, de Instagram-teksten en het logobestand.

## Controleren voor je oplevert

Draai de site met `npx serve -l 4321 .` en controleer in de browser:

```js
// geen externe requests
performance.getEntriesByType('resource').map(r => r.name).filter(n => !n.startsWith(location.origin))
// geen horizontale scroll
document.documentElement.scrollWidth > innerWidth
```

Kijk daarnaast op 375, 768 en 1440 px breed, en tab door de pagina om te zien of de focus overal zichtbaar blijft. Screenshots werken niet in elke omgeving; meten met JavaScript werkt wel.

## Ontwerpcanvas

De visuele richting is vastgesteld in een canvas dat is opgebouwd uit `design/*.dc.html` en `design/canvas.json`. Wil je dat bijwerken, pas dan die bronbestanden aan en bouw het canvas opnieuw op — het gegenereerde `design/bloom-stijlrichting.html` staat bewust niet in de repo.
