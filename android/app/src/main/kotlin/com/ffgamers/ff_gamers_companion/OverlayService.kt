package com.ffgamers.ff_gamers_companion

import android.app.Service
import android.content.Intent
import android.graphics.*
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.ImageView

class OverlayService : Service() {
    private lateinit var windowManager: WindowManager
    private lateinit var crosshairView: ImageView
    private var params: WindowManager.LayoutParams? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        createCrosshair()
    }

    private fun createCrosshair() {
        crosshairView = ImageView(this)
        crosshairView.setBackgroundColor(Color.TRANSPARENT)
        
        val bitmap = Bitmap.createBitmap(20, 20, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint().apply {
            color = Color.RED
            strokeWidth = 2f
            style = Paint.Style.STROKE
        }
        canvas.drawLine(10f, 0f, 10f, 20f, paint)
        canvas.drawLine(0f, 10f, 20f, 10f, paint)
        crosshairView.setImageBitmap(bitmap)

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            WindowManager.LayoutParams.TYPE_PHONE
        }

        params = WindowManager.LayoutParams(
            100, 100,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 0
            y = 0
        }

        windowManager.addView(crosshairView, params)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        windowManager.removeView(crosshairView)
    }
}