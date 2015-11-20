package com.synergygb.caw.registromovilcash.controller;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.AlertDialog;
import android.app.Application;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.text.TextUtils;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.Volley;
import com.synergygb.caw.registromovilcash.R;
import com.synergygb.caw.registromovilcash.manager.connection.CustomJsonObjectRequest;
import com.synergygb.caw.registromovilcash.manager.connection.DatabaseDataSource;
import com.synergygb.caw.registromovilcash.model.Session;
import com.synergygb.caw.registromovilcash.view.activity.LoginActivity;
import com.synergygb.caw.registromovilcash.view.activity.ValidateClientActivity;

/*
 * Created by Juan García on 7/24/15.
 */
public class ApplicationController extends Application {

    // Testing variables
    public static boolean isTestingUIApp = false;
    public static boolean isTestingDummyApp = false;
    public static boolean isTestingLogin = false;
    public static boolean isOnline = false;

    // Application variables
    private static ApplicationController mInstance = null;

    private RequestQueue mRequestQueue;

    private static Session globalSession;
    private static boolean showTAC;

    public static final String TAG = ApplicationController.class.getSimpleName();

    public ApplicationController() {
        mInstance = this;
    }

    @Override
    public void onCreate() {
        super.onCreate();

        mInstance = this;
    }

    public static synchronized ApplicationController getInstance() {
        if (mInstance == null) {
            return new ApplicationController();
        }
        return mInstance;
    }

    // Methods to get a Volley Request Queue
    public RequestQueue getRequestQueue() {
        if (mRequestQueue == null) {
            mRequestQueue = Volley.newRequestQueue(getApplicationContext());
        }
        return mRequestQueue;
    }

    // Methods to add a request to a Volley Request Queue
    public <T> void addToRequestQueue(Request<T> req, String tag) {
        req.setTag(TextUtils.isEmpty(tag) ? TAG : tag);
        getRequestQueue().add(req);
    }

    public <T> void addToRequestQueue(Request<T> req) {
        req.setTag(TAG);
        getRequestQueue().add(req);
    }

    // Method to cancel any pending request
    public void cancelPendingRequests(Object tag) {
        if (mRequestQueue != null) {
            mRequestQueue.cancelAll(tag);
        }
    }

    // Method to get the current session data
    public static Session getGlobalSession() {
        if (globalSession == null)
            return new Session();
        return globalSession;
    }

    // Method to set the current session data
    public static void setGlobalSession(Session globalSession) {
        ApplicationController.globalSession = globalSession;
    }

    // Method to know if the TAC must be shown
    public static boolean isShowTAC() {
        return showTAC;
    }

    // Method to set if the TAC must be shown
    public static void setShowTAC(boolean showTAC) {
        ApplicationController.showTAC = showTAC;
    }

    // Method to load fragments onto the activities
    public void loadFragment(Fragment fragment, int containerID, int animation, Activity activity) {
        FragmentTransaction transaction = activity.getFragmentManager().beginTransaction();
        transaction.replace(containerID, fragment);
        transaction.setTransition(animation);
        transaction.commit();
    }

    // Method to show a Toast message when needed
    public void showToast(Context context, String message) {
        Toast.makeText(context, message, Toast.LENGTH_LONG).show();
    }

    public boolean isAppInForeground() {
        if (getApplicationContext().getPackageName()
                .equalsIgnoreCase(
                        ((ActivityManager) getApplicationContext()
                                .getSystemService(Context.ACTIVITY_SERVICE))
                                .getRunningTasks(1).get(0).topActivity
                                .getPackageName())) {
            return true;
        }
        return false;
    }

    // Method to know if there is the network is available
    public boolean isNetworkAvailable(Context context) {
        ConnectivityManager connectivity =(ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);

        if (connectivity == null) {
            return false;
        } else {
            NetworkInfo[] info = connectivity.getAllNetworkInfo();
            if (info != null) {
                for (int i = 0; i < info.length; i++) {
                    if (info[i].getState() == NetworkInfo.State.CONNECTED) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

}
