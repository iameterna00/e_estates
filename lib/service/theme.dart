import 'package:flutter/material.dart';

class ThemePage extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;

  const ThemePage({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    // Determine if the current theme mode is dark to toggle the switch accordingly
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Theme Settings"), // const added for performance
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemeToggleButton(
              title: 'Light Theme',
              isActive: !isDarkMode,
              onToggle: () => onThemeChanged(ThemeMode.light),
            ),
            const SizedBox(height: 20), // const added for performance
            ThemeToggleButton(
              title: 'Dark Theme',
              isActive: isDarkMode,
              onToggle: () => onThemeChanged(ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onToggle;

  const ThemeToggleButton({
    super.key,
    required this.title,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onToggle,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive
            ? Colors.blue
            : Colors.grey, // Simplify logic for button color
      ),
      child: Text(title),
    );
  }
}
