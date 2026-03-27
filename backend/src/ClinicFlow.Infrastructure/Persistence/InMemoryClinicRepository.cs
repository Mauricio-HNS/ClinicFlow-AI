using ClinicFlow.Application.Abstractions;
using ClinicFlow.Domain.Entities;
using ClinicFlow.Domain.Enums;

namespace ClinicFlow.Infrastructure.Persistence;

public sealed class InMemoryClinicRepository : IClinicRepository
{
    private readonly List<Tenant> _tenants;
    private readonly List<User> _users;
    private readonly List<Patient> _patients;
    private readonly List<Professional> _professionals;
    private readonly List<Appointment> _appointments;
    private readonly List<Payment> _payments;

    public InMemoryClinicRepository()
    {
        var tenantId = Guid.Parse("a84e7a32-6d4c-4a13-8b25-3f4d580cc111");
        var patientId = Guid.Parse("d99d86b4-e2b4-4f72-9670-bf4f0c43b111");
        var secondPatientId = Guid.Parse("e97aa233-c6a1-4518-bb56-9f4ff697c222");
        var professionalId = Guid.Parse("1d6c7ac9-dffe-438c-8b1e-3f98e01de333");
        var secondProfessionalId = Guid.Parse("3f3c7ac9-dffe-438c-8b1e-3f98e01de444");
        var today = DateTime.UtcNow.Date.AddHours(9);
        var paidAppointmentId = Guid.Parse("85eb1a9f-6313-4de7-9730-0b9eb2b1f555");

        _tenants =
        [
            new Tenant
            {
                Id = tenantId,
                Name = "ClinicFlow Demo Clinic",
                Plan = "Growth",
                Status = TenantStatus.Active,
                CreatedAtUtc = DateTime.UtcNow.AddMonths(-4)
            }
        ];

        _users =
        [
            new User
            {
                Id = Guid.Parse("61fdf1be-bc43-4a1d-b59d-806cc8d2e001"),
                TenantId = tenantId,
                FullName = "Ana Costa",
                Email = "admin@clinicflow.ai",
                Role = UserRole.ClinicAdmin,
                Active = true
            },
            new User
            {
                Id = Guid.Parse("61fdf1be-bc43-4a1d-b59d-806cc8d2e002"),
                TenantId = tenantId,
                FullName = "Dr. Lucas Martins",
                Email = "doctor@clinicflow.ai",
                Role = UserRole.Doctor,
                Active = true
            }
        ];

        _patients =
        [
            new Patient
            {
                Id = patientId,
                TenantId = tenantId,
                FullName = "Marina Silva",
                BirthDate = new DateOnly(1992, 4, 18),
                Gender = "Female",
                Phone = "+34 600 100 200",
                Email = "marina@email.com",
                Document = "123456789",
                Insurance = "Sanitas",
                Notes = "acompanhamento de cardiologia e controle de pressao"
            },
            new Patient
            {
                Id = secondPatientId,
                TenantId = tenantId,
                FullName = "Joao Pereira",
                BirthDate = new DateOnly(1986, 9, 2),
                Gender = "Male",
                Phone = "+34 600 300 400",
                Email = "joao@email.com",
                Document = "987654321",
                Insurance = "Particular",
                Notes = "seguimento pos-procedimento com necessidade de retorno"
            }
        ];

        _professionals =
        [
            new Professional
            {
                Id = professionalId,
                TenantId = tenantId,
                FullName = "Dr. Lucas Martins",
                Specialty = "Cardiology",
                LicenseNumber = "CRM-ES-1100",
                AppointmentDurationMinutes = 30,
                Active = true
            },
            new Professional
            {
                Id = secondProfessionalId,
                TenantId = tenantId,
                FullName = "Dra. Sofia Ramirez",
                Specialty = "Dermatology",
                LicenseNumber = "CRM-ES-1101",
                AppointmentDurationMinutes = 40,
                Active = true
            }
        ];

        _appointments =
        [
            new Appointment
            {
                Id = paidAppointmentId,
                TenantId = tenantId,
                PatientId = patientId,
                ProfessionalId = professionalId,
                ClinicUnitName = "Madrid Central",
                StartAtUtc = today,
                EndAtUtc = today.AddMinutes(30),
                Status = AppointmentStatus.Confirmed,
                NoShowRiskScore = 42
            },
            new Appointment
            {
                Id = Guid.Parse("b6eb1a9f-6313-4de7-9730-0b9eb2b1f556"),
                TenantId = tenantId,
                PatientId = secondPatientId,
                ProfessionalId = secondProfessionalId,
                ClinicUnitName = "Madrid Central",
                StartAtUtc = today.AddHours(2),
                EndAtUtc = today.AddHours(2).AddMinutes(40),
                Status = AppointmentStatus.Scheduled,
                NoShowRiskScore = 55
            },
            new Appointment
            {
                Id = Guid.Parse("c7eb1a9f-6313-4de7-9730-0b9eb2b1f557"),
                TenantId = tenantId,
                PatientId = patientId,
                ProfessionalId = professionalId,
                ClinicUnitName = "Madrid Central",
                StartAtUtc = today.AddDays(-6),
                EndAtUtc = today.AddDays(-6).AddMinutes(30),
                Status = AppointmentStatus.Completed,
                NoShowRiskScore = 30
            },
            new Appointment
            {
                Id = Guid.Parse("d8eb1a9f-6313-4de7-9730-0b9eb2b1f558"),
                TenantId = tenantId,
                PatientId = secondPatientId,
                ProfessionalId = secondProfessionalId,
                ClinicUnitName = "Madrid Central",
                StartAtUtc = today.AddDays(-3),
                EndAtUtc = today.AddDays(-3).AddMinutes(40),
                Status = AppointmentStatus.NoShow,
                NoShowRiskScore = 80
            }
        ];

        _payments =
        [
            new Payment
            {
                Id = Guid.Parse("e9eb1a9f-6313-4de7-9730-0b9eb2b1f559"),
                TenantId = tenantId,
                AppointmentId = paidAppointmentId,
                Amount = 180m,
                Status = PaymentStatus.Paid,
                Method = PaymentMethod.Card,
                PaidAtUtc = DateTime.UtcNow.AddDays(-1)
            }
        ];
    }

