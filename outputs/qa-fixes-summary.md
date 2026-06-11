# QA Fixes Summary - User Registration & Verification

## Overview

We have resolved all 3 findings reported in the QA defect report. The fixes have been verified by updating and running the automated test suites on both the backend and frontend.

### Summary Metrics

- **Total Issues Received**: 3
- **Issues Fixed**: 3
- **Remaining Issues**: 0
- **Ready for QA Retest**: Yes

---

## Findings & Resolution Details

### DEF-001: Email verification link uses GET request which is not supported by the backend
- **Root Cause**: The backend registration flow sent verification emails containing a `GET` URL link (`/verify-email?token=...`), but the Express router only registered a `POST` handler for the route. Clicking the email link resulted in an HTTP 404 error.
- **Fix**: Added a new `GET /api/v1/auth/verify-email` endpoint in the backend router that reads the token from the query parameters, verifies it using the verification service, and serves a user-friendly, styled HTML page indicating success or failure.
- **Verification**: Added 3 new integration tests to `auth.test.js` validating:
  - Successful GET verification returning HTML.
  - Failure when token query parameter is missing.
  - Failure when token is invalid.
  All tests pass successfully.

### DEF-002: Email duplicate check and database unique constraint are case-sensitive
- **Root Cause**: The SQLite schema does not declare `COLLATE NOCASE` on the `email` column of the `User` table, and the queries/validation schemas were not normalizing email addresses, allowing different casings of the same email address to register distinct accounts.
- **Fix**: 
  - Updated the Joi registration validation schema in `authValidation.js` to include `.lowercase()`, automatically converting input email addresses to lowercase before processing.
  - Normalised emails to lowercase inside `createUser` and `findByEmail` in `userRepository.js` as an additional layer of data safety.
- **Verification**: Added a new integration test `should fail with 409 DUPLICATE_EMAIL if email is already registered with different casing` in `auth.test.js`. The test successfully passes.

### DEF-003: Empty verification token input is ignored without feedback
- **Root Cause**: The frontend email verification dialog dismissed empty inputs without providing feedback, resulting in a silent failure when the user clicked "Verify" without entering anything.
- **Fix**: Updated the verification dialog logic in `auth_screens.dart` to check if the entered token is empty and show an orange warning SnackBar asking the user to enter a token.
- **Verification**: Tested compilation and ran `flutter test` widget tests. All tests pass successfully.

---

## Risks & Dependencies
- **Downstream Auth Modules**: Retained all mock implementations for login, password resets, and sessions, ensuring that later modules compile without issues. No regressions or architectural changes were introduced.
