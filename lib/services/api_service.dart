import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  // ignore: unused_field
  static String? _token;

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // AUTH
  static Future<Map<String, dynamic>> login(
    String login,
    String password,
  ) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'login': login, 'password': password},
    );
    return response.data;
  }

  static Future<Map<String, dynamic>> register(
    String login,
    String password,
  ) async {
    final response = await _dio.post(
      '/auth/register',
      data: {'login': login, 'password': password},
    );
    return response.data;
  }

  // TRANSACTIONS
  static Future<List<dynamic>> getTransactions() async {
    final response = await _dio.get('/transactions/');
    return response.data;
  }

  static Future<Map<String, dynamic>> createTransaction({
    required double amount,
    required String type,
    int? categoryId,
    String? description,
  }) async {
    final response = await _dio.post(
      '/transactions/',
      data: {
        'amount': amount,
        'type': type,
        if (categoryId != null) 'category_id': categoryId,
        if (description != null) 'description': description,
      },
    );
    return response.data;
  }

  static Future<void> deleteTransaction(int id) async {
    await _dio.delete('/transactions/$id');
  }

  // CATEGORIES
  static Future<List<dynamic>> getCategories() async {
    final response = await _dio.get('/categories/');
    return response.data;
  }

  static Future<Map<String, dynamic>> createCategory({
    required String name,
    required String type,
  }) async {
    final response = await _dio.post(
      '/categories/',
      data: {'name': name, 'type': type},
    );
    return response.data;
  }

  // ANALYTICS
  static Future<Map<String, dynamic>> getSummary() async {
    final response = await _dio.get('/analytics/summary');
    return response.data;
  }

  static Future<Map<String, dynamic>> getMonthly() async {
    final response = await _dio.get('/analytics/monthly');
    return response.data;
  }

  // BUDGETS
  static Future<List<dynamic>> getBudgets() async {
    final response = await _dio.get('/budgets/');
    return response.data;
  }

  static Future<List<dynamic>> getBudgetStatus(String month) async {
    final response = await _dio.get(
      '/budgets/status',
      queryParameters: {'month': month},
    );
    return response.data;
  }

  static Future<Map<String, dynamic>> createBudget({
    required int categoryId,
    required double limitAmount,
    required String month,
  }) async {
    final response = await _dio.post(
      '/budgets/',
      data: {
        'category_id': categoryId,
        'limit_amount': limitAmount,
        'month': month,
      },
    );
    return response.data;
  }

  // GOALS
  static Future<List<dynamic>> getGoals() async {
    final response = await _dio.get('/goals/');
    return response.data;
  }

  static Future<Map<String, dynamic>> createGoal({
    required String title,
    required double targetAmount,
    String? deadline,
  }) async {
    final response = await _dio.post(
      '/goals/',
      data: {
        'title': title,
        'target_amount': targetAmount,
        if (deadline != null) 'deadline': deadline,
      },
    );
    return response.data;
  }

  static Future<Map<String, dynamic>> depositGoal({
    required int goalId,
    required double amount,
  }) async {
    final response = await _dio.put(
      '/goals/$goalId/deposit',
      data: {'amount': amount},
    );
    return response.data;
  }

  // SCHEDULED PAYMENTS
  static Future<List<dynamic>> getScheduledPayments() async {
    final response = await _dio.get('/scheduled-payments/');
    return response.data;
  }

  static Future<Map<String, dynamic>> createScheduledPayment({
    required String name,
    required double amount,
    required int dayOfMonth,
    String? category,
  }) async {
    final response = await _dio.post(
      '/scheduled-payments/',
      data: {
        'name': name,
        'amount': amount,
        'day_of_month': dayOfMonth,
        if (category != null) 'category': category,
        'is_active': 1,
      },
    );
    return response.data;
  }

  static Future<void> toggleScheduledPayment(int id) async {
    await _dio.patch('/scheduled-payments/$id/toggle');
  }

  static Future<void> deleteScheduledPayment(int id) async {
    await _dio.delete('/scheduled-payments/$id');
  }

  // AI
  static Future<String> getAiAdvice(String question) async {
    final response = await _dio.post(
      '/ai/advice',
      data: {'question': question},
    );
    return response.data['answer'];
  }
}
