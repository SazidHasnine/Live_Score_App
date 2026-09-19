import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/firestore_service.dart';
import '../services/football_api_service.dart';
import 'admin_screen.dart';
import 'match_details_screen.dart';

class HomeScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final FootballApiService _apiService = FootballApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Scores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync with Football-Data.org',
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Syncing matches...')),
                );
                await _apiService.syncMatchesToFirestore();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync completed!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sync failed: $e')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<MatchModel>>(
        stream: _firestoreService.getMatches(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final matches = snapshot.data ?? [];

          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No matches found.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _firestoreService.seedMatches(),
                    child: const Text('Seed Sample Data'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return MatchCard(match: match);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _firestoreService.seedMatches(),
        tooltip: 'Refresh/Seed Data',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  final MatchModel match;

  const MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    bool isLive = match.status.toLowerCase() == 'live';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchDetailsScreen(matchId: match.id),
            ),
          );
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildCrest(match.teamACrest),
                  const SizedBox(height: 8),
                  Text(
                    match.teamA,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${match.scoreA} - ${match.scoreB}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  if (isLive)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      match.status,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  _buildCrest(match.teamBCrest),
                  const SizedBox(height: 8),
                  Text(
                    match.teamB,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Text(match.matchDate),
              Text(
                match.venue,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCrest(String? url) {
    if (url == null || url.isEmpty || url.endsWith('.svg')) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[200],
        child: const Icon(Icons.sports_soccer, color: Colors.grey),
      );
    }
    return Image.network(
      url,
      height: 40,
      width: 40,
      errorBuilder: (context, error, stackTrace) => CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[200],
        child: const Icon(Icons.sports_soccer, color: Colors.grey),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const SizedBox(
          height: 40,
          width: 40,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }
}
