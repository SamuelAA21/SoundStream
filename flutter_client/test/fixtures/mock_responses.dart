/// Mock HTTP responses for testing
/// Centralized repository of realistic API responses

class MockResponses {
  // ────────────────────────────────────────────────────────────────────────
  // AUTH RESPONSES
  // ────────────────────────────────────────────────────────────────────────

  static const String loginSuccess = '''
  {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEiLCJlbWFpbCI6ImRlbW9Ac291bmRzdHJlYW0ubG9jYWwiLCJpYXQiOjE2Nzg4MzU5NDMsImV4cCI6MTY3ODg0Mjk0M30.test",
    "refreshToken": "refresh_token_here",
    "user": {
      "id": "1",
      "email": "demo@soundstream.local",
      "name": "Demo User",
      "accountType": "user",
      "createdAt": "2024-03-14T10:00:00Z"
    }
  }
  ''';

  static const String registerSuccess = '''
  {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjIiLCJlbWFpbCI6Im5ld3VzZXJAc291bmRzdHJlYW0ubG9jYWwiLCJpYXQiOjE2Nzg4MzU5NDMsImV4cCI6MTY3ODg0Mjk0M30.test",
    "refreshToken": "new_refresh_token_here",
    "user": {
      "id": "2",
      "email": "newuser@soundstream.local",
      "name": "New User",
      "accountType": "user",
      "createdAt": "2024-03-14T11:30:00Z"
    }
  }
  ''';

  static const String invalidCredentials = '''
  {
    "message": "Invalid email or password"
  }
  ''';

  static const String userNotFound = '''
  {
    "message": "User not found"
  }
  ''';

  static const String meSuccess = '''
  {
    "id": "1",
    "email": "demo@soundstream.local",
    "name": "Demo User",
    "accountType": "user",
    "createdAt": "2024-03-14T10:00:00Z"
  }
  ''';

  static const String refreshSuccess = '''
  {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEiLCJlbWFpbCI6ImRlbW9Ac291bmRzdHJlYW0ubG9jYWwiLCJpYXQiOjE2Nzg4MzYyNDMsImV4cCI6MTY3ODg0MzI0M30.test",
    "refreshToken": "new_refresh_token_updated"
  }
  ''';

  // ────────────────────────────────────────────────────────────────────────
  // CATALOG RESPONSES
  // ────────────────────────────────────────────────────────────────────────

  static const String songsListSuccess = '''
  [
    {
      "id": "song1",
      "title": "Bohemian Rhapsody",
      "artist": "Queen",
      "album": "A Night at the Opera",
      "genre": "Rock",
      "duration": 354,
      "imageUrl": "https://example.com/img1.jpg",
      "audioUrl": "https://example.com/audio1.mp3",
      "published": true
    },
    {
      "id": "song2",
      "title": "Imagine",
      "artist": "John Lennon",
      "album": "Imagine",
      "genre": "Pop",
      "duration": 183,
      "imageUrl": "https://example.com/img2.jpg",
      "audioUrl": "https://example.com/audio2.mp3",
      "published": true
    }
  ]
  ''';

  static const String albumsListSuccess = '''
  [
    {
      "id": "album1",
      "title": "A Night at the Opera",
      "artist": "Queen",
      "imageUrl": "https://example.com/album1.jpg",
      "releaseDate": "1975-11-21",
      "songCount": 12
    },
    {
      "id": "album2",
      "title": "Imagine",
      "artist": "John Lennon",
      "imageUrl": "https://example.com/album2.jpg",
      "releaseDate": "1971-09-09",
      "songCount": 10
    }
  ]
  ''';

  static const String albumDetailSuccess = '''
  {
    "id": "album1",
    "title": "A Night at the Opera",
    "artist": "Queen",
    "imageUrl": "https://example.com/album1.jpg",
    "releaseDate": "1975-11-21",
    "songs": [
      {
        "id": "song1",
        "title": "Bohemian Rhapsody",
        "artist": "Queen",
        "duration": 354,
        "genre": "Rock"
      },
      {
        "id": "song3",
        "title": "Don't Stop Me Now",
        "artist": "Queen",
        "duration": 237,
        "genre": "Rock"
      }
    ]
  }
  ''';

  static const String searchSuccess = '''
  [
    {
      "id": "song1",
      "title": "Bohemian Rhapsody",
      "artist": "Queen",
      "genre": "Rock",
      "duration": 354,
      "imageUrl": "https://example.com/img1.jpg"
    }
  ]
  ''';

  // ────────────────────────────────────────────────────────────────────────
  // FAVORITES RESPONSES
  // ────────────────────────────────────────────────────────────────────────

  static const String favoritesListSuccess = '''
  [
    {
      "id": "fav1",
      "songId": "song1",
      "song": {
        "id": "song1",
        "title": "Bohemian Rhapsody",
        "artist": "Queen",
        "duration": 354
      },
      "addedAt": "2024-03-14T10:00:00Z"
    }
  ]
  ''';

  static const String addFavoriteSuccess = '''
  {
    "id": "fav2",
    "songId": "song2",
    "addedAt": "2024-03-14T11:00:00Z"
  }
  ''';

  static const String removeFavoriteSuccess = '''
  {
    "message": "Favorite removed"
  }
  ''';

  // ────────────────────────────────────────────────────────────────────────
  // PLAYLISTS RESPONSES
  // ────────────────────────────────────────────────────────────────────────

  static const String playlistsListSuccess = '''
  [
    {
      "id": "playlist1",
      "name": "My Favorites",
      "description": "Songs I love",
      "userId": "1",
      "songCount": 15,
      "createdAt": "2024-03-10T10:00:00Z"
    }
  ]
  ''';

  static const String createPlaylistSuccess = '''
  {
    "id": "playlist2",
    "name": "New Playlist",
    "description": "A new playlist",
    "userId": "1",
    "songs": [],
    "createdAt": "2024-03-14T12:00:00Z"
  }
  ''';

  static const String playlistDetailSuccess = '''
  {
    "id": "playlist1",
    "name": "My Favorites",
    "description": "Songs I love",
    "userId": "1",
    "songs": [
      {
        "id": "song1",
        "title": "Bohemian Rhapsody",
        "artist": "Queen",
        "duration": 354
      },
      {
        "id": "song2",
        "title": "Imagine",
        "artist": "John Lennon",
        "duration": 183
      }
    ],
    "createdAt": "2024-03-10T10:00:00Z"
  }
  ''';

  // ────────────────────────────────────────────────────────────────────────
  // HISTORY RESPONSES
  // ────────────────────────────────────────────────────────────────────────

  static const String historyListSuccess = '''
  [
    {
      "id": "hist1",
      "songId": "song1",
      "song": {
        "id": "song1",
        "title": "Bohemian Rhapsody",
        "artist": "Queen"
      },
      "playedAt": "2024-03-14T10:30:00Z",
      "duration": 354,
      "completionRate": 1.0
    }
  ]
  ''';

  // ────────────────────────────────────────────────────────────────────────
  // ERROR RESPONSES
  // ────────────────────────────────────────────────────────────────────────

  static const String unauthorized = '''
  {
    "message": "Unauthorized"
  }
  ''';

  static const String forbidden = '''
  {
    "message": "Forbidden"
  }
  ''';

  static const String notFound = '''
  {
    "message": "Resource not found"
  }
  ''';

  static const String serverError = '''
  {
    "message": "Internal server error"
  }
  ''';

  static const String validationError = '''
  {
    "message": "Validation error",
    "errors": {
      "email": "Invalid email format"
    }
  }
  ''';
}
