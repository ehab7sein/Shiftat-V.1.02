-- ============================================================
-- SHIFTAT — Mobile Job Marketplace
-- Supabase / PostgreSQL Database Schema
-- Phase 1 — MVP Core Entities
-- ============================================================
-- Stack: Supabase (PostgreSQL 15+, PostGIS, RLS enabled)
-- Last updated: 2026-03-12
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 0. EXTENSIONS
-- ────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";        -- Location-based queries
CREATE EXTENSION IF NOT EXISTS "pg_cron";        -- Scheduled jobs (e.g. auto-expire)
CREATE EXTENSION IF NOT EXISTS "unaccent";       -- Arabic text search normalisation


-- ────────────────────────────────────────────────────────────
-- 1. ENUMS
-- ────────────────────────────────────────────────────────────

-- User role in the marketplace
CREATE TYPE user_type AS ENUM ('employer', 'worker');

-- Lifecycle state of every job listing
CREATE TYPE job_status AS ENUM (
  'draft',       -- saved but not published
  'active',      -- visible to workers
  'filled',      -- position(s) hired
  'expired',     -- auto-closed after 7 days
  'cancelled'    -- employer closed early
);

-- Shift schedule options
CREATE TYPE shift_type AS ENUM (
  'morning',     -- صباحي
  'evening',     -- مسائي
  'night',       -- ليلي
  'full_day',    -- يوم كامل
  'flexible',    -- مرونة في التوقيت
  'variable'     -- جدول متغير (employer specifies in notes)
);

-- Application lifecycle
CREATE TYPE application_status AS ENUM (
  'pending',              -- submitted, awaiting employer review
  'viewed',               -- employer opened the application
  'interview_scheduled',  -- employer set an interview
  'hired',                -- employer marked as hired
  'rejected',             -- employer rejected
  'withdrawn'             -- worker withdrew their application
);

-- Notification event categories
CREATE TYPE notification_type AS ENUM (
  'new_application',       -- employer: someone applied
  'application_viewed',    -- worker: employer viewed their app
  'interview_scheduled',   -- worker: interview was set
  'application_accepted',  -- worker: they were hired
  'application_rejected',  -- worker: they were rejected
  'job_expired',           -- employer: job auto-expired
  'system'                 -- platform-level notices
);


