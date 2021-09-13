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

import android.app.Dialog;
import android.app.ProgressDialog;
import android.bluetooth.BluetoothDevice;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import androidx.annotation.NonNull;
import androidx.fragment.app.DialogFragment;
//import android.support.v4.app.DialogFragment;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.fragment.app.FragmentManager;
import androidx.appcompat.widget.Toolbar;
import com.google.android.material.appbar.AppBarLayout;
import android.view.Menu;
import android.view.MenuItem;

import com.mbientlab.metawear.MetaWearBoard;
import com.mbientlab.metawear.android.BtleService;
import com.example.timber_test1.DeviceSetupActivityFragment.FragmentSettings;

import bolts.Continuation;

import static android.content.DialogInterface.BUTTON_NEGATIVE;

public class DeviceSetupActivity extends AppCompatActivity implements ServiceConnection, FragmentSettings {
    public final static String EXTRA_BT_DEVICE= "com.mbientlab.metawear.starter.DeviceSetupActivity.EXTRA_BT_DEVICE";

    public static class ReconnectDialogFragment extends DialogFragment implements  ServiceConnection {
        private static final String KEY_BLUETOOTH_DEVICE = "com.mbientlab.metawear.starter.DeviceSetupActivity.ReconnectDialogFragment.KEY_BLUETOOTH_DEVICE";

        private ProgressDialog reconnectDialog = null;
        private BluetoothDevice btDevice = null;
        private MetaWearBoard currentMwBoard = null;

        public static ReconnectDialogFragment newInstance(BluetoothDevice btDevice) {
            Bundle args = new Bundle();
            args.putParcelable(KEY_BLUETOOTH_DEVICE, btDevice);

            ReconnectDialogFragment newFragment = new ReconnectDialogFragment();
            newFragment.setArguments(args);

            return newFragment;
        }

        @NonNull
        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            System.out.println("ReconnectDialog: on Create Dialog");
            btDevice = getArguments().getParcelable(KEY_BLUETOOTH_DEVICE);
            getActivity().getApplicationContext().bindService(new Intent(getActivity(), BtleService.class), this, BIND_AUTO_CREATE);

            reconnectDialog = new ProgressDialog(getActivity());
            reconnectDialog.setTitle(getString(R.string.title_reconnect_attempt));
            reconnectDialog.setMessage(getString(R.string.message_wait));
            reconnectDialog.setCancelable(false);
            reconnectDialog.setCanceledOnTouchOutside(false);
            reconnectDialog.setIndeterminate(true);
            reconnectDialog.setButton(BUTTON_NEGATIVE, getString(android.R.string.cancel), (dialogInterface, i) -> {
                currentMwBoard.disconnectAsync();
                getActivity().finish();
            });

            return reconnectDialog;
        }

        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            System.out.println("ReconnectDialog: Service connected");
            currentMwBoard= ((BtleService.LocalBinder) service).getMetaWearBoard(btDevice);
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            System.out.println("ReconnectDialog: service disconnected");
        }

    }

    private BluetoothDevice btDevice;
    private MetaWearBoard metawear;

    private final String RECONNECT_DIALOG_TAG= "reconnect_dialog_tag";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        System.out.println("DeviceSetUp: on create");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_device_setup);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        btDevice= getIntent().getParcelableExtra(EXTRA_BT_DEVICE);
        getApplicationContext().bindService(new Intent(this, BtleService.class), this, BIND_AUTO_CREATE);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        System.out.println("DeviceSetup: on created option menu");
        getMenuInflater().inflate(R.menu.menu_device_setup, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch(item.getItemId()) {
            case R.id.action_disconnect:
                System.out.println("DeviceSetup: disconnect button pressed");
                //metawear.disconnectAsync();
                finish();
                return true;
        }

        return super.onOptionsItemSelected(item);
    }
    @Override
    public void onDestroy() {
        super.onDestroy();
        System.out.println("DeviceSetup: on destroy");
    }
    @Override
    public void onBackPressed() {
        System.out.println("DeviceSetup: back button pressed");
        metawear.disconnectAsync();
        super.onBackPressed();
    }

    @Override
    public void onServiceConnected(ComponentName name, IBinder service) {
        System.out.println("Devicesetup: service connected");
        metawear = ((BtleService.LocalBinder) service).getMetaWearBoard(btDevice);
        FragmentManager manager = getSupportFragmentManager();
        metawear.onUnexpectedDisconnect(status -> {
            ReconnectDialogFragment dialogFragment= ReconnectDialogFragment.newInstance(btDevice);
            dialogFragment.show(manager, "ss");
            dialogFragment.show(manager, RECONNECT_DIALOG_TAG);

            metawear.connectAsync().continueWithTask(task -> task.isCancelled() || !task.isFaulted() ? task : MetawearMainActivity.reconnect(metawear))
                    .continueWith((Continuation<Void, Void>) task -> {
                        if (!task.isCancelled()) {
                            runOnUiThread(() -> {
                                ((DialogFragment) getSupportFragmentManager().findFragmentByTag(RECONNECT_DIALOG_TAG)).dismiss();
                                ((com.example.timber_test1.DeviceSetupActivityFragment) getSupportFragmentManager().findFragmentById(R.id.device_setup_fragment)).reconnected();
                            });
                        } else {
                            finish();
                        }

                        return null;
                    });
        });
    }

    @Override
    public void onServiceDisconnected(ComponentName name) {
        System.out.println("DeviceSetup: service disconnected");
    }

    @Override
    public BluetoothDevice getBtDevice() {
        return btDevice;
    }
}
