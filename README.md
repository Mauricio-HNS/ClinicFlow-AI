# ClinicFlow AI

AI-powered multi-tenant SaaS for clinics, designed to look strong on GitHub, in portfolio reviews and in technical interviews.

## Screenshots

### Admin Dashboard

![ClinicFlow AI dashboard](docs/screenshots/clinicflow-dashboard.png)

### Mobile View

![ClinicFlow AI mobile view](docs/screenshots/clinicflow-mobile.png)

## Product Vision

ClinicFlow AI combines:

- smart scheduling and slot conflict control
- patient CRM
- AI-assisted patient summaries
- WhatsApp-ready confirmation message generation
- financial and operational dashboarding
- multi-tenant SaaS foundations

The project is being rebuilt inside this repository with a cleaner architecture and a stronger SaaS narrative. The older marketplace code remains in the repo for now, but the new foundation lives in the `ClinicFlow` modules below.

## Current Foundation

### Backend

New backend foundation in [backend/src/ClinicFlow.Api](/Users/mauriciohenrique/Documents/New%20project/backend/src/ClinicFlow.Api) with:

- modular monolith structure
- tenant-aware domain model
- demo seed for one clinic tenant
- appointment conflict detection
- dashboard summary endpoint
- AI phase 1 endpoints for patient summary and confirmation message generation

Supporting layers:

- [backend/src/ClinicFlow.Domain](/Users/mauriciohenrique/Documents/New%20project/backend/src/ClinicFlow.Domain)
- [backend/src/ClinicFlow.Application](/Users/mauriciohenrique/Documents/New%20project/backend/src/ClinicFlow.Application)
- [backend/src/ClinicFlow.Infrastructure](/Users/mauriciohenrique/Documents/New%20project/backend/src/ClinicFlow.Infrastructure)

### Frontend

New admin web shell in [apps/admin_web](/Users/mauriciohenrique/Documents/New%20project/apps/admin_web), prepared for React + TypeScript + Vite and already styled around the ClinicFlow AI positioning.

## MVP Scope

The current MVP direction is:

1. Authentication and tenant isolation
2. Patients
3. Professionals
4. Scheduling and status lifecycle
5. Financial summary
6. AI phase 1

## API Snapshot

Implemented initial endpoints:

- `POST /api/auth/login`
- `GET /api/patients`
- `POST /api/patients`
- `GET /api/professionals`
- `POST /api/professionals`
- `GET /api/appointments`
- `POST /api/appointments`
- `PUT /api/appointments/{appointmentId}/status`
- `GET /api/dashboard/summary`
- `POST /api/ai/patient-summary/{patientId}`
- `POST /api/ai/message-generate/{appointmentId}`

Tenant isolation for business endpoints currently uses the `X-Tenant-Id` header.

Demo login:

- `tenantSlug`: `demo-clinic`
- `email`: `admin@clinicflow.ai`
- `password`: any value for now

## How To Run

### Backend

```bash
cd backend/src/ClinicFlow.Api
dotnet run
```

Health check:

- `GET /health`

### Frontend

```bash
cd apps/admin_web
npm install
npm run dev
```

The frontend expects the backend health endpoint at `http://localhost:5057/health` in the current static demo shell.

## Recommended Next Steps

1. Replace in-memory persistence with PostgreSQL + EF Core.
2. Add JWT + refresh token and policy-based authorization.
3. Connect the React admin web to the API.
4. Add medical records and payments persistence.
5. Introduce real OpenAI workflows for summaries, triage and no-show reasoning.

## Recruiter Positioning

Built a multi-tenant AI-powered clinic management SaaS with intelligent scheduling, patient CRM, financial dashboards, automated notifications, and LLM-driven clinical summarization using ASP.NET Core, React, PostgreSQL-ready architecture, and AI workflow endpoints.
