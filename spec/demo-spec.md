# Demo spec — סבב דיירים – הוד ירושלים

*Version 1.0 (Nov 4, 2026). Build-ready spec for the demo in the public repo https://github.com/shlomi77/HodWebApp, hosted on GitHub Pages.*

> **MOCK DATA ONLY.** The demo runs entirely in the browser. All data is fake, stored in `localStorage` and created by a seed script.
> - Use fictional names only (e.g. "רחל לדוגמה", "משה בדיקה").
> - **Never** put real residents' names, ID numbers, phones, medical data, Nativ screenshots or Nativ exports in the repo, the commit history, issues or the Pages site.
> - A permanent banner reads **"גרסת הדגמה – נתונים פיקטיביים בלבד"** (demo version, fictitious data only).
>
> Production requirements (security level, Israeli privacy and MoH rules, retention, backend, real authentication) are in **hod-app-spec.md**, sections 4–5 and 11. They are out of scope here.

## Contents
1. Goals and non-goals
2. Technical frame
3. Screens and navigation
4. Modules
   - 4.1 Login and roles
   - 4.2 Rounds
   - 4.3 Resident file
   - 4.4 Movements
   - 4.5 Shift handover notes
   - 4.6 Service calls
   - 4.7 Exceptional events
   - 4.8 Medications and nursing (light)
   - 4.9 Settings
5. Mock data model (JSON)
6. Seed lists
7. Roles and permissions (simulated)
8. Build order
9. Definition of done

## 1. Goals and non-goals
**Goals**
- Show Ayelet and the staff a fast, simple, Hebrew RTL replacement for the daily Nativ workflows: the rounds, the resident file, movements, shift handover, service calls and exceptional events.
- Collect feedback on the flows and fields before a real backend is built.
- Make every screen usable on a desktop and a tablet, and respond instantly to the user.

**Non-goals**
- Real data, a backend, real authentication or multi-user sync. One browser holds one dataset.
- Legal or regulatory compliance. That is the production app's job (hod-app-spec.md, section 5).
- Finance, HR, training, property, pharmacy stock, physio, nutrition, the full medical file and the full eMAR.
- Migration from Nativ, and Nativ's actual logs. Mapping the shift log was dropped.

## 2. Technical frame
- **One file, `index.html`,** containing HTML, CSS and vanilla JS (or Preact/htm from a CDN), with `<html lang="he" dir="rtl">`. There is no build step, and it is served from GitHub Pages.
- **Storage:**
  - `localStorage` key `hod_demo_v1` holds a single JSON object (section 5).
  - A schema version field drives migration: if the version differs, reseed.
- **Seed and reset:**
  - On first load, seed about 60 fake residents across 2 buildings and 6 floors.
  - Settings has **"איפוס נתוני הדגמה"** (reset demo data), with a confirmation done inline, not as a modal.
  - Also provide JSON export and import of the dataset, for sharing demo states.
- **UX rules,** following the principles of hod-app-spec.md section 2:
  - **No blocking modals.** Use side panels, drawers and inline confirmation.
  - Inline validation messages next to the field.
  - Every list filters as the user types.
  - Dates are dd/mm/yyyy, times are 24h, and the clock is Asia/Jerusalem.
  - The font is system Hebrew (Assistant/Heebo from a CDN is optional).
  - The minimum tap target is 40px.
- **Audit (simulated):** each record carries `created_by/at` and `updated_by/at`, and status changes append to `history[]`.

## 3. Screens and navigation
- **Top bar:**
  - Logo, "סבב דיירים – הוד ירושלים", the demo banner, and the current user and role with a "החלף משתמש" (switch user) action.
  - Global search: resident by name or apartment, opening the resident file.
- **Main nav, right side:**
  1. **סבב** (rounds; the home screen)
  2. **דיירים** (resident list → resident file)
  3. **תנועות** (movements board)
  4. **מסירת משמרת** (shift handover)
  5. **קריאות שירות** (service calls)
  6. **אירועים חריגים** (exceptional events)
  7. **תרופות/סיעוד** (meds and nursing, light)
  8. **דוחות** (reports)
  9. **הגדרות** (settings)

  Items are hidden according to the role (section 7).
