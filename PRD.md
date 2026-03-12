# One-pager: Mobile Job Marketplace for Short-Term Work

## 1. TL;DR
A mobile-first Flutter application that connects small business owners and individuals with workers seeking simple, short-term jobs (waiters, cleaners, drivers, helpers, etc.). Built entirely in Arabic with a simplified interface for users with limited technical or educational background, the platform replaces unreliable word-of-mouth hiring with a centralized, efficient marketplace where employers post opportunities and workers discover and apply for nearby gigs.

## 2. Goals

### Business Goals
* Create a sustainable two-sided marketplace that grows both employer and worker user bases simultaneously
* Establish the platform as the go-to solution for short-term hiring in target markets, replacing social media groups and personal networks
* Achieve strong application-to-hire conversion rates (targeting 30%+ within first 6 months)
* Build a scalable platform that can expand to additional job categories and geographic markets
* Generate revenue through potential future monetization (premium listings, featured jobs, or subscription tiers)

### User Goals
**For Employers:**
* Find qualified workers quickly (ideally within hours, not days)
* Post job opportunities in under 2 minutes with minimal friction
* Review applicants and make hiring decisions efficiently
* Connect with reliable workers for both immediate and scheduled needs

**For Workers:**
* Discover legitimate job opportunities easily without relying on personal connections
* Apply to multiple jobs quickly from their mobile phone
* Understand job requirements clearly before applying
* Get timely responses and interview scheduling from employers

### Non-Goals
* Complex background verification or credential checking systems (initial version)
* In-app payment processing or escrow services
* Long-term employment or corporate hiring solutions
* Job categories requiring specialized certifications or advanced skills
* Multi-language support beyond Arabic (initial version)

## 3. User stories

**Persona 1: Ahmed (Small Restaurant Owner)**
* As a restaurant owner preparing for a busy weekend, I need to quickly hire 2 additional waiters so that I can handle the expected customer volume without compromising service quality
* As an employer with limited time, I need to see applicants' basic information and contact only qualified candidates so that I don't waste time on unsuitable matches
* As someone planning a special event, I need to schedule interviews in advance so that I can meet workers before committing to hire them

**Persona 2: Fatima (Worker Seeking Daily Jobs)**
* As a worker looking for flexible income, I need to browse available jobs near my location so that I can find opportunities that fit my schedule and skills
* As someone with basic phone skills, I need a simple application process so that I can apply without confusion or technical barriers
* As a job seeker, I need to know the salary and shift details upfront so that I can decide if the opportunity is worth pursuing
* As an applicant, I need timely notifications about my application status so that I can plan my schedule and pursue other opportunities if needed

**Persona 3: Sara (Event Organizer)**
* As an event planner working on multiple projects, I need to hire different types of workers (helpers, servers, drivers) from one platform so that I can manage all my staffing needs efficiently
* As someone hiring for a specific date, I need to post jobs with variable shift schedules so that workers understand the commitment required

## 4. Functional requirements

### Must-Have (P0) - Launch Essentials
* **User Registration & Authentication**
  * Phone number-based registration for both user types (employer/worker)
  * SMS verification for account activation
  * Simple profile setup with basic information
  * User type selection (employer vs. worker) during onboarding

* **Job Posting (Employer Side)**
  * Create job listing with: role title, number of workers needed, location, shift details (fixed or variable), salary or salary range, required skills/capabilities
  * Edit or delete posted jobs
  * View list of all posted jobs with status indicators

* **Job Discovery & Application (Worker Side)**
  * Browse available jobs with clear display of key details
  * Filter jobs by location, role type, or salary range
  * Apply to jobs with one-tap action
  * View application history and status

* **Application Management**
  * Notification system alerting employers of new applications
  * Employer dashboard showing all applicants per job
  * Accept/reject applicant functionality
  * Privacy protection: phone numbers only revealed after acceptance or interview scheduling

* **Interview Scheduling**
  * Employer can set interview date/time for accepted applicants
  * Option to mark worker as "hired immediately" (skip interview)
  * Notifications to workers about interview confirmations

* **Arabic Interface**
  * Full right-to-left (RTL) UI design
  * Clear, large fonts suitable for users with varying literacy levels
  * Simple iconography and visual cues to support text

### Should-Have (P1) - Near-Term Enhancements
* Location-based job recommendations for workers
* Job search functionality with keyword support
* Employer rating/review system for workers who complete jobs
* Worker rating/review system for employers
* Job expiration (automatic closure after time period)
* Save/bookmark jobs feature for workers
* Application withdrawal option for workers

### Nice-to-Have (P2) - Future Considerations
* In-app messaging between employers and workers
* Photo upload for job listings and worker profiles
* Skill verification or endorsements
* Job templates for repeat employers
* Push notification preferences and customization
* Analytics dashboard for employers (view counts, application rates)

## 5. User experience

### Employer Journey
* Download app → Select "I'm an employer" → Enter phone number → Verify SMS code → Complete basic profile (name, business type) → Land on employer dashboard
* Post a job: Tap "Post Job" button → Fill simple form (7-8 fields, all on one scrollable screen) → Review and publish → Receive confirmation
* Manage applications: Receive notification → Open "Applicants" tab → Review worker profiles → Tap "Schedule Interview" or "Hire Now" → Worker's phone number is revealed → Contact worker directly
* Close job: Mark position as filled → Job listing becomes inactive

### Worker Journey
* Download app → Select "I'm looking for work" → Enter phone number → Verify SMS code → Complete basic profile (name, skills, preferred job types) → Land on job feed
* Apply for job: Browse feed → Tap job card to view details → Read salary, location, requirements → Tap "Apply" → Receive confirmation
* Check status: Open "My Applications" → See pending/accepted/rejected status → If accepted, receive interview details and employer contact
* Attend interview/start work: Use revealed phone number to coordinate with employer

