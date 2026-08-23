# Migration zu statischer Website — Implementierungsplan

> **Für agentische Bearbeiter:** ERFORDERLICHE SUB-SKILL: Nutze
> `superpowers:subagent-driven-development` (empfohlen) oder
> `superpowers:executing-plans`, um diesen Plan Aufgabe für Aufgabe umzusetzen.
> Die Schritte verwenden Checkbox-Syntax (`- [ ]`) zur Nachverfolgung.

**Ziel:** Die Angular-22-SPA johannes-bauer.de wird durch elf handgeschriebene
statische HTML-Dateien plus ein Stylesheet ersetzt, ohne Build-Schritt und ohne
sichtbare Designänderung.

**Architektur:** Echte Dateien und Verzeichnisse statt Client-Routing. Ein
globales `styles.css` mit semantischen Klassen ersetzt Tailwind. Die exakten
CSS-Werte werden nicht geschätzt, sondern in Task 1 aus dem kompilierten
Tailwind-Stylesheet der App extrahiert. Das Deployment lädt das Repository
unverändert zu GitHub Pages hoch.

**Tech-Stack:** HTML5, CSS3, kein JavaScript, kein Build. GitHub Actions
(`upload-pages-artifact` / `deploy-pages`). Verifikation per Bash-Skript.

**Spec:** `docs/superpowers/specs/2026-08-22-static-site-migration-design.md`

## Global Constraints

Diese Vorgaben gelten für jede Aufgabe:

- **Kein JavaScript.** Keine ausgelieferte HTML-Datei enthält ein `<script>`-Tag.
- **Kein Build.** Nach Abschluss keine `package.json`, kein `node_modules`.
- **Design unverändert.** Farben, Abstände, Schriftgrößen, Schatten und
  Hover-Effekte müssen dem heutigen Zustand entsprechen.
- **DOM-Struktur beibehalten.** Beim Übersetzen einer Seite bleibt die
  Verschachtelung identisch; nur `class`-Attribute ändern sich, und `<fa-icon>`
  wird zu Inline-SVG. Keine Elemente hinzufügen oder entfernen.
- **Texte unverändert.** Kein Wort der Seiteninhalte wird geändert, auch keine
  HTML-Entities (`&szlig;`, `&shy;`, `&#64;`, `&bdquo;` bleiben wie sie sind).
- **Alle internen Referenzen root-absolut:** `/styles.css`,
  `/assets/img/portrait.jpg`, `/imprint/`. Relative Pfade würden aus
  Unterverzeichnissen heraus brechen (`/daylight/assets/…`). Die physische
  Ablage der Bilder bleibt `assets/img/`, externe Hotlinks auf
  `https://johannes-bauer.de/assets/img/portrait.jpg` funktionieren weiter —
  darauf zielte die Spec-Vorgabe.
- **Domain:** `https://johannes-bauer.de`
- **Kanonische URLs:** mit abschließendem Slash, z. B.
  `https://johannes-bauer.de/imprint/`
- **Deploy-Strip-Liste:** `.git`, `.github`, `docs`, `tools`.
- **Seitensprache:** `lang="de"` für Homepage, Impressum, Datenschutz, AGB,
  Daylight, Laundry, Partywheel und 404. `lang="en"` für Cavemap und Ventify —
  deren Inhalte sind englisch.
- **Keine `?/pfad`-Kompatibilität.** Der alte SPA-Hack wird nicht nachgebaut.
  Kommt die Idee beim Umsetzen auf: sie wurde bewusst verworfen, siehe Spec,
  Abschnitt „Bewusst nicht unterstützt". Alte `?/`-URLs landen künftig auf der
  Startseite; das ist das gewünschte Verhalten.
- **Commit nach jeder Task.** Kein Sammel-Commit am Ende.
- **Quelldateien bleiben bis Task 11 erhalten.** Jede Seiten-Task liest ihr
  Markup aus `src/johannes-bauer/src/app/<komponente>/`. Erst Task 11 löscht.

---

## Dateistruktur

| Datei | Verantwortung |
|---|---|
| `index.html` | Homepage: Portrait, Name, Rolle, vier Social-Links, Footer |
| `imprint/index.html` | Impressum |
| `privacy-policy/index.html` | Datenschutzerklärung der Website |
| `terms-and-conditions/index.html` | AGB / EULA |
| `daylight/index.html` | App-Seite Daylight |
| `laundry/index.html` | App-Seite Laundry Symbols |
| `partywheel/index.html` | App-Seite Partywheel |
| `cavemap/index.html` | Cave Map Privacy Policy (englisch) |
| `ventify/index.html` | Ventify Privacy Policy (englisch) |
| `impress/index.html` | Weiterleitung auf `/imprint/` |
| `daylight-app/index.html` | Weiterleitung auf `/daylight/` |
| `404.html` | Fehlerseite mit Link zur Startseite |
| `styles.css` | Einziges Stylesheet |
| `assets/img/*` | Acht Bilder, unverändert |
| `manifest.webmanifest` | PWA-Manifest, `scope`/`start_url` auf `/` |
| `sitemap.xml` | Neun kanonische URLs |
| `robots.txt`, `app-ads.txt`, `CNAME`, `.nojekyll` | unverändert |
| `tools/verify.sh` | Verifikationsskript, 12 Checks, nicht ausgeliefert |
| `tools/tailwind-reference.css` | Wertequelle, nicht ausgeliefert |
| `tools/icons/*.svg` | Extrahierte Icons, nicht ausgeliefert |
| `.github/workflows/deploy-gh.yml` | Deployment ohne Build |

**Reihenfolge:** Task 1 zuerst, solange das Angular-Projekt existiert.
Task 11 (Löschen) zuletzt.

---

### Task 1: Referenzdaten aus dem Angular-Projekt extrahieren

Erzeugt die Wertequelle für alle folgenden Aufgaben.

**Files:**
- Create: `tools/tailwind-reference.css`
- Create: `tools/icons/github.svg`, `tools/icons/linkedin.svg`,
  `tools/icons/xing.svg`, `tools/icons/envelope.svg`, `tools/icons/app-store.svg`

**Interfaces:**
- Produces: `tools/tailwind-reference.css` — das kompilierte Tailwind-Stylesheet
  des Produktionsbuilds. Enthält für jede der 86 verwendeten Klassen die exakte
  Regel samt `@media`- und `:hover`-Varianten sowie den `:root`-Block mit allen
  Farbvariablen. Einzige zulässige Wertequelle für Task 4.
- Produces: `tools/icons/*.svg` — je ein vollständiges `<svg>`-Element mit
  `viewBox`, `fill="currentColor"` und Pfaddaten. Verwendet von Task 5
  (github, linkedin, xing, envelope) und Task 6 (app-store).

- [ ] **Schritt 1: Abhängigkeiten installieren**

```bash
cd src/johannes-bauer && npm install
```

- [ ] **Schritt 2: Produktionsbuild erzeugen**

```bash
cd src/johannes-bauer && npm run build && ls -la dist/johannes-bauer/browser/*.css
```

Erwartet: genau eine `.css`-Datei mit Hash im Namen. Sie enthält sämtliche
Tailwind-Regeln aller neun Seiten in einer Datei — der Dev-Server tut das nicht
zuverlässig, deshalb der Produktionsbuild.

- [ ] **Schritt 3: Stylesheet als Referenz sichern**

```bash
mkdir -p tools && cp src/johannes-bauer/dist/johannes-bauer/browser/*.css tools/tailwind-reference.css
```

- [ ] **Schritt 4: Vollständigkeit prüfen**

```bash
missing=0
for c in 'bg-gray-50' 'drop-shadow-xs' 'shadow-md' 'rounded-lg' 'text-blue-600' \
         'h-72' 'select-none' 'list-decimal' 'object-cover' 'basis-1'; do
  grep -qF -- "$c" tools/tailwind-reference.css || { echo "FEHLT: $c"; missing=1; }
done
[ "$missing" = 0 ] && echo "OK: Referenz vollstaendig"
```

Erwartet: `OK: Referenz vollstaendig`. Bei Fehlern war der Build unvollständig —
Schritt 2 wiederholen.

Hinweis: Tailwind maskiert `:` und `/` in Selektoren (`.lg\:basis-1\/2`,
`.hover\:scale-105`). Greps auf Klassennamen mit diesen Zeichen müssen die
Maskierung berücksichtigen oder auf einen Teilstring ohne sie ausweichen.

- [ ] **Schritt 5: FontAwesome-Icons extrahieren**

```bash
cd src/johannes-bauer && node -e '
const fs = require("fs");
const out = "../../tools/icons";
fs.mkdirSync(out, { recursive: true });
const brands = require("@fortawesome/free-brands-svg-icons");
const regular = require("@fortawesome/free-regular-svg-icons");
const defs = {
  github: brands.faGithub,
  linkedin: brands.faLinkedin,
  xing: brands.faXing,
  "app-store": brands.faAppStoreIos,
  envelope: regular.faEnvelope,
};
for (const [name, def] of Object.entries(defs)) {
  const a = def.icon;
  const w = a[0], h = a[1], d = a[4];
  const path = Array.isArray(d) ? d.join("") : d;
  const svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 " + w +
    " " + h + "\" fill=\"currentColor\" aria-hidden=\"true\" focusable=\"false\">" +
    "<path d=\"" + path + "\"/></svg>";
  fs.writeFileSync(out + "/" + name + ".svg", svg);
  console.log(name, w + "x" + h);
}
'
```