- **The resident side panel** (drawer) opens from any list. It shows the header, contacts, the open movement and the latest notes, with links to the full file.
- **Deep links:** hash routes, e.g. `#/round`, `#/resident/R012/benefits`, `#/calls?status=open`.

## 4. Modules

### 4.1 Login and roles (simulated)
- **Story:** as a staff member, I choose my user and see only what my role allows.
- **Layout:** the login screen shows a list of demo users as cards (name and role) and a PIN field. Every demo PIN is `1234`, as stated on the screen.
- **Behaviour:**
  - The session is stored under `hod_demo_session`.
  - Auto-logout after 15 minutes of inactivity simulates the production rule.
  - "החלף משתמש" is always available.
- **Acceptance:**
  - A reception user cannot see the meds view or the clinical fields.
  - An admin can open settings.
  - Switching users updates the nav immediately.

### 4.2 Rounds (סבב בוקר / סבב ערב), exactly as in Ayelet's feedback
**Stories**
- As a receptionist, I open the current shift's round and mark every resident as located, quickly.
- As the shift manager, I see who is still not located.

**Round generation**
- One round per shift per day: **סבב בוקר** and **סבב ערב**. It is created automatically when first opened in that shift (morning before 14:00, evening from 14:00). "הוספת סבב" adds a round manually.
- **Eligibility, driven by `living.lives_alone` (the "גר לבד" field):**
  - Morning round: all active residents.
  - Evening round: only residents with `lives_alone = true`. Residents living as a couple or with a live-in foreign caregiver (`living.arrangement` = `couple` | `with_caregiver`) appear **in the morning round only**.
- **Exclusions:**
  - Residents with an open away-movement (hospital, vacation, away) or an active preference get the status **לא לאיתור** automatically, and the reason is shown.

**Layout**
- **Header:** round name, date, and the counter "אותרו X מתוך Y". A progress bar and filters: building, floor, and search by name or apartment.
- **Tabs:** **טרם אותרו** (default) / **אותרו** / **לא לאיתור**.
- **Compact list:** dense rows (about 36px) with **no per-apartment header rows**. Columns: apartment, last name, first name, floor/building, phone (click to call), then the inline outcome buttons.
- **Inline outcomes on each row,** with **no "לא ענה" and no "עוד" menu:**
  - **ראיתי אותו/אותה**
  - **ענה בטלפון**
  - **ביקור פיזי בדירה**, which expands inline into two sub-buttons: **אותר בדירה** / **אותר מחוץ לבניין**
- **After marking:** the row moves to אותרו, showing the time, the method and the user. **ביטול** (undo) on a located row requires a reason, entered inline. The cancellation is kept in history.
- **Locating a whole apartment:** a couple sharing an apartment is located with one action, or each person separately.
- **Round note:** a free-text field.
- **Print:** a print view (`window.print`) with a print stylesheet.

**Statuses:** `pending` (טרם אותר) → `located` (method ∈ seen, phone, visit_apartment, visit_outside), or `excluded` (לא לאיתור, with a reason). The round itself is `open` → `completed` (when all are located or excluded) or `closed_manually`.

**Validations**
- A row can't be located twice; undo it first.
- Undo requires a reason of at least 2 characters.
- The round can be closed manually only by shift_manager or admin, and only with a note when residents are still pending.

**Acceptance**
- A resident whose living arrangement is a couple or with a caregiver never appears in the evening round. Switching "גר לבד" to yes makes them appear in the next evening round.
- There are 3 outcome buttons and no "לא ענה".
- ביקור פיזי shows exactly the two sub-options.
- Opening a hospital movement moves the resident to לא לאיתור in the open round.
- The counters update instantly.

### 4.3 Resident file (תיק דייר)
**Stories:** as staff, I find a resident and see their details, contacts, movements, notes and benefits on one screen.

**Resident list (דיירים)**
- **Columns:** apartment, name, building/floor, status, גר לבד, responsible social worker, nursing level.
- **Filters:** status, building, floor, social worker.
- **Action:** "דייר חדש" (new resident; admin only).

