# הוד ירושלים – סבב דיירים

Web app for the reception desk's twice-daily resident welfare-check round (סבב בוקר 06:00 / סבב ערב 19:00) at Hod Yerushalayim. It replaces the legacy Windows desktop app.

## Run it
Open `index.html` in any modern browser (Chrome or Edge). There's no install and no build step.

`app.html` is the same page without the outer `<html>` skeleton. It's the source used for the hosted preview. After editing it, rebuild with `./build.sh` (it writes `index.html` and the GitHub Pages copy in `docs/`).

## Status: prototype
- All resident data is **made up** (about 130 fictional residents in buildings א, ב and ג).
- Everything is saved only in the browser it's opened in (localStorage). Use "איפוס נתוני הדגמה" to reset.
- Not built yet: a shared database, so several reception computers can share one live round; login; and import from the legacy system.

## What's in it
- 4 status tabs with live counts: טרם אותרו / בבירור / אותרו / לא לאיתור.
- Each resident has 3 big buttons ("ענה בטלפון", "ראיתי אותו/אותה", "לא ענה"); "עוד" holds the other methods and reasons.
- A resident marked "לא ענה" stays in "בבירור" until someone locates them.
- One-tap locate for a whole apartment (couples).
- One search bar for apartment, name, phone or ID, plus building and floor filters.
- A resident side panel with alerts, contacts, hospital/vacation entries (automatic return to the round), service calls and shift notes.
