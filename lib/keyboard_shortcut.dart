import 'package:flutter/material.dart';

class KeyboardShortcut extends StatelessWidget {
  final Widget child;
  final Map<ShortcutActivator, Intent> shortcuts;
  final Map<Type, Action<Intent>> actions;

  const KeyboardShortcut({
    super.key,
    required this.shortcuts,
    required this.actions,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: actions,
      child: Shortcuts(
        shortcuts: shortcuts,
        child: child,
      ),
    );
  }
}
