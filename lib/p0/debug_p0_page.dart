import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart' show PlatformException;

import 'p0_channel.dart';

/// Staged tarball location used by docs/P0_RUNBOOK.md (adb push + run-as copy).
const _defaultTarZstPath =
    '/data/data/io.github.mantoujun12.astrbot_go/files/rootfs.tar.zst';

/// P0 verification commands from docs/P0_VERIFICATION.md items 1-2.
class _Preset {
  const _Preset(this.label, this.argv);

  final String label;
  final List<String> argv;
}

const _presets = [
  _Preset(
    'Item 1: cat /etc/debian_version && uv --version',
    ['bash', '-c', 'cat /etc/debian_version && uv --version'],
  ),
  _Preset(
    'Item 2a: python3.12 -c "import ssl, sqlite3"',
    ['python3.12', '-c', 'import ssl, sqlite3'],
  ),
  _Preset(
    'Item 2b: uv venv /opt/astrbot-venv',
    ['uv', 'venv', '/opt/astrbot-venv'],
  ),
];

class _RunRecord {
  _RunRecord(this.argv, this.result, this.error);

  final List<String> argv;
  final P0RunResult? result;
  final String? error;
}

/// Debug-only P0 verification page: extract the staged base rootfs and run
/// the PRoot smoke commands from docs/P0_VERIFICATION.md.
class DebugP0Page extends StatefulWidget {
  const DebugP0Page({super.key});

  @override
  State<DebugP0Page> createState() => _DebugP0PageState();
}

class _DebugP0PageState extends State<DebugP0Page> {
  final _tarZstController = TextEditingController(text: _defaultTarZstPath);
  final _commandController = TextEditingController();

  P0Status? _status;
  String? _statusError;
  bool _extracting = false;
  final List<_RunRecord> _runs = [];

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  @override
  void dispose() {
    _tarZstController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    try {
      final status = await P0Channel.status();
      setState(() {
        _status = status;
        _statusError = null;
      });
    } on PlatformException catch (e) {
      setState(() => _statusError = e.message);
    } catch (e) {
      setState(() {
        _statusError = e.toString();
        _status = null;
      });
    }
  }

  Future<void> _extract() async {
    setState(() => _extracting = true);
    String? error;
    int entries = 0;
    try {
      final result = await P0Channel.extractBaseImage(
        tarZstPath: _tarZstController.text.trim(),
      );
      if (!result.ok) {
        error = result.error ?? 'extraction failed';
      } else {
        entries = result.entries;
      }
    } on PlatformException catch (e) {
      error = e.message;
    } catch (e) {
      error = e.toString();
    }
    await _refreshStatus();
    setState(() {
      _extracting = false;
      _runs.insert(
        0,
        _RunRecord(
          ['extractBaseImage', _tarZstController.text.trim()],
          error == null
              ? P0RunResult(
                  exitCode: 0,
                  output: 'Extracted $entries entries.',
                  durationMs: 0,
                  timedOut: false,
                )
              : null,
          error,
        ),
      );
    });
  }

  Future<void> _runArgv(List<String> argv) async {
    try {
      final result = await P0Channel.runProot(argv);
      setState(() => _runs.insert(0, _RunRecord(argv, result, null)));
    } on PlatformException catch (e) {
      setState(() => _runs.insert(0, _RunRecord(argv, null, e.message)));
    } catch (e) {
      setState(() => _runs.insert(0, _RunRecord(argv, null, e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('P0 Verification (debug)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _statusCard(theme),
          const SizedBox(height: 8),
          _extractCard(theme),
          const SizedBox(height: 8),
          _presetsCard(theme),
          const SizedBox(height: 8),
          _commandCard(theme),
          const SizedBox(height: 8),
          for (final run in _runs) _runCard(theme, run),
        ],
      ),
    );
  }

  Widget _statusCard(ThemeData theme) {
    final status = _status;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (status == null)
              Text(_statusError ?? 'Loading...')
            else ...[
              _statusRow('Base rootfs extracted',
                  status.extractedRootfsDir ?? 'no'),
              _statusRow('Native library dir', status.nativeLibraryDir),
              _statusRow('Bundled native libs', status.jniLibs.join(', ')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text('$label: $value', style: const TextStyle(fontFamily: 'monospace')),
      );

  Widget _extractCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Base image', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _tarZstController,
              decoration: const InputDecoration(
                labelText: 'Staged rootfs.tar.zst path',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _extracting ? null : _extract,
              icon: _extracting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.archive),
              label: Text(_extracting ? 'Extracting...' : 'Extract base image'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('P0 check presets', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final preset in _presets)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _runArgv(preset.argv),
                    child: Text(preset.label),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _commandCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Free-form command', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _commandController,
              decoration: const InputDecoration(
                labelText: 'argv (split on whitespace, no shell)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                final argv =
                    _commandController.text.trim().split(RegExp(r'\s+'));
                if (argv.isNotEmpty && argv.first.isNotEmpty) {
                  _runArgv(argv);
                }
              },
              child: const Text('Run in PRoot'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _runCard(ThemeData theme, _RunRecord run) {
    final result = run.result;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(run.argv.join(' '),
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontFamily: 'monospace')),
            const SizedBox(height: 8),
            if (run.error != null)
              Text('Error: ${run.error}', style: TextStyle(color: theme.colorScheme.error))
            else ...[
              Text(
                'exit ${result!.exitCode ?? 'none (timed out)'}'
                ' in ${result.durationMs} ms${result.timedOut ? ' (timed out)' : ''}',
                style: TextStyle(
                  color: result.timedOut || result.exitCode != 0
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                result.output.isEmpty ? '(no output)' : result.output,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
