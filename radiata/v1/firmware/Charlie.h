#ifndef __CHARLIE_H__
#define __CHARLIE_H__

#include "Arduino.h"

#define DUTY_MAX 5

class Charlie {
 public:
  Charlie(uint8_t pins[], int nPins);
  void init();

  void setDuty(int ledNum, uint8_t duty);
  void clear();

  void pause();
  void resume();

  void tick();

 private:
  struct LedDefn {
    volatile uint8_t *high_ddr;
    volatile uint8_t *high_port;
    volatile uint8_t *low_ddr;
    uint8_t highmask;
    uint8_t lowmask;
    volatile uint8_t duty;
  };

  volatile uint8_t curDuty;

  volatile bool pauseRequested;
  volatile bool paused;

  uint8_t tickCount;
  uint8_t curLED;

  LedDefn* ledDefns;
  uint8_t numLEDs;
};

#endif
