import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logbook_app_073/features/logbook/models/log_model.dart';
import '../helper/log_helper.dart';

class MongoService {
  Db? _db;
  DbCollection? _collection;

  Future<void> connect() async {
    // Mencegah koneksi ganda
    if (_db != null) {
      if (_db!.state == State.open) return;
      if (_db!.state == State.opening) {
        // Tunggu sebentar sampai statusnya berubah jika sedang opening
        while (_db!.state == State.opening) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        return;
      }
    }

    // Cek koneksi internet
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      await LogHelper.writeLog(
        "Tidak ada koneksi internet (Offline Mode)",
        source: 'MongoService',
        level: 1,
      );
      throw Exception("Silakan periksa koneksi internet Anda.");
    }

    final uri = dotenv.env['MONGODB_URI'];

    if (uri == null || uri.isEmpty) {
      await LogHelper.writeLog(
        "MONGODB_URI tidak ditemukan",
        source: 'MongoService',
        level: 1,
      );
      throw Exception("MONGODB_URI tidak ditemukan");
    }

    try {
      _db = await Db.create(uri);
      // Tambahkan timeout agar tidak menggantung selamanya
      await _db!.open().timeout(const Duration(seconds: 10));

      _collection = _db!.collection('logs');
      await LogHelper.writeLog(
        "Berhasil terkoneksi ke MongoDB",
        source: 'MongoService',
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "Gagal terkoneksi ke MongoDB: $e",
        source: 'MongoService',
        level: 1,
      );
      _db = null;
      throw Exception("Gagal terhubung ke database. Silakan coba lagi.");
    }
  }

  Future<void> close() async {
    await _db?.close();
  }

  // Menambahkan data log (Insert)
  Future<void> insertLog(LogModel log) async {
    if (_collection == null) {
      await LogHelper.writeLog(
        "Database belum terkoneksi (insertLog)",
        source: 'MongoService',
        level: 1,
      );
      throw Exception("Database belum terkoneksi");
    }

    await _collection!.insertOne(log.toMap());
    await LogHelper.writeLog(
      "Catatan baru ditambahkan: ${log.title}",
      source: 'MongoService',
      level: 3,
    );
  }

  // Mengambil semua data log (Get All)
  Future<List<LogModel>> getAllLogs() async {
    if (_collection == null) {
      await LogHelper.writeLog(
        "Database belum terkoneksi (getAllLogs)",
        source: 'MongoService',
        level: 1,
      );
      throw Exception("Database belum terkoneksi");
    }

    final data = await _collection!.find().toList();
    await LogHelper.writeLog(
      "Mengambil ${data.length} catatan dari Atlas",
      source: 'MongoService',
      level: 3,
    );

    return data.map((e) => LogModel.fromMap(e)).toList();
  }

  // Memperbarui data log (Update)
  Future<void> updateLog(String id, LogModel log) async {
    if (_collection == null) {
      await LogHelper.writeLog(
        "Database belum terkoneksi (updateLog)",
        source: 'MongoService',
        level: 1,
      );
      throw Exception("Database belum terkoneksi");
    }

    await _collection!.replaceOne(
      where.id(ObjectId.fromHexString(id)),
      log.toMap(),
      upsert: true,
    );
    await LogHelper.writeLog(
      "Catatan dengan ID $id berhasil diperbarui",
      source: 'MongoService',
      level: 2,
    );
  }

  // Menghapus data log (Delete)
  Future<void> deleteLog(String id) async {
    if (_collection == null) {
      await LogHelper.writeLog(
        "Database belum terkoneksi (deleteLog)",
        source: 'MongoService',
        level: 1,
      );
      throw Exception("Database belum terkoneksi");
    }

    await _collection!.deleteOne(where.id(ObjectId.fromHexString(id)));
    await LogHelper.writeLog(
      "Catatan dengan ID $id berhasil dihapus",
      source: 'MongoService',
      level: 2,
    );
  }
}
