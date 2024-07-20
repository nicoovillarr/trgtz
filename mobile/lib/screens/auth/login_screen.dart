import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/logger.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/auth/services/index.dart';
import 'package:trgtz/screens/auth/widgets/index.dart';
import 'package:trgtz/security.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:trgtz/store/local_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseScreen<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<TextEditState> _emailKey = GlobalKey<TextEditState>();
  final GlobalKey<TextEditState> _passwordKey = GlobalKey<TextEditState>();

  @override
  Widget body(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
        width: size.width,
        padding: const EdgeInsets.symmetric(
          vertical: 64.0,
          horizontal: 48,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBanner(),
            const SizedBox(height: 32.0),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text.rich(
            const TextSpan(
              text: appName,
              children: [
                TextSpan(
                  text: '.',
                  style: TextStyle(
                    height: 1,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            style: GoogleFonts.josefinSans(
              color: mainColor,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Welcome!',
            style: GoogleFonts.inter(
              height: 1,
              color: mainColor,
              fontSize: 14,
            ),
          )
        ],
      );

  Widget _buildForm() => Form(
        key: _formKey,
        child: SeparatedColumn(
          spacing: 24,
          children: [
            _buildFormField(
              child: _simpleButton(
                onPressed: () {},
                children: [
                  SvgPicture.asset(
                    'assets/icons/google-logo.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sign in with Google',
                    style: GoogleFonts.inter(
                      color: mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Separator(
              size: 160,
              text: 'OR',
            ),
            _buildFormField(
              title: 'E-Mail',
              child: TextEdit(
                key: _emailKey,
                placeholder: 'you@mail.com',
                maxLines: 1,
              ),
            ),
            _buildFormField(
              title: 'Password',
              child: TextEdit(
                key: _passwordKey,
                placeholder: '•••••••',
                isPassword: true,
                maxLines: 1,
              ),
            ),
            _buildFormField(child: _buildLoginButton()),
            _buildFormField(
              child: _simpleButton(
                onPressed: () {},
                border: false,
                children: [
                  const Text(
                    'Forgot your password?',
                  ),
                ],
              ),
            ),
            const Separator(
              size: 160,
            ),
            _simpleButton(
              onPressed: () => Navigator.of(context).popAndPushNamed('/signup'),
              border: false,
              children: [
                Text.rich(
                  const TextSpan(
                    text: 'Don\'t have an account? ',
                    children: [
                      TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _simpleButton({
    required List<Widget> children,
    required Function() onPressed,
    bool border = true,
  }) =>
      TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: border
                ? const BorderSide(
                    color: mainColor,
                    width: 1,
                  )
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: children,
        ),
      );

  Widget _buildLoginButton() => ElevatedButton(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          dismissKeyboard();
          setIsLoading(true);
          final email = _emailKey.currentState!.value;
          final password = _passwordKey.currentState!.value;
          final deviceInfo =
              await DeviceInformationService.of(context).getDeviceInfo();
          ModuleService()
              .login(email, password, deviceInfo)
              .then((token) async {
            setIsLoading(false);
            await Security.saveCredentials(email, password, token);

            final me = await ModuleService().getMe();
            User u = me['user'];
            store.dispatch(SetUserAction(user: u));
            store.dispatch(SetGoalsAction(goals: me['goals']));
            store.dispatch(SetFriendsAction(friends: me['friends']));
            store.dispatch(SetAlertsAction(alerts: me['alerts']));

            await LocalStorage.saveUserID(u.id);

            final ws = WebSocketService.getInstance();
            await ws.init();

            Logger.logLogin().then((_) {
              Navigator.of(context).popAndPushNamed('/home');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged in'),
                  duration: Duration(seconds: 2),
                ),
              );
            });
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Log in',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildFormField({
    required Widget child,
    String? title,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          Row(
            children: [
              Expanded(child: child),
            ],
          ),
        ],
      );

  @override
  Color get backgroundColor => const Color(0xFFF5F5F5);

  @override
  bool get useAppBar => false;
}
