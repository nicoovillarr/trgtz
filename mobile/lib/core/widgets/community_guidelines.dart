import 'package:flutter/material.dart';
import 'package:trgtz/constants.dart';

class CommunityGuidelines extends StatelessWidget {
  const CommunityGuidelines({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 32.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Community Guidelines',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Our community guidelines are designed to ensure that everyone has a safe and enjoyable experience on our platform. Please take a moment to review them.',
                style: TextStyle(
                  fontSize: 16,
                  color: mainColor,
                ),
              ),
              SizedBox(height: 64.0, child: const Divider()),
              ..._buildGuideline(
                title: '1. Be Respectful',
                description:
                    'Treat others with kindness and respect. Support your friends\' goals without judgment. Harassment, discrimination, or any form of abusive language will not be tolerated.',
              ),
              const SizedBox(height: 32),
              ..._buildGuideline(
                title: '2. Celebrate Positively',
                description:
                    'When celebrating milestones, focus on uplifting and constructive comments. Celebrations should be inclusive and positive for all involved.',
              ),
              const SizedBox(height: 32),
              ..._buildGuideline(
                title: '3. Constructive Feedback',
                description:
                    'If you offer suggestions or feedback, ensure it’s constructive and helpful. Negative or unhelpful criticism can discourage others.',
              ),
              const SizedBox(height: 32),
              ..._buildGuideline(
                title: '4. Stay on Topic',
                description:
                    'Keep comments relevant to the goals and achievements being shared. Avoid off-topic conversations that distract from the goal-setting environment.',
              ),
              const SizedBox(height: 32),
              ..._buildGuideline(
                title: '5. No Hate Speech or Bullying',
                description:
                    'We do not allow any form of hate speech, bullying, or personal attacks. This is a space for encouragement and growth, not negativity.',
              ),
              const SizedBox(height: 32),
              ..._buildGuideline(
                title: '6. Respect Privacy',
                description:
                    'Do not share anyone’s personal information without their consent. Keep the focus on the goals and achievements shared within the app.',
              ),
              const SizedBox(height: 32),
              ..._buildGuideline(
                title: '7. No Spamming or Self-Promotion',
                description:
                    'Please refrain from spamming or using the app to promote products, services, or other apps. Focus on genuine interactions about goal-setting.',
              ),
              const SizedBox(height: 32),
              ..._buildGuideline(
                title: '8. Follow the Law',
                description:
                    'Ensure that your content and behavior comply with local laws and the app\'s terms of service. Any illegal activity will result in account suspension or termination.',
              ),
              const SizedBox(height: 32),
              ..._buildGuideline(
                title: '9. Report Inappropriate Behavior',
                description:
                    'If you encounter any content or behavior that violates these guidelines, please report it so we can take appropriate action.',
              ),
            ],
          ),
        ),
      );

  List<Widget> _buildGuideline(
          {required String title, required String description}) =>
      [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(description),
      ];
}
