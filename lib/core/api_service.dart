import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:local_storage/core/storage/storage_service.dart';

import 'network/NetworkInfo.dart';

class Api_Service {
  final Dio dio;
  final NetworkInfo networkInfo;
  final SecureStorageService secureStorageService;

  Api_Service(this.dio, this.networkInfo, this.secureStorageService);

  /// Makes POST request and returns JSON map
  Future<Map<String, dynamic>> post(
      String path,
      Map<String, dynamic> body,
      ) async {
    await _checkConnection();
    try {
      debugPrint('🚀 POST → $path');
      debugPrint('📤 Body: $body');

      final token = await secureStorageService.getToken();
      debugPrint('🔑 Token: $token');

      final response = await dio.post(
        path,
        data: body,
        options: Options(
          headers: {
            "Accept": "application/json",
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint('🔑 Resposne: $response');

      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e, path);
    }
  }

  /// Makes GET request and returns JSON map
  Future<Map<String, dynamic>> get(
      String path, {
        Map<String, dynamic>? queryParams,
      }) async {
    await _checkConnection();
    try {
      debugPrint('🚀 GET → $path');
      debugPrint('🔍 QueryParams: $queryParams');

      final token = await secureStorageService.getToken();
      debugPrint('🔑 Token: $token');

      final response = await dio.get(
        path,
        queryParameters: queryParams,
        options: Options(
          headers: {
            "Accept": "application/json", // FIX 1
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint(
        "--------------------------------- Core Response data ----------------------------------------",
      );

      debugPrint("core Response data :${response.data}");
      debugPrint("core Response Status Code  :${response.statusCode}");
      debugPrint("core Response Status Message :${response.statusMessage}");

      debugPrint(
        "--------------------------------- END ----------------------------------------",
      );

      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e, path);
    }
  }

  /// Makes Multipart POST request for file upload + fields
  Future<Map<String, dynamic>> postMultipart(
      String path,
      Map<String, dynamic> fields, {
        File? file,
        String fileFieldName = "profile_image",
      }) async {
    await _checkConnection();
    try {
      debugPrint('🚀 Multipart POST → $path');
      debugPrint('📤 Fields: $fields');

      final token = await secureStorageService.getToken();
      debugPrint('🔑 Token: $token');

      final formData = FormData.fromMap({
        ...fields,
        if (file != null)
          fileFieldName: await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
      });

      final response = await dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json", // FIX 1
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint(
        "---------------------------------core Response data ----------------------------------------",
      );

      debugPrint("core Response data :${response.data}");
      debugPrint("core Response Status Code  :${response.statusCode}");
      debugPrint("core Response Status Message :${response.statusMessage}");

      debugPrint(
        "---------------------------------END ----------------------------------------",
      );

      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e, path);
    }
  }

  /// Internet check
  Future<void> _checkConnection() async {
    if (!await networkInfo.isConnected) {
      throw NetworkFailure('No internet connection 🌐❌');
    }
  }

  /// Handles successful responses
  Map<String, dynamic> _processResponse(Response response) {
    dynamic rawData = response.data;
    if (rawData is String) {
      rawData = json.decode(rawData);
    }

    // 🔥 FIX 2 – If somehow backend returns 200 but includes 401 message
    if (response.statusCode == 401) {
      throw UnAuthorizedFailure("Unauthenticated");
    }

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      if (rawData is Map<String, dynamic>) {
        return {
          "success": rawData["success"] ?? true,
          "message": rawData["message"]?.toString() ?? "Success 🎉",
          "data": rawData["data"] ?? [],
        };
      } else {
        return {"success": true, "message": "Success 🎉", "data": rawData};
      }
    } else {
      throw ServerFailure(
        (rawData is Map && rawData['message'] != null)
            ? rawData['message'].toString()
            : "Server error 🚨 [${response.statusCode}]",
      );
    }
  }

  /// Handles Dio errors and throws Failures
  Failure _handleDioError(DioException e, String path) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    debugPrint("🔥 ERROR → $path");
    debugPrint("📡 Status Code: $status");
    debugPrint("📥 Response: ${e.response?.data}");

    // FIX 3 — Correct Unauthorized handling
    // if (status == 401) {
    //   return UnAuthorizedFailure("Unauthenticated");
    // }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return TimeoutFailure("Connection timeout ⏳");
    }

    if (e.type == DioExceptionType.connectionError) {
      return NetworkFailure("No internet connection 🌐❌");
    }

    if (e.type == DioExceptionType.cancel) {
      return RequestCancelledFailure("Request cancelled ❌");
    }

    if (e.type == DioExceptionType.badResponse) {
      String message = "Server error 🚨 [$status]";

      if (data is Map<String, dynamic>) {
        message =
            data["message"]?.toString() ?? data["error"]?.toString() ?? message;
      }

      return ServerFailure(message);
    }

    return UnknownFailure(e.message ?? "Unexpected error ⚠️");
  }
}

/// Base class for all Failures
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// No Internet Connection
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Server error (5xx, 4xx, etc.)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Request timed out
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message);
}

/// Request was cancelled manually
class RequestCancelledFailure extends Failure {
  const RequestCancelledFailure(super.message);
}

/// Unknown / unexpected error
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

class UnAuthorizedFailure extends Failure {
  UnAuthorizedFailure(super.message);

  @override
  String toString() => "UnAuthorizedFailure($message)";
}