import '../features/logbook/models/log_model.dart';

class AccessPolicy {
  // Hak Edit
  static bool canEdit({required String userId, required String logAuthorId}) {
    return userId == logAuthorId;
  }

  // Hak Hapus
  static bool canDelete({required String userId, required String logAuthorId}) {
    return userId == logAuthorId;
  }

  // Hak Akses Baca
  static bool canView({required LogModel log, required String currentUserId}) {
    // Pemilik selalu bisa lihat
    if (log.authorId == currentUserId) return true;

    // Orang lain (anggota/ketua) bisa lihat jika publik
    return log.isPublic;
  }
}
