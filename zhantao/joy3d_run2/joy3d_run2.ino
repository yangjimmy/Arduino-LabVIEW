#include "HX711.h"
#define TC 271

//arduino pins
#define xDAT1 8
#define xCLK1 9
#define xDAT2 4
#define xCLK2 5
#define yDAT1 6
#define yCLK1 7
#define yDAT2 2
#define yCLK2 3

#define touchPin A0

// variables from joy3d_run
/*long lastMillis = 0;
long loops = 0;*/

//load cell amplifier calibration parameters
float x1_cal = 0.75*10000;
float x2_cal = 1*10000;
float y1_cal = 2.5*10000;
float y2_cal = 2.5*10000;

float x1 = 0;
float x2 = 0;
float y1 = 0;
float y2 = 0;

float touch = 0;
float button = 0;

HX711 scale_x1;
HX711 scale_x2;
HX711 scale_y1;
HX711 scale_y2;

//timer stuff
long TimeCounter;

unsigned long tempt = 0;
unsigned long temp = 0;

void setup() {
  // Timer1 setup
  TCCR1A =((1<<WGM11)|(1<<WGM10)/*|(1<<COM2B1)|(1<<COM2C1)*/);
  TCCR1B = (1<<WGM13)|(1<<WGM12)|(1<<CS12)|(0<<CS11)|(1<<CS10);
  OCR1A = 156;
  TIMSK1 = B00000001; // Enable Timer Interrupt
  
  
  // Timer2 setup
  TCCR2A =((1<<WGM21)|(1<<WGM20));
  TCCR2B = (1<<WGM22)|(1<<CS21)|(0<<CS20)|(1<<CS22);
  OCR2A = 4;  //4.2 kHz   4 for 60 microsec
  TIMSK2 = B00000001;//(1 << TOIE1);
  
  TimeCounter = 0;
  Serial.begin(115200);

  PresSenseInit();
}

void loop() {

}

ISR(TIMER1_OVF_vect)
{
  temp = micros() - tempt; // calculate the time 
  tempt = micros();
  //Update data
  PresSenseWrite();
}

ISR(TIMER2_OVF_vect)
{  
  //temp = micros() - tempt;
  //tempt = micros();  
  TimeCounter++;
  PresSenseRead();
}


void PresSenseInit(){
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
}

void PresSenseWrite(){
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
}

void PresSenseRead(){
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
}
