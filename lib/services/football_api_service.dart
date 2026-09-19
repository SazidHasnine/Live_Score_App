import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';

class FootballApiService {
  final Dio _dio = Dio();
  final String _apiKey = '57a8e984a90d4b6180994516d8fe8934';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncMatchesToFirestore() async {
    try {
      final response = await _dio.get(
        'https://api.football-data.org/v4/matches',
        options: Options(
          headers: {
            'X-Auth-Token': _apiKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final List matchesData = response.data['matches'];
        final batch = _firestore.batch();

        for (var m in matchesData) {
          final String matchId = m['id'].toString();
          final String teamA = m['homeTeam']['name'] ?? 'Unknown';
          final String teamB = m['awayTeam']['name'] ?? 'Unknown';
          final String? teamACrest = m['homeTeam']['crest'];
          final String? teamBCrest = m['awayTeam']['crest'];
          final int scoreA = m['score']['fullTime']['home'] ?? 0;
          final int scoreB = m['score']['fullTime']['away'] ?? 0;
          final String apiStatus = m['status'];
          
          String status = 'Upcoming';
          if (apiStatus == 'IN_PLAY' || apiStatus == 'PAUSED') {
            status = 'Live';
          } else if (apiStatus == 'FINISHED') {
            status = 'Finished';
          } else if (apiStatus == 'TIMED' || apiStatus == 'SCHEDULED') {
            status = 'Upcoming';
          }

          final String matchDate = m['utcDate'] ?? '';
          final String venue = m['venue'] ?? 'TBA';
          final String additionalInfo = m['competition']['name'] ?? '';

          final matchMap = {
            'teamA': teamA,
            'teamB': teamB,
            'teamACrest': teamACrest,
            'teamBCrest': teamBCrest,
            'scoreA': scoreA,
            'scoreB': scoreB,
            'status': status,
            'matchDate': matchDate,
            'venue': venue,
            'additionalInfo': additionalInfo,
          };

          final docRef = _firestore.collection('matches').doc(matchId);
          batch.set(docRef, matchMap, SetOptions(merge: true));
        }

        await batch.commit();
        print('Successfully synced ${matchesData.length} matches.');
      }
    } catch (e) {
      print('Error syncing matches: $e');
      rethrow;
    }
  }
}
