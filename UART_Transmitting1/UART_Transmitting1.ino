//#define ByteNumber 12

//Globle Variables
//unsigned long tempt = 0;
//unsigned long temp = 0;
//unsigned char SendingBytes[ByteNumber] = {0};
long Axis1 = 10000;
int Axis2 = 20000;
int Axis3 = 30000;
int Axis4 = 60000;
int Axis5 = 70000;

//float Axis1 = 0;
//float Axis2 = 0;
//float Axis3 = 0;
//float Axis4 = 0;
//float Axis5 = 0;
//
//String delim = ",";
//unsigned char StartingByte = 0xFF;

char delim = ',';
char eol = '\n';

void setup() 
{
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.flush();
  //Timer 2 Register setting
//  TCCR2A =((1<<WGM21)|(1<<WGM20)/*|(1<<COM2B1)|(1<<COM2C1)*/);
//  TCCR2B = (1<<WGM22)|(1<<CS21)|(1<<CS20)|(1<<CS22);
//  OCR2A = 156;  // set interrupt time to be about 0.01 sec
//  TIMSK2 = B00000001;//(1 << TOIE1);
  //

  //
  //Arbitually initialize the axis variable
//  Axis1 = 500;
//  Axis2 = 10000;
//  Axis3 = 29647;
//  Axis4 = 7775;
//  Axis5 = 5532;
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

//  Serial.flush();
  Serial.print(micros());
  char buffer[50];
  sprintf(buffer, "%ul,%d,%d,%d,%d",Axis1,Axis2,Axis3,Axis4,Axis5);
  Serial.println(buffer);
//  delay(10);
  Serial.print(micros());

  
//  Serial.sprintf(Axis1,"%d");//Serial.print('\n');
//  Serial.print(delim,"%c");
//  Serial.print(Axis2,"%d");
//  Serial.print(delim,"%c");
//  Serial.print(Axis3,"%d");
//  Serial.print(delim,"%c");
//  Serial.print(Axis4,"%d");
//  Serial.print(delim,"%c");
//  Serial.print(Axis5,"%d");
//  Serial.print(eol,"%c");
//  delay(1);
//  Serial.flush();

//  
//  delay(2000);
}

//ISR(TIMER2_OVF_vect) // Timer2 interrupt function which executes every 0.01 sec according to the Timer2 setting
//{  
//  temp = micros() - tempt; // calculate the time 
//  //
//  // Extract the Data
//  unsigned char Axis1L = Axis1 & 0xFF;
//  unsigned char Axis1H = (Axis1>>8) & 0xFF;
//  unsigned char Axis2L = Axis2 & 0xFF;
//  unsigned char Axis2H = (Axis2>>8) & 0xFF;
//  unsigned char Axis3L = Axis3 & 0xFF;
//  unsigned char Axis3H = (Axis3>>8) & 0xFF;
//  unsigned char Axis4L = Axis4 & 0xFF;
//  unsigned char Axis4H = (Axis4>>8) & 0xFF;
//  unsigned char Axis5L = Axis5 & 0xFF;
//  unsigned char Axis5H = (Axis5>>8) & 0xFF;
//  // 
////  // Putting Data in Sequence
////  SendingBytes[0] = StartingByte;
////  SendingBytes[1] = Axis1H;
////  SendingBytes[2] = Axis1L;
////  SendingBytes[3] = Axis2H;
////  SendingBytes[4] = Axis2L;
////  SendingBytes[5] = Axis3H;
////  SendingBytes[6] = Axis3L;
////  SendingBytes[7] = Axis4H;
////  SendingBytes[8] = Axis4L;
////  SendingBytes[9] = Axis5H;
////  SendingBytes[10] = Axis5L;
//  
////  //
////  //Calculate the Ckeck Sum
////  unsigned long CkSum = 0;
////  for(int i=0;i<ByteNumber-2;i++)
////  {
////    CkSum = CkSum + SendingBytes[i];
////  }
////  unsigned char CkSumL = CkSum & 0xFF;
////  unsigned char CkSumH = (CkSum>>8) & 0xFF;
////  SendingBytes[28] = CkSumH;
////  SendingBytes[29] = CkSumL;
////  //
//
//  SendingBytes[0] = Axis1H;
//  SendingBytes[1] = Axis1L;
//  SendingBytes[2] = Axis2H;
//  SendingBytes[3] = Axis2L;
//  SendingBytes[4] = Axis3H;
//  SendingBytes[5] = Axis3L;
//  SendingBytes[6] = Axis4H;
//  SendingBytes[7] = Axis4L;
//  SendingBytes[8] = Axis5H;
//  SendingBytes[9] = Axis5L;
//  unsigned char second_last = 'y';
//  unsigned char last = 'z';
//  SendingBytes[10] = second_last;
//  SendingBytes[11] = last;
//  
//  //Sending Data
//  Serial.print(SendingBytes[0]);
//  for(int i=0;i<ByteNumber;i++)
//  {
//    Serial.print(SendingBytes[i]);
////    if (i<ByteNumber-1){
////      Serial.print(",");
////    }
//  }
////  Serial.print(Axis1);
////  Serial.print(delim);
////  Serial.print(Axis2);
////  Serial.print(delim);
////  Serial.print(Axis3);
////  Serial.print(delim);
////  Serial.print(Axis4);
////  Serial.print(delim);
////  Serial.print(Axis5);
////  Serial.print('\n');
//
//  //
//  // Print of checking
//  //  Serial.print(Axis3H*256+Axis3L);
//  //  Serial.print("\t");
//  //  Serial.print(CkSum);
//  //  Serial.print("\t");    
//  //  Serial.print(CkSumH*256+CkSumL);
//  //  Serial.print("\n");    
//  //
//  tempt = micros();
//  //Serial.println(temp);  
//}
