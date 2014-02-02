#include "Charlie.h"
#include "TimerOne.h"
#include "MonoCap.h"
// #include "MonoCapWheel.h"

uint8_t charlie_pins[] = {0, 1, 2, 3, 4, 5, 6, 7, A0};
Charlie plex(charlie_pins, 9);
MonoCap electrode90(A3, 10);
MonoCap electrode210(A4, 10);
MonoCap electrode330(A5, 10);
// MonoCapWheel wheel(&electrode90, &electrode330, &electrode210);

const uint8_t mins2leds[] = {
  63, 0, 1, 2, 3, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
  19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
  39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 60, 61, 62
};

const uint8_t hours2leds[] = {
  56, 57, 58, 
  59, 64, 65, 
  66, 67, 68, 
  69, 70, 71
};

void setup() {
  // init the charlieplex before we start timer so that everything will be in
  // a clean state when we start.
  plex.init();

  // 5 usec timer interrupts
  Timer1.initialize(5);
  Timer1.attachInterrupt(tickISR, 20);

  electrode90.init();
  electrode210.init();
  electrode330.init();

  electrode210.suppress();
  electrode330.suppress();
  electrode90.calibrate();

  electrode90.suppress();
  electrode210.calibrate();

  electrode210.suppress();
  electrode330.calibrate();
}

void loop() {
  // fastStrobe();
  int initTime = forceSetTime();
  clock(initTime);
}

void readSensors(bool &modeButton, bool &downButton, bool &upButton) {
  plex.pause();

  electrode210.suppress();
  electrode330.suppress();
  modeButton = electrode90.measureNormalized() >= 200;
  electrode90.suppress();
  downButton = electrode210.measureNormalized() >= 200;
  electrode210.suppress();
  upButton = electrode330.measureNormalized() >= 200;

  plex.resume();
}

void displayMinute(int minute, uint8_t duty) {
  plex.setDuty(mins2leds[minute % 60], duty);
  plex.setDuty(hours2leds[minute / 60], duty);
}

// returns the minute that the user settled on
// TODO: make it blink when not touched to indicate it's in set mode
// TODO: make it go faster when a single direction is held down for some time
int setTime() {
  int minute = 0;
  displayMinute(minute, DUTY_MAX);
  while (true) {
    // check all the sensors
    bool modePressed, downPressed, upPressed;
    readSensors(modePressed, downPressed, upPressed);
    
    if (modePressed + downPressed + upPressed == 1) {
      if (modePressed) {
        // mode button exits setTime when held down for 2 seconds
        // TODO
      } else if (downPressed) {
        displayMinute(minute, 0);

        // decrease the minute counter
        minute--;
        if (minute < 0) minute = 719;
        displayMinute(minute, DUTY_MAX);
      } else {
        displayMinute(minute, 0);

        // increase the minute counter
        minute++;
        if (minute == 720) minute = 0;
        displayMinute(minute, DUTY_MAX);
      }
    }

    delay(250);
  }
}

int forceSetTime() {
  // blink all the leds on and off until the left or right electrodes are 
  // touched
  while (true) {
    bool modePressed, downPressed, upPressed;
    readSensors(modePressed, downPressed, upPressed);
    if (modePressed + downPressed + upPressed > 0) {
      break;
    }

    for (int i = 0; i < 60; i++) {
      plex.setDuty(mins2leds[i], DUTY_MAX);
    }
    for (int i = 0; i < 12; i++) {
      plex.setDuty(hours2leds[i], DUTY_MAX);
    }
    delay(500);
    for (int i = 0; i < 60; i++) {
      plex.setDuty(mins2leds[i], 0);
    }
    for (int i = 0; i < 12; i++) {
      plex.setDuty(hours2leds[i], 0);
    }
    delay(500);
  }
  

  // put the cursor at 1200, then let the user hit right or left to move the 
  // cursor
  return setTime();
}

void clock(int initTime) {
  int minute = initTime;
  uint16_t start = millis();
  while (true) {
    uint16_t now = millis();

    // check if we've rolled over another minute
    if (now >= start + 60000) {
      start = now;
      // turn off old minute
      displayMinute(minute, 0);
      minute++;
      if (minute == 720) minute = 0;
      // turn on new minute
      displayMinute(minute, DUTY_MAX);
    }

    // check if the mode button is being pressed and we should go into set mode
    // TODO
    
    // display the second animation
    // TODO
    
    // TODO: do we even need this delay?
    delay(1);
  }
}

void fastStrobe() {
  for (int hour = 0; hour < 12; hour++) {
    plex.setDuty(hours2leds[hour], DUTY_MAX);
    for (int min = 0; min < 60; min++) {
      plex.setDuty(mins2leds[min], DUTY_MAX);
      for (int sec = 0; sec < 60; sec ++) {
        if (sec != min) {
          plex.setDuty(mins2leds[sec], 1);
        }
        delay(1000);
        if (sec != min) {
          plex.setDuty(mins2leds[sec], 0);
        }
      }
      plex.setDuty(mins2leds[min], 0);
    }
    plex.setDuty(hours2leds[hour], 0);
  }
}

void tickISR() {
  plex.tick();
}