Erwartet: fünf Zeilen Ausgabe mit Namen und Maßen, z. B. `github 496x512`.

- [ ] **Schritt 6: Icons prüfen**

```bash
ls -la tools/icons/ && for f in tools/icons/*.svg; do
  grep -q '<path d="M' "$f" && echo "OK $f" || echo "DEFEKT $f"
done
```

Erwartet: fünf Dateien, alle `OK`.

- [ ] **Schritt 7: Commit**

```bash
git add tools/ && git commit -m "Referenzdaten aus Angular-Projekt extrahiert"
```

---

### Task 2: Verifikationsskript anlegen

Das Skript definiert die Abnahmekriterien. Es wird geschrieben, **bevor** eine
Seite existiert, und schlägt zunächst überall fehl. Jede folgende Task macht
einen Teil davon grün. Die Checks tragen Nummern (C1…C12), auf die sich spätere
Tasks berufen.

**Files:**
- Create: `tools/verify.sh`

**Interfaces:**
- Produces: `bash tools/verify.sh` — Exit 0 bei bestandener Prüfung, sonst 1.
  Ausgabe je Prüfpunkt eine Zeile `OK` oder `FEHL`. Wird von Task 3 bis 11 als
  Fortschrittsmaß verwendet.

- [ ] **Schritt 1: Skript schreiben**

Datei `tools/verify.sh` mit exakt diesem Inhalt:

```bash
#!/usr/bin/env bash
# Abnahmekriterien der statischen Website johannes-bauer.de
# Aufruf aus dem Repository-Root:  bash tools/verify.sh
set -uo pipefail

PAGES="index.html imprint/index.html privacy-policy/index.html \
terms-and-conditions/index.html daylight/index.html laundry/index.html \
partywheel/index.html cavemap/index.html ventify/index.html"
REDIRECTS="impress/index.html daylight-app/index.html"
ALL_HTML="$PAGES $REDIRECTS 404.html"

fail=0
ok()  { printf '  OK    %s\n' "$1"; }
bad() { printf '  FEHL  %s\n' "$1"; fail=1; }
sec() { printf '\n== %s\n' "$1"; }

sec "C1  Dateibestand"
for f in $ALL_HTML styles.css manifest.webmanifest sitemap.xml robots.txt \
         app-ads.txt CNAME .nojekyll assets/img/portrait.jpg; do
  if [ -f "$f" ]; then ok "$f"; else bad "$f fehlt"; fi
done

sec "C2  Kein JavaScript"
for f in $ALL_HTML; do
  [ -f "$f" ] || continue
  if grep -qi '<script' "$f"; then bad "$f enthaelt <script>"; else ok "$f"; fi
done

sec "C3  Keine Angular-Reste"
for f in $ALL_HTML; do
  [ -f "$f" ] || continue
  if grep -qE 'routerLink|<fa-icon|_ngcontent|<app-root|ng-version|\[icon\]' "$f"
  then bad "$f enthaelt Angular-Markup"; else ok "$f"; fi
done

sec "C4  Keine Tailwind-Utility-Klassen"
TW='(flex-col|bg-gray-50|bg-white|shadow-md|rounded-lg|drop-shadow|max-w-\(|list-inside|justify-center|items-center|mx-auto|hover:)'
for f in $ALL_HTML; do
  [ -f "$f" ] || continue
  if grep -oE 'class="[^"]*"' "$f" | grep -qE "$TW"; then
    bad "$f enthaelt Tailwind-Klassen"
  else ok "$f"; fi
done

sec "C5  Metadaten je Inhaltsseite"
for f in $PAGES; do
  [ -f "$f" ] || { bad "$f fehlt"; continue; }
  miss=""
  grep -q '<title>'                    "$f" || miss="$miss title"
  grep -q 'name="description"'         "$f" || miss="$miss description"
  grep -q 'rel="canonical"'            "$f" || miss="$miss canonical"
  grep -q 'property="og:title"'        "$f" || miss="$miss og:title"
  grep -q 'property="og:description"'  "$f" || miss="$miss og:description"
  grep -q 'property="og:url"'          "$f" || miss="$miss og:url"
  grep -q 'property="og:image"'        "$f" || miss="$miss og:image"
  grep -q 'rel="manifest"'             "$f" || miss="$miss manifest"
  grep -q 'href="/styles.css"'         "$f" || miss="$miss stylesheet"
  grep -q 'name="viewport"'            "$f" || miss="$miss viewport"
  grep -qE '<html lang="(de|en)"'      "$f" || miss="$miss lang"
  if [ -z "$miss" ]; then ok "$f"; else bad "$f fehlt:$miss"; fi
done

sec "C6  Grundmetadaten der 404-Seite"
if [ -f 404.html ]; then
  miss=""
  grep -q '<title>'               404.html || miss="$miss title"
  grep -q 'href="/styles.css"'    404.html || miss="$miss stylesheet"
  grep -q 'name="viewport"'       404.html || miss="$miss viewport"
  grep -q '<html lang="de"'       404.html || miss="$miss lang"
  grep -q 'href="/"'              404.html || miss="$miss home-link"
  if [ -z "$miss" ]; then ok "404.html"; else bad "404.html fehlt:$miss"; fi
else bad "404.html fehlt"; fi

sec "C7  Interne Links aufloesbar"
for f in $ALL_HTML; do
  [ -f "$f" ] || continue
  for href in $(grep -o 'href="/[^"#]*"' "$f" | sed 's/href="//; s/"$//' | sort -u); do
    case "$href" in
      */) t="${href#/}index.html" ;;
      *)  t="${href#/}" ;;
    esac
    if [ -f "$t" ]; then ok "$f -> $href"; else bad "$f -> $href (Ziel $t fehlt)"; fi
  done
done

sec "C8  Bildreferenzen aufloesbar"
for f in $ALL_HTML; do
  [ -f "$f" ] || continue
  for src in $(grep -o 'src="[^"]*"' "$f" | sed 's/src="//; s/"$//'); do
    case "$src" in http*) continue ;; /*) t="${src#/}" ;; *) t="$src" ;; esac
    if [ -f "$t" ]; then ok "$f -> $src"; else bad "$f -> $src fehlt"; fi
  done
done

sec "C9  Redirect-Seiten"
check_redirect() {
  local file="$1" target="$2"
  [ -f "$file" ] || { bad "$file fehlt"; return; }
  local miss=""
  grep -q "url=$target"                                  "$file" || miss="$miss meta-refresh"
  grep -q "rel=\"canonical\" href=\"https://johannes-bauer.de$target\"" \
                                                         "$file" || miss="$miss canonical"
  grep -q "href=\"$target\""                             "$file" || miss="$miss fallback-link"
  if [ -z "$miss" ]; then ok "$file -> $target"; else bad "$file fehlt:$miss"; fi
}
check_redirect impress/index.html /imprint/
check_redirect daylight-app/index.html /daylight/

sec "C10 Sitemap"
if [ -f sitemap.xml ]; then
  if grep -q '?/' sitemap.xml; then bad "sitemap enthaelt noch ?/-URLs"
  else ok "keine ?/-URLs"; fi
  n=$(grep -c '<loc>' sitemap.xml)
  if [ "$n" = 9 ]; then ok "9 URLs"; else bad "sitemap hat $n URLs, erwartet 9"; fi
  for u in / /imprint/ /privacy-policy/ /terms-and-conditions/ /daylight/ \
           /laundry/ /partywheel/ /cavemap/ /ventify/; do
    if grep -q "<loc>https://johannes-bauer.de$u</loc>" sitemap.xml
    then ok "$u"; else bad "$u fehlt in sitemap"; fi
  done
else bad "sitemap.xml fehlt"; fi

sec "C11 Manifest"
if [ -f manifest.webmanifest ]; then
  if grep -q '"scope": *"/"'     manifest.webmanifest; then ok "scope"
  else bad "scope ist nicht \"/\""; fi
  if grep -q '"start_url": *"/"' manifest.webmanifest; then ok "start_url"
  else bad "start_url ist nicht \"/\""; fi
else bad "manifest.webmanifest fehlt"; fi

sec "C12 Keine Build- und PWA-Reste im Root"
for f in package.json package-lock.json angular.json tsconfig.json \
         ngsw-config.json ngsw-worker.js .postcssrc.json; do
  if [ -e "$f" ]; then bad "$f existiert noch"; else ok "$f entfernt"; fi
done
if [ -d src/johannes-bauer ]; then bad "src/johannes-bauer existiert noch"
else ok "src/johannes-bauer entfernt"; fi
if [ -f .github/workflows/deploy-gh.yml ]; then
  if grep -qE 'setup-node|npm |ng build' .github/workflows/deploy-gh.yml
  then bad "Workflow enthaelt noch Build-Schritte"; else ok "Workflow ohne Build"; fi
  if grep -q 'rm -rf .git .github docs tools' .github/workflows/deploy-gh.yml
  then ok "Strip-Liste vollstaendig"; else bad "Strip-Liste fehlt/unvollstaendig"; fi
else bad "Workflow fehlt"; fi

printf '\n'
if [ "$fail" = 0 ]; then echo "ALLE CHECKS BESTANDEN"; else echo "CHECKS FEHLGESCHLAGEN"; fi
exit "$fail"
```