**File layout**
- **Header (always visible):** photo placeholder (avatar initials), name, apartment/floor/building, age, status (פעיל / בחופשה / באשפוז / עזב / נפטר), medical fund, an allergy badge (clinical roles only) and an open-movement badge.
- **Tabs:**
  1. **פרטים אישיים**
     - Fields: first name*, last name*, demo ID (`DEMO-0001`; a fake format, never a real ת.ז), gender, birth date*, mobile, email, languages, religion (optional), medical fund.
     - **Living arrangement:** `גר לבד` (yes/no)*, and when it is "no", `סוג מגורים` (couple / with a live-in caregiver / other)*.
     - Nursing functional level (עצמאי / תשוש / סיעודי) with history.
  2. **אנשי קשר:** name, relation, phone*, a "guardian / proxy" flag, and a "first to notify" flag.
  3. **תנועות:** this resident's movements (4.4).
  4. **תיק סוציאלי**
     - The header shows **עו"ס אחראי/ת** prominently. Choose from users with the social-worker role; seed: **חנה**, **שרית**.
     - Below it: a social follow-up notes list (date, author, text).
  5. **קצבאות**, with the חוק סיעוד fields from hod-app-spec.md section 12, laid out as in 6.4 below:
     - checkbox **זכאי/ת לגמלת סיעוד (חוק סיעוד)**;
     - when checked: **רמה** (1–6)*, **רמת זכאות** (מלאה/חלקית)*, **שעות סיעוד** (weekly hours, 0–60), **אופן קבלה** (חברת סיעוד + company name / גמלה כספית), **מוצרי ספיגה** (supplier, type, quantity per month), **עובד זר** (yes/no), and **שם תאגיד** (shown when the answer is yes).
     - The tab keeps a history with an effective-from date.
     - The **עובד זר** value is the same fact as `living.arrangement = with_caregiver`. It is stored once: setting one updates the other, with a hint.
  6. **הערות / קשר מחלקתי:** this resident's handover notes (4.5).
  7. **אירועים:** this resident's exceptional events (4.7). They are visible to the roles allowed in 7.
- **Actions:** עריכה / שמירה (inline edit mode with dirty-state warning), "פתח קריאת שירות", "דווח אירוע חריג", "פתח תנועה".

**Validations**
- Required fields are marked with \*.
- The phone must be 9–10 digits and start with 0.
- Dates can't be in the future (except planned ones).
- The level must be 1–6, and the hours 0–60.
- When the checkbox is unchecked, the חוק סיעוד fields are hidden but kept in history.

**Acceptance**
- The social worker's name shows at the top of the תיק סוציאלי tab and as a list column.
- Toggling עובד זר keeps the living arrangement consistent.
- All edits leave updated_by/at.

### 4.4 Movements (תנועות)
**Stories**
- As staff, I record that a resident left for the hospital or a vacation, and their return.
- As the manager, I see who is away right now.

**Board ("נמצאים מחוץ לבית")**
- Shows open movements: resident, type, since when, expected return, and destination (hospital or department).
- Overdue rows are highlighted red.

**New movement** (side panel)
- **Fields:** resident*, type*, start date and time*, expected return, destination (hospital list for אשפוז), note.
- **Types:** see 6.5.
- **Behaviour:**
  - Each type has `opens_state`: away / hospital / vacation / in_house / left.
  - **"חזר"** (returned) closes the open movement with one click, using now as the return time.
  - **Closing rules:** an opening type can only be closed by its matching closer. The demo builds them in, e.g. אשפוז → חזרה מאשפוז.

**Validations**
- Only one open away-movement per resident at a time.
- The return can't be earlier than the start.
- A hospital stay requires a hospital.

**Effects**
- The resident's header status changes.
- The resident is excluded from open rounds (4.2).
- A "left" or "deceased" type sets the resident status and removes them from future rounds.

**Acceptance**
- The open-movement badge appears everywhere.
- Return restores the resident to rounds.
- A history list shows every movement, filterable by type, dates and open-only.

### 4.5 Shift handover notes (מסירת משמרת)
**Stories**
- As the outgoing shift, I leave notes for the next shift, about a resident or the whole unit.
- As the incoming shift, I read what's new and confirm I've read it.

**Layout**
- A feed for the current shift and day (◄ ► to move between days), with filters for unit, resident, "requires action" and "unread".
- **New note:**
  - **Fields:** text*, resident (optional), unit, subject (כללי / רפואי / התנהגות / תחזוקה / משפחה), ☐ **דורש טיפול** (needs action), and assignee (role or user).
  - **Behaviour:** the shift is set automatically (בוקר 07–15, ערב 15–23, לילה 23–07).
