# ClinicFlow Backend

Backend foundation for the ClinicFlow AI SaaS.

## Architecture

- `ClinicFlow.Domain`: entities and enums for tenants, users, patients, professionals, appointments and payments
- `ClinicFlow.Application`: DTOs, repository abstraction and MVP application service
- `ClinicFlow.Infrastructure`: in-memory seeded repository used for the first executable slice
- `ClinicFlow.Api`: HTTP API with tenant header resolution and controller endpoints

## Demo Tenant

- Tenant slug: `demo-clinic`
- User email: `admin@clinicflow.ai`
- Password: placeholder for now

## Main Endpoints

- `POST /api/auth/login`
- `GET /api/patients`
- `GET /api/professionals`
- `GET /api/appointments`
- `GET /api/dashboard/summary`
- `POST /api/ai/patient-summary/{patientId}`
- `POST /api/ai/message-generate/{appointmentId}`

## Next Backend Upgrades

1. PostgreSQL persistence
2. JWT auth and refresh tokens
3. audit logging
4. background reminders
5. OpenAI service integration
