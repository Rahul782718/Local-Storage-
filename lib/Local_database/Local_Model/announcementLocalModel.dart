import '../../data/models/AnnouncementView_Model.dart';
import '../../domain/entities/announcementViewEntity.dart';

class AnnouncementLocalModel {
  final int id;
  final String title;
  final String description;
  final int acknowledge;
  final String? fileUrl;
  final String imageUrl;
  final bool isDirty;
  final String? operationType;
  final DateTime updatedAt;
  final String syncStatus;

  AnnouncementLocalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.acknowledge,
    this.fileUrl,
    required this.imageUrl,
    this.isDirty = false,
    this.operationType,
    required this.updatedAt,
    this.syncStatus = 'synced',
  });

  factory AnnouncementLocalModel.fromMap(Map<String, dynamic> map) => AnnouncementLocalModel(
    id: map['id'] ?? 0,
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    acknowledge: map['acknowledge'] ?? 0,
    fileUrl: map['file_url'],
    imageUrl: map['image_url'] ?? '',
    isDirty: (map['is_dirty'] ?? 0) == 1,
    operationType: map['operation_type'],
    updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    syncStatus: map['sync_status'] ?? 'synced',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'acknowledge': acknowledge,
    'file_url': fileUrl,
    'image_url': imageUrl,
    'is_dirty': isDirty ? 1 : 0,
    'operation_type': operationType,
    'updated_at': updatedAt.toIso8601String(),
    'sync_status': syncStatus,
  };

  AnnouncementView toEntity() => AnnouncementView(
    id: id,
    title: title,
    description: description,
    acknowledge: acknowledge,
    fileUrl: fileUrl,
    imageUrl: imageUrl,
  );
}
