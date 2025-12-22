import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage/core/service_loactor.dart';

import '../presentation_UI/announcements/bloc/announcement_bloc.dart';

class Multi_Bloc_Wrapper extends StatelessWidget {
  final Widget child;
  const Multi_Bloc_Wrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [

          BlocProvider<AnnouncementBloc>(
            create:
                (_) => sl<AnnouncementBloc>(), // fire on startup
          ),

        ], child: child,
    );
  }
}