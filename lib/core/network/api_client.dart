import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  final http.Client _httpClient;
  final Duration timeoutDuration;

  // Global Auth callbacks & token access
  static String? currentAccessToken;
  static String? currentRefreshToken;
  static Future<bool> Function()? onTokenRefreshRequested;
  static void Function()? onSessionExpired;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  ApiClient({
    http.Client? httpClient,
    this.timeoutDuration = const Duration(seconds: 15),
  }) : _httpClient = httpClient ?? http.Client();

  String _maskSecret(String text) {
    if (text.isEmpty) return text;
    return text.replaceAllMapped(
      RegExp(r'Bearer\s+([A-Za-z0-9\-\._~\+\/]+=*)', caseSensitive: false),
      (match) {
        final token = match.group(1) ?? '';
        if (token.length > 10) {
          return 'Bearer ${token.substring(0, 6)}...REDACTED';
        }
        return 'Bearer REDACTED';
      },
    ).replaceAllMapped(
      RegExp(r'"(password|refreshToken|accessToken|secret|dbPassword|jdbcUrl|databasePassword|db_password)"\s*:\s*"([^"]+)"', caseSensitive: false),
      (match) {
        final key = match.group(1);
        final val = match.group(2) ?? '';
        final maskedVal = val.length > 6 ? '${val.substring(0, 4)}...REDACTED' : 'REDACTED';
        return '"$key": "$maskedVal"';
      },
    );
  }

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?customHeaders,
    };

    if (currentAccessToken != null && currentAccessToken!.isNotEmpty) {
      String cleanToken = currentAccessToken!.trim();
      while (cleanToken.toLowerCase().startsWith('bearer ')) {
        cleanToken = cleanToken.substring(7).trim();
      }
      headers['Authorization'] = 'Bearer $cleanToken';
    }

    return headers;
  }

  Future<dynamic> get(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool retryOnAuthError = true,
  }) async {
    try {
      log("GET : $url", name: 'ApiClient');
      debugPrint("[API REQUEST] GET $url");
      Uri uri = Uri.parse(url);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final query = <String, String>{};
        queryParameters.forEach((key, value) {
          if (value != null) {
            query[key] = value.toString();
          }
        });
        uri = uri.replace(queryParameters: {...uri.queryParameters, ...query});
      }

      final response = await _httpClient
          .get(uri, headers: _buildHeaders(headers))
          .timeout(timeoutDuration);

      if (response.statusCode == 401 && retryOnAuthError) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          return get(
            url,
            headers: headers,
            queryParameters: queryParameters,
            retryOnAuthError: false,
          );
        }
      }

      return _processResponse(response);
    } on SocketException catch (e) {
      log("API SocketException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] SocketException for $url: $e");
      throw ApiException(
        message:
            'No connection to server. Please check your network or backend service.',
      );
    } on TimeoutException catch (e) {
      log("API TimeoutException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] TimeoutException for $url: $e");
      throw ApiException(
        message: 'Connection timed out. Server took too long to respond.',
      );
    } on FormatException catch (e) {
      log("API FormatException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] FormatException for $url: $e");
      throw ApiException(
        message: 'Invalid response format received from server.',
      );
    } catch (e) {
      _handleCatch(url, e);
    }
  }

  Never _handleCatch(String url, dynamic e) {
    if (e is ApiException) throw e;
    final errorStr = e.toString();
    log("API Error for $url: $errorStr", name: 'ApiClient');
    debugPrint("[API ERROR] Error for $url: $errorStr");

    if (errorStr.contains('Failed to fetch')) {
      throw ApiException(
        message: 'Unable to connect to backend server. Please verify Tomcat deployment and CORS/HTTP connectivity.',
      );
    }
    throw ApiException(message: 'Network error: $e');
  }

  Future<dynamic> post(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool retryOnAuthError = true,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      log("POST : $url", name: 'ApiClient');
      if (body != null) log("Body : ${jsonEncode(body)}", name: 'ApiClient');
      debugPrint("[API REQUEST] POST $url ${body != null ? 'Body: ${jsonEncode(body)}' : ''}");
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final stringParams = queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        uri = uri.replace(queryParameters: stringParams);
      }
      final response = await _httpClient
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 401 &&
          retryOnAuthError &&
          !url.contains('/auth/')) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          return post(
            url,
            headers: headers,
            queryParameters: queryParameters,
            body: body,
            retryOnAuthError: false,
          );
        }
      }

      return _processResponse(response);
    } on SocketException catch (e) {
      log("API SocketException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] SocketException for $url: $e");
      throw ApiException(
        message:
            'No connection to server. Please check your network or backend service.',
      );
    } on TimeoutException catch (e) {
      log("API TimeoutException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] TimeoutException for $url: $e");
      throw ApiException(
        message: 'Connection timed out. Server took too long to respond.',
      );
    } on FormatException catch (e) {
      log("API FormatException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] FormatException for $url: $e");
      throw ApiException(
        message: 'Invalid response format received from server.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      log("API Error for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] Error for $url: $e");
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<dynamic> put(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool retryOnAuthError = true,
  }) async {
    try {
      log("PUT : $url", name: 'ApiClient');
      if (body != null) log("Body : ${jsonEncode(body)}", name: 'ApiClient');
      debugPrint("[API REQUEST] PUT $url ${body != null ? 'Body: ${jsonEncode(body)}' : ''}");
      Uri uri = Uri.parse(url);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final stringParams = queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        uri = uri.replace(queryParameters: stringParams);
      }
      final response = await _httpClient
          .put(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 401 && retryOnAuthError) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          return put(
            url,
            headers: headers,
            queryParameters: queryParameters,
            body: body,
            retryOnAuthError: false,
          );
        }
      }

      return _processResponse(response);
    } on SocketException catch (e) {
      log("API SocketException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] SocketException for $url: $e");
      throw ApiException(
        message:
            'No connection to server. Please check your network or backend service.',
      );
    } on TimeoutException catch (e) {
      log("API TimeoutException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] TimeoutException for $url: $e");
      throw ApiException(
        message: 'Connection timed out. Server took too long to respond.',
      );
    } on FormatException catch (e) {
      log("API FormatException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] FormatException for $url: $e");
      throw ApiException(
        message: 'Invalid response format received from server.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      log("API Error for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] Error for $url: $e");
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<dynamic> patch(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool retryOnAuthError = true,
  }) async {
    try {
      log("PATCH : $url", name: 'ApiClient');
      if (body != null) log("Body : ${jsonEncode(body)}", name: 'ApiClient');
      debugPrint("[API REQUEST] PATCH $url ${body != null ? 'Body: ${jsonEncode(body)}' : ''}");
      Uri uri = Uri.parse(url);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final stringParams = queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        uri = uri.replace(queryParameters: stringParams);
      }
      final response = await _httpClient
          .patch(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 401 && retryOnAuthError) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          return patch(
            url,
            headers: headers,
            queryParameters: queryParameters,
            body: body,
            retryOnAuthError: false,
          );
        }
      }

      return _processResponse(response);
    } on SocketException catch (e) {
      log("API SocketException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] SocketException for $url: $e");
      throw ApiException(
        message:
            'No connection to server. Please check your network or backend service.',
      );
    } on TimeoutException catch (e) {
      log("API TimeoutException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] TimeoutException for $url: $e");
      throw ApiException(
        message: 'Connection timed out. Server took too long to respond.',
      );
    } on FormatException catch (e) {
      log("API FormatException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] FormatException for $url: $e");
      throw ApiException(
        message: 'Invalid response format received from server.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      log("API Error for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] Error for $url: $e");
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<dynamic> delete(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool retryOnAuthError = true,
  }) async {
    try {
      log("DELETE : $url", name: 'ApiClient');
      if (body != null) log("Body : ${jsonEncode(body)}", name: 'ApiClient');
      debugPrint("[API REQUEST] DELETE $url ${body != null ? 'Body: ${jsonEncode(body)}' : ''}");
      Uri uri = Uri.parse(url);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final stringParams = queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        uri = uri.replace(queryParameters: stringParams);
      }
      final response = await _httpClient
          .delete(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 401 && retryOnAuthError) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          return delete(
            url,
            headers: headers,
            queryParameters: queryParameters,
            body: body,
            retryOnAuthError: false,
          );
        }
      }

      return _processResponse(response);
    } on SocketException catch (e) {
      log("API SocketException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] SocketException for $url: $e");
      throw ApiException(
        message:
            'No connection to server. Please check your network or backend service.',
      );
    } on TimeoutException catch (e) {
      log("API TimeoutException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] TimeoutException for $url: $e");
      throw ApiException(
        message: 'Connection timed out. Server took too long to respond.',
      );
    } on FormatException catch (e) {
      log("API FormatException for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] FormatException for $url: $e");
      throw ApiException(
        message: 'Invalid response format received from server.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      log("API Error for $url: $e", name: 'ApiClient');
      debugPrint("[API ERROR] Error for $url: $e");
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<bool> _attemptTokenRefresh() async {
    if (_isRefreshing) {
      return _refreshCompleter?.future ?? Future.value(false);
    }

    if (currentRefreshToken == null || currentRefreshToken!.isEmpty) {
      onSessionExpired?.call();
      return false;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      if (onTokenRefreshRequested != null) {
        final success = await onTokenRefreshRequested!();
        _refreshCompleter?.complete(success);
        return success;
      }

      // Direct refresh request fallback
      final refreshUri = Uri.parse(ApiEndpoints.refresh);
      log("POST : $refreshUri", name: 'ApiClient');
      debugPrint("[API REQUEST] POST $refreshUri");
      final refreshRes = await _httpClient
          .post(
            refreshUri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': currentRefreshToken}),
          )
          .timeout(const Duration(seconds: 8));

      log("Response [${refreshRes.statusCode}] POST $refreshUri : ${refreshRes.body}", name: 'ApiClient');
      debugPrint("[API RESPONSE] [${refreshRes.statusCode}] POST $refreshUri -> ${refreshRes.body}");

      if (refreshRes.statusCode >= 200 && refreshRes.statusCode < 300) {
        final json = jsonDecode(utf8.decode(refreshRes.bodyBytes));
        final data = json['data'] ?? json;
        if (data is Map && data.containsKey('accessToken')) {
          currentAccessToken = data['accessToken'].toString();
          if (data.containsKey('refreshToken') &&
              data['refreshToken'] != null) {
            currentRefreshToken = data['refreshToken'].toString();
          }
          _refreshCompleter?.complete(true);
          return true;
        }
      }

      onSessionExpired?.call();
      _refreshCompleter?.complete(false);
      return false;
    } catch (_) {
      onSessionExpired?.call();
      _refreshCompleter?.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  dynamic _processResponse(http.Response response) {
    final method = response.request?.method ?? 'API';
    final url = response.request?.url.toString() ?? '';
    final statusCode = response.statusCode;
    final responseBody = response.body;

    final maskedBody = _maskSecret(responseBody);
    log("Response [$statusCode] $method $url : $maskedBody", name: 'ApiClient');
    debugPrint("[API RESPONSE] [$statusCode] $method $url -> $maskedBody");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } catch (e) {
        throw ApiException(
          message: 'Failed to parse server response.',
          statusCode: response.statusCode,
        );
      }
    } else {
      String errorMessage = 'Server error (${response.statusCode})';
      String? errorCode;
      List<String> errors = [];
      dynamic details;

      try {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body is Map) {
          details = body;
          if (body.containsKey('message') && body['message'] != null) {
            errorMessage = body['message'].toString();
          }
          if (body.containsKey('errorCode') && body['errorCode'] != null) {
            errorCode = body['errorCode'].toString();
          }
          if (body['errors'] is List) {
            errors = (body['errors'] as List).map((e) => e.toString()).toList();
          } else if (body['data'] is Map && body['success'] == false) {
            final fieldMap = body['data'] as Map;
            errors = fieldMap.entries
                .map((e) => '${e.key}: ${e.value}')
                .toList();
          }
        }
      } catch (_) {}

      // Sanitize user-facing error message to never leak SQL/DB credentials or statements
      final lowerMsg = errorMessage.toLowerCase();
      if (lowerMsg.contains('sql') ||
          lowerMsg.contains('jdbc') ||
          lowerMsg.contains('hibernate') ||
          lowerMsg.contains('mysql') ||
          lowerMsg.contains('postgres') ||
          lowerMsg.contains('rds') ||
          lowerMsg.contains('access denied for user') ||
          lowerMsg.contains('syntax error')) {
        errorMessage = 'A server data processing error occurred. Please try again or contact support.';
      }

      throw ApiException(
        message: errorMessage,
        statusCode: response.statusCode,
        errorCode: errorCode,
        errors: errors,
        details: details,
      );
    }
  }
}
