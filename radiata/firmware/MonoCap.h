#ifndef __MONO_CAP_H__
#define __MONO_CAP_H__

#include "Arduino.h"

class MonoCap {
public:
  MonoCap(uint8_t pin, uint8_t num_samples);
  void init();

  void calibrate();

  // Sample the touch electrode a number of times and return the result with 
  // respect to the calibration value.
  int16_t measure();
  
  // Sample the touch electrode a number of times, and then return the result 
  // mapped onto a normalized value 0 <= x <= 255.
  uint8_t measureNormalized();
  void setRange(uint16_t min, uint16_t max);

private:
  uint8_t pin;
  volatile uint8_t *port;
  uint8_t portmask;
  uint8_t adc_pin;
  uint8_t num_samples;

  uint16_t calibration_value;
  uint16_t min, max;

  uint16_t measureInternal();
  void enablePullup();
  void disablePullup();
};


#endif