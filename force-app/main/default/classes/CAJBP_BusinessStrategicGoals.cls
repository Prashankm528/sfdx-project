/*
* Class used to bring a set of Business Strategic Goals for a specific criteria.
*/
public inherited sharing class CAJBP_BusinessStrategicGoals {
    @TestVisible
    private static DAO DataService = new DAO();
    public static final Integer DEFAULT_ROWS = 10;

    /*
    * Returns a list of goals defined by the business.
    * @param year - the year to filter business goals for
    * @param clt - the central leadership team to filter business goals for
    * @param rows - the max goals to return
    */
    @AuraEnabled(Cacheable = true)
    public static List<CAJBP_Business_Strategic_Goal__c> getJbpGoals(string jbpid, string year, string clt, Integer rows) {

        List<CAJBP_Business_Strategic_Goal__c> goals = new List<CAJBP_Business_Strategic_Goal__c>();

        if (String.isNotBlank(jbpId)) {
            Integer rowLimit = (rows == null ? DEFAULT_ROWS : rows);
            goals = DataService.getJbpGoals(jbpid, year, clt, rowLimit + 1);
        }

        return goals;
    }

    /*
    * Returns a list of goals composed around a wrapper object, mainly used in the view all scope.
    */
    @AuraEnabled(Cacheable = true)
    public static List<Goal> getJbpCustomGoals(string jbpid, string year, string clt, Integer rows) {
        List<Goal> goals = new List<Goal>();

        for (CAJBP_Business_Strategic_Goal__c goal :getJbpGoals(jbpid, year, clt, rows)) {
            goals.add(new Goal(goal));
        }

        return goals;
    }


    /*
    * DAO service class for getting data and mocking.
    */
    public virtual with sharing class DAO {
        public virtual List<CAJBP_Business_Strategic_Goal__c> getJbpGoals(string jbpId,String year, String clt,Integer rows) {
            
            CAJBP_Joint_Business_Plan__c jbp = [SELECT id,CAJBP_CLT__c, CAJBP_Year__c,recordtype.NAME FROM CAJBP_Joint_Business_Plan__c WHERE Id=:jbpid LIMIT 1];
            
            return new List<CAJBP_Business_Strategic_Goal__c>([
                SELECT Id, Name, CAJBP_Description__c, CreatedBy.Name
                    FROM CAJBP_Business_Strategic_Goal__c
                    WHERE CAJBP_Year__c = :jbp.CAJBP_Year__c AND CAJBP_CLT__c = :jbp.CAJBP_CLT__c AND
                    CAJBP_Channel__C = : jbp.RecordType.Name
                    ORDER BY CreatedDate ASC
                    LIMIT :rows
            ]);
        }
    }


    public class Goal {
        @AuraEnabled
        public ID id {get; set;}
        @AuraEnabled
        public String title {get; set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public String createdByName {get; set;}
        @AuraEnabled
        public ID createdById {get; set;}


        public Goal(CAJBP_Business_Strategic_Goal__c goal) {
            this.id = goal.Id;
            this.title = goal.Name;
            this.description = goal.CAJBP_Description__c;
            this.createdByName = goal.CreatedBy.Name;
            this.createdById = goal.CreatedById;
        }
    }
}