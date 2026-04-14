package com.ffgamers.ff_gamers_companion

import android.app.ActivityManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Process
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "ff_gamers/memory"
    private val PERMISSION_CHANNEL = "ff_gamers/permissions"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getMemoryInfo" -> result.success(getMemoryInfo())
                "optimizeMemory" -> result.success(optimizeMemory())
                "getRunningProcesses" -> result.success(getRunningProcesses())
                "killBackgroundProcesses" -> result.success(killBackgroundProcesses())
                "getInstalledGames" -> result.success(getInstalledGames())
                "getAppUsageStats" -> result.success(getAppUsageStats())
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERMISSION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkUsageStatsPermission" -> result.success(checkUsageStatsPermission())
                "checkOverlayPermission" -> result.success(checkOverlayPermission())
                "checkRootAccess" -> result.success(checkRootAccess())
                else -> result.notImplemented()
            }
        }
    }

    private fun getMemoryInfo(): Map<String, Any> {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memInfo)

        val runtime = Runtime.getRuntime()
        val usedMemory = (runtime.totalMemory() - runtime.freeMemory()) / (1024 * 1024)
        val totalMemory = runtime.totalMemory() / (1024 * 1024)
        val freeMemory = runtime.freeMemory() / (1024 * 1024)
        val availableMemory = memInfo.availMem / (1024 * 1024)

        return mapOf(
            "totalMB" to (memInfo.totalMem / (1024 * 1024)).toInt(),
            "usedMB" to usedMemory.toInt(),
            "freeMB" to availableMemory.toInt(),
            "usagePercent" to ((usedMemory.toFloat() / totalMemory) * 100).toInt(),
            "lowMemory" to memInfo.lowMemory,
            "threshold" to (memInfo.threshold / (1024 * 1024)).toInt()
        )
    }

    private fun optimizeMemory(): Int {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        var killedCount = 0

        val runningProcesses = activityManager.runningAppProcesses
        for (process in runningProcesses) {
            if (process.importance >= ActivityManager.RunningAppProcessInfo.IMPORTANCE_SERVICE) {
                for (pid in process.pids) {
                    try {
                        Process.killProcess(pid)
                        killedCount++
                    } catch (e: Exception) {
                        // Skip protected processes
                    }
                }
            }
        }

        System.runFinalization()
        Runtime.getRuntime().gc()
        Thread.sleep(500)

        return killedCount
    }

    private fun getRunningProcesses(): List<Map<String, Any>> {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val processes = mutableListOf<Map<String, Any>>()

        val runningProcesses = activityManager.runningAppProcesses
        for (process in runningProcesses) {
            val memInfo = ActivityManager.MemoryInfo()
            activityManager.getMemoryInfo(memInfo)

            val packageName = process.processName.substringAfterLast(":")
            if (packageName.isNotEmpty() && packageName != process.processName) {
                val memUsage = process.memInfo?.let {
                    (it.dalvikPrivateDirty + it.nativePrivateDirty + it.otherPrivateDirty) / 1024
                } ?: 0

                processes.add(mapOf(
                    "name" to getAppName(packageName),
                    "package" to packageName,
                    "pid" to process.pid.firstOrNull() ?: 0,
                    "memoryMB" to memUsage,
                    "importance" to process.importance
                ))
            }
        }

        return processes.sortedByDescending { it["memoryMB"] as Int }.take(10)
    }

    private fun killBackgroundProcesses(): Int {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        var killedCount = 0

        val runningProcesses = activityManager.runningAppProcesses
        for (process in runningProcesses) {
            if (process.importance >= ActivityManager.RunningAppProcessInfo.IMPORTANCE_BACKGROUND) {
                val packageName = process.processName.substringAfterLast(":")
                if (packageName.isNotEmpty()) {
                    try {
                        activityManager.killBackgroundProcesses(packageName)
                        killedCount++
                    } catch (e: Exception) {
                        // Skip protected apps
                    }
                }
            }
        }

        return killedCount
    }

    private fun getInstalledGames(): List<Map<String, Any>> {
        val packageManager = packageManager
        val games = mutableListOf<Map<String, Any>>()

        val gamePackages = listOf(
            "com.garena.game.codm", "com.tencent.ig", "com.pubg.krmobile",
            "com.activision.callofduty.warzone", "com.ea.gp.apexlegendsmobilefps",
            "com.epicgames.fortnite", "com.mihoyo.honkai3rd", "com.miHoYo.GenshinImpact",
            "com.supercell.clashofclans", "com.supercell.brawlstars",
            "com.king.candycrushsaga", "com.rovio.bounce", "com.miniclip.androidgames"
        )

        for (packageName in gamePackages) {
            try {
                val appInfo = packageManager.getApplicationInfo(packageName, 0)
                games.add(mapOf(
                    "name" to packageManager.getApplicationLabel(appInfo),
                    "package" to packageName,
                    "installed" to true
                ))
            } catch (e: Exception) {
                // Game not installed
            }
        }

        // Also scan all installed apps for game-like apps
        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        for (app in installedApps) {
            if ((app.category == ApplicationInfo.CATEGORY_GAME || 
                 app.packageName.contains("game", ignoreCase = true)) &&
                games.none { it["package"] == app.packageName }) {
                games.add(mapOf(
                    "name" to packageManager.getApplicationLabel(app),
                    "package" to app.packageName,
                    "installed" to true
                ))
            }
        }

        return games
    }

    private fun getAppUsageStats(): List<Map<String, Any>> {
        if (!checkUsageStatsPermission()) {
            return emptyList()
        }

        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - (24 * 60 * 60 * 1000) // Last 24 hours

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        val result = mutableListOf<Map<String, Any>>()
        for (stat in stats) {
            if (stat.totalTimeInForeground > 0) {
                result.add(mapOf(
                    "package" to stat.packageName,
                    "name" to getAppName(stat.packageName),
                    "usageTime" to (stat.totalTimeInForeground / 60000), // Minutes
                    "lastUsed" to stat.lastTimeUsed
                ))
            }
        }

        return result.sortedByDescending { it["usageTime"] as Long }.take(15)
    }

    private fun getAppName(packageName: String): String {
        return try {
            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            packageName.substringAfterLast(".")
        }
    }

    private fun checkUsageStatsPermission(): Boolean {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - (1000 * 60)
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )
        return stats != null && stats.isNotEmpty()
    }

    private fun checkOverlayPermission(): Boolean {
        return android.provider.Settings.canDrawOverlays(this)
    }

    private fun checkRootAccess(): Boolean {
        val process = java.lang.Runtime.getRuntime().exec("su -c id")
        val output = java.io.BufferedReader(java.io.InputStreamReader(process.inputStream)).readLine()
        return output != null && output.contains("uid=0")
    }
}