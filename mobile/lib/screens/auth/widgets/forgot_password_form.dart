import 'package:flutter/material.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/utils.dart';

class ForgotPasswordForm extends StatefulWidget {
  final Function(String) onSend;
  const ForgotPasswordForm({
    super.key,
    required this.onSend,
  });

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  GlobalKey<TextEditState> emailKey = GlobalKey();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            TextEdit(
              key: emailKey,
              placeholder: 'someone@mail.com',
              validate: (s) => s == null || s.isEmpty || !Utils.validateEmail(s)
                  ? 'You must add a valid email.'
                  : null,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MButton(
                  onPressed: () {
                    if (emailKey.currentState?.validate() == true) {
                      widget.onSend(emailKey.currentState!.value);
                    }
                  },
                  text: 'Send reset link',
                ),
              ],
            ),
          ],
        ),
      );
}
