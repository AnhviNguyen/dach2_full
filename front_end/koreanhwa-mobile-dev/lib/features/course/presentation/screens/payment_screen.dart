import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/features/course_classroom_screen.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

enum _PaymentStage { form, success, error }

enum _PaymentMethod { momo, banking, card }

class PaymentScreen extends StatefulWidget {
  final String courseTitle;
  final double amount;
  final ValueChanged<bool>? onPaymentResult;

  const PaymentScreen({
    super.key,
    required this.courseTitle,
    required this.amount,
    this.onPaymentResult,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Banking fields
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  // Card fields (for international cards)
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  _PaymentStage _stage = _PaymentStage.form;
  _PaymentMethod _selectedMethod = _PaymentMethod.momo;
  String? _selectedBank;

  // Popular Vietnamese banks
  final List<Map<String, String>> _vietnameseBanks = [
    {'code': 'VCB', 'name': 'Vietcombank'},
    {'code': 'TCB', 'name': 'Techcombank'},
    {'code': 'BIDV', 'name': 'BIDV'},
    {'code': 'VTB', 'name': 'Vietinbank'},
    {'code': 'ACB', 'name': 'ACB'},
    {'code': 'MB', 'name': 'MBBank'},
    {'code': 'TPB', 'name': 'TPBank'},
    {'code': 'VPB', 'name': 'VPBank'},
    {'code': 'SCB', 'name': 'Sacombank'},
    {'code': 'OCB', 'name': 'OCB'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _stage = _PaymentStage.success;
    });
    widget.onPaymentResult?.call(true);
  }

  void _handleRetry() {
    setState(() {
      _stage = _PaymentStage.form;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (_stage) {
          _PaymentStage.form => _buildForm(),
          _PaymentStage.success => _buildSuccess(),
          _PaymentStage.error => _buildError(),
        },
      ),
    );
  }

  Widget _buildPaymentMethodOption(_PaymentMethod method, String title, IconData icon, Color color) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? color : Colors.grey.shade600, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? AppColors.primaryBlack : Colors.grey.shade700,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMoMoInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.pink.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Hướng dẫn thanh toán MoMo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionStep('1', 'Nhấn "Thanh toán với MoMo" bên dưới'),
          const SizedBox(height: 8),
          _buildInstructionStep('2', 'Ứng dụng MoMo sẽ tự động mở'),
          const SizedBox(height: 8),
          _buildInstructionStep('3', 'Xác nhận thanh toán trong ứng dụng MoMo'),
        ],
      ),
    );
  }

  Widget _buildBankingFields() {
    return Column(
      children: [
        // Bank Selection
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedBank,
              hint: Row(
                children: [
                  Icon(Icons.account_balance, color: Colors.blue.shade600, size: 22),
                  const SizedBox(width: 12),
                  const Text('Chọn ngân hàng'),
                ],
              ),
              icon: const Icon(Icons.arrow_drop_down),
              items: _vietnameseBanks.map((bank) {
                return DropdownMenuItem<String>(
                  value: bank['code'],
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bank['code']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(bank['name']!),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBank = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        _PaymentField(
          controller: _accountNumberController,
          label: 'Số tài khoản',
          icon: Icons.numbers_outlined,
          keyboardType: TextInputType.number,
          validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập số tài khoản' : null,
        ),
        const SizedBox(height: 16),
        _PaymentField(
          controller: _accountNameController,
          label: 'Tên chủ tài khoản',
          icon: Icons.person_outline,
          validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên chủ tài khoản' : null,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Thông tin chuyển khoản',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTransferInfo('Số tài khoản', '0123456789'),
              const SizedBox(height: 8),
              _buildTransferInfo('Chủ tài khoản', 'CONG TY KOREANHWA'),
              const SizedBox(height: 8),
              _buildTransferInfo('Ngân hàng', 'Vietcombank - CN Hà Nội'),
              const SizedBox(height: 8),
              _buildTransferInfo('Nội dung CK', 'KHOAHOC ${widget.courseTitle.split(' ').take(2).join('')}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardFields() {
    return Column(
      children: [
        _PaymentField(
          controller: _cardController,
          label: 'Số thẻ',
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          validator: (value) => value == null || value.length < 12 ? 'Số thẻ không hợp lệ' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _PaymentField(
                controller: _expiryController,
                label: 'MM/YY',
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.length < 4 ? 'Ngày hết hạn' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _PaymentField(
                controller: _cvvController,
                label: 'CVV',
                icon: Icons.lock_outline,
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) => value == null || value.length < 3 ? 'CVV không hợp lệ' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.pink.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransferInfo(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Summary Card - Improved
          _buildSummary(),
          const SizedBox(height: 24),

          // Payment Method Selection
          const Text(
            'Chọn phương thức thanh toán',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),

          // Payment Methods
          _buildPaymentMethodOption(
            _PaymentMethod.momo,
            'Ví MoMo',
            Icons.account_balance_wallet,
            Colors.pink.shade400,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodOption(
            _PaymentMethod.banking,
            'Chuyển khoản ngân hàng',
            Icons.account_balance,
            Colors.blue.shade600,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodOption(
            _PaymentMethod.card,
            'Thẻ quốc tế (Visa/Master)',
            Icons.credit_card,
            Colors.orange.shade600,
          ),

          const SizedBox(height: 24),

          // Payment Form Section
          const Text(
            'Thông tin thanh toán',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),

          Form(
            key: _formKey,
            child: Column(
              children: [
                // Common fields
                _PaymentField(
                  controller: _nameController,
                  label: 'Họ và tên',
                  icon: Icons.person_outline,
                  validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập họ tên' : null,
                ),
                const SizedBox(height: 16),
                _PaymentField(
                  controller: _phoneController,
                  label: 'Số điện thoại',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.length < 10 ? 'Số điện thoại không hợp lệ' : null,
                ),
                const SizedBox(height: 16),
                _PaymentField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || !value.contains('@') ? 'Email không hợp lệ' : null,
                ),
                const SizedBox(height: 16),

                // Method specific fields
                if (_selectedMethod == _PaymentMethod.momo) ...[
                  _buildMoMoInstructions(),
                ] else if (_selectedMethod == _PaymentMethod.banking) ...[
                  _buildBankingFields(),
                ] else if (_selectedMethod == _PaymentMethod.card) ...[
                  _buildCardFields(),
                ],

                const SizedBox(height: 24),

                // Total Amount Card - Improved
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryYellow.withOpacity(0.15),
                        AppColors.primaryYellow.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryYellow.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng thanh toán',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Một lần duy nhất',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${widget.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Button - Improved
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.primaryBlack,
                      elevation: 2,
                      shadowColor: AppColors.primaryYellow.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _selectedMethod == _PaymentMethod.momo
                          ? 'Thanh toán với MoMo'
                          : _selectedMethod == _PaymentMethod.banking
                          ? 'Xác nhận chuyển khoản'
                          : 'Xác nhận thanh toán',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Security Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Thanh toán được mã hóa và bảo mật',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success Icon with Animation Effect
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade50,
                  Colors.green.shade100,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 80,
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Thanh toán thành công!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Bạn đã đăng ký thành công khóa học "${widget.courseTitle}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Go to Classroom Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseClassroomScreen(courseTitle: widget.courseTitle),
                  ),
                );
              },
              icon: const Icon(Icons.school_outlined),
              label: const Text(
                'Đi đến phòng học',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.primaryBlack,
                elevation: 2,
                shadowColor: AppColors.primaryYellow.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Về trang khóa học',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade50,
                  Colors.red.shade100,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.error_rounded,
              color: Colors.red,
              size: 80,
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Thanh toán thất bại!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Vui lòng kiểm tra lại thông tin thẻ hoặc thử phương thức khác.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _handleRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Thử lại',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.primaryBlack,
                elevation: 2,
                shadowColor: AppColors.primaryYellow.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryYellow.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: AppColors.primaryBlack,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Chi tiết khóa học',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            widget.courseTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlack,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Thời hạn truy cập: 90 ngày',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  const _PaymentField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 15,
        ),
        prefixIcon: Icon(icon, color: AppColors.primaryYellow, size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}