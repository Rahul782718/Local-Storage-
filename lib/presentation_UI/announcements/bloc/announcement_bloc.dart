import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../domain/usecases/getAnnouncementView_UseCase.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  // final CreateAnnouncementUseCase _announcementUseCase;
  final GetAnnouncementViewUseCase _getAnnouncementViewUseCase;

  AnnouncementBloc(
      // this._announcementUseCase,

      this._getAnnouncementViewUseCase)
      : super(const AnnouncementInitial()) {
    // on<AnnouncementRequestedEvent>(_announcement);
    on<GetAnnouncementRequestedEvent>(_getAnnouncementView);
  }


  FutureOr<void> _getAnnouncementView(
      GetAnnouncementRequestedEvent event,
      Emitter<AnnouncementState> emit)async {
    emit(GetAnnouncementLoading());
    try{
      final result = await _getAnnouncementViewUseCase(event.role);
      debugPrint("GetAnnouncement response  :${result.data.length}");
      emit(GetAnnouncementSuccess(result));

    }catch (e){
      debugPrint("Error GetAnnouncement :  $e");
      emit(GetAnnouncementError(e.toString()));
    }
  }
}
