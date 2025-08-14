import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

enum HttpMethod { get, post, put, delete }

class ApiService {
  final _auth = AuthStorage();

  Future<dynamic> getRequest(
    String endpoint, {
    bool requiresToken = true,
    void Function(dynamic)? handleSuccess,
  }) async {
    try {
      final token = _auth.token;
      final headers = <String, String>{
        if (requiresToken && token != null) 'Authorization': 'Bearer $token',
      };
      print(token);
      final response = await http.get(Uri.parse(ApiConstants.baseUrl + endpoint), headers: headers);
      final decodedBody = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        final responseJson = decodedBody.isNotEmpty ? json.decode(decodedBody) : {};
        handleSuccess?.call(responseJson);
        return responseJson;
      } else {
        final responseJson = decodedBody.isNotEmpty ? json.decode(decodedBody) : {};
        _handleApiError(response.statusCode, responseJson['message']?.toString() ?? 'anErrorOccurred'.tr);
        return null;
      }
    } on SocketException {
      CustomWidgets.showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (_) {
      CustomWidgets.showSnackBar('unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
      return null;
    }
  }

  Future<dynamic> handleApiRequest(
    String endpoint, {
    required Map<String, dynamic> body,
    required String method,
    required bool requiresToken,
    bool isForm = false,
    Map<String, File>? files,
  }) async {
    try {
      final token = _auth.token;
      final uri = Uri.parse(endpoint.startsWith('http') ? endpoint : '${ApiConstants.baseUrl}$endpoint');
      print(uri);
      print(token);
      late http.BaseRequest request;

      if (isForm) {
        request = http.MultipartRequest(method, uri);
        // Metin alanlarını ekle
        body.forEach((key, value) {
          (request as http.MultipartRequest).fields[key] = value;
        });

        // YENİ: Dosyaları ekle
        if (files != null) {
          for (var entry in files.entries) {
            var file = await http.MultipartFile.fromPath(entry.key, entry.value.path);
            (request as http.MultipartRequest).files.add(file);
          }
        }
      } else {
        request = http.Request(method, uri);
        request.headers[HttpHeaders.contentTypeHeader] = 'application/json; charset=UTF-8';
        if (body.isNotEmpty) {
          (request as http.Request).body = jsonEncode(body);
        }
      }

      if (requiresToken && token != null) {
        request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }

      print('API Request to: $endpoint');
      print('Request Body: $body');
      if (files != null) print('Request Files: ${files.keys.join(', ')}');

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final statusCode = streamedResponse.statusCode;

      print('API Response Status: $statusCode');
      print('API Response Body: $responseBody');

      // Başarılı durum (2xx)
      if (statusCode >= 200 && statusCode < 300) {
        // Cevap boş olabilir, bu bir hata değildir.
        if (responseBody.isEmpty) {
          return {}; // Boş bir Map döndürerek null hatalarını önle
        }
        // Başarılıysa JSON verisini decode edip döndür
        return json.decode(responseBody);
      }
      // Hata durumu
      else {
        dynamic errorJson;
        try {
          // Hata mesajı JSON formatında olabilir, bunu ayrıştırmaya çalışalım
          errorJson = json.decode(responseBody);
        } catch (e) {
          // Eğer cevap JSON değilse (HTML gibi), genel bir mesaj gösterelim
          errorJson = {'message': 'Server returned a non-JSON response.'};
        }
        if (statusCode == 409) {
        } else {
          _handleApiError(statusCode, errorJson['message']?.toString() ?? 'anErrorOccurred'.tr);
        }
        return statusCode; // Hata durumunda status kodunu döndür
      }
    } on SocketException {}
  }

  void _handleApiError(int statusCode, String message) {
    String errorMessage;
    switch (statusCode) {
      case 400:
        errorMessage = 'invalidNumber'.tr;
        break;
      case 401:
        errorMessage = '${'unauthorized'.tr}: $message';
        break;
      case 403:
        errorMessage = message;
        break;
      case 404:
        errorMessage = '${'notFound'.tr}: $message';
        break;
      case 405:
        errorMessage = 'userDoesNotExist'.tr;
        break;
      case 500:
        errorMessage = '${'serverError'.tr}: $message';
        break;

      default:
        errorMessage = '${'errorStatus'.tr} $statusCode: $message';
    }
    CustomWidgets.showSnackBar('Error'.tr, errorMessage, Colors.red);
  }
}
