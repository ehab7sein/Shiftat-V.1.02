# Build Worker Feed with Egyptian Localization

**Description:**  
Implement the discovery feed for workers using Supabase Realtime for job updates, localized for Egypt's main governorates (Cairo, Giza, Alexandria, etc.).

**Priority:**  
High

**Complexity:**  
Hard

**Notes:**  
- **Reference:** Use `@UI/worker_home_screen/code.html`.
- Backend: Fetch jobs from Supabase using `order('created_at', { ascending: false })`.
- Localization: Use Egyptian Arabic labels for categories (e.g., "ويتر" for Waiter, "عامل نظافة").
