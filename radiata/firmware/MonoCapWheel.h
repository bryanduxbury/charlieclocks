#ifndef __MONO_CAP_WHEEL_H__
#define __MONO_CAP_WHEEL_H__

#include "MonoCap.h"

#define MIN_TOUCH_THRESHOLD 50
#define NOT_TOUCHED -1

class MonoCapWheel {
public:
  MonoCapWheel(MonoCap *e1, MonoCap *e2, MonoCap *e3);

  /**
   * Returns a number 0 <= x < 360 indicating degrees of orientation, where the
   * center of electrode 1 is 0 degrees. The physical layout of the electrodes
   * (and the order they are passed in) determines whether the degrees are 
   * clockwise or counter clockwise.
   */
  int16_t getOrientation();

private:
  MonoCap *e1;
  MonoCap *e2;
  MonoCap *e3;
};

#endif