#define ByteNumber 30

//Globle Variables
unsigned long tempt = 0;
unsigned long temp = 0;
unsigned char SendingBytes[ByteNumber] = {0};
unsigned int Axis1 = 0;
unsigned int Axis2 = 0;
unsigned int Axis3 = 0;
unsigned int Axis4 = 0;
unsigned int Axis5 = 0;
unsigned char StartingByte = 0xFF;

void setup() 
{
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.flush();
  //Timer 2 Register setting
  TCCR2A =((1<<WGM21)|(1<<WGM20)/*|(1<<COM2B1)|(1<<COM2C1)*/);
  TCCR2B = (1<<WGM22)|(1<<CS21)|(1<<CS20)|(1<<CS22);
  OCR2A = 156;  // set interrupt time to be about 0.01 sec
  TIMSK2 = B00000001;//(1 << TOIE1);
  //

  //
  //Arbitually initialize the axis varible
  Axis1 = 500;
  Axis2 = 10000;
  Axis3 = 29647;
  Axis4 = 7775;
  Axis5 = 5532;
}

void loop() 
{
  // put your main code here, to run repeatedly:
  // Arbitually change the axis varible
//  Axis1++;
//  Axis2 = Axis2 + 2;
//  Axis3 = Axis3 + 3;
//  Axis4 = Axis4 + 4;
//  Axis5 = Axis5 + 5;
  delay(2000);
}

ISR(TIMER2_OVF_vect) // Timer2 interrupt function which executes every 0.01 sec according to the Timer2 setting
{  
  temp = micros() - tempt; // calculate the time 
  //
  // Extract the Data
  unsigned char Axis1L = Axis1 & 0xFF;
  unsigned char Axis1H = (Axis1>>8) & 0xFF;
  unsigned char Axis2L = Axis2 & 0xFF;
  unsigned char Axis2H = (Axis2>>8) & 0xFF;
  unsigned char Axis3L = Axis3 & 0xFF;
  unsigned char Axis3H = (Axis3>>8) & 0xFF;
  unsigned char Axis4L = Axis4 & 0xFF;
  unsigned char Axis4H = (Axis4>>8) & 0xFF;
  unsigned char Axis5L = Axis5 & 0xFF;
  unsigned char Axis5H = (Axis5>>8) & 0xFF;
  // 
  // Putting Data in Sequence
  SendingBytes[0] = StartingByte;
  SendingBytes[1] = Axis1H;
  SendingBytes[2] = Axis1L;
  SendingBytes[3] = Axis2H;
  SendingBytes[4] = Axis2L;
  SendingBytes[5] = Axis3H;
  SendingBytes[6] = Axis3L;
  SendingBytes[7] = Axis4H;
  SendingBytes[8] = Axis4L;
  SendingBytes[9] = Axis5H;
  SendingBytes[10] = Axis5L;
  //
  //Calculate the Ckeck Sum
  unsigned long CkSum = 0;
  for(int i=0;i<ByteNumber-2;i++)
  {
    CkSum = CkSum + SendingBytes[i];
  }
  unsigned char CkSumL = CkSum & 0xFF;
  unsigned char CkSumH = (CkSum>>8) & 0xFF;
  SendingBytes[28] = CkSumH;
  SendingBytes[29] = CkSumL;
  //
  //Sending Data
  //Serial.print(SendingBytes[0]);
  for(int i=0;i<ByteNumber;i++)
  {
    Serial.write(SendingBytes[i]);
  }
  //
  // Print of checking
  //  Serial.print(Axis3H*256+Axis3L);
  //  Serial.print("\t");
  //  Serial.print(CkSum);
  //  Serial.print("\t");    
  //  Serial.print(CkSumH*256+CkSumL);
  //  Serial.print("\n");    
  //
  tempt = micros();
  //Serial.println(temp);  
}
