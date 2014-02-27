#include "Charlie.h"
#include "TimerOne.h"

uint8_t charlie_pins[] = {0, 1, 2, 3, 4, 5, 6, 7, A0};
Charlie plex(charlie_pins, 9);

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

#define UPSW A1
#define DOWNSW A2

void setup() {
  // init the charlieplex before we start timer so that everything will be in
  // a clean state when we start.
  plex.init();

  // 5 usec timer interrupts
  Timer1.initialize(5);
  Timer1.attachInterrupt(tickISR, 20);

  // inputs for the switches
  pinMode(UPSW, INPUT);
  pinMode(DOWNSW, INPUT);
  digitalWrite(UPSW, HIGH);
  digitalWrite(DOWNSW, HIGH);
  
}

void loop() {
  clock();
}

void displayMinute(int minute, uint8_t duty) {
  plex.setDuty(mins2leds[minute % 60], duty);
  plex.setDuty(hours2leds[minute / 60], duty);
}

void clock() {
  int minute = 0;
  displayMinute(minute, DUTY_MAX);

  int consecutiveButtonPresses = 0;

  uint64_t start = millis();
  while (true) {
    uint64_t now = millis();

    // check if up or down switches are pressed
    bool upVal = digitalRead(UPSW) == LOW;
    bool downVal = digitalRead(DOWNSW) == LOW;
    if (upVal || downVal) {
      // clear the reference time, so we won't immediately roll the minute when
      // we let go of the buttons
      start = now;
      displayMinute(minute, 0);

      // inc or dec the minute, rolling as necessary
      if (upVal) {
        minute++;
        if (minute == 720) minute = 0;
      } else if (downVal) {
        minute--;
        if (minute == -1) minute = 719;
      }
      displayMinute(minute, DUTY_MAX);

      // if the user has held the button for more than 10 ticks, let's start 
      // moving faster, since they're probably going to a distant time
      if (++consecutiveButtonPresses > 10) {
        delay(25);
      } else {
        delay(500);
      }

      // continue here makes us skip the remainder of the clock loop. this is
      // important, so that we won't play second animation nor examine time as
      // it elapses.
      continue;
    }

    // so the user isn't pressing the time-setting buttons anymore, but they
    // were a second ago. pause for 1/2 second to give them a breath before we
    // start animating again.
    if (consecutiveButtonPresses > 0) {
      delay(500);
      consecutiveButtonPresses = 0;
    }

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

    // display the second animation
    for (int i = 0; i < 59; i++) {
      plex.setDuty(mins2leds[(minute + 1 + i) % 60], DUTY_MAX);
      delay(500/60);
      plex.setDuty(mins2leds[(minute + 1 + i) % 60], 0);
    }
    delay(500);
  }
}

void tickISR() {
  plex.tick();
}
