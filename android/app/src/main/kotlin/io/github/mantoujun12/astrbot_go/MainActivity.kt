package io.github.mantoujun12.astrbot_go

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Debug-only P0 verification harness; refuses calls in release builds.
        P0MethodChannel(applicationContext).register(flutterEngine.dartExecutor.binaryMessenger)
    }
}
