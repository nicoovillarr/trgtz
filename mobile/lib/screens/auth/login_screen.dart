import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redux/redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/exceptions/sso_login_exception.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/logger.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/auth/services/index.dart';
import 'package:trgtz/screens/auth/widgets/index.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:trgtz/utils.dart';

import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseScreen<LoginScreen>
    with SingleTickerProviderStateMixin {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  bool ready = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<TextEditState> _emailKey = GlobalKey<TextEditState>();
  final GlobalKey<TextEditState> _passwordKey = GlobalKey<TextEditState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Utils.preloadFonts([
        'Inter',
        'Josefin Sans',
      ]);
      FlutterNativeSplash.remove();

      setState(() {
        ready = true;
      });
    });

    super.initState();
  }

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
          children: ready
              ? [
                  _buildBanner(),
                  const SizedBox(height: 32.0),
                  _buildForm(),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildBanner() => Animate(
        effects: const [
          FadeEffect(),
          SlideEffect(curve: Curves.easeOut),
        ],
        delay: _delayDuration,
        child: Column(
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
        ),
      );

  Widget _buildForm() => Form(
        key: _formKey,
        child: SeparatedColumn(
          spacing: 24,
          children: [
            _buildFormField(
              child: _simpleButton(
                onPressed: _handleGoogleSignIn,
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
            _simpleButton(
              onPressed: _forgotPassword,
              border: false,
              children: [
                const Text(
                  'Forgot your password?',
                ),
              ],
            ).animate(
              effects: const [
                FadeEffect(),
              ],
              delay: _delayDuration,
            ),
            const Separator(
              size: 160,
            ),
            _simpleButton(
              onPressed: () => Navigator.of(context).pushNamed('/signup'),
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
            ).animate(
              effects: const [
                FadeEffect(),
              ],
              delay: _delayDuration,
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
              .then(_completeSignIn);
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

  Future<void> _completeSignIn(Map<String, dynamic> response) async {
    await LocalStorage.saveToken(response['token'].toString());

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
    });
  }

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
      ).animate(
        effects: const [
          FadeEffect(),
          SlideEffect(curve: Curves.easeOut),
        ],
        delay: _delayDuration,
      );

  int _animatedWidgetsCount = 0;
  Duration get _delayDuration =>
      Duration(milliseconds: 500 + 150 * _animatedWidgetsCount++);

  @override
  Color get backgroundColor => const Color(0xFFF5F5F5);

  @override
  bool get useAppBar => false;

  void _handleGoogleSignIn() async {
    setIsLoading(true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setIsLoading(false);
        throw Exception("Google sign in failed");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        setIsLoading(false);
        throw Exception("Google sign in failed");
      }

      await _completeGoogleSignIn(idToken, googleUser);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      rethrow;
    }
  }

  Future _completeGoogleSignIn(
      String idToken, GoogleSignInAccount googleUser) async {
    final deviceInfo =
        await DeviceInformationService.of(context).getDeviceInfo();
    ModuleService()
        .googleSignIn(idToken, googleUser.email, deviceInfo)
        .then(_completeSignIn)
        .catchError((e) {
      setIsLoading(false);
      if (e is SsoLoginException) {
        final String email = googleUser.email;
        final String displayName = googleUser.displayName ?? '';
        final String photoUrl = googleUser.photoUrl ?? '';
        simpleBottomSheet(
          height: size.height * 0.85,
          title: 'Use your password to log in before linking your account',
          child: SsoIntermediatePassword(
            email: email,
            idToken: idToken,
            displayName: displayName,
            photoUrl: photoUrl,
          ),
        );
      } else {
        throw e;
      }
    });
  }

  void _forgotPassword() {
    simpleBottomSheet(
      title: 'Forgot your password?',
      child: ForgotPasswordForm(
        onSend: (email) {
          setIsLoading(true);
          ModuleService().sendResetLink(email).then((_) {
            setIsLoading(false);

            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Reset link sent to your email.'),
                duration: const Duration(seconds: 2),
              ),
            );
          });
        },
      ),
    );
  }

  void _printAppEndpoint() {
    Store<ApplicationState> store = StoreProvider.of<ApplicationState>(context);
    if (!store.state.isProduction) {
      showSnackBar('Endpoint: ${dotenv.env['ENDPOINT']}');
    }
  }
}
