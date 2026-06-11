# Backend Setup

## Role
Act as the Backend Engineer. Read and follow:

* [backend-developer.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/personas/backend-developer.md) 
* [save-token.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/md-files/save-token.md) 

Adopt all standards, responsibilities, and token-saving instructions.

## Action
Execute all tasks under:

[execution-plan.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/md-files/execution-plan.md) → 1.3 Development Environment Setup → Backend Setup

Complete each step in sequence without skipping.

## Context

Project: Journal Hub

Backend must support:

* Authentication
* Journal entries
* Tags
* Search & filters
* Calendar view
* Sharing
* Analytics
* Export

Strictly Follow [backend-developer.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/personas/backend-developer.md)for Technical Standards and Responsibilities.

## Execute

For each completed step, provide:

* Task completed
* Files created/updated
* Validation performed
* Next step

Follow [save-token.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/md-files/save-token.md)  throughout the execution and continue until all Backend Setup tasks in Section 1.3 are complete.

----

# Database Setup

## Role
Act as the Backend Engineer. Read and follow:

* [backend-developer.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/personas/backend-developer.md) 
* [save-token.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/md-files/save-token.md) 

Adopt all standards, responsibilities, and token-saving instructions.

## Action
Execute all tasks under:

[execution-plan.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/md-files/execution-plan.md) → Phase 2: Database Design

Complete each step in sequence without skipping.

## Context

Project: Journal Hub

Backend must support:

* Authentication
* Journal entries
* Tags
* Search & filters
* Calendar view
* Sharing
* Analytics
* Export

Strictly Follow:
[backend-developer.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/personas/backend-developer.md)for Technical Standards and Responsibilities. 


## Execute

For each completed step, provide:

* Task completed
* Files created/updated
* Validation performed
* Next step

Follow [save-token.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/md-files/save-token.md)  throughout the execution and continue until all Backend Setup tasks in Section 1.3 are complete.

----

# Flutter Frontend Setup

## Role
Act as the Frontend Flutter Engineer. Read and follow:

*  [flutter-developer.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/personas/flutter-developer.md) 
* [save-token.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/md-files/save-token.md) 

Adopt all standards, responsibilities, and token-saving instructions.

## Action
Execute all tasks under:

[execution-plan.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/md-files/execution-plan.md) → 1.3 Development Environment Setup -> Frontend Setup

Complete each step in sequence without skipping.

## Context

Project: Journal Hub
Folder Path : outputs/frontend

Strictly Follow:
[flutter-developer.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/personas/flutter-developer.md) for Technical Standards and Responsibilities. 


## Execute

For each completed step, provide:

* Task completed
* Files created/updated
* Validation performed
* Next step

Follow [save-token.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/md-files/save-token.md)  throughout the execution and continue until all Frontend Setup task completed.


----

# Flutter UI Implementation with Mock Data

## Role
Act as a Senior Flutter Developer.

Read and follow:

* [flutter-developer.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/personas/flutter-developer.md) 
* [save-token.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/journal-hub/agent-prompts/md-files/save-token.md) 

Adopt all coding standards, architecture guidelines, and token-saving practices.

## Action

Implement the Stitch-generated UI screens into the Flutter project.

For this phase:

1. Build all UI screens and navigation flows.
2. Create reusable widgets and layouts.
3. Connect screens using mock repositories/services only.
4. Populate screens with realistic mock data.
5. Simulate loading, success, empty, and error states.
6. Do NOT implement real API integration.
7. Do NOT implement backend business logic.
8. Focus on validating the complete user workflow.

## Context

The goal is to verify the end-to-end user experience before backend integration.

Use mock data for:

* Authentication
* User profile
* Journal entries
* Tags
* Search results
* Calendar data
* Analytics dashboard
* Shared entries

The application should feel fully functional from a user's perspective.

@mcp:StitchMCP:get_project:1171524168852387012

Screen ID: Digital Journal System

## Execute

For each screen:

* Implement UI from Stitch design.
* Create mock models and repositories if needed.
* Connect navigation and user flows.
* Verify screen responsiveness.
* Test happy path and edge states.

After each completed screen provide:

* Files created/updated
* Mock data added
* Navigation connected
* UI validation performed
* Next screen to implement

Goal: Complete a clickable, testable MVP UI with mock data so the entire journal workflow can be tested before API integration.

---


# Flutter Email Verification Bypass in SignUp Flow

## Role
Act as a Senior Flutter Developer.

## Action
Remove email verification functionality in SignUp Flow

## Context
Currently, the QA team is blocked from testing the complete user workflow because the backend email verification mechanism is not yet implemented. To unblock testing, we need to bypass this step.

Execute:
Provide the updated Flutter code for the modified navigation/authentication flow and the mock data setup, ensuring it is ready for QA to compile and test immediately.

Goal: Modify the authentication flow to remove the email verification blocking step and deliver a fully clickable, testable end-to-end MVP UI with mock data.

---

# Fixing Flutter UI Implementation

## Role
Act as a Senior Flutter Developer.

## Action
Debug the route cause and fix the Settings flow.

## Context
QA team found the issue while testing the settings flow, Settings functionality is not working as expected.

Execute:
Provide the updated Flutter code for the modified navigation/settings flow and the mock data setup, ensuring it is ready for QA to compile and test immediately.

Goal: Modify the settings flow deliver a fully clickable, testable end-to-end MVP UI with mock data.

---