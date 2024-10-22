import java.security.KeyStore;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import javax.net.ssl.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.*;


import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;

import java.util.UUID;


String dbUrl = "jdbc:mysql://localhost:3306/iot";
String username = "root";
String password = "";

String mqttUser = "ubuntu";
String mqttPassword = "3vhhdv7v";

MqttClient client;
String broker = "ssl://brokermqttiot.duckdns.org:8883";
String clientId = "processing-subscriberannasacchet";
MemoryPersistence persistence = new MemoryPersistence();
String payload;

float lum;

PVector[] points3;
float angle3;

int startTime;
int duration = 20000; 

void setup() {
 
 size(700,700);
 background(0);

  try {
  client = new MqttClient(broker, clientId, persistence);

    MqttConnectOptions connOpts = new MqttConnectOptions();
   
    SSLSocketFactory socketFactory = getSocketFactory();
   
    connOpts.setSocketFactory(socketFactory);
   
    connOpts.setCleanSession(true);
    
    connOpts.setUserName(mqttUser);
    connOpts.setPassword(mqttPassword.toCharArray());

    client.setCallback(new SimpleMqttCallback());
    client.connect(connOpts);

    println("MQTT Connected");
    client.subscribe("153005/lum");
  } catch (MqttException e) {
     e.printStackTrace();
    print("CONNESSIONE AL BROKER FALLITA!!!");
  }
  
   init();
}

void saveData(float lum) {
  try {
    Connection connection = DriverManager.getConnection(dbUrl, username, password);

    String imageUUID = UUID.randomUUID().toString();
    print(imageUUID);
 
    Timestamp currentTimestamp = new Timestamp(System.currentTimeMillis());

    String query = "INSERT INTO sensor_data (image_uuid, luminosity, timestamp) VALUES (?, ?, ?)";

    PreparedStatement statement = connection.prepareStatement(query);
    statement.setString(1, imageUUID);
    statement.setFloat(2, lum);
    statement.setTimestamp(3, currentTimestamp);
    
    int rowsInserted = statement.executeUpdate();

    statement.close();
    connection.close();

    println("Dati salvati nel database.");
  } catch (SQLException e) {
    e.printStackTrace();
    println("Errore durante il salvataggio dei dati nel database.");
  }
}


void init() {

 points3 = new PVector[5000]; 
  for (int i = 0; i < points3.length; i++)   //per tutti i punti
    points3[i] = new PVector(random(-width/2, width/2),random(-height/2, height/2));
}

    private static SSLSocketFactory getSocketFactory() {
                  String rootCACert = "-----BEGIN CERTIFICATE-----\n" +
        "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\n" +
        "-----END CERTIFICATE-----";
    try {
        // Carica il certificato radice  dal formato PEM
        CertificateFactory cf = CertificateFactory.getInstance("X.509");
   
        InputStream caInput = new ByteArrayInputStream(rootCACert.getBytes());
        X509Certificate ca = (X509Certificate) cf.generateCertificate(caInput);

        KeyStore keyStore = KeyStore.getInstance(KeyStore.getDefaultType());
        keyStore.load(null, null);
        keyStore.setCertificateEntry("ca", ca);

        TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        tmf.init(keyStore);

        SSLContext sslContext = SSLContext.getInstance("TLS");
        sslContext.init(null, tmf.getTrustManagers(), null);

        return sslContext.getSocketFactory();
    } catch (Exception e) {
        e.printStackTrace();
        return null;
    }
 
}

void draw() {
translate(width/2, height/2);  
noFill();
stroke(255,255,255);
rectMode(CENTER);
rect(0 ,0 , 1000, 1000); 


stroke(lum);

  if (lum >=0 && lum < 203)
  stroke(8, 40, 91); //blu scuro 
else if (lum >= 204 && lum < 407)
  stroke(63, 110, 204); //azzurro scuro scuro
else if (lum >= 408 && lum < 612)
  stroke(107, 135, 191); //azzurro scuro 
else if (lum >= 613 && lum < 817)
  stroke(168, 190, 234); //azzurro chiaro 
else //over 
  stroke(255, 255, 255); //bianco da 768 in poi
  
  
  
 for(PVector p : points3){
    if (millis() - startTime > duration) { 
      continue; 
    }
    
    angle3= noise(p.x / 200, p.y / 200) * TAU *map(lum,0,1024,0,3);
    p.add(new PVector((cos(angle3)/TAU) * map(lum,0,1024,0,5) , (sin(angle3)/TAU )*map(lum,0,1024,0,5)));  
    if(p.y < -400 || p.y > 400 || p.x < -400 || p.x > 400)
      p= new PVector(random(-width/2, width/2), random(-height/2, height/2));
    else
      point(p.x, p.y);
  }

 if(lum > 0)
   saveData(lum);
 
}

class SimpleMqttCallback implements MqttCallback {
  public void connectionLost(Throwable cause) {
    println("Connection lost!");
    cause.printStackTrace();
  }

  public void messageArrived(String topic, MqttMessage message) throws Exception {
    payload = new String(message.getPayload());
     String[] dati = payload.split(",");
    lum = Float.parseFloat(dati[0]);
    println("Paylod Float " + lum);
    
    println();
  }

  public void deliveryComplete(IMqttDeliveryToken token) {
    // not used in this example
  }
}
