import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'SyncService.dart';

class AutoSyncService {
  static final AutoSyncService _instance = AutoSyncService._internal();
  factory AutoSyncService() => _instance;
  AutoSyncService._internal();

  final SyncService _syncService = GetIt.instance<SyncService>();
  final Connectivity _connectivity = GetIt.instance<Connectivity>();
  StreamSubscription? _subscription;
  Timer? _timer;
  bool _isSyncing = false;

  void init() {
    print('🚀 AutoSyncService started');

    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && !_isSyncing) {
        print('🌐 Connected → Auto sync');
        _triggerSync();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 2), _triggerSync);
    });
  }

  Future<void> _triggerSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      await _syncService.syncPendingChanges();
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _timer?.cancel();
  }
}
