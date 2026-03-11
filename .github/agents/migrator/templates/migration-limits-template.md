---
description: Defines items that must never be touched during migration without explicit developer approval. Copy to `.github/migration/[app]-migration-limits.md` and fill it in before Phase 2 begins.
---

# Migration Limits — [APP]

> **How this file works**
>
> The Migrator agent checks every planned increment against the lists below.
> If a planned change would touch any protected item, the agent **stops** and presents an
> approval request. You must type **YES** (case-insensitive) to approve. Silence, "ok",
> "proceed", or similar responses are not accepted.
>
> Once you approve an override, the agent records it in the [Override History](#override-history)
> section at the bottom of this file.

---

## Protected Files & Directories

Paths are matched against files the agent plans to modify. Use glob patterns where needed.

| Path / Pattern | Reason |
|---|---|
| `src/auth/**` | Authentication flows — security-critical, must be reviewed by the security team before any change |
| `src/db/migrations/**` | Database migration scripts — irreversible changes that must be reviewed by a DBA |
| `config/production.yml` | Production configuration — any change risks an outage |
| `src/security/**` | Security utilities and policies |
| *(add your own rows)* | *(explain why this path must not be touched without approval)* |

---

## Protected Concerns (Cross-Cutting)

These are concerns rather than specific file paths. The agent will flag any planned change that
touches these areas, even if the files are not listed above.

| Concern | Scope description | Reason |
|---|---|---|
| **Authentication & sessions** | Login flows, session management, token creation/validation, OAuth handlers | Security-critical — a regression could expose user accounts |
| **Authority & permission checks** | Role checks, permission guards, `@PreAuthorize`/`@Secured` annotations, ACL rules, middleware guards | A silent regression here grants unauthorised access — must be verified by a human after any change |
| **Database schema** | ORM models, migration scripts, schema definition files | Irreversible at the DB level — requires DBA sign-off |
| **Public API contracts** | REST/GraphQL endpoint signatures, request/response shapes, versioning | Breaking changes affect consumers outside this repo |
| **Secrets & credentials** | Files that read, write, or reference API keys, passwords, certificates | Security policy — accidental exposure risk |
| **Billing & payments** | Payment processing, subscription logic, invoicing | Financial impact and compliance requirements |
| *(add your own rows)* | *(describe the scope)* | *(explain why)* |

---

## Override Rules

- The agent must present a named, explicit approval request for **each** protected item separately.
- Blanket approvals ("approve all of them") are **not accepted** — each item must be individually confirmed.
- Approvals are scoped to the **specific increment** in which they are granted. A new increment touching the same item requires a new approval.
- If you want to permanently remove a limit, delete or comment out its row in this file.

---

## Override History

> The agent appends a row here every time a protected item is touched with your approval.
> Do not edit this section manually.

| Date | Increment | Protected Item | Reason override was granted |
|---|---|---|---|
| *(filled by agent)* | | | |
