
#include "LEACH.h"

configuration LEACHAppC {
}
implementation {
	//GENERAL
  components MainC;
	components LEACHC as App;
	App -> MainC.Boot;
  
	//TIMMER
	components new TimerMilliC() as Timer0;
  App.Timer0 -> Timer0;
	
	//NETWORKING	
	components ActiveMessageC;
  components new AMSenderC(AM_LEACH);
  components new AMReceiverC(AM_LEACH);
  App.AMControl -> ActiveMessageC;
	App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;

}

