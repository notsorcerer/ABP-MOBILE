import '../models/user.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _api;

  AuthRepository(this._api);

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _api.post('auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });

    final data = response.data['data'];
    final user = User.fromJson(data['user']);
    final token = data['token'] as String;

    await _api.saveToken(token);

    return {'user': user, 'token': token};
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('auth/login', data: {
      'email': email,
      'password': password,
    });

    final data = response.data['data'];
    final user = User.fromJson(data['user']);
    final token = data['token'] as String;

    await _api.saveToken(token);

    return {'user': user, 'token': token};
  }

  Future<void> logout() async {
    await _api.post('auth/logout');
    await _api.deleteToken();
  }

  Future<User> getUser() async {
    final response = await _api.get('auth/user');
    return User.fromJson(response.data['data']);
  }

  Future<bool> hasToken() async {
    final token = await _api.getToken();
    return token != null;
  }
}
