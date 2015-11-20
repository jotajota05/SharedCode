package com.synergygb.caw.registromovilcash.manager.connection;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;

import com.synergygb.caw.registromovilcash.controller.DatabaseController;
import com.synergygb.caw.registromovilcash.model.DBRegisterContent;

import java.util.ArrayList;
import java.util.List;

/*
 * Created by Juan García on 10/20/15.
 */
public class DatabaseDataSource {

    private SQLiteDatabase database;
    private DatabaseController dbController;
    private String[] allColumns = { DatabaseController.COLUMN_ID, DatabaseController.COLUMN_CLIENT, DatabaseController.COLUMN_SUBMIT };

    public DatabaseDataSource(Context context) {
        this.dbController = new DatabaseController(context);
    }

    public void open() throws SQLException {
        this.database = this.dbController.getWritableDatabase();
    }

    public void close() {
        this.dbController.close();
    }

    public void resetDatabase() {
        this.dbController.onUpgrade(this.database, 1, 1);
    }

    public DBRegisterContent createRequest(String clientinfo) {
        ContentValues values = new ContentValues();
        values.put(DatabaseController.COLUMN_CLIENT, clientinfo);
        values.put(DatabaseController.COLUMN_SUBMIT, 0);
        long insertId = database.insert(DatabaseController.TABLE_REGISTER, null, values);
        Cursor cursor = database.query(DatabaseController.TABLE_REGISTER, allColumns, DatabaseController.COLUMN_ID + " = " + insertId, null, null, null, null);
        cursor.moveToFirst();
        DBRegisterContent newRequest = cursorToRequest(cursor);
        cursor.close();
        return newRequest;
    }

    public DBRegisterContent updateRequestToProcessed(long requestId) {
        ContentValues values = new ContentValues();
        values.put(DatabaseController.COLUMN_SUBMIT, 1);
        database.update(DatabaseController.TABLE_REGISTER, values, DatabaseController.COLUMN_ID + " = " + requestId, null);
        Cursor cursor = database.query(DatabaseController.TABLE_REGISTER, allColumns, DatabaseController.COLUMN_ID + " = " + requestId, null, null, null, null);
        cursor.moveToFirst();
        DBRegisterContent newRequest = cursorToRequest(cursor);
        cursor.close();
        return newRequest;
    }

    public List<DBRegisterContent> getAllRequest() {
        List<DBRegisterContent> requests = new ArrayList<>();

        Cursor cursor = database.query(DatabaseController.TABLE_REGISTER, allColumns, null, null, null, null, null);

        cursor.moveToFirst();
        while (!cursor.isAfterLast()) {
            DBRegisterContent request = cursorToRequest(cursor);
            requests.add(request);
            cursor.moveToNext();
        }
        // make sure to close the cursor
        cursor.close();
        return requests;
    }

    public List<DBRegisterContent> getAllRequestNotProcessed() {
        List<DBRegisterContent> requests = new ArrayList<>();

        Cursor cursor = database.query(DatabaseController.TABLE_REGISTER, allColumns, DatabaseController.COLUMN_SUBMIT + " = " + 0, null, null, null, null);

        cursor.moveToFirst();
        while (!cursor.isAfterLast()) {
            DBRegisterContent request = cursorToRequest(cursor);
            requests.add(request);
            cursor.moveToNext();
        }
        // make sure to close the cursor
        cursor.close();
        return requests;
    }

    public int numberOfNotProcessedRequest() {
        return getAllRequestNotProcessed().size();
    }

    private DBRegisterContent cursorToRequest(Cursor cursor) {
        DBRegisterContent request = new DBRegisterContent();
        request.setId(cursor.getLong(0));
        request.setClientinfo(cursor.getString(1));
        request.setSubmitted(cursor.getLong(2));
        return request;
    }
}
