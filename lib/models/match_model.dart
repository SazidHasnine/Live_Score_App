class MatchModel {
  final String id;
  final String teamA;
  final String teamB;
  final String? teamACrest;
  final String? teamBCrest;
  final int scoreA;
  final int scoreB;
  final String status; // Upcoming, Live, Finished
  final String matchDate;
  final String venue;
  final String additionalInfo;

  MatchModel({
    required this.id,
    required this.teamA,
    required this.teamB,
    this.teamACrest,
    this.teamBCrest,
    required this.scoreA,
    required this.scoreB,
    required this.status,
    required this.matchDate,
    required this.venue,
    required this.additionalInfo,
  });

  Map<String, dynamic> toMap() {
    return {
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
  }

  factory MatchModel.fromMap(String id, Map<String, dynamic> map) {
    return MatchModel(
      id: id,
      teamA: map['teamA'] ?? '',
      teamB: map['teamB'] ?? '',
      teamACrest: map['teamACrest'],
      teamBCrest: map['teamBCrest'],
      scoreA: map['scoreA'] ?? 0,
      scoreB: map['scoreB'] ?? 0,
      status: map['status'] ?? 'Upcoming',
      matchDate: map['matchDate'] ?? '',
      venue: map['venue'] ?? '',
      additionalInfo: map['additionalInfo'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
