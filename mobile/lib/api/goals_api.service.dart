import 'package:trgtz/api/api.service.dart';
import 'package:trgtz/models/index.dart';

class GoalsApiService extends ApiBaseService {
  GoalsApiService() {
    controller = 'goals';
  }

  Future<ApiResponse> createGoals(List<Goal> goals) async =>
      await post('/', goals.map((goal) => goal.toJson()).toList());
}
