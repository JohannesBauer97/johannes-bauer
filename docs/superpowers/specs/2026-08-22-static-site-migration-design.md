# Migration: Angular-SPA zu statischer Website ohne Build

**Datum:** 2026-08-22
**Status:** Genehmigt (Design), offen für Spec-Review
**Repository:** johannes-bauer (johannes-bauer.de)

## Ziel

Die Website johannes-bauer.de wird von einer Angular-22-SPA auf handgeschriebene
statische HTML-Dateien umgestellt. Kein Build-Schritt, keine Framework-Abhängigkeit,
kein `node_modules`. Das sichtbare Design bleibt unverändert. Hosting bleibt
GitHub Pages unter derselben Domain. Alle bestehenden URLs und Redirects bleiben
funktionsfähig.

## Ausgangslage

Die App enthält neun Komponenten ohne jede Logik — reine Templates. Die einzigen
Angular-Konstrukte im Markup sind fünf `<fa-icon>`-Elemente und drei `routerLink`-
Attribute. Es gibt keine Formulare, keine Event-Handler, keinen State und keine
HTTP-Aufrufe. Die App ist inhaltlich bereits statisch.

Bestehende Abhängigkeiten, die entfallen:

| Abhängigkeit | Zweck heute | Ersatz |
|---|---|---|
| Angular 22 (Core, Router, Platform) | Bootstrapping, Routing | Echte Dateien und Verzeichnisse |
| Tailwind CSS v4 + PostCSS | Sämtliches Styling | Handgeschriebenes `styles.css` |
| FontAwesome (4 Pakete) | 5 Icons | Inline-SVG |
| `@angular/service-worker` (ngsw) | PWA-Caching | Ersatzlos entfernt |

## Nicht-Ziele

- Keine inhaltlichen Textänderungen auf den Seiten.
- Keine Änderung am sichtbaren Design (Farben, Abstände, Schriftgrößen, Hover-Effekte).
- Kein Static-Site-Generator und kein Template-System. Wiederholtes Markup
  (`<head>`-Boilerplate, Footer) wird bewusst dupliziert; bei elf Dateien ist das
  günstiger als ein Build-Schritt.
- Kein Offline-Caching mehr.
- Keine Rückwärtskompatibilität für die `?/pfad`-URL-Form des alten SPA-Hacks.

## Entscheidungen

Getroffen im Brainstorming, hier zur Nachvollziehbarkeit dokumentiert:

1. **Styling:** Handgeschriebenes CSS mit semantischen Klassen. Verworfen wurden
   eingefrorenes Tailwind-Kompilat (verlagert das Build-Problem nur in die Zukunft)
   und das Tailwind Play CDN (~400 KB JS, FOUC, vom Hersteller nicht für Produktion
   empfohlen, und weiterhin ein Framework).
2. **Service Worker:** Ersatzlos entfernen. Ein Kill-Switch-Worker wurde erwogen
   und verworfen — bei der geringen Besucherzahl lohnt er nicht. Das Löschen ist
   selbstheilend: Der Browser prüft bei Navigation auf eine neue Version von
   `ngsw-worker.js`; der 404 führt dazu, dass er die Registrierung selbst abmeldet.
   Bestandsbesucher sehen dadurch einmalig noch die gecachte alte Seite.
3. **Repo-Layout:** Website-Dateien direkt im Repo-Root.
4. **Zusatz-Scope:** Eigene Titel/Meta pro Seite, Sitemap auf saubere URLs,
   Open-Graph-Tags. Alle drei sind additiv und ändern das sichtbare Design nicht.
5. **`?/pfad`-Altlinks:** Keine Kompatibilitätsschicht. Siehe Abschnitt
   "Routing und Redirects".
6. **404-Verhalten:** Echte, gestaltete 404-Seite statt des heutigen stillen
   Redirects auf die Startseite. Begründung: Der stille Redirect erzeugt
   "Soft 404s", die Suchmaschinen als Fehler werten.

Die Entscheidungen 2, 5 und 6 sind bewusst in Kauf genommene Verhaltensänderungen
gegenüber heute. Alle drei sind für Besucher entweder unsichtbar oder einmalig.
Am sichtbaren Design ändert keine von ihnen etwas.

