# FocusFlow - Study App Plan (Android, Flutter)

## 1. Executive Summary

FocusFlow is a local-only Android study app that enforces focus sessions by blocking access to all apps except a user-selected whitelist via Android AccessibilityService. Users set a timer, complete a focused session (non-pausable, non-resumable), answer post-session questions, and onboard with habit data. After accumulating at least 10 hours of recorded study sessions, the app surfaces the user's best study time (by average productivity score) and optimal session length (derived from productivity vs duration) in a simple dashboard. All data remains on-device.

## 2. Goals

- Enforce distraction-free study: block non-whitelisted apps during an active focus session using AccessibilityService; show a "blocked" overlay when blocked apps are launched.
- Allow users to enter a custom timer (non-pausable, non-resumable). Track session start/end, duration, ended-early flag, and bypass attempts.
- Collect onboarding data (wake time, sleep time, work schedule, caffeine consumption/timing, chronotype/energy patterns, typical study days).
- Collect post-session feedback with specific rating-scale questions.
- Require a minimum of 10 hours of total recorded study sessions before computing recommendations.
- Recommend "best study time" by average productivity score (granular by time of day/day of week). Recommend "optimal session length" based on historical productivity vs duration.
- Present recommendations in a simple dashboard (no specific chart type mandated).
- Local-only; no reminders.

## 3. Non-Goals (MVP)

- iOS support.
- Pause/resume sessions.
- Reminders/notifications for optimal times.
- Cloud sync/accounts/export/import.
- Gamification, social features, break timers (Pomodoro) unless needed later.
- Machine learning beyond simple aggregates.

## 4. User Flows

### Onboarding
1. Welcome + explanation of permissions and purpose.
2. Profile: wake time, sleep time, work start/end (optional), drinks caffeine (Y/N), caffeine timing (morning/afternoon/evening/other + time if applicable), chronotype/typical energy by time of day, typical week schedule (days studied).
3. Whitelist: select "important" apps from all installed apps (searchable). Anything not selected is blocked during sessions.
4. Permissions: guide to enable AccessibilityService, overlay (SYSTEM_ALERT_WINDOW), FOREGROUND_SERVICE, and handle Android 8+ permission nuances. Explain each before redirecting to Settings.
5. Review + confirm; persist onboarding complete.

### Focus Session
1. Home: start session -> enter duration (minutes/seconds or presets; custom allowed). Display estimated end time.
2. Active session screen: large countdown, session status, "End session early" button (available anytime). Session cannot be paused/resumed.
3. Blocker active: foreground service runs with persistent notification (to keep alive). On app launch/foreground change, if package not in whitelist -> show full-screen/overlay "App blocked" screen; do not allow proceeding to blocked app. Track bypass/attempts (see 5).
4. Session ends when timer completes OR user taps "End early" -> transition to post-session survey. Session is immutable once ended.

### Post-Session Survey
1. Show session summary (duration, start/end, ended early, attempts during session).
2. Required questions (rating scales where specified):
- Q1: How productive were you? (1-10, 1=not at all productive, 10=extremely productive)
- Q2: How focused were you? (1-10)
- Q3: How mentally tired were you before/during? (1-10, 1=very fresh, 10=very tired)
- Q4: How physically energized were you? (1-10, 1=very low energy, 10=very high energy)
- Q5: Were you distracted by external/internal factors? (1-10, 1=not distracted at all, 10=extremely distracted)
- Q6: Did you use any of your whitelisted "important" apps during this session? (Yes/No). If Yes, which (multi-select from whitelist) — optional details.
- Q7: Rate your overall satisfaction with this session (1-10)
- Q8: Optional notes (free text, short)
3. Save feedback linked to session (sessionId FK).

### Dashboard
1. Stats summary: total study time (sum of durations), sessions count, total attempts across all sessions.
2. "Best Study Time": computed only if total recorded study time >= 10 hours. Show the time block(s) (by day of week + hour range or time block buckets) with highest average productivity score. Include: block label (e.g., "Tue 09:00-11:00"), avg productivity (1-10), number of sessions in that block, total minutes in block.
3. "Optimal Session Length": computed only if total recorded study time >= 10 hours. Show recommended duration range (e.g., "20-25 min") based on peak average productivity vs duration buckets, with confidence note (sessions count in recommended bucket, avg productivity).
4. "Data sufficiency": if < 10 hours, display "Need X more hours of study sessions to generate recommendations (currently Y hours recorded)." Also show progress toward 10h.

