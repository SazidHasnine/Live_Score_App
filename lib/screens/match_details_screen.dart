import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/match_model.dart';

class MatchDetailsScreen extends StatelessWidget {
  final String matchId;

  const MatchDetailsScreen({required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('matches').doc(matchId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Match not found.'));
          }

          final match = MatchModel.fromMap(snapshot.data!.id, snapshot.data!.data()!);
          bool isLive = match.status.toLowerCase() == 'live';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTeamInfo(match.teamA, match.teamACrest),
                    Column(
                      children: [
                        Text(
                          '${match.scoreA} - ${match.scoreB}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isLive)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            match.status,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                    _buildTeamInfo(match.teamB, match.teamBCrest),
                  ],
                ),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),
                _buildInfoRow(Icons.calendar_today, 'Date', match.matchDate),
                _buildInfoRow(Icons.location_on, 'Venue', match.venue),
                _buildInfoRow(Icons.info_outline, 'Info', match.additionalInfo),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamInfo(String teamName, String? crestUrl) {
    return Expanded(
      child: Column(
        children: [
          _buildCrest(crestUrl),
          const SizedBox(height: 12),
          Text(
            teamName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCrest(String? url) {
    if (url == null || url.isEmpty || url.endsWith('.svg')) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.sports_soccer, size: 40, color: Colors.grey),
      );
    }
    return Image.network(
      url,
      height: 80,
      width: 80,
      errorBuilder: (context, error, stackTrace) => CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.sports_soccer, size: 40, color: Colors.grey),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const SizedBox(
          height: 80,
          width: 80,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
