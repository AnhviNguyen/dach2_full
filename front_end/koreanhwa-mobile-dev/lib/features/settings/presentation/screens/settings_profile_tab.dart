import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/models/settings_model.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class SettingsProfileTab extends StatefulWidget {
  const SettingsProfileTab({super.key});

  @override
  State<SettingsProfileTab> createState() => _SettingsProfileTabState();
}

class _SettingsProfileTabState extends State<SettingsProfileTab> {
  late ProfileSettings _profile;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _profile = SettingsService.getSettings().profile;
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      SettingsService.updateProfile(_profile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật hồ sơ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryBlack.withOpacity(0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------- AVATAR -----------
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryBlack,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _profile.avatar,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ),
                        ),

                        // ICON CAMERA
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlack,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryWhite,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.primaryWhite,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ----------- TEXT + BUTTONS -----------
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Ảnh đại diện',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thay đổi ảnh đại diện của bạn',
                          style: TextStyle(
                            color: AppColors.grayLight,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ----------- 2 BUTTONS TRÊN 1 DÒNG – KHÔNG OVERFLOW -----------
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.upload, size: 16),
                                label: const Text('Tải ảnh lên'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlack,
                                  foregroundColor: AppColors.primaryWhite,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  textStyle: const TextStyle(fontSize: 14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.camera_alt, size: 16),
                                label: const Text('Chụp ảnh'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryBlack,
                                  side: BorderSide(
                                    color: AppColors.primaryBlack.withOpacity(0.1),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  textStyle: const TextStyle(fontSize: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Personal Information
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryBlack.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin cá nhân',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _profile.firstName,
                          decoration: const InputDecoration(
                            labelText: 'Họ',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _profile = ProfileSettings(
                                firstName: value,
                                lastName: _profile.lastName,
                                email: _profile.email,
                                phone: _profile.phone,
                                avatar: _profile.avatar,
                                level: _profile.level,
                                goal: _profile.goal,
                                birthday: _profile.birthday,
                                location: _profile.location,
                                bio: _profile.bio,
                                interests: _profile.interests,
                                studyTime: _profile.studyTime,
                                timezone: _profile.timezone,
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _profile.lastName,
                          decoration: const InputDecoration(
                            labelText: 'Tên',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _profile = ProfileSettings(
                                firstName: _profile.firstName,
                                lastName: value,
                                email: _profile.email,
                                phone: _profile.phone,
                                avatar: _profile.avatar,
                                level: _profile.level,
                                goal: _profile.goal,
                                birthday: _profile.birthday,
                                location: _profile.location,
                                bio: _profile.bio,
                                interests: _profile.interests,
                                studyTime: _profile.studyTime,
                                timezone: _profile.timezone,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _profile.email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setState(() {
                        _profile = ProfileSettings(
                          firstName: _profile.firstName,
                          lastName: _profile.lastName,
                          email: value,
                          phone: _profile.phone,
                          avatar: _profile.avatar,
                          level: _profile.level,
                          goal: _profile.goal,
                          birthday: _profile.birthday,
                          location: _profile.location,
                          bio: _profile.bio,
                          interests: _profile.interests,
                          studyTime: _profile.studyTime,
                          timezone: _profile.timezone,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _profile.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() {
                        _profile = ProfileSettings(
                          firstName: _profile.firstName,
                          lastName: _profile.lastName,
                          email: _profile.email,
                          phone: value,
                          avatar: _profile.avatar,
                          level: _profile.level,
                          goal: _profile.goal,
                          birthday: _profile.birthday,
                          location: _profile.location,
                          bio: _profile.bio,
                          interests: _profile.interests,
                          studyTime: _profile.studyTime,
                          timezone: _profile.timezone,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _profile.birthday,
                          decoration: const InputDecoration(
                            labelText: 'Ngày sinh',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _profile = ProfileSettings(
                                  firstName: _profile.firstName,
                                  lastName: _profile.lastName,
                                  email: _profile.email,
                                  phone: _profile.phone,
                                  avatar: _profile.avatar,
                                  level: _profile.level,
                                  goal: _profile.goal,
                                  birthday: '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                                  location: _profile.location,
                                  bio: _profile.bio,
                                  interests: _profile.interests,
                                  studyTime: _profile.studyTime,
                                  timezone: _profile.timezone,
                                );
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _profile.location,
                          decoration: const InputDecoration(
                            labelText: 'Địa điểm',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _profile = ProfileSettings(
                                firstName: _profile.firstName,
                                lastName: _profile.lastName,
                                email: _profile.email,
                                phone: _profile.phone,
                                avatar: _profile.avatar,
                                level: _profile.level,
                                goal: _profile.goal,
                                birthday: _profile.birthday,
                                location: value,
                                bio: _profile.bio,
                                interests: _profile.interests,
                                studyTime: _profile.studyTime,
                                timezone: _profile.timezone,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Learning Profile
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryBlack.withOpacity(0.1)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 520;

                  Widget buildDropdown({
                    required String value,
                    required String label,
                    required List<DropdownMenuItem<String>> items,
                    required ValueChanged<String?> onChanged,
                  }) {
                    return DropdownButtonFormField<String>(
                      value: value,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: label,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: items,
                      onChanged: onChanged,
                    );
                  }

                  const levelItems = [
                    DropdownMenuItem(value: 'Sơ cấp 1', child: Text('Sơ cấp 1')),
                    DropdownMenuItem(value: 'Sơ cấp 2', child: Text('Sơ cấp 2')),
                    DropdownMenuItem(value: 'Sơ cấp 3', child: Text('Sơ cấp 3')),
                    DropdownMenuItem(value: 'Trung cấp 1', child: Text('Trung cấp 1')),
                    DropdownMenuItem(value: 'Trung cấp 2', child: Text('Trung cấp 2')),
                    DropdownMenuItem(value: 'Cao cấp', child: Text('Cao cấp')),
                  ];

                  const goalItems = [
                    DropdownMenuItem(value: 'TOPIK I', child: Text('TOPIK I')),
                    DropdownMenuItem(value: 'TOPIK II', child: Text('TOPIK II')),
                    DropdownMenuItem(value: 'Giao tiếp cơ bản', child: Text('Giao tiếp cơ bản')),
                    DropdownMenuItem(value: 'Du lịch Hàn Quốc', child: Text('Du lịch Hàn Quốc')),
                    DropdownMenuItem(value: 'Công việc', child: Text('Công việc')),
                  ];

                  const studyTimeItems = [
                    DropdownMenuItem(value: 'Buổi sáng', child: Text('Buổi sáng')),
                    DropdownMenuItem(value: 'Buổi trưa', child: Text('Buổi trưa')),
                    DropdownMenuItem(value: 'Buổi chiều', child: Text('Buổi chiều')),
                    DropdownMenuItem(value: 'Buổi tối', child: Text('Buổi tối')),
                    DropdownMenuItem(value: 'Cuối tuần', child: Text('Cuối tuần')),
                  ];

                  const timezoneItems = [
                    DropdownMenuItem(value: 'Asia/Ho_Chi_Minh', child: Text('Việt Nam (GMT+7)')),
                    DropdownMenuItem(value: 'Asia/Seoul', child: Text('Hàn Quốc (GMT+9)')),
                    DropdownMenuItem(value: 'Asia/Tokyo', child: Text('Nhật Bản (GMT+9)')),
                    DropdownMenuItem(value: 'America/New_York', child: Text('New York (GMT-5)')),
                    DropdownMenuItem(value: 'Europe/London', child: Text('London (GMT+0)')),
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hồ sơ học tập',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // MOBILE - xếp dọc
                      if (isNarrow) ...[
                        buildDropdown(
                          value: _profile.level,
                          label: 'Cấp độ hiện tại',
                          items: levelItems,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _profile = ProfileSettings(
                                  firstName: _profile.firstName,
                                  lastName: _profile.lastName,
                                  email: _profile.email,
                                  phone: _profile.phone,
                                  avatar: _profile.avatar,
                                  level: value,
                                  goal: _profile.goal,
                                  birthday: _profile.birthday,
                                  location: _profile.location,
                                  bio: _profile.bio,
                                  interests: _profile.interests,
                                  studyTime: _profile.studyTime,
                                  timezone: _profile.timezone,
                                );
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        buildDropdown(
                          value: _profile.goal,
                          label: 'Mục tiêu học tập',
                          items: goalItems,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _profile = ProfileSettings(
                                  firstName: _profile.firstName,
                                  lastName: _profile.lastName,
                                  email: _profile.email,
                                  phone: _profile.phone,
                                  avatar: _profile.avatar,
                                  level: _profile.level,
                                  goal: value,
                                  birthday: _profile.birthday,
                                  location: _profile.location,
                                  bio: _profile.bio,
                                  interests: _profile.interests,
                                  studyTime: _profile.studyTime,
                                  timezone: _profile.timezone,
                                );
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        buildDropdown(
                          value: _profile.studyTime,
                          label: 'Thời gian học tập',
                          items: studyTimeItems,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _profile = ProfileSettings(
                                  firstName: _profile.firstName,
                                  lastName: _profile.lastName,
                                  email: _profile.email,
                                  phone: _profile.phone,
                                  avatar: _profile.avatar,
                                  level: _profile.level,
                                  goal: _profile.goal,
                                  birthday: _profile.birthday,
                                  location: _profile.location,
                                  bio: _profile.bio,
                                  interests: _profile.interests,
                                  studyTime: value,
                                  timezone: _profile.timezone,
                                );
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        buildDropdown(
                          value: _profile.timezone,
                          label: 'Múi giờ',
                          items: timezoneItems,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _profile = ProfileSettings(
                                  firstName: _profile.firstName,
                                  lastName: _profile.lastName,
                                  email: _profile.email,
                                  phone: _profile.phone,
                                  avatar: _profile.avatar,
                                  level: _profile.level,
                                  goal: _profile.goal,
                                  birthday: _profile.birthday,
                                  location: _profile.location,
                                  bio: _profile.bio,
                                  interests: _profile.interests,
                                  studyTime: _profile.studyTime,
                                  timezone: value,
                                );
                              });
                            }
                          },
                        ),
                      ],

                      // DESKTOP / TABLET – 2 cột
                      if (!isNarrow) ...[
                        Row(
                          children: [
                            Expanded(
                              child: buildDropdown(
                                value: _profile.level,
                                label: 'Cấp độ hiện tại',
                                items: levelItems,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _profile = ProfileSettings(
                                        firstName: _profile.firstName,
                                        lastName: _profile.lastName,
                                        email: _profile.email,
                                        phone: _profile.phone,
                                        avatar: _profile.avatar,
                                        level: value,
                                        goal: _profile.goal,
                                        birthday: _profile.birthday,
                                        location: _profile.location,
                                        bio: _profile.bio,
                                        interests: _profile.interests,
                                        studyTime: _profile.studyTime,
                                        timezone: _profile.timezone,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: buildDropdown(
                                value: _profile.goal,
                                label: 'Mục tiêu học tập',
                                items: goalItems,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _profile = ProfileSettings(
                                        firstName: _profile.firstName,
                                        lastName: _profile.lastName,
                                        email: _profile.email,
                                        phone: _profile.phone,
                                        avatar: _profile.avatar,
                                        level: _profile.level,
                                        goal: value,
                                        birthday: _profile.birthday,
                                        location: _profile.location,
                                        bio: _profile.bio,
                                        interests: _profile.interests,
                                        studyTime: _profile.studyTime,
                                        timezone: _profile.timezone,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: buildDropdown(
                                value: _profile.studyTime,
                                label: 'Thời gian học tập',
                                items: studyTimeItems,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _profile = ProfileSettings(
                                        firstName: _profile.firstName,
                                        lastName: _profile.lastName,
                                        email: _profile.email,
                                        phone: _profile.phone,
                                        avatar: _profile.avatar,
                                        level: _profile.level,
                                        goal: _profile.goal,
                                        birthday: _profile.birthday,
                                        location: _profile.location,
                                        bio: _profile.bio,
                                        interests: _profile.interests,
                                        studyTime: value,
                                        timezone: _profile.timezone,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: buildDropdown(
                                value: _profile.timezone,
                                label: 'Múi giờ',
                                items: timezoneItems,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _profile = ProfileSettings(
                                        firstName: _profile.firstName,
                                        lastName: _profile.lastName,
                                        email: _profile.email,
                                        phone: _profile.phone,
                                        avatar: _profile.avatar,
                                        level: _profile.level,
                                        goal: _profile.goal,
                                        birthday: _profile.birthday,
                                        location: _profile.location,
                                        bio: _profile.bio,
                                        interests: _profile.interests,
                                        studyTime: _profile.studyTime,
                                        timezone: value,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.primaryBlack,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Lưu thay đổi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddInterestDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm sở thích'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nhập sở thích mới',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  final newInterests = List<String>.from(_profile.interests)..add(controller.text.trim());
                  _profile = ProfileSettings(
                    firstName: _profile.firstName,
                    lastName: _profile.lastName,
                    email: _profile.email,
                    phone: _profile.phone,
                    avatar: _profile.avatar,
                    level: _profile.level,
                    goal: _profile.goal,
                    birthday: _profile.birthday,
                    location: _profile.location,
                    bio: _profile.bio,
                    interests: newInterests,
                    studyTime: _profile.studyTime,
                    timezone: _profile.timezone,
                  );
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.primaryBlack,
            ),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

