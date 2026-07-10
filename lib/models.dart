import 'package:flutter/material.dart';

class ProjectItem {
  final String title;
  final String description;
  final String subtitle;
  final List<String> technologies;
  final String demoType; // 'compiler', 'vehicle', '6g'
  final IconData icon;

  const ProjectItem({
    required this.title,
    required this.description,
    required this.subtitle,
    required this.technologies,
    required this.demoType,
    required this.icon,
  });
}

class ExperienceItem {
  final String role;
  final String company;
  final String location;
  final String duration;
  final List<String> details;
  final IconData icon;

  const ExperienceItem({
    required this.role,
    required this.company,
    required this.location,
    required this.duration,
    required this.details,
    required this.icon,
  });
}

class SkillCategory {
  final String name;
  final IconData icon;
  final List<String> skills;
  final String description;

  const SkillCategory({
    required this.name,
    required this.icon,
    required this.skills,
    required this.description,
  });
}
