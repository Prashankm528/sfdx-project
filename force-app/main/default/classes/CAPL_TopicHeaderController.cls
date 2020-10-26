public with sharing class CAPL_TopicHeaderController {
	
	@AuraEnabled
	public static String fetchArticleName(String topicId) {
		ConnectApi.Topic top;

		if (!Test.isRunningTest()) {
			top = ConnectApi.Topics.getTopic(Network.getNetworkId(), topicId);
		} 

		if (top != null) {
			return top.name;
		} else {
			String emptyResult = '';
			return emptyResult;
		}
	}
}