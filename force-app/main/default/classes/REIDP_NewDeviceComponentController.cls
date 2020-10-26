/**
 * @author Ragim Ragimov
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 * This Controller is used in NewDeviceComponent Visualforce component in BP Community
 */
public with sharing class REIDP_NewDeviceComponentController {
    public ID userId {get; set;}
    
    public List<List<String>> getDeviceInfo() {
        if(userId != null) {
            Map <String, Object> result = new Map <String, Object>();
            List<List<String>> results = new List<List<String>>();
            User user = [SELECT Id, REIDP_Devices__c FROM User WHERE id = :userId];
            String devicesJson = user.REIDP_Devices__c;
            if (devicesJson == null)
                return null;

            Map<String, DateTime> deviceDateMap = (Map<String, DateTime>) JSON.deserialize(devicesJson, 
                                                                                           Map<String, DateTime>.class);
            Set<String> devices = deviceDateMap.keySet();
            List<DateTime> dates = deviceDateMap.values();
            dates.sort();
            for (String agentPlatform: devices) {
                if (deviceDateMap.get(agentPlatform) == dates[dates.size()-1]) {
                    String[] words = agentPlatform.split('!', 3);

                    List<String> os = new List<String>();
                    List<String> br = new List<String>();
                    os.add('Operating System');
                    os.add(words[0]);
                    os.add('background-color:#f7f7f7');
                    br.add('Browser');
                    br.add(words[2]);
                    br.add('background-color:white');
                    
                    results.add(os);
                    results.add(br);
                    break;
                }
            }
            return results;
        }
        return null;
    }
}