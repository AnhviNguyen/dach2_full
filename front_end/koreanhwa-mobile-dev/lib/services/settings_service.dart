import 'dart:convert';
import 'package:koreanhwa_flutter/models/settings_model.dart';
import 'package:koreanhwa_flutter/core/storage/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static UserSettings? _settings;
  
  // Keys for SharedPreferences
  static const String _keySettings = 'user_settings';
  static const String _keyProfile = 'profile_settings';
  static const String _keyNotifications = 'notification_settings';
  static const String _keyAppearance = 'appearance_settings';
  static const String _keyLanguage = 'language_settings';
  static const String _keyMotivation = 'motivation_settings';
  
  static Future<UserSettings> getSettings() async {
    if (_settings != null) return _settings!;
    
    // Load user data from SharedPreferences
    final user = await SharedPreferencesService.getUser();
    if (user != null) {
      final nameParts = user.name.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      _settings = UserSettings(
        profile: ProfileSettings(
          firstName: firstName,
          lastName: lastName,
          email: user.email ?? '',
          phone: '',
          avatar: user.avatar ?? (user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U'),
          level: user.level ?? 'Sơ cấp 1',
          goal: 'TOPIK II',
          birthday: '',
          location: '',
          bio: '',
          interests: [],
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
          streakGoal: user.streakDays ?? 7,
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
            current: user.streakDays ?? 0,
            longest: user.streakDays ?? 0,
            goal: 30,
            rewards: [
              StreakReward(days: 7, achieved: (user.streakDays ?? 0) >= 7, reward: 'Huy hiệu 7 ngày'),
              StreakReward(days: 14, achieved: (user.streakDays ?? 0) >= 14, reward: 'Huy hiệu 2 tuần'),
              StreakReward(days: 30, achieved: (user.streakDays ?? 0) >= 30, reward: 'Huy hiệu 1 tháng'),
              StreakReward(days: 100, achieved: (user.streakDays ?? 0) >= 100, reward: 'Huy hiệu 100 ngày'),
            ],
          ),
        ),
      );
    } else {
      // Default settings if no user data
      _settings = UserSettings(
        profile: ProfileSettings(
          firstName: '',
          lastName: '',
          email: '',
          phone: '',
          avatar: 'U',
          level: 'Sơ cấp 1',
          goal: 'TOPIK II',
          birthday: '',
          location: '',
          bio: '',
          interests: [],
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
            current: 0,
            longest: 0,
            goal: 30,
            rewards: [
              StreakReward(days: 7, achieved: false, reward: 'Huy hiệu 7 ngày'),
              StreakReward(days: 14, achieved: false, reward: 'Huy hiệu 2 tuần'),
              StreakReward(days: 30, achieved: false, reward: 'Huy hiệu 1 tháng'),
              StreakReward(days: 100, achieved: false, reward: 'Huy hiệu 100 ngày'),
            ],
          ),
        ),
      );
    }
    
    // Load saved settings from SharedPreferences
    await _loadSavedSettings();
    
    return _settings!;
  }
  
  // Helper method to load saved settings from SharedPreferences
  static Future<void> _loadSavedSettings() async {
    if (_settings == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Load profile
    final profileJson = prefs.getString(_keyProfile);
    if (profileJson != null) {
      final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
      _settings = _settings!.copyWith(profile: ProfileSettings(
        firstName: profileData['firstName'] ?? _settings!.profile.firstName,
        lastName: profileData['lastName'] ?? _settings!.profile.lastName,
        email: profileData['email'] ?? _settings!.profile.email,
        phone: profileData['phone'] ?? _settings!.profile.phone,
        avatar: profileData['avatar'] ?? _settings!.profile.avatar,
        level: profileData['level'] ?? _settings!.profile.level,
        goal: profileData['goal'] ?? _settings!.profile.goal,
        birthday: profileData['birthday'] ?? _settings!.profile.birthday,
        location: profileData['location'] ?? _settings!.profile.location,
        bio: profileData['bio'] ?? _settings!.profile.bio,
        interests: List<String>.from(profileData['interests'] ?? _settings!.profile.interests),
        studyTime: profileData['studyTime'] ?? _settings!.profile.studyTime,
        timezone: profileData['timezone'] ?? _settings!.profile.timezone,
      ));
    }

    // Load notifications
    final notificationsJson = prefs.getString(_keyNotifications);
    if (notificationsJson != null) {
      final notifData = jsonDecode(notificationsJson) as Map<String, dynamic>;
      final quietHoursData = notifData['quietHours'] as Map<String, dynamic>?;
      _settings = _settings!.copyWith(notifications: NotificationSettings(
        emailNotifications: notifData['emailNotifications'] ?? _settings!.notifications.emailNotifications,
        pushNotifications: notifData['pushNotifications'] ?? _settings!.notifications.pushNotifications,
        studyReminders: notifData['studyReminders'] ?? _settings!.notifications.studyReminders,
        competitionUpdates: notifData['competitionUpdates'] ?? _settings!.notifications.competitionUpdates,
        blogUpdates: notifData['blogUpdates'] ?? _settings!.notifications.blogUpdates,
        weeklyReports: notifData['weeklyReports'] ?? _settings!.notifications.weeklyReports,
        dailyGoals: notifData['dailyGoals'] ?? _settings!.notifications.dailyGoals,
        streakAlerts: notifData['streakAlerts'] ?? _settings!.notifications.streakAlerts,
        achievementAlerts: notifData['achievementAlerts'] ?? _settings!.notifications.achievementAlerts,
        friendActivity: notifData['friendActivity'] ?? _settings!.notifications.friendActivity,
        soundEnabled: notifData['soundEnabled'] ?? _settings!.notifications.soundEnabled,
        vibrationEnabled: notifData['vibrationEnabled'] ?? _settings!.notifications.vibrationEnabled,
        quietHours: QuietHours(
          enabled: quietHoursData?['enabled'] ?? _settings!.notifications.quietHours.enabled,
          start: quietHoursData?['start'] ?? _settings!.notifications.quietHours.start,
          end: quietHoursData?['end'] ?? _settings!.notifications.quietHours.end,
        ),
      ));
    }

    // Load appearance
    final appearanceJson = prefs.getString(_keyAppearance);
    if (appearanceJson != null) {
      final appearData = jsonDecode(appearanceJson) as Map<String, dynamic>;
      _settings = _settings!.copyWith(appearance: AppearanceSettings(
        theme: appearData['theme'] ?? _settings!.appearance.theme,
        fontSize: appearData['fontSize'] ?? _settings!.appearance.fontSize,
        compactMode: appearData['compactMode'] ?? _settings!.appearance.compactMode,
        showAnimations: appearData['showAnimations'] ?? _settings!.appearance.showAnimations,
        colorScheme: appearData['colorScheme'] ?? _settings!.appearance.colorScheme,
        accentColor: appearData['accentColor'] ?? _settings!.appearance.accentColor,
        backgroundImage: appearData['backgroundImage'] ?? _settings!.appearance.backgroundImage,
        cardStyle: appearData['cardStyle'] ?? _settings!.appearance.cardStyle,
        showAvatars: appearData['showAvatars'] ?? _settings!.appearance.showAvatars,
        showIcons: appearData['showIcons'] ?? _settings!.appearance.showIcons,
      ));
    }

    // Load language
    final languageJson = prefs.getString(_keyLanguage);
    if (languageJson != null) {
      final langData = jsonDecode(languageJson) as Map<String, dynamic>;
      _settings = _settings!.copyWith(language: LanguageSettings(
        interfaceLanguage: langData['interfaceLanguage'] ?? _settings!.language.interfaceLanguage,
        studyLanguage: langData['studyLanguage'] ?? _settings!.language.studyLanguage,
        subtitles: langData['subtitles'] ?? _settings!.language.subtitles,
        pronunciation: langData['pronunciation'] ?? _settings!.language.pronunciation,
        romanization: langData['romanization'] ?? _settings!.language.romanization,
        translationLanguage: langData['translationLanguage'] ?? _settings!.language.translationLanguage,
        autoTranslate: langData['autoTranslate'] ?? _settings!.language.autoTranslate,
        showBothLanguages: langData['showBothLanguages'] ?? _settings!.language.showBothLanguages,
      ));
    }

    // Load motivation
    final motivationJson = prefs.getString(_keyMotivation);
    if (motivationJson != null) {
      final motivData = jsonDecode(motivationJson) as Map<String, dynamic>;
      final streakData = motivData['studyStreak'] as Map<String, dynamic>?;
      final currentStreak = streakData?['current'] ?? _settings!.motivation.studyStreak.current;
      final longestStreak = streakData?['longest'] ?? _settings!.motivation.studyStreak.longest;
      final streakGoal = streakData?['goal'] ?? _settings!.motivation.studyStreak.goal;
      
      // Update rewards based on current streak
      final rewards = _settings!.motivation.studyStreak.rewards.map((r) => 
        StreakReward(days: r.days, achieved: currentStreak >= r.days, reward: r.reward)
      ).toList();
      
      _settings = _settings!.copyWith(motivation: MotivationSettings(
        streakGoal: motivData['streakGoal'] ?? _settings!.motivation.streakGoal,
        weeklyChallenges: motivData['weeklyChallenges'] ?? _settings!.motivation.weeklyChallenges,
        achievementDisplay: motivData['achievementDisplay'] ?? _settings!.motivation.achievementDisplay,
        progressCelebration: motivData['progressCelebration'] ?? _settings!.motivation.progressCelebration,
        milestoneRewards: motivData['milestoneRewards'] ?? _settings!.motivation.milestoneRewards,
        socialFeatures: motivData['socialFeatures'] ?? _settings!.motivation.socialFeatures,
        leaderboardParticipation: motivData['leaderboardParticipation'] ?? _settings!.motivation.leaderboardParticipation,
        customRewards: _settings!.motivation.customRewards,
        motivationMessages: _settings!.motivation.motivationMessages,
        studyStreak: StudyStreak(
          current: currentStreak,
          longest: longestStreak,
          goal: streakGoal,
          rewards: rewards,
        ),
      ));
    }
  }

  static void updateSettings(UserSettings newSettings) {
    _settings = newSettings;
  }

  static Future<void> updateProfile(ProfileSettings profile) async {
    _settings = _settings?.copyWith(profile: profile);
    await _saveProfileSettings(profile);
  }

  static Future<void> updateNotifications(NotificationSettings notifications) async {
    _settings = _settings?.copyWith(notifications: notifications);
    await _saveNotificationSettings(notifications);
  }

  static void updatePrivacy(PrivacySettings privacy) {
    _settings = _settings?.copyWith(privacy: privacy);
  }

  static Future<void> updateAppearance(AppearanceSettings appearance) async {
    _settings = _settings?.copyWith(appearance: appearance);
    await _saveAppearanceSettings(appearance);
  }

  static Future<void> updateLanguage(LanguageSettings language) async {
    _settings = _settings?.copyWith(language: language);
    await _saveLanguageSettings(language);
  }

  static void updateStudy(StudySettings study) {
    _settings = _settings?.copyWith(study: study);
  }

  static Future<void> updateMotivation(MotivationSettings motivation) async {
    _settings = _settings?.copyWith(motivation: motivation);
    await _saveMotivationSettings(motivation);
  }

  // Helper methods to save individual settings
  static Future<void> _saveProfileSettings(ProfileSettings profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfile, jsonEncode({
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      'email': profile.email,
      'phone': profile.phone,
      'avatar': profile.avatar,
      'level': profile.level,
      'goal': profile.goal,
      'birthday': profile.birthday,
      'location': profile.location,
      'bio': profile.bio,
      'interests': profile.interests,
      'studyTime': profile.studyTime,
      'timezone': profile.timezone,
    }));
  }

  static Future<void> _saveNotificationSettings(NotificationSettings notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNotifications, jsonEncode({
      'emailNotifications': notifications.emailNotifications,
      'pushNotifications': notifications.pushNotifications,
      'studyReminders': notifications.studyReminders,
      'competitionUpdates': notifications.competitionUpdates,
      'blogUpdates': notifications.blogUpdates,
      'weeklyReports': notifications.weeklyReports,
      'dailyGoals': notifications.dailyGoals,
      'streakAlerts': notifications.streakAlerts,
      'achievementAlerts': notifications.achievementAlerts,
      'friendActivity': notifications.friendActivity,
      'soundEnabled': notifications.soundEnabled,
      'vibrationEnabled': notifications.vibrationEnabled,
      'quietHours': {
        'enabled': notifications.quietHours.enabled,
        'start': notifications.quietHours.start,
        'end': notifications.quietHours.end,
      },
    }));
  }

  static Future<void> _saveAppearanceSettings(AppearanceSettings appearance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppearance, jsonEncode({
      'theme': appearance.theme,
      'fontSize': appearance.fontSize,
      'compactMode': appearance.compactMode,
      'showAnimations': appearance.showAnimations,
      'colorScheme': appearance.colorScheme,
      'accentColor': appearance.accentColor,
      'backgroundImage': appearance.backgroundImage,
      'cardStyle': appearance.cardStyle,
      'showAvatars': appearance.showAvatars,
      'showIcons': appearance.showIcons,
    }));
  }

  static Future<void> _saveLanguageSettings(LanguageSettings language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, jsonEncode({
      'interfaceLanguage': language.interfaceLanguage,
      'studyLanguage': language.studyLanguage,
      'subtitles': language.subtitles,
      'pronunciation': language.pronunciation,
      'romanization': language.romanization,
      'translationLanguage': language.translationLanguage,
      'autoTranslate': language.autoTranslate,
      'showBothLanguages': language.showBothLanguages,
    }));
  }

  static Future<void> _saveMotivationSettings(MotivationSettings motivation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMotivation, jsonEncode({
      'streakGoal': motivation.streakGoal,
      'weeklyChallenges': motivation.weeklyChallenges,
      'achievementDisplay': motivation.achievementDisplay,
      'progressCelebration': motivation.progressCelebration,
      'milestoneRewards': motivation.milestoneRewards,
      'socialFeatures': motivation.socialFeatures,
      'leaderboardParticipation': motivation.leaderboardParticipation,
      'studyStreak': {
        'current': motivation.studyStreak.current,
        'longest': motivation.studyStreak.longest,
        'goal': motivation.studyStreak.goal,
      },
    }));
  }

  static void saveSettings() {
    // In real app, save to local storage or backend
  }
}
