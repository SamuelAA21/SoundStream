class UserProfile {
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.artist,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final ArtistIdentity? artist;

  bool get isAdmin => role == 'admin';
  bool get isArtist => role == 'artist';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      artist: json['artist'] is Map<String, dynamic>
          ? ArtistIdentity.fromJson(json['artist'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'artist': artist?.toJson(),
      };
}

class ArtistIdentity {
  ArtistIdentity({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory ArtistIdentity.fromJson(Map<String, dynamic> json) {
    return ArtistIdentity(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class AuthSession {
  AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserProfile user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': user.toJson(),
      };
}

class Collaborator {
  Collaborator({
    required this.id,
    required this.name,
    required this.role,
  });

  final String id;
  final String name;
  final String role;

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    return Collaborator(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}

class Song {
  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    this.album,
    this.albumId,
    this.durationSeconds = 0,
    this.streamUrl,
    this.collaborators = const [],
    this.isPublished,
    this.score,
    this.reason,
    this.favoritedAt,
  });

  final String id;
  final String title;
  final String artist;
  final String genre;
  final String? album;
  final String? albumId;
  final int durationSeconds;
  final String? streamUrl;
  final List<Collaborator> collaborators;
  final bool? isPublished;
  final double? score;
  final String? reason;
  final DateTime? favoritedAt;

  factory Song.fromJson(Map<String, dynamic> json) {
    final collaboratorsJson = json['collaborators'];
    return Song(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      album: json['album']?.toString(),
      albumId: json['albumId']?.toString(),
      genre: json['genre']?.toString() ?? '',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      streamUrl: json['streamUrl']?.toString(),
      collaborators: collaboratorsJson is List
          ? collaboratorsJson
              .whereType<Map<String, dynamic>>()
              .map(Collaborator.fromJson)
              .toList()
          : const [],
      isPublished: json['isPublished'] as bool?,
      score: (json['score'] as num?)?.toDouble(),
      reason: json['reason']?.toString(),
      favoritedAt: json['favoritedAt'] != null
          ? DateTime.tryParse(json['favoritedAt'].toString())
          : null,
    );
  }
}

class Album {
  Album({
    required this.id,
    required this.title,
    required this.artist,
    this.genre,
    this.songCount = 0,
    this.songs = const [],
  });

  final String id;
  final String title;
  final String artist;
  final String? genre;
  final int songCount;
  final List<Song> songs;

  factory Album.fromJson(Map<String, dynamic> json) {
    final songsJson = json['songs'];
    return Album(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      genre: json['genre']?.toString(),
      songCount: (json['songCount'] as num?)?.toInt() ??
          (songsJson is List ? songsJson.length : 0),
      songs: songsJson is List
          ? songsJson
              .whereType<Map<String, dynamic>>()
              .map(Song.fromJson)
              .toList()
          : const [],
    );
  }
}

class PlaylistSummary {
  PlaylistSummary({
    required this.id,
    required this.name,
    this.description,
    required this.isPublic,
    required this.songCount,
  });

  final String id;
  final String name;
  final String? description;
  final bool isPublic;
  final int songCount;

  factory PlaylistSummary.fromJson(Map<String, dynamic> json) {
    return PlaylistSummary(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      isPublic: json['isPublic'] as bool? ?? false,
      songCount: (json['songCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class PlaylistSong {
  PlaylistSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    this.album,
    required this.durationSeconds,
    required this.position,
    this.addedAt,
  });

  final String id;
  final String title;
  final String artist;
  final String genre;
  final String? album;
  final int durationSeconds;
  final int position;
  final DateTime? addedAt;

  factory PlaylistSong.fromJson(Map<String, dynamic> json) {
    return PlaylistSong(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      album: json['album']?.toString(),
      genre: json['genre']?.toString() ?? '',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      position: (json['position'] as num?)?.toInt() ?? 0,
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt'].toString())
          : null,
    );
  }
}

class PlaylistDetail extends PlaylistSummary {
  PlaylistDetail({
    required super.id,
    required super.name,
    super.description,
    required super.isPublic,
    required super.songCount,
    required this.songs,
  });

  final List<PlaylistSong> songs;

  factory PlaylistDetail.fromJson(Map<String, dynamic> json) {
    final songsJson = json['songs'] as List<dynamic>? ?? const [];
    return PlaylistDetail(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      isPublic: json['isPublic'] as bool? ?? false,
      songCount: (json['songCount'] as num?)?.toInt() ?? songsJson.length,
      songs: songsJson
          .whereType<Map<String, dynamic>>()
          .map(PlaylistSong.fromJson)
          .toList(),
    );
  }
}

class HistoryEntry {
  HistoryEntry({
    required this.id,
    required this.songId,
    required this.title,
    required this.artist,
    required this.genre,
    required this.playedSeconds,
    required this.completionRate,
    required this.startedAt,
  });

  final String id;
  final String songId;
  final String title;
  final String artist;
  final String genre;
  final int playedSeconds;
  final double completionRate;
  final DateTime? startedAt;

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'].toString(),
      songId: json['songId'].toString(),
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      genre: json['genre']?.toString() ?? '',
      playedSeconds: (json['playedSeconds'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString())
          : null,
    );
  }
}

class RecommendationItem {
  RecommendationItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    this.album,
    required this.score,
    this.reason,
  });

  final String id;
  final String title;
  final String artist;
  final String genre;
  final String? album;
  final double score;
  final String? reason;

  Song toSong() {
    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      genre: genre,
      durationSeconds: 0,
      score: score,
      reason: reason,
    );
  }

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      album: json['album']?.toString(),
      genre: json['genre']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      reason: json['reason']?.toString(),
    );
  }
}

class AdminUser {
  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.lastLoginAt,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class AudioStreamData {
  AudioStreamData({
    required this.bytes,
    required this.mimeType,
  });

  final List<int> bytes;
  final String mimeType;
}
