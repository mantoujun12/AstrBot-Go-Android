import 'package:material_ui/material_ui.dart';

import '../common/app_toast.dart';
import '../common/section_card.dart';
import '../common/settings_item.dart';

/// 'General' settings card: background behavior switches. Mock state
/// only; nothing persists yet.
class GeneralSection extends StatefulWidget {
  const GeneralSection({super.key});

  @override
  State<GeneralSection> createState() => _GeneralSectionState();
}

class _GeneralSectionState extends State<GeneralSection> {
  bool _restoreOnBoot = false;
  bool _restartAfterCrash = false;

  void _toggle(void Function(bool) set, bool value) {
    setState(() => set(value));
    // shortcut: no persistence until the P1 settings store
    showAppToast(context, 'Saved (mock)');
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      // No card title: the second-level page's app bar already names it.
      child: Column(
        children: [
          SettingsItem(
            title: 'Restore instances on boot',
            subtitle: 'Restart instances that were running when the app closed',
            trailing: Switch(
              value: _restoreOnBoot,
              onChanged: (v) => _toggle((x) => _restoreOnBoot = x, v),
            ),
          ),
          SettingsItem(
            title: 'Restart after abnormal exit',
            subtitle: 'Automatically restart crashed instances (per-instance setting)',
            trailing: Switch(
              value: _restartAfterCrash,
              onChanged: (v) => _toggle((x) => _restartAfterCrash = x, v),
            ),
          ),
        ],
      ),
    );
  }
}
