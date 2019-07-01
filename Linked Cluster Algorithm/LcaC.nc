
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

		//SENSOR
		interface Sensor as compSensor;

		//CH_ELECTION
		interface CH_Election as compCH;

		//CLUSTER_FORMATION
		interface Cluster_Formation as compCM;
		
		//LIBMESSAGE
		interface ComponentsLibMessage as compLibMSG;
	}
}
implementation {
	const p=0.2;
	const tCluster=25;
	const tExit=0.1;
	
	double RSS;
	uint16_t myCH;
	uint16_t myID = TOS_NODE_ID;
	
	double knownCHs[15][2];	
		
	message_t pkt;
	uint16_t currentState; 			
	uint16_t aux;						

	
	//----------------- implementation of events ------------------

	event void Boot.booted() {			//boot da aplicação
		call AMControl.start(); 		//inicialização do rádio
	}

	
	event void AMControl.startDone(error_t err) {	//evento após inicialização do rádio
    		if (err == SUCCESS) {
			state_INI();			//chamada do primeiro STATE: INI
		}else{
			call AMControl.start();		//caso ocorra erro, inicializa o rádio novamente
		}
  	}

	event void Timer0.fired(){			//evento executado ao final do timer
		if (currentState == 3){ 		//verificação do STATE atual
			state_Cluster_Formation();	//transição de estado
		} else if(currentState == 6){
			state_Exit();
		}
	}
	
	//event to receive messages
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
	
		if (len == sizeof(CH_ANNOUNCE)) {			//verificando o tipo da mensagem
      			CH_ANNOUNCE* btrpkt = (CH_ANNOUNCE*)payload;	
			if (currentState == 3){			//verificação do STATE atual
				RSS = compSensor->getRSS(btrpkt->sensorId);
				knownCHs[btrpkt->sensorId][0] = btrpkt->sensorId;
				knownCHs[btrpkt->sensorId][1] = RSS;
			}
    		} else if (len == sizeof(ACK_CH_ANNOUNCE)) {		//verificando o tipo da mensagem
			if(currentState == 6){
				ACK_CH_ANNOUNCE* btrpkt = (ACK_CH_ANNOUNCE*)payload;
				if(btrpkt->myCH = TOS_NODE_ID){
					compCH->members.insert(btrpkt->sensorId);
				}
			}
		}
		return msg;
  	}
	
	//----------------- implementation of states ------------------
	
	void state_INI(){			//STATE: INI
		currentState = 1;
		if(TOS_NODE_ID == 1){		
			sendMsg(SENSOR_ID);	//transmitindo mensagem
		}
		state_Select_CH();		//transição de estado			
	}

	void state_Select_CH(){
		currentState = 2;
		if(call CompCH.select_CH(neighbors) == 1){ //se igual a 1 o sensor é CH
			sendMsg(CH_ANNOUNCE);
			compSensor->role = CH;
		} else{
			compSensor->role = CM;
		}
		state_Join_Cluster();
	}
	
	void state_Join_Cluster(){
		currentState = 3;
		call Timer0.startOneShot(TIMER_PERIOD_MILLI); 
	}	

	void state_Cluster_Formation(){
		currentState = 5;
		if(compSensor->role = CM){
			myCH = compCM->joinCluster(knownCHs);
			sendMsg(ACK_CH_ANNOUNCE, myCH);
			state_Exit();
		} else {
			state_Store_Members();
		}
	}

	void state_Store_Members(){
		currentState = 6;
		call Timer0.startOneShot(TIMER_PERIOD_MILLI); 
	}	
	
	void state_Exit(){
		call AmControl.stop();
	}
  
  //----------------- implementation of methods  ------------------

	void knownCHs_insert(uint16_t id, double sinal){ 	
		knownCHs[id][1] = sinal;																				
	}

	void sendMsg(char typeMsg, uint_16 param){ 	
		if (typeMsg == CH_ANNOUNCE){
			CH_ANNOUNCE* btrpkt = (CH_ANNOUNCE*)(call Packet.getPayload(&pkt, sizeof(CH_ANNOUNCE)));
   			btrpkt->sensorId = TOS_NODE_ID;
     			call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CH_ANNOUNCE));
		} else if (typeMsg == ACK_CH_ANNOUNCE){
			ACK_CH_ANNOUNCE* btrpkt = (ACK_CH_ANNOUNCE*)(call Packet.getPayload(&pkt, sizeof(ACK_CH_ANNOUNCE)));
   			btrpkt->myCH = param;
			btrpkt->sensorId = TOS_NODE_ID;
     			call AMSend.send(param, &pkt, sizeof(ACK_CH_ANNOUNCE));
		}
	}
	
	event void AMControl.stopDone(error_t err) {}
	event void AMSend.sendDone(message_t* msg, error_t err) {}
}
