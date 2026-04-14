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
    private val OVERLAY_CHANNEL = "ff_gamers/overlay"

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
                "getDeviceInfo" -> result.success(getDeviceInfo())
                "getDisplayInfo" -> result.success(getDisplayInfo())
                "getRefreshRate" -> result.success(getRefreshRate())
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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOverlayPermission" -> result.success(checkOverlayPermission())
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(true)
                }
                "startOverlay" -> {
                    startOverlayService(call)
                    result.success(true)
                }
                "stopOverlay" -> {
                    stopOverlayService()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startOverlayService(call: io.flutter.plugin.common.MethodCall) {
        val intent = android.content.Intent(this, OverlayService::class.java).apply {
            action = "START"
            putExtra("x", call.argument<Double>("x") ?: 0.5)
            putExtra("y", call.argument<Double>("y") ?: 0.5)
            putExtra("size", call.argument<Double>("size") ?: 50.0)
            putExtra("color", call.argument<Int>("color") ?: 0xFF00FF88)
            putExtra("isLocked", call.argument<Boolean>("isLocked") ?: false)
        }
        startService(intent)
    }

    private fun stopOverlayService() {
        val intent = android.content.Intent(this, OverlayService::class.java).apply {
            action = "STOP"
        }
        startService(intent)
    }

    private fun requestOverlayPermission() {
        val intent = android.content.Intent(
            android.provider.Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            android.net.Uri.parse("package:$packageName")
        )
        startActivity(intent)
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

    private fun getDeviceInfo(): Map<String, Any> {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memInfo)
        
        val totalRAM = (memInfo.totalMem / (1024 * 1024 * 1024)).toInt()
        val availableRAM = (memInfo.availMem / (1024 * 1024 * 1024)).toDouble()
        
        val modelName = getFriendlyDeviceName(Build.MODEL)
        val processor = getProcessorName()
        val chipset = getChipset()
        
        return mapOf(
            "model" to modelName,
            "brand" to Build.BRAND.replaceFirstChar { it.uppercase() },
            "device" to Build.DEVICE,
            "hardware" to Build.HARDWARE,
            "processor" to processor,
            "chipset" to chipset,
            "totalRAMGB" to totalRAM,
            "availableRAMGB" to availableRAM,
            "androidVersion" to Build.VERSION.RELEASE,
            "sdkVersion" to Build.VERSION.SDK_INT,
        )
    }

    private fun getFriendlyDeviceName(model: String): String {
        val friendlyNames = mapOf(
            "SM-G998" to "Samsung Galaxy S21 Ultra",
            "SM-G991" to "Samsung Galaxy S21",
            "SM-F936" to "Samsung Galaxy Z Fold 3",
            "SM-A525" to "Samsung Galaxy A52",
            "RMX3081" to "Realme 8",
            "RMX3085" to "Realme 8 5G",
            "RMX2195" to "Realme C3",
            "M2006C3MG" to "Redmi 9C",
            "M2101K7AG" to "Redmi Note 10",
            "M2104K10I" to "POCO X3 Pro",
            "V2111" to "Vivo Y33s",
            "CPH2197" to "Oppo A15",
            "RMX2101" to "Realme 7",
            "Infinix X695" to "Infinix Note 10 Pro",
            "Tecno KF6" to "Tecno Spark 8",
        )
        return friendlyNames[model] ?: model
    }

    private fun getProcessorName(): String {
        return try {
            val cpuInfo = java.io.File("/proc/cpuinfo").readText()
            val hardwareLine = cpuInfo.lines().find { it.startsWith("Hardware") }
            hardwareLine?.substringAfter(":")?.trim() 
                ?: java.lang.Runtime.getRuntime().availableProcessors().toString() + " Cores"
        } catch (e: Exception) {
            "${java.lang.Runtime.getRuntime().availableProcessors()} Cores"
        }
    }

    private fun getChipset(): String {
        return when {
            Build.HARDWARE.contains("qcom") || Build.HARDWARE.contains("snapdragon") -> "Qualcomm Snapdragon"
            Build.HARDWARE.contains("mt") || Build.HARDWARE.contains("mediatek") -> "MediaTek"
            Build.HARDWARE.contains("exynos") -> "Samsung Exynos"
            Build.HARDWARE.contains("kirin") -> "HiSilicon Kirin"
            Build.HARDWARE.contains("unisoc") || Build.HARDWARE.contains("spreadtrum") -> "UNISOC"
            else -> "Unknown"
        }
    }

    private fun getDisplayInfo(): Map<String, Any> {
        val display = windowManager.defaultDisplay
        val metrics = android.util.DisplayMetrics()
        display.getRealMetrics(metrics)
        
        val densityDpi = metrics.densityDpi
        val density = metrics.density
        val widthPx = metrics.widthPixels
        val heightPx = metrics.heightPixels
        
        return mapOf(
            "widthPx" to widthPx,
            "heightPx" to heightPx,
            "densityDpi" to densityDpi,
            "density" to density,
            "xdpi" to metrics.xdpi,
            "ydpi" to metrics.ydpi,
            "refreshRate" to display.refreshRate,
        )
    }

    private fun getRefreshRate(): Map<String, Any> {
        val display = windowManager.defaultDisplay
        val supportedModes = display.supportedModes
        val currentMode = display.mode
        
        val modes = supportedModes.map { mode ->
            mapOf(
                "width" to mode.physicalWidth,
                "height" to mode.physicalHeight,
                "refreshRate" to mode.refreshRate
            )
        }
        
        return mapOf(
            "currentRefreshRate" to currentMode.refreshRate,
            "supportedModes" to modes
        )
    }
}