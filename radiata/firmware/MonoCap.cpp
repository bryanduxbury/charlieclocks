#include "MonoCap.h"

MonoCap::MonoCap(uint8_t pin, uint8_t num_samples) {
  this->pin = pin;
  this->port = portOutputRegister(digitalPinToPort(pin));
  this->portmask = digitalPinToBitMask(pin);
  this->adc_pin = pin - 14;
  this->num_samples = num_samples;
  min = 0;
  max = 0;
}

void MonoCap::init() {
  pinMode(pin, INPUT);
  ADMUX  |= (1<<REFS0); //reference AVCC (5v)

  ADCSRA |= (1<<ADPS2)|(1<<ADPS1); //clockiv 64
  //final clock 8MHz/64 = 125kHz

  ADCSRA |= (1<<ADEN); //enable ADC
}

void MonoCap::calibrate() {
  calibration_value = 0;
  uint16_t cv = num_samples * 1024;

  for (int i = 0; i < 10; i++) {
    uint16_t measurement = measure();
    if (measurement < cv) {
      cv = measurement;
    }
  }
  // cv = 0;
  Serial.print("new calibration value: ");
  Serial.println(cv);
  this->calibration_value = cv;
}

int16_t MonoCap::measure() {
  int16_t sum = 0;
  for (int i = 0; i < num_samples; i++) {
    uint16_t thisMeasurement = measureInternal();
    // Serial.print(thisMeasurement);
    // Serial.print(" ");
    sum += thisMeasurement;
  }
  // Serial.println();
  // Serial.print(">");
  // Serial.print("Num samples: ");
  // Serial.print(num_samples);
  // Serial.print(" Value: ");
  // Serial.print(sum);
  // Serial.print(" vs calibration: ");
  // Serial.println(calibration_value);
  return sum - calibration_value;
}

#define MAX(x, y) ((x) > (y) ? (x) : (y))
#define MIN(x, y) ((x) < (y) ? (x) : (y))
#define CLAMP(x, min, max) (MAX(MIN((x), (max)), (min)))

uint8_t MonoCap::measureNormalized() {
  uint16_t measurement = measure();
  return (uint8_t)((CLAMP(measurement, min, max) - min) / ((float) max - min) * 255);
}

void MonoCap::setRange(uint16_t min, uint16_t max) {
  this->min = min;
  this->max = max;
}

inline void MonoCap::enablePullup() {
  *port |= portmask;
}

inline void MonoCap::disablePullup() {
  *port &= ~portmask;
}

static inline uint16_t adc_measure() {
  ADCSRA |= (1<<ADSC); //start conversion
  while(!(ADCSRA & (1<<ADIF))); //wait for conversion to finish
  ADCSRA |= (1<<ADIF); //reset the flag
  return ADC; //return value
}

static inline void groundInternalCap() {
  // mux to ground
  ADMUX &= ~0b1111;
  ADMUX |= 0b1111;
  // do a measurement to discharge the sampling cap
  // Serial.print("Measure inside groundInternalCap: ");
  // Serial.println();
  adc_measure();
}

uint16_t MonoCap::measureInternal() {
  // enable pullup
  enablePullup();
  // wait until the external cap is charged
  delay(1);
  // disable pullup
  disablePullup();

  // ground and discharge the internal cap
  groundInternalCap();

  // connect internal cap to external cap
  ADMUX &= ~(0b1111);
  ADMUX |= adc_pin;
  // uint16_t measurement = adc_measure();
  return adc_measure();
}