## Zielstruktur

```
/
├── index.html                      Homepage
├── imprint/index.html
├── privacy-policy/index.html
├── terms-and-conditions/index.html
├── daylight/index.html
├── laundry/index.html
├── partywheel/index.html
├── cavemap/index.html
├── ventify/index.html
├── impress/index.html              Redirect auf /imprint/
├── daylight-app/index.html         Redirect auf /daylight/
├── 404.html
├── styles.css
├── assets/img/                     8 Bilder, Pfade unverändert
├── manifest.webmanifest
├── robots.txt
├── sitemap.xml
├── app-ads.txt
├── CNAME
├── .nojekyll
├── README.md
├── docs/
└── .github/workflows/deploy-gh.yml
```

Verzeichnisse statt flacher `.html`-Dateien: GitHub Pages leitet `/imprint`
zuverlässig per 301 auf `/imprint/` weiter und liefert dort `index.html`. Das ist
dokumentiertes Verhalten. Die extensionslose Auflösung von `imprint.html` ist ein
undokumentiertes Extra und wird nicht vorausgesetzt.

## Routing und Redirects

Der SPA-Hack (`404.html` schreibt Pfade in einen `?/pfad`-Query-String um, den
`index.html` zurückübersetzt) entfällt ersatzlos. Echte Dateien brauchen kein
JavaScript-Routing.

| Bestehende URL | Ziel | Mechanismus |
|---|---|---|
| `/` | `/` | Datei |
| `/imprint` | `/imprint/` | GitHub Pages 301 |
| `/terms-and-conditions` | `/terms-and-conditions/` | GitHub Pages 301 |
| `/privacy-policy` | `/privacy-policy/` | GitHub Pages 301 |
| `/daylight` | `/daylight/` | GitHub Pages 301 |
| `/laundry` | `/laundry/` | GitHub Pages 301 |
| `/partywheel` | `/partywheel/` | GitHub Pages 301 |
| `/cavemap` | `/cavemap/` | GitHub Pages 301 |
| `/ventify` | `/ventify/` | GitHub Pages 301 |
| `/impress` | `/imprint/` | Redirect-Seite |
| `/daylight-app` | `/daylight/` | Redirect-Seite |
| unbekannter Pfad | `404.html` | GitHub Pages |

### Bewusst nicht unterstützt: die `?/pfad`-Altform

Die alten SPA-Hack-URLs (`https://johannes-bauer.de/?/imprint`) werden **nicht**
per Skript umgeleitet. Sie liefern künftig die Startseite statt der Zielseite —
kein Fehler, nur die falsche Seite. Das ist eine bewusste Vereinfachung: Die einzige
bekannte Quelle dieser URLs ist die aktuelle `sitemap.xml`, die im Zuge dieser
Migration ohnehin auf saubere URLs umgestellt wird. Die Seite hat wenig Verkehr, der
Aufwand eines Kompatibilitätsskripts steht in keinem Verhältnis.

### Redirect-Seiten

`impress/index.html` und `daylight-app/index.html` enthalten je:

- `<meta http-equiv="refresh" content="0; url=/imprint/">` — die eigentliche Weiterleitung
- `<link rel="canonical" href="https://johannes-bauer.de/imprint/">` — für Suchmaschinen
- Einen sichtbaren Textlink als Fallback

Kein JavaScript. `meta refresh` mit Verzögerung `0` ist praktisch verzögerungsfrei.

## CSS-Architektur

Ein einziges `styles.css` im Root, in vier Blöcken:

1. **Base** — `box-sizing: border-box`, `margin: 0`, Hintergrund `rgb(249, 250, 251)`,
   Tailwinds Default-Font-Stack wörtlich übernommen
   (`ui-sans-serif, system-ui, sans-serif, "Apple Color Emoji", …`), damit die
   Schriftdarstellung identisch bleibt.
2. **Typografie** — die `h1`/`h2`/`h3`-Größen aus dem heutigen `@layer base`-Block
   (`text-2xl`, `text-xl`, `text-lg`) plus die Abstände aus den Komponenten-CSS-Dateien.
3. **Komponenten** — semantische Klassen für die wiederkehrenden Muster:
   `.card`, `.avatar`, `.social-links`, `.app-badge`, `.footer-links`, `.page`.
