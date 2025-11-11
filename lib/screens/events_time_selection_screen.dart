import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventTimeSelectionScreen extends StatefulWidget {
  final String eventId; // primim id-ul evenimentului curent

  const EventTimeSelectionScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventTimeSelectionScreen> createState() => _EventTimeSelectionScreenState();
}

class _EventTimeSelectionScreenState extends State<EventTimeSelectionScreen> {
  final supabase = Supabase.instance.client;

  final List<String> intervals = [
    "08:00 - 09:00",
    "09:00 - 10:00",
    "10:00 - 11:00",
    "11:00 - 12:00",
    "12:00 - 13:00",
    "13:00 - 14:00",
    "14:00 - 15:00",
    "15:00 - 16:00",
    "16:00 - 17:00",
    "17:00 - 18:00",
  ];

  Map<String, int> _attendeeCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendeeCounts();
  }

  Future<void> _fetchAttendeeCounts() async {
    setState(() => _loading = true);

    try {
      final response = await supabase
          .from('event_attendees')
          .select('interval')
          .eq('event_id', widget.eventId);

      final Map<String, int> counts = {};
      for (final row in response) {
        final interval = row['interval'] as String;
        counts[interval] = (counts[interval] ?? 0) + 1;
      }

      for (final interval in intervals) {
        counts.putIfAbsent(interval, () => 0);
      }

      setState(() {
        _attendeeCounts = counts;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Eroare la citirea participanților: $error');
      setState(() => _loading = false);
    }
  }

  Color _getIndicatorColor(int count) {
    if (count < 30) return Colors.green;
    if (count < 50) return Colors.yellow[700]!;
    return Colors.red;
  }

  Future<void> _selectInterval(String interval) async {
    try {
      final userId = supabase.auth.currentUser!.id;

      await supabase.from('event_attendees').insert({
        'event_id': widget.eventId,
        'user_id': userId,
        'interval': interval,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Te-ai înscris pentru intervalul $interval!')),
      );

      // actualizează numărul de participanți
      _fetchAttendeeCounts();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la înscriere: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alege intervalul orar"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: intervals.length,
        itemBuilder: (context, idx) {
          final interval = intervals[idx];
          final count = _attendeeCounts[interval] ?? 0;
          final color = _getIndicatorColor(count);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color,
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(interval),
              trailing: ElevatedButton(
                onPressed: () => _selectInterval(interval),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Selectează"),
              ),
            ),
          );
        },
      ),
    );
  }
}