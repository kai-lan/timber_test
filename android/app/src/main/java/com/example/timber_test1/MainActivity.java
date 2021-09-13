package com.example.timber_test1;

import android.content.*;
import android.os.Handler;
import android.util.Log;

import androidx.annotation.NonNull;

import com.mbientlab.metawear.MetaWearBoard;
import com.mbientlab.metawear.android.BtleService;
import com.mbientlab.metawear.module.Accelerometer;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    public static final String CHANNEL = "example.flutter.dev/battery";
    public static final String EVENT = "platform_channel_events/connectivity";
    public static final String READY = "platform_channel_events/dataReady";
    private static MethodChannel channel;
    private static EventChannel event;
    private static EventChannel ready;
    public static MethodChannel.Result outcome;
    private Handler handler, handler1; // handler for event channel

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        channel = new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        event = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),
                EVENT);
        ready = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),
                READY);
        super.configureFlutterEngine(flutterEngine);
        channel.setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "getNativeView":
                            Intent myIntent = new Intent(MainActivity.this,
                                    MetawearMainActivity.class);
                            myIntent.putExtra("key", "Hello world!"); //Optional parameters
                            MainActivity.this.startActivity(myIntent);
                            outcome = result;
                            break;
                        case "startSensor":
                            MetawearMainActivity.startSensor();
                            break;
                        case "stopSensor":
                            MetawearMainActivity.stopSensor();
                            break;
                        case "disconnect":
                            MetawearMainActivity.disconnectBle();
                            break;
                        case "boardLocalPath":
                            result.success(MetawearMainActivity.context.getFilesDir().getPath()
                                    + "/test.txt");
                            break;
                        default:
                            result.notImplemented();
                    }
                }

        );
        event.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object listener, EventChannel.EventSink eventSink) {
                handler = new Handler(message -> {
                    eventSink.success(MetawearMainActivity.values);
                    handler.sendEmptyMessageDelayed(0, 10);
                    return false;
                });
                handler.sendEmptyMessage(0);

            }
            @Override
            public void onCancel(Object listener) {
                handler.removeMessages(0);
                handler = null;
            }
        });
        ready.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object listener, EventChannel.EventSink eventSink) {
                // Numbers every second+1
                handler1 = new Handler(message -> {
                    // Then send the number to Flutter
                    eventSink.success(MetawearMainActivity.finished);
                    handler1.sendEmptyMessageDelayed(0, 10);
                    return false;
                });
                handler1.sendEmptyMessage(0);
            }
            @Override
            public void onCancel(Object listener) {
                handler1.removeMessages(0);
                handler1 = null;
            }
        });
    }

    public static void uploadSensorData(String filePath) {
        channel.invokeMethod("uploadSensorData", filePath);
    }

    public static void writeStringAsFile(Context context, String fileContents, String fileName) {
        try {
            FileWriter out = new FileWriter(new File(context.getFilesDir(), fileName), true);
            out.write(fileContents);
            out.close();
        } catch (IOException e) {
            android.util.Log.d("WriteToFileError", e.toString());
        }
    }
    public static void clearFile(Context context, String fileName) {
        try {
            FileWriter out = new FileWriter(new File(context.getFilesDir(), fileName));
            out.write("");
            out.close();
        } catch (IOException e) {
            Log.d("WriteToFileError", e.toString());
        }
    }
}
