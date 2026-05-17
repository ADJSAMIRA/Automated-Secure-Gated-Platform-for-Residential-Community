#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// --- الأرجل (Pins) ---
#define FLAME_PIN 16      // D0 (نار)
#define LIGHT_IR_PIN D5   // حساس حركة
#define STREET_LED_PIN D7  // ليدات الطريق

// الباب يستعمل RGB دركا
#define GATE_RED_PIN D8    // أحمر
#define GATE_GREEN_PIN 3   // أخضر (RX)

// الباركينغ في الأرجل الجديدة
#define TRIG_PIN D6      
#define ECHO_PIN D4      

const char* ssid = "admin";         
const char* password = "Tfouh ya lklab ?!"; 
const char* baseUrl = "https://amazing-demographic-cardiovascular-louis.trycloudflare.com/api/iot"; 

LiquidCrystal_I2C lcd(0x27, 16, 2);

bool isNightMode = false;
bool alertSent = false;
String lastDoorStatus = "";
String lastParkingStatus = "";
unsigned long lastCheck = 0;
unsigned long lightOnTimer = 0;

void setup() {
  // Serial.begin ممنوع بسبب RX
  
  pinMode(FLAME_PIN, INPUT);
  pinMode(LIGHT_IR_PIN, INPUT);
  pinMode(STREET_LED_PIN, OUTPUT);
  pinMode(GATE_RED_PIN, OUTPUT);
  pinMode(GATE_GREEN_PIN, OUTPUT);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  // الحالة الابتدائية: الباب مغلوق (أحمر)
  analogWrite(GATE_RED_PIN, 100); // 30% حماية
  digitalWrite(GATE_GREEN_PIN, LOW);
  digitalWrite(STREET_LED_PIN, LOW);

  Wire.begin(4, 5); 
  lcd.init();
  lcd.backlight();
  lcd.print("Smart Residence");

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) { delay(200); }
  lcd.clear(); lcd.print("Ready to Scan");
}

void loop() {
  unsigned long now = millis();

  // 1. نظام الحريق (D0) - النسخة الأصلية
  if (digitalRead(FLAME_PIN) == HIGH) { 
    if (!alertSent) {
      lcd.clear(); lcd.setCursor(0, 0); lcd.print("!! FIRE ALERT !!");
      if (WiFi.status() == WL_CONNECTED) {
        WiFiClientSecure client; client.setInsecure();
        HTTPClient http;
        http.begin(client, String(baseUrl) + "/fire-alert");
        http.addHeader("Content-Type", "application/json");
        http.POST("{\"device_id\": 1, \"category\":\"Fire\", \"urgency\":\"Critical\"}");
        http.end();
      }
      alertSent = true;
    }
  } else if (alertSent) {
    alertSent = false; lcd.clear(); lcd.print("Ready to Scan");
  }

  // 2. نظام الإضاءة (D7 + D5) - النسخة الأصلية
  if (isNightMode && digitalRead(LIGHT_IR_PIN) == LOW) { 
      digitalWrite(STREET_LED_PIN, HIGH);
      lightOnTimer = now; 
  } else if (now - lightOnTimer >= 5000) { 
      digitalWrite(STREET_LED_PIN, LOW); 
  }

  // 3. نظام الباركينغ (صامت - تحديث قاعدة البيانات فقط)
  digitalWrite(TRIG_PIN, LOW); delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH); delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH, 25000);
  float distance = duration * 0.034 / 2;

  String currentStatus = (distance > 0.5 && distance < 12.0) ? "Occupied" : "Available";
  if (currentStatus != lastParkingStatus) {
      if (WiFi.status() == WL_CONNECTED) {
          WiFiClientSecure client; client.setInsecure();
          HTTPClient http;
          http.begin(client, String(baseUrl) + "/parking-update");
          http.addHeader("Content-Type", "application/json");
          http.POST("{\"spot_name\":\"P03\", \"status\":\"" + currentStatus + "\"}");
          http.end();
      }
      lastParkingStatus = currentStatus;
  }

  // 4. تحديث حالة الباب بـ RGB (D8, RX) - كل 3 ثواني
  if (now - lastCheck > 3000) {
    lastCheck = now;
    if (WiFi.status() == WL_CONNECTED) {
      WiFiClientSecure client; client.setInsecure();
      HTTPClient http;
      http.begin(client, String(baseUrl) + "/door-status");
      if (http.GET() > 0) {
        DynamicJsonDocument doc(256);
        deserializeJson(doc, http.getString());
        String status = doc["status"].as<String>();
        
        if (status != lastDoorStatus && !alertSent) {
          lastDoorStatus = status;
          lcd.clear();
          if (status == "OPEN") {
            lcd.print("ACCESS GRANTED");
            analogWrite(GATE_RED_PIN, 0);   // طفي الأحمر
            analogWrite(GATE_GREEN_PIN, 120); // شعل الأخضر
          } else {
            lcd.print("Ready to Scan");
            analogWrite(GATE_RED_PIN, 120);  // شعل الأحمر
            analogWrite(GATE_GREEN_PIN, 0);   // طفي الأخضر
          }
        }
      }
      http.end();

      // تحديث وضع الليل
      http.begin(client, String(baseUrl) + "/lighting-state");
      if (http.GET() > 0) {
        DynamicJsonDocument doc(256); deserializeJson(doc, http.getString());
        isNightMode = doc["nightMode"].as<bool>();
      }
      http.end();
    }
  }
}