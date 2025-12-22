import 'package:equatable/equatable.dart';


import '../../../domain/entities/announcementViewEntity.dart';

abstract class AnnouncementState extends Equatable {
  const AnnouncementState();

  @override
  List<Object?> get props => [];
}



class AnnouncementInitial extends AnnouncementState {
  const AnnouncementInitial();
}




///---------------------Get Announcement

class GetAnnouncementLoading extends AnnouncementState {
  const GetAnnouncementLoading();
}

class GetAnnouncementSuccess extends AnnouncementState {
  final AnnouncementViewEntity response;
  const GetAnnouncementSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class GetAnnouncementError extends AnnouncementState {
  final String error;
  const GetAnnouncementError(this.error);
}