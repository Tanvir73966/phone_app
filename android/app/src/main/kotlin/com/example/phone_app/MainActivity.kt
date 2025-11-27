package com.example.phone_app

import android.Manifest
import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.telecom.TelecomManager
import android.telephony.TelephonyManager
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "custom.dialer/channel"
    private val PERMISSION_REQUEST_CODE = 100
    private val DIALER_REQUEST_CODE = 101
    private var permissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "makeCall" -> {
                        val number = call.argument<String>("number") ?: ""
                        result.success(makeSystemCall(number))
                    }
                    "runUSSD" -> {
                        val code = call.argument<String>("code") ?: ""
                        runUSSD(code) { response ->
                            runOnUiThread { result.success(response) }
                        }
                    }
                    "requestDefaultDialer" -> {
                        requestDialerRole()
                        result.success(true)
                    }
                    "requestPermissions" -> {
                        permissionResult = result
                        requestPhonePermissions()
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** ----------------------
     *  Permission Handling
     *  ---------------------- */
    private fun requestPhonePermissions() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(
                Manifest.permission.CALL_PHONE,
                Manifest.permission.READ_PHONE_STATE
            ),
            PERMISSION_REQUEST_CODE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val granted = grantResults.all { it == android.content.pm.PackageManager.PERMISSION_GRANTED }
            permissionResult?.success(granted)
            permissionResult = null
        }
    }

    /** ----------------------
     *  Default Dialer Handling
     *  ---------------------- */
    private fun requestDialerRole() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
            val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_DIALER)
            startActivityForResult(intent, DIALER_REQUEST_CODE)
        } else {
            val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER)
            intent.putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)
            startActivityForResult(intent, DIALER_REQUEST_CODE)
        }
    }

    /** ----------------------
     *  Make Phone Call
     *  ---------------------- */
    private fun makeSystemCall(number: String): Boolean {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE) !=
            android.content.pm.PackageManager.PERMISSION_GRANTED
        ) {
            requestPhonePermissions()
            return false
        }

        return try {
            val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
            val uri = Uri.parse("tel:$number")
            telecomManager.placeCall(uri, Bundle())
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /** ----------------------
     *  Run USSD Code
     *  ---------------------- */
    private fun runUSSD(code: String, callback: (String) -> Unit) {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) !=
            android.content.pm.PackageManager.PERMISSION_GRANTED
        ) {
            requestPhonePermissions()
            callback("Permission required")
            return
        }

        try {
            val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            val method = telephonyManager.javaClass.getDeclaredMethod(
                "sendUssdRequest",
                String::class.java,
                TelephonyManager.UssdResponseCallback::class.java,
                Handler::class.java
            )
            method.invoke(
                telephonyManager,
                code,
                object : TelephonyManager.UssdResponseCallback() {
                    override fun onReceiveUssdResponse(
                        tm: TelephonyManager?,
                        request: String?,
                        response: CharSequence?
                    ) {
                        callback(response?.toString() ?: "No Response")
                    }

                    override fun onReceiveUssdResponseFailed(
                        tm: TelephonyManager?,
                        request: String?,
                        failureCode: Int
                    ) {
                        callback("USSD Failed ($failureCode)")
                    }
                },
                Handler(mainLooper)
            )
        } catch (e: Exception) {
            e.printStackTrace()
            callback("Error running USSD")
        }
    }
}
