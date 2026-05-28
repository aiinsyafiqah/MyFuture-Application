import 'package:flutter/material.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class PersonalityTestBanner extends StatelessWidget {
  final VoidCallback onTap;

  const PersonalityTestBanner({
    super.key, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Make it stand out with a gradient (Blue to Purple-ish)
          gradient: const LinearGradient(
            colors: [
              Color(0xFF7B8FD3), // Your primary blue
              Color(0xFF91A3E2), // A slightly lighter blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B8FD3).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Side: Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Not sure what to study?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Take the 5-minute personality test to find your path.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // "Start Now" Button styling
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "START",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            // Right Side: Illustration/Icon
            // TIP: Replace Icon with Image.asset('assets/quiz_illus.png') for better looks
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_outlined, // Brain/Psychology icon
                color: Colors.white,
                size: 45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}