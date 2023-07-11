#include "HX711.h"

/*long lastMillis = 0;
long loops = 0;*/

//load cell amplifier calibration parameters
float x1_cal = 0.75*10000;
float x2_cal = 1*10000;
float y1_cal = 2.5*10000;
float y2_cal = 2.5*10000;

//arduino pins
const int xDAT1 = 8;
const int xCLK1 = 9;
const int xDAT2 = 4;
const int xCLK2 = 5;
const int yDAT1 = 6;
const int yCLK1 = 7;
const int yDAT2 = 2;
const int yCLK2 = 3;

float filter = 0.3;   //decoupling filter
const float ceiling = 10;   //max abs output value
float max_val = 0;    //max of all raw output

float x = 0;
float y = 0;
float z = 0;

float x1 = 0;
float x2 = 0;
float y1 = 0;
float y2 = 0;

float x1m = 0;
float x2m = 0;
float y1m = 0;
float y2m = 0;

float avg = 0;

float max_x = 0;
float max_y = 0;

float x_temp = 0;
float y_temp = 0;

HX711 scale_x1;
HX711 scale_x2;
HX711 scale_y1;
HX711 scale_y2;

void setup() {
  Serial.begin(115200);
  //intialize load cell amplifier
  scale_x1.begin(xDAT1, xCLK1);
  scale_x2.begin(xDAT2, xCLK2);
  scale_y1.begin(yDAT1, yCLK1);
  scale_y2.begin(yDAT2, yCLK2);
  //calibrate load cell amplifier
  scale_x1.set_scale(x1_cal);
  scale_x2.set_scale(x2_cal);
  scale_y1.set_scale(y1_cal);
  scale_y2.set_scale(y2_cal);
  //zeroing readings
  scale_x1.tare();
  scale_x2.tare();
  scale_y1.tare();
  scale_y2.tare();
}

void loop() {
  /*long currentMillis = millis();
  loops++;*/

  if (scale_x1.is_ready() && scale_x2.is_ready() && scale_y1.is_ready() && scale_y2.is_ready()) {
    //get load cell readings
    x1 = scale_x1.get_units();
    x2 = scale_x2.get_units();
    y1 = scale_y1.get_units();
    y2 = scale_y2.get_units();
      
    avg = (x1 + x2 + y1 + y2) / 4.0;
    // x reading
    x1m = x1 - avg;
    x2m = x2 - avg;
    // y reading
    y1m = y1 - avg;
    y2m = y2 - avg;

    // calc max reading
    max_x = max(abs(x1m),abs(x2m));
    max_y = max(abs(y1m),abs(y2m));
    
    max_val = max(max(max_x, max_y),abs(avg));

    // calc z value
    avg = avg*2;

    //decouple x y z outputs and filter out small outputs
    x_temp = -(x1m-x2m)/2;
    if (abs(x_temp) > filter*max_val) {
      if (abs(x_temp) <= ceiling) {
        x = x_temp / ceiling;
      } else {
        if (x_temp > 0){
          x = 1;
        }else{
          x = -1;
        }
      }
    }else{
      x = 0;
    }

    y_temp = -(y1m-y2m)/2;
    if (abs(y_temp) > 0.75*filter*max_val) {
      if (abs(y_temp) <= ceiling) {
        y = y_temp / ceiling;
      } else {
        if (y_temp > 0){
          y = 1;
        }else{
          y = -1;
        }
      }
    }else{
      y = 0;
    }

    if (abs(avg) > 2.0*filter*max_val) {
      if (abs(avg) <= ceiling) {
        z = avg / ceiling;
      } else {
        if (avg > 0) {
          z = 1;
        }else{
          z = -1;
        }
      }
    }else{
      z = 0;
    }
    
    if (x >= 0) {
      Serial.print("+");
    }
    Serial.print(x);
    Serial.print(",");
    if (y >= 0) {
      Serial.print("+");
    }
    Serial.print(y);
    Serial.print(",");
    if (z >= 0) {
      Serial.print("+");
    }
    Serial.print(z);
    Serial.print("\n");
    }

/*if(currentMillis - lastMillis > 1000){
    Serial.print("\n");
    Serial.print("Loops last second:");
    Serial.println(loops);
    Serial.print("\n");
    
    lastMillis = currentMillis;
    loops = 0;
  }*/
  delay(5);

}
