import 'package:flutter/material.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/index.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends BaseScreen<PasswordResetScreen> {
  GlobalKey<TextEditState> passwordKey = GlobalKey();
  GlobalKey<TextEditState> rePasswordKey = GlobalKey();

  @override
  Widget body(BuildContext context) => Column(
    children: [
      TextEdit(
        key: passwordKey,
        placeholder: 'Password',
        isPassword: true,
        validate: (s) => s == null || s.isEmpty || s.length < 6
            ? 'Password must be at least 6 characters.'
            : null,
      ),
      const SizedBox(height: 20),
      TextEdit(
        key: rePasswordKey,
        placeholder: 'Re-enter Password',
        isPassword: true,
        validate: (s) => s != passwordKey.currentState?.value
            ? 'Passwords do not match.'
            : null,
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MButton(
            onPressed: () {
              if (passwordKey.currentState?.validate() == true &&
                  rePasswordKey.currentState?.validate() == true) {
                // Call the API to reset the password
              }
            },
            text: 'Reset Password',
          ),
        ],
      ),
    ],
  );
}