# ClinicFlow Backend

Backend foundation for ClinicFlow AI, a multi-tenant clinic management SaaS with AI-assisted workflows.

## Current backend scope

- tenant-aware domain model
- patients, professionals and appointments
- dashboard summary
- AI endpoints for patient summary and message generation
- in-memory persistence for the first executable slice

## Project structure

- `ClinicFlow.Domain`
- `ClinicFlow.Application`
- `ClinicFlow.Infrastructure`
- `ClinicFlow.Api`

## Demo tenant

- slug: `demo-clinic`
- email: `admin@clinicflow.ai`
- password: placeholder for now

## Main endpoints

- `POST /api/auth/login`
- `GET /api/patients`
- `GET /api/professionals`
- `GET /api/appointments`
- `GET /api/dashboard/summary`
- `POST /api/ai/patient-summary/{patientId}`
- `POST /api/ai/message-generate/{appointmentId}`

## Next backend upgrades

1. PostgreSQL persistence
2. JWT auth and refresh tokens
3. audit logging
4. background reminders
5. stronger OpenAI service integration
