import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../data/data_sources/local/hive_service.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/chat_history_model.dart';
import '../../../../data/models/search_history_model.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/constants/countries.dart';
import '../../../common/widgets/country_dropdown.dart';
import '../../profile/views/profile_view.dart';
import '../../auth/views/login_view.dart';

class AppDrawer extends StatefulWidget {
  final UserModel? user;
  final Function(AppTheme) onThemeChanged;

  const AppDrawer({
    super.key,
    required this.user,
    required this.onThemeChanged,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<ChatHistoryModel> _chatHistory = [];
  List<SearchHistoryModel> _searchHistory = [];
  String _selectedCountry = 'India';
  bool _showSearchHistory = true; // Toggle between chat and search

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _selectedCountry = HiveService.getSelectedTheme();
  }

  void _loadHistory() {
    setState(() {
      _chatHistory = HiveService.getAllChatHistory();
      _searchHistory = HiveService.getAllSearchHistory();
    });
  }

  void _onCountryChanged(String country) {
    setState(() {
      _selectedCountry = country;
    });
    
    HiveService.saveSelectedTheme(country);
    
    final theme = _getThemeFromCountry(country);
    widget.onThemeChanged(theme);
    
    Navigator.pop(context);
  }

  AppTheme _getThemeFromCountry(String country) {
    switch (country) {
      case 'India':
        return AppTheme.india;
      case 'Bangladesh':
        return AppTheme.bangladesh;
      case 'Nepal':
        return AppTheme.nepal;
      case 'Bhutan':
        return AppTheme.bhutan;
      case 'Singapore':
        return AppTheme.singapore;
      case 'Sri Lanka':
        return AppTheme.sriLanka;
      default:
        return AppTheme.india;
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await HiveService.updateLoginStatus(false);
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginView(
              onThemeChanged: widget.onThemeChanged,
            ),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            _buildDrawerHeader(theme),
            Expanded(child: _buildHistorySection(theme)),
            _buildBottomActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileView(
                        onThemeChanged: widget.onThemeChanged,
                        onProfileUpdated: () {},
                      ),
                    ),
                  );
                },
                child: _buildProfileAvatar(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user?.fullName ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    if (widget.user?.profileImagePath != null && 
        widget.user!.profileImagePath!.isNotEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          image: DecorationImage(
            image: FileImage(File(widget.user!.profileImagePath!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.3),
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Center(
          child: Text(
            widget.user?.initials ?? 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildHistorySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle between Search and Chat History
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showSearchHistory = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _showSearchHistory 
                          ? theme.primaryColor 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          color: _showSearchHistory 
                              ? Colors.white 
                              : theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Search History',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _showSearchHistory 
                                ? Colors.white 
                                : theme.colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showSearchHistory = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_showSearchHistory 
                          ? theme.primaryColor 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: !_showSearchHistory 
                              ? Colors.white 
                              : theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Chat History',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: !_showSearchHistory 
                                ? Colors.white 
                                : theme.colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: _showSearchHistory 
              ? _buildSearchHistoryList(theme)
              : _buildChatHistoryList(theme),
        ),
      ],
    );
  }

  Widget _buildSearchHistoryList(ThemeData theme) {
    if (_searchHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 60,
                color: theme.colorScheme.tertiary.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No search history yet',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.tertiary.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _searchHistory.length,
      itemBuilder: (context, index) {
        final search = _searchHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.history,
                color: theme.primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              search.productName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.tertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Searched ${search.searchCount} time${search.searchCount > 1 ? "s" : ""}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.tertiary.withOpacity(0.6),
              ),
            ),
            trailing: Text(
              _getTimeAgo(search.searchedAt),
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.tertiary.withOpacity(0.5),
              ),
            ),
            onTap: () {
              // TODO: Will implement navigation to search with this query
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Search for: ${search.productName}'),
                  backgroundColor: theme.primaryColor,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildChatHistoryList(ThemeData theme) {
    if (_chatHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: theme.colorScheme.tertiary.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No chat history yet',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.tertiary.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _chatHistory.length,
      itemBuilder: (context, index) {
        final chat = _chatHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: theme.primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              chat.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.tertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              chat.lastMessage,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.tertiary.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red.withOpacity(0.7),
                size: 20,
              ),
              onPressed: () async {
                await HiveService.deleteChatHistory(chat.id);
                _loadHistory();
              },
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildBottomActions(ThemeData theme) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CountryDropdown(
              selectedCountry: _selectedCountry,
              onCountryChanged: _onCountryChanged,
              showLabel: false,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.person_outline,
              label: 'View Profile',
              theme: theme,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileView(
                      onThemeChanged: widget.onThemeChanged,
                      onProfileUpdated: () {},
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              icon: Icons.logout,
              label: 'Logout',
              theme: theme,
              isDestructive: true,
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required ThemeData theme,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : theme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
