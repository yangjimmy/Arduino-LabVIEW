//#include <Encoder.h>
//#define Fortest

#define ENCODER0_A 3
#define ENCODER0_B 2
#define ENCODER1_A 4
#define ENCODER1_B 5
#define ENCODER2_A 6
#define ENCODER2_B 7
#define ENCODER3_A 8
#define ENCODER3_B 9
#define SwitchPin 13
#define HallSensor A4
#define RECORD_TIME 10 // sec
#define HallSensorMax 865  // found by experiment
#define HallSensorMin 778  // found by experiment
#define HallSensorResolution 32 // Desired Axis 5 Resolution 0~31

#define ByteNumber 29

#define Encoder1Bias 5000;
#define Encoder2Bias 5000;
#define Encoder3Bias 50000;
#define Encoder4Bias 5000;
#define HallSensorBias 5000;

//Globle Variables
unsigned long tempt = 0;
unsigned long temp = 0;
unsigned char SendingBytes[ByteNumber] = {0};
unsigned int Axis1 = 0;
unsigned int Axis2 = 0;
unsigned int Axis3 = 0;
unsigned int Axis4 = 0;
unsigned int Axis5 = 0;
unsigned char StartingByte = 0xFF; //0x0A
int HallSensorRange = HallSensorMax - HallSensorMin;
int Halltemp;
//unsigned char StartingByte = 0x0A;

unsigned char Encoder_Status[4];
unsigned char Encoder_PinA[4];
unsigned char Encoder_PinB[4];
long RecordTime = long(RECORD_TIME * 1000000 / 60);
int Encoder_Counter[4] = {0};
int HSBias = HallSensorBias;
//double timet, temp;
long TimeCounter;
boolean EncoderUpdateBool = true;

void setup()
{
  // Timer1 setup
  //TCCR1A =((1<<WGM11)|(1<<COM1B1)|(1<<COM1A1));
  TCCR1A = ((1 << WGM11) | (1 << WGM10)/*|(1<<COM2B1)|(1<<COM2C1)*/);
  TCCR1B = (1 << WGM13) | (1 << WGM12) | (1 << CS12) | (0 << CS11) | (1 << CS10);
  OCR1A = 312;//156;
  //ICR1 = 4000;
  TIMSK1 = B00000001; // Enable Timer Interrupt


  // Timer2 setup
  TCCR2A = ((1 << WGM21) | (1 << WGM20)/*|(1<<COM2B1)|(1<<COM2C1)*/);
  TCCR2B = (1 << WGM22) | (1 << CS21) | (0 << CS20) | (1 << CS22);
  //ICR2 = 4000;
  OCR2A = 4;  //4.2 kHz   4 for 60 microsec
  TIMSK2 = B00000001;//(1 << TOIE1);

  TimeCounter = 0;
  Serial.begin(115200);
  pinMode(HallSensor, INPUT);
  pinMode(SwitchPin,INPUT_PULLUP);

  EncoderInit();
  //Encoder_Counter[0] = 5000;
  //Encoder_Counter[1] = 5000;
  //Encoder_Counter[2] = 5000;
  //Encoder_Counter[3] = 5000;
}

