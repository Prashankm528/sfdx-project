public with sharing class LCP_ColorCodingFieldsBatchSchedulable implements Schedulable{
	public void execute(SchedulableContext sc){
         LCP_ColorCodingFieldsBatch  batch = new  LCP_ColorCodingFieldsBatch(); 
         database.executebatch(batch);
    }
}