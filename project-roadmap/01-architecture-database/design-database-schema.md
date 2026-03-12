# Design Supabase Schema for Core Entities

**Description:**  
Define the PostgreSQL relational database schema within Supabase to support users, jobs, applications, and sessions. Ensure proper indexing for location-based queries using PostGIS (available as a Supabase extension).

**Priority:**  
High

**Complexity:**  
Medium

**Notes:**  
- Tables needed: `profiles` (id, phone, user_type, full_name, city), `jobs` (id, employer_id, title, location_description, salary_egp, shift_type, status), `applications` (id, job_id, worker_id, status, applied_at).
- Enable Supabase Row Level Security (RLS) for all tables.
- Use Supabase Edge Functions for any complex server-side logic (e.g., SMS triggers).
