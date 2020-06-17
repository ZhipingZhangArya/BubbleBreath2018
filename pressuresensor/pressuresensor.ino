#include <Wire.h>
#include <Adafruit_BMP085.h>

/*************************************************** 
  This is the code for reading air pressure data from BMP180 sensor and 'connect' with Processing.
  This code is modified based on  the example for the BMP085 Barometric Pressure & Temp Sensor
  These displays use I2C to communicate, 2 pins are required to interface
  Adafruit invests time and resources providing this open source code, 
  please support Adafruit and open-source hardware by purchasing 
  products from Adafruit!
  Written by Limor Fried/Ladyada for Adafruit Industries.  
  BSD license, all text above must be included in any redistribution
 ****************************************************/

// Connect VCC of the BMP180 sensor to 3.3V
// Connect GND to Ground
// Connect SCL to i2c clock - on '168/'328 Arduino Uno/Duemilanove/etc thats Analog 5
// Connect SDA to i2c data - on '168/'328 Arduino Uno/Duemilanove/etc thats Analog 4
// EOC is not used, it signifies an end of conversion
// XCLR is a reset pin, also not used here

Adafruit_BMP085 bmp;
  float val = 0;
void setup() {
  Serial.begin(9600);
  //for checking
  if (!bmp.begin()) {
	Serial.println("Could not find a valid BMP085 sensor, check wiring!");
	while (1) {}
  }
}
  
void loop() {
 val=bmp.readPressure()-102000;//(-102000)is to simplified the val.
    Serial.write((byte)val);
    delay(20);
}
