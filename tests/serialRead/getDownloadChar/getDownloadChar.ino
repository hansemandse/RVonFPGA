int incomingByte = 0;

void setup() {
  Serial.begin(115200);
}

void loop() {
  if (Serial.available() > 0) {
    incomingByte = Serial.read();
    if (incomingByte == 0x77) {
      Serial.print("YES!\n");
    } else {
      Serial.print("NO! Value: ");
      Serial.print(incomingByte, HEX);
      Serial.print("\n");
    }
  }
}
