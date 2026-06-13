import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await _repository.hasToken();
      if (hasToken) {
        _user = await _repository.getUser();
      }
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.login(
        email: email,
        password: password,
      );
      _user = result['user'] as User;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      _user = result['user'] as User;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {}
    _user = null;
    notifyListeners();
  }

  String _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      if (e.response != null) {
        final message = e.response?.data?['message'] as String?;
        if (message != null && message.isNotEmpty) {
          return message;
        }
        if (e.response?.statusCode == 422) {
          final errors = e.response?.data?['errors'] as Map<String, dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            return errors.values.first is List
                ? (errors.values.first as List).first as String
                : errors.values.first as String;
          }
        }
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Koneksi timeout. Periksa koneksi Anda.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Tidak dapat terhubung ke server. Pastikan backend berjalan.';
      }
      return e.message ?? 'Terjadi kesalahan. Silakan coba lagi.';
    }
    final str = e.toString();
    if (str.contains('SocketException') ||
        str.contains('Connection refused')) {
      return 'Tidak dapat terhubung ke server';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
