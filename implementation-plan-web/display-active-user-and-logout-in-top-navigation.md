# PRD: Display Active User and Logout in Top Navigation

> **Portfolio sanitization notice:** Application names, internal routes, roles, menu labels, and implementation identifiers are generalized. No credentials, production URLs, or personal data are included.

## Problem

After the application moved from side navigation to a top-navigation layout, authenticated users could not clearly identify the active account or easily find the Logout action.

The existing user-menu control preferred an optional display-name field, while authentication relied on a required username field. When the display name was empty, the menu trigger could appear without a useful label and make logout difficult to discover.

## Goal

- Show the authenticated user's username on the right side of the top navigation.
- Provide Logout through an accessible user menu.
- Preserve the existing authentication and session-termination flow.
- Keep the user menu usable on desktop and mobile layouts.

## Target Users

- Authenticated operational users
- Administrators
- Reporting users

## Functional Requirements

- The top navigation displays the authenticated user's username.
- The username acts as the trigger for the user menu.
- The user menu contains a Logout action.
- Logout submits a `POST` request through the existing logout route.
- The logout request includes CSRF protection.
- Successful logout ends the authenticated session and follows the application's existing post-logout redirect.
- The user menu and Logout action appear only for authenticated users.
- The menu remains operable through the responsive navigation on desktop and mobile.
- The change does not modify roles, permissions, or menu authorization.

## Technical Rules

- Reuse the existing navigation partial and authentication route.
- Use the authenticated account's required username field as the primary visible identity.
- Do not create a second logout workflow.
- Preserve the existing `POST`, CSRF, and session-invalidation mechanisms.
- Preserve the current top-navigation configuration and application menus.
- Do not display email addresses, passwords, tokens, or other sensitive account data.
- Use unique form and element identifiers when the navigation is rendered.

## Acceptance Criteria

- An authenticated user sees their username on the right side of the top navigation.
- Selecting the username opens the user menu.
- The user menu displays a Logout action.
- Selecting Logout ends the session through the existing logout route.
- An unauthenticated user cannot see the authenticated user menu.
- Logout remains operable on supported desktop and mobile layouts.
- A user with an empty optional display name still sees their username.
- Existing application menus continue to navigate correctly.
- Existing role and permission behavior remains unchanged.

## Out of Scope

- User profile pages
- Username, password, or email changes
- Profile photographs or avatars
- Authentication-route or login-flow changes
- Role or permission changes
- User-database schema changes
- Full navigation redesign
