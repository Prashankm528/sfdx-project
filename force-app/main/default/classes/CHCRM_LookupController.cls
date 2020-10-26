/***********************************************************************************************
 * @author           Chris
 * @date             2020/03/27
 * @group            CHCRM
 * @description      controller class used by custom lookup lightning component

 * history
 * 2020/03/27  Chris  Created 
 ************************************************************************************************/
public with sharing class CHCRM_LookupController {
    @AuraEnabled(cacheable=true)
    public static List<Object> query(String queryStr, String objName) {
        
        if(objName == 'HQ Monthly Assignment'){
            objName = 'CHCRM_HQ_Monthly_Assgmnt__c';
        }
        String query = 'SELECT Id, ';   
        query += 'Name ';
        query += 'FROM ' + objName ;
        query += ' WHERE Id != NULL ';
        if(String.isNotBlank(queryStr)){
            query += ' AND Name LIKE \'%';
            query += queryStr + '%\'';
        }
        query += ' LIMIT 8';
        system.debug('=====>'+query);
        return Database.query(query);
    }
}