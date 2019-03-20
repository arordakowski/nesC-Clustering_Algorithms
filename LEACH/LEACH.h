
#ifndef LEACH_H
#define LEACH_H

enum {
  AM_LEACH = 6,
  TIMER_PERIOD_MILLI = 150
};

typedef nx_struct SENSOR_ID { 
	nx_uint16_t sensorId;
} SENSOR_ID;

	typedef struct intStrMap{
	uint8_t K;
	uint16_t V;
	} intStrMap;

#endif
