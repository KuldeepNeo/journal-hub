# QA Fixes Summary - Journal Hub

---

## Module 2: Authentication & Session Management

### Overview
We have resolved all 6 findings reported in the QA defect report for Module 2. The fixes have been verified by updating and running the automated test suites on both the backend and frontend.

### Summary Metrics
- **Total Issues Received**: 6
- **Issues Fixed**: 6
- **Remaining Issues**: 0
- **Ready for QA Retest**: Yes

### Findings & Resolution Details

#### DEF-004: Frontend fails to redirect user to login on token expiration (KPI-013)
- **Root Cause**: The API Client (`api_client.dart`) did not handle HTTP 401 Unauthorized responses. If a session expired or was invalidated by the backend, requests failed but the user remained stuck on the dashboard.
- **Fix**: Updated `api_client.dart`'s `onError` block to detect HTTP 401 errors, clear tokens from `SharedPreferences`, and invoke a static callback `onUnauthorizedGlobal`. In `providers.dart`, this callback clears the `AuthNotifier` state and triggers `goRouter.go('/login')` to redirect the user to login.
- **Verification**: Ran `flutter test`. All widget and provider tests continue to compile and pass successfully.

#### DEF-005: Frontend token decoder does not validate expiration claim (KPI-013)
- **Root Cause**: The JWT decoder `_decodeUserFromToken` in `auth_repository.dart` decoded the user object from local storage without verifying the `exp` claim, causing the app to navigate to the dashboard with an expired token instead of showing the login screen.
- **Fix**: Added verification of the `exp` payload claim in `_decodeUserFromToken`. If the token is expired, it throws a `TOKEN_EXPIRED` exception. `getCurrentUser()` catches this exception, cleans local `SharedPreferences`, and returns `null` so the app starts on the login page.
- **Verification**: Verified using unit checks and widget test assertions.

#### DEF-006 & DEF-007: Journal draft auto-save simulation & missing endpoints (KPI-014)
- **Root Cause**: The frontend draft auto-save was a UI simulation that did not write to any storage. The backend schema had a `Draft` table, but no endpoints or controller actions existed for draft management.
- **Fix**:
  - **Backend**: Implemented `draftRepository.js`, `draftService.js`, `draftController.js`, and `draftRoutes.js` to support `POST /api/v1/drafts` and `GET /api/v1/drafts/:draftId` protected by `authMiddleware`.
  - **Frontend**: Created `draft_repository.dart` providing `saveDraftLocal` (cached in SharedPreferences for offline recovery), `saveDraftRemote` (POST `/drafts` API), and retrieval/cleanup functions. Integrated these in `editor_screen.dart` with a prompt on editor load to recover unsaved drafts.
- **Verification**: Created `tests/draft.test.js` to verify backend CRUD operations, user ownership rules, and validations. All 43 backend integration tests pass.

#### DEF-008: Frontend password reset flow is hardcoded to "123456" and blocks integration (KPI-015 / KPI-016)
- **Root Cause**: The client-side `ForgotPasswordScreen` aborted password reset requests if the code entered by the user was not `'123456'`, blocking the use of the real backend-generated random codes.
- **Fix**: Removed the client-side `'123456'` code check from `_handleResetPassword` and allowed the real code to be passed directly to the repository and reset API.
- **Verification**: Verified compilation and ran smoke widget tests.

#### DEF-009: Mobile users are unable to logout (Usability / Session Management)
- **Root Cause**: The logout button was only present in the desktop sidebar layout. The mobile layout bottom navigation bar and settings page lacked a logout option.
- **Fix**: Added an "Account" section containing a "Logout" list tile in the `SettingsScreen` (which is accessible on mobile from the dashboard app bar).
- **Verification**: Verified mobile layout navigation and logout button rendering in the settings screen.

---

## Module 1: User Registration & Verification

### Overview
Resolved all 3 findings reported in the QA defect report for Module 1.

### Summary Metrics
- **Total Issues Received**: 3
- **Issues Fixed**: 3
- **Remaining Issues**: 0
- **Ready for QA Retest**: Yes

### Findings & Resolution Details

#### DEF-001: Email verification link uses GET request which is not supported by the backend
- **Root Cause**: The backend registration email verification link used a `GET` request, but the Express router only registered a `POST` handler.
- **Fix**: Added a `GET /api/v1/auth/verify-email` endpoint that validates the token and serves a success/failure HTML page.
- **Verification**: Added integration tests in `auth.test.js`.

#### DEF-002: Email duplicate check and database unique constraint are case-sensitive
- **Root Cause**: SQLite `User.email` comparison was case-sensitive.
- **Fix**: Added `.lowercase()` validation in Joi schema and converted email inputs to lowercase in the repository layer.
- **Verification**: Added case-sensitivity test in `auth.test.js`.

#### DEF-003: Empty verification token input is ignored without feedback
- **Root Cause**: The verification dialog dismissed empty inputs without visual warning.
- **Fix**: Added empty-string validation and a SnackBar error alert in `auth_screens.dart`.
- **Verification**: Verified via widget testing.
