// Choose mode and debug
#define MEGA2560
//#define PrintDebugData


/////////////////////////////////////////////////////////////////////////////////////
#include <SoftwareSerial.h>
const byte C2000_1_rxPin = 2; // Connect to C2000_1 Pin 4  /  44
const byte C2000_1_txPin = 3; // Connect to C2000_1 Pin 3  /  43 
const byte C2000_2_rxPin = 4; // Connect to C2000_2 Pin 4
const byte C2000_2_txPin = 5; // Connect to C2000_2 Pin 3

//Encoder 1 connect to C2000_1 QEP_A
//Encoder 2 connect to C2000_1 QEP_B
//Encoder 3 connect to C2000_2 QEP_A
//Encoder 4 connect to C2000_2 QEP_B

//QEP Start from right side : ChB/ChA , ChA/ChB, Index, 5V, GND

#define DigitalInput1 6
#define DigitalOutput1 7
#define BufferLength 3
#define HallSensorMax 839  // found by experiment
#define HallSensorMin 758  // found by experiment
#define HallSensorResolution 32 // Desired Axis 5 Resolution 0~31
//#define ByteNumber 29
#ifdef MEGA2560  
  #define SwitchPin 44
  #define HallSensor A15
#endif
#ifndef MEGA2560  
  #define SwitchPin 13
  #define HallSensor A4
  SoftwareSerial SerialC2000_1 (C2000_1_rxPin, C2000_1_txPin);
  SoftwareSerial SerialC2000_2 (C2000_2_rxPin, C2000_2_txPin);
#endif
unsigned char SerialC2000_1_Buffer[BufferLength] = {0};
unsigned char SerialC2000_2_Buffer[BufferLength] = {0};
int TerminateNum = 0;
long encoder1,encoder2,encoder3,encoder4;
unsigned long tempt = 0;
unsigned long temp = 0;
long LastE1, LastE2, LastE3, LastE4;
int Encoder_Counter[4] = {0};

//For Serial to Computer
unsigned char StartingByte = 0xFF; //0x0A
int HallSensorRange = HallSensorMax - HallSensorMin;
int Halltemp;

long TimeCounter;
boolean EncoderUpdateBool = true;

void setup() 
{
  // Timer1 setup
  //TCCR1A =((1<<WGM11)|(1<<COM1B1)|(1<<COM1A1));
  TCCR1A = ((1 << WGM11) | (1 << WGM10)/*|(1<<COM2B1)|(1<<COM2C1)*/);
  TCCR1B = (1 << WGM13) | (1 << WGM12) | (1 << CS12) | (0 << CS11) | (1 << CS10);
  OCR1A = 62;//62;//156;
  //ICR1 = 4000;
  TIMSK1 = B00000001; // Enable Timer Interrupt
  
#ifndef MEGA2560  
  SerialC2000_1.begin(57604);
  //SerialC2000_2.begin(57604);
#endif

#ifdef MEGA2560  
  pinMode(16,OUTPUT);
  pinMode(18,OUTPUT);
  pinMode(17,INPUT);
  pinMode(19,INPUT);
  Serial1.begin(57604);
  Serial2.begin(57604);
#endif

  //Serial.begin(115200);
  Serial.begin(250000);
  pinMode(DigitalInput1,INPUT);
  pinMode(DigitalOutput1,OUTPUT);
  pinMode(HallSensor, INPUT);
  pinMode(SwitchPin,INPUT_PULLUP);
  delay(100);
  //Serial.print("Start!");
}

void loop() 
{
  if(digitalRead(SwitchPin)) {EncoderUpdateBool = false;}
  else {EncoderUpdateBool = true;}
  //EncoderUpdateBool = true;
  /*
  if(SerialC2000_1.available()>0)
  {
    Serial.print(SerialC2000_1.read());
    //Serial.print("In");
  }
  */
  UpdateC2000_1();
  UpdateC2000_2();

  //Serial.println(temp);
  
}
ISR(TIMER1_OVF_vect)
{
  temp = micros() - tempt; // calculate the time
  tempt = micros();
  /*
  Serial.print("En1: ");
  Serial.print(encoder1);
  Serial.print("\t");
  Serial.print("En2: ");
  Serial.print(encoder2);
  Serial.print("\t");
  Serial.print("En3: ");
  Serial.print(encoder3);
  Serial.print("\t");
  Serial.print("En4: ");  
  Serial.print(encoder4);
  Serial.print("\n");
  */

  // Hall sensor and switch test

  #ifdef PrintDebugData
    Serial.print(digitalRead(SwitchPin));  
    Serial.print("\t");
    //Serial.print(EncoderUpdateBool);  
    Serial.print(analogRead(HallSensor)); 
    Serial.print("\t"); 
  #endif

  UpdateEncoder();
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
  
}

