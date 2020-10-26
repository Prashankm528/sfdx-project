/**
 * @author			Venkatesh Muniyasamy
 * @date			14/01/2020
 * @group			CAJBP
 * @description		Renders Custom Calendar.
 *
 * history
 * 14/01/2020	Venkatesh Muniyasamy	    Custom Calendar
 * 15/07/2020   Abhinit Kohar               Updated for Global Calendar
 * 07/08/2020   Abhinit Kohar               Updated for new calendar filters
 */
public with sharing class CAJBP_CalendarController
{
    public static List<Activities> activity = new List<Activities>();
    public static string eventStatus;

    @AuraEnabled
    public static Map<String, Object> getData(Id jbpId, Boolean allJBPs) {
        Map<String, Object> response = new Map<String, Object>();

        setJbpActivities(jbpId, allJBPs);
        response.put('activities', activity);

        response.put(
                'api_key',
                [SELECT CAJBP_Value__c
                FROM CAJBP_Config__mdt
                WHERE Label = 'FULL_CALENDAR_API_KEY' LIMIT 1
                ].CAJBP_Value__c
        );

        return response;
    }

    @AuraEnabled
    public static List <CAJBP_Joint_Business_Plan__c> getFilterData() {
        return [select id, name, OwnerId, CAJBP_Owner_Name__c, CAJBP_Country__c from CAJBP_Joint_Business_Plan__c];
    }

    public static void setJbpActivities(Id jbpId, Boolean allJBPs) {
        String soqlQuery = '';
        if(allJBPs){
            soqlQuery = 'SELECT Id, Name, CAJBP_Start_Date__c, CAJBP_End_Date__c, CAJBP_Description__c, CAJBP_Status__c, CAJBP_Activity_Type__c, CAJBP_Paid_for_by__c, CAJBP_Objective__c, CAJBP_Objective__r.Name, CAJBP_Activity_Ownership__c, CAJBP_Joint_Business_Plan__c, CAJBP_Joint_Business_Plan__r.CAJBP_Country__c, CAJBP_Joint_Business_Plan__r.OwnerId, CAJBP_Joint_Business_Plan__r.CAJBP_Owner_Name__c, (SELECT id, Subject,StartDateTime,EndDateTime, Description,Type FROM Events WHERE StartDateTime != null), (SELECT id, subject, status,type,Description, ActivityDate FROM Tasks WHERE ActivityDate != null) FROM CAJBP_JBP_Activity__c WHERE CAJBP_Start_Date__c != NULL';
        } else {
            soqlQuery = 'SELECT Id, Name, CAJBP_Start_Date__c, CAJBP_End_Date__c, CAJBP_Description__c, CAJBP_Status__c, CAJBP_Activity_Type__c, CAJBP_Paid_for_by__c, CAJBP_Objective__c, CAJBP_Objective__r.Name, CAJBP_Activity_Ownership__c, CAJBP_Joint_Business_Plan__c, CAJBP_Joint_Business_Plan__r.CAJBP_Country__c, CAJBP_Joint_Business_Plan__r.OwnerId, CAJBP_Joint_Business_Plan__r.CAJBP_Owner_Name__c, (SELECT id, Subject,StartDateTime,EndDateTime, Description,Type FROM Events WHERE StartDateTime != null), (SELECT id, subject, status,type,Description, ActivityDate FROM Tasks WHERE ActivityDate != null) FROM CAJBP_JBP_Activity__c WHERE CAJBP_Start_Date__c != NULL AND CAJBP_Joint_Business_Plan__c = :jbpId';
        }

        for(CAJBP_JBP_Activity__c jbpActivity : Database.query(soqlQuery))
        {
            activity.add(new Activities(jbpActivity));
            for(Event event : jbpActivity.Events)
            {
                eventStatus = getEventStatus(event);
                activity.add(new Activities(event, jbpActivity, eventStatus));
            }
            for(Task task : jbpActivity.Tasks)
            {
                activity.add(new Activities(task, jbpActivity));
            }
        }
    }

    public static string getEventStatus(Event event)
    {
        String status;
        if(DateTime.now() < event.startDateTime)
        {
            status = 'Not Started';
        }
        else if(DateTime.now() > event.endDateTime)
        {
            status = 'Completed';
        }
        else
        {
            status = 'In Progress';
        }
        return status;
    }

    public class Activities
    {
        @AuraEnabled
        public Id id {get;set;}
        @AuraEnabled
        public DateTime startDateTime 
        {
            get
            {
                return startDateTime;
            }
            set
            {
                if(value!=null && this.objectType == 'Event')
                {
                    Integer offset = UserInfo.getTimezone().getOffset(value);
                    startDateTime = value.addSeconds(offset/1000);
                }
                else
                {
                    startDateTime = value;
                }
            }
        }
        @AuraEnabled
        public DateTime endDateTime
        {
            get{return endDateTime;}
            set
                {
                    if(value !=null && this.objectType !='Event')
                    {
                        endDateTime = value.addDays(1);
                    }
                    else if (this.objectType == 'Event')
                    {
                        Integer offset = UserInfo.getTimezone().getOffset(value);
                        endDateTime = value.addSeconds(offset/1000);
                    }
                    else
                    {
                        endDateTime = value;
                    }
                }
        }
        @AuraEnabled
        public Boolean allDay {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Map<String, Object> extendedProps {get;set;}
        @AuraEnabled
        public String colour {get; set;}
        public DateTime addHours {get;set;}
        public string objectType{get;set;}

        public Activities(CAJBP_JBP_Activity__c activity) {
            this.id = activity.Id;
            this.objectType = string.valueOf(activity.getSObjectType());
            this.startDateTime = activity.CAJBP_Start_Date__c;
            this.endDateTime = activity.CAJBP_End_Date__c;
            this.name = activity.Name;
            this.allDay = true;
            this.colour =  '#d15b97';

            extendedProps = new Map<String, Object>{
                'description' => activity.CAJBP_Description__c,
                'status' => activity.CAJBP_Status__c,
                'objectiveName' => activity.CAJBP_Objective__r.Name,
                'objectiveId' => activity.CAJBP_Objective__c,
                'type' => activity.CAJBP_Activity_Type__c,
                'paidBy' => activity.CAJBP_Paid_for_by__c,
                'ownership' => activity.CAJBP_Activity_Ownership__c,
                'objectType' => 'Activity',
                'jbpId' => activity.CAJBP_Joint_Business_Plan__c,
                'ownerName' => activity.CAJBP_Joint_Business_Plan__r.CAJBP_Owner_Name__c,
                'country' => activity.CAJBP_Joint_Business_Plan__r.CAJBP_Country__c
            };
        }

        public Activities(Event event, CAJBP_JBP_Activity__c activity, String eventStatus) {
            this.id = event.Id;
            this.objectType = string.valueOf(event.getSObjectType());
            this.startDateTime = event.StartDateTime;
            this.endDateTime = event.EndDateTime;
            this.name = event.Subject == null? '': +event.Subject ;
            this.colour = '#5882FA';

            extendedProps = new Map<String, Object>{
                'description' => event.Description,
                'status' => eventStatus,
                'objectiveName' => activity.CAJBP_Objective__r.Name,
                'objectiveId' => activity.CAJBP_Objective__c,
                'type' => event.Type,
                'objectType' => 'Event',
                'jbpId' => activity.CAJBP_Joint_Business_Plan__c,
                'jbpIdObjectType' => activity.CAJBP_Joint_Business_Plan__c + 'Event',
                'ownerName' => activity.CAJBP_Joint_Business_Plan__r.CAJBP_Owner_Name__c,
                'country' => activity.CAJBP_Joint_Business_Plan__r.CAJBP_Country__c,
                'countryObjectType' => activity.CAJBP_Joint_Business_Plan__r.CAJBP_Country__c + 'Event',
                'ownerObjectType' => activity.CAJBP_Joint_Business_Plan__r.CAJBP_Owner_Name__c + 'Event'
            };
        }
        public Activities(Task task, CAJBP_JBP_Activity__c activity) {
            this.id = task.Id;
            this.objectType = string.valueOf(task.getSObjectType());
            this.startDateTime = task.ActivityDate;
            this.endDateTime = task.ActivityDate;
            this.name = task.Subject == null? '': + task.Subject ;
            this.allDay = true;
            this.colour =  '#127753';

            extendedProps = new Map<String, Object>{
                'description' => task.Description,
                'status' => task.Status,
                'objectiveName' => activity.CAJBP_Objective__r.Name,
                'objectiveId' => activity.CAJBP_Objective__c,
                'type' => task.type,
                'objectType' => 'Task',
                'jbpId' => activity.CAJBP_Joint_Business_Plan__c,
                'jbpIdObjectType' => activity.CAJBP_Joint_Business_Plan__c + 'Task',
                'ownerName' => activity.CAJBP_Joint_Business_Plan__r.CAJBP_Owner_Name__c,
                'country' => activity.CAJBP_Joint_Business_Plan__r.CAJBP_Country__c,
                'countryObjectType' => activity.CAJBP_Joint_Business_Plan__r.CAJBP_Country__c + 'Task',
                'ownerObjectType' => activity.CAJBP_Joint_Business_Plan__r.CAJBP_Owner_Name__c + 'Task'
            };
        }
    }
}