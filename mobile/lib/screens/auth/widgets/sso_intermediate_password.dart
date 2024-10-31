import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/core/exceptions/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/logger.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/auth/services/index.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';

class SsoIntermediatePassword extends StatefulWidget {
  final String email;
  final String idToken;
  final String? displayName;
  final String? photoUrl;
  const SsoIntermediatePassword({
    super.key,
    required this.email,
    required this.idToken,
    this.displayName = '',
    this.photoUrl = '',
  });

  @override
  State<SsoIntermediatePassword> createState() =>
      _SsoIntermediatePasswordState();
}

class _SsoIntermediatePasswordState extends State<SsoIntermediatePassword> {
  final GlobalKey<TextEditState> _passwordKey = GlobalKey<TextEditState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: SizedBox(
        width: 260.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty)
              _buildPhoto(),
            const SizedBox(height: 16.0),
            if (widget.displayName != null && widget.displayName!.isNotEmpty)
              _buildDisplayName(),
            _buildEmailAddress(),
            const SizedBox(height: 24.0),
            _buildPasswordInput(),
            const SizedBox(height: 8.0),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MButton(
            onPressed: _login,
            text: 'Log In',
          ),
        ],
      );

  Widget _buildPasswordInput() => TextEdit(
        key: _passwordKey,
        placeholder: 'Password',
        isPassword: true,
        maxLines: 1,
      );

  Widget _buildEmailAddress() => Text(
        widget.email,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      );

  Widget _buildDisplayName() => Text(
        widget.displayName!,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _buildPhoto() => Container(
        width: 100,
        height: 100,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: LazyImage(imageUrl: widget.photoUrl!),
      );

  void _login() async {
    final email = widget.email;
    final password = _passwordKey.currentState!.value;
    final deviceInfo =
        await DeviceInformationService.of(context).getDeviceInfo();
    try {
      final response = await ModuleService().login(email, password, deviceInfo);
      if (response['token'] != null) {
        await LocalStorage.saveToken(response['token'].toString());
        if (await ModuleService().addAuthProvider('google', widget.idToken)) {
          await _completeSignIn(response);
        }
      }
    } on ApiException catch (e) {
      _passwordKey.currentState!.errorText = e.message;
    }
  }

  Future<void> _completeSignIn(Map<String, dynamic> response) async {
    final store = StoreProvider.of<ApplicationState>(context);

    final me = await ModuleService().getUserProfile(response['_id'].toString());
    User u = me['user'];
    store.dispatch(SetUserAction(user: u));
    store.dispatch(SetGoalsAction(goals: me['goals']));
    store.dispatch(SetFriendsAction(friends: me['friends']));
    store.dispatch(SetAlertsAction(alerts: me['alerts']));

    await LocalStorage.saveUserID(u.id);

    final ws = WebSocketService.getInstance();
    await ws.init();

    Logger.logLogin().then((_) {
      Navigator.of(context).popUntil((route) => false);
      Navigator.of(context).pushNamed('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged in'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}
