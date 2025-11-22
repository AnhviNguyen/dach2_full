class PrizeClaimInfo {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String bankAccount;
  final String bankName;
  final String address;
  final String? note;

  PrizeClaimInfo({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.bankAccount,
    required this.bankName,
    required this.address,
    this.note,
  });
}

