import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition_result.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/prize_claim_info.dart';
import 'package:koreanhwa_flutter/services/competition_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class CompetitionPrizeClaimScreen extends StatefulWidget {
  final CompetitionResult? result;

  const CompetitionPrizeClaimScreen({super.key, this.result});

  @override
  State<CompetitionPrizeClaimScreen> createState() => _CompetitionPrizeClaimScreenState();
}

class _CompetitionPrizeClaimScreenState extends State<CompetitionPrizeClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bankAccountController.dispose();
    _bankNameController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final claimInfo = PrizeClaimInfo(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        bankAccount: _bankAccountController.text.trim(),
        bankName: _bankNameController.text.trim(),
        address: _addressController.text.trim(),
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      CompetitionService.claimPrize(widget.result!.competitionId, claimInfo);
      context.push('/competition/prize-pending', extra: widget.result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Không tìm thấy kết quả')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlack,
        title: const Text(
          'Thông tin nhận giải',
          style: TextStyle(color: AppColors.primaryWhite),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prize Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryYellow,
                      AppColors.primaryYellow.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 48,
                      color: AppColors.primaryBlack,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Giải thưởng của bạn',
                      style: TextStyle(
                        color: AppColors.primaryBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.result!.prizeAmount != null)
                      Text(
                        '${widget.result!.prizeAmount!.toLocaleString()} VNĐ',
                        style: const TextStyle(
                          color: AppColors.primaryBlack,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Vui lòng điền thông tin để nhận giải thưởng',
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Form Fields
              _buildTextField(
                controller: _fullNameController,
                label: 'Họ và tên',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (value.length < 10) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!value.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bankAccountController,
                label: 'Số tài khoản ngân hàng',
                icon: Icons.account_balance,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tài khoản';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bankNameController,
                label: 'Tên ngân hàng',
                icon: Icons.business,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên ngân hàng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Địa chỉ',
                icon: Icons.location_on,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _noteController,
                label: 'Ghi chú (tùy chọn)',
                icon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.primaryBlack,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Gửi thông tin',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primaryYellow),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Thông tin của bạn sẽ được xét duyệt trong vòng 1-3 ngày làm việc',
                        style: TextStyle(
                          color: AppColors.primaryWhite,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppColors.primaryWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.grayLight),
        prefixIcon: Icon(icon, color: AppColors.primaryYellow),
        filled: true,
        fillColor: AppColors.primaryBlack.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grayLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grayLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

extension NumberExtension on int {
  String toLocaleString() {
    final numberStr = toString();
    final reversed = numberStr.split('').reversed.join();
    final chunks = <String>[];
    for (int i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.substring(i, (i + 3 > reversed.length) ? reversed.length : i + 3));
    }
    return chunks.join('.').split('').reversed.join();
  }
}

