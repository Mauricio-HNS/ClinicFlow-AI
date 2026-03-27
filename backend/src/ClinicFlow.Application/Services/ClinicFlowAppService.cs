using ClinicFlow.Application.Abstractions;
using ClinicFlow.Application.Contracts;
using ClinicFlow.Domain.Entities;
using ClinicFlow.Domain.Enums;

namespace ClinicFlow.Application.Services;

public sealed class ClinicFlowAppService(IClinicRepository repository)
{
    public LoginResponse Login(LoginRequest request)
    {
        var tenant = repository.FindTenantBySlug(request.TenantSlug)
            ?? throw new InvalidOperationException("Tenant not found.");

        var user = repository.FindUserByEmail(tenant.Id, request.Email)
            ?? throw new InvalidOperationException("User not found.");

        return new LoginResponse(
            AccessToken: $"demo-token-{tenant.Id:N}-{user.Id:N}",
            TenantId: tenant.Id,
            TenantName: tenant.Name,
            UserId: user.Id,
            FullName: user.FullName,
            Role: user.Role);
    }

    public IReadOnlyList<PatientDto> GetPatients(Guid tenantId) =>
        repository.GetPatients(tenantId)
            .OrderBy(x => x.FullName)
            .Select(MapPatient)
            .ToList();

    public PatientDto CreatePatient(Guid tenantId, CreatePatientRequest request)
    {
        var patient = repository.AddPatient(new Patient
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            FullName = request.FullName.Trim(),
            BirthDate = request.BirthDate,
            Gender = request.Gender.Trim(),
            Phone = request.Phone.Trim(),
            Email = request.Email.Trim(),
            Document = request.Document.Trim(),
            Insurance = request.Insurance.Trim(),
            Notes = request.Notes.Trim(),
            CreatedAtUtc = DateTime.UtcNow
        });

