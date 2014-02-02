#ifndef __MONO_CAP_SLIDER_H__
#define __MONO_CAP_SLIDER_H__

#include "MonoCap.h"

class MonoCapSlider {
 public:
  MonoCapSlider(MonoCap *left, MonoCap *right, MonoCap *outer);
  int8_t getPosition();

 private:
  MonoCap *left;
  MonoCap *right;
  MonoCap *outer;
};

#endif