class UserSettings {
  final ProfileSettings profile;
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final AppearanceSettings appearance;
  final LanguageSettings language;
  final StudySettings study;
  final MotivationSettings motivation;

  UserSettings({
    required this.profile,
    required this.notifications,
    required this.privacy,
    required this.appearance,
    required this.language,
    required this.study,
    required this.motivation,
  });

  UserSettings copyWith({
    ProfileSettings? profile,
    NotificationSettings? notifications,
    PrivacySettings? privacy,
    AppearanceSettings? appearance,
    LanguageSettings? language,
    StudySettings? study,
    MotivationSettings? motivation,
  }) {
    return UserSettings(
      profile: profile ?? this.profile,
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
      appearance: appearance ?? this.appearance,
      language: language ?? this.language,
      study: study ?? this.study,
      motivation: motivation ?? this.motivation,
    );
  }
}

class ProfileSettings {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String avatar;
  final String level;
  final String goal;
  final String birthday;
  final String location;
  final String bio;
  final List<String> interests;
  final String studyTime;
  final String timezone;

  ProfileSettings({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.level,
    required this.goal,
    required this.birthday,
    required this.location,
    required this.bio,
    required this.interests,
    required this.studyTime,
    required this.timezone,
  });
}

class NotificationSettings {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool studyReminders;
  final bool competitionUpdates;
  final bool blogUpdates;
  final bool weeklyReports;
  final bool dailyGoals;
  final bool streakAlerts;
  final bool achievementAlerts;
  final bool friendActivity;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final QuietHours quietHours;

  NotificationSettings({
    required this.emailNotifications,
    required this.pushNotifications,
    required this.studyReminders,
    required this.competitionUpdates,
    required this.blogUpdates,
    required this.weeklyReports,
    required this.dailyGoals,
    required this.streakAlerts,
    required this.achievementAlerts,
    required this.friendActivity,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.quietHours,
  });
}

class QuietHours {
  final bool enabled;
  final String start;
  final String end;

  QuietHours({
    required this.enabled,
    required this.start,
    required this.end,
  });
}

class PrivacySettings {
  final String profileVisibility;
  final bool showProgress;
  final bool showAchievements;
  final bool allowMessages;
  final bool dataSharing;
  final bool showOnlineStatus;
  final bool allowFriendRequests;
  final bool showEmail;
  final bool showPhone;
  final bool allowAnalytics;

  PrivacySettings({
    required this.profileVisibility,
    required this.showProgress,
    required this.showAchievements,
    required this.allowMessages,
    required this.dataSharing,
    required this.showOnlineStatus,
    required this.allowFriendRequests,
    required this.showEmail,
    required this.showPhone,
    required this.allowAnalytics,
  });
}

class AppearanceSettings {
  final String theme;
  final String fontSize;
  final bool compactMode;
  final bool showAnimations;
  final String colorScheme;
  final String accentColor;
  final String backgroundImage;
  final String cardStyle;
  final bool showAvatars;
  final bool showIcons;

  AppearanceSettings({
    required this.theme,
    required this.fontSize,
    required this.compactMode,
    required this.showAnimations,
    required this.colorScheme,
    required this.accentColor,
    required this.backgroundImage,
    required this.cardStyle,
    required this.showAvatars,
    required this.showIcons,
  });
}

class LanguageSettings {
  final String interfaceLanguage;
  final String studyLanguage;
  final bool subtitles;
  final String pronunciation;
  final bool romanization;
  final String translationLanguage;
  final bool autoTranslate;
  final bool showBothLanguages;

  LanguageSettings({
    required this.interfaceLanguage,
    required this.studyLanguage,
    required this.subtitles,
    required this.pronunciation,
    required this.romanization,
    required this.translationLanguage,
    required this.autoTranslate,
    required this.showBothLanguages,
  });
}

class StudySettings {
  final int dailyGoal;
  final int weeklyGoal;
  final bool autoPlayAudio;
  final bool showHints;
  final bool autoSave;
  final int reviewInterval;
  final bool spacedRepetition;
  final bool difficultyAdjustment;
  final bool focusMode;
  final StudyBreaks studyBreaks;
  final String learningPath;
  final String practiceMode;
  final int vocabularyLimit;
  final String grammarFocus;

  StudySettings({
    required this.dailyGoal,
    required this.weeklyGoal,
    required this.autoPlayAudio,
    required this.showHints,
    required this.autoSave,
    required this.reviewInterval,
    required this.spacedRepetition,
    required this.difficultyAdjustment,
    required this.focusMode,
    required this.studyBreaks,
    required this.learningPath,
    required this.practiceMode,
    required this.vocabularyLimit,
    required this.grammarFocus,
  });
}

class StudyBreaks {
  final bool enabled;
  final int duration;
  final int interval;

  StudyBreaks({
    required this.enabled,
    required this.duration,
    required this.interval,
  });
}

class MotivationSettings {
  final int streakGoal;
  final bool weeklyChallenges;
  final bool achievementDisplay;
  final bool progressCelebration;
  final bool milestoneRewards;
  final bool socialFeatures;
  final bool leaderboardParticipation;
  final CustomRewards customRewards;
  final MotivationMessages motivationMessages;
  final StudyStreak studyStreak;

  MotivationSettings({
    required this.streakGoal,
    required this.weeklyChallenges,
    required this.achievementDisplay,
    required this.progressCelebration,
    required this.milestoneRewards,
    required this.socialFeatures,
    required this.leaderboardParticipation,
    required this.customRewards,
    required this.motivationMessages,
    required this.studyStreak,
  });
}

class CustomRewards {
  final bool enabled;
  final List<Reward> rewards;

  CustomRewards({
    required this.enabled,
    required this.rewards,
  });
}

class Reward {
  final int id;
  final String name;
  final int points;
  final bool completed;

  Reward({
    required this.id,
    required this.name,
    required this.points,
    required this.completed,
  });
}

class MotivationMessages {
  final bool enabled;
  final String frequency;
  final List<String> categories;

  MotivationMessages({
    required this.enabled,
    required this.frequency,
    required this.categories,
  });
}

class StudyStreak {
  final int current;
  final int longest;
  final int goal;
  final List<StreakReward> rewards;

  StudyStreak({
    required this.current,
    required this.longest,
    required this.goal,
    required this.rewards,
  });
}

class StreakReward {
  final int days;
  final bool achieved;
  final String reward;

  StreakReward({
    required this.days,
    required this.achieved,
    required this.reward,
  });
}

