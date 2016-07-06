// This #include statement was automatically added by the Particle IDE.
#include "ThingSpeak/ThingSpeak.h"

// This #include statement was automatically added by the Particle IDE.
#include "Adafruit_DHT/Adafruit_DHT.h"

#define DHTTYPE DHT22
#define DHT_POWER D1
#define DHT_GND D4
#define DHT_SENSE D2

DHT dht(DHT_SENSE, DHTTYPE);

/* Thingspeak Setup */
TCPClient client;
unsigned long myChannelID = 127505;
const char * myWriteAPIKey = "Y1ROXRBWFYVMD1OK";

//int numSleepMins = 1; // Number of minutes to sleep

void setup() {
    ThingSpeak.begin(client); // Start up ThingSpeak library
    pinMode(DHT_POWER, OUTPUT); // Set power pin to output
    pinMode(DHT_GND, OUTPUT); // Set GND pin to output
    // Turn power to sensor on: 
    digitalWrite(DHT_POWER, HIGH); 
    digitalWrite(DHT_GND, LOW);
    delay(1500); // Let sensor settle
    dht.begin(); // init DHT sensor reader
}

void sendThingSpeak(){
    double humidity = dht.getHumidity(); // Read Humidity 
    double temp = dht.getTempFarenheit(); // Read temp in degrees F
    ThingSpeak.setField(1, (float)temp);
    ThingSpeak.setField(2, (float)humidity);
    ThingSpeak.writeFields(myChannelID, myWriteAPIKey); // Push to ThingSpeak
}
void sendParticle(){
    double humidity = dht.getHumidity(); // Read Humidity 
    double temp = dht.getTempFarenheit(); // Read temp in degrees F
    Particle.publish("temp", (float)temp);
    Particle.publish("humid", (float)humidity);
}

void loop() {
    digitalWrite(DHT_POWER,HIGH); // Turn power back on
    delay(1000); // Let sensor settle
    sendThingSpeak();
    //sendParticle();
    delay(1000); // Wait a little before sleeping
    digitalWrite(DHT_POWER,LOW); // Turn power to sensor off
    
    // Go to Sleep:
    System.sleep(D0, RISING, 30); // sleep 30s. This mode saves more data, uses more power 
    //System.sleep(SLEEP_MODE_DEEP, numSleepMins*60); // uses more data, uses less power 
}
