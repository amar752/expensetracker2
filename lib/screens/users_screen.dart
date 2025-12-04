import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/balance_provider.dart';
import '../models/user.dart';
import 'add_user_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final provider = context.read<UserProvider>();
    await provider.load();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addUser() async {
    final provider = context.read<UserProvider>();
    final created = await Navigator.push<User?>(
      context,
      MaterialPageRoute(builder: (_) => const AddUserScreen()),
    );
    if (!mounted) return;
    if (created != null) {
      // Ensure provider reloads and UI updates
      await provider.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final users = provider.users;
    final current = provider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF101225),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Users', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: _addUser,
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white70),
            tooltip: 'New user',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No users yet',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addUser,
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Create user'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final u = users[index];
                final isCurrent = current?.id == u.id;
                return ListTile(
                  tileColor: const Color(0xFF161936),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          u.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  subtitle: u.email != null && u.email!.isNotEmpty
                      ? Row(
                          children: [
                            Expanded(
                              child: Text(
                                u.email!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        )
                      : null,
                  leading: CircleAvatar(
                    backgroundColor: isCurrent
                        ? const Color(0xFF6C5CE7)
                        : Colors.white24,
                    child: Text(
                      u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCurrent)
                        IconButton(
                          onPressed: () async {
                            final provider = context.read<UserProvider>();
                            await provider.setCurrentUser(u);
                            if (!mounted) return;
                            // Reload data from the selected user's DB
                            await context.read<ExpenseProvider>().load();
                            await context.read<CategoryProvider>().load();
                            await context.read<BalanceProvider>().load();
                            setState(() {});
                          },
                          icon: const Icon(Icons.check, color: Colors.white70),
                          tooltip: 'Set current',
                        ),
                      IconButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF161936),
                              title: const Text(
                                'Delete user',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Are you sure you want to delete this user?',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final provider = context.read<UserProvider>();
                            await provider.deleteUser(u);
                          }
                        },
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: users.length,
            ),
    );
  }
}