### Settings
1. Manage whitelist (add/remove apps, search).
2. Edit onboarding data (profile fields).
3. View session history (list with duration, date/time, ended early, attempts, productivity score).
4. View attempts log per session (optional detail).
5. About/permissions status (AccessibilityService enabled, overlay granted).

## 5. Technical Architecture

### Stack
- Flutter 3.x (Dart), min SDK targeting Android 8+ (API 26+).
- State: Riverpod (recommended for timer, blocker state, DB streams).
- Navigation: go_router.
- Local DB: Drift (SQLite) — type-safe, good for time-series aggregates and FKs. Or Isar; Drift fits relational model well.
- Forms: flutter_form_builder + validators.
- Utils: intl (time/day formatting), uuid, equatable/freezed for models.

### Key Packages
- device_apps / installed_apps: enumerate installed apps (with icons/package names). Ensure QUERY_ALL_PACKAGES usage handled per Android 11+.
- android_intent_plus: deep-link to Settings (Accessibility, Usage/overlay, app settings).
- flutter_local_notifications: only for the foreground service notification while session active (required to keep service alive). No scheduled reminders.
- shared_preferences: lightweight flags (onboarding complete, permissions guidance seen, etc.)
- flutter/services (PlatformChannel): to communicate with Android AccessibilityService and ForegroundService.

### Android Native Components
- AccessibilityService (class extending AccessibilityService): 
  - Detect foreground app changes via `onAccessibilityEvent` (TYPE_WINDOW_STATE_CHANGED/TYPE_WINDOWS_CHANGED as appropriate)
  - Check active package against whitelist + allowlist of system apps if needed (launcher, system UI, accessibility settings flows?) — never block launcher/home; allow system components that are required to return to app/home.
  - When non-whitelisted foreground app detected and session active -> start/ensure overlay activity/view is shown and optionally bring focus back or prevent access. Overlay is shown on top of blocked app.
- ForegroundService: started when session begins; bound to session state; stops when session ends. Posts ongoing notification (required). Runs in foreground to reduce kill likelihood.
- Overlay UI (Activity/WindowManager overlay): "App blocked" screen with message, session timer remaining (optional), "End session" or "Return home" actions. Cannot be dismissed while blocking is active for that app.
- BroadcastReceiver or in-process state: session active flag (timestamp, endTime, whitelist set) shared between service/overlay/UI. Since local-only and single-process, state in DB + in-memory (Riverpod) synced.

### Permissions (Android)
- `FOREGROUND_SERVICE` (API 26+)
- `POST_NOTIFICATIONS` (API 33+; service needs notification)
- `SYSTEM_ALERT_WINDOW` (overlay) — special permission
- AccessibilityService — special permission (user enables in Settings > Accessibility)
- `QUERY_ALL_PACKAGES` — declare in AndroidManifest.xml (to list all installed apps). Justify in store metadata if distributed.
- (No PACKAGE_USAGE_STATS required if using AccessibilityService for foreground detection; AccessibilityService is chosen per requirements.)

Manifest notes: declare service with `android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"`, intent filter, config XML for accessibility service (meta-data). Declare overlay permission and foreground service type if needed.

### State Management
- SessionController (Riverpod): timer tick, start/end session, endedEarly, attempts counter, session lifecycle (idle/active/ended). Non-pausable/resumable.
- BlockerController: active sessionId, endTime, whitelist (Set<String> packageNames), blocked package tracking, attempts count increments on block events.
- ProfileController/Onboarding: form state + persistence.
- DB providers: Drift database singleton, DAOs/repositories.

## 6. Data Model (Drift schema)

All models persisted locally in SQLite.

