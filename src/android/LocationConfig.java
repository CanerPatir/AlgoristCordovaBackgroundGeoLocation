/**
 * Created by Caner on 8.04.2016.
 */
package com.algorist.plugins.LocationListener;

import android.content.Context;
import android.util.Xml;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlPullParserFactory;
import org.xmlpull.v1.XmlSerializer;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.ObjectOutputStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Properties;

public class LocationConfig {
    private static final String CONFIG_FILE_NAME = "svc_config.xml";

    public String getPostUrl() {
        return postUrl;
    }

    public void setPostUrl(String postUrl) {
        this.postUrl = postUrl;
    }

    private String postUrl;

    public HashMap<String, String> getHeaders() {
        return headers;
    }

    public void setHeaders(HashMap<String, String> headers) {
        this.headers = headers;
    }

    private HashMap<String, String> headers;


    public boolean isDebug() {
        return isDebug;
    }

    public void setIsDebug(boolean isDebug) {
        this.isDebug = isDebug;
    }

    private boolean isDebug;

    public LocationConfig(String postUrl, HashMap<String, String> headers, boolean isDebug) {
        this.postUrl = postUrl;
        this.headers = headers;
        this.isDebug = isDebug;
    }

    public void toFile(Context context) {
        try {
            FileOutputStream fos = new FileOutputStream(new File(context.getExternalFilesDir("BizGrapp"), CONFIG_FILE_NAME));
//            FileOutputStream fileos= getApplicationContext().openFileOutput(xmlFile, Context.MODE_PRIVATE);
            XmlSerializer xmlSerializer = Xml.newSerializer();

            StringWriter writer = new StringWriter();

            xmlSerializer.setOutput(writer);
            xmlSerializer.startDocument("UTF-8", true);
            xmlSerializer.startTag(null, "data");
            xmlSerializer.startTag(null, "postUrl");
            xmlSerializer.text(postUrl);
            xmlSerializer.endTag(null, "postUrl");
            xmlSerializer.startTag(null, "headers");
            xmlSerializer.text(headers.toString());
            xmlSerializer.endTag(null, "headers");
            xmlSerializer.startTag(null, "isDebug");
            xmlSerializer.text(isDebug ? "true" : "false");
            xmlSerializer.endTag(null, "isDebug");
            xmlSerializer.endTag(null, "data");
            xmlSerializer.endDocument();
            xmlSerializer.flush();

            String dataWrite = writer.toString();
            fos.write(dataWrite.getBytes());
            fos.close();
        } catch (FileNotFoundException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IllegalStateException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

    }

    public static LocationConfig fromFile(Context context) {
        final String xmlFile = "userData";
        ArrayList<String> userData = new ArrayList<String>();
        String data = read(context.getExternalFilesDir("BizGrapp"), CONFIG_FILE_NAME);

        XmlPullParserFactory factory = null;
        try {
            factory = XmlPullParserFactory.newInstance();
        } catch (XmlPullParserException e2) {
            // TODO Auto-generated catch block
            e2.printStackTrace();
        }
        factory.setNamespaceAware(true);
        XmlPullParser xpp = null;
        try {
            xpp = factory.newPullParser();
        } catch (XmlPullParserException e2) {
            // TODO Auto-generated catch block
            e2.printStackTrace();
        }
        try {
            xpp.setInput(new StringReader(data));
        } catch (XmlPullParserException e1) {
            // TODO Auto-generated catch block
            e1.printStackTrace();
        }
        int eventType = 0;
        try {
            eventType = xpp.getEventType();
        } catch (XmlPullParserException e1) {
            // TODO Auto-generated catch block
            e1.printStackTrace();
        }
        while (eventType != XmlPullParser.END_DOCUMENT) {
            if (eventType == XmlPullParser.START_DOCUMENT) {
                System.out.println("Start document");
            } else if (eventType == XmlPullParser.START_TAG) {
                System.out.println("Start tag " + xpp.getName());
            } else if (eventType == XmlPullParser.END_TAG) {
                System.out.println("End tag " + xpp.getName());
            } else if (eventType == XmlPullParser.TEXT) {
                userData.add(xpp.getText());
            }
            try {
                eventType = xpp.next();
            } catch (XmlPullParserException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }

        try {
            String str = userData.get(1);
            Properties props = new Properties();
            props.load(new StringReader(str.substring(1, str.length() - 1).replace(", ", "\n")));
            HashMap<String, String> map2 = new HashMap<String, String>();
            for (HashMap.Entry<Object, Object> e : props.entrySet()) {
                map2.put((String) e.getKey(), (String) e.getValue());
            }

            return new LocationConfig(userData.get(0), map2, userData.get(2) == "true");
        } catch (IOException e) {
            return null;
        }
    }

    private static String read(File path, String fname) {

        BufferedReader br = null;
        String response = null;

        try {

            StringBuffer output = new StringBuffer();

            br = new BufferedReader(new FileReader(new File(path, fname)));
            String line = "";
            while ((line = br.readLine()) != null) {
                output.append(line + "n");
            }
            response = output.toString();

        } catch (IOException e) {
            e.printStackTrace();
            return null;

        }
        return response;

    }
}
