public with sharing class CAPL_CreateSharableLinkTriggerHandler {

	public static Boolean isExecuting = false;

	public static void createSharableLink(Map<Id, ContentVersion> contentMap) {
		if (CAPL_CreateSharableLinkTriggerHandler.isExecuting) {
			return;
		}

		try {

			List<ContentDistribution> cdList = new List<ContentDistribution>();
	    
		    for (Id cvi : contentMap.keySet()) {
		        ContentDistribution test = new ContentDistribution();
		        test.Name = contentMap.get(cvi).Title;
		        test.ContentVersionId = cvi;
		        
		        cdList.add(test);
		    }
		    
		    try {
		    	insert cdList;	
		    } catch (DmlException ex) {
		    	ex.getMessage();
		    }
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
	    
	} 
}