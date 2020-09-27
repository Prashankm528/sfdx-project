public with sharing class ErpClass {
    @AuraEnabled
    public static list<Holidays__mdt> getHolidays(){
        return [SELECT id, Date_of_Holiday__c , Holiday__c, MasterLabel FROM Holidays__mdt 
        order by Date_of_Holiday__c];
    }

    @AuraEnabled
    public static list<Time_Card_Details__c> getTimeDetails(id employeeID){
        return [SELECT id, Employee_Detail__r.name , Month__r.name, Project__r.Name,Time__c,Type__c,Description__c
         FROM Time_Card_Details__c where  Employee_Detail__c =:employeeID ];
        
    }

    @AuraEnabled(cacheable = true)
    public static list<Leave_Management__c> getLeaveDetails(id employeeID ){
        system.debug(employeeID);

        return [SELECT id, Employee_Detail__c,Employee_Detail__r.Name, Status__c, Leave_To__c 
        FROM Leave_Management__c  where  Employee_Detail__c =:employeeID];
       
    }

    @AuraEnabled(cacheable = true)
    public static list<Time_Card_Details__c> getManagerDetails(id employeeID ){
        system.debug(employeeID);

        return [SELECT id, Employee_Detail__r.name , Month__r.name, Project__r.Name,Time__c,Type__c,Description__c
         FROM Time_Card_Details__c where  Employee_Detail__r.Employee_Details__c =:employeeID ];
       
    }

    @AuraEnabled(cacheable = true)
    public static list<Employee_Detail__c> getReporteeDetails(id employeeID ){
        system.debug(employeeID);

        return [SELECT id, Name FROM Employee_Detail__c where  Employee_Details__c =:employeeID ];
       
    }
    @AuraEnabled(cacheable = true)
    public static list<Leave_Management__c> getLeaveDetailsEmployee(id employeeID ){
        system.debug(employeeID);

        return [SELECT id, Name , Employee_Detail__c,Employee_Detail__r.Name, Status__c, Leave_To__c 
        FROM Leave_Management__c  where  Employee_Detail__r.Employee_Details__c =:employeeID];
       
    }

    @AuraEnabled
    public static string getEmployeeEmail(id empId){
        system.debug('id is ' + empId);

        return [SELECT id, Name, Email__c FROM Employee_Detail__c where  Employee_Details__c =:empId ].Email__c;
       
    }

    @AuraEnabled
    public static string getMonth(string Month){
        //system.debug('id is ' + empId);

        return [SELECT id, Name FROM Month__c where  Name =:Month ].Name;
       
    }

}
