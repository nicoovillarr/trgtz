import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/index.dart';

class ReportDialog extends StatefulWidget {
  final List<ReportCategory> categoriesAvailable;
  final String entityType;
  final String entityId;
  final Function() showCommunityGuidelines;
  const ReportDialog({
    super.key,
    required this.categoriesAvailable,
    required this.entityType,
    required this.entityId,
    required this.showCommunityGuidelines,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ReportService _reportService = ReportService();

  late PageController _pageController;
  int _currentPage = 0;

  bool _isSubmitting = false;

  ReportCategory? _selectedCategory;
  String? reason;

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
            bottom: 0,
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
                'Report menu',
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
        _buildCategoryPickerPage(),
        _buildReasonPage(),
        _buildConfirmationPage(),
      ];

  Widget _buildCategoryPickerPage() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What do you want to report?',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: 'Make sure to check our ',
              children: [
                TextSpan(
                  text: 'community guidelines',
                  style: TextStyle(
                    color: textButtonColor.withOpacity(0.75),
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => widget.showCommunityGuidelines(),
                ),
                const TextSpan(text: ' before reporting.'),
              ],
              style: TextStyle(color: mainColor.withOpacity(0.75)),
            ),
          ),
          const SizedBox(height: 20),
          ...widget.categoriesAvailable
              .map((category) => _buildReportOption(category: category)),
        ],
      );

  Widget _buildReportOption({required ReportCategory category}) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: _selectedCategory == category
              ? mainColor.withOpacity(0.075)
              : Colors.transparent,
          border: Border.all(
            color:
                _selectedCategory == category ? mainColor : Colors.transparent,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                reason = null;
                _selectedCategory = category;
              });

              _goNext();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Report.getDisplayText(category),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(Report.getCategoryDescription(category)),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildReasonPage() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please provide a reason for your report',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('This will help us understand the issue better'),
          const SizedBox(height: 24),
          TextEdit(
            placeholder: 'Reason',
            initialValue: reason,
            maxLength: 150,
            onSaved: (s) {
              setState(() {
                reason = s ?? '';
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
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
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
                const TextSpan(text: 'Category: '),
                TextSpan(
                  text: Report.getDisplayText(
                      _selectedCategory ?? ReportCategory.other),
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
                  text: reason ?? '-',
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
          )
        ],
      );

  void _submitReport() {
    if (_selectedCategory == null || reason == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    _reportService
        .createReport(
          widget.entityType,
          widget.entityId,
          _selectedCategory!.toString().split('.').last,
          reason!,
        )
        .then((_) => _close())
        .catchError((e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while submitting the report'),
        ),
      );
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
