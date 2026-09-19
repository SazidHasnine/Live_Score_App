import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/firestore_service.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  MatchModel? _selectedMatch;
  int _scoreA = 0;
  int _scoreB = 0;
  String _status = 'Upcoming';

  final List<String> _statusOptions = ['Upcoming', 'Live', 'Finished'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: StreamBuilder<List<MatchModel>>(
        stream: _firestoreService.getMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final matches = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<MatchModel>(
                  decoration: const InputDecoration(labelText: 'Select Match'),
                  value: _selectedMatch,
                  items: matches.map((match) {
                    return DropdownMenuItem(
                      value: match,
                      child: Text('${match.teamA} vs ${match.teamB}'),
                    );
                  }).toList(),
                  onChanged: (match) {
                    setState(() {
                      _selectedMatch = match;
                      _scoreA = match!.scoreA;
                      _scoreB = match.scoreB;
                      _status = match.status;
                    });
                  },
                ),
                if (_selectedMatch != null) ...[
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildScoreController(_selectedMatch!.teamA, _scoreA, (val) {
                        setState(() => _scoreA = val);
                      }),
                      const Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      _buildScoreController(_selectedMatch!.teamB, _scoreB, (val) {
                        setState(() => _scoreB = val);
                      }),
                    ],
                  ),
                  const SizedBox(height: 32),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Status'),
                    value: _status,
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem(value: status, child: Text(status));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _status = val!);
                    },
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      try {
                        await _firestoreService.updateMatchScore(
                          _selectedMatch!.id,
                          _scoreA,
                          _scoreB,
                          _status,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Score updated successfully!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    child: const Text('Update Match'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreController(String team, int score, Function(int) onChanged) {
    return Column(
      children: [
        Text(team, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                if (score > 0) onChanged(score - 1);
              },
            ),
            Text('$score', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(score + 1),
            ),
          ],
        ),
      ],
    );
  }
}
