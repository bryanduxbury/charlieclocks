#include "MonoCapSlider.h"

#define MIN_TOUCH_THRESHOLD 25
#define NOT_TOUCHED -1

MonoCapSlider::MonoCapSlider(MonoCap *left, MonoCap *right, MonoCap *outer) {
  this->left = left;
  this->right = right;
  this->outer = outer;
}

#define IS_MAX(x, y, z) ((x) > (y) && (x) > (z))

#define DEBUG(label, value) Serial.print((label)); Serial.println((value));

// |------|------|------|
// 0      43     85     127
int8_t MonoCapSlider::getPosition() {
  // measure left, right, and outer values
  uint8_t leftVal = left->measureNormalized();
  uint8_t rightVal = right->measureNormalized();
  uint8_t outerVal = outer->measureNormalized();

  if (leftVal < MIN_TOUCH_THRESHOLD 
    && rightVal < MIN_TOUCH_THRESHOLD 
    && outerVal < MIN_TOUCH_THRESHOLD)
  {
    return NOT_TOUCHED;
  }

  // DEBUG("l:", leftVal);
  // DEBUG("r:", rightVal);
  // DEBUG("o:", outerVal);

  // TODO: are all the electrodes of approximately equal values? 
  // return ALL_TOUCHED;

  uint16_t lr = (uint16_t)leftVal + rightVal;
  uint16_t lo = (uint16_t)leftVal + outerVal;
  uint16_t ro = (uint16_t)rightVal + outerVal;

  // DEBUG("lr:", lr);
  // DEBUG("lo:", lo);
  // DEBUG("ro:", ro);

  int8_t result = 0;

  if (IS_MAX(lr, lo, ro)) {
    // left/right interaction
    float proportion = (float)rightVal / lr;
    result = 43 + 42 * proportion;
  } else if (IS_MAX(lo, lr, ro)) {
    // left/outer interaction
    float proportion = (float)leftVal / lo;
    result = 42 * proportion; 
  } else {
    // right/outer interaction
    float proportion = (float)outerVal / ro;
    result = 85 + 42 * proportion;
  }

  return result;
}