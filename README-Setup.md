# Setup-Anleitung — Adventskalender / Holiday Week mit Supabase + Mailjet

Diese Anleitung führt dich Schritt für Schritt durch das Einrichten. Du musst
**nichts programmieren** — nur klicken und ein paar Werte kopieren. Alles, was
nach „Code" aussieht, liegt fertig in diesem `backend/`-Ordner.

> Login funktioniert **genau wie beim Tippspiel**: E-Mail eingeben → Supabase
> schickt einen Magic-Link **und** einen 6-stelligen Code → fertig. Kein Passwort,
> kein Username.

---

## Schritt 1 — Eigenes Supabase-Projekt anlegen  (≈ 3 Min.)
1. Auf https://supabase.com einloggen → **New project**.
2. Name z. B. `ehorses-kalender`, Region **Frankfurt (eu-central-1)**, Passwort vergeben.
3. Warten, bis das Projekt bereit ist.

## Schritt 2 — Datenbank einrichten  (1 Klick)
1. Links im Menü **SQL Editor** → **New query**.
2. Den kompletten Inhalt von **`backend/schema.sql`** einfügen → **Run**.
3. Fertig — alle Tabellen (Profile, Türchen, Teilnahmen, Gewinner) sind angelegt.

## Schritt 3 — Die zwei öffentlichen Werte kopieren
Unter **Project Settings → API** findest du:
- **Project URL**  (z. B. `https://xxxx.supabase.co`)
- **Publishable / anon key**  (beginnt mit `sb_publishable_…` bzw. `eyJ…`)

👉 **Diese zwei Werte gibst du mir** — damit verdrahte ich die Kalender-App.
   (Beide sind öffentlich/ungefährlich — den **service_role**-Key NIEMALS teilen.)

## Schritt 4 — Anmelde-Mail über Mailjet versenden  (Magic-Link + Code)
Supabase verschickt die Anmelde-Mail selbst — wir leiten den Versand über Mailjet:
1. In Mailjet unter **Account → SMTP** die SMTP-Zugangsdaten holen
   (Server `in-v3.mailjet.com`, Port `587`, User = API-Key, Passwort = Secret-Key).
2. In Supabase: **Authentication → Emails → SMTP Settings** → **Custom SMTP** aktivieren
   und die Mailjet-Daten + Absender (`MAIL_FROM`) eintragen.
3. **Authentication → Email Templates → „Magic Link"**: Betreff/Inhalt im ehorses-Look
   anpassen. Den 6-stelligen Code fügst du mit dem Platzhalter `{{ .Token }}` ein,
   den Link mit `{{ .ConfirmationURL }}`.

## Schritt 5 — Erinnerungs- & Gewinner-Mails (Edge Functions)
Diese zwei Funktionen liegen fertig in `backend/functions/`. Dein Dev (oder du mit
der Supabase-CLI) deployt sie:
```bash
supabase functions deploy reminder
supabase functions deploy notify-winner
```
Danach unter **Project Settings → Edge Functions → Secrets** setzen:
- `MAILJET_API_KEY`, `MAILJET_API_SECRET`
- `MAIL_FROM` (z. B. `adventskalender@ehorses.de`), `MAIL_FROM_NAME`
- (`SUPABASE_URL` & `SUPABASE_SERVICE_ROLE_KEY` sind automatisch verfügbar)

**Tägliche Erinnerung morgens** automatisieren: unter **Database → Cron** (pg_cron)
einen Job anlegen, der die `reminder`-Funktion z. B. jeden Tag um 08:00 aufruft.

## Schritt 6 — Dich selbst zum Admin machen
Einmal in der App anmelden, dann im SQL Editor:
```sql
update public.profiles set is_admin = true where email = 'DEINE@EMAIL.de';
```

---

## Was übernimmt wer?
| Aufgabe | Wer |
|---|---|
| Code, Schema, Mail-Funktionen, App-Verdrahtung | **Ich (fertig bzw. liefere ich)** |
| Supabase-Projekt anlegen, SQL ausführen, Keys kopieren | **Du (Klicks oben)** |
| Funktionen deployen, Domain, Live-Schaltung | **Du / euer Entwickler** |
| Geheime Keys (service_role, Mailjet-Secret) | **Bleiben bei euch** |

**Nächster Schritt für mich:** Sobald du mir **Project URL + Publishable Key** (aus
Schritt 3) gibst, baue ich die Kalender-App so um, dass Login, Teilnahme und
Gewinner-Ziehung echt gegen deine Supabase-Datenbank laufen — statt nur lokal.
