import 'package:flutter/material.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/widgets/index.dart';

class FormAction {
  final String text;
  final IconData? icon;
  final Function() onPressed;

  FormAction({
    required this.text,
    required this.onPressed,
    this.icon,
  });
}

class TextEditModal extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _textEditKey = GlobalKey<TextEditState>();

  final String placeholder;
  final Function(String?) onSave;
  final String? Function(String?)? validate;
  final String buttonText;
  final String? initialValue;
  final int? maxLines;
  final int? maxLength;
  final double separation;
  final List<FormAction> actions;

  TextEditModal({
    super.key,
    required this.placeholder,
    required this.onSave,
    this.buttonText = 'Save',
    this.validate,
    this.initialValue = '',
    this.maxLines,
    this.maxLength,
    this.separation = 16.0,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 24.0,
          right: 24.0,
          bottom: MediaQuery.of(context).viewInsets.bottom == 0 ? 48.0 : 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextEdit(
              key: _textEditKey,
              placeholder: placeholder,
              initialValue: initialValue,
              maxLines: maxLines,
              maxLength: maxLength,
              validate: validate,
            ),
            SizedBox(height: separation),
            _buildActionsRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    List<Widget> buttons = [
      Expanded(
        flex: 4,
        child: ElevatedButton(
          onPressed: () {
            NavigatorState navigator = Navigator.of(context);
            if (_formKey.currentState!.validate() && navigator.canPop()) {
              onSave(_textEditKey.currentState!.value);
              navigator.pop();
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: const Color(0xFF003E4B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          child: Text(buttonText),
        ),
      ),
    ];

    if (actions.isNotEmpty) {
      buttons.add(SizedBox(width: 8.0));
      buttons.add(
        Expanded(
          flex: actions.length == 1 ? 4 : 2,
          child: TextButton(
            style: TextButton.styleFrom(
              elevation: 0,
              backgroundColor: textButtonColor.withAlpha(20),
              foregroundColor: mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              splashFactory: NoSplash.splashFactory,
            ),
            onPressed: () => _actionFn(context, actions[0].onPressed),
            child: actions.length == 2
                ? Icon(actions[0].icon)
                : Text(actions[0].text),
          ),
        ),
      );

      if (actions.length > 1) {
        buttons.add(SizedBox(width: 8.0));
        buttons.add(Expanded(
          flex: actions.length == 2 ? 2 : 1,
          child: TextButton(
            style: TextButton.styleFrom(
              elevation: 0,
              padding: EdgeInsets.zero,
              backgroundColor: textButtonColor.withAlpha(20),
              foregroundColor: mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            onPressed: actions.length == 2
                ? () => _actionFn(context, actions[1].onPressed)
                : () => _showOverflowActions(context),
            child: actions.length == 2
                ? Icon(actions[1].icon)
                : Icon(Icons.more_vert),
          ),
        ));
      }
    }

    buttons = buttons.reversed.toList();

    return Row(
      children: buttons,
    );
  }

  void _showOverflowActions(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: actions
                .map(
                  (action) => ListTile(
                    leading: Icon(action.icon),
                    title: Text(action.text),
                    onTap: () {
                      Navigator.of(context).pop();
                      _actionFn(context, action.onPressed);
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  void _actionFn(BuildContext context, Function() fn) {
    Navigator.of(context).pop();
    fn();
  }
}
