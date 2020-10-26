/****************************************************************************************************
*  Date          : 12-may-2020
*  Author        : Apoorv Jain
*  Description   : Data import controller class.
* Modifications  : 
12-May-2020    : Apoorv - Modifed the class for task and case insert logic with callable interface
****************************************************************************************************/
public class GCM_Data_Import_Case_Helper {
    
    /****************************************************************************************************
* Insert operation to perform the case record operations
****************************************************************************************************/       
    public static string importData(string strImportLogID) {
        // Get Log Details
        GCM_File_Import_Log__c log = null;
        Integer strFailedCount = 0,strSuccessCount=0;
        try
        {
            List<GCM_File_Import_Log__c> logs = [select Id, GCM_Input__c, GCM_Output__c from GCM_File_Import_Log__c where Id = :strImportLogID];
            for (GCM_File_Import_Log__c thisLog : logs) {
                log = thisLog;
            }
            if (log == null) return null;
            
            String data = log.GCM_Input__c;
            
            // Parse Comma Delimited, Double Quote Qualified Fields
            List<String> records = data.split('\n(?=(?:[^\\"]*\\"[^\\"]*\\")*[^\\"]*$)');
            List<List<String>> recordSets = new List<List<String>>();
            
            recordSets = GCM_Data_Import.parseData(data);
            
            // At Least 2 Lines In File
            if (recordSets.size() < 2) return null;
            
            String output = '';
            
            // Append Status Column
            output += records[0].replace('\r', '') + ',Status'+ ',Record ID\n';
            
            // Get Foreign Keys
            
            Map<String, Id> mapExcelValue = new Map<String, Id>();
            Map<String, Id> mapValueRecordId = new Map<String, Id>();
            Map<String, Id> mapAccountValueRecordId = new Map<String, Id>();
            set<string> setValues = new set<string>();
            set<string> setAccountValues = new set<string>();
            
            for (List<String> recordSet : recordSets) {
                setAccountValues.add(recordSet[5]);
                setAccountValues.add(recordSet[6]);
                setValues.add(recordSet[7]);
                setValues.add(recordSet[8]);
                setValues.add(recordSet[9]);
                setValues.add(recordSet[10]);
                setValues.add(recordSet[13]);
            }
            setValues.remove('');
            setValues.remove(null);
            Map<String, integer> mapRecordCount = new Map<String, integer>();
            Map<String, integer> mapAccountRecordCount = new Map<String, integer>();
            for(AggregateResult aggr: [select name,Account_ERP_ID__c,count(id) from account where (name in:setAccountValues OR  Account_ERP_ID__c in:setAccountValues)group by name,Account_ERP_ID__c]){                 
                mapAccountRecordCount.put((string)aggr.get('Name'),(integer)aggr.get('expr0'));
                mapAccountRecordCount.put((string)aggr.get('Account_ERP_ID__c'),(integer)aggr.get('expr0'));
            } 
            
            
            
            for(AggregateResult aggr: [select email,firstname,lastname,count(id) from contact where ( email in:setValues OR firstname in:setValues OR lastname in:setValues) group by email,firstname,lastname]){                 
                mapRecordCount.put((string)aggr.get('email'),(integer)aggr.get('expr0'));
                mapRecordCount.put((string)aggr.get('firstname'),(integer)aggr.get('expr0'));
                mapRecordCount.put((string)aggr.get('lastname'),(integer)aggr.get('expr0'));
            }         
            
            List<account> lstAccount = [select Id, Account_ERP_ID__c,name from account where (Account_ERP_ID__c in : setAccountValues OR name in :setAccountValues)];
            for (account thisaccount : lstAccount) {
                
                if(thisaccount.name != null && mapAccountRecordCount.get(thisaccount.name) == 1)
                    mapAccountValueRecordId.put(thisaccount.name, thisaccount.Id);
                if(thisaccount.Account_ERP_ID__c != null && mapAccountRecordCount.get(thisaccount.Account_ERP_ID__c) == 1)
                    mapAccountValueRecordId.put(thisaccount.Account_ERP_ID__c, thisaccount.Id);
                
            }
            
            List<recordtype> lstRecordType = [select Id, name from recordtype where name in :setValues AND sobjecttype='case'];
            for (recordtype thisRecordType : lstRecordType) {
                mapValueRecordId.put(thisRecordType.name, thisRecordType.Id);
            }
            
            List<contact> lstContact = [select Id, email,firstname,lastname from contact where (email in:setValues OR firstname in: setValues OR lastname in:setValues)];
            for (contact thiscontact : lstContact) {
                if(thiscontact.lastname != null && mapRecordCount.get(thiscontact.lastname) == 1 )
                    mapValueRecordId.put(thiscontact.lastname, thiscontact.Id);
                if(thiscontact.firstname != null && mapRecordCount.get(thiscontact.firstname) == 1 )
                    mapValueRecordId.put(thiscontact.firstname, thiscontact.Id);
                if(thiscontact.email != null && mapRecordCount.get(thiscontact.email) == 1 )
                    mapValueRecordId.put(thiscontact.email, thiscontact.Id);
                system.debug('thiscontact'+thiscontact.firstname+'..'+thiscontact.lastname); 
            }
            
            
            List<user> lstUser = [select Id, email,NTID__c,name from user where NTID__c in:setValues AND isactive = true];
            for (user thisUser : lstUser) {
                if(thisUser.NTID__c != null)
                    mapValueRecordId.put(thisUser.NTID__c, thisUser.Id);
            }
            
            List<case> lstcase = new List<case>();
            List<string> lstInsertRecords = new List<string>();
            for (Integer count = 1; count < recordSets.size(); count++) {
                system.debug('recordSets[count]'+recordSets[count]);
                case thiscase = new case();
                String error = '';
                
                try {
                    thiscase.type = String.valueOf(recordSets[count][0]);
                }
                catch (Exception exception0) {
                    error += exception0.getMessage() + ' ';
                }
                
                try {
                    thiscase.Area__c = String.valueOf(recordSets[count][1]);
                }
                catch (Exception exception0) {
                    error += exception0.getMessage() + ' ';
                }
                try {
                    thiscase.Sub_Area__c = String.valueOf(recordSets[count][2]);
                }
                catch (Exception exception0) {
                    error += exception0.getMessage() + ' ';
                }
                try {
                    if(String.valueOf(recordSets[count][3]) =='')
                    {
                        thiscase.Priority = '4-Low';
                    }
                    else
                        thiscase.Priority = String.valueOf(recordSets[count][3]);
                }
                catch (Exception exception0) {
                    error += exception0.getMessage() + ' ';
                }
                try {
                    thiscase.Description = String.valueOf(recordSets[count][4]);
                }
                catch (Exception exception0) {
                    error += exception0.getMessage() + ' ';
                } 
                
                try {
                    
                    if( mapAccountValueRecordId.get(recordSets[count][5]) != null)
                        thiscase.accountid = mapAccountValueRecordId.get(recordSets[count][5]);
                    else if( mapAccountValueRecordId.get(recordSets[count][6]) != null)
                        thiscase.accountid = mapAccountValueRecordId.get(recordSets[count][6]);
                    else if(mapAccountValueRecordId.get(recordSets[count][5]) == null && mapAccountValueRecordId.get(recordSets[count][6]) == null)
                    {
                        error +='Failed : Unique Account record was not found';
                    }
                }
                catch (Exception exception0) {
                    error += exception0.getMessage() + ' ';
                }
                try {
                    if( mapValueRecordId.get(recordSets[count][7]) != null)
                        thiscase.contactid = mapValueRecordId.get(recordSets[count][7]);
                    else if( mapValueRecordId.get(recordSets[count][8]) != null)
                        thiscase.contactid = mapValueRecordId.get(recordSets[count][8]);
                    else if( mapValueRecordId.get(recordSets[count][9]) != null)
                        thiscase.contactid = mapValueRecordId.get(recordSets[count][9]);
                    else if(mapValueRecordId.get(recordSets[count][7]) == null && mapValueRecordId.get(recordSets[count][8]) == null && mapValueRecordId.get(recordSets[count][9]) == null)
                    {
                        error +='Failed : Unique contact record was not found';
                    }
                }
                catch (Exception exception0) {
                    error += exception0.getMessage() + ' ';
                }
                
                try {
                    if( mapValueRecordId.get(recordSets[count][10]) != null)
                        thiscase.ownerid = mapValueRecordId.get(recordSets[count][10]);
                    else 
                    {
                        thiscase.ownerid = userinfo.getUserId();
                        
                    }
                }
                catch (Exception exception0) {
                    error += exception0.getMessage() + ' ';
                }
                try {
                    thiscase.GCM_Incident_Date_Time__c = datetime.valueOf(recordSets[count][11]);
                }
                catch (Exception exception0) {
                    error += exception0.getMessage() + ' ';
                }
                try {
                    thiscase.Complaint__c = boolean.valueOf(recordSets[count][12]);
                }
                catch (Exception exception0) {
                    error += exception0.getMessage() + ' ';
                }
                
                try {
                    thiscase.recordtypeid = mapValueRecordId.get(recordSets[count][13]);
                }
                catch (Exception exception0) {
                    error += exception0.getMessage() + ' ';
                }
                
                if (error == '') {
                    lstcase.add(thiscase);
                    system.debug('saveResultoutput thiscase'+thiscase);
                    lstInsertRecords.add(records[count]);
                }
                else
                {
                    output += records[count].replace('\r', '') + ',' + error + '\n';
                    strFailedCount ++;
                }
            }
            
            integer iFieldValues=0;
            string strErrormessage ='';
            
            Database.saveResult[] saveResults_Insert = Database.insert(lstcase, false);
            for(Database.saveResult saveResult : saveResults_Insert)
            {
                strErrormessage = '';
                if (!saveResult.isSuccess()) 
                {
                    for(Database.Error err : saveResult.getErrors()) 
                    {
                        strErrormessage += err.getMessage()+',';
                        
                    }
                    output += lstInsertRecords[iFieldValues].replace('\r', '') +',Failed : '+strErrormessage.remove(',') + '\n';
                    strFailedCount ++;
                }            
                else
                { 
                    strSuccessCount ++;
                    output += lstInsertRecords[iFieldValues].replace('\r', '') + ',Success,'+ saveResult.getId() + '\n';
                }
                ++ iFieldValues;
            }
            
            log.GCM_Output__c = output;
            if(strSuccessCount > 0 )
                log.GCM_Status__c = string.valueOf(strSuccessCount);
            else 
                log.GCM_Status__c = '0';
            if(strFailedCount > 0 )
                log.GCM_Status__c = log.GCM_Status__c +','+string.valueOf(strFailedCount);
            else 
                log.GCM_Status__c = log.GCM_Status__c + ',0';
            
            update log;
            return 'success';
        }
        catch(exception ex)
        {
            system.debug('Error : GCM_Data_Import.ParseData'+ex.getMessage());
            return null;
        }   
    }
}