- [ ] **Schritt 2: Syntaxprüfung**

```bash
bash -n tools/verify.sh && echo "Syntax OK"
```

Erwartet: `Syntax OK`.

- [ ] **Schritt 3: Skript laufen lassen**

```bash
chmod +x tools/verify.sh && bash tools/verify.sh; echo "Exit: $?"
```

Erwartet: sehr viele `FEHL`-Zeilen, Abschluss `CHECKS FEHLGESCHLAGEN`,
`Exit: 1`. Das ist der korrekte Ausgangszustand — noch existiert nichts.

- [ ] **Schritt 4: Commit**

```bash
git add tools/verify.sh && git commit -m "Verifikationsskript mit 12 Abnahmechecks"
```

---

### Task 3: Grundgerüst — Assets und Metadatendateien

Verschiebt alles, was unverändert oder nahezu unverändert übernommen wird.
Macht C1 (bis auf HTML und CSS), C10 und C11 grün.

**Files:**
- Create: `assets/img/` (8 Bilder, aus `src/johannes-bauer/src/assets/img/`)
- Create: `robots.txt`, `app-ads.txt`, `manifest.webmanifest`, `sitemap.xml`
- Create: `.gitignore`
- Vorhanden: `CNAME`, `.nojekyll` bleiben unberührt im Root

**Interfaces:**
- Produces: `/assets/img/portrait.jpg`, `/assets/img/daylight1.jpeg`,
  `/assets/img/daylight2.jpeg`, `/assets/img/daylight3.jpeg`,
  `/assets/img/laundry_screen1.jpg`, `/assets/img/laundry_screen2.jpg`,
  `/assets/img/partywheel-1.png`, `/assets/img/partywheel-2.png` — exakt diese
  acht Pfade werden von Task 5 und Task 6 referenziert.

- [ ] **Schritt 1: Ausgangszustand festhalten**

```bash
bash tools/verify.sh 2>&1 | grep -c FEHL
```

Notiere die Zahl. Sie muss nach dieser Task kleiner sein.

- [ ] **Schritt 2: Bilder und einfache Dateien kopieren**

```bash
mkdir -p assets/img
cp src/johannes-bauer/src/assets/img/* assets/img/
cp src/johannes-bauer/src/robots.txt .
cp src/johannes-bauer/src/app-ads.txt .
ls assets/img/ | wc -l
```

Erwartet: `8`.

- [ ] **Schritt 3: `manifest.webmanifest` schreiben**

Gegenüber der Vorlage ändern sich nur `scope` und `start_url` von `"./"` auf
`"/"` — begründet in der Spec, Abschnitt „Service Worker entfernen".

```json
{
  "name": "Johannes Bauer",
  "short_name": "Johannes Bauer",
  "theme_color": "#f9fafb",
  "background_color": "#f9fafb",
  "display": "standalone",
  "scope": "/",
  "start_url": "/"
}
```

- [ ] **Schritt 4: `sitemap.xml` schreiben**

Neun kanonische URLs mit Slash, keine `?/`-Formen, `privacy-policy` neu
aufgenommen.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://johannes-bauer.de/</loc><lastmod>2026-08-22</lastmod><priority>1.0</priority></url>
  <url><loc>https://johannes-bauer.de/imprint/</loc><lastmod>2026-08-22</lastmod><priority>0.9</priority></url>
  <url><loc>https://johannes-bauer.de/privacy-policy/</loc><lastmod>2026-08-22</lastmod><priority>0.9</priority></url>
  <url><loc>https://johannes-bauer.de/terms-and-conditions/</loc><lastmod>2026-08-22</lastmod><priority>0.8</priority></url>
  <url><loc>https://johannes-bauer.de/daylight/</loc><lastmod>2026-08-22</lastmod><priority>0.7</priority></url>
  <url><loc>https://johannes-bauer.de/laundry/</loc><lastmod>2026-08-22</lastmod><priority>0.7</priority></url>
  <url><loc>https://johannes-bauer.de/partywheel/</loc><lastmod>2026-08-22</lastmod><priority>0.7</priority></url>
  <url><loc>https://johannes-bauer.de/cavemap/</loc><lastmod>2026-08-22</lastmod><priority>0.7</priority></url>
  <url><loc>https://johannes-bauer.de/ventify/</loc><lastmod>2026-08-22</lastmod><priority>0.7</priority></url>
</urlset>
```

- [ ] **Schritt 5: `.gitignore` schreiben**

```
.DS_Store
```

- [ ] **Schritt 6: Prüfen**

```bash
bash tools/verify.sh 2>&1 | sed -n '/C10 Sitemap/,/C12/p'
```

Erwartet: C10 und C11 vollständig `OK`.

- [ ] **Schritt 7: Commit**

```bash
git add assets robots.txt app-ads.txt manifest.webmanifest sitemap.xml .gitignore
git commit -m "Assets und Metadatendateien in die Zielstruktur uebernommen"
```

---

### Task 4: `styles.css` schreiben

Das Herzstück. Alle Werte stammen aus `tools/tailwind-reference.css` — nichts
wird geschätzt.

**Files:**
- Create: `styles.css`

**Interfaces:**
- Produces: folgende Klassennamen, die Task 5 bis 9 im Markup verwenden:
  - `.page` — Vollhöhen-Flex-Spalte, ersetzt `flex flex-col h-full w-full bg-gray-50 select-none`
  - `.page-centered` — zentrierender Wrapper, ersetzt `flex flex-col items-center justify-center w-full`
  - `.page-top` — oben ausgerichtet, ersetzt `flex items-start justify-center w-full`
  - `.card` — weiße Box, ersetzt `bg-white p-3 shadow-md` plus Radius/Margin-Varianten
  - `.card--sm` — Radius und Margin ab 640px (`sm:rounded-lg sm:m-5`)
  - `.card--lg` — Radius und Margin ab 1024px (`lg:rounded-lg lg:m-5`)
  - `.card--always` — Radius immer, Margin ab 640px (AGB-Seite)
  - `.card--xl` / `.card--2xl` — `max-width` 80rem bzw. 96rem
  - `.spacer` — `flex-grow: 1`
  - `.avatar` — Portraitkreis mit Hover-Zoom
  - `.social-links` — Zeile mit `gap`
  - `.social-link` — Basisstil der vier Icon-Links; setzt `font-size` aus `text-4xl`,
    die das enthaltene `.icon` erbt. Plus Modifier
    `.social-link--linkedin`, `--xing`, `--github`, `--mail`
  - `.footer-links` — Footerzeile
  - `.app-link` — App-Store-Titelzeile (blau, Icon plus Überschrift)
  - `.app-link--centered` — zusätzlich horizontal zentriert (Daylight, Partywheel)
  - `.icon` — **größenneutral**: `width:1em; height:1em`, `display:inline-block`,
    `vertical-align:-0.125em`. Setzt selbst **keine** `font-size`. Die Größe kommt
    vom Elternelement — `.social-link` (Homepage, `text-4xl`) bzw. `.app-link`
    (App-Seiten, `text-3xl` / ab 640px `text-5xl`). So verhält sich das Inline-SVG
    wie das bisherige FontAwesome-Icon, das ebenfalls über `font-size` skaliert wurde.
  - `.screenshots` — horizontale Screenshot-Reihe (Daylight, Partywheel)
  - `.screenshots__img` — responsive Bildbreiten 150/250/300px
  - `.screenshots__img--bordered` — zusätzlich 2px Rahmen (Partywheel)
  - `.split` / `.split__half` — zweispaltiges Layout ab 1024px (Laundry)
  - `.laundry-shots` / `.laundry-shots__img` — Screenshot-Paar (Laundry)
  - `.prose` — Textcontainer, ersetzt `container mx-auto p-6` (Cavemap, Ventify)
  - `.home__body` — zentrierter Inhaltsblock der Homepage und der 404-Seite
  - `.home__name` — grosse Namenszeile, ersetzt `text-4xl font-bold mb-2 text-center drop-shadow-xs`
  - `.home__role` — Rollenzeile, ersetzt `text-xl mb-6 text-center drop-shadow-xs`
  - `.link` — Inline-Textlink, ersetzt `text-blue-600 hover:underline` und `hover:underline`
  - Body-Scopes: `.home`, `.app-page`, `.legal`, `.terms`, `.cavemap`,
    `.ventify`, `.redirect`

  Vollstaendige Zuordnung jeder einzelnen Tailwind-Klasse zu diesen Namen: siehe
  Anhang „Vollständige Klassenzuordnung" am Ende dieses Plans.

- [ ] **Schritt 1: Wertequelle bereitstellen**

Öffne `tools/tailwind-reference.css`. Für jeden Wert unten gilt: den zugehörigen
Selektor in der Referenz suchen und die Deklaration wörtlich übernehmen. Die
Farbvariablen stehen im `:root`-Block der Referenz.

Suchmuster für die häufigsten Werte:

```bash
grep -o '\.bg-gray-50{[^}]*}'      tools/tailwind-reference.css
grep -o '\.shadow-md{[^}]*}'       tools/tailwind-reference.css
grep -o '\.drop-shadow-xs{[^}]*}'  tools/tailwind-reference.css
grep -o '\.drop-shadow-md{[^}]*}'  tools/tailwind-reference.css
grep -o '\.rounded-lg{[^}]*}'      tools/tailwind-reference.css
grep -o '\.rounded-full{[^}]*}'    tools/tailwind-reference.css
grep -o '\.text-4xl{[^}]*}'        tools/tailwind-reference.css
grep -o '\.text-5xl{[^}]*}'        tools/tailwind-reference.css
grep -o -- '--color-blue-600:[^;]*' tools/tailwind-reference.css
grep -o -- '--color-gray-600:[^;]*' tools/tailwind-reference.css
grep -o -- '--breakpoint-xl:[^;]*'  tools/tailwind-reference.css
grep -o -- '--default-font-family:[^;]*' tools/tailwind-reference.css
```

- [ ] **Schritt 2: Variablenblock schreiben**

`styles.css` beginnt mit einem `:root`-Block, der alle aus der Referenz
übernommenen Werte sammelt. Nur hier stehen Literale; der Rest der Datei
verwendet ausschließlich `var(…)`. So bleibt nachvollziehbar, woher jeder Wert
stammt.

```css
/* styles.css — johannes-bauer.de
   Alle Werte stammen aus tools/tailwind-reference.css (Tailwind v4 Build).
   Icons: Font Awesome Free, CC BY 4.0, https://fontawesome.com/license/free */

