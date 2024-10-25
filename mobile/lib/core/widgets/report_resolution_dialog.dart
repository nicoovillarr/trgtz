import 'package:flutter/material.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';

class ReportResolutionDialog extends StatefulWidget {
  final void Function(ReportStatus status, String reason,
      void Function(String error) setError) onResolution;
  const ReportResolutionDialog({
    super.key,
    required this.onResolution,
  });

  @override
  State<ReportResolutionDialog> createState() => _ReportResolutionDialogState();
}

class _ReportResolutionDialogState extends State<ReportResolutionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late PageController _pageController;
  int _currentPage = 0;

  bool _isSubmitting = false;

  ReportStatus? _selectedStatus;
  String? _reason;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  late List<Widget> _pages;

  @override
  Widget build(BuildContext context) {
    _pages = _loadPages();
    return Material(
      child: Stack(
        children: [
          _buildNavBar(),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            bottom: 50,
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) => SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _pages[index],
                ),
              ),
            ),
          ),
          _buildSpinner(),
        ],
      ),
    );
  }

  Widget _buildNavBar() => Container(
        height: 50,
        color: Colors.white,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextButton(
                  child: Text(_currentPage == 0 ? 'Cancel' : 'Back'),
                  onPressed: () => _currentPage == 0 ? _close() : _goBack(),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Resolve report menu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

  void _goBack() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 150), curve: Curves.easeIn);
  }

  void _goNext() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 150), curve: Curves.easeIn);
  }

  void _close() {
    Navigator.of(context).pop();
  }

  List<Widget> _loadPages() => [
        _buildResolutionPickerPage(),
        _buildReasonPage(),
        _buildConfirmationPage(),
      ];

  Widget _buildResolutionPickerPage() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What do you want to do?',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildReportOption(
              title: 'Approve',
              description: 'Approve this report to take action',
              status: ReportStatus.resolved),
          _buildReportOption(
              title: 'Reject',
              description: 'Rejected reports will be closed',
              status: ReportStatus.rejected),
        ],
      );

  Widget _buildReportOption(
          {required ReportStatus status,
          required String title,
          required String description}) =>
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: _selectedStatus == status
              ? mainColor.withOpacity(0.075)
              : Colors.transparent,
          border: Border.all(
            color: _selectedStatus == status ? mainColor : Colors.transparent,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _reason = null;
                _selectedStatus = status;
              });

              _goNext();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(description),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildReasonPage() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please, provide a reason for your resolution',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
              'This will help the user understand the resolution better'),
          const SizedBox(height: 24),
          TextEdit(
            placeholder: 'Reason',
            initialValue: _reason,
            maxLength: 150,
            validate: (s) =>
                s == null || s.isEmpty ? 'Please provide a reason' : null,
            onSaved: (s) {
              setState(() {
                _reason = s ?? '';
              });

              _goNext();
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                  }
                },
                text: 'Next',
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildConfirmationPage() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please confirm your report',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Make sure everything is correct before submitting'),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              children: [
                const TextSpan(text: 'Resolution: '),
                TextSpan(
                  text: _selectedStatus != null
                      ? Report.getStatusText(_selectedStatus!)
                      : '',
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              children: [
                const TextSpan(text: 'Reason: '),
                TextSpan(
                  text: _reason ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MButton(
                onPressed: _submitReport,
                text: 'Submit',
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          if (_error.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _error,
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      );

  void _submitReport() {
    if (_selectedStatus == null || _reason == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    widget.onResolution(_selectedStatus!, _reason!, setError);
  }

  void setError(String error) {
    setState(() {
      _error = error;
      _isSubmitting = false;
    });
  }

  Widget _buildSpinner() => _isSubmitting
      ? Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        )
      : const SizedBox();
}
