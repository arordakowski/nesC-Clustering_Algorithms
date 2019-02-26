
#include "Timer.h"

module LcaC @safe(){
	
	uses{

	//GENERAL
  interface Boot;
  interface SplitControl as AMControl;

	//NETWORKING	
	interface Packet;
  interface AMPacket;
  interface AMSend;
  interface Receive;

	//TIMMER
	interface Timer<TMilli> as Timer0;

	//LIBRARY
	interface library;

	}
}
implementation {
	
	uint16_t CH;
	message_t pkt;
	uint16_t nextState; 			
	uint16_t neighbors[7];	
	uint16_t aux;						

//----------------- implementation of methods  ------------------

	void discoveredNeighbors(uint16_t id){ 	
		for(aux = 0x01; aux<0x07; aux++){		
			if(neighbors[aux] == 0){					
				neighbors[aux] = id;							
				aux = 0x07;											
			}
		}
	}

	void sendMsg(uint16_t tipoMsg){ 	
		if(tipoMsg == 1){
			SENSOR_ID* btrpkt = (SENSOR_ID*)(call Packet.getPayload(&pkt, sizeof(SENSOR_ID)));
   		btrpkt->sensorId = TOS_NODE_ID;
     	call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(SENSOR_ID));
		}
		else if(tipoMsg == 2){
			CH_ANNOUNCE* btrpkt = (CH_ANNOUNCE*)(call Packet.getPayload(&pkt, sizeof(CH_ANNOUNCE)));
   		btrpkt->sensorId = TOS_NODE_ID;
     	call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CH_ANNOUNCE));
		}	
	}
	
//----------------- implementation of events ------------------

	void state_Select_CH(){
		if((call library.MIN(neighbors))==TOS_NODE_ID){
			sendMsg(2);
			CH = TOS_NODE_ID;
			nextState = 3;
			dbg("Boot", "\t==== I'm Cluster Head ====\n");
		}else{
			CH = TOS_NODE_ID;
		}
		nextState = 3;
		call Timer0.startOneShot(TIMER_PERIOD_MILLI);		
	}

	void state_Form_Neighbor_List(){
		call Timer0.startOneShot(TIMER_PERIOD_MILLI) ;
	}

	void state_INI(){
	call AMControl.start(); 	
	}

	event void Boot.booted() {
		state_INI();
  }

	
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
			if(TOS_NODE_ID == 1){ 
				nextState = 2; //SELECT_CH
				sendMsg(1);
			}else{
				nextState = 1;//DISCOVERY			
			}
		}else{
			call AMControl.start();
    }
  }

	event void AMControl.stopDone(error_t err) {
		
  }

	event void Timer0.fired(){

	 if(nextState == 2){		
		state_Select_CH();
	}
	else if (nextState == 3){ // FINISH
		dbg("Boot", " ===> CH: %i \n",CH);
	}


	}
		
  event void AMSend.sendDone(message_t* msg, error_t err) {
  }

	//event to receive messages
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
		
		if (len == sizeof(SENSOR_ID)) {
      SENSOR_ID* btrpkt = (SENSOR_ID*)payload;
			discoveredNeighbors(btrpkt->sensorId);
			if (nextState == 1){
				sendMsg(1);	
				nextState = 2;
			}
    }
		else if (len == sizeof(CH_ANNOUNCE)) {
      CH_ANNOUNCE* btrpkt = (CH_ANNOUNCE*)payload;
			
			if(TOS_NODE_ID > btrpkt->sensorId){
				CH = btrpkt->sensorId;
				nextState = 3;		
			}
		}
		call Timer0.startOneShot(TIMER_PERIOD_MILLI);  
    return msg;
  }
}
