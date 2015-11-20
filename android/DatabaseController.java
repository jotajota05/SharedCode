package com.synergygb.caw.registromovilcash.controller;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

/*
 * Created by Juan García on 10/19/15.
 */
public class DatabaseController extends SQLiteOpenHelper {

    public static final String TABLE_REGISTER = "register";
    public static final String COLUMN_ID = "_id";
    public static final String COLUMN_CLIENT = "clientinfo";
    public static final String COLUMN_SUBMIT = "submitted";

    private static final String DATABASE_NAME = "register.db";
    private static final int DATABASE_VERSION = 1;

    private static final String DATABASE_CREATE = "create table "
            + TABLE_REGISTER + "("
            + COLUMN_ID + " integer primary key autoincrement, "
            + COLUMN_CLIENT + " text not null, "
            + COLUMN_SUBMIT + " integer not null"
            + ");";

    public DatabaseController(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(DATABASE_CREATE);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        Log.w(DatabaseController.class.getName(), "Upgrading database from version "
                + oldVersion + " to " + newVersion + ", which will destroy all old data");
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_REGISTER);
        onCreate(db);
    }
}
