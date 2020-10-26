/****************************************************************************************************
*  Date          : 12-may-2020
*  Author        : Apoorv Jain
*  Description   : GCM_Data_Import_Task controller class.
* Modifications  : 
12-May-2020    : Apoorv - Modifed the class for task and case insert logic with callable interface
****************************************************************************************************/
public class GCM_Data_Import_Task implements Callable {
    
    /****************************************************************************************************
* Insert operation calling GCM_Data_Import_Task_Helper class
****************************************************************************************************/       
    String GCM_Insert(string idImportLogID) {
        try
        {
            return GCM_Data_Import_Task_Helper.importData(idImportLogID);
        }
        catch(exception ex)
        {
            system.debug('Error : GCM_Data_Import.ParseData'+ex.getMessage());
            return null;
        }
    }
    
    /****************************************************************************************************
* callable interface call methoed to perform insert operation
****************************************************************************************************/   
    public Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'GCM_Insert' {
                return this.GCM_Insert((String)args.get('idImportLogID'));
            }
            when else {
                throw new ExtensionMalformedCallException('Method not implemented');
            }
        }
    }
   
    /****************************************************************************************************
* Exception class for interface
****************************************************************************************************/     
    public class ExtensionMalformedCallException extends Exception {}
    
}