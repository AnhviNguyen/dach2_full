import 'package:koreanhwa_flutter/models/material_model.dart';

class MaterialService {
  static int _userPoints = 1250;

  static int get userPoints => _userPoints;

  static void deductPoints(int points) {
    _userPoints -= points;
  }

  static List<LearningMaterial> _materials = [
    LearningMaterial(
      id: 1,
      title: 'Từ vựng cơ bản TOPIK I',
      description: 'Bộ từ vựng cơ bản cho kỳ thi TOPIK I, bao gồm 500 từ thường gặp nhất',
      type: 'pdf',
      skill: 'vocabulary',
      level: 'beginner',
      points: 50,
      downloads: 1240,
      rating: 4.8,
      size: '2.5 MB',
      duration: null,
      thumbnail: '📚',
      isDownloaded: false,
      isFeatured: true,
      pdfUrl: 'https://kanata.edu.vn/wp-content/uploads/2022/10/Giao-trinh-Tieng-Han-Tong-hop-so-cap-1.pdf',
    ),
    LearningMaterial(
      id: 2,
      title: 'Luyện nghe cơ bản - Bài 1-10',
      description: '10 bài luyện nghe cơ bản với file audio và transcript',
      type: 'audio',
      skill: 'listening',
      level: 'beginner',
      points: 75,
      downloads: 890,
      rating: 4.6,
      size: '45 MB',
      duration: '2 giờ 30 phút',
      thumbnail: '🎧',
      isDownloaded: true,
      isFeatured: false,
    ),
    LearningMaterial(
      id: 3,
      title: 'Ngữ pháp trung cấp - Phần 1',
      description: 'Tài liệu ngữ pháp trung cấp với ví dụ và bài tập',
      type: 'pdf',
      skill: 'grammar',
      level: 'intermediate',
      points: 100,
      downloads: 567,
      rating: 4.9,
      size: '3.2 MB',
      duration: null,
      thumbnail: '📖',
      isDownloaded: false,
      isFeatured: false,
    ),
    LearningMaterial(
      id: 4,
      title: 'Video bài giảng - Giao tiếp hàng ngày',
      description: 'Video bài giảng về các tình huống giao tiếp thường gặp',
      type: 'video',
      skill: 'speaking',
      level: 'intermediate',
      points: 120,
      downloads: 432,
      rating: 4.7,
      size: '156 MB',
      duration: '1 giờ 45 phút',
      thumbnail: '🎥',
      isDownloaded: false,
      isFeatured: true,
    ),
    LearningMaterial(
      id: 5,
      title: 'Bài tập viết TOPIK II',
      description: 'Bộ bài tập viết cho kỳ thi TOPIK II với đáp án chi tiết',
      type: 'pdf',
      skill: 'writing',
      level: 'advanced',
      points: 150,
      downloads: 234,
      rating: 4.5,
      size: '4.1 MB',
      duration: null,
      thumbnail: '✍️',
      isDownloaded: false,
      isFeatured: false,
    ),
    LearningMaterial(
      id: 6,
      title: 'Audio luyện phát âm chuẩn',
      description: 'File audio luyện phát âm với hướng dẫn chi tiết',
      type: 'audio',
      skill: 'speaking',
      level: 'beginner',
      points: 60,
      downloads: 678,
      rating: 4.8,
      size: '28 MB',
      duration: '1 giờ 15 phút',
      thumbnail: '🎤',
      isDownloaded: false,
      isFeatured: false,
    ),
  ];

  static List<LearningMaterial> getMaterials({
    String? level,
    String? skill,
    String? type,
    String? searchQuery,
  }) {
    var filtered = List<LearningMaterial>.from(_materials);

    if (level != null && level != 'all') {
      filtered = filtered.where((m) => m.level == level).toList();
    }

    if (skill != null && skill != 'all') {
      filtered = filtered.where((m) => m.skill == skill).toList();
    }

    if (type != null && type != 'all') {
      filtered = filtered.where((m) => m.type == type).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((m) {
        return m.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            m.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  static LearningMaterial? getMaterialById(int id) {
    try {
      return _materials.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<LearningMaterial> getFeaturedMaterials() {
    return _materials.where((m) => m.isFeatured).toList();
  }

  static List<LearningMaterial> getDownloadedMaterials() {
    return _materials.where((m) => m.isDownloaded).toList();
  }

  static bool downloadMaterial(int id) {
    final material = getMaterialById(id);
    if (material == null || _userPoints < material.points) {
      return false;
    }

    deductPoints(material.points);
    final index = _materials.indexWhere((m) => m.id == id);
    if (index != -1) {
      _materials[index] = LearningMaterial(
        id: _materials[index].id,
        title: _materials[index].title,
        description: _materials[index].description,
        type: _materials[index].type,
        skill: _materials[index].skill,
        level: _materials[index].level,
        points: _materials[index].points,
        downloads: _materials[index].downloads + 1,
        rating: _materials[index].rating,
        size: _materials[index].size,
        duration: _materials[index].duration,
        thumbnail: _materials[index].thumbnail,
        isDownloaded: true,
        isFeatured: _materials[index].isFeatured,
        pdfUrl: _materials[index].pdfUrl,
      );
    }
    return true;
  }

  static String getSkillName(String skill) {
    switch (skill) {
      case 'listening':
        return 'Nghe';
      case 'speaking':
        return 'Nói';
      case 'reading':
        return 'Đọc';
      case 'writing':
        return 'Viết';
      case 'vocabulary':
        return 'Từ vựng';
      case 'grammar':
        return 'Ngữ pháp';
      default:
        return 'Tất cả';
    }
  }

  static String getLevelName(String level) {
    switch (level) {
      case 'beginner':
        return 'Sơ cấp';
      case 'intermediate':
        return 'Trung cấp';
      case 'advanced':
        return 'Cao cấp';
      default:
        return 'Tất cả';
    }
  }

  static String getTypeName(String type) {
    switch (type) {
      case 'pdf':
        return 'PDF';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'lesson':
        return 'Bài giảng';
      default:
        return 'Tất cả';
    }
  }
}

