

import 'package:flutter/material.dart';

class BadgeScreen extends StatelessWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = [
      {
        'title': 'Primele 10 cărți',
        'icon': Icons.star,
        'unlocked': true,
        'description': 'Ai încărcat primele tale 10 cărți!'
      },
      {
        'title': 'Primele 50 cărți',
        'icon': Icons.star_border,
        'unlocked': false,
        'description': 'Încarcă 50 de cărți pentru a debloca acest badge.'
      },
      {
        'title': '5 prieteni',
        'icon': Icons.people,
        'unlocked': false,
        'description': 'Adaugă 5 prieteni pentru a debloca acest badge.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Badge-uri',
          style: TextStyle(
            fontFamily: 'Merriweather',
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2F25),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3E2F25)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDFCFB), Color(0xFFE2D1C3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: badges.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
          ),
          itemBuilder: (context, index) {
            final badge = badges[index];
            final unlocked = badge['unlocked'] as bool;

            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDFCFB),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Color(0xFFE3C7A4), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              badge['icon'] as IconData,
                              size: 60,
                              color: unlocked ? Colors.amber : Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              badge['title'] as String,
                              style: const TextStyle(
                                fontFamily: 'Merriweather',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2F25),
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              badge['description'] as String,
                              style: const TextStyle(
                                fontFamily: 'Merriweather',
                                color: Color(0xFF8C6E54),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4B2E1E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Înapoi',
                                style: TextStyle(
                                  fontFamily: 'Merriweather',
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unlocked
                          ? const Color(0xFFFFF3C2)
                          : const Color(0xFFD9D1C7),
                      boxShadow: [
                        if (unlocked)
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                      ],
                    ),
                    child: Icon(
                      badge['icon'] as IconData,
                      size: 36,
                      color: unlocked ? Colors.amber : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge['title'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Merriweather',
                      color:
                          unlocked ? const Color(0xFF3E2F25) : const Color(0xFF8C6E54),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}