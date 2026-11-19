import 'package:flutter/services.dart';

/// Snapshot of the native P0 harness state.
class P0Status {
  const P0Status({
    required this.extractedRootfsDir,
    required this.nativeLibraryDir,
    required this.jniLibs,
  });

  /// Absolute path of the extracted base rootfs, or null if not extracted yet.
  final String? extractedRootfsDir;

  /// Directory where the bundled PRoot binaries were extracted.
  final String nativeLibraryDir;

  /// File names of the bundled native libraries.
  final List<String> jniLibs;

  factory P0Status.fromMap(Map<Object?, Object?> map) => P0Status(
        extractedRootfsDir: map['extractedRootfsDir'] as String?,
        nativeLibraryDir: map['nativeLibraryDir']! as String,
        jniLibs: (map['jniLibs']! as List<Object?>).cast<String>(),
      );
}

/// Result of a base image extraction.
class P0ExtractResult {
  const P0ExtractResult({
    required this.ok,
    required this.entries,
    required this.durationMs,
    this.error,
  });

  final bool ok;

  /// Number of tar entries extracted (only meaningful when [ok] is true).
  final int entries;

  final int durationMs;

  /// Failure description when [ok] is false.
  final String? error;

  factory P0ExtractResult.fromMap(Map<Object?, Object?> map) => P0ExtractResult(
        ok: map['ok']! as bool,
        entries: (map['entries'] as int?) ?? 0,
        durationMs: (map['durationMs'] as int?) ?? 0,
        error: map['error'] as String?,
      );
}

/// Result of one PRoot command run.
class P0RunResult {
  const P0RunResult({
    required this.exitCode,
    required this.output,
    required this.durationMs,
    required this.timedOut,
  });

  /// Guest exit code, or null when the run timed out.
  final int? exitCode;

  /// Combined stdout and stderr of the guest command.
  final String output;

  final int durationMs;

  final bool timedOut;

  factory P0RunResult.fromMap(Map<Object?, Object?> map) => P0RunResult(
        exitCode: map['exitCode'] as int?,
        output: (map['output'] as String?) ?? '',
        durationMs: (map['durationMs'] as int?) ?? 0,
        timedOut: map['timedOut']! as bool,
      );
}

/// Thin typed wrapper over the debug-only `p0/run` MethodChannel.
///
/// Throws [PlatformException] when the channel refuses a call, e.g. in a
/// release build.
class P0Channel {
  P0Channel._();

  static const MethodChannel _channel = MethodChannel('p0/run');

  static Future<P0Status> status() async {
    final map = await _channel.invokeMethod<Map<Object?, Object?>>('status');
    return P0Status.fromMap(map ?? const {});
  }

  static Future<P0ExtractResult> extractBaseImage({
    required String tarZstPath,
    String? sha256Hex,
  }) async {
    final map = await _channel.invokeMethod<Map<Object?, Object?>>(
      'extractBaseImage',
      <String, Object?>{
        'tarZstPath': tarZstPath,
        'sha256Hex': sha256Hex,
      },
    );
    return P0ExtractResult.fromMap(map ?? const {});
  }

  static Future<P0RunResult> runProot(List<String> args, {int timeoutSec = 120}) async {
    final map = await _channel.invokeMethod<Map<Object?, Object?>>(
      'runProot',
      <String, Object?>{
        'args': args,
        'timeoutSec': timeoutSec,
      },
    );
    return P0RunResult.fromMap(map ?? const {});
  }
}