-- ────────────────────────────────────────────────────────────
-- 2. PROFILES
-- Extends Supabase auth.users (one row per authenticated user)
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.profiles (
  id              UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone           TEXT        NOT NULL UNIQUE,          -- E.164 format (+20...)
  user_type       user_type   NOT NULL,
  full_name       TEXT        NOT NULL,
  city            TEXT,                                  -- free-text city name (Arabic)
  avatar_url      TEXT,                                  -- Supabase Storage URL
  bio             TEXT,                                  -- short worker bio / employer description
  is_verified     BOOLEAN     NOT NULL DEFAULT FALSE,    -- phone OTP verified
  is_active       BOOLEAN     NOT NULL DEFAULT TRUE,     -- soft-delete flag
  fcm_token       TEXT,                                  -- Firebase Cloud Messaging device token
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_profiles_user_type ON public.profiles (user_type);
CREATE INDEX idx_profiles_city      ON public.profiles (city);
CREATE INDEX idx_profiles_phone     ON public.profiles (phone);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ────────────────────────────────────────────────────────────
-- 3. WORKER SKILLS (normalised many-to-many)
-- ────────────────────────────────────────────────────────────

-- Reference list of available skills / job types
CREATE TABLE public.skill_tags (
  id          SERIAL      PRIMARY KEY,
  name_ar     TEXT        NOT NULL UNIQUE,   -- Arabic label shown in UI
  name_en     TEXT        NOT NULL UNIQUE,   -- internal / search key
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Worker → skill mapping
CREATE TABLE public.worker_skills (
  worker_id   UUID    NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  skill_id    INTEGER NOT NULL REFERENCES public.skill_tags(id) ON DELETE CASCADE,
  PRIMARY KEY (worker_id, skill_id)
);

CREATE INDEX idx_worker_skills_worker ON public.worker_skills (worker_id);
CREATE INDEX idx_worker_skills_skill  ON public.worker_skills (skill_id);


-- ────────────────────────────────────────────────────────────
-- 4. JOBS
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.jobs (
  id                  UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  employer_id         UUID          NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

  -- Basic details
  title               TEXT          NOT NULL,
  description         TEXT,
  workers_needed      INTEGER       NOT NULL DEFAULT 1 CHECK (workers_needed >= 1),

  -- Location
  location_description TEXT         NOT NULL,           -- human-readable address (Arabic)
  location            GEOGRAPHY(POINT, 4326),           -- PostGIS coordinates (lat/lng)
  city                TEXT,

  -- Compensation & schedule
  salary_egp          NUMERIC(10,2),                    -- salary per shift in EGP
  salary_max_egp      NUMERIC(10,2),                    -- upper bound for ranges
  shift_type          shift_type    NOT NULL,
  shift_notes         TEXT,                             -- extra schedule details
  start_date          DATE,                             -- when the gig starts
  end_date            DATE,                             -- when the gig ends (null = open-ended)

  -- Metadata
  status              job_status    NOT NULL DEFAULT 'draft',
  views_count         INTEGER       NOT NULL DEFAULT 0,
  applications_count  INTEGER       NOT NULL DEFAULT 0,
  expires_at          TIMESTAMPTZ   NOT NULL DEFAULT (NOW() + INTERVAL '7 days'),
  created_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Indexes for common queries
CREATE INDEX idx_jobs_employer        ON public.jobs (employer_id);
CREATE INDEX idx_jobs_status          ON public.jobs (status);
CREATE INDEX idx_jobs_city            ON public.jobs (city);
CREATE INDEX idx_jobs_created         ON public.jobs (created_at DESC);
CREATE INDEX idx_jobs_expires         ON public.jobs (expires_at);
CREATE INDEX idx_jobs_location        ON public.jobs USING GIST (location);  -- spatial
CREATE INDEX idx_jobs_salary          ON public.jobs (salary_egp);

-- Auto-update updated_at
CREATE TRIGGER trg_jobs_updated_at
  BEFORE UPDATE ON public.jobs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ────────────────────────────────────────────────────────────
-- 4a. JOB REQUIRED SKILLS (normalised many-to-many)
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.job_required_skills (
  job_id      UUID    NOT NULL REFERENCES public.jobs(id) ON DELETE CASCADE,
  skill_id    INTEGER NOT NULL REFERENCES public.skill_tags(id) ON DELETE CASCADE,
  PRIMARY KEY (job_id, skill_id)
);

CREATE INDEX idx_job_skills_job   ON public.job_required_skills (job_id);
CREATE INDEX idx_job_skills_skill ON public.job_required_skills (skill_id);


-- ────────────────────────────────────────────────────────────
-- 5. APPLICATIONS
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.applications (
  id                  UUID               PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_id              UUID               NOT NULL REFERENCES public.jobs(id) ON DELETE CASCADE,
  worker_id           UUID               NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

  status              application_status NOT NULL DEFAULT 'pending',
  cover_note          TEXT,                                -- optional short message from worker
  phone_revealed      BOOLEAN            NOT NULL DEFAULT FALSE,  -- privacy gate

  -- Interview details (set by employer)
  interview_at        TIMESTAMPTZ,
  interview_location  TEXT,
  interview_notes     TEXT,

  applied_at          TIMESTAMPTZ        NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ        NOT NULL DEFAULT NOW(),

  -- Prevent duplicate applications
  UNIQUE (job_id, worker_id)
);

-- Indexes
CREATE INDEX idx_applications_job        ON public.applications (job_id);
CREATE INDEX idx_applications_worker     ON public.applications (worker_id);
CREATE INDEX idx_applications_status     ON public.applications (status);
CREATE INDEX idx_applications_applied    ON public.applications (applied_at DESC);

-- Auto-update updated_at
CREATE TRIGGER trg_applications_updated_at
  BEFORE UPDATE ON public.applications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Increment / decrement applications_count on jobs
CREATE OR REPLACE FUNCTION sync_applications_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.jobs
    SET applications_count = applications_count + 1
    WHERE id = NEW.job_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.jobs
    SET applications_count = GREATEST(applications_count - 1, 0)
    WHERE id = OLD.job_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_applications_count
  AFTER INSERT OR DELETE ON public.applications
  FOR EACH ROW EXECUTE FUNCTION sync_applications_count();


-- ────────────────────────────────────────────────────────────
-- 6. SAVED JOBS (bookmarks — P1 feature, schema ready now)
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.saved_jobs (
  worker_id   UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  job_id      UUID        NOT NULL REFERENCES public.jobs(id) ON DELETE CASCADE,
  saved_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (worker_id, job_id)
);

CREATE INDEX idx_saved_jobs_worker ON public.saved_jobs (worker_id);
CREATE INDEX idx_saved_jobs_job    ON public.saved_jobs (job_id);


-- ────────────────────────────────────────────────────────────
-- 7. RATINGS  (P1 — employer ↔ worker, schema ready now)
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.ratings (
  id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  application_id  UUID        NOT NULL REFERENCES public.applications(id) ON DELETE CASCADE,
  rater_id        UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  ratee_id        UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

  score           SMALLINT    NOT NULL CHECK (score BETWEEN 1 AND 5),
  comment         TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- One rating per direction per application
  UNIQUE (application_id, rater_id)
);

CREATE INDEX idx_ratings_ratee ON public.ratings (ratee_id);


-- ────────────────────────────────────────────────────────────
-- 8. NOTIFICATIONS
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.notifications (
  id              UUID              PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipient_id    UUID              NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type            notification_type NOT NULL,
  title_ar        TEXT              NOT NULL,   -- Arabic push title
  body_ar         TEXT              NOT NULL,   -- Arabic push body
  data            JSONB,                        -- extra payload (job_id, application_id …)
  is_read         BOOLEAN           NOT NULL DEFAULT FALSE,
  sent_at         TIMESTAMPTZ       NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_recipient ON public.notifications (recipient_id, is_read, sent_at DESC);


-- ────────────────────────────────────────────────────────────
-- 9. OTP / PHONE VERIFICATION SESSIONS
-- (Supabase handles phone OTP natively; this table is for
--  custom resend-rate-limiting and audit logging only)
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.phone_verifications (
  id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone           TEXT        NOT NULL,
  requested_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  verified_at     TIMESTAMPTZ,
  ip_address      INET,
  user_agent      TEXT
);

CREATE INDEX idx_phone_verif_phone ON public.phone_verifications (phone, requested_at DESC);


-- ────────────────────────────────────────────────────────────
-- 10. ROW LEVEL SECURITY (RLS)
-- ────────────────────────────────────────────────────────────

-- Enable RLS on all user-facing tables
ALTER TABLE public.profiles           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.applications       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_jobs         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ratings            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.worker_skills      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_required_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.phone_verifications ENABLE ROW LEVEL SECURITY;

-- ── profiles ──────────────────────────────────────────────
-- Anyone can read public profile info; only the owner can write
CREATE POLICY "profiles_select_public"
  ON public.profiles FOR SELECT
  USING (TRUE);  -- profiles are public read (no phone revealed here)

CREATE POLICY "profiles_insert_own"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_own"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- ── jobs ──────────────────────────────────────────────────
-- Workers can read active jobs; employers manage their own
CREATE POLICY "jobs_select_active"
  ON public.jobs FOR SELECT
  USING (
    status = 'active'
    OR employer_id = auth.uid()
  );

CREATE POLICY "jobs_insert_employer"
  ON public.jobs FOR INSERT
  WITH CHECK (
    auth.uid() = employer_id
    AND (SELECT user_type FROM public.profiles WHERE id = auth.uid()) = 'employer'
  );

CREATE POLICY "jobs_update_own"
  ON public.jobs FOR UPDATE
  USING (employer_id = auth.uid());

CREATE POLICY "jobs_delete_own"
  ON public.jobs FOR DELETE
  USING (employer_id = auth.uid());

-- ── applications ──────────────────────────────────────────
-- Worker sees their own; employer sees applications on their jobs
CREATE POLICY "applications_select"
  ON public.applications FOR SELECT
  USING (
    worker_id = auth.uid()
    OR job_id IN (SELECT id FROM public.jobs WHERE employer_id = auth.uid())
  );

CREATE POLICY "applications_insert_worker"
  ON public.applications FOR INSERT
  WITH CHECK (
    auth.uid() = worker_id
    AND (SELECT user_type FROM public.profiles WHERE id = auth.uid()) = 'worker'
  );

CREATE POLICY "applications_update"
  ON public.applications FOR UPDATE
  USING (
    -- worker can withdraw; employer can update status/interview
    worker_id = auth.uid()
    OR job_id IN (SELECT id FROM public.jobs WHERE employer_id = auth.uid())
  );

-- ── saved_jobs ────────────────────────────────────────────
CREATE POLICY "saved_jobs_own"
  ON public.saved_jobs FOR ALL
  USING (worker_id = auth.uid())
  WITH CHECK (worker_id = auth.uid());

-- ── ratings ───────────────────────────────────────────────
CREATE POLICY "ratings_select"
  ON public.ratings FOR SELECT
  USING (TRUE);  -- ratings are public

CREATE POLICY "ratings_insert_own"
  ON public.ratings FOR INSERT
  WITH CHECK (rater_id = auth.uid());

-- ── notifications ─────────────────────────────────────────
CREATE POLICY "notifications_own"
  ON public.notifications FOR ALL
  USING (recipient_id = auth.uid())
  WITH CHECK (recipient_id = auth.uid());

-- ── worker_skills ─────────────────────────────────────────
CREATE POLICY "worker_skills_select"
  ON public.worker_skills FOR SELECT USING (TRUE);

CREATE POLICY "worker_skills_manage_own"
  ON public.worker_skills FOR ALL
  USING (worker_id = auth.uid())
  WITH CHECK (worker_id = auth.uid());

-- ── job_required_skills ───────────────────────────────────
CREATE POLICY "job_skills_select"
  ON public.job_required_skills FOR SELECT USING (TRUE);

CREATE POLICY "job_skills_manage_employer"
  ON public.job_required_skills FOR ALL
  USING (job_id IN (SELECT id FROM public.jobs WHERE employer_id = auth.uid()))
  WITH CHECK (job_id IN (SELECT id FROM public.jobs WHERE employer_id = auth.uid()));

-- ── phone_verifications ───────────────────────────────────
-- Service role only; no direct user access
CREATE POLICY "phone_verif_deny_all"
  ON public.phone_verifications FOR ALL
  USING (FALSE);


-- ────────────────────────────────────────────────────────────
-- 11. VIEWS (convenience / security)
-- ────────────────────────────────────────────────────────────

-- Public job feed with employer name, hides internal fields
CREATE OR REPLACE VIEW public.job_feed AS
SELECT
  j.id,
  j.title,
  j.description,
  j.workers_needed,
  j.location_description,
  j.city,
  j.salary_egp,
  j.salary_max_egp,
  j.shift_type,
  j.shift_notes,
  j.start_date,
  j.end_date,
  j.status,
  j.views_count,
  j.applications_count,
  j.expires_at,
  j.created_at,
  p.full_name   AS employer_name,
  p.city        AS employer_city
FROM public.jobs j
JOIN public.profiles p ON p.id = j.employer_id
WHERE j.status = 'active';

-- Worker application list (includes interview info, hides employer phone unless revealed)
CREATE OR REPLACE VIEW public.my_applications AS
SELECT
  a.id,
  a.job_id,
  a.status,
  a.cover_note,
  a.phone_revealed,
  a.interview_at,
  a.interview_location,
  a.interview_notes,
  a.applied_at,
  j.title          AS job_title,
  j.location_description,
  j.salary_egp,
  j.shift_type,
  -- Only expose employer phone after acceptance
  CASE WHEN a.phone_revealed THEN emp.phone ELSE NULL END AS employer_phone,
  emp.full_name    AS employer_name
FROM public.applications a
JOIN public.jobs     j   ON j.id  = a.job_id
JOIN public.profiles emp ON emp.id = j.employer_id
WHERE a.worker_id = auth.uid();


-- ────────────────────────────────────────────────────────────
-- 12. FUNCTIONS & TRIGGERS
-- ────────────────────────────────────────────────────────────

-- Increment views_count when a worker opens a job
CREATE OR REPLACE FUNCTION increment_job_views(p_job_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.jobs
  SET views_count = views_count + 1
  WHERE id = p_job_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Reveal phone number when application is accepted or interview is scheduled
CREATE OR REPLACE FUNCTION maybe_reveal_phone()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status IN ('hired', 'interview_scheduled') AND NOT OLD.phone_revealed THEN
    NEW.phone_revealed := TRUE;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_reveal_phone
  BEFORE UPDATE ON public.applications
  FOR EACH ROW EXECUTE FUNCTION maybe_reveal_phone();

-- Auto-expire active jobs past their expires_at timestamp
-- (scheduled via pg_cron every hour)
CREATE OR REPLACE FUNCTION expire_stale_jobs()
RETURNS VOID AS $$
BEGIN
  UPDATE public.jobs
  SET status = 'expired'
  WHERE status = 'active'
    AND expires_at < NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Register the cron job (runs every hour)
SELECT cron.schedule(
  'expire-stale-jobs',      -- job name (idempotent)
  '0 * * * *',              -- every hour at :00
  'SELECT expire_stale_jobs();'
);

-- New profile trigger: auto-create profile row after auth.users insert
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, phone, user_type, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.phone, ''),
    COALESCE((NEW.raw_user_meta_data->>'user_type')::user_type, 'worker'),
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();


-- ────────────────────────────────────────────────────────────
-- 13. SEED DATA — Skill Tags
-- ────────────────────────────────────────────────────────────
INSERT INTO public.skill_tags (name_ar, name_en) VALUES
  ('نادل / نادلة',         'waiter'),
  ('طباخ / طاهٍ',          'cook'),
  ('عامل نظافة',           'cleaner'),
  ('سائق',                  'driver'),
  ('مساعد عام',             'general_helper'),
  ('أمن وحراسة',            'security_guard'),
  ('تحميل وتفريغ',          'loader_unloader'),
  ('بائع / كاشير',          'cashier_salesperson'),
  ('موظف استقبال',          'receptionist'),
  ('عامل مستودع',           'warehouse_worker'),
  ('ميكانيكي',              'mechanic'),
  ('كهربائي',               'electrician'),
  ('نجار',                  'carpenter'),
  ('دهان / بوية',           'painter'),
  ('مندوب توصيل',           'delivery_rider')
ON CONFLICT (name_en) DO NOTHING;


-- ────────────────────────────────────────────────────────────
-- END OF SCHEMA
-- ────────────────────────────────────────────────────────────
