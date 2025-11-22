import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/settings/data/models/settings_section.dart';

class SettingsSectionCard extends StatelessWidget {
  final SettingsSection section;
  final VoidCallback? onTap;

  const SettingsSectionCard({
    super.key,
    required this.section,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primaryBlack.withOpacity(0.08)),
      ),
      child: section.type == SettingsSectionType.inline
          ? ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Icon(section.icon, color: AppColors.primaryBlack),
              title: Text(
                section.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
              subtitle: Text(
                section.description,
                style: TextStyle(
                  color: AppColors.primaryBlack.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  constraints: const BoxConstraints(maxHeight: 420),
                  width: double.infinity,
                  child: section.builder(),
                ),
                const SizedBox(height: 12),
              ],
            )
          : ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(section.icon, color: AppColors.primaryBlack),
              ),
              title: Text(
                section.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
              subtitle: Text(
                section.description,
                style: TextStyle(
                  color: AppColors.primaryBlack.withOpacity(0.6),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: onTap,
            ),
    );
  }
}

