namespace ClinicFlow.Application.Contracts;

public sealed record DashboardSummaryDto(
    int AppointmentsToday,
    int ConfirmedAppointments,
    decimal RevenueMonth,
    double NoShowRate,
    int ActivePatients,
    int ActiveProfessionals);
