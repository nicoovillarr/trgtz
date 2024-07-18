import 'package:encrypt/encrypt.dart';
import 'package:trgtz/api/index.dart';
import 'package:trgtz/store/local_storage.dart';

class Security {
  static final _key = Key.fromUtf8('should be removed when deployed!');
  static final _iv = IV.fromLength(16);

  static String encrypt(String text) {
    final encrypter = Encrypter(AES(_key));
    return encrypter.encrypt(text, iv: _iv).base64;
  }

  static String decrypt(String text) {
    final encrypter = Encrypter(AES(_key));
    return encrypter.decrypt(Encrypted.fromBase64(text), iv: _iv);
  }

  static Future saveCredentials(
      String email, String password, String token) async {
    await LocalStorage.saveEmail(email);
    await LocalStorage.savePass(password);
    await LocalStorage.saveToken(token);
  }

  static Future clearCredentials() async {
    await LocalStorage.saveEmail(null);
    await LocalStorage.savePass(null);
    await LocalStorage.saveToken(null);
  }

  static Future<bool> internalLogIn() async {
    final authApiService = AuthApiService();
    String? token = await LocalStorage.getToken();
    if (token != null) {
      final tickResponse = await authApiService.tick(token);
      if (tickResponse.status) {
        return true;
      } else {
        await LocalStorage.clear();
        // String? email, pass;
        // try {
        //   email = await LocalStorage.getEmail();
        //   pass = await LocalStorage.getPass();
        // } catch (_) {}
        // if (email != null && pass != null) {
        // final deviceInfo =
        //     await DeviceInformationService.of(context).getDeviceInfo();
        // final loginResponse =
        //     await authApiService.login(email, pass, deviceInfo);
        // String? token = loginResponse.content.containsKey('token')
        //     ? loginResponse.content['token'].toString()
        //     : null;
        // if (loginResponse.status && token != null) {
        //   LocalStorage.saveToken(token);
        //   return true;
        // } else {
        //   await LocalStorage.clear();
        // }
        // }
      }
    }

    return false;
  }
}
