#include "MonoCapWheel.h"

#define IS_MAX(x, y, z) ((x) > (y) && (x) > (z))

MonoCapWheel::MonoCapWheel(MonoCap *e1, MonoCap *e2, MonoCap *e3) {
  this->e1 = e1;
  this->e2 = e2;
  this->e3 = e3;
}

uint8_t collectReading(MonoCap *electrode, MonoCap *other1, MonoCap *other2) {
  // other1->suppress();
  // other2->suppress();
  uint16_t sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += electrode->measureNormalized();
    // delayMicroseconds(500);
  }
  return sum / 10;
}

int16_t MonoCapWheel::getOrientation() {
  // uint8_t e1Val = e1->measureNormalized();
  // uint8_t e2Val = e2->measureNormalized();
  // uint8_t e3Val = e3->measureNormalized();

  uint8_t e1Val = collectReading(e1, e2, e3);
  uint8_t e2Val = collectReading(e2, e3, e1);
  uint8_t e3Val = collectReading(e3, e1, e2);

  if (e1Val < MIN_TOUCH_THRESHOLD 
    && e2Val < MIN_TOUCH_THRESHOLD 
    && e3Val < MIN_TOUCH_THRESHOLD)
  {
    return NOT_TOUCHED;
  }

  // TODO: are all the electrodes of approximately equal values? 
  // return ALL_TOUCHED;

  // if (IS_MAX(e1Val, e2Val, e3Val)) {
  //   // touch is centered on e1
  //   // float neighborProportions = (float) e2Val / e3Val;
  //   // if (neighborProportions )
  //   if (e2Val > e3Val) {
  //     return 120 * (((float) e1Val) / (e1Val + e2Val));
  //   } else {
  //     return 240 + 120 * (((float) e1Val) / (e1Val + e2Val));
  //   }
  // } else if (IS_MAX(e2Val, e1Val, e3Val)) {
  //   // touch is centered on e2
  // } else {
  //   // touch is centered on e3
  // }

  uint16_t v12 = (uint16_t)e1Val + e2Val;
  uint16_t v23 = (uint16_t)e2Val + e3Val;
  uint16_t v13 = (uint16_t)e1Val + e3Val;
  
  int16_t result = 0;
  
  if (IS_MAX(v12, v23, v13)) {
    // e1/e2 interaction
    float proportion = (float)e2Val / v12;
    result = proportion * 120;
  } else if (IS_MAX(v13, v12, v23)) {
    // e1/e3 interaction
    float proportion = (float)e3Val / v13;
    result = 360 - proportion * 120; 
  } else {
    // e2/e3 interaction
    float proportion = (float)e3Val / v23;
    result = 120 + proportion * 120;
  }

  return result;
}