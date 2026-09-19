import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of matches
  Stream<List<MatchModel>> getMatches() {
    return _db.collection('matches').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => MatchModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Update match score and status
  Future<void> updateMatchScore(
      String id, int scoreA, int scoreB, String status) async {
    await _db.collection('matches').doc(id).update({
      'scoreA': scoreA,
      'scoreB': scoreB,
      'status': status,
    });
  }

  // Seed sample data
  Future<void> seedMatches() async {
    final snapshot = await _db.collection('matches').get();
    if (snapshot.docs.isEmpty) {
      final List<Map<String, dynamic>> sampleMatches = [
        {
          'teamA': 'Real Madrid',
          'teamB': 'Barcelona',
          'teamACrest': 'https://crests.football-data.org/86.png',
          'teamBCrest': 'https://crests.football-data.org/81.png',
          'scoreA': 0,
          'scoreB': 0,
          'status': 'Live',
          'matchDate': '2023-10-28 20:00',
          'venue': 'Santiago Bernabéu',
          'additionalInfo': 'El Clásico'
        },
        {
          'teamA': 'Manchester City',
          'teamB': 'Liverpool',
          'teamACrest': 'https://crests.football-data.org/65.png',
          'teamBCrest': 'https://crests.football-data.org/64.png',
          'scoreA': 1,
          'scoreB': 2,
          'status': 'Finished',
          'matchDate': '2023-11-25 12:30',
          'venue': 'Etihad Stadium',
          'additionalInfo': 'Premier League clash'
        },
        {
          'teamA': 'Arsenal',
          'teamB': 'Tottenham',
          'teamACrest': 'https://crests.football-data.org/57.png',
          'teamBCrest': 'https://crests.football-data.org/73.png',
          'scoreA': 0,
          'scoreB': 0,
          'status': 'Upcoming',
          'matchDate': '2023-12-02 15:00',
          'venue': 'Emirates Stadium',
          'additionalInfo': 'North London Derby'
        },
      ];

      for (var match in sampleMatches) {
        await _db.collection('matches').add(match);
      }
    }
  }
}