:root {
  /* Schrift: Wert aus --default-font-family der Referenz */
  --font-sans: <aus Referenz>;

  /* Farben: Werte aus dem :root-Block der Referenz */
  --color-gray-50: <aus Referenz>;
  --color-gray-600: <aus Referenz>;
  --color-gray-800: <aus Referenz>;
  --color-gray-900: <aus Referenz>;
  --color-blue-500: <aus Referenz>;
  --color-blue-600: <aus Referenz>;
  --color-blue-700: <aus Referenz>;
  --color-blue-800: <aus Referenz>;
  --color-green-600: <aus Referenz>;
  --color-green-800: <aus Referenz>;
  --color-red-600: <aus Referenz>;
  --color-red-800: <aus Referenz>;

  /* Schatten */
  --shadow-md: <aus .shadow-md>;
  --drop-shadow-xs: <aus .drop-shadow-xs>;
  --drop-shadow-md: <aus .drop-shadow-md>;

  /* Maße */
  --radius-lg: <aus .rounded-lg>;
  --breakpoint-xl: <aus --breakpoint-xl>;
  --breakpoint-2xl: <aus --breakpoint-2xl>;
}
```

Die Platzhalter `<aus Referenz>` werden in diesem Schritt durch die tatsächlichen
Werte ersetzt. Nach Schritt 2 darf kein `<aus` mehr in der Datei stehen —
Schritt 6 prüft das.

- [ ] **Schritt 3: Base und Typografie**

Entspricht dem heutigen `styles.css` plus dessen `@layer base`-Block.

```css
*, *::before, *::after { box-sizing: border-box; }

html, body {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  background-color: rgb(249, 250, 251);
  font-family: var(--font-sans);
}

/* Groessen aus .text-2xl / .text-xl / .text-lg der Referenz */
h1 { font-size: <aus .text-2xl>; line-height: <aus .text-2xl>; }
h2 { font-size: <aus .text-xl>;  line-height: <aus .text-xl>; }
h3 { font-size: <aus .text-lg>;  line-height: <aus .text-lg>; }
```

Der Hintergrundwert `rgb(249, 250, 251)` steht so im heutigen `styles.css` und
wird wörtlich übernommen — nicht durch `--color-gray-50` ersetzt, weil die beiden
Werte sich in Tailwind v4 unterscheiden können.

- [ ] **Schritt 4: Komponenten und Seiten-Scopes schreiben**

Für jede in „Interfaces" gelistete Klasse die Deklarationen aus der Referenz
zusammensetzen. Die Zuordnung Tailwind-Klasse zu semantischer Klasse steht in
der Mapping-Tabelle am Ende dieses Plans.

Die Seiten-Scopes übernehmen die heutigen Komponenten-CSS-Dateien wörtlich:

| Scope | Quelle |
|---|---|
| `.legal` | `src/johannes-bauer/src/app/imprint/imprint.component.css` (identisch zu `privacy.component.css`) |
| `.terms` | `src/johannes-bauer/src/app/terms-and-conditions/terms-and-conditions.component.css` |
| `.cavemap` | `src/johannes-bauer/src/app/cave-map/cave-map.component.css` |
| `.app-page li` | `daylight.component.css` und `wheel-of-drinking.component.css` — beide enthalten `li { padding: 3px 0 3px 0 }`. Laundry hat kein eigenes CSS und keine `<li>`. |

Beispiel für `.legal` — die Regeln werden mit dem Scope präfixiert:

```css
.legal h1 { margin-top: 24px; margin-bottom: 8px; font-weight: bold; }
.legal h2 { margin-top: 18px; margin-bottom: 8px; font-weight: bold; }
.legal h3 { margin-top: 12px; margin-bottom: 8px; font-weight: bold; }
.legal h4 { margin-top: 8px;  margin-bottom: 4px; font-weight: bold; }
.legal .first-headline { margin-top: initial; }
.legal p  { text-align: justify; }
```

- [ ] **Schritt 5: Breakpoints als Media Queries**

Tailwind-Präfixe werden zu `min-width`-Abfragen. Die Werte aus der Referenz
bestätigen:

```css
@media (min-width: 40rem) { /* sm:  */ }
@media (min-width: 48rem) { /* md:  */ }
@media (min-width: 64rem) { /* lg:  */ }
```

- [ ] **Schritt 6: Keine Platzhalter mehr**

```bash
grep -n '<aus' styles.css && echo "FEHLER: Platzhalter uebrig" || echo "OK: keine Platzhalter"
```

Erwartet: `OK: keine Platzhalter`.

- [ ] **Schritt 7: Prüfen**

```bash
bash tools/verify.sh 2>&1 | grep 'styles.css'
```

Erwartet: `OK    styles.css` in C1.

- [ ] **Schritt 8: Commit**

```bash
git add styles.css && git commit -m "styles.css: Tailwind durch handgeschriebenes CSS ersetzt"
```

---

## Gemeinsame Kopfvorlage

Tasks 5 bis 8 verwenden diese Vorlage. Die Platzhalter in geschweiften Klammern
werden je Seite aus der Metadaten-Tabelle darunter ersetzt. Es gibt bewusst kein
Template-System — die Vorlage wird pro Datei kopiert, das ist bei neun Seiten
günstiger als ein Build-Schritt.

```html
<!doctype html>
<html lang="{LANG}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{TITLE}</title>
  <meta name="description" content="{DESC}">
  <link rel="canonical" href="https://johannes-bauer.de{PATH}">
  <meta property="og:type" content="website">
  <meta property="og:title" content="{TITLE}">
  <meta property="og:description" content="{DESC}">
  <meta property="og:url" content="https://johannes-bauer.de{PATH}">
  <meta property="og:image" content="https://johannes-bauer.de/assets/img/portrait.jpg">
  <link rel="manifest" href="/manifest.webmanifest">
  <link rel="stylesheet" href="/styles.css">
</head>
<body class="{BODYCLASS}">
```

Abschluss jeder Seite:

```html
</body>
</html>
```

### Metadaten je Seite

| Datei | LANG | PATH | TITLE | DESC | BODYCLASS |
|---|---|---|---|---|---|
| `index.html` | de | `/` | `Johannes Bauer` | `Johannes Bauer ist Fullstack Web- und Mobile-App-Entwickler aus Stuttgart.` | `home` |
| `imprint/index.html` | de | `/imprint/` | `Impressum – Johannes Bauer` | `Impressum und Anbieterkennzeichnung von Johannes Bauer, Stuttgart.` | `legal` |
| `privacy-policy/index.html` | de | `/privacy-policy/` | `Datenschutzerklärung – Johannes Bauer` | `Datenschutzerklärung der Website johannes-bauer.de.` | `legal` |
| `terms-and-conditions/index.html` | de | `/terms-and-conditions/` | `Geschäftsbedingungen – Johannes Bauer` | `Allgemeine Geschäftsbedingungen und Endbenutzer-Lizenzvertrag.` | `terms` |
| `daylight/index.html` | de | `/daylight/` | `Daylight – Sonnenaufgang und Sonnenuntergang` | `Daylight ist die App für Sonnenauf- und Sonnenuntergangszeiten an beliebigen Orten. Für iOS, macOS, iPadOS und watchOS.` | `app-page` |
| `laundry/index.html` | de | `/laundry/` | `Laundry Symbols – Wäschesymbole scannen` | `Laundry Symbols scannt Pflegeetiketten und erklärt Wäschesymbole in 27 Sprachen. Werbefrei und barrierefrei.` | `app-page` |
| `partywheel/index.html` | de | `/partywheel/` | `Partywheel – Kurze Partyspiele` | `Partywheel ist das interaktive Glücksrad für Spieleabende und Hauspartys.` | `app-page` |
| `cavemap/index.html` | en | `/cavemap/` | `Cave Map – Privacy Policy` | `Privacy policy for the Cave Map iOS app. No data leaves your device.` | `cavemap` |
| `ventify/index.html` | en | `/ventify/` | `Ventify – Privacy Policy` | `Privacy policy for the Ventify app. No personal data is collected.` | `ventify` |

---

### Task 5: Homepage

Die aufwendigste Seite: vier Inline-SVG-Icons und die drei Footer-Links, die aus
`routerLink` zu echten `href` werden.

**Files:**
- Create: `index.html`
- Read: `src/johannes-bauer/src/app/homepage/homepage.component.html`
- Read: `tools/icons/linkedin.svg`, `xing.svg`, `github.svg`, `envelope.svg`

**Interfaces:**
- Consumes: `.page`, `.spacer`, `.avatar`, `.social-links`, `.social-link` mit
  Modifiern, `.footer-links`, `.icon` aus Task 4; die vier SVGs aus Task 1.
- Produces: `/` als Linkziel für Task 9 (404-Seite) und Task 3 (Sitemap).

- [ ] **Schritt 1: `index.html` schreiben**

Vollständiger Inhalt. Die vier `{SVG:*}`-Marker werden durch den Inhalt der
jeweiligen Datei aus `tools/icons/` ersetzt.

```html
<!doctype html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Johannes Bauer</title>
  <meta name="description" content="Johannes Bauer ist Fullstack Web- und Mobile-App-Entwickler aus Stuttgart.">
  <link rel="canonical" href="https://johannes-bauer.de/">
  <meta property="og:type" content="website">
  <meta property="og:title" content="Johannes Bauer">
  <meta property="og:description" content="Johannes Bauer ist Fullstack Web- und Mobile-App-Entwickler aus Stuttgart.">
  <meta property="og:url" content="https://johannes-bauer.de/">
  <meta property="og:image" content="https://johannes-bauer.de/assets/img/portrait.jpg">
  <link rel="manifest" href="/manifest.webmanifest">
  <link rel="stylesheet" href="/styles.css">
