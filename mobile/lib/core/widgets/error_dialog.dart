import 'package:flutter/material.dart';
import 'package:trgtz/core/exceptions/index.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String content;
  final AppException? innerException;
  const ErrorDialog({
    super.key,
    this.title = 'Error',
    this.content = 'An unexpected error occurred.',
    this.innerException,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(title),
        content:
            Text(innerException != null ? innerException!.message : content),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('OK'),
          ),
        ],
      );
}
