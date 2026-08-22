# Website of Johannes Bauer [![Deploy to Pages](https://github.com/JohannesBauer97/jb-web/actions/workflows/deploy-gh.yml/badge.svg)](https://github.com/JohannesBauer97/jb-web/actions/workflows/deploy-gh.yml)

Statische Website ohne Build-Schritt. Reines HTML und CSS, kein JavaScript.

## Lokal ansehen

```bash
python3 -m http.server 8080
```

Dann `http://localhost:8080` öffnen. Das Verhalten bei Verzeichnis-URLs
entspricht dem von GitHub Pages.

## Aufbau

Unterseiten liegen je als `index.html` in einem Verzeichnis, das dem URL-Pfad entspricht (`imprint/index.html` für `/imprint/`). Die Startseite ist `index.html` im Root. `404.html` liegt im Root — GitHub Pages liefert sie für unbekannte Pfade. `styles.css` ist das einzige Stylesheet.

## Prüfen

```bash
bash tools/verify.sh
```

Prüft Dateibestand, Metadaten, interne Links, Weiterleitungen und Sitemap.

## Deployment

Jeder Push auf `main` wird automatisch zu GitHub Pages deployt. Es gibt keinen
Build-Schritt — das Repository wird bis auf `.git`, `.github`, `docs` und
`tools` unverändert hochgeladen.
