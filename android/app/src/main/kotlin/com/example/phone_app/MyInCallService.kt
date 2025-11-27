package com.example.phone_app

import android.telecom.Call
import android.telecom.InCallService

class MyInCallService : InCallService() {

    override fun onCallAdded(call: Call) {
        super.onCallAdded(call)
        // Optional: show custom call UI here
        // e.g., notify Flutter or update in-app UI
    }

    override fun onCallRemoved(call: Call) {
        super.onCallRemoved(call)
        // Optional: hide call UI or cleanup
    }
}