</head>
<body class="home">
<div class="page">
  <!-- Spacer -->
  <div class="spacer"></div>

  <!-- Body -->
  <div class="home__body">
    <div class="avatar">
      <img alt="Portrait of Johannes Bauer" src="/assets/img/portrait.jpg">
    </div>

    <h1 class="home__name">Johannes Bauer</h1>
    <p class="home__role">Fullstack Web &amp; Mobile App Developer</p>

    <!-- Icons: Font Awesome Free, CC BY 4.0, https://fontawesome.com/license/free -->
    <div class="social-links">
      <a aria-label="Go to my LinkedIn profile"
         class="social-link social-link--linkedin"
         href="https://www.linkedin.com/in/johannes-bauer-dev/" target="_blank">
        {SVG:linkedin}
      </a>
      <a aria-label="Go to my Xing profile"
         class="social-link social-link--xing"
         href="https://www.xing.com/profile/Johannes_Bauer119" target="_blank">
        {SVG:xing}
      </a>
      <a aria-label="Go to my GitHub profile"
         class="social-link social-link--github"
         href="https://github.com/JohannesBauer97/" target="_blank">
        {SVG:github}
      </a>
      <a aria-label="Send me a mail"
         class="social-link social-link--mail"
         href="mailto:kontakt@johannes-bauer.de">
        {SVG:envelope}
      </a>
    </div>
  </div>

  <!-- Spacer -->
  <div class="spacer"></div>

  <!-- Footer -->
  <p class="footer-links">
    <a href="/imprint/">Impressum</a>
    <span> | </span>
    <a href="/privacy-policy/">Datenschutz</a>
    <span> | </span>
    <a href="/terms-and-conditions/">Geschäftsbedingungen</a>
  </p>
</div>
</body>
</html>
```

Jedes eingesetzte `<svg>` bekommt zusätzlich `class="icon"`.

- [ ] **Schritt 2: SVGs eingesetzt?**

```bash
grep -c '<svg' index.html && grep -c '{SVG:' index.html
```

Erwartet: `4` und `0`.

- [ ] **Schritt 3: Verifikation**

```bash
bash tools/verify.sh 2>&1 | grep -E '^\s+(OK|FEHL)\s+index\.html'
```

Erwartet: nur `OK`-Zeilen für `index.html` in C2, C3, C4, C5, C7, C8.
C7 meldet die drei Footer-Ziele noch als fehlend — die entstehen in Task 8.

- [ ] **Schritt 4: Visuelle Abnahme**

Angular-Referenz und statische Fassung nebeneinander vergleichen:

```bash
cd src/johannes-bauer && npm start
```

Referenz: `http://localhost:4200/`. Neue Fassung: in einem zweiten Terminal aus
dem Repository-Root `python3 -m http.server 8080`, dann `http://localhost:8080/`.
Beide bei 1280px und bei 375px Breite vergleichen. Zu prüfen: Kreisgröße und
Abstand des Portraits, Hover-Zoom, Schriftgrößen von Name und Rolle,
Icon-Größe und -Farben, Hover-Farben aller vier Icons, Footer-Abstand.

- [ ] **Schritt 5: Commit**

```bash
git add index.html && git commit -m "Homepage als statisches HTML"
```

---

### Task 6: App-Seiten Daylight, Laundry, Partywheel

Drei Seiten mit gleicher Grundstruktur: App-Store-Titelzeile mit Icon,
Screenshots, Beschreibung, App-Datenschutz.

**Files:**
- Create: `daylight/index.html`, `laundry/index.html`, `partywheel/index.html`
- Read: `src/johannes-bauer/src/app/daylight/daylight.component.html`
- Read: `src/johannes-bauer/src/app/laundry-symbols/laundry-symbols.component.html`
- Read: `src/johannes-bauer/src/app/wheel-of-drinking/wheel-of-drinking.component.html`
- Read: `tools/icons/app-store.svg`

**Interfaces:**
- Consumes: `.page-centered`, `.card`, `.card--lg`, `.card--2xl`, `.app-link`,
  `.app-link--centered`, `.icon`, `.screenshots`, `.screenshots__img`,
  `.screenshots__img--bordered`, `.split`, `.split__half`, `.laundry-shots`,
  `.laundry-shots__img` aus Task 4.
- Produces: `/daylight/` als Ziel der Weiterleitung in Task 9.

- [ ] **Schritt 1: Klassenzuordnung dieser drei Seiten**

| Tailwind im Original | Ersatz |
|---|---|
| `flex flex-col items-center justify-center w-full` (äußeres div) | `page-centered` |
| `flex flex-col bg-white p-3 shadow-md lg:rounded-lg lg:m-5 max-w-(--breakpoint-2xl)` | `card card--lg card--2xl` |
| `text-blue-500 hover:text-blue-700 drop-shadow-xs hover:drop-shadow-md flex flex-row gap-4 justify-center` | `app-link app-link--centered` |
| `text-blue-500 … flex flex-row gap-4` (Laundry, ohne `justify-center`) | `app-link` |
| `sm:text-5xl text-3xl` (auf `fa-icon` und `h1`) | SVG bekommt `icon`, `h1` bekommt keine Klasse — die Größe setzt `.app-link` als Container, beide erben sie |
| `flex flex-row flex-nowrap gap-1 justify-start md:justify-center mt-4 overflow-auto` | `screenshots` |
| `max-w-[150px] md:max-w-[250px] lg:max-w-[300px] w-full` | `screenshots__img` |
| dieselbe plus `border-2` (Partywheel) | `screenshots__img screenshots__img--bordered` |
| `flex flex-row flex-wrap` (Laundry) | `split` |
| `lg:basis-1/2` (Laundry) | `split__half` |
| `flex flex-row flex-wrap gap-5 justify-center lg:basis-1/2` (Laundry) | `laundry-shots split__half` |
| `h-fit max-w-[250px]` (Laundry) | `laundry-shots__img` |
| `mt-4`, `mt-2 font-semibold`, `mb-2 mt-5 font-bold`, `mb-2 mt-4 font-semibold` | entfallen — `body.app-page` regelt Abstände und Gewichte |
| `list-disc list-inside`, `list-decimal list-inside` | entfallen — `body.app-page ul` / `ol` regeln das |
| `text-justify` (Laundry-Beschreibung) | entfällt — `body.app-page p` regelt das |

Die letzten drei Zeilen bedeuten: Task 4 muss `body.app-page` so definieren, dass
`p`, `h1`, `h2`, `ul`, `ol` die heutigen Abstände, Gewichte und Listenstile
erhalten. Die Werte stehen in `tools/tailwind-reference.css` unter `.mt-4`,
`.mt-2`, `.mt-5`, `.mb-2`, `.font-bold`, `.font-semibold`, `.list-disc`,
`.list-decimal`, `.list-inside`, `.text-justify`.

- [ ] **Schritt 2: `daylight/index.html` schreiben**

Kopfvorlage mit den Werten aus der Metadaten-Tabelle. Body-Inhalt aus
`daylight.component.html` übernehmen, Klassen gemäß Schritt 1 ersetzen,
`<fa-icon [icon]="faAppStore" class="sm:text-5xl text-3xl"></fa-icon>` durch den
Inhalt von `tools/icons/app-store.svg` mit `class="icon"` ersetzen, alle drei
`src="assets/img/…"` auf `src="/assets/img/…"` umstellen. Texte und Struktur
unverändert lassen.

Den drei `<img>`-Elementen fehlt im Original ein `alt`-Attribut. Ergänze
`alt="Screenshot der App Daylight"` — das ist eine Barrierefreiheitskorrektur
ohne visuelle Wirkung.