        return MapPatient(patient);
    }

    public IReadOnlyList<ProfessionalDto> GetProfessionals(Guid tenantId) =>
        repository.GetProfessionals(tenantId)
            .OrderBy(x => x.FullName)
            .Select(MapProfessional)
            .ToList();

    public ProfessionalDto CreateProfessional(Guid tenantId, CreateProfessionalRequest request)
    {
        var professional = repository.AddProfessional(new Professional
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            FullName = request.FullName.Trim(),
            Specialty = request.Specialty.Trim(),
            LicenseNumber = request.LicenseNumber.Trim(),
            AppointmentDurationMinutes = request.AppointmentDurationMinutes <= 0 ? 30 : request.AppointmentDurationMinutes,
            Active = true
        });

        return MapProfessional(professional);
    }

    public IReadOnlyList<AppointmentDto> GetAppointments(Guid tenantId) =>
        repository.GetAppointments(tenantId)
            .OrderBy(x => x.StartAtUtc)
            .Select(x =>
            {
                var patient = repository.FindPatient(tenantId, x.PatientId);
                var professional = repository.FindProfessional(tenantId, x.ProfessionalId);

                return new AppointmentDto(
                    x.Id,
                    x.TenantId,
                    x.PatientId,
                    patient?.FullName ?? "Unknown patient",
                    x.ProfessionalId,
                    professional?.FullName ?? "Unknown professional",
                    x.ClinicUnitName,
                    x.StartAtUtc,
                    x.EndAtUtc,
                    x.Status,
                    x.NoShowRiskScore);
            })
            .ToList();

    public AppointmentDto CreateAppointment(Guid tenantId, CreateAppointmentRequest request)
    {
        var patient = repository.FindPatient(tenantId, request.PatientId)
            ?? throw new InvalidOperationException("Patient not found.");

        var professional = repository.FindProfessional(tenantId, request.ProfessionalId)
            ?? throw new InvalidOperationException("Professional not found.");

        var endAtUtc = request.StartAtUtc.AddMinutes(professional.AppointmentDurationMinutes);
        var appointments = repository.GetAppointments(tenantId);
        var hasConflict = appointments.Any(x =>
            x.ProfessionalId == request.ProfessionalId &&
            x.Status is not AppointmentStatus.Cancelled &&
            x.StartAtUtc < endAtUtc &&
            request.StartAtUtc < x.EndAtUtc);

        if (hasConflict)
        {
            throw new InvalidOperationException("Time slot conflict for this professional.");
        }

        var appointment = repository.AddAppointment(new Appointment
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            PatientId = patient.Id,
            ProfessionalId = professional.Id,
            ClinicUnitName = string.IsNullOrWhiteSpace(request.ClinicUnitName) ? "Main Unit" : request.ClinicUnitName.Trim(),
            StartAtUtc = request.StartAtUtc,
            EndAtUtc = endAtUtc,
            Status = AppointmentStatus.Scheduled,
            Notes = request.Notes.Trim(),
            NoShowRiskScore = CalculateNoShowRisk(request.StartAtUtc)
        });

        return new AppointmentDto(
            appointment.Id,
            appointment.TenantId,
            appointment.PatientId,
            patient.FullName,
            appointment.ProfessionalId,
            professional.FullName,
            appointment.ClinicUnitName,
            appointment.StartAtUtc,
            appointment.EndAtUtc,
            appointment.Status,
            appointment.NoShowRiskScore);
    }

    public AppointmentDto UpdateAppointmentStatus(Guid tenantId, Guid appointmentId, UpdateAppointmentStatusRequest request)
    {
        var appointment = repository.FindAppointment(tenantId, appointmentId)
            ?? throw new InvalidOperationException("Appointment not found.");
        var patient = repository.FindPatient(tenantId, appointment.PatientId)
            ?? throw new InvalidOperationException("Patient not found.");
        var professional = repository.FindProfessional(tenantId, appointment.ProfessionalId)
            ?? throw new InvalidOperationException("Professional not found.");

        appointment.Status = request.Status;
        appointment.CancellationReason = request.CancellationReason?.Trim();

        return new AppointmentDto(
            appointment.Id,
            appointment.TenantId,
            appointment.PatientId,
            patient.FullName,
            appointment.ProfessionalId,
            professional.FullName,
            appointment.ClinicUnitName,
            appointment.StartAtUtc,
            appointment.EndAtUtc,
            appointment.Status,
            appointment.NoShowRiskScore);
    }

    public DashboardSummaryDto GetDashboard(Guid tenantId)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var appointments = repository.GetAppointments(tenantId);
        var todayAppointments = appointments
            .Where(x => DateOnly.FromDateTime(x.StartAtUtc) == today)
            .ToList();
        var payments = repository.GetPayments(tenantId);
        var monthStart = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1);
        var paidAppointmentIds = payments
            .Where(x => x.Status == PaymentStatus.Paid && x.PaidAtUtc >= monthStart)
            .Select(x => x.AppointmentId)
            .ToHashSet();
        var revenue = payments
            .Where(x => x.Status == PaymentStatus.Paid && x.PaidAtUtc >= monthStart)
            .Sum(x => x.Amount);
        var completed = appointments.Count(x => x.Status == AppointmentStatus.Completed || x.Status == AppointmentStatus.NoShow);
        var noShow = appointments.Count(x => x.Status == AppointmentStatus.NoShow);

        return new DashboardSummaryDto(
            AppointmentsToday: todayAppointments.Count,
            ConfirmedAppointments: todayAppointments.Count(x => x.Status == AppointmentStatus.Confirmed),
            RevenueMonth: revenue,
            NoShowRate: completed == 0 ? 0 : Math.Round((double)noShow / completed * 100, 1),
            ActivePatients: repository.GetPatients(tenantId).Count,
            ActiveProfessionals: repository.GetProfessionals(tenantId).Count(x => x.Active));
    }

    public PatientSummaryDto GeneratePatientSummary(Guid tenantId, Guid patientId)
    {
        var patient = repository.FindPatient(tenantId, patientId)
            ?? throw new InvalidOperationException("Patient not found.");
        var latestAppointments = repository.GetAppointments(tenantId)
            .Where(x => x.PatientId == patientId)
            .OrderByDescending(x => x.StartAtUtc)
            .Take(3)
            .ToList();

        var summary = latestAppointments.Count == 0
            ? $"{patient.FullName} ainda não possui consultas registradas."
            : $"{patient.FullName} teve {latestAppointments.Count} interacoes recentes e possui historico com foco em {patient.Notes.ToLowerInvariant()}";

        return new PatientSummaryDto(
            patient.Id,
            summary,
            AttentionPoints: $"Convenio: {patient.Insurance}. Ultimo contato: {latestAppointments.FirstOrDefault()?.StartAtUtc:yyyy-MM-dd HH:mm} UTC.",
            SuggestedNextSteps: "Confirmar retorno preventivo, revisar aderencia ao tratamento e validar dados de contato.");
    }

    public MessageSuggestionDto GenerateConfirmationMessage(Guid tenantId, Guid appointmentId)
    {
        var appointment = repository.FindAppointment(tenantId, appointmentId)
            ?? throw new InvalidOperationException("Appointment not found.");
        var patient = repository.FindPatient(tenantId, appointment.PatientId)
            ?? throw new InvalidOperationException("Patient not found.");
        var professional = repository.FindProfessional(tenantId, appointment.ProfessionalId)
            ?? throw new InvalidOperationException("Professional not found.");

        return new MessageSuggestionDto(
            appointment.Id,
            "WhatsApp",
            $"Ola {patient.FullName}, sua consulta com {professional.FullName} esta agendada para {appointment.StartAtUtc:dd/MM/yyyy HH:mm} UTC. Responda CONFIRMAR para garantir o horario.");
    }

    private static int CalculateNoShowRisk(DateTime startAtUtc)
    {
        var score = 25;

        if (startAtUtc.DayOfWeek is DayOfWeek.Monday or DayOfWeek.Friday)
        {
            score += 15;
        }

        if (startAtUtc.Hour < 9 || startAtUtc.Hour >= 18)
        {
            score += 10;
        }

        if ((startAtUtc - DateTime.UtcNow).TotalHours > 72)
        {
            score += 20;
        }

        return Math.Min(score, 95);
    }

    private static PatientDto MapPatient(Patient patient) =>
        new(
            patient.Id,
            patient.TenantId,
            patient.FullName,
            patient.BirthDate,
            patient.Gender,
            patient.Phone,
            patient.Email,
            patient.Insurance,
            patient.Notes);

    private static ProfessionalDto MapProfessional(Professional professional) =>
        new(
            professional.Id,
            professional.TenantId,
            professional.FullName,
            professional.Specialty,
            professional.LicenseNumber,
            professional.AppointmentDurationMinutes,
            professional.Active);
}
