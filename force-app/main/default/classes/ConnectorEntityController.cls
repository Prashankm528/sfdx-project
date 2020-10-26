/****************************************************************************************************
*  Date          : 02-JAN-2020
*  Author        : SoftPhone IT
*  Description   : ConnectorEntityController
*  Modifications : 
****************************************************************************************************/
global with sharing class ConnectorEntityController {

/****************************************************************************************************
  ConnectorEntityController constructor.
 ****************************************************************************************************/
    public ConnectorEntityController() { } 

/****************************************************************************************************
  ConnectorEntityController parameterized constructor with GCM_CTIController.
 ****************************************************************************************************/    
    public ConnectorEntityController(GCM_CTIController ctiControllerCust){ }

/****************************************************************************************************
  createTask default method.
 ****************************************************************************************************/    
    @RemoteAction
    global static Task createTask(Task task,String field, String value) {
        List<Id> idList = new List<Id>();
        try{        
            List<Contact> contacts = Database.query('Select id,AccountId,Birthdate,Email,FirstName,LastName,Phone from Contact where ' + field + ' = \'' + value + '\'');
            System.debug('contacts found : ' + contacts);
            if ( contacts.size() == 1 ){
                task.WhoId = contacts.get(0).Id;
                idList.add(contacts.get(0).Id);
            } 
            } catch(Exception e){	 BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'ConnectorEntityController', 'createTask', idList, 'GCM_Business_Administrator'); 
        	}

        try{           
            Database.SaveResult sr =  Database.insert(task);
                System.debug('save result : ' + sr);   
            	return task;
            } catch(Exception e){	 BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'ConnectorEntityController', 'createTaskInsert', idList, 'GCM_Business_Administrator'); 
        	}
        return null;
    }

/****************************************************************************************************
  ERCOmniUtilsPath getter setter to load omniutils static resource.
 ****************************************************************************************************/
    @RemoteAction
    global static String ERCOmniUtilsPath {
        get {
           return GetResourceURL('softphoneerc','omniUtils');
        }
    }

/****************************************************************************************************
  GetResourceURL to get omniutil static resource.
 ****************************************************************************************************/
    public static String GetResourceURL(String namespace,String resourceName){

        List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName AND NamespacePrefix = :namespace];
            if(resourceList.size() == 1){
                String nm = resourceList[0].NamespacePrefix;
               return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (nm != null && nm != '' ? nm + '__' : '') + resourceName; 
            }
            return ''; 
        
        }

}