package com.synergygb.caw.registromovilcash.connector;

import android.content.Context;
import android.util.Log;

import com.android.volley.VolleyError;
import com.synergygb.caw.registromovilcash.R;
import com.synergygb.caw.registromovilcash.controller.ApplicationController;
import com.synergygb.caw.registromovilcash.manager.connection.ConnectionUtils;
import com.synergygb.caw.registromovilcash.manager.connection.CustomVolleyErrorListener;
import com.synergygb.caw.registromovilcash.manager.connection.CustomVolleyJsonListener;
import com.synergygb.caw.registromovilcash.model.request.LoginRequest;
import com.synergygb.caw.registromovilcash.model.response.LoginResponse;
import com.synergygb.caw.registromovilcash.view.fragments.LoginSPFragment;

import org.json.JSONObject;

/*
 * Created by Juan García on 7/29/15.
 */
public class LoginConnector {

    private static LoginConnector sharedInstance;

    private LoginSPFragment loginFragment;
    private LoginResponse loginResponse;

    private LoginConnector() {
        sharedInstance = this;
    }

    public static synchronized LoginConnector getInstance() {
        if (sharedInstance == null) {
            return new LoginConnector();
        }
        return sharedInstance;
    }

    public void setLoginFragment(LoginSPFragment loginFragment) {
        this.loginFragment = loginFragment;
    }

    public void performLogin(String username, String password) {

        final Context applicationContext = ApplicationController.getInstance().getApplicationContext();

        LoginRequest request = getLoginRequest(username, password);
        String serviceName = applicationContext.getString(R.string.login_url);

        CustomVolleyJsonListener loginListenerOk = new CustomVolleyJsonListener() {
            @Override
            public void onResponse(JSONObject response) {
                String jsonResult = response.toString();
                Log.d("RMC - LOG - RESP", jsonResult);
                loginFragment.getProgressDialog().dismiss();
                loginResponse = (LoginResponse) ConnectionUtils.parseJsonObjectRequestResponse(response, LoginResponse.class, this.jsonRequest);
                ApplicationController.isOnline = true;
                loginFragment.startNextActivity(loginResponse);
            }
        };

        CustomVolleyErrorListener customVolleyErrorListener = new CustomVolleyErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                loginFragment.getProgressDialog().dismiss();
                ApplicationController.getInstance().showToast(loginFragment.getActivity(), loginFragment.getString(R.string.validate_server_problem_msg));
                ApplicationController.isOnline = false;
                loginFragment.startNextActivity();
            }
        };

        ConnectionUtils.makeJsonObjectRequest(request,
                applicationContext.getString(R.string.services_url) + serviceName,
                loginListenerOk,
                customVolleyErrorListener,
                null,
                Integer.parseInt(applicationContext.getString(R.string.service_timeout)),
                ConnectionUtils.POST,
                false);
    }

    private LoginRequest getLoginRequest(String username, String password) {
        LoginRequest request = new LoginRequest();
        request.setUsername(username);
        request.setPassword(password);
        return request;
    }
}
