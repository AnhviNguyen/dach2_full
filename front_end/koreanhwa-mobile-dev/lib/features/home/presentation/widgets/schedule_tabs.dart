import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/home/presentation/widgets/section_header.dart';
import 'package:koreanhwa_flutter/features/home/data/models/day_tab.dart';

class ScheduleTabs extends StatelessWidget {
  final List<DayTab> weekDays;

  const ScheduleTabs({super.key, required this.weekDays});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Lịch học trong tuần', icon: Icons.calendar_today),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: weekDays.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final day = weekDays[index];

              return Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: day.isStudied
                        ? AppColors.primaryYellow
                        : AppColors.primaryWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: day.isStudied
                          ? AppColors.primaryYellow
                          : AppColors.primaryBlack.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.label,
                        style: const TextStyle(
                          color: AppColors.primaryBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      day.isStudied
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryBlack,
                              size: 20,
                            )
                          : Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryBlack.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

