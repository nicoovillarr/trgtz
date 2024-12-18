import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redux/redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/logger.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/auth/services/index.dart';
import 'package:trgtz/screens/auth/widgets/index.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends BaseScreen<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<TextEditState> _firstNameKey = GlobalKey<TextEditState>();
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
          GestureDetector(
            onTap: _printAppEndpoint,
            child: Text.rich(
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
              title: 'First name',
              child: TextEdit(
                key: _firstNameKey,
                placeholder: 'John',
                maxLines: 1,
              ),
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
            _buildFormField(child: _buildSignUpButton()),
            const Separator(
              size: 160,
            ),
            _simpleButton(
              onPressed: () => Navigator.of(context).pop(),
              border: false,
              children: [
                Text.rich(
                  const TextSpan(
                    text: 'Already created an account? ',
                    children: [
                      TextSpan(
                        text: 'Sign in',
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
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'By signing up, you agree to our ',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.w900,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _openPage('terms');
                      },
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.w900,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _openPage('privacy');
                      },
                  ),
                ],
              ),
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

  Widget _buildSignUpButton() => ElevatedButton(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          dismissKeyboard();
          setIsLoading(true);
          final firstName = _firstNameKey.currentState!.value;
          final email = _emailKey.currentState!.value;
          final password = _passwordKey.currentState!.value;
          final deviceInfo =
              await DeviceInformationService(context: context).getDeviceInfo();
          ModuleService()
              .signup(firstName, email, password, deviceInfo)
              .then((response) async {
            setIsLoading(false);

            LocalStorage.saveToken(response['token'].toString());

            final Map<String, dynamic> me = await ModuleService()
                .getUserProfile(response['_id'].toString());
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
                'Sign up',
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

  void _printAppEndpoint() {
    Store<ApplicationState> store = StoreProvider.of<ApplicationState>(context);
    if (!store.state.isProduction) {
      showSnackBar('Endpoint: ${dotenv.env['ENDPOINT']}');
    }
  }

  void _openPage(String path) async {
    final String url = '${dotenv.env['WEB']}/$path';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else if (kDebugMode) {
      print('Could not launch $url');
    }
  }
}
