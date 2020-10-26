public with sharing class CAPL_ContentVisibilityTriggerHandler {
	
	public static Boolean isExecuting = false;

	public static void changeVisibility(List<ContentDocumentLink> contentLinkList) {
		if (CAPL_ContentVisibilityTriggerHandler.isExecuting) {
			return;
		}
		
	    for (ContentDocumentLink cdl : contentLinkList) {
	        cdl.Visibility = 'AllUsers';
	    }
	    
	} 
}