- **Read tracking:**
  - Each note has **"קראתי"** (read). The list shows "נקרא ע"י N" with names.
  - Unread notes are bold for the current user.
- **Shift summary:** an auto-generated block with this shift's round result (located/total), movements opened or closed, new service calls, new events and notes with דורש טיפול. It can be printed.
- **Statuses:**
  - For דורש טיפול notes: `open` → `done` (who, when).
  - Notes are not editable after 15 minutes; a correction is a new linked note.

**Acceptance**
- The next-shift user sees the unread count in the nav.
- Marking done records the user and time.
- A note about a resident also appears in that resident's file.

### 4.6 Service calls (קריאות שירות)
**Stories**
- As staff, I open a maintenance call for an apartment quickly.
- As maintenance, I see my open calls by age.
- As the admin, I edit the categories and see response times.

**List**
- **Columns:** call no., opened date and time, apartment/location, category, urgency, status, handler, age (hh:mm, red when over the target).
- **Filters:** status, category, urgency, building, handler, dates.
- **Bulk action:** status change on selected rows.

**New or edit call** (side panel)
- **Fields:** location* (apartment or common area), resident (optional; prefilled when opened from the file), category*, description*, urgency* (רגילה / דחופה / דחוף ביותר), handler (default from the category), notify users.
- **Status flow:** `open` (נפתחה) → `assigned` (שובצה) → `in_progress` (בטיפול) → `done` (בוצעה) → `closed` (נסגרה), with `cancelled` (בוטלה, needs a reason) possible from any state before closed.
- **Timestamps:** opened_at, assigned_at, first_response_at (the first move to in_progress), done_at, closed_at.
- **History:** every status change goes to `history[]`, viewable in the call.

**Editable categories (settings, admin)**
- Add, rename, reorder (drag or ↑↓) and deactivate a category, with optional per-category settings: default handler, default urgency and target hours per urgency.
- A deactivated category stays on old calls but can't be chosen for new ones.

**Response-time reports (דוחות → קריאות שירות)**
- **Measures:** average and **median** time to first response and time to close.
- **Breakdowns:** category, urgency, handler and building/floor.
- **Scope:** a date range.
- **Also shown:**
  - open calls ordered by age;
  - overdue against the target (SLA);
  - CSV export, opening in Excel with a UTF-8 BOM for Hebrew.

**Validations**
- Closing requires done first.
- Cancelling requires a reason.
- The description must be at least 3 characters.

**Acceptance**
- A new category appears immediately in the form.
- A deactivated one disappears from the form but not from history.
- The report numbers match the seeded calls (seed with known durations).

### 4.7 Exceptional events (אירועים חריגים), a simplified section 11
**Stories**
- As any staff member, I report an event in under a minute.
- As a manager, I review, add corrective actions and close.

**Quick report** (a button in the top bar, from the resident file and from a round row)
- **Minimum fields:** event type*, date and time*, location*, resident(s)*, description* (factual).
- **Optional fields:**
  - immediate actions, injury (yes/no + description), hospital transfer (yes/no), witnesses/involved;
  - family/proxy notified (yes/no + time), doctor notified (yes/no + time);
  - ☐ near miss, which is set automatically for the type כמעט אירוע חריג.
- **Severity:** ללא נזק / קל / בינוני / חמור / מוות.

**Workflow, with manager review**
- `draft` (טיוטה) → `reported` (דווח) → `under_review` (בבדיקת מנהל) → `actions` (פעולות מתקנות) → `closed` (נסגר). `cancelled` (בוטל) requires a reason and is allowed only by the manager.
- **Who does what:**
  - The manager or chief nurse moves the event to under_review and fills in the **review**: findings, root cause, corrective actions (action, owner, due date, done ✓), and whether the care plan was updated.
  - Closing requires the review to be filled in and all actions done or explicitly waived.
- **Rules:**
  - A closed event is read-only; later additions are an "addendum".
  - For the type **אלימות**, a mandatory inline notice about the duty to report to the police or welfare officer (section 368D of the Penal Law) appears, with a checkbox "דווח / סיבת אי-דיווח" (reported / reason for not reporting).
  - **Notification checklist** (simplified from the section 11.2 matrix, display only): for each type, it shows who should be notified and the deadline, with a checkbox and time for each. **Nothing is sent externally.**

