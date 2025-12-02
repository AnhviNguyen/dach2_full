import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:koreanhwa_flutter/services/notification_service.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';

/// Service để tracking thời gian sử dụng app và tính streak
class AppUsageService extends WidgetsBindingObserver {
  static AppUsageService? _instance;
  static AppUsageService get instance {
    _instance ??= AppUsageService._internal();
    return _instance!;
  }

  AppUsageService._internal() {
    // Initialize in background, don't block
    _initialize().catchError((error) {
      // Log error but don't crash
      debugPrint('Error initializing AppUsageService: $error');
    });
  }

  // SharedPreferences keys
  static const String _keyTodayUsageSeconds = 'today_usage_seconds';
  static const String _keyCurrentStreak = 'current_streak';
  static const String _keyLastCompletionDate = 'last_completion_date';
  static const String _keyTrackingDate = 'tracking_date';
  static const String _keyLongestStreak = 'longest_streak';

  // State
  DateTime? _appResumedTime;
  Timer? _usageTimer;
  final ValueNotifier<int> _todayUsageSeconds = ValueNotifier<int>(0);
  final ValueNotifier<int> _currentStreak = ValueNotifier<int>(0);
  final ValueNotifier<int> _longestStreak = ValueNotifier<int>(0);
  bool _isTracking = false;

  // Getters
  ValueNotifier<int> get todayUsageSeconds => _todayUsageSeconds;
  ValueNotifier<int> get currentStreak => _currentStreak;
  ValueNotifier<int> get longestStreak => _longestStreak;

  Future<void> _initialize() async {
    try {
      await _loadFromStorage();
      // Only add observer if binding is available
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance.addObserver(this);
      }
    } catch (e) {
      debugPrint('Error in AppUsageService._initialize: $e');
    }
  }

  /// Load data from SharedPreferences
  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    _todayUsageSeconds.value = prefs.getInt(_keyTodayUsageSeconds) ?? 0;
    _currentStreak.value = prefs.getInt(_keyCurrentStreak) ?? 0;
    _longestStreak.value = prefs.getInt(_keyLongestStreak) ?? 0;

    // Check if we need to reset for new day
    await _checkAndResetForNewDay();
  }

  /// Save data to SharedPreferences
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTodayUsageSeconds, _todayUsageSeconds.value);
    await prefs.setInt(_keyCurrentStreak, _currentStreak.value);
    await prefs.setInt(_keyLongestStreak, _longestStreak.value);
  }

  /// Format date to yyyy-MM-dd string
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Parse date from yyyy-MM-dd string
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    } catch (e) {
      // Invalid date format
    }
    return null;
  }

  /// Check and reset if it's a new day
  Future<void> _checkAndResetForNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDate(DateTime.now());
    final trackingDate = prefs.getString(_keyTrackingDate);

    if (trackingDate != today) {
      // New day - reset today's usage
      _todayUsageSeconds.value = 0;
      await prefs.setString(_keyTrackingDate, today);
      await _saveToStorage();
    }
  }

  /// Start tracking app usage
  Future<void> startTracking() async {
    if (_isTracking) return;

    // Check for new day first
    await _checkAndResetForNewDay();

    _isTracking = true;
    _appResumedTime = DateTime.now();

    // Start timer to update usage every second
    _usageTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_isTracking || _appResumedTime == null) {
        timer.cancel();
        return;
      }

      // Increment by 1 second each tick
      _todayUsageSeconds.value += 1;
      _appResumedTime = DateTime.now(); // Update for next check
      await _saveToStorage();

      // Check if goal reached and update streak
      await _checkGoalAndUpdateStreak();
    });
  }

  /// Stop tracking app usage
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    _isTracking = false;
    _usageTimer?.cancel();
    _usageTimer = null;

    // Final check if goal reached before stopping
    if (_appResumedTime != null) {
      await _checkGoalAndUpdateStreak();
      _appResumedTime = null;
    }
  }

  /// Check if daily goal is reached and update streak
  Future<void> _checkGoalAndUpdateStreak() async {
    // Get daily goal from settings (in minutes, convert to seconds)
    final settings = await SettingsService.getSettings();
    final dailyGoalMinutes = settings.study.dailyGoal;
    final dailyGoalSeconds = dailyGoalMinutes * 60;

    // Check if goal reached
    if (_todayUsageSeconds.value >= dailyGoalSeconds) {
      // Update streak first (returns true if updated, false if already completed today)
      final streakUpdated = await _updateStreak();
      
      // Only show notification and cancel reminder if streak was updated (first time today)
      if (streakUpdated) {
        await _handleGoalReached();
      }
    }
  }

  /// Update streak based on completion date
  /// Returns true if streak was updated, false if already completed today
  Future<bool> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final todayStr = _formatDate(today);
    final yesterdayStr = _formatDate(yesterday);

    final lastCompletionDateStr = prefs.getString(_keyLastCompletionDate);
    final lastCompletionDate = _parseDate(lastCompletionDateStr);

    // Case 3: Already completed today - do nothing
    if (lastCompletionDate != null && _formatDate(lastCompletionDate) == todayStr) {
      return false;
    }

    // Case 1: Completed yesterday - increment streak
    if (lastCompletionDate != null && _formatDate(lastCompletionDate) == yesterdayStr) {
      _currentStreak.value += 1;
    }
    // Case 2: Missed a day or first time - reset to 1
    else {
      _currentStreak.value = 1;
    }

    // Update longest streak
    if (_currentStreak.value > _longestStreak.value) {
      _longestStreak.value = _currentStreak.value;
    }

    // Save completion date
    await prefs.setString(_keyLastCompletionDate, todayStr);
    await _saveToStorage();
    return true;
  }

  /// Handle when daily goal is reached (called only when streak is updated)
  Future<void> _handleGoalReached() async {
    // Show celebration notification with current streak
    await NotificationService.showNotification(
      title: '🎉 Xuất sắc!',
      body: 'Bạn đã hoàn thành mục tiêu ngày và đạt Streak ${_currentStreak.value} ngày!',
    );
  }

  /// Get current usage in minutes
  int getTodayUsageMinutes() {
    return (_todayUsageSeconds.value / 60).floor();
  }

  /// Get current usage in seconds
  int getTodayUsageSeconds() {
    return _todayUsageSeconds.value;
  }

  /// Get current streak
  int getCurrentStreak() {
    return _currentStreak.value;
  }

  /// Get longest streak
  int getLongestStreak() {
    return _longestStreak.value;
  }

  /// WidgetsBindingObserver callbacks
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        startTracking();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        stopTracking();
        break;
      case AppLifecycleState.hidden:
        // Do nothing
        break;
    }
  }

  /// Dispose resources
  void dispose() {
    _usageTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _todayUsageSeconds.dispose();
    _currentStreak.dispose();
    _longestStreak.dispose();
  }
}

