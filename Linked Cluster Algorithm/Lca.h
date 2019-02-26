
#ifndef LCA_H
#define LCA_H

enum {
  AM_LCA = 6,
  TIMER_PERIOD_MILLI = 150
};

typedef nx_struct SENSOR_ID { 
	nx_uint16_t sensorId;
} SENSOR_ID;

typedef nx_struct CH_ANNOUNCE { 
	nx_uint16_t sensorId;
	nx_uint16_t param;
} CH_ANNOUNCE;

#endif
