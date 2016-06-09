/**
 * Test for stepper drivers.
 */
#include <Streaming.h>

#define pXEN 27
#define pXSTEP 25
#define pXDIR 23

#define CLW HIGH
#define CCLW LOW

void enableDriver(int pin) {
    // Enable is active low
    digitalWrite(pin, LOW);
}
void disableDriver(int pin) {
    // Enable is active low, so set high to disable
    digitalWrite(pin, HIGH);
}

void setup() {
	Serial.begin(9600);
    Serial << "Ready....\n";
    // Set up the control pins
    pinMode(pXEN, OUTPUT); 
    disableDriver(pXEN);
    pinMode(pXSTEP, OUTPUT); 
    digitalWrite(pXSTEP, LOW);
    pinMode(pXDIR, OUTPUT); 
    digitalWrite(pXDIR, LOW);
}

// Run the motor in a direction at a specific speed for a specific time
void runMotor(int dir, int speed, int dur) {
    // Set the direction
    digitalWrite(pXDIR, dir);
    // The delay based on speed
    int speedPause = 1000 - speed;
    int pulseLen = speedPause/10;
    pulseLen = pulseLen < 1 ? 1 : pulseLen;
    enableDriver(pXEN);


    while (1) {
        Serial << "In... ";
        // Enable the driver
        //enableDriver(pXEN);
        Serial << "enabled... ";
        // Pulse the stepper
        digitalWrite(pXSTEP, HIGH);
        Serial << "pulse[" << pulseLen << "]... ";
        delay(pulseLen);
        digitalWrite(pXSTEP, LOW);
        //disableDriver(pXEN);
        Serial << "pulse off, disable[" << speedPause << "]\n";
        // Wait
        delay(speedPause);
    }
}

void forward(int speed, int dur) {
    runMotor(CLW, speed, dur);
}
void reverse(int speed, int dur) {
    runMotor(CCLW, speed, dur);
}

// the loop function runs over and over again forever
void loop() {
    forward(999, 10);
}
