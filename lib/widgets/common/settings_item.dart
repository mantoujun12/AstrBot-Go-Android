import 'package:material_ui/material_ui.dart';

/// One settings row: title, hint subtitle, trailing control (e.g. a
/// Switch), mirroring the desktop SettingsItem component.
class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
