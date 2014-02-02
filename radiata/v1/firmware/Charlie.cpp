#include "Charlie.h"

Charlie::Charlie(uint8_t pins[], int nPins) {
  numLEDs = nPins * nPins - nPins;
  ledDefns = (LedDefn*)malloc(numLEDs * sizeof(LedDefn));
  LedDefn *cur = ledDefns;

  for (int high = 0; high < nPins; high++) {
    for (int low = 0; low < nPins; low++) {
      if (high == low) continue;

      LedDefn defn;
      defn.high_ddr = portModeRegister(digitalPinToPort(pins[high]));
      defn.low_ddr = portModeRegister(digitalPinToPort(pins[low]));
      defn.high_port = portOutputRegister(digitalPinToPort(pins[high]));
      defn.highmask = digitalPinToBitMask(pins[high]);
      defn.lowmask = digitalPinToBitMask(pins[low]);
      defn.duty = 0;
      *cur++ = defn;
    }
  }
  
  pauseRequested = false;
  paused = false;
}

// Turn all the pins in the plex to INPUT and LOW. This makes sure every pin is
// ready to be used as a highside or lowside. Note that this will do some 
// duplicate work.
void Charlie::init() {
  for (int i = 0; i < numLEDs; i++) {
    LedDefn currentDefn = ledDefns[i];
    *(currentDefn.high_ddr) &= ~currentDefn.highmask;
    *(currentDefn.high_port) &= ~currentDefn.highmask;
  }
}

void Charlie::tick() {
  LedDefn currentDefn;

  // increment the tick count
  tickCount++;

  // check if the current LED has reached the limit of it's duty cycle
  if (curDuty == tickCount || (pauseRequested && !paused)) {
    // need to retrieve the ledDefn now so that we can turn it off!
    currentDefn = ledDefns[curLED];
    *(currentDefn.high_ddr) &= ~currentDefn.highmask;
    *(currentDefn.high_port) &= ~currentDefn.highmask;
    *(currentDefn.low_ddr) &= ~currentDefn.lowmask;
  }

  // if a pause has been requested, then at this point we've succeeded in 
  // pausing (by turning off the current LED), so we should set the paused 
  // flag to let the pauser now it's ok to continue.
  if (pauseRequested) {
    paused = true;
  }
  
  // so we're not supposed to be paused anymore, but we are. clear the paused 
  // flag so we can get back to work.
  if (paused && !pauseRequested) {
    paused = false;
  }

  // if tickCount reaches DUTY_MAX, it's time to reset tickCount and move on to
  // the next LED
  if (tickCount == DUTY_MAX) {
    tickCount = 0;

    // wrap around from end to beginning if necessary
    curLED++;
    if (curLED == numLEDs) {
      curLED = 0;
    }

    // turn on the next LED unless its duty is 0
    currentDefn = ledDefns[curLED];

    // copy the target duty into the current duty. this prevents a race condition
    // that can cause an LED not to be turned off when the duty is set to a number
    // lower than the tickCount while the LED is currently lit.
    // if we're paused (either because this condition was set in the current 
    // tick or a prior one), then we'll just force the duty to 0. this will
    // ensure that we don't turn on again.
    if (paused) {
      curDuty = 0;
    } else {
      curDuty = currentDefn.duty;
    }

    if (curDuty != 0) {
      *(currentDefn.high_ddr) |= currentDefn.highmask;
      *(currentDefn.low_ddr) |= currentDefn.lowmask;
      *(currentDefn.high_port) |= currentDefn.highmask;
      // never need to set the low port, since it should already be set to LOW.
    }
  }
}

void Charlie::setDuty(int ledNum, uint8_t duty) {
  ledDefns[ledNum].duty = duty;
}

void Charlie::clear() {
  for (int i = 0; i < numLEDs; i++) {
    ledDefns[i].duty = 0;
  }
}

void Charlie::pause() {
  pauseRequested = true;
  while (!paused) {
    // tight loop
  }
}

void Charlie::resume() {
  pauseRequested = false;
}