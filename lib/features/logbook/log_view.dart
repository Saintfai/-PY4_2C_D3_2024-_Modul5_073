import 'package:flutter/material.dart';
import 'package:logbook_app_073/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_073/features/logbook/log_controller.dart';
import 'package:logbook_app_073/features/logbook/models/log_model.dart';
import 'package:logbook_app_073/features/logbook/widgets/log_card.dart';
import 'package:logbook_app_073/features/logbook/widgets/log_empty_state.dart';
import 'package:logbook_app_073/features/logbook/log_editor_page.dart';
import 'package:logbook_app_073/services/access_policy.dart';
import 'package:logbook_app_073/features/vision/vision_view.dart';

// ────────────────────────────────────────────────────────────
// LogView
// ────────────────────────────────────────────────────────────
class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  final TextEditingController _searchController = TextEditingController();

  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier('');
  late Future<List<LogModel>> _logFuture;

  // 🛡️ simulated role & userId
  String get role =>
      widget.username.toLowerCase() == 'ketua' ? 'ketua' : 'anggota';
  String get userId => widget.username;

  @override
  void initState() {
    super.initState();
    _logFuture = _controller.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ── Dialog Selamat Datang ──────────────────────────────────
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selamat Datang'),
          content: Text(
            'Halo ${widget.username}, selamat menggunakan Logbook!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mulai'),
            ),
          ],
        );
      },
    );
  }

  // ── Navigasi Editor ──────────────────────────────────────
  Future<void> _navigateToEditor({LogModel? log, int? index}) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LogEditorPage(log: log, role: role, userId: userId),
      ),
    );

    if (result != null) {
      setState(() {
        if (log == null) {
          _logFuture = _controller.addLog(
            result['title'],
            result['description'],
            category: result['category'],
            authorId: userId,
            isPublic: result['isPublic'] ?? false,
          );
        } else {
          _logFuture = _controller.updateLog(
            index!,
            result['title'],
            result['description'],
            category: result['category'],
            isPublic: result['isPublic'] ?? false,
          );
        }
      });
    }
  }

  // ── Refresh Handler ──────────────────────────────────────
  Future<void> _handleRefresh() async {
    setState(() {
      _logFuture = _controller.loadFromCloud();
    });
    await _logFuture;
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Text(
                  widget.username.isNotEmpty
                      ? widget.username[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'My Logbook',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Smart Patrol Vision',
            icon: const Icon(Icons.camera_alt_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VisionView()),
              );
            },
          ),
          IconButton(
            icon: Badge(
              label: ValueListenableBuilder<List<LogModel>>(
                valueListenable: _controller.logsNotifier,
                builder: (context, logs, _) => Text('${logs.length}'),
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const OnboardingView(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari catatan...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (ctx, val, child) => val.text.isNotEmpty
                      ? IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.clear_rounded,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _searchQueryNotifier.value = '';
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                _searchQueryNotifier.value = value.toLowerCase();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<LogModel>>(
              future: _logFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            snapshot.error.toString().contains('internet')
                                ? Icons.wifi_off_rounded
                                : Icons.error_outline_rounded,
                            size: 80,
                            color: Colors.redAccent.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            snapshot.error.toString().contains('Exception: ')
                                ? snapshot.error.toString().replaceAll(
                                    'Exception: ',
                                    '',
                                  )
                                : 'Terjadi kesalahan saat memuat data.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _handleRefresh,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: Theme.of(context).primaryColor,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        alignment: Alignment.center,
                        child: const LogEmptyState(isSearching: false),
                      ),
                    ),
                  );
                }

                final logs = snapshot.data!;

                return ValueListenableBuilder<String>(
                  valueListenable: _searchQueryNotifier,
                  builder: (context, query, _) {
                    final filteredLogs = logs.where((log) {
                      // 🛡️ Visibility Check
                      final canSee = AccessPolicy.canView(
                        log: log,
                        currentUserId: userId,
                      );
                      if (!canSee) return false;

                      final titleMatch = log.title.toLowerCase().contains(query);
                      final descMatch = log.description.toLowerCase().contains(
                        query,
                      );
                      return titleMatch || descMatch;
                    }).toList();

                    if (filteredLogs.isEmpty && query.isNotEmpty) {
                      return RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: Theme.of(context).primaryColor,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            alignment: Alignment.center,
                            child: const LogEmptyState(isSearching: true),
                          ),
                        ),
                      );
                    }

                    if (filteredLogs.isEmpty && query.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: Theme.of(context).primaryColor,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            alignment: Alignment.center,
                            child: const LogEmptyState(isSearching: false),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: Theme.of(context).primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];

                          // 🛡️ Access Checks (Sovereignty: Only Author)
                          final bool canEdit = AccessPolicy.canEdit(
                            userId: userId,
                            logAuthorId: log.authorId,
                          );
                          final bool canDelete = AccessPolicy.canDelete(
                            userId: userId,
                            logAuthorId: log.authorId,
                          );

                          return Dismissible(
                            key: ValueKey(log.id ?? log.title + log.date),
                            direction: canDelete
                                ? DismissDirection.endToStart
                                : DismissDirection.none,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.delete_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              if (!canDelete) return false;
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: const Text('Hapus Catatan?'),
                                      content: Text(
                                        'Catatan "${log.title}" akan dihapus secara permanen.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ),
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (direction) {
                              final originalIndex = logs.indexOf(log);
                              setState(() {
                                _logFuture = _controller.removeLog(
                                  originalIndex,
                                );
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Catatan "${log.title}" dihapus.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  action: SnackBarAction(
                                    label: 'OK',
                                    onPressed: () {},
                                  ),
                                ),
                              );
                            },
                            child: AnimatedLogCard(
                              log: log,
                              index: index,
                              canEdit: canEdit,
                              canDelete: canDelete,
                              onTap: () {
                                if (canEdit) {
                                  final originalIndex = logs.indexOf(log);
                                  _navigateToEditor(
                                    log: log,
                                    index: originalIndex,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Anda tidak memiliki izin untuk mengedit catatan ini.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              onDelete: () async {
                                if (!canDelete) return;
                                final confirm =
                                    await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        title: const Text('Hapus Catatan?'),
                                        content: Text(
                                          'Catatan "${log.title}" akan dihapus secara permanen.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Batal'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                  10,
                                                ),
                                              ),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;

                                if (confirm) {
                                  final originalIndex = logs.indexOf(log);
                                  setState(() {
                                    _logFuture = _controller.removeLog(
                                      originalIndex,
                                    );
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditor(),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 8,
        icon: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 2 * 3.14159,
              child: const Icon(Icons.add_rounded),
            );
          },
        ),
        label: const Text(
          'Catatan Baru',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
