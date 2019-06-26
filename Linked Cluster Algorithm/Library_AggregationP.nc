
module Library_AggregationP
{
  provides interface Library_Aggregation;
}
implementation
{
  command int Library_Aggregation.MIN(uint16_t neighbors[]){

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

