#include "Timer.h"

module CH_ElectionC @safe{
	
	provides interface CH_Election;
  
  	uses {
  		interface Library_Aggregation as compLib;
  		interface Packet;
  		interface AMSend;
	}
}

implementation {

	message_t pkt;

	command CH_Election.selectCH(uint16_t neighbors[]){
		
		uint16_t minNeighbors = call compLib.MIN(neighbors);
	
		if(TOS_NODE_ID < minNeighbors){
			role = CH;
			CH_ANNOUNCE* btrpkt = (CH_ANNOUNCE*)(call Packet.getPayload(&pkt, sizeof(CH_ANNOUNCE)));
			btrpkt->sensorId = TOS_NODE_ID;
			call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CH_ANNOUNCE));
			dbg("Boot", "\t==== I'm Cluster Head ====\n");
		} else{
			role = CM;
		}
  	}
}

