import 'package:material_ui/material_ui.dart';

import '../common/section_card.dart';
import 'network_source_card.dart';

/// Settings section for download sources, mirroring the desktop
/// NetworkSourceList. The Settings page consumes only this contract.
class NetworkSection extends StatelessWidget {
  const NetworkSection({super.key});

  // shortcut: presets are static until the settings store exists
  static const _githubPresets = [
    'https://github.com',
    'gh-proxy.com',
    'gh-proxy.org',
    'hk.gh-proxy.com',
    'edgeone.gh-proxy.com',
    'gh.llkk.cc',
  ];

  // shortcut: presets are static until the settings store exists
  static const _pypiPresets = [
    'https://pypi.org/simple',
    'https://mirrors.aliyun.com/pypi/simple',
    'https://mirrors.cloud.tencent.com/pypi/simple',
    'https://pypi.mirrors.ustc.edu.cn/simple',
    'https://pypi.tuna.tsinghua.edu.cn/simple',
    'https://mirrors.cernet.edu.cn/pypi/web/simple',
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      // No card title: the second-level page's app bar already names it.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetworkSourceCard(
            title: 'GitHub proxy',
            presets: _githubPresets,
            customHint: 'https://gh.example.com/ — custom GitHub proxy',
          ),
          const Divider(height: 24),
          NetworkSourceCard(
            title: 'PyPI mirror',
            presets: _pypiPresets,
            customHint: 'https://mirror.example.com/simple — custom PyPI index',
          ),
          const Divider(height: 24),
          const NetworkSourceCard(
            title: 'Custom artifact base URL',
            presets: [],
            customHint:
                'https://example.com/ — self-hosted mirror of base images '
                'and version packages',
          ),
        ],
      ),
    );
  }
}
