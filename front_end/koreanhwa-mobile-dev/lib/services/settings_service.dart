import 'package:koreanhwa_flutter/models/settings_model.dart';

class SettingsService {
  static UserSettings _settings = UserSettings(
    profile: ProfileSettings(
      firstName: 'Nguyễn',
      lastName: 'Văn A',
      email: 'nguyenvana@example.com',
      phone: '0123456789',
      avatar: 'A',
      level: 'Sơ cấp 2',
      goal: 'TOPIK II',
      birthday: '1995-05-15',
      location: 'Hà Nội, Việt Nam',
      bio: 'Học viên tiếng Hàn nhiệt huyết, yêu thích văn hóa Hàn Quốc và K-Pop',
      interests: ['K-Pop', 'Du lịch', 'Nấu ăn', 'Phim Hàn Quốc'],
      studyTime: 'Buổi tối',
      timezone: 'Asia/Ho_Chi_Minh',
    ),
    notifications: NotificationSettings(
      emailNotifications: true,
      pushNotifications: true,
      studyReminders: true,
      competitionUpdates: true,
      blogUpdates: false,
      weeklyReports: true,
      dailyGoals: true,
      streakAlerts: true,
      achievementAlerts: true,
      friendActivity: false,
      soundEnabled: true,
      vibrationEnabled: true,
      quietHours: QuietHours(
        enabled: true,
        start: '22:00',
        end: '07:00',
      ),
    ),
    privacy: PrivacySettings(
      profileVisibility: 'public',
      showProgress: true,
      showAchievements: true,
      allowMessages: true,
      dataSharing: false,
      showOnlineStatus: true,
      allowFriendRequests: true,
      showEmail: false,
      showPhone: false,
      allowAnalytics: true,
    ),
    appearance: AppearanceSettings(
      theme: 'light',
      fontSize: 'medium',
      compactMode: false,
      showAnimations: true,
      colorScheme: 'blue',
      accentColor: '#3B82F6',
      backgroundImage: 'default',
      cardStyle: 'rounded',
      showAvatars: true,
      showIcons: true,
    ),
    language: LanguageSettings(
      interfaceLanguage: 'vi',
      studyLanguage: 'ko',
      subtitles: true,
      pronunciation: 'korean',
      romanization: false,
      translationLanguage: 'vi',
      autoTranslate: true,
      showBothLanguages: true,
    ),
    study: StudySettings(
      dailyGoal: 30,
      weeklyGoal: 180,
      autoPlayAudio: true,
      showHints: true,
      autoSave: true,
      reviewInterval: 7,
      spacedRepetition: true,
      difficultyAdjustment: true,
      focusMode: false,
      studyBreaks: StudyBreaks(
        enabled: true,
        duration: 5,
        interval: 25,
      ),
      learningPath: 'adaptive',
      practiceMode: 'mixed',
      vocabularyLimit: 20,
      grammarFocus: 'balanced',
    ),
    motivation: MotivationSettings(
      streakGoal: 7,
      weeklyChallenges: true,
      achievementDisplay: true,
      progressCelebration: true,
      milestoneRewards: true,
      socialFeatures: true,
      leaderboardParticipation: true,
      customRewards: CustomRewards(
        enabled: true,
        rewards: [
          Reward(id: 1, name: 'Xem phim Hàn Quốc', points: 100, completed: false),
          Reward(id: 2, name: 'Mua sách tiếng Hàn', points: 200, completed: false),
          Reward(id: 3, name: 'Du lịch Hàn Quốc', points: 1000, completed: false),
        ],
      ),
      motivationMessages: MotivationMessages(
        enabled: true,
        frequency: 'daily',
        categories: ['encouragement', 'achievement', 'reminder'],
      ),
      studyStreak: StudyStreak(
        current: 12,
        longest: 25,
        goal: 30,
        rewards: [
          StreakReward(days: 7, achieved: true, reward: 'Huy hiệu 7 ngày'),
          StreakReward(days: 14, achieved: true, reward: 'Huy hiệu 2 tuần'),
          StreakReward(days: 30, achieved: false, reward: 'Huy hiệu 1 tháng'),
          StreakReward(days: 100, achieved: false, reward: 'Huy hiệu 100 ngày'),
        ],
      ),
    ),
  );

  static UserSettings getSettings() {
    return _settings;
  }

  static void updateSettings(UserSettings newSettings) {
    _settings = newSettings;
  }

  static void updateProfile(ProfileSettings profile) {
    _settings = _settings.copyWith(profile: profile);
  }

  static void updateNotifications(NotificationSettings notifications) {
    _settings = _settings.copyWith(notifications: notifications);
  }

  static void updatePrivacy(PrivacySettings privacy) {
    _settings = _settings.copyWith(privacy: privacy);
  }

  static void updateAppearance(AppearanceSettings appearance) {
    _settings = _settings.copyWith(appearance: appearance);
  }

  static void updateLanguage(LanguageSettings language) {
    _settings = _settings.copyWith(language: language);
  }

  static void updateStudy(StudySettings study) {
    _settings = _settings.copyWith(study: study);
  }

  static void updateMotivation(MotivationSettings motivation) {
    _settings = _settings.copyWith(motivation: motivation);
  }

  static void saveSettings() {
    // In real app, save to local storage or backend
  }
}