### Edge Cases & UI Notes
* **Empty states:** Show encouraging messages with clear calls-to-action (e.g., "No jobs in your area yet - check back soon!" with illustration)
* **No internet connection:** Display clear offline indicator and queue actions when possible
* **Application already submitted:** Prevent duplicate applications with visual indicator showing "Already Applied"
* **Expired jobs:** Automatically mark as closed after 7 days (configurable) or when employer fills all positions
* **Phone verification failures:** Provide "Resend code" option with 60-second cooldown; offer troubleshooting tips
* **Large applicant volumes:** Implement pagination; show count indicator (e.g., "24 applicants")
* **Accessibility:** Ensure minimum touch target sizes (44x44pt), high contrast ratios, and support for device text scaling
* **Form validation:** Real-time field validation with clear error messages in simple Arabic

## 6. Narrative

**Friday, 9:00 AM**

Ahmed opens his small café in the city center, already thinking about tomorrow's rush. His regular server just called in sick for the weekend. In the past, he would spend hours calling friends, posting in Facebook groups, and hoping someone reliable would respond. Not anymore.

He pulls out his phone, opens the app, and taps "Post Job." Within 90 seconds, he's filled in the details: "Waiter - 1 person - Weekend shifts (Sat-Sun, 10am-6pm) - 150 SAR per day - Experience with customer service preferred." He hits publish and gets back to preparing for the morning customers.

**Friday, 10:30 AM**

Across town, Fatima is finishing her morning routine when her phone buzzes. She opens the app and sees three new job postings near her neighborhood. One catches her eye immediately - a weekend waiter position at a café she's walked past before. The pay is fair, the location is perfect, and the schedule works with her weekday commitments. She taps "Apply" and goes about her day.

**Friday, 11:15 AM**

Ahmed's phone vibrates. "You have a new applicant for Waiter position." He opens the app during a quiet moment and sees Fatima's profile - she's worked as a server before and lives nearby. He taps "Schedule Interview," selects Saturday at 2 PM, and adds a note about meeting at the café. The app reveals her phone number, and he sends a quick message confirming the details.

**Friday, 11:20 AM**

Fatima receives the interview notification. Tomorrow at 2 PM - perfect timing. She confirms her attendance in the app and feels relieved that she found an opportunity so quickly, without asking for favors or scrolling through cluttered social media groups for hours.

**Saturday, 2:45 PM**

The interview went well. Ahmed is impressed with Fatima's experience and friendly demeanor. He taps "Hire" in the app and marks the position as filled. Fatima starts tomorrow morning, and Ahmed can finally focus on running his business instead of scrambling for help.

Both of them found what they needed - quickly, easily, and reliably. No endless phone calls, no unreliable connections, no wasted time. Just a simple solution to an everyday problem.

## 7. Success metrics

**Acquisition Metrics**
* Monthly active users (employers and workers, tracked separately)
* New user registration rate
* Install-to-registration conversion rate

**Engagement Metrics**
* Number of jobs posted per week/month
* Number of applications submitted per week/month
* Average applications per job posting
* User retention rate (30-day and 90-day)
* Average session duration and frequency

**Marketplace Health Metrics**
* Application-to-hire conversion rate (target: 30%+ within 6 months)
* Average time-to-fill per job (target: <24 hours)
* Percentage of jobs successfully filled
* Ratio of workers to employers (target: 5:1 to 10:1)

**Quality Metrics**
* Application acceptance rate (indicates quality of matches)
* Percentage of employers who post multiple jobs (indicates satisfaction)
* Percentage of workers who apply to multiple jobs (indicates platform utility)
* User-reported issues or support tickets per 1000 users

**Leading Indicators**
* Profile completion rates
* Search and filter usage rates
* Notification open rates and response times
* Job post abandonment rate

## 8. Milestones & sequencing

### Phase 1: MVP Launch (Weeks 1-8)
**Team: 2 developers, 1 designer, 1 PM**
* Weeks 1-2: Core architecture setup, user authentication, database design
* Weeks 3-4: Job posting and application workflows, basic UI implementation
* Weeks 5-6: Notification system, profile management, privacy controls
* Weeks 7-8: Arabic localization, RTL support, testing with target users, beta launch with 50 users

**Launch criteria:** Both user types can register, employers can post jobs, workers can apply, basic notifications work, Arabic interface is fully functional

### Phase 2: Early Traction (Weeks 9-16)
**Focus: Validate product-market fit and iterate based on feedback**
* Launch marketing campaign in target neighborhood/city
* Weekly user interviews (5-10 users per week)
* Implement critical feedback items and usability improvements
* Add location-based recommendations and basic search
* Build employer/worker rating system
* Target: 500 registered users, 100 jobs posted, 50 successful hires

### Phase 3: Growth & Refinement (Weeks 17-24)
**Focus: Scale what works and improve retention**
* Expand to 2-3 additional cities/neighborhoods
* Implement job templates and saved searches
* Add in-app messaging (if user feedback indicates strong need)
* Optimize notification strategy based on engagement data
* Introduce analytics dashboard for employers
* Target: 2,500 registered users, 500 jobs posted, 25% month-over-month growth

### Phase 4: Platform Maturity (Week 25+)
**Focus: Sustainable growth and advanced features**
* Expand job categories based on demand
* Consider monetization options (premium listings, featured posts)
* Build referral/invite system to drive organic growth
* Explore partnerships with business associations or training programs
* Scale infrastructure for regional expansion

**Keep it scrappy:** Start with manual moderation, simple admin tools, and direct user support via WhatsApp before building complex internal systems. Focus on proving the core marketplace dynamics work before adding sophisticated features. 