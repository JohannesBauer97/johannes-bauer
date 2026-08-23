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
  reason=""
  grep -qi '<script'                 "$f" && reason="$reason <script>"
  grep -qiE '[[:space:]]on[a-z]+='   "$f" && reason="$reason inline-event-handler"
  grep -qi 'javascript:'             "$f" && reason="$reason javascript:-URL"
  if [ -z "$reason" ]; then ok "$f"; else bad "$f enthaelt:$reason"; fi
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

  # Werteabgleich: canonical/og:url muessen auf die eigene URL der Seite zeigen,
  # nicht nur irgendeine vorhanden sein.
  case "$f" in
    index.html)     url="https://johannes-bauer.de/" ;;
    */index.html)   dir="${f%/index.html}"; url="https://johannes-bauer.de/$dir/" ;;
    *)              url="" ;;
  esac
  if grep -q "rel=\"canonical\" href=\"$url\"" "$f"
  then ok "$f canonical -> $url"; else bad "$f canonical zeigt nicht auf $url"; fi
  if grep -q "property=\"og:url\" content=\"$url\"" "$f"
  then ok "$f og:url -> $url"; else bad "$f og:url zeigt nicht auf $url"; fi
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

sec "C8b <img> hat alt-Attribut"
for f in $ALL_HTML; do
  [ -f "$f" ] || continue
  # <img>-Tags koennen ueber mehrere Zeilen laufen (z.B. partywheel/index.html);
  # Zeilenumbrueche vor der Suche zu Leerzeichen normalisieren, damit jedes Tag
  # als eine logische Einheit erfasst wird.
  imgs=$(tr '\n' ' ' < "$f" | grep -oE '<img[^>]*>')
  if [ -n "$imgs" ]; then
    while IFS= read -r tag; do
      [ -z "$tag" ] && continue
      if printf '%s' "$tag" | grep -qE '[[:space:]]alt='; then
        ok "$f: <img> hat alt"
      else
        bad "$f: <img> ohne alt-Attribut ($tag)"
      fi
    done <<< "$imgs"
  fi
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
  if grep -q 'rm -rf .git .github docs tools .superpowers' .github/workflows/deploy-gh.yml
  then ok "Strip-Liste vollstaendig"; else bad "Strip-Liste fehlt/unvollstaendig"; fi
else bad "Workflow fehlt"; fi

printf '\n'
if [ "$fail" = 0 ]; then echo "ALLE CHECKS BESTANDEN"; else echo "CHECKS FEHLGESCHLAGEN"; fi
exit "$fail"
