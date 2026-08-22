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