4. **Seitenspezifisch** — Impressum, Datenschutz, AGB und Cavemap haben heute
   eigenes Komponenten-CSS. Dieses wird über eine Klasse am `<body>` gescopet
   (etwa `.legal h2 { … }`). Keine `<style>`-Blöcke in den Seiten.

Jede Tailwind-Utility-Klasse im heutigen Markup wird einzeln in ihren berechneten
Wert übersetzt, einschließlich `drop-shadow-xs`, `drop-shadow-md`,
`hover:scale-105 transition ease-in-out duration-500`, `select-none` und
`max-w-(--breakpoint-xl)`. Der `sm:`-Breakpoint (640px) wird zu einer Media Query.

Erwartete Größe: unter 8 KB unkomprimiert, gegenüber heute rund 250 KB JS und CSS.

## Icons und Assets

Die fünf FontAwesome-Icons (LinkedIn, Xing, GitHub, Envelope, App Store) werden als
Inline-SVG ins Markup übernommen. Die Pfaddaten stammen aus dem installierten
`node_modules`-Paket und müssen extrahiert werden, **bevor** das Angular-Projekt
gelöscht wird.

FontAwesome-Free-Icons stehen unter CC BY 4.0. Ein Attributions-Kommentar wird im
Markup an passender Stelle gesetzt.

Die acht Bilder werden unverändert nach `assets/img/` übernommen — gleiche Dateien,
gleiche Pfade, damit externe Verlinkungen und Hotlinks weiter funktionieren.

## Service Worker entfernen

`ngsw-worker.js` wird ersatzlos gelöscht, ebenso `ngsw-config.json` und die
`ServiceWorkerModule`-Registrierung. Die neuen Seiten registrieren keinen Service
Worker.

Bestandsbesucher haben den alten Worker noch installiert und bekommen beim nächsten
Aufruf zunächst die gecachte Angular-Seite. Parallel prüft der Browser die
Worker-Datei auf Aktualisierungen; der 404 führt dazu, dass er die Registrierung
entfernt. Ab dem übernächsten Aufruf sehen sie die neue Seite. Ein aktives
Aufräumen ist bei dieser Besucherzahl nicht nötig.

`manifest.webmanifest` bleibt inhaltlich erhalten — die Seite bleibt installierbar,
nur ohne Offline-Cache. Eine Anpassung ist nötig: `scope` und `start_url` stehen
heute auf `"./"` (relativ). Da es künftig echte Unterseiten gibt, würde eine
Installation von `/imprint/` aus dort auch starten. Beide Werte werden deshalb auf
`"/"` gesetzt. Das Manifest wird von allen Seiten verlinkt.

## Kein JavaScript

Als Folge der beiden Vereinfachungen enthält die fertige Seite keinerlei
JavaScript: kein Routing, kein Kompatibilitätsskript, kein Service Worker, keine
Redirect-Skripte. Alle elf HTML-Dateien sind reines Markup plus ein Stylesheet.
Das ist ein prüfbares Abnahmekriterium — siehe Verifikation.

## Metadaten und SEO

Heute teilen sich alle Seiten einen `<title>` und eine Meta-Description, weil es nur
eine `index.html` gibt. Künftig erhält jede Seite:

- Eigenen `<title>` (Muster: `Impressum – Johannes Bauer`)
- Eigene `<meta name="description">`
- `<link rel="canonical">` auf die kanonische URL mit Slash
- Open-Graph-Tags: `og:title`, `og:description`, `og:url`, `og:type`,
  `og:image` (Portrait aus `assets/img/portrait.jpg`)

Die Keyword-Meta-Liste der heutigen `index.html` wird nicht übernommen — sie wird
von Suchmaschinen seit langem ignoriert.

`sitemap.xml` wird auf die echten URLs umgestellt (`https://johannes-bauer.de/imprint/`
statt `https://johannes-bauer.de/?/imprint`), `privacy-policy` ergänzt und `lastmod`
aktualisiert. `robots.txt` und `app-ads.txt` bleiben inhaltlich unverändert.

## Deploy-Workflow

