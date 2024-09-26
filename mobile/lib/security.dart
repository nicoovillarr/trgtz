import 'package:google_sign_in/google_sign_in.dart';
import 'package:trgtz/api/index.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/local_storage.dart';

class Security {
  static Future<String?> internalLogIn() async {
    String userId = '';

    final authApiService = AuthApiService();
    String? token = await LocalStorage.getToken();
    if (token != null) {
      final tickResponse = await authApiService.tick(token);
      if (tickResponse.status) {
        userId = tickResponse.content['_id'];
      } else {
        await Security.logOut();
        return null;
      }

      if (tickResponse.content['session']['provider'] == 'google') {
        final googleUser = await GoogleSignIn().signInSilently();
        if (googleUser != null) {
          final googleAuth = await googleUser.authentication;
          final googleToken = googleAuth.idToken;
          if (googleToken == null) {
            await Security.logOut();
            return null;
          }
        }
      }
    }

    return userId;
  }

  static Future logOut() async {
    await AuthApiService().logout();
    await GoogleSignIn().signOut();
    await LocalStorage.clear();
    WebSocketService.getInstance().close();
  }
}
