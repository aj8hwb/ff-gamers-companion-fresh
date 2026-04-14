package com.ffgamers.ff_gamers_companion

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.FrameLayout
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class OverlayService : Service() {
    private val CHANNEL = "ff_gamers/overlay"
    private var windowManager: WindowManager? = null
    private var overlayView: OverlayView? = null
    private var drawerView: DrawerView? = null
    private var isDrawerOpen = false
    private var isOverlayActive = false

    companion object {
        const val CHANNEL_ID = "overlay_service_channel"
        const val NOTIFICATION_ID = 1001
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "START" -> startOverlay(
                intent.getDoubleExtra("x", 0.5),
                intent.getDoubleExtra("y", 0.5),
                intent.getDoubleExtra("size", 50.0),
                intent.getIntExtra("color", 0xFF00FF88),
                intent.getBooleanExtra("isLocked", false)
            )
            "STOP" -> stopOverlay()
            "UPDATE_POSITION" -> updatePosition(
                intent.getDoubleExtra("x", 0.5),
                intent.getDoubleExtra("y", 0.5)
            )
            "UPDATE_SIZE" -> updateSize(intent.getDoubleExtra("size", 50.0))
            "UPDATE_COLOR" -> updateColor(intent.getIntExtra("color", 0xFF00FF88))
            "TOGGLE_LOCK" -> toggleLock(intent.getBooleanExtra("locked", false))
            "TOGGLE_DRAWER" -> toggleDrawer()
        }
        return START_STICKY
    }

    private fun startForegroundService() {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("FF Gamers Companion")
            .setContentText("Gaming Overlay Active")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(CHANNEL_ID, "Overlay Service", NotificationManager.IMPORTANCE_LOW)
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        startForeground(NOTIFICATION_ID, notification)
    }

    private fun startOverlay(x: Double, y: Double, size: Double, color: Int, isLocked: Boolean) {
        if (isOverlayActive) return

        startForegroundService()

        overlayView = OverlayView(this, x, y, size, color, isLocked)
        drawerView = DrawerView(this) { toggleDrawer() }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )
        params.gravity = Gravity.TOP or Gravity.LEFT

        try {
            windowManager?.addView(overlayView, params)
            windowManager?.addView(drawerView, getDrawerParams())
            isOverlayActive = true
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun stopOverlay() {
        try {
            overlayView?.let { windowManager?.removeView(it) }
            drawerView?.let { windowManager?.removeView(it) }
            overlayView = null
            drawerView = null
            isOverlayActive = false
        } catch (e: Exception) {}
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun updatePosition(x: Double, y: Double) {
        overlayView?.updatePosition(x, y)
    }

    private fun updateSize(size: Double) {
        overlayView?.updateSize(size)
    }

    private fun updateColor(color: Int) {
        overlayView?.updateColor(color)
    }

    private fun toggleLock(locked: Boolean) {
        overlayView?.setLocked(locked)
    }

    private fun toggleDrawer() {
        drawerView?.toggle()
    }

    private fun getDrawerParams(): WindowManager.LayoutParams {
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
        )
        params.gravity = Gravity.END
        return params
    }

    override fun onDestroy() {
        stopOverlay()
        super.onDestroy()
    }
}

class OverlayView(context: Context, var x: Double, var y: Double, var size: Double, var color: Int, var isLocked: Boolean) : View(context) {
    private var lastX = 0f
    private var lastY = 0f
    private var initialX = 0f
    private var initialY = 0f
    private var paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = this@OverlayView.color }

    fun updatePosition(newX: Double, newY: Double) {
        x = newX
        y = newY
        invalidate()
    }

    fun updateSize(newSize: Double) {
        size = newSize
        invalidate()
    }

    fun updateColor(newColor: Int) {
        color = newColor
        paint.color = color
        invalidate()
    }

    fun setLocked(locked: Boolean) {
        isLocked = locked
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        
        val displayMetrics = context.resources.displayMetrics
        val posX = (displayMetrics.widthPixels * x).toFloat()
        val posY = (displayMetrics.heightPixels * y).toFloat()
        val scaledSize = (size * displayMetrics.density)

        paint.color = color
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = 8f

        canvas.drawCircle(posX, posY, scaledSize / 2, paint)

        paint.strokeWidth = 4f
        canvas.drawLine(posX - scaledSize / 4, posY, posX + scaledSize / 4, posY, paint)
        canvas.drawLine(posX, posY - scaledSize / 4, posX, posY + scaledSize / 4, paint)

        val glowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = this@OverlayView.color
            alpha = 50
            style = Paint.Style.STROKE
            strokeWidth = 16f
            maskFilter = BlurMaskFilter(20f, BlurMaskFilter.Blur.OUTER)
        }
        canvas.drawCircle(posX, posY, scaledSize / 2, glowPaint)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (isLocked) return true

        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                lastX = event.rawX
                lastY = event.rawY
                initialX = event.rawX
                initialY = event.rawY
            }
            MotionEvent.ACTION_MOVE -> {
                val dx = event.rawX - lastX
                val dy = event.rawY - lastY

                val displayMetrics = context.resources.displayMetrics
                x = (x * displayMetrics.widthPixels + dx) / displayMetrics.widthPixels
                y = (y * displayMetrics.heightPixels + dy) / displayMetrics.heightPixels

                x = x.coerceIn(0.05, 0.95)
                y = y.coerceIn(0.05, 0.95)

                lastX = event.rawX
                lastY = event.rawY
                invalidate()
            }
            MotionEvent.ACTION_UP -> {
                if (kotlin.math.abs(event.rawX - initialX) < 10 && kotlin.math.abs(event.rawY - initialY) < 10) {
                    toggleDrawer()
                }
            }
        }
        return true
    }

    private fun toggleDrawer() {
        val intent = Intent(context, OverlayService::class.java).apply {
            action = "TOGGLE_DRAWER"
        }
        context.startService(intent)
    }
}

class DrawerView(context: Context, private val onToggle: () -> Unit) : View(context) {
    private var isOpen = false
    private val handlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        alpha = 100
    }

    fun toggle() {
        isOpen = !isOpen
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        
        val displayMetrics = context.resources.displayMetrics
        val handleWidth = 30f
        val handleHeight = 80f
        val handleX = if (isOpen) 0f else (displayMetrics.widthPixels - handleWidth)
        val handleY = (displayMetrics.heightPixels / 2 - handleHeight / 2)

        val handleRect = RectF(handleX, handleY, handleX + handleWidth, handleY + handleHeight)
        canvas.drawRoundRect(handleRect, 8f, 8f, handlePaint)

        if (isOpen) {
            val drawerWidth = 250
            val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.parseColor("#CC1A1A1A")
            }
            canvas.drawRect(0f, 0f, drawerWidth.toFloat(), displayMetrics.heightPixels.toFloat(), bgPaint)

            val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.WHITE
                textSize = 40f
            }
            canvas.drawText("Controls", 30f, 100f, textPaint)

            textPaint.textSize = 30f
            canvas.drawText("Lock/Unlock", 30f, 200f, textPaint)
            canvas.drawText("Exit Overlay", 30f, 300f, textPaint)
        }
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (event.action == MotionEvent.ACTION_UP) {
            onToggle()
            return true
        }
        return true
    }
}