**List**
- **Columns:** no., date, type, resident, location, severity, status, days open.
- **Filters:** type, status, dates, unit, ☐ only open.
- **Counters by type and status:** a simple bar chart in דוחות.

**Access:** reception can report and sees only its own reports' status. Managers, nurses and social workers see everything (section 7).

**Acceptance**
- An event can't be closed without a review.
- Every status change goes into history (who, when).
- The event shows in the resident's אירועים tab.
- A print view of a single event is available.

### 4.8 Medications and nursing (light)
**Scope:** enough to show the shift worklist and tap-to-give idea. This is not a real eMAR; there is no prescribing, pharmacy or stock.

**Stories:** as a nurse, I see who has doses due this round and mark each as given or not given with a reason.

**Data:** each resident has 0–6 mock medication orders: drug name (fake or generic), dose, route, times (e.g. 08:00 / 13:00 / 20:00) and PRN yes/no.

**Screen "חלוקת תרופות"**
- **Header:** pick the med round (בוקר / צהריים / ערב / לילה); it defaults by the current time.
- **List:** residents with doses due in that round, grouped by floor. Residents who are away (open movement) are greyed out with the reason.
- **Per dose:**
  - **ניתן** (given; one tap, recording time and user).
  - **לא ניתן** + a reason* (סירב / ישן / באשפוז / לא במלאי / הושהה לפי הוראה / אחר + note).
  - An undo with a reason.
- **Due-dose counter:** given / total for the round.

**Vitals quick entry (optional, phase 4):** BP, pulse, temperature, saturation and weight per resident, shown with normal-range flags in red, plus a last-5 list in the file.

**Validations**
- "Not given" requires a reason.
- A dose can't be marked twice.
- Only nurse and shift_manager roles can access this screen.

**Acceptance:** away residents are excluded automatically, and the round counter and a per-resident MAR grid for today are correct.

### 4.9 Settings (הגדרות, admin)
- Service-call categories (4.6).
- Users and roles: the demo user list, add/edit, social-worker flag.
- Buildings, floors and apartments.
- Movement types: read-only list.
- Event types and the notification checklist per type.
- Shift times.
- Reset demo data, and export/import JSON.

