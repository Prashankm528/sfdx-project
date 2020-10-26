/*
* Used to render a custom view for relating swots to an objective.
*/
public inherited sharing class CAJBP_ObjectiveSwots {
    @TestVisible
    private static CAJBP_ObjectiveSwots.DAOProvider DAOService = new CAJBP_ObjectiveSwots.DAOProvider();
    @TestVisible
    private static CAJBP_ObjectiveSwots.DMLProvider DMLService = new CAJBP_ObjectiveSwots.DMLProvider();

    /*
    * Returns a list of swot options containing basic details of a swot including icon name and if selected.
    */
    @AuraEnabled
    public static List<Option> getSwotOptions(ID jbpId, ID objectiveId) {
        List<Option> currentJbpSwots = new List<Option>();
        Set<ID> existingObjectiveSwotIds = new Set<ID>();

        //Find existing swots for this objective, used to set the selected flag.
        if (String.isNotBlank(objectiveId)) {
            for (CAJBP_Objective_SWOT__c swot :DAOService.getObjectiveSwots(objectiveId)) {
                existingObjectiveSwotIds.add(swot.CAJBP_SWOT__c);
            }
        }

        //Find the current jbp swots for this objective.
        for (CAJBP_SWOT__c swot :DAOService.getJbpSwots(jbpId)) {
            currentJbpSwots.add(new Option(swot, existingObjectiveSwotIds.contains(swot.Id)));
        }

        return currentJbpSwots;
    }

    /*
    * Commits an objective to the DB and associated swots, rolls back if failed.
    */
    @AuraEnabled
    public static void saveObjective(String objectiveJson, List<ID> swotIdsToInsert) {
        Savepoint sp = Database.setSavepoint();

        try {
            CAJBP_Objective__c objective = (CAJBP_Objective__c)JSON.deserialize(objectiveJson, CAJBP_Objective__c.class);
            DMLService.upsertRecords(new List<CAJBP_Objective__c>{objective});
            insertSwots(objective.Id, swotIdsToInsert);
        } catch(System.Exception ex) {
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /*
    * Inserts associated objective swots.
    */
    @AuraEnabled
    public static void saveSwots(ID objectiveId, List<ID> swotIdsToInsert) {
        Savepoint sp = Database.setSavepoint();

        try {
            insertSwots(objectiveId, swotIdsToInsert);
        } catch(System.Exception ex) {
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @TestVisible
    private static void insertSwots(ID objectiveId, List<ID> swotIdsToInsert) {
        if (String.isBlank(objectiveId) || swotIdsToInsert == null) {
            return;
        }

        List<CAJBP_Objective_SWOT__c> currentSwotsToDelete = new List<CAJBP_Objective_SWOT__c>();
        Set<ID> currentSwotsToInsert = new Set<ID>(swotIdsToInsert);

        //Get all current objective swots in the db.
        for (CAJBP_Objective_SWOT__c objective :DAOService.getObjectiveSwots(objectiveId)) {
            //Has this swot already been added to this objective.
            if (currentSwotsToInsert.contains(objective.CAJBP_SWOT__c)) {
                currentSwotsToInsert.remove(objective.CAJBP_SWOT__c);
            } else {
                //If swot is in the system but not currently selected, then delete it.
                currentSwotsToDelete.add(objective);
            }
        }

        if (!currentSwotsToDelete.isEmpty()) {
            DMLService.deleteRecords(currentSwotsToDelete);
        }

        //Queue up swots to be inserted.
        if (!currentSwotsToInsert.isEmpty()) {
            List<CAJBP_Objective_SWOT__c> objectiveSwotsToInsert = new List<CAJBP_Objective_SWOT__c>();

            for (ID swotId :currentSwotsToInsert) {
                objectiveSwotsToInsert.add(new CAJBP_Objective_SWOT__c(
                    CAJBP_Objective__c = objectiveId,
                    CAJBP_SWOT__c = swotId
                ));
            }

            DMLService.insertRecords(objectiveSwotsToInsert);
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
        * Returns a list of swots associated with a specific jbp.
        */
        public virtual List<CAJBP_SWOT__c> getJbpSwots(ID jbpId) {
            List<CAJBP_SWOT__c> swots = new List<CAJBP_SWOT__c>();

            if (String.isNotBlank(jbpId)) {
                swots = new List<CAJBP_SWOT__c>([
                    SELECT Id, Name, Type__c
                        FROM CAJBP_SWOT__c
                        WHERE CAJBP_Joint_Business_Plan__c = :jbpId
                        ORDER BY Type__c ASC
                ]);
            }

            return swots;
        }

        /*
        * Returns a list of existing objective swots.
        */
        public virtual List<CAJBP_Objective_SWOT__c> getObjectiveSwots(ID objectiveId) {
            List<CAJBP_Objective_SWOT__c> swots = new List<CAJBP_Objective_SWOT__c>();

            if (String.isNotBlank(objectiveId)) {
                swots = new List<CAJBP_Objective_SWOT__c>([
                    SELECT CAJBP_SWOT__c, CAJBP_SWOT__r.Name,
                            CAJBP_SWOT__r.Type__c
                        FROM CAJBP_Objective_SWOT__c
                        WHERE CAJBP_Objective__c = :objectiveId
                        ORDER BY Name ASC
                ]);
            }

            return swots;
        }
    }

    /*
    * Class that stores current selected swot, icon name used in custom ui for objective swots.
    */
    public class Option {
        @AuraEnabled
        public ID id {get; set;}
        @AuraEnabled
        public String title {get; set;}
        @AuraEnabled
        public String type {get; set;}
        @AuraEnabled
        public String iconName {get; set;}
        @AuraEnabled
        public Boolean selected {get; set;}

        public Option(CAJBP_SWOT__c swot, Boolean selected) {
            this.id = swot.Id;
            this.title = swot.Name;
            this.type = swot.Type__c;

            //Map icon to specific swot type.
            switch on this.type {
                when 'Strength' {
                    this.iconName = 'custom:custom5';
                }
                when 'Opportunity' {
                    this.iconName = 'custom:custom57';
                }
                when 'Weakness' {
                    this.iconName = 'custom:custom91';
                }
                when 'Threat' {
                    this.iconName = 'custom:custom53';
                }
            }

            this.selected = selected;
        }
    }
}