    public Tenant? FindTenantBySlug(string tenantSlug) =>
        tenantSlug.Equals("demo-clinic", StringComparison.OrdinalIgnoreCase)
            ? _tenants[0]
            : null;

    public User? FindUserByEmail(Guid tenantId, string email) =>
        _users.FirstOrDefault(x =>
            x.TenantId == tenantId &&
            x.Email.Equals(email, StringComparison.OrdinalIgnoreCase));

    public IReadOnlyList<Patient> GetPatients(Guid tenantId) =>
        _patients.Where(x => x.TenantId == tenantId).ToList();

    public Patient AddPatient(Patient patient)
    {
        _patients.Add(patient);
        return patient;
    }

    public IReadOnlyList<Professional> GetProfessionals(Guid tenantId) =>
        _professionals.Where(x => x.TenantId == tenantId).ToList();

    public Professional AddProfessional(Professional professional)
    {
        _professionals.Add(professional);
        return professional;
    }

    public IReadOnlyList<Appointment> GetAppointments(Guid tenantId) =>
        _appointments.Where(x => x.TenantId == tenantId).ToList();

    public Appointment AddAppointment(Appointment appointment)
    {
        _appointments.Add(appointment);
        return appointment;
    }

    public Appointment? FindAppointment(Guid tenantId, Guid appointmentId) =>
        _appointments.FirstOrDefault(x => x.TenantId == tenantId && x.Id == appointmentId);

    public Patient? FindPatient(Guid tenantId, Guid patientId) =>
        _patients.FirstOrDefault(x => x.TenantId == tenantId && x.Id == patientId);

    public Professional? FindProfessional(Guid tenantId, Guid professionalId) =>
        _professionals.FirstOrDefault(x => x.TenantId == tenantId && x.Id == professionalId);

    public IReadOnlyList<Payment> GetPayments(Guid tenantId) =>
        _payments.Where(x => x.TenantId == tenantId).ToList();
}