## 5. Mock data model (JSON)
```json
{
  "version": 1,
  "users": [{"id":"U1","name":"חנה","role":"social_worker","pin":"1234","active":true}],
  "units": [{"id":"A5","building":"א","floor":5,"label":"קומה 5 בניין א"}],
  "residents": [{
    "id":"R001","demo_id":"DEMO-0001","first_name":"רחל","last_name":"לדוגמה",
    "gender":"F","birth_date":"1938-03-12","apartment":"512","unit_id":"A5",
    "phone":"050-0000001","status":"active","medical_fund":"כללית",
    "living":{"lives_alone":false,"arrangement":"with_caregiver"},
    "nursing_level":[{"level":"תשוש","from":"2025-01-01"}],
    "responsible_social_worker_id":"U1",
    "contacts":[{"name":"בן משפחה לדוגמה","relation":"בן","phone":"050-0000002","is_proxy":true,"notify_first":true}],
    "benefits":[{"from":"2026-01-01","ltc_eligible":true,"level":3,"eligibility":"full",
      "care_hours_weekly":12,"receipt":"company","care_company":"חברת סיעוד לדוגמה",
      "absorbent":{"supplier":"ספק לדוגמה","type":"מכנס","qty_month":60},
      "foreign_worker":true,"agency":"תאגיד לדוגמה"}],
    "allergies":["פניצילין"],
    "created_by":"U3","created_at":"2026-11-01T09:00:00+02:00","updated_by":"U3","updated_at":"2026-11-01T09:00:00+02:00"
  }],
  "rounds": [{"id":"RD-20261104-E","date":"2026-11-04","shift":"evening","status":"open","note":"",
    "entries":[{"resident_id":"R002","status":"located","method":"visit_outside","at":"2026-11-04T19:10:00+02:00","by":"U2",
      "history":[{"status":"pending","at":"…"}]}]}],
  "preferences": [{"resident_id":"R003","type":"no_check","from":"2026-11-01","to":null,"reason":"…"}],
  "movements": [{"id":"M1","resident_id":"R004","type":"hospital","opens_state":"hospital","start":"2026-11-02T10:00:00+02:00",
    "expected_return":null,"end":null,"hospital":"בית חולים לדוגמה","note":"","by":"U2"}],
  "handover_notes": [{"id":"N1","at":"…","shift":"morning","unit_id":"A5","resident_id":null,"subject":"כללי",
    "text":"…","needs_action":true,"assignee":"role:nurse","status":"open","read_by":[{"user":"U4","at":"…"}],"by":"U2"}],
  "service_categories": [{"id":"C1","name":"חשמל","order":1,"active":true,"default_handler":"U5","default_urgency":"normal",
    "target_hours":{"normal":48,"urgent":8,"critical":2}}],
  "service_calls": [{"id":"SC-1001","location":"דירה 512","resident_id":"R001","category_id":"C1","urgency":"normal",
    "description":"…","handler":"U5","status":"in_progress","opened_at":"…","assigned_at":"…","first_response_at":"…",
    "done_at":null,"closed_at":null,"history":[{"status":"open","at":"…","by":"U2"}]}],
  "event_types": [{"id":"E_FALL","name":"נפילה","active":true,"notify":[{"to":"family_proxy","within_min":60},{"to":"doctor","within_min":60},{"to":"manager","within_min":1440}]}],
  "events": [{"id":"EV-2026-001","type_id":"E_FALL","occurred_at":"…","reported_at":"…","reported_by":"U2","location":"חדר אוכל",
    "resident_ids":["R001"],"description":"…","immediate_actions":"…","severity":"minor","near_miss":false,"injury":false,
    "hospital_transfer":false,"notifications":[{"to":"doctor","done":true,"at":"…"}],"status":"under_review",
    "review":{"by":"U6","findings":"…","root_cause":"…","actions":[{"text":"…","owner":"U4","due":"2026-11-10","done_at":null}],"care_plan_updated":false},
    "addenda":[],"history":[{"status":"reported","at":"…","by":"U2"}]}],
  "med_orders": [{"id":"MO1","resident_id":"R001","drug":"תרופה לדוגמה 5mg","dose":"1 טבליה","route":"פומי","times":["08:00","20:00"],"prn":false,"active":true}],
  "med_admin": [{"order_id":"MO1","date":"2026-11-04","time":"08:00","status":"given","reason":null,"at":"…","by":"U4"}],
  "vitals": [{"resident_id":"R001","type":"bp","value":"130/80","at":"…","by":"U4"}],
  "settings": {"shifts":{"morning":"07:00","evening":"15:00","night":"23:00"},"round_evening_from":"14:00"}
}
```
All IDs are strings, and timestamps are ISO with `+02:00`/`+03:00`. Phones in the seed are `050-00000NN` only.

## 6. Seed lists
### 6.1 Service-call categories (editable)
חשמל · אינסטלציה · תיקונים · צבע · מנעול · מיזוג אוויר · ריהוט · ניקיון · מעלית · אחר.
- **Urgency:** רגילה / דחופה / דחוף ביותר.
- **Target hours:** 48 / 8 / 2.

### 6.2 Exceptional event types
These are Nativ's types (hod-app-spec 3.6.9) plus the section 11.2 types Nativ lacks:
- **From Nativ:** אחר, אלימות, חבלה/סימן, טעות בטיפול, כמעט אירוע חריג, נפילה, פגיעה בשלמות העור, שליפת צנטר, השפעת תרופות, תאונה בזמן העברה, תאונות.
- **Added:** היעדרות / דייר חסר, פטירה, חשד להתעללות או הזנחה, זיהום / מחלה מדבקת, חנק / אספירציה, אובדן או גניבת רכוש, אירוע פרטיות / אבטחת מידע, אירוע חירום (שריפה, הצפה, הפסקת חשמל).

### 6.3 Statuses
- **Round entry:** טרם אותר / אותר (ראיתי · ענה בטלפון · אותר בדירה · אותר מחוץ לבניין) / לא לאיתור.
- **Round:** פתוח / הושלם / נסגר ידנית.
- **Resident:** פעיל / בחופשה / באשפוז / עזב / נפטר.
- **Service call:** נפתחה / שובצה / בטיפול / בוצעה / נסגרה / בוטלה.
- **Event:** טיוטה / דווח / בבדיקת מנהל / פעולות מתקנות / נסגר / בוטל.
- **Handover note:** פתוח / טופל.
- **Dose:** ממתין / ניתן / לא ניתן.