- [ ] **Schritt 3: `laundry/index.html` schreiben**

Kopfvorlage mit den Werten aus der Metadaten-Tabelle (`lang="de"`,
`BODYCLASS="app-page"`). Body-Inhalt aus `laundry-symbols.component.html`
übernehmen, Klassen gemäß Schritt 1 ersetzen. Diese Seite weicht in zwei Punkten
von Daylight ab: die Titelzeile hat **kein** `justify-center`, bekommt also nur
`app-link` ohne `--centered`; und der Inhalt ist zweispaltig, also `split` für
den Zeilencontainer, `split__half` für den Beschreibungsblock und
`laundry-shots split__half` für den Screenshot-Block. Das App-Store-Icon wie bei
Daylight durch `tools/icons/app-store.svg` mit `class="icon"` ersetzen, beide
`src="assets/img/…"` auf `src="/assets/img/…"` umstellen und
`alt="Screenshot der App Laundry Symbols"` an beiden Bildern ergänzen.

- [ ] **Schritt 4: `partywheel/index.html` schreiben**

Kopfvorlage mit den Werten aus der Metadaten-Tabelle (`lang="de"`,
`BODYCLASS="app-page"`). Body-Inhalt aus `wheel-of-drinking.component.html`
übernehmen, Klassen gemäß Schritt 1 ersetzen. Die Titelzeile ist wie bei
Daylight zentriert (`app-link app-link--centered`). Beide Screenshots tragen
zusätzlich einen Rahmen, also `screenshots__img screenshots__img--bordered`.
Das App-Store-Icon durch `tools/icons/app-store.svg` mit `class="icon"`
ersetzen, beide `src="assets/img/…"` auf `src="/assets/img/…"` umstellen und
`alt="Screenshot der App Partywheel"` an beiden Bildern ergänzen.

Diese Seite enthält als einzige der drei eine `<ol>`-Liste (Spielanleitung) und
einen externen Link auf Googles AdMob-Dokumentation im Datenschutzabschnitt. Der
Link bleibt inhaltlich unverändert, bekommt aber statt `class="hover:underline"`
die Klasse `link`.

- [ ] **Schritt 5: Verifikation**

```bash
bash tools/verify.sh 2>&1 | grep -E 'daylight/|laundry/|partywheel/'
```

Erwartet: ausschließlich `OK`-Zeilen.

- [ ] **Schritt 6: Visuelle Abnahme**

Alle drei Seiten bei 1280px und 375px gegen `http://localhost:4200/daylight`,
`/laundry`, `/partywheel` vergleichen. Besonders zu prüfen: Screenshot-Breiten
an den Breakpoints 768px und 1024px, horizontales Scrollen der Screenshot-Reihe
auf schmalen Viewports, zweispaltiges Laundry-Layout ab 1024px, Kartenrand und
Radius ab 1024px.

- [ ] **Schritt 7: Commit**

```bash
git add daylight laundry partywheel
git commit -m "App-Seiten Daylight, Laundry und Partywheel als statisches HTML"
```

---

### Task 7: Cavemap und Ventify

Zwei schlichte englische Textseiten ohne Karte, ohne Bilder.

**Files:**
- Create: `cavemap/index.html`, `ventify/index.html`
- Read: `src/johannes-bauer/src/app/cave-map/cave-map.component.html`
- Read: `src/johannes-bauer/src/app/ventify/ventify.component.html`
- Read: `src/johannes-bauer/src/app/cave-map/cave-map.component.css`

**Interfaces:**
- Consumes: `.prose`, Body-Scopes `.cavemap` und `.ventify` aus Task 4.

- [ ] **Schritt 1: Klassenzuordnung**

| Tailwind im Original | Ersatz |
|---|---|
| `container mx-auto p-6` | `prose` |
| `text-3xl font-bold mb-4` (Ventify `h1`) | entfällt — `body.ventify h1` |
| `text-2xl font-semibold mb-2` (Ventify `h2`) | entfällt — `body.ventify h2` |
| `mb-4`, `mb-6`, `mb-2` (Ventify) | entfallen — `body.ventify` regelt Abstände |
| `list-disc ml-6` (Ventify) | entfällt — `body.ventify ul` |
| `text-blue-600 hover:underline` (Ventify-Mailadresse) | `link` |

Cavemap verwendet außer `container mx-auto p-6` keine Utility-Klassen; seine
Überschriften- und Absatzabstände stammen aus `cave-map.component.css` und
werden in Task 4 unter `.cavemap` abgelegt.

- [ ] **Schritt 2: `cavemap/index.html` schreiben**

Kopfvorlage mit `lang="en"`, `BODYCLASS="cavemap"`. Body-Inhalt
wörtlich aus `cave-map.component.html`, äußeres `div` bekommt `class="prose"`.
Das `<address>`-Element, alle `<strong>` und die externen Links bleiben
unverändert.

- [ ] **Schritt 3: `ventify/index.html` schreiben**

Kopfvorlage mit `lang="en"`, `BODYCLASS="ventify"`. Body-Inhalt
wörtlich aus `ventify.component.html`, Klassen gemäß Schritt 1.

Hinweis: Die Abschnittsnummerierung im Original springt von „4. Contact" auf
„6. Changes to This Policy", und ein HTML-Kommentar nennt „Section 9". Das ist
ein bestehender Inhaltsfehler. Er wird **nicht** korrigiert — Texte bleiben
unverändert. Melde ihn stattdessen im Abschlussbericht.

- [ ] **Schritt 4: Verifikation**

```bash
bash tools/verify.sh 2>&1 | grep -E 'cavemap/|ventify/'
```

Erwartet: ausschließlich `OK`-Zeilen.

- [ ] **Schritt 5: Visuelle Abnahme**

Gegen `http://localhost:4200/cavemap` und `/ventify` bei 1280px und 375px.
Zu prüfen: Textbreite und Zentrierung des `container`, Innenabstand,
Überschriftengrößen und -abstände, Listeneinzug.

- [ ] **Schritt 6: Commit**

```bash
git add cavemap ventify && git commit -m "Cavemap- und Ventify-Seiten als statisches HTML"
```

---

### Task 8: Rechtstexte — Impressum, Datenschutz, AGB

**Files:**
- Create: `imprint/index.html`, `privacy-policy/index.html`,
  `terms-and-conditions/index.html`
- Read: `src/johannes-bauer/src/app/imprint/imprint.component.html`
- Read: `src/johannes-bauer/src/app/privacy/privacy.component.html`
- Read: `src/johannes-bauer/src/app/terms-and-conditions/terms-and-conditions.component.html`

**Interfaces:**
- Consumes: `.page-centered`, `.page-top`, `.card`, `.card--sm`, `.card--always`,
  `.card--xl`, Body-Scopes `.legal` und `.terms` aus Task 4.
- Produces: `/imprint/`, `/privacy-policy/`, `/terms-and-conditions/` — die drei
  Ziele der Footer-Links aus Task 5 und der Weiterleitung aus Task 9. Erst nach
  dieser Task wird C7 vollständig grün.

- [ ] **Schritt 1: Klassenzuordnung**

| Tailwind im Original | Ersatz |
|---|---|
| `flex flex-col items-center justify-center w-full` (Impressum, Datenschutz) | `page-centered` |
| `flex items-start justify-center w-full` (AGB) | `page-top` |
| `bg-white p-3 sm:rounded-lg shadow-md sm:m-5 max-w-(--breakpoint-xl)` | `card card--sm card--xl` |
| `bg-white p-3 rounded-lg shadow-md sm:m-5 max-w-(--breakpoint-xl)` (AGB) | `card card--always card--xl` |
| `first-headline` | bleibt `first-headline` — wird in `.legal` gescopet |
| `font-semibold` (AGB `h1`) | entfällt — `body.terms h1` |
| `text-justify` (AGB `p`) | entfällt — `body.terms p` |
| `id="headline"` (AGB) | bleibt — `.terms #headline` setzt `margin-top: initial` |

Beachte den Unterschied zwischen Impressum/Datenschutz (`sm:rounded-lg`, Radius
erst ab 640px) und AGB (`rounded-lg`, Radius immer). Das ist im Original so und
wird beibehalten.

- [ ] **Schritt 2: `imprint/index.html` schreiben**

Kopfvorlage, `BODYCLASS="legal"`. Body-Inhalt aus `imprint.component.html`.
Alle HTML-Entities unverändert lassen (`Nibelungenstra&szlig;e`,
`kontakt&#64;johannes-bauer.de`, `Verbraucher&shy;streit&shy;beilegung`).

- [ ] **Schritt 3: `privacy-policy/index.html` schreiben**

Kopfvorlage, `BODYCLASS="legal"`. Body-Inhalt aus `privacy.component.html` —
235 Zeilen, die wörtlich übernommen werden. Die Datei verwendet nur drei
verschiedene `class`-Attribute; alle anderen Elemente sind unklassifiziert und
werden unverändert kopiert.

- [ ] **Schritt 4: `terms-and-conditions/index.html` schreiben**

Kopfvorlage, `BODYCLASS="terms"`. Body-Inhalt aus
`terms-and-conditions.component.html`.

- [ ] **Schritt 5: Verifikation**

```bash
bash tools/verify.sh 2>&1 | sed -n '/C7  Interne Links/,/C8/p'
```

