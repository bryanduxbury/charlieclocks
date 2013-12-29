#include "MonoCapWheel.h"

#define IS_MAX(x, y, z) ((x) > (y) && (x) > (z))

MonoCapWheel::MonoCapWheel(MonoCap *e1, MonoCap *e2, MonoCap *e3) {
  this->e1 = e1;
  this->e2 = e2;
  this->e3 = e3;
}

int16_t MonoCapWheel::getOrientation() {
  // measure left, right, and outer values
  uint8_t e1Val = e1->measureNormalized();
  uint8_t e2Val = e2->measureNormalized();
  uint8_t e3Val = e3->measureNormalized();

  if (e1Val < MIN_TOUCH_THRESHOLD 
    && e2Val < MIN_TOUCH_THRESHOLD 
    && e3Val < MIN_TOUCH_THRESHOLD)
  {
    return NOT_TOUCHED;
  }

  // DEBUG("l:", leftVal);
  // DEBUG("r:", rightVal);
  // DEBUG("o:", outerVal);

  // TODO: are all the electrodes of approximately equal values? 
  // return ALL_TOUCHED;

  uint16_t v12 = (uint16_t)e1Val + e2Val;
  uint16_t v23 = (uint16_t)e2Val + e3Val;
  uint16_t v13 = (uint16_t)e1Val + e3Val;

  // DEBUG("lr:", lr);
  // DEBUG("lo:", lo);
  // DEBUG("ro:", ro);

  int16_t result = 0;

  if (IS_MAX(v12, v23, v13)) {
    // e1/e2 interaction
    float proportion = (float)e2Val / v12;
    result = proportion * 120;
  } else if (IS_MAX(v13, v12, v23)) {
    // e1/e3 interaction
    float proportion = (float)e1Val / v13;
    result = 360 - proportion * 120; 
  } else {
    // e2/e3 interaction
    float proportion = (float)e3Val / v23;
    result = 120 + proportion * 120;
  }

  return result;
}