void loop()
{
  if(digitalRead(SwitchPin)) {EncoderUpdateBool = false;}
  else {EncoderUpdateBool = true;}
  //Serial.println(digitalRead(ENCODER1_A)<<1|digitalRead(ENCODER1_B));
  //Serial.println(1<<digitalRead(ENCODER1_A));
  //Serial.println(digitalRead(ENCODER1_B));
  //Serial.print(temp);
  //Serial.print("\t");
  /*
    if(TimeCounter <= RecordTime)
    {
    Serial.print(TimeCounter);
    Serial.print("\t");
    Serial.print(analogRead(HallSensor));
    Serial.print("\t");
    Serial.print(Encoder_Counter[0]);
    Serial.print("\t");
    Serial.print(Encoder_Counter[1]);
    Serial.print("\t");
    Serial.print(Encoder_Counter[2]);
    Serial.print("\t");
    Serial.print(Encoder_Counter[3]);
    Serial.print("\n");
    }

  */
  //Serial.println(temp);
  /*
    Serial.write(Encoder_Counter[0]);
    Serial.write("\t");
    Serial.write(Encoder_Counter[1]);
    Serial.write("\t");
    Serial.write(Encoder_Counter[2]);
    Serial.write("\t");
    Serial.write(Encoder_Counter[3]);
    Serial.write("\n");
  */
  //Axis1++;
  //Axis2 = Axis2 + 2;
  //Axis3 = Axis3 + 3;
  //Axis4 = Axis4 + 4;
  //Axis5 = Axis5 + 5;
  //delay(2000);
  //Serial.println(temp);
  /*
    PrintEncoderN(0);
    Serial.print(",");
    PrintEncoderN(1);
    Serial.print(",");
    PrintEncoderN(2);
    Serial.print(",");
    PrintEncoderN(3);
    Serial.print(",");
    PrintHallSensor();
    Serial.print("\n");
    delay(5);
  */
}


ISR(TIMER1_OVF_vect)
{
  temp = micros() - tempt; // calculate the time
  tempt = micros();
#ifndef Fortest
  //Serial.write(SendingBytes[i]);
#endif
  //Update data

  Serial.print("T"); // Start Bytes
  PrintEncoderN(0);
  Serial.print(",");
  PrintEncoderN(1);
  Serial.print(",");
  PrintEncoderN(2);
  Serial.print(",");
  PrintEncoderN(3);
  Serial.print(",");
  PrintHallSensor();
  Serial.print("\n");


#ifdef Fortest
  //Serial.print(analogRead(HallSensor));
  Serial.print(Halltemp);
  Serial.print("\t");
  Serial.print(Axis1);
  Serial.print("\t");
  Serial.print(Axis2);
  Serial.print("\t");
  Serial.print(Axis3);
  Serial.print("\t");
  Serial.print(Axis4);
  Serial.print("\t");
  Serial.print(Axis5);
  Serial.print("\n");
#endif
}

ISR(TIMER2_OVF_vect)
{
  //temp = micros() - tempt;
  //tempt = micros();
  TimeCounter++;
  //ReadEncoder(int EncoderPinA, int EncoderPinB, unsigned char laststate, long CurrentCount)
  //Encoder1_Counter = ReadEncoder(ENCODER1_A, ENCODER1_A, Encoder1_Status, Encoder1_Counter);
  if (EncoderUpdateBool)
  {
    Read_Encoder(0);
    Read_Encoder(1);
    Read_Encoder(2);
    Read_Encoder(3);
  }
}

void EncoderInit(void)
{
  Encoder_PinA[0] = ENCODER0_A;
  Encoder_PinB[0] = ENCODER0_B;
  Encoder_PinA[1] = ENCODER1_A;
  Encoder_PinB[1] = ENCODER1_B;
  Encoder_PinA[2] = ENCODER2_A;
  Encoder_PinB[2] = ENCODER2_B;
  Encoder_PinA[3] = ENCODER3_A;
  Encoder_PinB[3] = ENCODER3_B;
  for (int i = 0; i < 4; i++)
  {
    pinMode(Encoder_PinA[i], INPUT_PULLUP);
    pinMode(Encoder_PinB[i], INPUT_PULLUP);
    Encoder_Status[i] = digitalRead(Encoder_PinA[i]) << 1 | digitalRead(Encoder_PinB[i]);
  }
}

