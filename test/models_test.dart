import 'package:flutter_test/flutter_test.dart';

import 'package:astrbot_go/models/instance.dart';
import 'package:astrbot_go/models/version_entry.dart';
import 'package:astrbot_go/state/app_state.dart';

void main() {
  test('InstanceStateX labels and isTransition cover all four states', () {
    expect(InstanceState.stopped.label, 'Stopped');
    expect(InstanceState.starting.label, 'Starting');
    expect(InstanceState.running.label, 'Running');
    expect(InstanceState.stopping.label, 'Stopping');

    expect(InstanceState.stopped.isTransition, isFalse);
    expect(InstanceState.running.isTransition, isFalse);
    expect(InstanceState.starting.isTransition, isTrue);
    expect(InstanceState.stopping.isTransition, isTrue);
  });

  test('copyWith updates a field and clear flags reset to null', () {
    final instance = Instance(
      id: 'i',
      name: 'bot',
      version: 'v1.0.0',
      port: 6185,
      state: InstanceState.stopped,
      startedAt: DateTime(2026, 1, 1),
      lastExitReason: 'crashed',
    );

    final renamed = instance.copyWith(name: 'bot2');
    expect(renamed.name, 'bot2');
    expect(renamed.startedAt, instance.startedAt);
    expect(renamed.lastExitReason, 'crashed');

    final cleared = instance.copyWith(
      clearStartedAt: true,
      clearLastExitReason: true,
    );
    expect(cleared.startedAt, isNull);
    expect(cleared.lastExitReason, isNull);
  });

  test('Instance.webUiUrl formats host and port', () {
    const instance = Instance(
      id: 'i',
      name: 'bot',
      version: 'v1.0.0',
      port: 6185,
      state: InstanceState.stopped,
    );
    expect(instance.webUiUrl, 'http://127.0.0.1:6185/');
  });

  test('MockAppState.freePort skips ports taken by instances', () {
    final state = MockAppState();
    expect(state.freePort, 6185 + 2); // 6185/6186 are in use
  });

  test('MockAppState.addInstance creates a stopped instance and returns its id',
      () {
    final state = MockAppState();
    final before = state.instances.length;

    final id = state.addInstance(name: 'new-bot', version: 'v4.30.0');

    expect(state.instances, hasLength(before + 1));
    final added = state.instanceById(id);
    expect(added, isNotNull);
    expect(added!.state, InstanceState.stopped);
    expect(added.name, 'new-bot');
    expect(added.version, 'v4.30.0');
    expect(state.instances.map((i) => i.id).toSet(), hasLength(state.instances.length));

    final secondId = state.addInstance(name: 'another', version: 'v4.30.0');
    final second = state.instanceById(secondId)!;
    expect(second.port, isNot(added.port));
  });

  test('MockAppState.delete removes the instance and notifies listeners', () {
    final state = MockAppState();
    var notifications = 0;
    state.addListener(() => notifications++);

    state.delete('inst-a1b2c3');

    expect(state.instanceById('inst-a1b2c3'), isNull);
    expect(state.instances, hasLength(1));
    expect(notifications, 1);
  });

  test('MockAppState.start transitions through starting to running', () async {
    final state = MockAppState();
    final states = <InstanceState>[];
    state.addListener(() {
      final instance = state.instanceById('inst-d4e5f6');
      if (instance != null) states.add(instance.state);
    });

    await state.start('inst-d4e5f6');

    expect(states.first, InstanceState.starting);
    expect(states.last, InstanceState.running);
    final instance = state.instanceById('inst-d4e5f6')!;
    expect(instance.state, InstanceState.running);
    expect(instance.startedAt, isNotNull);
    expect(instance.lastExitReason, isNull);
  }, timeout: const Timeout(Duration(seconds: 5)));

  test('VersionEntry.isPreRelease follows the channel field', () {
    const stable = VersionEntry(
      tag: 'v4.29.3',
      channel: 'stable',
      installed: true,
    );
    const pre = VersionEntry(
      tag: 'v4.30.0-beta.1',
      channel: 'pre-release',
      installed: false,
    );
    expect(stable.isPreRelease, isFalse);
    expect(pre.isPreRelease, isTrue);
  });
}
