package com.example.timber_test1;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.bluetooth.BluetoothDevice;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.DialogFragment;

import com.mbientlab.bletoolbox.scanner.BleScannerFragment;
import com.mbientlab.metawear.Data;
import com.mbientlab.metawear.MetaWearBoard;
import com.mbientlab.metawear.Route;
import com.mbientlab.metawear.Subscriber;
import com.mbientlab.metawear.android.BtleService;
import com.mbientlab.metawear.builder.RouteBuilder;
import com.mbientlab.metawear.builder.RouteComponent;
import com.mbientlab.metawear.data.Acceleration;
import com.mbientlab.metawear.module.Accelerometer;
import com.mbientlab.metawear.module.Logging;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.logging.Logger;

import bolts.Continuation;
import bolts.Task;
import io.flutter.plugin.common.MethodChannel;

public class MetawearMainActivity extends AppCompatActivity implements BleScannerFragment.ScannerCommunicationBus, ServiceConnection {
    public static final int REQUEST_START_APP= 1;
    // Keep values of these variables even when activity is destroyed

    private BtleService.LocalBinder serviceBinder;
    private static MetaWearBoard metawear;
    private static Accelerometer accelerometer;
    private static ServiceConnection connection;
    private static boolean connected;
    @SuppressLint("StaticFieldLeak")
    public static Context context;
    private static boolean executing = false;
    public static ArrayList<Double> values;
    private static Logging logging;
    public static boolean finished = false;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        context = getApplicationContext();
        connection = this;
        values = new ArrayList<Double>(Arrays.asList(0.0, 0.0, 0.0));
        context.bindService(new Intent(this, BtleService.class), this, BIND_AUTO_CREATE);

        Button backButton = findViewById(R.id.backButton);
        backButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                connected = false;
                finish();
            }
        });
    }

    @Override
    public void onPause() {
        super.onPause();
    }
    @Override
    public void onResume(){
        super.onResume();
    }
    @Override
    public void onDestroy() {
        MainActivity.outcome.success(connected);
        super.onDestroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch(requestCode) {
            case REQUEST_START_APP:
                ((BleScannerFragment) getFragmentManager().findFragmentById(R.id.scanner_fragment)).startBleScan();
                break;
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public UUID[] getFilterServiceUuids() {
        return new UUID[] {MetaWearBoard.METAWEAR_GATT_SERVICE};
    }

    @Override
    public long getScanDuration() {
        return 10000L;
    }

    @Override
    public void onDeviceSelected(final BluetoothDevice device) {
        metawear = serviceBinder.getMetaWearBoard(device);
        final ProgressDialog connectDialog = new ProgressDialog(this);
        connectDialog.setTitle(getString(R.string.title_connecting));
        connectDialog.setMessage(getString(R.string.message_wait));
        connectDialog.setCancelable(false);
        connectDialog.setCanceledOnTouchOutside(false);
        connectDialog.setIndeterminate(true);
        connectDialog.setButton(DialogInterface.BUTTON_NEGATIVE, getString(android.R.string.cancel),
                (dialogInterface, i) -> metawear.disconnectAsync());
        connectDialog.show();

        metawear.connectAsync().continueWithTask(task
                -> task.isCancelled() || !task.isFaulted() ? task : reconnect(metawear))
                .continueWith(task -> {
                    if (!task.isCancelled()) {
                        runOnUiThread(connectDialog::dismiss);
                        metawear.onUnexpectedDisconnect(status -> {
                            finish();
                        });
                        accelerometer = metawear.getModule(Accelerometer.class);
                        accelerometer.configure()
                                .odr(1000f)       // Set sampling frequency to 25Hz, or closest valid ODR
                                .commit();
                        connected = true;
                        System.out.println("connect!");
                        finish();

                    }
                    return null;
                });
    }

    @Override
    public void onServiceConnected(ComponentName name, IBinder service) {
        serviceBinder = (BtleService.LocalBinder) service;
    }


    @Override
    public void onServiceDisconnected(ComponentName name) {
    }

    public static Task<Void> reconnect(final MetaWearBoard board) {
        return board.connectAsync().continueWithTask(task -> task.isFaulted() ? reconnect(board) : task);
    }

    public static void startSensor() {
        if (!executing && (accelerometer != null)) {
            System.out.println("Starting sensor");
            executing = true;
            finished = false;
            MainActivity.clearFile(MetawearMainActivity.context, "test.txt");

            accelerometer.acceleration().addRouteAsync(new RouteBuilder() {
                @Override
                public void configure(RouteComponent source) {
                    source.stream((data, env) -> {
                        double x = data.value(Acceleration.class).x();
                        double y =data.value(Acceleration.class).y();
                        double z = data.value(Acceleration.class).z();
                        values = new ArrayList<Double>(Arrays.asList(x, y, z));
                    });
                    source.log(new Subscriber() {
                        @Override
                        public void apply(Data data, Object... env) {
                            double x = data.value(Acceleration.class).x();
                            double y =data.value(Acceleration.class).y();
                            double z = data.value(Acceleration.class).z();
                            Log.i("Sensor data",
                                    data.formattedTimestamp()+data.value(Acceleration.class).toString());
                            MainActivity.writeStringAsFile(MetawearMainActivity.context,
                                    data.formattedTimestamp()+ " " + x + " "
                                            + y + " " + z + "\n", "test.txt");
                        }
                    });
                }
            }).continueWith(new Continuation<Route, Void>() {
                @Override
                public Void then(Task<Route> task) throws Exception {
                    logging = metawear.getModule(Logging.class);
                    logging.start(true);
                    accelerometer.acceleration().start();
                    accelerometer.start();
                    return null;
                }
            });
        }
    }

    public static void stopSensor() {
        if (executing && (accelerometer != null)) {
            System.out.println("Stoping sensor");
            executing = false;
            accelerometer.stop();
            accelerometer.acceleration().stop();
            logging.stop();
            logging.flushPage();
            logging.downloadAsync().continueWith(task -> {
                Log.i("Logging","Log download complete");
                logging.clearEntries();
                metawear.tearDown();
                finished = true;
                return null;
            });
        }
    }
    public static void disconnectBle() {
        metawear.disconnectAsync();
        context.unbindService(connection);
    }
}