### user_profile
- id (TEXT/UUID PK)
- wake_time (TEXT HH:mm)
- sleep_time (TEXT HH:mm)
- work_start_time (TEXT HH:mm nullable)
- work_end_time (TEXT HH:mm nullable)
- drinks_caffeine (INTEGER 0/1)
- caffeine_timing (TEXT nullable: morning/afternoon/evening/other)
- caffeine_time (TEXT HH:mm nullable)
- chronotype (TEXT nullable)
- energy_by_time_json (TEXT nullable) or structured
- study_days (TEXT JSON array of 0-6)
- onboarding_completed_at (INTEGER millis)

### app_whitelist
- package_name (TEXT PK)
- app_name (TEXT)
- icon_path (TEXT nullable) or store icon bytes? avoid large blobs if not needed; can cache icon file path

### study_session
- id (TEXT/UUID PK)
- start_time (INTEGER millis)
- end_time (INTEGER millis)
- duration_minutes (REAL or INTEGER seconds? store precise; compute minutes)
- ended_early (INTEGER 0/1)
- day_of_week (INTEGER 0-6, derived from start_time)
- hour_of_day (INTEGER 0-23)
- time_block (TEXT: morning/afternoon/evening/late_night) derived at insert
- attempts_count (INTEGER default 0)
- created_at (INTEGER millis)

### session_feedback
- id (TEXT/UUID PK)
- session_id (TEXT FK -> study_session.id ON DELETE CASCADE)
- q_productivity (INTEGER 1-10)
- q_focus (INTEGER 1-10)
- q_mental_tired (INTEGER 1-10)  (1=fresh, 10=tired)
- q_physical_energy (INTEGER 1-10) (1=low, 10=high)
- q_distracted (INTEGER 1-10) (1=not distracted, 10=extremely)
- q_used_whitelisted (INTEGER 0/1)
- q_used_apps_json (TEXT nullable) list of package names
- q_satisfaction (INTEGER 1-10)
- notes (TEXT nullable)
- submitted_at (INTEGER millis)

### block_attempt
- id (TEXT/UUID PK)
- session_id (TEXT FK -> study_session.id)
- blocked_package (TEXT)
- attempt_time (INTEGER millis)
- reason (TEXT nullable)

Derivations: time_block = morning 06:00-11:59, afternoon 12:00-17:59, evening 18:00-23:59, late_night 00:00-05:59 (configurable later). day_of_week/hour_of_day from start_time.

## 7. Recommendation Algorithm

Require total recorded study time >= 10 hours before showing recommendations. Compute from sessions that have feedback (productivity scores present). Only count completed sessions with duration>0.

### Best Study Time (by average productivity score)
Compute per bucket: (dayOfWeek, timeBlock) or finer (dayOfWeek, hour range). Use timeBlock buckets for simplicity (matches typical schedule) — also can consider hourOfDay if data sparse. 
Metrics per bucket b:
- sessions_b = count of sessions with start_time in bucket and feedback.q_productivity set
- total_minutes_b = sum(duration_minutes)
- avg_prod_b = mean(q_productivity) over sessions_b
- total_hours = sum(duration_minutes)/60 over all sessions with feedback

Only consider buckets with sessions_b >= 2 (minimum confidence) unless total sessions very small but >=10h? Prefer >=3 sessions. If a single bucket dominates, still show it with counts.

Score: avg_prod_b (primary). Also show supporting stats (sessions_b, total_minutes_b). Return top bucket(s) sorted by avg_prod_b desc, tie-breaker by sessions_b desc. Dashboard shows the best bucket and its details.

Example:
```dart
group sessions by (dow, timeBlock) where hasFeedback
filter buckets with count>=2
sort by avgProductivity desc, sessionCount desc
return top1 (or top3) as "best study time"
```

### Optimal Session Length
Bucket durations into ranges: <15, 15-19, 20-24, 25-29, 30-39, 40-49, 50-59, >=60 minutes (or adjust based on observed data). For each range r:
- sessions_r, avg_prod_r = mean(q_productivity), avg_mental_tired_r, avg_satisfaction_r
Find range with highest avg_prod_r. Apply constraints:
- require sessions_r >= 3 for recommendation
- if tied, prefer range with higher sessions_r or lower avg_mental_tired_r
- penalize very long ranges if avg_mental_tired_r high relative to others
Return recommended range label and stats. Also show distribution (optional) but not mandated.

