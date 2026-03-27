using ClinicFlow.Domain.Enums;

namespace ClinicFlow.Domain.Entities;

public sealed class Payment
{
    public Guid Id { get; init; }
    public Guid TenantId { get; init; }
    public Guid AppointmentId { get; init; }
    public decimal Amount { get; init; }
    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;
    public PaymentMethod Method { get; init; }
    public DateTime? PaidAtUtc { get; set; }
}
