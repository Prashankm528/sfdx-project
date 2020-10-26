public with sharing class LCP_RPColorCodingFieldsBatchSchedulable implements Schedulable{
	public void execute(SchedulableContext sc){
         LCP_RPColorCodingFieldsBatch  batch = new  LCP_RPColorCodingFieldsBatch(); 
         database.executebatch(batch);
    }
}