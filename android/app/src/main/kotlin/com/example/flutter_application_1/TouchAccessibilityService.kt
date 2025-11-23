package com.example.flutter_application_1

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.graphics.Rect
import android.view.accessibility.AccessibilityEvent
import io.flutter.plugin.common.EventChannel
import kotlin.math.ln
import kotlin.math.cos
import kotlin.math.PI
import kotlin.math.sqrt
import kotlin.random.Random

class TouchAccessibilityService : AccessibilityService() {

    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onServiceConnected() {
        super.onServiceConnected()

        val info = AccessibilityServiceInfo().apply {
            eventTypes =
                AccessibilityEvent.TYPE_TOUCH_INTERACTION_START or
                AccessibilityEvent.TYPE_VIEW_CLICKED or
                AccessibilityEvent.TYPE_VIEW_LONG_CLICKED or
                AccessibilityEvent.TYPE_VIEW_SCROLLED or
                AccessibilityEvent.TYPE_VIEW_FOCUSED or
                AccessibilityEvent.TYPE_VIEW_SELECTED or
                AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED

            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        }
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || event.source == null) return

        val node = event.source ?: return
        val bounds = Rect()
        node.getBoundsInScreen(bounds)

        val left = bounds.left
        val top = bounds.top
        val width = bounds.width()
        val height = bounds.height()

        if (width <= 0 || height <= 0) {
            node.recycle()
            return
        }

        // Coordenadas “simuladas” dentro del elemento
        val xOffset = generateNormalOffset(width)
        val yOffset = generateNormalOffset(height)

        val x = left + xOffset
        val y = top + yOffset

        val data = mapOf(
            "x" to x,
            "y" to y,
            "element_left" to left,
            "element_top" to top,
            "element_width" to width,
            "element_height" to height,
            "timestamp" to System.currentTimeMillis(),
            "package" to (event.packageName?.toString() ?: ""),
            "component_type" to (node.className?.toString() ?: ""),
            "view_id" to (node.viewIdResourceName ?: "")
        )

        eventSink?.success(data)
        node.recycle()
    }

    // Distribución normal centrada
    private fun generateNormalOffset(dimension: Int): Int {
        val mean = dimension / 2.0
        val stdDev = dimension / 6.0

        var value: Double
        do {
            val u1 = Random.nextDouble()
            val u2 = Random.nextDouble()
            val z = sqrt(-2.0 * ln(u1)) * cos(2.0 * PI * u2)
            value = mean + stdDev * z
        } while (value < 0 || value >= dimension)

        return value.toInt()
    }

    override fun onInterrupt() {}
}