If no range meets confidence, show "insufficient distribution of session lengths to determine optimal length" but still may show best time if time criterion met.

## 8. App Blocking Details (AccessibilityService)

### Detection
- Use AccessibilityService to monitor foreground window state changes. Listen for `AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED` and `AccessibilityEvent.TYPE_WINDOWS_CHANGED` as appropriate (Android varies). Extract package name via `event.packageName` or active window.
- Maintain `activeSession` state (sessionId, endTime, whitelist Set<String>).
- Allowlist: always allow the current app’s own package, home/launcher packages (resolve launcher intent), accessibility settings, and Android system UI packages that are necessary to navigate. Also allow overlay activity package.
- Whitelist check: `isBlocked = sessionActive && !whitelist.contains(package) && !isSystemAllowed(package)`

### Blocking Action
When blocked: launch/show the BlockedOverlayActivity (or add overlay view via WindowManager with TYPE_APPLICATION_OVERLAY) immediately. 
- BlockedOverlayActivity is a full-screen transparent/ themed activity that shows "This app is blocked during your focus session" with remaining time, session info, and actions (End session, Go to Home).
- Bring the overlay to front; prevent interaction with underlying app. 
- Increment attempts counter: `attempts_count++` on study_session and insert `block_attempt` record (timestamp, blocked_package). Track attempts per session (requirement 5).

### Edge Cases
- Session ends while overlay shown -> dismiss overlay, stop service.
- User presses Home/Recents: detection will fire; if returning to non-whitelisted, show overlay.
- Launcher detected -> do not block.
- Multiple rapid launches -> debounce (e.g., 300-500ms) to avoid spam increments.
- AccessibilityService disabled mid-session: detect via `isEnabled()` checks; show warning state on UI, but blocking cannot function — log state; user must re-enable.

### Lifecycle
- Start ForegroundService + set `activeSession = true` at session start (with endTime = startTime + duration).
- Timer drives endTime; when reached -> stop session: set activeSession=false, stop service, dismiss overlays.
- "End session early" same as timer end.

## 9. Implementation Phases

### Phase 0: Scaffold (0.5-1 day)
- [ ] Create Flutter project (flutter create focusflow)
- [ ] Add dependencies (riverpod, drift, go_router, flutter_local_notifications, device_apps/installed_apps, android_intent_plus, intl, uuid, freezed/json_serializable)
- [ ] Setup Riverpod, routing, theme (minimal)
- [ ] Android: update minSdk to 26 (Android 8+), add permissions to AndroidManifest

### Phase 1: Data Model & DB (1 day)
- [ ] Define Drift tables per schema
- [ ] DAOs/repositories for sessions, feedback, whitelist, profile
- [ ] Type converters for JSON (study_days, used_apps)
- [ ] Migrations not needed for MVP (fresh schema)
- [ ] Seed helpers

### Phase 2: Onboarding (1-2 days)
- [ ] Screens: Welcome, Profile (time pickers, toggles, checkboxes for days), Whitelist (app list with search, icons, multi-select), Permissions (explanation + Settings links)
- [ ] Form validation
- [ ] Persist profile, whitelist
- [ ] Mark onboarding complete
- [ ] Permission state detection (AccessibilityService enabled, overlay granted)

### Phase 3: Timer & Session UI (1 day)
- [ ] Home screen: duration input (number picker or text), start button
- [ ] Session screen: countdown, end-early button, status
- [ ] SessionController with non-pausable timer (Ticker/Timer.periodic)
- [ ] Prevent back navigation during active session? (use WillPopScope)
- [ ] Transition to survey on end