#ifndef MEGA2560  

int UpdateC2000_1(void)
{
  //SerialC2000_1.begin(57604);
  if(SerialC2000_1.read() == 'T')
  {
    if(SerialC2000_1.read() == 'C')
    {
      char tempRead = SerialC2000_1.read();
      if(tempRead == 'A')
      {
        for(int i=0;i<BufferLength;i++)
        {
          SerialC2000_1_Buffer[i] = SerialC2000_1.read();
          //Serial.println(SerialC2000_1_Buffer[i]);
        }
        if(SerialC2000_1_Buffer[2] == 'E')
        {
          //Serial.println("Inn");
          long newValue = long(SerialC2000_1_Buffer[1]<<8) + SerialC2000_1_Buffer[0];         
          //if(abs(newValue - encoder1) < 15 || LastE1 == newValue)  encoder1 = newValue;  // 
          //LastE1 = newValue;
          encoder1 = newValue;
          //Serial.print("En1: ");
          //Serial.println(encoder1);
        }
      }
      else if(tempRead == 'B')
      {
        for(int i=0;i<BufferLength;i++)
        {
          SerialC2000_1_Buffer[i] = SerialC2000_1.read();
          //Serial.println(SerialC2000_1_Buffer[i]);
        }
        if(SerialC2000_1_Buffer[2] == 'E')
        {
          //Serial.println("Inn");
          //encoder2 = long(SerialC2000_1_Buffer[1]<<8) + SerialC2000_1_Buffer[0];

          long newValue = long(SerialC2000_1_Buffer[1]<<8) + SerialC2000_1_Buffer[0];         
          //if(abs(newValue - encoder2) < 60 || LastE2 == newValue)  encoder2 = newValue;
          //LastE2 = newValue;
          encoder2 = newValue;
          //Serial.print("En2: ");
          //Serial.println(encoder2);
        }

      }      
      //delay(1);
    }
  }
  return 1;
}

int UpdateC2000_2(void)
{  
  //SerialC2000_2.begin(57604);
  if(SerialC2000_2.read() == 'T')
  {
    if(SerialC2000_2.read() == 'C')
    {
      char tempRead = SerialC2000_2.read();
      if(tempRead == 'A')
      {
        for(int i=0;i<BufferLength;i++)
        {
          SerialC2000_2_Buffer[i] = SerialC2000_2.read();
          //Serial.println(SerialC2000_1_Buffer[i]);
        }
        if(SerialC2000_2_Buffer[2] == 'E')
        {
          //Serial.println("Inn");
          long newValue = long(SerialC2000_2_Buffer[1]<<8) + SerialC2000_2_Buffer[0];         
          //if(abs(newValue - encoder1) < 15 || LastE1 == newValue)  encoder1 = newValue;  // 
          //LastE1 = newValue;
          encoder3 = newValue;
          //Serial.print("En1: ");
          //Serial.println(encoder1);
        }
      }
      else if(tempRead == 'B')
      {
        for(int i=0;i<BufferLength;i++)
        {
          SerialC2000_2_Buffer[i] = SerialC2000_2.read();
          //Serial.println(SerialC2000_1_Buffer[i]);
        }
        if(SerialC2000_2_Buffer[2] == 'E')
        {
          //Serial.println("Inn");
          //encoder2 = long(SerialC2000_1_Buffer[1]<<8) + SerialC2000_1_Buffer[0];

          long newValue = long(SerialC2000_2_Buffer[1]<<8) + SerialC2000_2_Buffer[0];         
          //if(abs(newValue - encoder2) < 60 || LastE2 == newValue)  encoder2 = newValue;
          //LastE2 = newValue;
          encoder4 = newValue;
          //Serial.print("En2: ");
          //Serial.println(encoder2);
        }

      }      
      //delay(1);
    }
  }
  return 1;
}

#endif


/////////////////////////////////////////////////////////////MEGA
#ifdef MEGA2560  

