import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/search/models/filter_detail_model.dart';

class FilterService {
  final Dio _dio = Dio();
  final AuthStorage _authStorage = AuthStorage();
  final String _baseUrl = ApiConstants.baseUrl;

  FilterService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _authStorage.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<List<int>> applyFilters() async {
    try {
      final String endpoint = _baseUrl + ApiConstants.filters;
      print('GET Request to: $endpoint');
      final response = await _dio.get(
        endpoint,
      );

      if (response.statusCode == 200) {
        print('Response data: ${response.data}');
        final List<dynamic> data = response.data;
        return data.map((item) => item['id'] as int).toList();
      } else {
        throw Exception(
            'Failed to load filtered properties: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error during applyFilters: $e');
      if (e.response != null) {
        print('Error Response data: ${e.response?.data}');
        print('Response headers: ${e.response?.headers}');
        print('Response request options: ${e.response?.requestOptions}');
      } else {
        print('Request options: ${e.requestOptions}');
        print('Error message: ${e.message}');
      }
      throw Exception('Failed to apply filters: ${e.message}');
    } catch (e) {
      print('Error during applyFilters: $e');
      throw Exception('An unexpected error occurred while applying filters.');
    }
  }

  Future<List<FilterDetailModel>> fetchFilterDetails() async {
    try {
      final String endpoint = _baseUrl + ApiConstants.filters;
      print('GET Request to fetchFilterDetails: $endpoint');
      final response = await _dio.get(
        endpoint,
      );

      if (response.statusCode == 200) {
        print('Response data for fetchFilterDetails: ${response.data}');
        // Check if response.data is a Map and extract the list from 'results' or 'data' key
        List<dynamic> dataList;
        if (response.data is Map<String, dynamic>) {
          if (response.data.containsKey('results')) {
            dataList = response.data['results'];
          } else if (response.data.containsKey('data')) {
            dataList = response.data['data'];
          } else {
            throw Exception(
                'Response Map does not contain "results" or "data" key.');
          }
        } else if (response.data is List<dynamic>) {
          dataList = response.data;
        } else {
          throw Exception(
              'Unexpected response data type for filter details: ${response.data.runtimeType}');
        }
        return dataList
            .map((json) => FilterDetailModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load filter details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error during fetchFilterDetails: $e');
      if (e.response != null) {
        print('Error Response data: ${e.response?.data}');
        print('Response headers: ${e.response?.headers}');
        print('Response request options: ${e.response?.requestOptions}');
      } else {
        print('Request options: ${e.requestOptions}');
        print('Error message: ${e.message}');
      }
      throw Exception('Failed to fetch filter details: ${e.message}');
    } catch (e) {
      print('Error during fetchFilterDetails: $e');
      throw Exception(
          'An unexpected error occurred while fetching filter details.');
    }
  }

  Future<List<PropertyModel>> fetchHousesByFilter(
      Map<String, dynamic> filterData) async {
    try {
      final String endpoint = '$_baseUrl${ApiConstants.getProductList}';
      print('GET Request to fetch houses: $endpoint');
      print('GET Parameters for houses: $filterData');
      final response = await _dio.get(
        endpoint,
        queryParameters: filterData,
      );

      if (response.statusCode == 200) {
        // Assuming the response data is a list of property maps
        // If it's a paginated response, you'll need to adjust this.
        List<dynamic> data = response.data;
        return data.map((json) => PropertyModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load houses with filters: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error during fetchHousesByFilter: $e');
      if (e.response != null) {
        print('Error Response data for houses: ${e.response?.data}');
        print('Response headers: ${e.response?.headers}');
        print('Response request options: ${e.response?.requestOptions}');
      } else {
        print('Request options: ${e.requestOptions}');
        print('Error message: ${e.message}');
      }
      throw Exception('Failed to fetch houses with filters: ${e.message}');
    } catch (e) {
      print('Error during fetchHousesByFilter: $e');
      throw Exception(
          'An unexpected error occurred while fetching houses with filters.');
    }
  }

  Future<void> saveFilters(Map<String, dynamic> filterData) async {
    try {
      // Null olan alanları silmek için
      filterData.removeWhere((key, value) => value == null || value == '');

      print('Filter data to send: $filterData');

      final response = await _dio.post(
        'http://216.250.10.237:9000/api/filters/',
        data: FormData.fromMap(filterData),
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Filters saved successfully!');
        print('Response data: ${response.data}');
      } else {
        throw Exception('Failed to save filters: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio error during saveFilters: $e');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        print('Response headers: ${e.response?.headers}');
        print('Request options: ${e.response?.requestOptions}');
      } else {
        print('Request options: ${e.requestOptions}');
        print('Error message: ${e.message}');
      }
      throw Exception('Failed to save filters: ${e.message}');
    } catch (e) {
      print('Unexpected error during saveFilters: $e');
      throw Exception('An unexpected error occurred while saving filters.');
    }
  }

  Future<List<MapPropertyModel>> searchProperties(Map<String, dynamic> filterData) async {
    try {
      final String endpoint =
          _baseUrl + 'api/search/'; // Assuming this is the correct endpoint
      print('POST Request to searchProperties: $endpoint');
      print('Request data: $filterData');

      final response = await _dio.post(
        endpoint,
        data: filterData,
      );

      if (response.statusCode == 200) {
        print('Response data for searchProperties: ${response.data}');
        final List<dynamic> results = response.data['results'];
        return results.map((item) => MapPropertyModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search properties: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error during searchProperties: $e');
      if (e.response != null) {
        print('Error Response data: ${e.response?.data}');
        print('Response headers: ${e.response?.headers}');
        print('Response request options: ${e.response?.requestOptions}');
      } else {
        print('Request options: ${e.requestOptions}');
        print('Error message: ${e.message}');
      }
      throw Exception('Failed to search properties: ${e.message}');
    } catch (e) {
      print('Error during searchProperties: $e');
      throw Exception(
          'An unexpected error occurred while searching properties.');
    }
  }

  Future<List<MapPropertyModel>> fetchPropertiesByFilterId(int filterId) async {
    try {
      final String endpoint =
          _baseUrl + 'api/filterbyid/' + filterId.toString();
      print('GET Request to fetchPropertiesByFilterId: $endpoint');

      final response = await _dio.get(
        endpoint,
      );

      if (response.statusCode == 200) {
        print('Response data for fetchPropertiesByFilterId: ${response.data}');
        Map<String, dynamic> responseMap;
        if (response.data is String) {
          responseMap = json.decode(response.data) as Map<String, dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          responseMap = response.data;
        } else {
          throw Exception(
              'Unexpected response data type: ${response.data.runtimeType}. Expected String or Map<String, dynamic>.');
        }

        final List<dynamic> results = responseMap['results'];
        return results.map((item) => MapPropertyModel.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to fetch properties by filter ID: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error during fetchPropertiesByFilterId: $e');
      if (e.response != null) {
        print('Error Response data: ${e.response?.data}');
        print('Response headers: ${e.response?.headers}');
        print('Response request options: ${e.response?.requestOptions}');
      } else {
        print('Request options: ${e.requestOptions}');
        print('Error message: ${e.message}');
      }
      throw Exception('Failed to fetch properties by filter ID: ${e.message}');
    } catch (e) {
      print('Error during fetchPropertiesByFilterId: $e');
      throw Exception(
          'An unexpected error occurred while fetching properties by filter ID.');
    }
  }
}
