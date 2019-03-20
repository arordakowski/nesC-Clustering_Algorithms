
#include "Timer.h"

module LEACHC @safe(){
	
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
	}
}
implementation {

	message_t pkt;
	uint16_t neighbors[7];
	uint16_t aux;						
	uint8_t currentState;

//----------------- implementation of methods  ------------------
	void discovered(uint16_t id){
		
	}

	void storeMem(uint16_t id){
		
	}

	void sendMsg(){ 	// method of sending messages 
		SENSOR_ID* btrpkt = (SENSOR_ID*)(call Packet.getPayload(&pkt, sizeof(SENSOR_ID)));
  	btrpkt->sensorId = TOS_NODE_ID;				
   	call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(SENSOR_ID));
	}
	

//----------------- implementation of states ------------------
	
	void EXIT(){
		currentState = 5;
		dbg("Boot", "EXIT\n");
	}

	void Store_Members(){
		currentState = 4;
		call Timer0.startOneShot(TIMER_PERIOD_MILLI) ; 	
	}

	void Cluster_Formation(){
		currentState = 3; 
		if(compSensor->role = CM){
			myCH = compCM->joinCluster(knownCHs);
			sensorList.insert(myCH);
			sendMsg(ACK_CH_ANNOUNCE);
			EXIT();
		}else{
			Store_Members();
		}
	}

	void Join_Cluster(){
		currentState = 2; 
		call Timer0.startOneShot(TIMER_PERIOD_MILLI) ; 
	}

	void Select_CH(){
		currentState = 1;
		
		if (compCH->selectCH(TOS_NODE_ID, prob)){
			sendMsg();
			compSensor->role = CH;
		}else{
			compSensor->role = CM;
		}
		Join_Cluster();	
	}

	void INI(){

		if(TOS_NODE_ID == 1){
			currentState = 0;
			call Timer0.startOneShot(TIMER_PERIOD_MILLI); 
		}
		else{
			Select_CH();
		}
	}

//----------------- implementation of events ------------------

	event void Boot.booted() {
		call AMControl.start(); 		
		INI(); 
  }

  event void AMControl.startDone(error_t err) {
  	 
		if(err == SUCCESS) {
			dbg("Boot","APPL: started\n");
		}
  }

	event void Timer0.fired(){			
	
		if(currentState == 0){
			sendMsg();
			Select_CH();
		}
		else if(currentState == 2){
			Cluster_Formation();
		}
		else if(currentState == 4){
			EXIT();
		}	
	}

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){

		SENSOR_ID* btrpkt = (SENSOR_ID*)payload;
		
		if(currentState == 2){	
			RSS = compSensor -> getRSS(ID);
			knownCHa.insert(ID, RSS);
		} 
		else if(currentState == 4){
			for(v in destListID){
				if(v == myID){
					compCH->members.insert(fromID);
				}
			}
    }

	return msg;
  }

	event void AMControl.stopDone(error_t err) {
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
  }
}