void Read_Encoder(int EncoderNumber)
{
  unsigned char CurrentSatate = digitalRead(Encoder_PinA[EncoderNumber]) << 1 | digitalRead(Encoder_PinB[EncoderNumber]);
  switch (CurrentSatate)
  {
    case 0:
      if (Encoder_Status[EncoderNumber] == 1)    {
        Encoder_Counter[EncoderNumber]++;
      }
      if (Encoder_Status[EncoderNumber] == 2)    {
        Encoder_Counter[EncoderNumber]--;
      }
      break;
    case 1:
      if (Encoder_Status[EncoderNumber] == 3)    {
        Encoder_Counter[EncoderNumber]++;
      }
      if (Encoder_Status[EncoderNumber] == 0)    {
        Encoder_Counter[EncoderNumber]--;
      }
      break;
    case 2:
      if (Encoder_Status[EncoderNumber] == 0)    {
        Encoder_Counter[EncoderNumber]++;
      }
      if (Encoder_Status[EncoderNumber] == 3)    {
        Encoder_Counter[EncoderNumber]--;
      }
      break;
    case 3:
      if (Encoder_Status[EncoderNumber] == 2)    {
        Encoder_Counter[EncoderNumber]++;
      }
      if (Encoder_Status[EncoderNumber] == 1)    {
        Encoder_Counter[EncoderNumber]--;
      }
      break;
  }
  Encoder_Status[EncoderNumber] = CurrentSatate;
}

long ReadEncoder(int EncoderPinA, int EncoderPinB, unsigned char laststate, long CurrentCount)
{
  long newCount;
  switch (digitalRead(ENCODER1_A) << 1 | digitalRead(ENCODER1_B))
  {
    case 0:
      if (laststate == 1)    {
        newCount = CurrentCount + 1;
      }
      if (laststate == 2)    {
        newCount = CurrentCount - 1;
      }
      else {
        newCount = CurrentCount;
      }
      break;
    case 1:
      if (laststate == 3)    {
        newCount = CurrentCount + 1;
      }
      if (laststate == 0)    {
        newCount = CurrentCount - 1;
      }
      else {
        newCount = CurrentCount;
      }
      break;
    case 2:
      if (laststate == 0)    {
        newCount = CurrentCount + 1;
      }
      if (laststate == 3)    {
        newCount = CurrentCount - 1;
      }
      else {
        newCount = CurrentCount;
      }
      break;
    case 3:
      if (laststate == 2)    {
        newCount = CurrentCount + 1;
      }
      if (laststate == 1)    {
        newCount = CurrentCount - 1;
      }
      else {
        newCount = CurrentCount;
      }
      break;
  }
  return newCount;
}

int PrintEncoderN(int ENumber)
{
  if (Encoder_Counter[ENumber] >= 0)
  {
    Serial.print("+");
    long Temp = Encoder_Counter[ENumber];
    if (Temp < 10)
    {
      Serial.print("000");
      Serial.print(Temp);
    }
    else if (Temp < 100)
    {
      Serial.print("00");
      Serial.print(Temp);
    }
    else if (Temp < 1000)
    {
      Serial.print("0");
      Serial.print(Temp);
    }/*
    else if(Temp < 10000)
    {
      Serial.print("0");
      Serial.print(Temp);
    }*/
    else
    {
      Serial.print(Temp);
    }
  }
  else // Counter < 0
  {
    Serial.print("-");
    long Temp = -1 * Encoder_Counter[ENumber];
    if (Temp < 10)
    {
      Serial.print("000");
      Serial.print(Temp);
    }
    else if (Temp < 100)
    {
      Serial.print("00");
      Serial.print(Temp);
    }
    else if (Temp < 1000)
    {
      Serial.print("0");
      Serial.print(Temp);
    }
    else
    {
      Serial.print(Temp);
    }
  }
}

int PrintHallSensor(void)
{
  Halltemp = analogRead(HallSensor);
  int TempH = int((double(Halltemp - HallSensorMin) / HallSensorRange) * HallSensorResolution);
  if (TempH >= 0)
  {
    Serial.print("+");
    long Temp = TempH;
    if (Temp < 10)
    {
      Serial.print("00");
      Serial.print(Temp);
    }
    else if (Temp < 100)
    {
      Serial.print("0");
      Serial.print(Temp);
    }
    else
    {
      Serial.print(Temp);
    }
  }
  else // Counter < 0
  {
    Serial.print("-");
    long Temp = -1 * TempH;
    if (Temp < 10)
    {
      Serial.print("00");
      Serial.print(Temp);
    }
    else if (Temp < 100)
    {
      Serial.print("0");
      Serial.print(Temp);
    }
    else
    {
      Serial.print(Temp);
    }
  }
}
