/*
* Used to render a custom view for relating customer priorities to an objective.
*/
public inherited sharing class CAJBP_ObjectiveCustomerPriorities  {
    @TestVisible
    private static CAJBP_ObjectiveCustomerPriorities.DAOProvider DAOService = new CAJBP_ObjectiveCustomerPriorities.DAOProvider();
    @TestVisible
    private static CAJBP_ObjectiveCustomerPriorities.DMLProvider DMLService = new CAJBP_ObjectiveCustomerPriorities.DMLProvider();

    /*
    * Returns a list of customer priorities options
    */
    @AuraEnabled
    public static List<Option> getPrioritiesOptions(ID jbpId, ID objectiveId) {
        List<Option> currentJbpPriorities = new List<Option>();
        Set<ID> existingObjectivePrioritiesIds = new Set<ID>();

        //Find existing customer priorities for this objective, used to set the selected flag.
        if (String.isNotBlank(objectiveId)) {
            for (CAJBP_Objective_Customer_Priority__c objCustPriority :DAOService.getObjectiveCustomerPriorities(objectiveId)) {
                existingObjectivePrioritiesIds.add(objCustPriority.CAJBP_Customer_Priority__c);
            }
        }

        //Find the current jbp customer priorities for this objective.
        for (CAJBP_Customer_Priority__c priority :DAOService.getCustomerPriotities(jbpId)) {
            currentJbpPriorities.add(new Option(priority, existingObjectivePrioritiesIds.contains(priority.Id)));
        }

        return currentJbpPriorities;
    }

    /*
    * Commits an objective to the DB and associated customer priorities, rolls back if failed.
    */
    @AuraEnabled
    public static void saveObjective(String objectiveJson, List<ID> priorityIdsToInsert) {
        Savepoint sp = Database.setSavepoint();

        try {
            CAJBP_Objective__c objective = (CAJBP_Objective__c)JSON.deserialize(objectiveJson, CAJBP_Objective__c.class);
            DMLService.upsertRecords(new List<CAJBP_Objective__c>{objective});
            insertPriorities(objective.Id, priorityIdsToInsert);
        } catch(System.Exception ex) {
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /*
    * Inserts associated objective customer priorities.
    */
    @AuraEnabled
    public static void savePriorities(ID objectiveId, List<ID> priorityIdsToInsert) {
        Savepoint sp = Database.setSavepoint();

        try {
            insertPriorities(objectiveId, priorityIdsToInsert);
        } catch(System.Exception ex) {
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @TestVisible
    private static void insertPriorities(ID objectiveId, List<ID> priorityIdsToInsert) {
        if (String.isBlank(objectiveId) || priorityIdsToInsert == null) {
            return;
        }

        List<CAJBP_Objective_Customer_Priority__c> currentPrioritiesToDelete = new List<CAJBP_Objective_Customer_Priority__c>();
        Set<ID> currentPrioritiesToInsert = new Set<ID>(priorityIdsToInsert);

        //Get all current objective customer priorities in the db.
        for (CAJBP_Objective_Customer_Priority__c objective :DAOService.getObjectiveCustomerPriorities(objectiveId)) {
            //Has this customer priority already been added to this objective.
            if (currentPrioritiesToInsert.contains(objective.CAJBP_Customer_Priority__c)) {
                currentPrioritiesToInsert.remove(objective.CAJBP_Customer_Priority__c);
            } else {
                //If customer priority is in the system but not currently selected, then delete it.
                currentPrioritiesToDelete.add(objective);
            }
        }

        if (!currentPrioritiesToDelete.isEmpty()) {
            DMLService.deleteRecords(currentPrioritiesToDelete);
        }

        //Queue up priorities to be inserted.
        if (!currentPrioritiesToInsert.isEmpty()) {
            List<CAJBP_Objective_Customer_Priority__c> objectivePrioritiesToInsert = new List<CAJBP_Objective_Customer_Priority__c>();

            for (ID priorityId :currentPrioritiesToInsert) {
                objectivePrioritiesToInsert.add(new CAJBP_Objective_Customer_Priority__c(
                    CAJBP_Objective__c = objectiveId,
                    CAJBP_Customer_Priority__c = priorityId
                ));
            }

            DMLService.insertRecords(objectivePrioritiesToInsert);
        }
    }

    /*
    * Custom dml service that encapsulates committing to the DB, ability to mock DB transactions.
    */
    public virtual class DMLProvider {
        public virtual void insertRecords(List<SObject> records) {
            insert records;
        }

        public virtual void upsertRecords(List<SObject> records) {
            upsert records;
        }

        public virtual void deleteRecords(List<SObject> records) {
            delete records;
        }
    }

    public with sharing virtual class DAOProvider {
        /*
        * Returns a list of customer priorities associated with a specific jbp.
        */
        public virtual List<CAJBP_Customer_Priority__c> getCustomerPriotities(ID jbpId) {
            List<CAJBP_Customer_Priority__c> priorities = new List<CAJBP_Customer_Priority__c>();

            if (String.isNotBlank(jbpId)) {
                priorities = new List<CAJBP_Customer_Priority__c>([
                    SELECT Id, Name, CAJBP_Description__c
                        FROM CAJBP_Customer_Priority__c
                        WHERE CAJBP_Joint_Business_Plan__c = :jbpId
                        ORDER BY Name ASC
                ]);
            }

            return priorities;
        }

        /*
        * Returns a list of existing objective customer priorities.
        */
        public virtual List<CAJBP_Objective_Customer_Priority__c> getObjectiveCustomerPriorities(ID objectiveId) {
            List<CAJBP_Objective_Customer_Priority__c> objectivePriorities = new List<CAJBP_Objective_Customer_Priority__c>();

            if (String.isNotBlank(objectiveId)) {
                objectivePriorities = new List<CAJBP_Objective_Customer_Priority__c>([
                    SELECT CAJBP_Customer_Priority__c, CAJBP_Customer_Priority__r.Name                            
                        FROM CAJBP_Objective_Customer_Priority__c
                        WHERE CAJBP_Objective__c = :objectiveId
                        ORDER BY Name ASC
                ]);
            }

            return objectivePriorities;
        }
    }

    /*
    * Class that stores current selected customer priorities
    */
    public class Option {
        @AuraEnabled
        public ID id {get; set;}
        @AuraEnabled
        public String title {get; set;}
        @AuraEnabled
        public String description {get; set;}        
        @AuraEnabled
        public Boolean selected {get; set;}

        public Option(CAJBP_Customer_Priority__c priority, Boolean selected) {
            this.id = priority.Id;
            this.title = priority.Name;
            this.description = priority.CAJBP_Description__c;            
            this.selected = selected;
        }
    }
}