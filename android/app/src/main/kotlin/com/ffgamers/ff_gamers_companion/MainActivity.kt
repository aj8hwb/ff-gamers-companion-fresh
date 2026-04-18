package com.ffgamers.ff_gamers_companion

import android.os.Bundle
import android.app.ActivityManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.FileReader

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ffgamers.memory"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getMemoryInfo" -> {
                        val memInfo = getMemoryUsage()
                        result.success(memInfo)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getMemoryUsage(): Map<String, Any> {
        val memInfo = android.os.Debug.MemoryInfo()
        android.os.Debug.getMemoryInfo(memInfo)
        
        return mapOf(
            "dalvikPrivateDirty" to memInfo.dalvikPrivateDirty,
            "nativePrivateDirty" to memInfo.nativePrivateDirty,
            "otherPrivateDirty" to memInfo.otherPrivateDirty,
            "totalPss" to memInfo.totalPss
        )
    }
}