Erwartet: alle Zeilen `OK`, insbesondere die drei Footer-Links aus `index.html`.

- [ ] **Schritt 6: Textgleichheit prüfen**

Der sicherste Test gegen versehentliche Textänderungen: sichtbaren Text beider
Fassungen vergleichen.

```bash
python3 - <<'PY'
import re, html, pathlib
def text(p):
    s = pathlib.Path(p).read_text(encoding="utf-8")
    s = re.sub(r"(?s)<(script|style).*?</\1>", " ", s)
    s = re.sub(r"<[^>]+>", " ", s)
    return " ".join(html.unescape(s).split())
a = text("src/johannes-bauer/src/app/imprint/imprint.component.html")
b = text("imprint/index.html")
print("IDENTISCH" if a in b else "ABWEICHUNG")
PY
```

Erwartet: `IDENTISCH`. Für die beiden anderen Seiten mit angepassten Pfaden
wiederholen.

- [ ] **Schritt 7: Visuelle Abnahme**

Gegen `http://localhost:4200/imprint`, `/privacy-policy`,
`/terms-and-conditions` bei 1280px und 375px. Zu prüfen: Kartenbreite
(max. 80rem), Radius-Unterschied zwischen AGB und den anderen beiden unterhalb
640px, Blocksatz, Überschriftenabstände.

- [ ] **Schritt 8: Commit**

```bash
git add imprint privacy-policy terms-and-conditions
git commit -m "Rechtstexte als statisches HTML"
```

---

### Task 9: Weiterleitungen und 404-Seite

**Files:**
- Create: `impress/index.html`, `daylight-app/index.html`, `404.html`

**Interfaces:**
- Consumes: `/imprint/` und `/daylight/` aus Task 8 und Task 6, `.page`,
  `.spacer` aus Task 4.
- Produces: macht C6 und C9 grün.

- [ ] **Schritt 1: `impress/index.html` schreiben**

```html
<!doctype html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="0; url=/imprint/">
  <link rel="canonical" href="https://johannes-bauer.de/imprint/">
  <title>Weiterleitung zum Impressum</title>
  <link rel="stylesheet" href="/styles.css">
</head>
<body class="redirect">
<p>Diese Seite ist umgezogen. Weiter zum <a href="/imprint/">Impressum</a>.</p>
</body>
</html>
```

- [ ] **Schritt 2: `daylight-app/index.html` schreiben**

```html
<!doctype html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="0; url=/daylight/">
  <link rel="canonical" href="https://johannes-bauer.de/daylight/">
  <title>Weiterleitung zu Daylight</title>
  <link rel="stylesheet" href="/styles.css">
</head>
<body class="redirect">
<p>Diese Seite ist umgezogen. Weiter zu <a href="/daylight/">Daylight</a>.</p>
</body>
</html>
```

- [ ] **Schritt 3: `404.html` schreiben**

Ersetzt den bisherigen SPA-Hack. Gestaltet wie die Homepage, damit der Bruch
nicht auffällt.

```html
<!doctype html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Seite nicht gefunden – Johannes Bauer</title>
  <meta name="robots" content="noindex">
  <link rel="stylesheet" href="/styles.css">
</head>
<body class="home">
<div class="page">
  <div class="spacer"></div>
  <div class="home__body">
    <h1 class="home__name">Seite nicht gefunden</h1>
    <p class="home__role">Diese Adresse gibt es hier nicht.</p>
    <p class="footer-links"><a href="/">Zur Startseite</a></p>
  </div>
  <div class="spacer"></div>
</div>
</body>
</html>
```

Task 4 muss `body.redirect` definieren: schlichter zentrierter Text mit
Innenabstand. Falls die Klasse dort fehlt, jetzt in `styles.css` ergänzen und
mitcommitten.

- [ ] **Schritt 4: Verifikation**

```bash
bash tools/verify.sh 2>&1 | sed -n '/C6  Grundmetadaten/,/C10/p'
```

Erwartet: C6 `OK`, C9 beide Weiterleitungen `OK`.

- [ ] **Schritt 5: Weiterleitung lokal testen**

```bash
python3 -m http.server 8080
```

`http://localhost:8080/impress/` muss ohne Zutun auf `/imprint/` landen,
`http://localhost:8080/daylight-app/` auf `/daylight/`. Danach mit im Browser
deaktiviertem JavaScript wiederholen — das Ergebnis muss identisch sein, weil
`meta refresh` kein JavaScript braucht.

- [ ] **Schritt 6: Commit**

```bash
git add impress daylight-app 404.html styles.css
git commit -m "Weiterleitungen und 404-Seite"
```

---

### Task 10: Deploy-Workflow und README

**Files:**
- Modify: `.github/workflows/deploy-gh.yml` (vollständig ersetzen)
- Modify: `README.md`

**Interfaces:**
- Produces: macht den Workflow-Teil von C12 grün. Die Zeile
  `rm -rf .git .github docs tools` wird von C12 wörtlich geprüft — sie muss
  exakt so lauten.

- [ ] **Schritt 1: Workflow ersetzen**

```yaml
# Deployt die statische Website im Repository-Root zu GitHub Pages.
# Kein Build-Schritt, keine Abhaengigkeiten.
name: Deploy to Pages

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Nicht-Website-Dateien entfernen
        run: rm -rf .git .github docs tools

      - name: Setup Pages
        uses: actions/configure-pages@v5

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: '.'

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

Das Entfernen von `.git` ist zwingend: ohne diesen Schritt läge die komplette
Repository-Historie öffentlich unter `/.git/`.

- [ ] **Schritt 2: README aktualisieren**

Der bisherige Text nennt Angular und trägt einen Badge mit dem alten
Workflow-Namen. Neuer Inhalt:

````markdown
# Website of Johannes Bauer [![Deploy to Pages](https://github.com/JohannesBauer97/jb-web/actions/workflows/deploy-gh.yml/badge.svg)](https://github.com/JohannesBauer97/jb-web/actions/workflows/deploy-gh.yml)

Statische Website ohne Build-Schritt. Reines HTML und CSS, kein JavaScript.

## Lokal ansehen

```bash
python3 -m http.server 8080
```

Dann `http://localhost:8080` öffnen. Das Verhalten bei Verzeichnis-URLs
entspricht dem von GitHub Pages.

## Aufbau

Jede Seite ist eine eigene `index.html` in einem Verzeichnis, das dem URL-Pfad
entspricht. `styles.css` im Root ist das einzige Stylesheet.

## Prüfen

```bash
bash tools/verify.sh
```

Prüft Dateibestand, Metadaten, interne Links, Weiterleitungen und Sitemap.

## Deployment

Jeder Push auf `main` wird automatisch zu GitHub Pages deployt. Es gibt keinen
Build-Schritt — das Repository wird bis auf `.git`, `.github`, `docs` und
`tools` unverändert hochgeladen.
````

- [ ] **Schritt 3: Workflow-Syntax prüfen**

```bash
python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/deploy-gh.yml')); print('YAML OK')"
```

Erwartet: `YAML OK`. Ist PyYAML nicht vorhanden, ersatzweise
`gh workflow list` nach dem Push prüfen.

- [ ] **Schritt 4: Verifikation**

```bash
bash tools/verify.sh 2>&1 | sed -n '/C12/,$p'
```

Erwartet: `Workflow ohne Build` und `Strip-Liste vollstaendig` beide `OK`.
`src/johannes-bauer existiert noch` ist hier weiterhin `FEHL` — das räumt
Task 11 ab.

- [ ] **Schritt 5: Commit**

```bash
git add .github/workflows/deploy-gh.yml README.md
git commit -m "Deployment ohne Build-Schritt, README aktualisiert"
```

---

### Task 11: Angular-Projekt entfernen und Endabnahme

Letzte Task. Vorher muss die visuelle Abnahme aller neun Seiten aus Task 5 bis 8
abgeschlossen sein — danach ist die Referenz nur noch über die Git-Historie
erreichbar.

**Files:**
- Delete: `src/johannes-bauer/` vollständig, danach `src/`

**Interfaces:**
- Produces: macht C12 vollständig grün und damit `bash tools/verify.sh` Exit 0.

- [ ] **Schritt 1: Visuelle Abnahme bestätigen**

Alle neun Seiten wurden in Task 5 bis 8 gegen die Angular-Fassung verglichen und
freigegeben. Ist auch nur eine Seite offen, hier abbrechen und zurückgehen.

```bash
cd src/johannes-bauer && npm start
```

Letzter Durchgang über alle neun Routen bei 1280px und 375px, jeweils gegen die
statische Fassung auf Port 8080.

- [ ] **Schritt 2: Dev-Server stoppen und löschen**

```bash
git rm -r --cached src/johannes-bauer >/dev/null
rm -rf src
git status --short | head -20
```

- [ ] **Schritt 3: Vollständige Verifikation**

```bash
bash tools/verify.sh; echo "Exit: $?"
```

Erwartet: keine einzige `FEHL`-Zeile, Abschluss `ALLE CHECKS BESTANDEN`,
`Exit: 0`.

- [ ] **Schritt 4: Kein JavaScript im Auslieferungsstand**

```bash
grep -rn '<script' --include='*.html' . | grep -v '^./docs/' | grep -v '^./tools/'
echo "Treffer oben muessen leer sein"
```

