package com.example.phone_app

import android.telecom.Connection
import android.telecom.ConnectionService
import android.telecom.DisconnectCause
import android.telecom.PhoneAccountHandle
import android.telecom.ConnectionRequest

class MyConnectionService : ConnectionService() {

    override fun onCreateIncomingConnection(
        connectionManagerPhoneAccount: PhoneAccountHandle?,
        request: ConnectionRequest?
    ): Connection {
        return MyConnection().apply {
            setInitializing()
            setActive()
        }
    }

    override fun onCreateOutgoingConnection(
        connectionManagerPhoneAccount: PhoneAccountHandle?,
        request: ConnectionRequest?
    ): Connection {
        return MyConnection().apply {
            setInitializing()
            setActive()
        }
    }

    private class MyConnection : Connection() {
        init {
            setAudioModeIsVoip(true)
        }

        override fun onAnswer() {
            super.onAnswer()
            setActive()
        }

        override fun onDisconnect() {
            super.onDisconnect()
            setDisconnected(DisconnectCause(DisconnectCause.LOCAL))
            destroy()
        }

        override fun onAbort() {
            super.onAbort()
            setDisconnected(DisconnectCause(DisconnectCause.CANCELED))
            destroy()
        }
    }
}
