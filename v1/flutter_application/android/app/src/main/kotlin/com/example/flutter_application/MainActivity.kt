package com.example.flutter_application

import android.util.Log
import android.widget.Toast
import android.view.MotionEvent

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.JSONMessageCodec

// https://chromium.googlesource.com/external/github.com/flutter/flutter/+/refs/heads/flutter-2.8-candidate.0/dev/benchmarks/platform_channels_benchmarks/android/app/src/main/kotlin/com/example/platform_channels_benchmarks/MainActivity.kt

private const val DEBUG_TAG = "Gestures"

class MainActivity : FlutterActivity() {
    private val actionChannel = "com.freemansoft.eventchannel/action"
    private val message = "{\"action\":\"increment\", \"source\":\"Android\" }"

   override fun configureFlutterEngine(flutterEngine: FlutterEngine){
        super.configureFlutterEngine(flutterEngine);

        var channel = BasicMessageChannel(flutterEngine.dartExecutor, actionChannel, JSONMessageCodec.INSTANCE);
        channel.setMessageHandler{ message,reply ->
            Log.d("Android", "Android received message: "+message);
            Toast.makeText(this, "Android received message from Flutter: $message", Toast.LENGTH_SHORT).show();
            reply.reply("Message received");
        };

    }


    // This example shows an Activity. You can use the same approach if you are
    // subclassing a View.
    override fun onTouchEvent(event: MotionEvent): Boolean {
        var channel = BasicMessageChannel(this.flutterEngine!!.dartExecutor, actionChannel, JSONMessageCodec.INSTANCE)
        return when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                channel.send(message)
                Log.d("Android", "Action was DOWN")
                true
            }
            else -> super.onTouchEvent(event)
        }
    }
}
