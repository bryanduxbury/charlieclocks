#include "MonoCap.h"

#define MAX(x, y) ((x) > (y) ? (x) : (y))
#define MIN(x, y) ((x) < (y) ? (x) : (y))
#define CLAMP(x, min, max) (MAX(MIN((x), (max)), (min)))

MonoCap::MonoCap(uint8_t pin, uint8_t num_samples) {
  this->pin = pin;
  this->port = portOutputRegister(digitalPinToPort(pin));
  this->portmask = digitalPinToBitMask(pin);
  this->adc_pin = pin - 14;
  this->num_samples = num_samples;
  max = 1;
}

void MonoCap::init() {
  pinMode(pin, INPUT);

  // TODO: move the rest of this stuff into a global init?

  //reference AVCC (5v)
  ADMUX  |= (1<<REFS0);

  // we're aiming for a adc clock speed between 50kHz and 200kHz.
  // our main clock is 16MHz, so we'll use a prescaler of 128 to set the final
  // adc clock to 125kHz.
  ADCSRA |= (1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0);

  //enable ADC
  ADCSRA |= (1<<ADEN);
}

void MonoCap::calibrate() {
  // take 30 samples from the sensor
  uint16_t samples[30] = {0};
  uint32_t sum = 0;
  for (int i = 0; i < 30; i++) {
    samples[i] = measure();
    sum += samples[i];
  }

  // compute the mean. this is the average untouched value the sensor will return.
  uint16_t mean = sum / 30;

  // compute the sum of the squared differences between samples and mean
  uint16_t squared_sum = 0;
  for (int i = 0; i < 30; i++) {
    int32_t mean_diff = (int32_t)samples[i] - mean;
    squared_sum += mean_diff * mean_diff;
  }

  // we can now compute the standard deviation of the distribution.
  uint16_t stdev = sqrt(squared_sum / 30);
  
  // we set the minimum touched threshold at mean + 3 sigmas. this means that
  // there's only a ~1.5% chance that a value above it is random noise, and 
  // it's probably a touch.
  touch_threshold = mean + stdev * 3;
}

void MonoCap::suppress() {
  enablePullup();
}

uint16_t MonoCap::measure() {
  int16_t sum = 0;
  for (int i = 0; i < num_samples; i++) {
    uint16_t thisMeasurement = measureInternal();
    sum += thisMeasurement;
  }

  return MAX(0, sum - (int16_t)touch_threshold);
}


uint8_t MonoCap::measureNormalized() {
  uint16_t measurement = measure();

  // adjust min and max to account for global min/max 
  // if (measurement < min) min = measurement;
  if (measurement > max) max = measurement;

  // convert the measurement into a value 0 <= x <= 255
  return (uint8_t)((float)measurement / max * 255);
}

void MonoCap::setRange(uint16_t min, uint16_t max) {
  this->max = max;
}

inline void MonoCap::enablePullup() {
  *port |= portmask;
}

inline void MonoCap::disablePullup() {
  *port &= ~portmask;
}

static inline uint16_t adc_measure() {
  // start conversion
  ADCSRA |= (1<<ADSC);
  // wait for conversion to finish
  while(!(ADCSRA & (1<<ADIF)));
  // reset the flag
  ADCSRA |= (1<<ADIF);
  // return value
  return ADC; 
}

static inline void groundInternalCap() {
  // mux to ground
  ADMUX &= ~0b1111;
  ADMUX |= 0b1111;
  // do a measurement to discharge the sampling cap
  adc_measure();
}

uint16_t MonoCap::measureInternal() {
  // charge the external electrode
  // enable pullup
  enablePullup();
  // wait until the external cap is charged
  delayMicroseconds(100);
  // disable pullup
  disablePullup();

  // ground and discharge the internal cap
  groundInternalCap();

  // connect to the external electrode and take a measurement
  // connect internal cap to external cap
  ADMUX &= ~(0b1111);
  ADMUX |= adc_pin;
  return adc_measure();
}