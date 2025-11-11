import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'events_time_selection_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> events = [
      {
        'title': 'Duminică la BookLoop Hub ☕',
        'date': 'În fiecare duminică, 10:00 - 14:00',
        'description':
            'Te așteptăm la BookLoop Hub pentru o cafea bună și un schimb de cărți cu alți iubitori de lectură 📚',
      },
      {
        'title': 'Atelier de lectură interactivă',
        'date': '15 Noiembrie 2025, ora 17:00',
        'description':
            'Participă la o seară de lectură și discuții relaxante despre literatura contemporană.',
      },
      {
        'title': 'Târg de cărți second-hand',
        'date': '22 Noiembrie 2025, ora 12:00',
        'description':
            'Adu-ți cărțile preferate și descoperă noi povești. Eveniment deschis tuturor utilizatorilor BookLoop.',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              const String query = 'Le Club Târgu Mureș';
              final Uri googleMapsUri = Uri.parse('comgooglemaps://?q=$query');
              final Uri googleMapsWeb = Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=$query');
              final Uri wazeUri =
                  Uri.parse('waze://?ll=46.545018,24.564624&navigate=yes');
              final Uri wazeWeb = Uri.parse(
                  'https://waze.com/ul?ll=46.545018,24.564624&navigate=yes');
              final Uri appleMapsUri = Uri.parse(
                  'http://maps.apple.com/?daddr=46.545018,24.564624&dirflg=d&t=m');

              bool hasGoogleMaps = await canLaunchUrl(googleMapsUri);
              bool hasWaze = await canLaunchUrl(wazeUri);
              bool hasAppleMaps = await canLaunchUrl(appleMapsUri);

              if (!hasGoogleMaps && await canLaunchUrl(googleMapsWeb)) {
                hasGoogleMaps = true;
              }
              if (!hasWaze && await canLaunchUrl(wazeWeb)) {
                hasWaze = true;
              }

              final availableApps = [
                if (hasGoogleMaps)
                  {
                    'name': 'Google Maps',
                    'icon': Icons.map,
                    'url': hasGoogleMaps ? googleMapsUri : googleMapsWeb,
                    'color': Colors.blue
                  },
                if (hasWaze)
                  {
                    'name': 'Waze',
                    'icon': Icons.navigation,
                    'url': wazeUri,
                    'color': Colors.deepPurple
                  },
                if (hasAppleMaps)
                  {
                    'name': 'Apple Maps',
                    'icon': Icons.map_outlined,
                    'url': appleMapsUri,
                    'color': Colors.green
                  },
              ];

              if (availableApps.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Nicio aplicație de hărți nu este instalată pe acest dispozitiv.')),
                );
                return;
              }

              if (availableApps.length == 1) {
                await launchUrl(availableApps.first['url'] as Uri,
                    mode: LaunchMode.externalApplication);
                return;
              }

              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Deschide locația în:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        for (final app in availableApps)
                          ListTile(
                            leading: Icon(app['icon'] as IconData,
                                color: app['color'] as Color),
                            title: Text(app['name'] as String),
                            onTap: () async {
                              await launchUrl(app['url'] as Uri,
                                  mode: LaunchMode.externalApplication);
                              Navigator.pop(context);
                            },
                          ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.redAccent, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Le Club 📍",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Strada Târgului 15, Târgu Mureș",
                          style: TextStyle(color: Colors.black54),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Apasă pentru direcții",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Următoarele evenimente",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...events.map((event) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                title: Text(
                  event['title']!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      event['date']!,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event['description']!,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 30),
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventTimeSelectionScreen(eventId: 'default-event-id')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: const [
                    Text(
                      "☕ Duminica e pentru cititori!",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.brown),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Ne vedem la BookLoop Hub pentru un schimb de cărți și o cafea bună alături de comunitatea ta de cititori!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.brown, fontSize: 14),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