int UpdateC2000_1(void)
{
  //SerialC2000_1.begin(57604);
  if((Serial1.available() >= 6))
  {
  if(Serial1.read() == 'T')
  {
    if(Serial1.read() == 'C')
    {
      char tempRead = Serial1.read();
      if(tempRead == 'A')
      {
        for(int i=0;i<BufferLength;i++)
        {
          SerialC2000_1_Buffer[i] = Serial1.read();
          //Serial.println(SerialC2000_1_Buffer[i]);
        }
        if(SerialC2000_1_Buffer[2] == 'E')
        {
          //Serial.println("Inn");
          long newValue = long(SerialC2000_1_Buffer[1]<<8) + SerialC2000_1_Buffer[0];         
          //if(abs(newValue - encoder1) < 15 || LastE1 == newValue)  encoder1 = newValue;  // 
          //LastE1 = newValue;
          encoder1 = newValue;
          //Serial.print("En1: ");
          //Serial.println(encoder1);
        }
      }
      else if(tempRead == 'B')
      {
        for(int i=0;i<BufferLength;i++)
        {
          SerialC2000_1_Buffer[i] = Serial1.read();
          //Serial.println(SerialC2000_1_Buffer[i]);
        }
        if(SerialC2000_1_Buffer[2] == 'E')
        {
          //Serial.println("Inn");
          //encoder2 = long(SerialC2000_1_Buffer[1]<<8) + SerialC2000_1_Buffer[0];

          long newValue = long(SerialC2000_1_Buffer[1]<<8) + SerialC2000_1_Buffer[0];         
          //if(abs(newValue - encoder2) < 60 || LastE2 == newValue)  encoder2 = newValue;
          //LastE2 = newValue;
          encoder2 = newValue;
          //Serial.print("En2: ");
          //Serial.println(encoder2);
        }

      }      
      //delay(1);
    }
  }
  }
  return 1;
}

int UpdateC2000_2(void)
{  
  //SerialC2000_2.begin(57604);
  if((Serial2.available() >= 6))
  {
  if(Serial2.read() == 'T')
  {
    if(Serial2.read() == 'C')
    {
      char tempRead = Serial2.read();
      if(tempRead == 'A')
      {
        for(int i=0;i<BufferLength;i++)
        {
          SerialC2000_2_Buffer[i] = Serial2.read();
          //Serial.println(SerialC2000_1_Buffer[i]);
        }
        if(SerialC2000_2_Buffer[2] == 'E')
        {
          //Serial.println("Inn");
          long newValue = long(SerialC2000_2_Buffer[1]<<8) + SerialC2000_2_Buffer[0];         
          //if(abs(newValue - encoder1) < 15 || LastE1 == newValue)  encoder1 = newValue;  // 
          //LastE1 = newValue;
          encoder3 = newValue;
          //Serial.print("En1: ");
          //Serial.println(encoder1);
        }
      }
      else if(tempRead == 'B')
      {
        for(int i=0;i<BufferLength;i++)
        {
          SerialC2000_2_Buffer[i] = Serial2.read();
          //Serial.println(SerialC2000_1_Buffer[i]);
        }
        if(SerialC2000_2_Buffer[2] == 'E')
        {
          //Serial.println("Inn");
          //encoder2 = long(SerialC2000_1_Buffer[1]<<8) + SerialC2000_1_Buffer[0];

          long newValue = long(SerialC2000_2_Buffer[1]<<8) + SerialC2000_2_Buffer[0];         
          //if(abs(newValue - encoder2) < 60 || LastE2 == newValue)  encoder2 = newValue;
          //LastE2 = newValue;
          encoder4 = newValue;
          //Serial.print("En2: ");
          //Serial.println(encoder2);
        }

      }      
      //delay(1);
    }
  }
  }
  return 1;
}


#endif

int UpdateEncoder(void) //Update 4 encoder (should consider the switch)
{
  int dE1 = encoder1 - LastE1;
  int dE2 = encoder2 - LastE2;
  int dE3 = encoder3 - LastE3;
  int dE4 = encoder4 - LastE4;
  
  if(EncoderUpdateBool)
  {
    Encoder_Counter[0] += dE1;
    Encoder_Counter[1] -= dE2;
    Encoder_Counter[2] -= dE3;
    Encoder_Counter[3] += dE4;
  }
  //Encoder_Counter[0] = encoder1;
  //Encoder_Counter[1] = encoder2;
  //Encoder_Counter[2] = encoder3;
  //Encoder_Counter[3] = encoder4;
  LastE1 = encoder1;
  LastE2 = encoder2;
  LastE3 = encoder3;
  LastE4 = encoder4;
  
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
