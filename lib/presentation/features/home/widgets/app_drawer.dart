import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../data/data_sources/local/hive_service.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/chat_history_model.dart';
import '../../../../core/theme/app_themes.dart';
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
  String _selectedCountry = 'India';

  final List<String> _countries = [
    'India',
    'Bangladesh',
    'Nepal',
    'Bhutan',
    'Singapore',
    'Sri Lanka',
  ];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _selectedCountry = HiveService.getSelectedTheme();
  }

  void _loadChatHistory() {
    setState(() {
      _chatHistory = HiveService.getAllChatHistory();
    });
  }

  void _onCountryChanged(String? country) {
    if (country != null) {
      setState(() {
        _selectedCountry = country;
      });
      
      HiveService.saveSelectedTheme(country);
      
      final theme = _getThemeFromCountry(country);
      widget.onThemeChanged(theme);
      
      Navigator.pop(context);
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            // Drawer Header
            _buildDrawerHeader(theme),
            
            // Chat History Section
            Expanded(
              child: _buildChatHistorySection(theme),
            ),
            
            // Bottom Actions
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
              // Profile Picture
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
              
              // User Info
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

  Widget _buildChatHistorySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.history, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Chat History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: _chatHistory.isEmpty
              ? Center(
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
                        const SizedBox(height: 8),
                        Text(
                          'Start a conversation to see your history here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.tertiary.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _chatHistory.length,
                  itemBuilder: (context, index) {
                    final chat = _chatHistory[index];
                    return _buildChatHistoryItem(chat, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildChatHistoryItem(ChatHistoryModel chat, ThemeData theme) {
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
            _loadChatHistory();
          },
        ),
        onTap: () {
          // Navigate to chat detail
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme) {
    return Container(
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
          // Country Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCountry,
                      isExpanded: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: theme.primaryColor,
                      ),
                      items: _countries.map((String country) {
                        return DropdownMenuItem<String>(
                          value: country,
                          child: Text(
                            country,
                            style: TextStyle(
                              color: theme.colorScheme.tertiary,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: _onCountryChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Profile Button
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
          
          // Logout Button
          _buildActionButton(
            icon: Icons.logout,
            label: 'Logout',
            theme: theme,
            isDestructive: true,
            onTap: _logout,
          ),
        ],
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
