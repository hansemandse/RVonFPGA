char myS[2];
int i = 0;
int incomingBytes[4] = {0, 0, 0, 0};

void setup() {
  Serial.begin(115200);
}

void loop() {
  if (Serial.available() > 0) {
    incomingBytes[i] = Serial.read();
    i++;
  }
  if (i == sizeof(incomingBytes)/sizeof(int)) {
    for (int j = 0; j < sizeof(incomingBytes)/sizeof(int); j++) {
      sprintf(myS, "%2X", incomingBytes[j]);
      Serial.print(myS);
    }
    Serial.print("\n");
    i = 0;
  }
}
