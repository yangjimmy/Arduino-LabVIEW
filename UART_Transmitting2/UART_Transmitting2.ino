void setup() {
  Serial.begin(115200); // Set the baud rate to 115200 (you can adjust this if needed)
  Serial.setTimeout(10); // Set a timeout for Serial.read() if necessary
}

void loop() {
  static unsigned long previousMillis = 0;
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= 10) { // 10 ms delay for 100 Hz
    previousMillis = currentMillis;

//    // Your data acquisition code or calculations
//    int data = analogRead(A0); // Example: reading an analog pin

    // Serial print
    Serial.println(data);
  }
}