### 6.4 חוק סיעוד fields (hod-app-spec section 12)
- זכאי/ת לגמלת סיעוד (checkbox).
- רמה: 1–6.
- רמת זכאות: מלאה / חלקית.
- שעות סיעוד (weekly).
- אופן קבלה: חברת סיעוד (+ שם חברה) / גמלה כספית.
- מוצרי ספיגה: ספק, סוג, כמות לחודש.
- עובד זר: כן / לא.
- שם תאגיד.
- The record has an effective-from date (history).

### 6.5 Movement types
| Opener | Closer | Effect |
|---|---|---|
| אשפוז | חזרה מאשפוז | hospital |
| חופשה | חזרה מחופשה | vacation |
| יציאה זמנית | חזרה | away |
| עזיבה | (none) | left |
| פטירה | (none) | deceased |

### 6.6 Demo users
| User | Role |
|---|---|
| קבלה 1 | reception |
| אחראי משמרת | shift_manager |
| אחות 1 | nurse |
| חנה | social_worker |
| שרית | social_worker |
| אב בית | maintenance |
| מנהלת | manager |
| מנהל מערכת | admin |

## 7. Roles and permissions (simulated)
Permissions are checked in the UI only (they are not secure, and that is fine for the demo). They are centralised in one `can(role, action)` table.

| Area | reception | shift_manager | nurse | social_worker | maintenance | manager | admin |
|---|---|---|---|---|---|---|---|
| Rounds: run | ✓ | ✓ | ✓ | – | – | ✓ | ✓ |
| Rounds: close manually / undo | – | ✓ | – | – | – | ✓ | ✓ |
| Resident file: basic | view | view | view | view | location only | edit | edit |
| Clinical fields, meds | – | ✓ | ✓ | – | – | view | ✓ |
| תיק סוציאלי, קצבאות | – | view | view | edit | – | edit | edit |
| Movements | create | ✓ | ✓ | view | – | ✓ | ✓ |
| Handover notes | ✓ | ✓ | ✓ | ✓ | view | ✓ | ✓ |
| Service calls | create | ✓ | create | create | handle | ✓ | ✓ |
| Events: report | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Events: view all / review / close | own only | view | view | view | own only | ✓ | ✓ |
| Reports | – | ✓ | ✓ | ✓ | calls only | ✓ | ✓ |
| Settings | – | – | – | – | – | categories | ✓ |

## 8. Build order
| Phase | Scope | Done when |
|---|---|---|
| **0. Shell** | index.html, RTL layout, nav, hash router, storage layer with versioning, seed (60 residents, users), demo banner, simulated login and `can()` | Login works, nav follows the role, reset reseeds |
| **1. Rounds and residents** | Rounds (4.2) with the גר לבד eligibility, resident list and file (4.3: personal, contacts, תיק סוציאלי with the social worker), side panel | Ayelet's 4.2 criteria pass |
| **2. Movements and handover** | Movements board and closing (4.4), wired into rounds exclusion; handover notes with read tracking and shift summary (4.5) | Hospital exclusion works; unread count works |
| **3. Service calls and קצבאות** | Calls (4.6), editable categories, response-time report and CSV; the קצבאות / חוק סיעוד tab (4.3) | Report numbers match the seed |
| **4. Events and meds** | Exceptional events with manager review (4.7); light meds round (4.8) and optional vitals | An event can't close without a review; dose reason required |
| **5. Polish** | Reports page, print styles, JSON export/import, empty states, keyboard shortcuts, accessibility (labels, focus, contrast), tablet layout | Definition of done |

## 9. Definition of done
- Every acceptance criterion in section 4 passes manually on Chrome and Edge, desktop and tablet.
- There are no blocking modals, and every Hebrew screen is RTL.
- The demo banner is always visible.
- Searching the repo finds no real names, ID numbers or phone numbers. A seed-data review is part of each PR: fake names only, `050-00000NN` phones and `DEMO-` IDs.
- The README states the mock-data-only rule and links to hod-app-spec.md for the production requirements.
