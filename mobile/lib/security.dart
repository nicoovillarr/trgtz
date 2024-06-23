import 'package:encrypt/encrypt.dart';
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
}
