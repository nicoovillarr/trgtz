import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildScrollView(),
    );
  }

  AppBar _buildAppBar() => AppBar(
        title: const Text('hi, Nico'),
        backgroundColor: Colors.white,
        elevation: 5,
      );

  Widget _buildScrollView() => SingleChildScrollView(
        child: Wrap(
          direction: Axis.vertical,
          children: _buildBody(),
        ),
      );

  List<Widget> _buildBody() => [
        // ... content
      ];
}