Erwartet: keine Ausgabe.

- [ ] **Schritt 5: Größe prüfen**

```bash
du -sh assets && du -ch *.html */index.html styles.css | tail -1
```

Zur Einordnung: Das HTML plus CSS sollte deutlich unter 200 KB liegen, gegenüber
rund 250 KB JavaScript allein im bisherigen Build.

- [ ] **Schritt 6: Commit**

```bash
git add -A && git commit -m "Angular-Projekt entfernt"
```

- [ ] **Schritt 7: Deployment prüfen**

Nach dem Merge nach `main` und erfolgreichem Workflow-Lauf jede URL einzeln
aufrufen:

```bash
for u in / /imprint /imprint/ /privacy-policy/ /terms-and-conditions/ \
         /daylight/ /laundry/ /partywheel/ /cavemap/ /ventify/ \
         /impress /daylight-app /gibtesnicht; do
  printf '%-28s %s\n' "$u" "$(curl -s -o /dev/null -w '%{http_code} -> %{redirect_url}' "https://johannes-bauer.de$u")"
done
```

Erwartet: `200` für alle Seiten-URLs, `301` mit Ziel auf die Slash-Variante für
`/imprint`, `200` für die beiden Weiterleitungsseiten (deren Umleitung passiert
im Browser, nicht per HTTP), `404` für `/gibtesnicht`.

Zusätzlich prüfen, dass `https://johannes-bauer.de/.git/config` mit `404`
antwortet — der Beweis, dass der Strip-Schritt gegriffen hat.

---

## Anhang: Vollständige Klassenzuordnung

Alle 86 im Original verwendeten Tailwind-Klassen und ihr Ziel. Die Spalte
„Referenz" nennt den Selektor, unter dem der exakte Wert in
`tools/tailwind-reference.css` steht.

### Layout

| Semantische Klasse | Ersetzt | Referenz |
|---|---|---|
| `.page` | `flex flex-col h-full w-full bg-gray-50 select-none` | `.flex`, `.flex-col`, `.h-full`, `.w-full`, `.bg-gray-50`, `.select-none` |
| `.page-centered` | `flex flex-col items-center justify-center w-full` | `.items-center`, `.justify-center` |
| `.page-top` | `flex items-start justify-center w-full` | `.items-start` |
| `.spacer` | `grow` | `.grow` |
| `.home__body` | `flex flex-col items-center justify-center` | wie oben |
| `.prose` | `container mx-auto p-6` | `.container`, `.mx-auto`, `.p-6` |

### Karten

| Semantische Klasse | Ersetzt | Referenz |
|---|---|---|
| `.card` | `bg-white p-3 shadow-md` (auf App-Seiten zusätzlich `flex flex-col`) | `.bg-white`, `.p-3`, `.shadow-md` |
| `.card--sm` | `sm:rounded-lg sm:m-5` | `@media (min-width:40rem)` auf `.rounded-lg`, `.m-5` |
| `.card--lg` | `lg:rounded-lg lg:m-5` | `@media (min-width:64rem)` |
| `.card--always` | `rounded-lg` plus `sm:m-5` | `.rounded-lg` |
| `.card--xl` | `max-w-(--breakpoint-xl)` | `--breakpoint-xl` |
| `.card--2xl` | `max-w-(--breakpoint-2xl)` | `--breakpoint-2xl` |

### Homepage

| Semantische Klasse | Ersetzt | Referenz |
|---|---|---|
| `.avatar` | `w-72 h-72 mb-8 rounded-full overflow-hidden drop-shadow-md hover:scale-105 transition ease-in-out duration-500` | `.w-72`, `.h-72`, `.mb-8`, `.rounded-full`, `.overflow-hidden`, `.drop-shadow-md`, `.hover\:scale-105`, `.transition`, `.ease-in-out`, `.duration-500` |
| `.avatar img` | `w-full h-full object-cover` | `.object-cover` |
| `.home__name` | `text-4xl font-bold mb-2 text-center drop-shadow-xs` | `.text-4xl`, `.font-bold`, `.mb-2`, `.text-center`, `.drop-shadow-xs` |
| `.home__role` | `text-xl mb-6 text-center drop-shadow-xs` | `.text-xl`, `.mb-6` |
| `.social-links` | `flex gap-x-4` | `.gap-x-4` |
| `.social-link` | `text-4xl drop-shadow-xs hover:drop-shadow-md` | `.hover\:drop-shadow-md` |
| `.social-link--linkedin` | `text-blue-600 hover:text-blue-800` | `--color-blue-600`, `--color-blue-800` |
| `.social-link--xing` | `text-green-600 hover:text-green-800` | `--color-green-600`, `--color-green-800` |
| `.social-link--github` | `text-gray-800 hover:text-gray-900` | `--color-gray-800`, `--color-gray-900` |
| `.social-link--mail` | `text-red-600 hover:text-red-800` | `--color-red-600`, `--color-red-800` |
| `.footer-links` | `text-gray-600 text-sm mb-2 text-center` | `.text-sm`, `--color-gray-600` |
| `.footer-links a` | `hover:underline` | `.hover\:underline` |

### App-Seiten

| Semantische Klasse | Ersetzt | Referenz |
|---|---|---|
| `.app-link` | `text-blue-500 hover:text-blue-700 drop-shadow-xs hover:drop-shadow-md flex flex-row gap-4` | `--color-blue-500`, `--color-blue-700`, `.gap-4`, `.flex-row` |
| `.app-link--centered` | `justify-center` | `.justify-center` |
| `.app-link` (Container) | `sm:text-5xl text-3xl` — setzt `font-size`, Icon und `h1` erben sie | `.text-3xl`, `@media (min-width:40rem)` auf `.text-5xl` |
| `.icon` | groessenneutral: `width:1em; height:1em` plus `display:inline-block` und `vertical-align:-0.125em` | keine — folgt der `font-size` des Elternelements |
| `.screenshots` | `flex flex-row flex-nowrap gap-1 justify-start md:justify-center mt-4 overflow-auto` | `.flex-nowrap`, `.gap-1`, `.justify-start`, `.mt-4`, `.overflow-auto`, `@media (min-width:48rem)` |
| `.screenshots__img` | `max-w-[150px] md:max-w-[250px] lg:max-w-[300px] w-full` | Literalwerte 150px / 250px / 300px |
| `.screenshots__img--bordered` | `border-2` | `.border-2` |
| `.split` | `flex flex-row flex-wrap` | `.flex-wrap` |
| `.split__half` | `lg:basis-1/2` | `.lg\:basis-1\/2` |
| `.laundry-shots` | `flex flex-row flex-wrap gap-5 justify-center` | `.gap-5` |
| `.laundry-shots__img` | `h-fit max-w-[250px]` | `.h-fit` |
| `.link` | `text-blue-600 hover:underline` bzw. nur `hover:underline` | `--color-blue-600` |

### Body-Scopes für Typografie

Diese Klassen entfallen im Markup und werden über den Body-Scope geregelt.

| Scope | Übernimmt | Referenz |
|---|---|---|
| `body.app-page p` | `mt-4`, `mt-2`, `text-justify` | `.mt-4`, `.mt-2`, `.text-justify` |
| `body.app-page p strong-artige` | `font-semibold` | `.font-semibold` |
| `body.app-page h1` | `mb-2 mt-5 font-bold` | `.mb-2`, `.mt-5`, `.font-bold` |
| `body.app-page h2` | `mb-2 mt-4 font-semibold` | `.mb-2`, `.mt-4` |
| `body.app-page ul` | `list-disc list-inside` | `.list-disc`, `.list-inside` |
| `body.app-page ol` | `list-decimal list-inside` | `.list-decimal` |
| `body.ventify h1` | `text-3xl font-bold mb-4` | `.text-3xl`, `.mb-4` |
| `body.ventify h2` | `text-2xl font-semibold mb-2` | `.text-2xl` |
| `body.ventify ul` | `list-disc ml-6` | `.ml-6` |
| `body.ventify > .prose > div` | `mb-6` | `.mb-6` |
| `body.legal` | `imprint.component.css` wörtlich | — |
| `body.terms` | `terms-and-conditions.component.css` wörtlich | — |
| `body.cavemap` | `cave-map.component.css` wörtlich | — |
| `body.redirect` | neu: zentrierter Text mit Innenabstand | — |

### Globale Basis

`h1`/`h2`/`h3` erhalten die Größen aus dem heutigen `@layer base`-Block
(`text-2xl`, `text-xl`, `text-lg`). `html, body` übernehmen Hintergrund und
Maße wörtlich aus dem heutigen `src/johannes-bauer/src/styles.css`.

---

## Reihenfolge auf einen Blick

```
Task 1  Referenzdaten          (Angular muss existieren)
Task 2  Verifikationsskript
Task 3  Assets und Metadaten
Task 4  styles.css             (braucht Task 1)
Task 5  Homepage               (braucht Task 1, 4)
Task 6  App-Seiten             (braucht Task 1, 3, 4)
Task 7  Cavemap, Ventify       (braucht Task 4)
Task 8  Rechtstexte            (braucht Task 4) -> C7 wird gruen
Task 9  Weiterleitungen, 404   (braucht Task 6, 8)
Task 10 Workflow, README
Task 11 Angular entfernen      (zuletzt, nach visueller Abnahme)
```
