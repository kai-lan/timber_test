/*
 * Copyright 2015 MbientLab Inc. All rights reserved.
 *
 * IMPORTANT: Your use of this Software is limited to those specific rights
 * granted under the terms of a software license agreement between the user who
 * downloaded the software, his/her employer (which must be your employer) and
 * MbientLab Inc, (the "License").  You may not use this Software unless you
 * agree to abide by the terms of the License which can be found at
 * www.mbientlab.com/terms . The License limits your use, and you acknowledge,
 * that the  Software may not be modified, copied or distributed and can be used
 * solely and exclusively in conjunction with a MbientLab Inc, product.  Other
 * than for the foregoing purpose, you may not use, reproduce, copy, prepare
 * derivative works of, modify, distribute, perform, display or sell this
 * Software and/or its documentation for any purpose.
 *
 * YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
 * PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
 * NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
 * MBIENTLAB OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT, NEGLIGENCE,
 * STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER LEGAL EQUITABLE
 * THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED
 * TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST
 * PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY,
 * SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY
 * DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *
 * Should you have any questions regarding your right to use this Software,
 * contact MbientLab Inc, at www.mbientlab.com.
 */

package com.example.timber_test1;

import android.app.Activity;
import android.bluetooth.BluetoothDevice;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.fragment.app.Fragment;

import com.mbientlab.metawear.Data;
import com.mbientlab.metawear.MetaWearBoard;
import com.mbientlab.metawear.Route;
import com.mbientlab.metawear.Subscriber;
import com.mbientlab.metawear.android.BtleService;
import com.mbientlab.metawear.builder.RouteBuilder;
import com.mbientlab.metawear.builder.RouteComponent;
import com.mbientlab.metawear.data.Acceleration;
import com.mbientlab.metawear.module.Accelerometer;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import bolts.Continuation;
import bolts.Task;
import io.flutter.plugin.common.MethodChannel;

/**
 * A placeholder fragment containing a simple view.
 */
public class DeviceSetupActivityFragment extends Fragment implements ServiceConnection {
    public interface FragmentSettings {
        BluetoothDevice getBtDevice();
    }

    private MetaWearBoard metawear = null;
    private FragmentSettings settings;
    private boolean executing = false;

    public DeviceSetupActivityFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        System.out.println("Fragment: on create");
        super.onCreate(savedInstanceState);

        Activity owner = getActivity();
        if (!(owner instanceof FragmentSettings)) {
            throw new ClassCastException("Owning activity must implement the FragmentSettings interface");
        }

        settings = (FragmentSettings) owner;
        owner.getApplicationContext().bindService(new Intent(owner, BtleService.class), this, Context.BIND_AUTO_CREATE);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        System.out.println("Fragment: on destroy");
        ///< Unbind the service when the activity is destroyed
        getActivity().getApplicationContext().unbindService(this);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        System.out.println("Fragment: on create view");
        setRetainInstance(true);
        return inflater.inflate(R.layout.fragment_device_setup, container, false);
    }


    private Accelerometer accelerometer;

    @Override
    public void onServiceConnected(ComponentName name, IBinder service) {
        System.out.println("Fragment: service connected");
        metawear = ((BtleService.LocalBinder) service).getMetaWearBoard(settings.getBtDevice());

        accelerometer = metawear.getModule(Accelerometer.class);
        accelerometer.configure()
                .odr(25f)       // Set sampling frequency to 25Hz, or closest valid ODR
                .commit();
    }

    @Override
    public void onServiceDisconnected(ComponentName name) {
        System.out.println("Fragment: service disconnected");
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        System.out.println("Fragment: on view created");
        view.findViewById(R.id.acc_start).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!executing) {
                    executing = true;
                    accelerometer.acceleration().addRouteAsync(new RouteBuilder() {
                        @Override
                        public void configure(RouteComponent source) {
                            source.stream(new Subscriber() {
                                @Override
                                public void apply(Data data, Object... env) {
                                    String x = String.valueOf(data.value(Acceleration.class).x());
                                    String y = String.valueOf(data.value(Acceleration.class).y());
                                    String z = String.valueOf(data.value(Acceleration.class).z());
                                    
                                    Log.i("Sensor data x", String.valueOf(data.value(Acceleration.class).x()));
                                    //Log.i("Sensor data y", String.valueOf(data.value(Acceleration.class).y()));
                                    //Log.i("Sensor data z", String.valueOf(data.value(Acceleration.class).z()));
                                }
                            });
                        }
                    }).continueWith(new Continuation<Route, Void>() {
                        @Override
                        public Void then(Task<Route> task) throws Exception {
                            accelerometer.acceleration().start();
                            accelerometer.start();
                            return null;
                        }
                    });
                }
            }
        });
        view.findViewById(R.id.acc_stop).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (executing) {
                    executing = false;
                    accelerometer.stop();
                    accelerometer.acceleration().stop();
                    metawear.tearDown();
                }
            }
        });
        view.findViewById(R.id.upload).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                System.out.println(MetawearMainActivity.context.getFilesDir().getPath());
                /////////////////////////
                MainActivity.uploadSensorData(
                        MetawearMainActivity.context.getFilesDir().getPath()
                                + "/test.txt");
                ////////////////////////
            }
        });
    }

    /**
     * Called when the app has reconnected to the board
     */
    public void reconnected() {
        System.out.println("Fragment: service reconnected");
    }

    
    

    public String readFileAsString(Context context, String fileName) {
        StringBuilder stringBuilder = new StringBuilder();
        String line;
        BufferedReader in = null;

        try {
            in = new BufferedReader(new FileReader(new File(context.getFilesDir(), fileName)));
            while ((line = in.readLine()) != null) {
                stringBuilder.append(line);
            }

        } catch (FileNotFoundException e) {
            Log.d("WriteToFileError", e.toString());
        } catch (IOException e) {
            Log.d("WriteToFileError", e.toString());
        }

        return stringBuilder.toString();
    }
}
