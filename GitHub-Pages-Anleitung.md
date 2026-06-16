# Test-URL über GitHub Pages — Schritt für Schritt

Ziel: eine kostenlose, öffentliche **Test-Adresse** (z. B.
`https://nadinegoetzen.github.io/adventskalender/`) — genau wie beim Tippspiel.
Kein Programmieren nötig, alles im Browser.

---

## Schritt 1 — Projekt herunterladen
Hier im Chat erscheint eine **Download-Karte** („Projekt"). Klick sie an und
**entpacke** die ZIP-Datei auf deinem Rechner. Du hast dann einen Ordner mit
`index.html`, `Adventskalender.dc.html`, `support.js`, dem Ordner `assets/` und `backend/`.

## Schritt 2 — Neues Repository anlegen
1. Auf **github.com** einloggen → oben rechts **„+" → New repository**.
2. Name: **`adventskalender`** · Sichtbarkeit: **Public** · **Create repository**.

## Schritt 3 — Dateien hochladen (Drag & Drop)
1. Im neuen Repo: **„uploading an existing file"** (oder **Add file → Upload files**).
2. **Alle** Dateien und Ordner aus dem entpackten Projekt ins Fenster ziehen
   (inkl. `index.html`, `support.js`, `assets/`, `backend/`).
3. Unten **„Commit changes"**.

## Schritt 4 — GitHub Pages einschalten
1. Im Repo oben **Settings** → links **Pages**.
2. Unter **Source**: „Deploy from a branch" → **Branch: `main`** / Ordner **`/ (root)`** → **Save**.
3. 1–2 Minuten warten → oben erscheint deine **Test-URL**.
   Sie sieht so aus: `https://DEIN-NAME.github.io/adventskalender/`
   (zeigt dank `index.html` automatisch den Kalender).

## Schritt 5 — Magic-Link für die Test-URL freischalten
Damit der Link aus der Anmelde-Mail auf die Test-Seite zurückführt:
- Supabase → **Authentication → URL Configuration** →
  **Site URL** = deine Pages-URL, und unter **Redirect URLs** dieselbe URL ergänzen → Save.
- (Der **6-stellige Code** funktioniert auch ohne diesen Schritt.)

---

### Gut zu wissen
- **Updates:** Wenn ich hier etwas am Kalender ändere, lädst du die geänderten
  Dateien einfach erneut im Repo hoch (gleicher Weg wie Schritt 3) — Pages
  aktualisiert sich automatisch.
- **Eigene Domain** (z. B. `adventskalender.ehorses.de`) lässt sich später in
  **Settings → Pages → Custom domain** eintragen.
- Diese Pages-Seite ist **öffentlich** — fürs reine Testen okay; für den echten
  Launch deployt ihr es auf euer Hosting / eure Domain.
