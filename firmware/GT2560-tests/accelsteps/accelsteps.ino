// ConstantSpeed.pde
// -*- mode: C++ -*-
//
// Shows how to run AccelStepper in the simplest,
// fixed speed mode with no accelerations
/// \author  Mike McCauley (mikem@airspayce.com)
// Copyright (C) 2009 Mike McCauley
// $Id: ConstantSpeed.pde,v 1.1 2011/01/05 01:51:01 mikem Exp mikem $

#include <AccelStepper.h>
#include <Streaming.h>

#define pXEN 27
#define pXSTEP 25
#define pXDIR 23

#define mSTOP     0x31
#define mSTART    0x32
#define mREVERSE  0x33
#define mFORWARD  0x34
#define mFASTER1  0x35
#define mFASTER10 0x36
#define mSLOWER10 0x37
#define mSLOWER1  0x38
#define mSHOW     0x3F

AccelStepper Xaxis(AccelStepper::DRIVER, pXSTEP, pXDIR);

void menu() {
    Serial << "\nMenu";
    Serial << "\n----\n";
    Serial << char(mSTOP)     << ": Stop\n";
    Serial << char(mSTART)    << ": Start\n";
    Serial << char(mREVERSE)  << ": Reverse\n";
    Serial << char(mFORWARD)  << ": Forward\n";
    Serial << char(mFASTER1)  << ": Faster by 1\n";
    Serial << char(mFASTER10) << ": Faster by 10\n";
    Serial << char(mSLOWER10) << ": Slower by 10\n";
    Serial << char(mSLOWER1)  << ": Slower by 1\n";
    Serial << char(mSHOW)     << ": Show menu\n";
}

void adjustSpeed(float adj) {
    Xaxis.setSpeed(Xaxis.speed() + adj);
    Serial << "Speed: " << Xaxis.speed() << endl;
}

// @param dir: one of mFORWARD or mREVERSE
void adjustDir(int dir) {
    float speed = Xaxis.speed();

    speed = abs(speed) * (dir==mFORWARD ? 1.0 : -1.0);

    Xaxis.setSpeed(speed);
    Serial << "Speed: " << Xaxis.speed() << endl;
}

void serialEvent() {
    char b = Serial.read();

    while (b != -1) {
        switch(b) {
            case mSTOP:
                Xaxis.disableOutputs();
                break;
            case mSTART:
                Xaxis.enableOutputs();
                break;
            case mREVERSE:
            case mFORWARD:
                adjustDir(b);
                break;
            case mFASTER1:
                adjustSpeed(1);
                break;
            case mFASTER10:
                adjustSpeed(10);
                break;
            case mSLOWER10:
                adjustSpeed(-10);
                break;
            case mSLOWER1:
                adjustSpeed(-1);
                break;
            case mSHOW:
                menu();
                break;
            default:
                Serial << "Invalid option: " << char(b) << endl;
        }
        b = Serial.read();
    }
}

void setup()
{  
    Serial.begin(115200);
    Serial << "Ready....\n";
    Xaxis.setEnablePin(pXEN);
    Xaxis.setPinsInverted(false, false, true);
    //Xaxis.enableOutputs();
    Xaxis.setMinPulseWidth(500);
    Xaxis.setMaxSpeed(1000);
    Xaxis.setSpeed(900);	
    menu();
}

void loop()
{  
   Xaxis.runSpeed();
}