### Phase 4: App Blocker (2-3 days) — highest complexity
- [ ] Android: AccessibilityService implementation
- [ ] ForegroundService for active session
- [ ] BlockedOverlayActivity + WindowManager overlay
- [ ] Platform channels (Flutter <-> native) for session state, whitelist sync
- [ ] Whitelist sync from Flutter DB to native (SharedPreferences or method calls)
- [ ] Attempts tracking on block events
- [ ] System-allowed package detection (launcher, system UI, own package)
- [ ] Debouncing of rapid events
- [ ] Edge case handling

### Phase 5: Post-Session Survey (0.5-1 day)
- [ ] Survey form with all 8 questions (rating scales 1-10, Y/N, multi-select for used apps, notes)
- [ ] Validation (required fields as specified)
- [ ] Link to session, save to session_feedback
- [ ] Compute derived fields if needed

### Phase 6: Dashboard & Recommendations (1-1.5 days)
- [ ] Aggregates: total hours, sessions count, total attempts
- [ ] Best study time calculation (by avg productivity, >=10h, confidence filter)
- [ ] Optimal session length (bucketed, confidence filter)
- [ ] Simple UI (text blocks, no mandated chart)
- [ ] "Insufficient data" states with progress (X/10h)
- [ ] Session history list

### Phase 7: Polish, QA, Hardening (0.5-1 day)
- [ ] Permission edge cases (service disabled, overlay denied)
- [ ] Foreground service notification content
- [ ] Prevent session start without required permissions? warn but allow? better: gate start with checks
- [ ] Test on Android 8+ devices/emulator where possible (blocking behavior needs device)
- [ ] Lint, format, basic unit tests for algorithm

**Total estimate: 8-10 days for MVP.**

## 10. Testing Strategy

- Unit tests: recommendation logic (best time, optimal length), time block derivation, session state, attempts counting.
- Widget tests: onboarding forms, timer, survey, dashboard states.
- Integration tests: session lifecycle (start->end->survey).
- Device tests (critical): AccessibilityService, overlay blocking, foreground service persistence, attempts tracking across launches. Test with real apps.
- Edge cases: end session while blocked app shown, service killed/restarted? (foreground service reduces risk), AccessibilityService toggled off, overlay permission revoked.

## 11. Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| AccessibilityService disabled mid-session | High | Detect state; log; UI shows warning; blocking stops until re-enabled. Document in UI. |
| Overlay permission denied | High | Gate session start: check `Settings.canDrawOverlays()`; redirect to Settings if missing. |
| Foreground service killed by OEM/battery | High | Use foreground service with notification; consider `startForegroundService` + notification. Test on target OEMs if possible. |
| User can return via Recents/Home | Medium | Detection on foreground change covers it; always allow launcher/home. |
| False positives on system UI | Medium | Maintain allowed packages list (launcher, system, own app, overlay). |
| Insufficient data (<10h) | Medium | Clear progress UI; do not compute/stale results. |
| Performance with large app list | Medium | Lazy load, search, cache icons. |
| Android 8+ API differences | Medium | Test min/max; handle notification channels (API 26+). |

## 12. Implementation Notes

- Keep blocking logic native (Kotlin/Java) minimal and testable; communicate state via PlatformChannel.
- Whitelist is the source of truth in Flutter DB; sync to native on changes and at session start.
- Attempts: increment on every time we detect a non-whitelisted package entering foreground while session active (debounced).
- Session is non-pausable/resumable: timer is a simple countdown to endTime; no pause actions/state.
- Local-only: no network dependencies, no analytics, no cloud storage.
- No reminders: do not schedule any alarms/notifications except the ongoing session foreground notification.

## 13. Acceptance Criteria (MVP)

- Onboarding captures all specified fields and whitelist; permissions guided.
- Can start session with custom timer; timer counts down; cannot pause/resume; "End early" works.
- During active session, non-whitelisted apps are blocked with overlay; launcher/home allowed.
- Attempts tracked per session and persisted (block_attempts + attempts_count).
- Session ends -> survey with all questions completed -> saved linked to session.
- Dashboard shows <10h message until total >=10h; then shows best time (by avg productivity) and optimal length with confidence counts.
- All data stored locally (Drift); no cloud calls.
- Runs on Android 8+ with AccessibilityService approach.

---

*This is the build plan for FocusFlow (Android, Flutter).*
