package com.example.flutter_application

import android.util.Log
import android.widget.Toast;

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.JSONMessageCodec

// https://chromium.googlesource.com/external/github.com/flutter/flutter/+/refs/heads/flutter-2.8-candidate.0/dev/benchmarks/platform_channels_benchmarks/android/app/src/main/kotlin/com/example/platform_channels_benchmarks/MainActivity.kt

class MainActivity : FlutterActivity() {
   private val actionChannel = "com.freemansoft.eventchannel/action"

   override fun configureFlutterEngine(flutterEngine: FlutterEngine){
        super.configureFlutterEngine(flutterEngine);

        var channel = BasicMessageChannel(flutterEngine.dartExecutor, actionChannel, JSONMessageCodec.INSTANCE);
        channel.setMessageHandler{ message,reply ->
            Log.d("TAG", "received message: "+message);
            Toast.makeText(this, "Received message from Flutter: $message", Toast.LENGTH_SHORT).show();
            reply.reply("Message received");
        };

    }
}
