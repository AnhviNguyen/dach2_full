import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/services/app_usage_service.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';

/// Widget wrapper để bọc app và tự động tracking usage
class UsageTrackerWrapper extends StatefulWidget {
  final Widget child;

  const UsageTrackerWrapper({
    super.key,
    required this.child,
  });

  @override
  State<UsageTrackerWrapper> createState() => _UsageTrackerWrapperState();
}

class _UsageTrackerWrapperState extends State<UsageTrackerWrapper> {
  final AppUsageService _usageService = AppUsageService.instance;

  @override
  void initState() {
    super.initState();
    // Initialize in background, don't block UI
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Start tracking
      await _usageService.startTracking();
    } catch (e) {
      // Log error but don't block app
      debugPrint('Error initializing UsageTrackerWrapper: $e');
    }
  }

  @override
  void dispose() {
    _usageService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always return child, initialize in background
    return widget.child;
  }
}

