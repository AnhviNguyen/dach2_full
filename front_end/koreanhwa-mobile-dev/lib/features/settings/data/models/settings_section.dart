import 'package:flutter/material.dart';

enum SettingsSectionType {
  inline,
  page,
}

class SettingsSection {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final SettingsSectionType type;
  final Widget Function() builder;

  const SettingsSection({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.builder,
  });
}
