#include "HX711.h"
long lastMillis = 0;
long loops = 0;

#define touchPin A0
float touch = 0;
float button = 0;

float x1_cal = 1.25 * 10000;
float x2_cal = 1.25 * 10000;
float y1_cal = 2 * 10000;
float y2_cal = 2 * 10000;

const int xDAT1 = 8;
const int xCLK1 = 9;
const int xDAT2 = 4;
const int xCLK2 = 5;
const int yDAT1 = 6;
const int yCLK1 = 7;
const int yDAT2 = 2;
const int yCLK2 = 3;

float x1 = 0;
float x2 = 0;
float y1 = 0;
float y2 = 0;

HX711 scale_x1;
HX711 scale_x2;
HX711 scale_y1;
HX711 scale_y2;

void setup() {
  Serial.begin(115200);
  scale_x1.begin(xDAT1, xCLK1);
  scale_x2.begin(xDAT2, xCLK2);
  scale_y1.begin(yDAT1, yCLK1);
  scale_y2.begin(yDAT2, yCLK2);
  scale_x1.set_scale(x1_cal);
  scale_x2.set_scale(x2_cal);
  scale_y1.set_scale(y1_cal);
  scale_y2.set_scale(y2_cal);
  scale_x1.tare();
  scale_x2.tare();
  scale_y1.tare();
  scale_y2.tare();
  pinMode(touchPin, INPUT);
  Serial.flush();
}

void loop() {
  long currentMillis = millis();
    loops++;

  touch = analogRead(touchPin);
  if (touch > 20) {
    button = 1;
  } else {
    button = 0;
  }

  if (scale_x1.is_ready() && scale_x2.is_ready() && scale_y1.is_ready() && scale_y2.is_ready()) {
    x1 = scale_x1.get_units();
    x2 = scale_x2.get_units();
    y1 = scale_y1.get_units();
    y2 = scale_y2.get_units();
  }

  if (abs(x1) < 0.02) {
    x1 = 0;
  }

  if (abs(x2) < 0.02) {
    x2 = 0;
  }

  if (abs(y1) < 0.02) {
    y1 = 0;
  }

  if (abs(y2) < 0.02) {
    y2 = 0;
  }

  Serial.print("T");

  if (x1 >= 0) {
    Serial.print("+");
  }
  Serial.print(x1);
  Serial.print(",");
  if (x2 >= 0) {
    Serial.print("+");
  }
  Serial.print(x2);
  Serial.print(",");
  if (y1 >= 0) {
    Serial.print("+");
  }
  Serial.print(y1);
  Serial.print(",");
  if (y2 >= 0) {
    Serial.print("+");
  }
  Serial.print(y2);
  Serial.print(",");
  Serial.println(button);

  delay(5);

}
