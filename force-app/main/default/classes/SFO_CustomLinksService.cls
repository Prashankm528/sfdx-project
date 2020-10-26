/*
* Service class that returns active custom links and current user info used in filtering links.
*/
public without sharing virtual class SFO_CustomLinksService {
    
    /*
* returns a set of custom active links.
* @param config the unique identifier that links records for a particular component.
* @param names return only specific links, uses developer name.
*/
    public virtual List<SFO_Custom_Link__mdt> getCustomLinks(String config, Set<String> names) {
        List<SFO_Custom_Link__mdt> links = new List<SFO_Custom_Link__mdt>();
        
        if (String.isNotBlank(config)) {
            String query = 'SELECT SFO_Config__c, SFO_Title__c, SFO_URL__c, SFO_Target__c, '
                +   'SFO_Sales_Organisation__c, SFO_Active__c, SFO_Order__c, SFO_Business_Unit__c '
                + 'FROM SFO_Custom_Link__mdt '
                + 'WHERE SFO_Active__c = TRUE '
                + (names != null && !names.isEmpty() ? 'AND DeveloperName IN '
                   + generateInQuery((Iterable<String>)(names)) : '')
                + 'AND SFO_Config__c = \'' + String.escapeSingleQuotes(config) + '\' '
                + 'ORDER BY SFO_Order__c ASC';
            
            links = (List<SFO_Custom_Link__mdt>)retrieve(query);
        }
        
        return links;
    }
    
    /*
* filters any links for the current sales organisation and business unit.
* @param salesOrg the sales organisation to compare links to.
* @param businessUnit the business unit to compare links to.
* @param records the current link records to filter on.
*/
    public virtual List<SFO_Custom_Link__mdt> filter(String salesOrg, String businessUnit, List<SFO_Custom_Link__mdt> records) {
        List<SFO_Custom_Link__mdt> links = new List<SFO_Custom_Link__mdt>();
        
        for (SFO_Custom_Link__mdt link :records) {
            //Links configured for both sales organisation and business unit
            if (String.isNotBlank(link.SFO_Sales_Organisation__c) && String.isNotBlank(link.SFO_Business_Unit__c)) {
                if (String.isNotBlank(salesOrg)
                    && link.SFO_Sales_Organisation__c.containsIgnoreCase(salesOrg) 
                    && String.isNotBlank(businessUnit)
                    && validateBusinessUnit(businessUnit, link.SFO_Business_Unit__c)) {                        
                        links.add(link);
                    }
            //Links configured for only sales organisation 
            }else if (String.isNotBlank(link.SFO_Sales_Organisation__c) && String.isBlank(link.SFO_Business_Unit__c)) {
                
                if (String.isNotBlank(salesOrg)
                    && link.SFO_Sales_Organisation__c.containsIgnoreCase(salesOrg) 
                   ) {
                       
                       links.add(link);
                   }
            //Links configured for only business unit
            }else if (String.isBlank(link.SFO_Sales_Organisation__c) && String.isNotBlank(link.SFO_Business_Unit__c)) {
                
                if (String.isNotBlank(businessUnit)
                    && validateBusinessUnit(businessUnit, link.SFO_Business_Unit__c)) {
                        
                        links.add(link);
                    }
            //Links with no sales organisation or business unit
            }else {
                links.add(link);
            }
            
        }
        
       return links;
}

/*
* returns current user info used for filtering links.
*/
public virtual User getUserInfo(Id userId) {
    String query = 'SELECT Sales_Organisation__c, ProfileId, Profile.Name, Business_Unit__c, ' +
        +   'UserRoleId, UserRole.Name ' +
        + 'FROM User '
        + 'WHERE Id = \'' + String.escapeSingleQuotes(userId) + '\'';
    
    return ((List<User>)retrieve(query)).get(0);
}

/*
* custom method to query db, can be mocked to return dummy data for tests.
*/
@TestVisible
private virtual Object retrieve(String query) {
    return Database.query(query);
}

@TestVisible
private String generateInQuery(Iterable<Object> data) {
    return '(' + '\'' + String.join(data, '\', \'') + '\')';
}
    /*
* Used to validate if all user business units are configured in the custom metadata
*/
    public boolean validateBusinessUnit(String userBusinessUnit, String configBusinessUnit){
        for (String businessUnit: userBusinessUnit.split(';')){
            if(!configBusinessUnit.containsIgnoreCase(businessUnit)) return false;
        }
        return true;
    }
}