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
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "custom.dialer/channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "makeCall" -> {
                        val number = call.argument<String>("number") ?: ""
                        val ok = makeSystemCall(number)
                        result.success(ok)
                    }

                    "runUSSD" -> {
                        val code = call.argument<String>("code") ?: ""
                        val response = runUSSD(code)
                        result.success(response)
                    }

                    "requestDefaultDialer" -> {
                        requestDialerRole()
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun makeSystemCall(number: String): Boolean {
        try {
            val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager

            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE)
                != android.content.pm.PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CALL_PHONE), 100)
                return false
            }

            val uri = Uri.parse("tel:$number")
            return try {
                telecomManager.placeCall(uri, Bundle())
                true
            } catch (e: Exception) {
                e.printStackTrace()
                false
            }

        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    private fun runUSSD(code: String): String {
        return try {
            val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

            val method = telephonyManager.javaClass.getDeclaredMethod(
                "sendUssdRequest",
                String::class.java,
                TelephonyManager.UssdResponseCallback::class.java,
                Handler::class.java
            )

            var responseText = "Pending..."

            method.invoke(
                telephonyManager,
                code,
                object : TelephonyManager.UssdResponseCallback() {
                    override fun onReceiveUssdResponse(
                        telephonyManager: TelephonyManager?,
                        request: String?,
                        response: CharSequence?
                    ) {
                        responseText = response?.toString() ?: "No Response"
                    }

                    override fun onReceiveUssdResponseFailed(
                        telephonyManager: TelephonyManager?,
                        request: String?,
                        failureCode: Int
                    ) {
                        responseText = "USSD Failed ($failureCode)"
                    }
                },
                Handler(mainLooper)
            )

            responseText
        } catch (e: Exception) {
            e.printStackTrace()
            "Error running USSD"
        }
    }

    private fun requestDialerRole() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(RoleManager::class.java)
            val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_DIALER)
            startActivityForResult(intent, 101)
        } else {
            val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER)
            intent.putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)
            startActivityForResult(intent, 101)
        }
    }
}
