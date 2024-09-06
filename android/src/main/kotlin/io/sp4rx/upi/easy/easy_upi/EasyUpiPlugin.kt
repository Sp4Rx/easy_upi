package io.sp4rx.upi.easy.easy_upi

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.io.ByteArrayOutputStream

class EasyUpiPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var finalResult: Result? = null
    private var resultReturned = false
    private lateinit var uriString: String

    companion object {
        const val TAG = "EASY UPI"
        const val UNIQUE_REQUEST_CODE = 512078
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "easy_upi")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        finalResult = result
        when (call.method) {
            "startTransaction" -> startTransaction(call)
            "getAllUpiApps" -> getAllUpiApps(call)
            else -> result.notImplemented()
        }
    }

    private fun getAllUpiApps(call: MethodCall) {
        uriString = call.argument<String>("upiUri") ?: run {
            finalResult?.error("invalid_parameters", "UPI URI string is missing", null)
            return
        }

        val packages = mutableListOf<Map<String, Any>>()
        val intent = Intent(Intent.ACTION_VIEW)
        val uri = Uri.parse(uriString)
        intent.data = uri

        activity?.let { activity ->
            val pm = activity.packageManager
            val resolveInfoList = pm.queryIntentActivities(intent, 0)
            for (resolveInfo in resolveInfoList) {
                try {
                    val packageName = resolveInfo.activityInfo.packageName
                    val name = pm.getApplicationLabel(
                        pm.getApplicationInfo(
                            packageName,
                            PackageManager.GET_META_DATA
                        )
                    ) as String
                    val icon = pm.getApplicationIcon(packageName)

                    val bitmapIcon = getBitmapFromDrawable(icon)
                    val stream = ByteArrayOutputStream()
                    bitmapIcon.compress(Bitmap.CompressFormat.PNG, 100, stream)
                    val iconBytes = stream.toByteArray()

                    val appInfo = mapOf(
                        "packageName" to packageName,
                        "name" to name,
                        "icon" to iconBytes
                    )
                    packages.add(appInfo)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            finalResult?.success(packages)
        } ?: run {
            finalResult?.error("activity_missing", "No attached activity found!", null)
        }
    }

    private fun getBitmapFromDrawable(drawable: Drawable): Bitmap {
        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth,
            drawable.intrinsicHeight,
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    private fun startTransaction(call: MethodCall) {
        resultReturned = false
        val app = call.argument<String>("app") ?: "in.org.npci.upiapp"
        try {
            val uri = Uri.parse(uriString)
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = uri
                setPackage(app)
            }

            if (isAppInstalled(app)) {
                activity?.startActivityForResult(intent, UNIQUE_REQUEST_CODE)
            } else {
                resultReturned = true
                finalResult?.error("app_not_installed", "Requested app not installed", null)
            }
        } catch (ex: Exception) {
            resultReturned = true
            finalResult?.error("invalid_parameters", "Transaction parameters are invalid", null)
        }
    }

    private fun isAppInstalled(uri: String): Boolean {
        return try {
            activity?.packageManager?.getPackageInfo(uri, PackageManager.GET_ACTIVITIES)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == UNIQUE_REQUEST_CODE && finalResult != null) {
            if (data != null) {
                try {
                    val response = data.getStringExtra("response")
                    if (!resultReturned) finalResult?.success(response)
                } catch (ex: Exception) {
                    if (!resultReturned) finalResult?.error(
                        "null_response",
                        "No response received from app",
                        null
                    )
                }
            } else {
                if (!resultReturned) finalResult?.error(
                    "user_canceled",
                    "User canceled the transaction",
                    null
                )
            }
        }
        return true
    }
}