`.github/workflows/deploy-gh.yml` verliert die Node- und Build-Schritte:

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Nicht-Website-Dateien entfernen
    run: rm -rf .git .github docs
  - uses: actions/configure-pages@v5
  - uses: actions/upload-pages-artifact@v3
    with:
      path: '.'
  - uses: actions/deploy-pages@v4
```

Das Entfernen von `.git` ist zwingend — ohne diesen Schritt läge die komplette
Repo-Historie öffentlich unter `/.git/`. `docs/` wird ebenfalls entfernt, damit die
Spezifikationen nicht ausgeliefert werden.

Trigger, Permissions und Concurrency-Einstellungen bleiben wie bisher.

Erwartete Laufzeit: rund zwanzig Sekunden statt bisher etwa zwei Minuten.

## Lokale Entwicklung

```bash
python3 -m http.server 8080
```

Python liefert bei Verzeichnis-URLs dasselbe Verhalten wie GitHub Pages
(`/imprint` → 301 → `/imprint/` → `index.html`), die lokale Vorschau ist damit
aussagekräftig. Ein Hinweis dazu kommt in die `README.md`.

## Verifikation

Handgeschriebenes CSS trägt das Risiko visueller Abweichung. Deshalb ist der
Screenshot-Vergleich verbindlicher Bestandteil der Umsetzung und bestimmt die
Reihenfolge der Arbeit:

1. Angular-App lokal starten (`npm start`), von allen neun Seiten
   Referenz-Screenshots aufnehmen — je in 1280px (Desktop) und 375px (Mobil),
   ergibt 18 Referenzbilder.
2. Erst danach die statischen Seiten erstellen.
3. Statische Version lokal servieren, dieselben 18 Screenshots aufnehmen.
4. Paarweise vergleichen, Abweichungen im CSS nachziehen, bis Deckungsgleichheit
   erreicht ist.

Die Referenz-Screenshots müssen entstehen, **bevor** das Angular-Projekt gelöscht
wird. Nach dem Löschen ist die Referenz nur noch über die Git-Historie
rekonstruierbar.

Zusätzlich zu prüfen:

- Nach dem Deploy wird jede Seiten-URL in beiden Formen einzeln aufgerufen: ohne
  Slash (`/imprint`) und mit Slash (`/imprint/`) — für alle acht Unterseiten. Dazu
  die beiden Redirect-Seiten und ein frei erfundener Pfad für die 404-Seite.
- Alle Seiten werden mit deaktiviertem JavaScript geprüft und müssen unverändert
  aussehen und funktionieren.
- `grep -rn "<script" .` über die fertige Seite liefert keine Treffer.

## Zu löschen

Der Ordner `src/johannes-bauer/` vollständig, darunter:

`package.json`, `package-lock.json`, `angular.json`, `tsconfig.json`,
`tsconfig.app.json`, `tsconfig.spec.json`, `.postcssrc.json`, `ngsw-config.json`,
`node_modules/`, `.idea/`, `.vscode/`, `.editorconfig`, die projekteigene
`README.md` sowie sämtliche `.ts`-Dateien (`main.ts`, `app.module.ts`,
`app-routing.module.ts`, alle neun Komponenten-Klassen).

Die `.html`-, `.css`- und Asset-Dateien werden vorher in die neue Struktur überführt.

Die Root-`README.md` wird aktualisiert: Der Badge-Text "Deploy Angular App to Pages"
und der Satz "Build with Angular" stimmen nach der Migration nicht mehr.

## Risiken

| Risiko | Gegenmaßnahme |
|---|---|
| Visuelle Abweichung durch handgeschriebenes CSS | Screenshot-Vergleich vor/nach, siehe Verifikation |
| Bestandsbesucher sehen einmalig die gecachte alte Seite | Bewusst akzeptiert; der 404 auf `ngsw-worker.js` lässt den Browser die Registrierung selbst entfernen |
| Indexierte `?/pfad`-URLs zeigen die Startseite | Bewusst akzeptiert; `sitemap.xml` wird auf saubere URLs umgestellt, die Quelle entfällt damit |
| Repo-Historie öffentlich unter `/.git/` | `rm -rf .git` im Workflow vor dem Upload |
| FontAwesome-Pfaddaten nach dem Löschen nicht mehr verfügbar | Icons vor dem Löschen extrahieren |
