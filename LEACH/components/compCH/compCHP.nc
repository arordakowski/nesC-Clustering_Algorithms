
module compCHP
{
  provides interface compCH;
}
implementation
{

	typedef struct intStrMap{
	uint8_t K;
	uint16_t V;
	} intStrMap;

  command int compCH.selectCH(intStrMap* neighbors[]){

		uint16_t aux;
		uint16_t i;		
		aux = TOS_NODE_ID; 

		for(i = 0x01; i <= 7; i++){			
			if(neighbors[i] < aux && neighbors[i] > 0){
				aux = neighbors[i];
			}
		}
		return aux;	
	}
}

