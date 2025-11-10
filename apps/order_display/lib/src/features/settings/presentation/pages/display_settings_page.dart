import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/audio_announcement_service.dart';

/// Display Settings Page
///
/// Configure display appearance, language, audio, and other options
class DisplaySettingsPage extends ConsumerStatefulWidget {
  const DisplaySettingsPage({super.key});

  @override
  ConsumerState<DisplaySettingsPage> createState() => _DisplaySettingsPageState();
}

class _DisplaySettingsPageState extends ConsumerState<DisplaySettingsPage> {
  String _selectedLanguage = 'en';
  String _selectedTheme = 'default';
  bool _audioEnabled = true;
  double _audioVolume = 0.8;
  bool _showEstimatedTime = true;
  bool _showOrderType = true;
  int _refreshInterval = 3;

  @override
  void initState() {
    super.initState();
    _audioEnabled = audioAnnouncementService.isEnabled;
    _audioVolume = audioAnnouncementService.volume;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Settings'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          FilledButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Language settings
            _buildSection(
              context,
              title: 'Language',
              icon: Icons.language,
              child: Column(
                children: [
                  _buildLanguageOption('English', 'en', '🇺🇸'),
                  _buildLanguageOption('Español', 'es', '🇪🇸'),
                  _buildLanguageOption('العربية', 'ar', '🇸🇦'),
                  _buildLanguageOption('Français', 'fr', '🇫🇷'),
                  _buildLanguageOption('中文', 'zh', '🇨🇳'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Audio settings
            _buildSection(
              context,
              title: 'Audio Announcements',
              icon: Icons.volume_up,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Audio'),
                    subtitle: const Text('Play sound for new orders'),
                    value: _audioEnabled,
                    onChanged: (value) {
                      setState(() {
                        _audioEnabled = value;
                      });
                      audioAnnouncementService.setEnabled(value);
                    },
                  ),
                  if (_audioEnabled) ...[
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Volume'),
                      subtitle: Slider(
                        value: _audioVolume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: '${(_audioVolume * 100).toInt()}%',
                        onChanged: (value) {
                          setState(() {
                            _audioVolume = value;
                          });
                          audioAnnouncementService.setVolume(value);
                        },
                      ),
                      trailing: Text(
                        '${(_audioVolume * 100).toInt()}%',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    ListTile(
                      title: const Text('Test Audio'),
                      trailing: FilledButton.icon(
                        onPressed: () {
                          audioAnnouncementService.announceNowServing(
                            '123',
                            language: _selectedLanguage,
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Test'),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Display settings
            _buildSection(
              context,
              title: 'Display Options',
              icon: Icons.display_settings,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Show Estimated Time'),
                    subtitle: const Text('Display wait time estimates'),
                    value: _showEstimatedTime,
                    onChanged: (value) {
                      setState(() {
                        _showEstimatedTime = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Show Order Type'),
                    subtitle: const Text('Display dine-in, takeaway, or delivery'),
                    value: _showOrderType,
                    onChanged: (value) {
                      setState(() {
                        _showOrderType = value;
                      });
                    },
                  ),
                  ListTile(
                    title: const Text('Refresh Interval'),
                    subtitle: Text('Update every $_refreshInterval seconds'),
                    trailing: DropdownButton<int>(
                      value: _refreshInterval,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1s')),
                        DropdownMenuItem(value: 2, child: Text('2s')),
                        DropdownMenuItem(value: 3, child: Text('3s')),
                        DropdownMenuItem(value: 5, child: Text('5s')),
                        DropdownMenuItem(value: 10, child: Text('10s')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _refreshInterval = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Theme settings
            _buildSection(
              context,
              title: 'Theme',
              icon: Icons.palette,
              child: Column(
                children: [
                  _buildThemeOption('Default', 'default', Colors.blue),
                  _buildThemeOption('Red', 'red', Colors.red),
                  _buildThemeOption('Green', 'green', Colors.green),
                  _buildThemeOption('Purple', 'purple', Colors.purple),
                  _buildThemeOption('Orange', 'orange', Colors.orange),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Preview button
            Card(
              child: ListTile(
                leading: const Icon(Icons.preview),
                title: const Text('Preview Display'),
                subtitle: const Text('See how your settings look'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  context.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String name, String code, String flag) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(name),
        ],
      ),
      value: code,
      groupValue: _selectedLanguage,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedLanguage = value;
          });
        }
      },
    );
  }

  Widget _buildThemeOption(String name, String code, Color color) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(name),
        ],
      ),
      value: code,
      groupValue: _selectedTheme,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedTheme = value;
          });
        }
      },
    );
  }

  void _saveSettings() {
    // In a real app, save to shared preferences or database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );

    context.pop();
  }
}
