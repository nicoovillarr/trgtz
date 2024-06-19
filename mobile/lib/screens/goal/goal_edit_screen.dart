import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mobile/core/widgets/index.dart';
import 'package:mobile/models/index.dart';
import 'package:mobile/store/actions.dart';
import 'package:mobile/store/app_state.dart';
import 'package:mobile/store/local_storage.dart';
import 'package:redux/redux.dart';

final _formKey = GlobalKey<FormState>();

class GoalEditScreen extends StatefulWidget {
  const GoalEditScreen({super.key});

  @override
  State<GoalEditScreen> createState() => _GoalEditScreenState();
}

class _GoalEditScreenState extends State<GoalEditScreen> {
  late Goal _originalGoal;

  final _titleKey = GlobalKey<TextEditState>();
  final _descKey = GlobalKey<TextEditState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final store = StoreProvider.of<AppState>(context);
      String goalId = ModalRoute.of(context)!.settings.arguments as String;
      _originalGoal =
          store.state.goals.firstWhere((element) => element.goalID == goalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    String goalId = ModalRoute.of(context)!.settings.arguments as String;
    return StoreConnector<AppState, Goal>(
      converter: (store) =>
          store.state.goals.firstWhere((element) => element.goalID == goalId),
      builder: (ctx, goal) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Edit Goal'),
          elevation: 1,
        ),
        body: _buildBody(goal),
      ),
    );
  }

  Widget _buildBody(Goal goal) => SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTitleField(goal),
              _buildDescriptionField(goal),
              _buildSaveButton(),
            ],
          ),
        ),
      );

  Widget _buildTitleField(Goal goal) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextEdit(
          key: _titleKey,
          placeholder: 'Buy a new PC',
          initialValue: goal.title,
          maxLines: 2,
          maxLength: 50,
          validate: (value) => value!.isEmpty ? 'Value cannot be empty.' : null,
        ),
      );

  Widget _buildDescriptionField(Goal goal) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextEdit(
          key: _descKey,
          placeholder: 'A new PC will help me work faster.',
          initialValue: goal.description ?? '',
          maxLength: 150,
          validate: (value) => value!.isEmpty ? 'Value cannot be empty.' : null,
        ),
      );

  Widget _buildSaveButton() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Store<AppState> store = StoreProvider.of<AppState>(context);
              Goal editedGoal = _originalGoal;
              editedGoal.title = _titleKey.currentState!.value;
              editedGoal.description = _descKey.currentState!.value;
              store.dispatch(UpdateGoalAction(goal: editedGoal));
              LocalStorage.saveGoals(store.state.goals);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      );
}
