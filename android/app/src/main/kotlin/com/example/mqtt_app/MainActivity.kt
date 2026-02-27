// android/app/src/main/kotlin/com/upgrade/mqtt_app/MainActivity.kt
// Replace your existing MainActivity.kt with this file.
// (adjust the package name to match yours if different)

package com.example.mqtt_app

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val BATTERY_CHANNEL = "com.example.mqtt_app/battery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "openBatterySettings") {
                    try {
                        // Try to open the exact battery optimization page for this app
                        val intent = Intent(
                            Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        try {
                            // Fallback: open the general battery optimization list
                            val intent = Intent(
                                Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS
                            )
                            startActivity(intent)
                            result.success(null)
                        } catch (e2: Exception) {
                            result.error("UNAVAILABLE", "Cannot open battery settings", null)
                        }
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}