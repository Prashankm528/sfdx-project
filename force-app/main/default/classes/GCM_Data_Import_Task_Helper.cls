/****************************************************************************************************
*  Date          : 12-may-2020
*  Author        : Apoorv Jain
*  Description   : GCM_Data_Import_Task_Helper controller class.
* Modifications  : 
12-May-2020    : Apoorv - Modifed the class for task and case insert logic with callable interface
****************************************************************************************************/
public class GCM_Data_Import_Task_Helper {
    
    /****************************************************************************************************
* Insert operation to perform the task record operations
****************************************************************************************************/      
    public static string importData(string strImportLogID) {
        system.debug('importData'+strImportLogID);
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
            List<String>  records = data.split('\n(?=(?:[^\\"]*\\"[^\\"]*\\")*[^\\"]*$)');
            List<List<String>> recordSets = new List<List<String>>();
           
            recordSets = GCM_Data_Import.parseData(data);
            
            // At Least 2 Lines In File
            if (recordSets.size() < 2) return null;
            
            String output = '';
            
            // Append Status Column
            output += records[0].replace('\r', '') + ',Status,Record ID\n';
            
            // Get Foreign Keys
            Map<String, Id> ownerMap = new Map<String, Id>();
            for (List<String> recordSet : recordSets) {
                ownerMap.put(recordSet[2], null);
            }
            List<User> users = [select Id, NTID__c from User where NTID__c in :ownerMap.keySet() AND isactive = true];
            for (User thisUser : users) {
                ownerMap.put(thisUser.NTID__c, thisUser.Id);
            }
            
            // Fields: Subject, Description, OwnerId, ActivityDate
            List<Task> tasks = new List<Task>();
            for (Integer count = 1; count < recordSets.size(); count++) {
                Task thisTask = new Task();
                String error = '';
                try {
                    thisTask.Subject = String.valueOf(recordSets[count][0]);
                }
                catch (Exception exception0) {
                    error += exception0.getMessage() + ' ';
                }
                try {
                    thisTask.Description = String.valueOf(recordSets[count][1]);
                }
                catch (Exception exception1) {
                    error += exception1.getMessage() + ' ';
                }
                if (ownerMap.get(recordSets[count][2]) == null) {
                    thisTask.OwnerId = userinfo.getUserId();
                }
                else {
                    thisTask.OwnerId = ownerMap.get(recordSets[count][2]);
                }
                try {
                    thisTask.ActivityDate = Date.valueOf(recordSets[count][3]);
                }
                catch (Exception exception3) {
                    error += exception3.getMessage() + ' ';
                }
                
                // Add Status
                if (error == '') {
                    tasks.add(thisTask);
                }
                else
                {
                    output += records[count].replace('\r', '') + ',' + error + '\n';
                    strFailedCount ++;
                }
            }
            
            string strErrormessage ='';
            integer iFieldValues=1;
            Database.saveResult[] saveResults_Insert = Database.insert(tasks, false);
            for(Database.saveResult saveResult : saveResults_Insert)
            {
                strErrormessage = '';
                system.debug('saveResult'+saveResult);
                if (!saveResult.isSuccess())
                {
                    for(Database.Error err : saveResult.getErrors())
                    {
                        strErrormessage += err.getMessage()+',';
                    }
                    output += records[iFieldValues].replace('\r', '')  +',Failed : '+strErrormessage.remove('') + '\n';
                    strFailedCount ++;
                }
                else
                {
                    strSuccessCount ++;
                    output += records[iFieldValues].replace('\r', '') + ',Success,'+ saveResult.getId() + '\n';
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