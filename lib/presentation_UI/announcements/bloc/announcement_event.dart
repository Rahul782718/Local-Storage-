import 'package:equatable/equatable.dart';

abstract class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();

  @override
  List<Object?> get props => [];
}


class GetAnnouncementRequestedEvent extends AnnouncementEvent {
  final String role;
  const GetAnnouncementRequestedEvent(this.role);

}