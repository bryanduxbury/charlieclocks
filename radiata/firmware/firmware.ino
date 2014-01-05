#include "Charlie.h"
#include "TimerOne.h"
#include "MonoCap.h"
#include "MonoCapWheel.h"

uint8_t charlie_pins[] = {0, 1, 2, 3, 4, 5, 6, 7, A0};
Charlie plex(charlie_pins, 9);
MonoCap electrode90(A3, 10);
MonoCap electrode210(A4, 10);
MonoCap electrode330(A5, 10);
MonoCapWheel wheel(&electrode90, &electrode330, &electrode210);

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
  // electrode90.setRange(8050, 9500);
  // electrode90.measureNormalized();

  electrode90.suppress();
  electrode210.calibrate();
  // electrode210.measureNormalized();
  // electrode210.setRange(8000, 9500);

  electrode210.suppress();
  electrode330.calibrate();
  // electrode330.measureNormalized();
  // electrode330.setRange(8000, 9500);
}

void loop() {
  // testSequence();
  // fastStrobe();
  touchTest();
  // wheelTest();
}

void wheelTest() {
  int lastOn = -1;
  while (true) {
    delay(100);
    // plex.clear();
    // int16_t orientation = wheel.getOrientation();
    // if (orientation == NOT_TOUCHED) {
    //   plex.clear();
    // } else {
    //   display3Digits(orientation);
    // }

    

    if (lastOn != -1) {
      plex.setDuty(mins2leds[lastOn], 0);
      lastOn = -1;
    }
    
    plex.clear();
    int16_t o1 = wheel.getOrientation();
    // // int16_t o2 = wheel.getOrientation();
    // // int16_t o3 = wheel.getOrientation();
    // // 
    // if (o1 == NOT_TOUCHED /*|| o2 == NOT_TOUCHED || o3 == NOT_TOUCHED*/) {
    //   continue;
    // }
    // 
    // // int16_t orientation = (o1 + o2 + o3) / 3;
    int16_t orientation = o1;
    
    if (orientation != NOT_TOUCHED) {
      lastOn = orientation / 6;
      plex.setDuty(mins2leds[orientation / 6], DUTY_MAX);
    } else {
      lastOn = -1;
    }
  }
}

void touchTest() {
  while (true) {
    // electrode210.suppress();
    // electrode330.suppress();
    uint8_t val = electrode90.measureNormalized();
    display3Digits(val);
    // for (int i = 0; i < 60; i++) {
    //   if (i < val / (255.0 / 60)) {
    //     plex.setDuty(mins2leds[i], DUTY_MAX);
    //   } else {
    //     plex.setDuty(mins2leds[i], 0);
    //   }
    // 
    //   // plex.setDuty(mins2leds[i * 3 + 1], DUTY_MAX);
    //   // plex.setDuty(mins2leds[i * 3 + 2], DUTY_MAX);
    // }

    delay(500);
    // plex.clear();
  }
}

void display3Digits(uint16_t val) {
  uint8_t x = val;

  for (int i = 0; i < 10; i++) {
    plex.setDuty(mins2leds[i + 20], i < val % 10 ? DUTY_MAX : 0);
  }
  
  val /= 10;  

  for (int i = 0; i < 10; i++) {
    plex.setDuty(mins2leds[i + 10], i < val % 10 ? DUTY_MAX : 0);
  }

  val /= 10;

  for (int i = 0; i < 10; i++) {
    plex.setDuty(mins2leds[i + 0], i < val % 10 ? DUTY_MAX : 0);
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

void testSequence() {
  // int highpins[] = {A0};
  int highpins[] = {0, 1, 2, 3, 4, 5, 6, 7, A0};
  int lowpins[] = {0, 1, 2, 3, 4, 5, 6, 7, A0};
  // int lowpins[] = { 7};
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (highpins[i] == lowpins[j]) continue;
      // pulse the selected LED for 1000 milliseconds.
      pulseFor(highpins[i], lowpins[j], 100);
    }
  }
}

// output a simple bitbang PWM for testing purposes. produces a 1 kHz, 10% duty wave 
// which should be safe for any of the LEDs to take nonstop.
void pulseFor(int high, int low, unsigned int duration) {
  // note start time
  unsigned int start = millis();
  
  // prepare the selected pins to source or sink current as appropriate.
  pinMode(high, OUTPUT);
  pinMode(low, OUTPUT);

  // loop until we've past the desired end point. note that this could do an "extra"
  // pulse, since we aren't interrupting an ongoing pulse.
  while (millis() < start + duration) {
    digitalWrite(high, HIGH);
    delayMicroseconds(100);
    digitalWrite(high, LOW);
    delayMicroseconds(900);
  }
  
  // put the pins back to low, since 
  pinMode(high, INPUT);
  pinMode(low, INPUT);
}

void tickISR() {
  plex.tick();
}
