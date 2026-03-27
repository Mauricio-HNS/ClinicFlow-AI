using ClinicFlow.Domain.Entities;

namespace ClinicFlow.Application.Abstractions;

public interface IClinicRepository
{
    Tenant? FindTenantBySlug(string tenantSlug);
    User? FindUserByEmail(Guid tenantId, string email);
    IReadOnlyList<Patient> GetPatients(Guid tenantId);
    Patient AddPatient(Patient patient);
    IReadOnlyList<Professional> GetProfessionals(Guid tenantId);
    Professional AddProfessional(Professional professional);
    IReadOnlyList<Appointment> GetAppointments(Guid tenantId);
    Appointment AddAppointment(Appointment appointment);
    Appointment? FindAppointment(Guid tenantId, Guid appointmentId);
    Patient? FindPatient(Guid tenantId, Guid patientId);
    Professional? FindProfessional(Guid tenantId, Guid professionalId);
    IReadOnlyList<Payment> GetPayments(Guid tenantId);
}
