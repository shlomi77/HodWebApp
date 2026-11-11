# הוד קשר – הוד ירושלים (demo)

A clickable demo of a web app for Hod Yerushalayim's staff: the morning and evening resident rounds, the resident file, movements, shift handover, service calls, exceptional events and a light meds round. It replaces the daily workflows of the legacy desktop system, in Hebrew, right to left.

> **Mock data only.** Everything runs in the browser. All residents, phones and IDs are fictitious, created by a seed script and stored in `localStorage` (`hod_demo_v1`). A permanent banner says **"גרסת הדגמה – נתונים פיקטיביים בלבד"**.
> Never put real residents' names, ID numbers, phone numbers, medical data, or screenshots/exports of the legacy system in this repo, its history, issues or the Pages site. Seed phones are `050-00000NN` only and IDs are `DEMO-NNNN`.

## Open it
- **Online:** GitHub Pages serves the `docs/` folder of `main` (Settings → Pages → Deploy from a branch → `main` / `/docs`).
- **Locally:** open `index.html` in Chrome or Edge. No install, no build step.

Log in by picking a demo user. **Every demo PIN is `1234`.** Each role sees a different menu:

| User | Role | Sees |
|---|---|---|
| קבלה 1 | reception | rounds, residents (no clinical data), movements, handover, calls, own events |
| אחראי משמרת | shift manager | + undo/close rounds, meds, reports |
| אחות 1 | nurse | + meds round, vitals, clinical fields |
| חנה, שרית | social worker | social file and benefits (edit), no rounds |
| אב בית | maintenance | service calls (handle), apartment location only |
| מנהלת | manager | everything + event review, service-call categories |
| מנהל מערכת | admin | everything + all settings, new residents |

## What's in it
- **סבב** – one morning and one evening round per day, created automatically (evening from 14:00). Evening rounds include only residents who live alone. Three outcome buttons per row (ראיתי / ענה בטלפון / ביקור פיזי → אותר בדירה / אותר מחוץ לבניין), one-tap locate for a whole apartment, undo with a reason, manual close, print.
- **דיירים** – list with filters, side drawer, and a resident file with tabs: personal details (גר לבד drives round eligibility), contacts, movements, social file (responsible social worker), benefits (חוק סיעוד, with history), notes, events, nursing.
- **תנועות** – who is away right now (overdue in red), new movement panel, one-click "חזר". Hospital/vacation/away removes the resident from open rounds; return restores them.
- **מסירת משמרת** – notes per shift with read tracking, unread count in the menu, "דורש טיפול" status, auto shift summary (printable).
- **קריאות שירות** – list with age vs. target, bulk status change, status flow with timestamps and history, editable categories in settings.
- **אירועים חריגים** – quick report (under a minute), manager review with corrective actions, can't close without a review, violence reporting notice, notification checklist (display only, nothing is sent).
- **תרופות/סיעוד** – light med round (given / not given with reason / undo) and vitals with out-of-range flags. Fake drug names; not a real eMAR.
- **דוחות** – service-call response times (average and median, by category, urgency, handler, building/floor), CSV export for Excel, event counters, round history.
- **הגדרות** – categories, users and roles, buildings/floors/apartments, event types, shift times, reset demo data, JSON export/import.

No blocking pop-ups: forms open in a side panel and confirmations are inline. Dates are dd/mm/yyyy, times 24h, Asia/Jerusalem. Keyboard: `/` search, `Esc` close, `Alt+1…9` screens. Auto-logout after 15 minutes idle (simulated).

## Develop
`index.html` is the whole app (HTML, CSS and vanilla JS in one file). After editing it, run `./build.sh` to copy it to `docs/` for GitHub Pages. Permissions live in one table (`PERMS` / `can(role, action)`); they are checked in the UI only, which is fine for a demo and not secure.

## Specs
- [spec/demo-spec.md](spec/demo-spec.md) – what this demo must do (build order, acceptance criteria).
- `hod-app-spec.md` – production requirements (security, privacy and Ministry of Health rules, retention, backend, real login). Out of scope for this demo; kept outside this public repo.
