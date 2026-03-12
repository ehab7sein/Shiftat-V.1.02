# 🗄️ Shiftat — Database

Supabase / PostgreSQL schema for the **Shiftat** mobile job marketplace.

---

## 📁 Files

| File | Description |
|---|---|
| `schema.sql` | Complete Phase 1 schema — run once on a fresh Supabase project |

---

## ⚡ Quick Start

### 1. Create a Supabase project
Go to [supabase.com](https://supabase.com), create a new project, and note your **Project URL** and **anon/service_role keys**.

### 2. Enable required extensions
In your Supabase dashboard → **Database → Extensions**, enable:
- `uuid-ossp`
- `PostGIS`
- `pg_cron`
- `unaccent`

Or they will be enabled automatically by the first lines of `schema.sql`.

### 3. Run the schema
Paste `schema.sql` into **SQL Editor → New query** and click **Run**.

Alternatively, use the Supabase CLI:
```bash
supabase db push --db-url postgresql://postgres:<password>@<host>:5432/postgres
```

---

## 🏗️ Schema Overview

### Tables

| Table | Purpose |
|---|---|
| `profiles` | One row per user (extends `auth.users`). Holds name, phone, user_type, city, FCM token. |
| `skill_tags` | Master list of job skill/category labels (Arabic + English). |
| `worker_skills` | Many-to-many: which skills a worker has. |
| `jobs` | Job listings posted by employers. Includes PostGIS `location` point. |
| `job_required_skills` | Many-to-many: skills required for a job. |
| `applications` | Worker applications to jobs. Tracks status lifecycle + phone privacy gate. |
| `saved_jobs` | Worker bookmarks (P1 feature). |
| `ratings` | Post-hire employer ↔ worker mutual ratings (P1 feature). |
| `notifications` | In-app + push notification log. |
| `phone_verifications` | Audit log for OTP requests (rate-limiting). |

### Enums

| Enum | Values |
|---|---|
| `user_type` | `employer`, `worker` |
| `job_status` | `draft`, `active`, `filled`, `expired`, `cancelled` |
| `shift_type` | `morning`, `evening`, `night`, `full_day`, `flexible`, `variable` |
| `application_status` | `pending`, `viewed`, `interview_scheduled`, `hired`, `rejected`, `withdrawn` |
| `notification_type` | `new_application`, `application_viewed`, `interview_scheduled`, `application_accepted`, `application_rejected`, `job_expired`, `system` |

### Views

| View | Purpose |
|---|---|
| `job_feed` | Public feed of active jobs with employer name (no sensitive data). |
| `my_applications` | Authenticated worker's application history; employer phone revealed only after acceptance/interview. |

---

## 🔒 Security Model

All tables use **Row Level Security (RLS)**:

| Table | Who can SELECT | Who can INSERT/UPDATE |
|---|---|---|
| `profiles` | Everyone (public) | Own row only |
| `jobs` | Active jobs (all) + own drafts | Employers only, own jobs |
| `applications` | Worker = own; Employer = on their jobs | Workers insert; both can update |
| `saved_jobs` | Own rows only | Own rows only |
| `ratings` | Public | Rater = self |
| `notifications` | Own rows only | Own rows only |

Phone numbers are **never exposed** in `applications` unless `phone_revealed = TRUE`, which is only set when an application moves to `hired` or `interview_scheduled`.

---

## ⏰ Automated Jobs (pg_cron)

| Job | Schedule | Action |
|---|---|---|
| `expire-stale-jobs` | Every hour | Sets `status = 'expired'` on active jobs past their `expires_at` |

---

## 🌱 Seed Data

15 common skill/job-type tags are pre-seeded in Arabic and English (waiters, cooks, drivers, cleaners, etc.).

---

## 📐 Entity Relationship Diagram

```
auth.users
    │ (1:1 trigger)
    ▼
profiles ──────────────────────────────────────────────────────┐
    │                                                           │
    │ (employer)          (worker)                             │
    ▼                        ▼                                 │
  jobs ◄──── job_required_skills    worker_skills              │
    │              │                     │                     │
    │        skill_tags ◄────────────────┘                     │
    │                                                           │
    ▼                                                           │
applications ──► phone_revealed gate ──► expose employer phone ┘
    │
    ├──► notifications (worker + employer)
    │
    └──► ratings (post-hire)
```
