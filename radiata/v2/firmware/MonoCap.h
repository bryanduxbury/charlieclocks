#ifndef __MONO_CAP_H__
#define __MONO_CAP_H__

#include "Arduino.h"

class MonoCap {
public:
  MonoCap(uint8_t pin, uint8_t num_samples);
  void init();

  void calibrate();

  // reduce the potential for this electrode to interfere with nearby 
  // electrodes during measurement. calling measure() will disable suppression.
  void suppress();

  // Sample the touch electrode a number of times and return a result. Most 
  // noise should be filtered, so nonzero values represent actual signal.
  uint16_t measure();

  // Sample the touch electrode a number of times, and then return the result 
  // mapped onto a normalized value 0 <= x <= 255. The maximum value is learned
  // over time from actual values.
  uint8_t measureNormalized();

  // deprecated
  void setRange(uint16_t min, uint16_t max);

private:
  uint8_t pin;
  volatile uint8_t *port;
  uint8_t portmask;
  uint8_t adc_pin;
  uint8_t num_samples;

  uint16_t touch_threshold;
  uint16_t max;

  uint16_t measureInternal();
  void enablePullup();
  void disablePullup();
};


#endif