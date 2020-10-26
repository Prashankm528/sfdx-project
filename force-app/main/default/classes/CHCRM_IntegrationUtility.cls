/***********************************************************************************************
 * @author           Xc
 * @date             2020/08/11
 * @group            CHCRM
 * @description      Integration Utility Class

 * history
 * 2020/08/11  Xc  Created 
 ************************************************************************************************/
public with sharing class CHCRM_IntegrationUtility {

    public static Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    public static final String AUTHORIZATION_METHOD = 'Authorization';
    public static final String HTTP_POST = 'POST';
    public static final String AUTH_BEARER = 'Bearer ';
    public static final String CONTENT_TYPE = 'Content-Type';
    public static final String CONTENT_TYPE_JSON = 'application/json';

    public static void doCallout(String settingName, String body) {
        CHCRM_Integration_Setting__mdt setting = [SELECT Id,
                                                    CHCRM_Prod_Client_ID__c,
                                                    CHCRM_Prod_Client_Secret__c,
                                                    CHCRM_Test_Client_ID__c,
                                                    CHCRM_Test_Client_Secret__c,
                                                    CHCRM_Prod_End_Point__c,
                                                    CHCRM_Prod_Token_End_Point__c,
                                                    CHCRM_Test_End_Point__c,
                                                    CHCRM_Test_Token_End_Point__c,
                                                    CHCRM_Prod_Resource__c,
                                                    CHCRM_Test_Resource__c,
                                                    CHCRM_Prod_Token_Client_ID__c,
                                                    CHCRM_Prod_Token_Client_Secret__c,
                                                    CHCRM_Test_Token_Client_ID__c,
                                                    CHCRM_Test_Token_Client_Secret__c
                                                    FROM CHCRM_Integration_Setting__mdt
                                                    WHERE DeveloperName = :settingName LIMIT 1];
        //Get Token
        Http h = new Http();
        HttpRequest tokenReq = new HttpRequest();
        tokenReq.setMethod('GET');
        tokenReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        

        PageReference ref = null;
        Map<String, String> params = new Map<String, String>();
        params.put('grant_type','client_credentials');

        if(isSandbox) {
            tokenReq.setEndpoint(setting.CHCRM_Test_Token_End_Point__c);
            ref = new PageReference(setting.CHCRM_Test_Token_End_Point__c);
            params.put('client_id',setting.CHCRM_Test_Token_Client_ID__c);
            params.put('client_secret',setting.CHCRM_Test_Token_Client_Secret__c);
            params.put('resource',setting.CHCRM_Test_Resource__c);
        } else {
            tokenReq.setEndpoint(setting.CHCRM_Prod_Token_End_Point__c);
            ref = new PageReference(setting.CHCRM_Prod_Token_End_Point__c);
            params.put('client_id',setting.CHCRM_Prod_Token_Client_ID__c);
            params.put('client_secret',setting.CHCRM_Prod_Token_Client_Secret__c);
            params.put('resource',setting.CHCRM_Prod_Resource__c);
        }
        ref.getParameters().putAll(params);
        Url finalUrl = new Url(ref.getUrl());
        tokenReq.setBody(finalUrl.getQuery());
        System.debug('***Callout Token Body:' + finalUrl.getQuery());

        HttpResponse tokenRes = h.send(tokenReq);
        TokenResponse tResObj = (TokenResponse) JSON.deserialize(tokenRes.getBody(), TokenResponse.class);
        System.debug('***Callout Token Response:' + tResObj);

        //Business Process Call Out
        HttpRequest bizReq = new HttpRequest();
        bizReq.setMethod(HTTP_POST);
        bizReq.setHeader(AUTHORIZATION_METHOD, AUTH_BEARER + tResObj.access_token);
        bizReq.setHeader(CONTENT_TYPE, CONTENT_TYPE_JSON);
        if(isSandbox) {
            bizReq.setEndpoint(setting.CHCRM_Test_End_Point__c + '?client_id=' + setting.CHCRM_Test_Client_ID__c + '&client_secret=' + setting.CHCRM_Test_Client_Secret__c);
        } else {
            bizReq.setEndpoint(setting.CHCRM_Prod_End_Point__c + '?client_id=' + setting.CHCRM_Prod_Client_ID__c + '&client_secret=' + setting.CHCRM_Prod_Client_Secret__c);
        }
        System.debug('The End point is :'+setting.CHCRM_Test_End_Point__c + '?client_id=' + setting.CHCRM_Test_Client_ID__c + '&client_secret=' + setting.CHCRM_Test_Client_Secret__c);
        bizReq.setBody(body);
        HttpResponse bizRes = h.send(bizReq);
        System.debug('***Callout Response:' + bizRes.getBody());
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      TokenResponse Class
    ************************************************************************************************/
    public with sharing class TokenResponse {
        //Error
        public String error { get; set; }
        public String error_description { get; set; }
        public List<String> error_codes { get; set; }
        public String timestamp { get; set; }
        public String trace_id { get; set; }
        public String correlation_id { get; set; }
        public String error_uri { get; set; }
        //Success
        public String token_type { get; set; }
        public String expires_in { get; set; }
        public String ext_expires_in { get; set; }
        public String expires_on { get; set; }
        public String not_before { get; set; }
        public String resource { get; set; }
        public String access_token { get; set; }
    }

    //Mothly Assignment Objective
    //@future(callout=true)
    public static void sendMonthlyObjectives(String objectiveId, String token) {
        if(isMuleSoftIntegrateProfile()){
            return;
        }
        CHCRM_HQ_Monthly_Assgmnt_Obj__c objective = [SELECT Id,
                                                        OwnerId,
                                                        CHCRM_OEM_Brand__c,CHCRM_SD_Group__c,
                                                        CHCRM_Month__c,CHCRM_Year__c,
                                                        CHCRM_OEM_HQ__c,CHCRM_Plan_Status__c,
                                                        LastModifiedDate,
                                                        CHCRM_Visit_Objective__c,CHCRM_Description__c 
                                                        FROM CHCRM_HQ_Monthly_Assgmnt_Obj__c WHERE Id = :objectiveId LIMIT 1];
        String requestBody = generateMonthlyObjectiveRequestBody(objective,token);
        System.debug('*** Request Body:' + requestBody);
        if(!Test.isRunningTest()) {
            doCallout('MonthlyObjective',requestBody);
        }
    }

    public static String generateMonthlyObjectiveRequestBody(CHCRM_HQ_Monthly_Assgmnt_Obj__c obj, String pToken) {
        List<MonthlyObjectiveItem> items = new List<MonthlyObjectiveItem>();
        MonthlyObjective objective = new MonthlyObjective();
        objective.token = pToken;

        OEMBrand brand = new OEMBrand();
        brand.code = obj.CHCRM_OEM_Brand__c;
        SDGroup sdGroup = new SDGroup();
        sdGroup.code = obj.CHCRM_SD_Group__c;
        RecordOwner ow = new RecordOwner();
        ow.code = obj.OwnerId;
        MonthlyObjectiveItem item = new MonthlyObjectiveItem();
        item.code = obj.Id;
        item.month = obj.CHCRM_Month__c;
        item.year = obj.CHCRM_Year__c;
        item.brandHq = obj.CHCRM_OEM_HQ__c;
        item.planStatus = obj.CHCRM_Plan_Status__c;
        item.description = obj.CHCRM_Description__c;
        item.visitObjectives = obj.CHCRM_Visit_Objective__c.split(';');
        item.modifyTime = obj.LastModifiedDate;
        item.sd = sdGroup;
        item.brand = brand;
        item.userFile = ow;
        items.add(item);
        objective.data = items;
        return JSON.serialize(objective);
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      MonthlyObjective Class
    ************************************************************************************************/
    public with sharing class MonthlyObjective {
        public String token { get; set; }
        public List<MonthlyObjectiveItem> data { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      MonthlyObjectiveItem Class
    ************************************************************************************************/
    public with sharing class MonthlyObjectiveItem {
        public String code { get; set; }
        public String month { get; set; }
        public String year { get; set; }
        public String brandHq { get; set; }
        public String planStatus { get; set; }
        public String description { get; set; }
        public List<String> visitObjectives { get; set; }
        public SDGroup sd { get; set; }
        public OEMBrand brand { get; set; }
        public RecordOwner userFile { get; set; }
        public DateTime modifyTime { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      SDGroup Class
    ************************************************************************************************/
    public with sharing class SDGroup {
        public String code { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      OEMBrand Class
    ************************************************************************************************/
    public with sharing class OEMBrand {
        public String code { get; set; }
    }

    //Mothly Assignment
    //@future(callout=true)
    public static void sendMonthlyAssignments(String assignmentId, String token) {
        if(isMuleSoftIntegrateProfile()){
            return;
        }
        CHCRM_HQ_Monthly_Assgmnt__c assignment = [SELECT Id,
                                                        CHCRM_Acceptance_Status__c,CHCRM_Covered_Status__c,
                                                        CHCRM_Description__c,CHCRM_HQ_Mnthly_Assgmnt_Obj__c,
                                                        CHCRM_Workshop__c,CHCRM_Month__c,
                                                        OwnerId,
                                                        CHCRM_HQ_Mnthly_Assgmnt_Obj__r.CHCRM_OEM_Brand__c,
                                                        CHCRM_Physically_Visit__c,CHCRM_Reject_Reason__c,
                                                        CHCRM_HQ_Mnthly_Assgmnt_Obj__r.CHCRM_SD_Group__c,
                                                        CHCRM_HQ_Mnthly_Assgmnt_Obj__r.CHCRM_OEM_Brand__r.CHCRM_Headquarter__c,
                                                        LastModifiedDate,
                                                        CHCRM_Visit_Target__c,CHCRM_Year__c 
                                                        FROM CHCRM_HQ_Monthly_Assgmnt__c WHERE Id = :assignmentId LIMIT 1];
        String requestBody = generateMonthlyAssignmentRequestBody(assignment,token);
        System.debug('*** Request Body:' + requestBody);
        if(!Test.isRunningTest()) {
            doCallout('MonthlyAssignment',requestBody);
        }
    }


    public static String generateMonthlyAssignmentRequestBody(CHCRM_HQ_Monthly_Assgmnt__c assignment, String pToken) {
        List<MonthlyAssignmentItem> items = new List<MonthlyAssignmentItem>();
        MonthlyAssignment mothlyAssign = new MonthlyAssignment();
        mothlyAssign.token = pToken;

        OEMBrand brand = new CHCRM_IntegrationUtility.OEMBrand();
        brand.code = assignment.CHCRM_HQ_Mnthly_Assgmnt_Obj__r.CHCRM_OEM_Brand__c;
        CHCRM_IntegrationUtility.SDGroup sdGroup = new SDGroup();
        sdGroup.code = assignment.CHCRM_HQ_Mnthly_Assgmnt_Obj__r.CHCRM_SD_Group__c;
        MonthlyAssignmentObj objective = new MonthlyAssignmentObj();
        objective.code = assignment.CHCRM_HQ_Mnthly_Assgmnt_Obj__c;
        KeyWorkshop keyWS = new KeyWorkshop();
        keyWS.code = assignment.CHCRM_Workshop__c;
        OEMHQ hq = new OEMHQ();
        hq.code = assignment.CHCRM_HQ_Mnthly_Assgmnt_Obj__r.CHCRM_OEM_Brand__r.CHCRM_Headquarter__c;
        RecordOwner ow = new RecordOwner();
        ow.code = assignment.OwnerId;

        MonthlyAssignmentItem item = new MonthlyAssignmentItem();
        item.code = assignment.Id;
        item.target = objective;
        item.year = assignment.CHCRM_Year__c;
        item.month = assignment.CHCRM_Month__c;
        item.visitObjective = assignment.CHCRM_Visit_Target__c;
        item.wm = ow;
        item.keyActivation = keyWS;
        item.brand = brand;
        item.belong = hq;
        item.sd = sdGroup;
        item.coveredStatus = assignment.CHCRM_Covered_Status__c;
        item.description = assignment.CHCRM_Description__c;
        item.acceptanceStatus = assignment.CHCRM_Acceptance_Status__c;
        item.refusalReason = assignment.CHCRM_Reject_Reason__c;
        item.modifyTime = assignment.LastModifiedDate;
        items.add(item);
        mothlyAssign.data = items;
        return JSON.serialize(mothlyAssign);
    }


    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      MonthlyAssignment Class
    ************************************************************************************************/
    public with sharing class MonthlyAssignment {
        public String token { get; set; }
        public List<MonthlyAssignmentItem> data { get; set; }
    }
    
    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      MonthlyAssignmentItem Class
    ************************************************************************************************/
    public with sharing class MonthlyAssignmentItem {
        public String code { get; set; }
        public String coveredStatus { get; set; }
        public String description { get; set; }
        public String acceptanceStatus { get; set; }
        public String refusalReason { get; set; }
        public SDGroup sd { get; set; }
        public OEMBrand brand { get; set; }
        public OEMHQ belong { get; set; }
        public KeyWorkshop keyActivation { get; set; }
        public RecordOwner wm { get; set; }
        public String visitObjective { get; set; }
        public String month { get; set; }
        public String year { get; set; }
        public MonthlyAssignmentObj target { get; set; }
        public DateTime modifyTime { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      MonthlyAssignmentObj Class
    ************************************************************************************************/
    public with sharing class MonthlyAssignmentObj {
        public String code { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      KeyWorkshop Class
    ************************************************************************************************/
    public with sharing class KeyWorkshop {
        public String code { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      OEMHQ Class
    ************************************************************************************************/
    public with sharing class OEMHQ {
        public String code { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      RecordOwner Class
    ************************************************************************************************/
    public with sharing class RecordOwner {
        public String code { get; set; }
    }  

    //Event
    //@future(callout=true)
    public static void sendEvent(Id eventId, String token) {
        if(isMuleSoftIntegrateProfile()){
            return;
        }
        Event event = [SELECT Id, StartDateTime,EndDateTime,Type,
                              SOM_Status__c,Subject,CHCRM_Event__c,Description,
                              WhatId,WhoId,OwnerId,CHCRM_HQ_Mnthly_Assgmnt__c,LastModifiedDate 
                        FROM Event WHERE Id = :eventId LIMIT 1];
        CHCRM_Event__c chcrmEvent = [SELECT Id,CHCRM_Check_In_Time__c,CHCRM_Check_In_Address__c,CHCRM_Check_In_Location__Longitude__s,CHCRM_Check_In_Location__Latitude__s,CHCRM_Complaint_Resolved__c,
                                            CHCRM_Complaint_Remarks__c,CHCRM_Cust_Exp_Day_Executed__c,CHCRM_Cust_Exp_Day_Remarks__c,
                                            CHCRM_Lead_Collected__c,CHCRM_Lead_Collected_Remarks__c,CHCRM_HQ_Policy_or_Mkt_Act__c,
                                            CHCRM_HQ_Policy_or_Mkt_Act_Remarks__c,CHCRM_Training__c,CHCRM_Training_Remarks__c,
                                            CHCRM_LTT_Exec__c,CHCRM_LTT_Remarks__c,LastModifiedDate FROM CHCRM_Event__c WHERE Id = :event.CHCRM_Event__c LIMIT 1];
        String requestBody = generateEventRequestBody(event,chcrmEvent,token);
        System.debug('*** Request Body:' + requestBody);
        if(!Test.isRunningTest()) {
            doCallout('Event',requestBody);
        }
    }

    public static String generateEventRequestBody(Event event,CHCRM_Event__c chcrm_event, String pToken) {
        List<EventItem> items = new List<EventItem>();
        Events events = new Events();
        events.token = pToken;
        EventItem item = new EventItem();
        item.code = event.Id;
        item.startTime = event.StartDateTime;
        item.endTime = event.EndDateTime;
        item.signTime = String.valueOf(chcrm_event.CHCRM_Check_In_Time__c);
        item.signPlace = chcrm_event.CHCRM_Check_In_Address__c;
        item.status = event.SOM_Status__c;
        item.longitude = chcrm_event.CHCRM_Check_In_Location__Longitude__s;
        item.latitude = chcrm_event.CHCRM_Check_In_Location__Latitude__s;
        item.content = event.Description;
        item.type = event.Type;
        item.topic = event.Subject;
        UserFile userFile = new UserFile();
        userFile.code = event.OwnerId;
        item.userFile = userFile;
        Customer customer = new Customer();
        customer.code = event.WhatId;
        item.customer = customer;
        CustomerContacter customerContacter = new CustomerContacter();
        customerContacter.code = event.WhoId;
        item.customerContacter = customerContacter;
        Task task = new Task();
        task.code = event.CHCRM_HQ_Mnthly_Assgmnt__c;
        item.task = task;
        item.complaint = chcrm_event.CHCRM_Complaint_Resolved__c;
        item.complaintMemo = chcrm_event.CHCRM_Complaint_Remarks__c;
        item.customerDay = chcrm_event.CHCRM_Cust_Exp_Day_Executed__c;
        item.customerDayMemo = chcrm_event.CHCRM_Cust_Exp_Day_Remarks__c;
        item.customerInfo = chcrm_event.CHCRM_Lead_Collected__c;
        item.customerInfoMemo = chcrm_event.CHCRM_Lead_Collected_Remarks__c;
        item.activity = chcrm_event.CHCRM_HQ_Policy_or_Mkt_Act__c;
        item.activityMemo = chcrm_event.CHCRM_HQ_Policy_or_Mkt_Act_Remarks__c;
        item.train = chcrm_event.CHCRM_Training__c;
        item.trainMemo = chcrm_event.CHCRM_Training_Remarks__c;
        item.ltt = chcrm_event.CHCRM_LTT_Exec__c;
        item.lttMemo = chcrm_event.CHCRM_LTT_Remarks__c;
        if(event.LastModifiedDate > chcrm_event.LastModifiedDate) {
            item.modifyTime = event.LastModifiedDate;
        } else {
            item.modifyTime = chcrm_event.LastModifiedDate;
        }
        items.add(item);
        events.data = items;
        return JSON.serialize(events);
    }
    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      Events Class
    ************************************************************************************************/
    public with sharing class Events {
        public String token { get; set; }
        public List<EventItem> data { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      EventItem Class
    ************************************************************************************************/
    public with sharing class EventItem{
        public String code { get; set; }
        public DateTime startTime { get; set; }
        public DateTime endTime { get; set; }
        public String signTime { get; set; }
        public String signPlace { get; set; }
        public String status { get; set; }
        public Decimal longitude { get; set; }
        public Decimal latitude { get; set; }
        public String content { get; set; }
        public String type { get; set; }
        public String topic { get; set; }
        public UserFile userFile { get; set; }
        public CustomerContacter customerContacter { get; set; }
        public Customer customer { get; set; }
        public Task task { get; set; }
        public Boolean complaint { get; set; }
        public String complaintMemo { get; set; }
        public Boolean customerDay { get; set; }
        public String customerDayMemo { get; set; }
        public Boolean customerInfo { get; set; }
        public String customerInfoMemo { get; set; }
        public Boolean activity { get; set; }
        public String activityMemo { get; set; }
        public Boolean train { get; set; }
        public String trainMemo { get; set; }
        public Boolean ltt { get; set; }
        public String lttMemo { get; set; }
        public DateTime modifyTime { get; set; }
    }
    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      UserFile Class
    ************************************************************************************************/
    public with sharing class UserFile {
        public String code { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      CustomerContacter Class
    ************************************************************************************************/
    public with sharing class CustomerContacter {
        public String code { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      Customer Class
    ************************************************************************************************/
    public with sharing class Customer {
        public String code { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      Task Class
    ************************************************************************************************/
    public with sharing class Task {
        public String code { get; set; }
    }

    //Delete Event
    //@future(callout=true)
    public static void sendDelEvent(String eventId, String token) {
        if(isMuleSoftIntegrateProfile()){
            return;
        }
        String requestBody = generateDelEventRequestBody(eventId,token);
        System.debug('*** Request Body:' + requestBody);
        if(!Test.isRunningTest()) {
            doCallout('DeleteEvent',requestBody);
        }
    }

    public static String generateDelEventRequestBody(String Id, String pToken) {
        DelEvents delEvents = new DelEvents();
        delEvents.Token = pToken;
        List<String> idList = new List<String>();
        idList.add(Id);
        delEvents.data = idList;
        return JSON.serialize(delEvents);
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      DelEvents Class
    ************************************************************************************************/
    public with sharing class DelEvents{
        public String token { get; set; }
        public List<String> data { get; set; }
    }

    //CHCRM Contact
    //@future(callout=true)
    public static void sendContacts(String contactId, String token) {
        if(isMuleSoftIntegrateProfile()){
            return;
        }
        Contact con = [SELECT Id,
                                            AccountId,
                                            Name,
                                            MobilePhone,
                                            Title,
                                            LastModifiedDate,
                                            CHCRM_Primary_Contact__c 
                                            FROM Contact WHERE Id = :contactId LIMIT 1];
        String requestBody = generateContactRequestBody(con,token);
        System.debug('*** Request Body:' + requestBody);
        if(!Test.isRunningTest()) {
            doCallout('Contact',requestBody);
        }
    }

    public static String generateContactRequestBody(Contact c, String pToken) {
        CHCRMContact cContact = new CHCRMContact();
        List<CHCRMContactItem> items = new List<CHCRMContactItem>();
        cContact.token = pToken;
        cContact.parentCode = c.AccountId;
        CHCRMContactItem item = new CHCRMContactItem();
        item.code = c.Id;
        item.name = c.Name;
        item.phone = c.MobilePhone;
        item.position = c.Title;
        item.primaryContacter = c.CHCRM_Primary_Contact__c;
        item.modifyTime = c.LastModifiedDate;
        items.add(item);
        cContact.data = items;
        return JSON.serialize(cContact);
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      CHCRMContact Class
    ************************************************************************************************/
    public with sharing class CHCRMContact {
        public String token { get; set; }
        public String parentCode { get; set; }
        public List<CHCRMContactItem> data { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      CHCRMContactItem Class
    ************************************************************************************************/
    public with sharing class CHCRMContactItem {
        public String code { get; set; }
        public String name { get; set; }
        public String phone { get; set; }
        public String position { get; set; }
        public Boolean primaryContacter { get; set; }
        public DateTime modifyTime { get; set; }
    }

    //@future(callout=true)
    public static void sendWorkshopYearlyStats(String wspYearlyStatsId, String token) {
        if(isMuleSoftIntegrateProfile()){
            return;
        }
        CHCRM_WSP_Yearly_Stats__c wspYearlyStats = [SELECT Id,CHCRM_Year__c,CHCRM_Workshop_Lubes_Volume__c,
                                                           CHCRM_Externally_Procured__c,CHCRM_Procured_from_Castrol__c,
                                                           CHCRM_Castrol_Total_Volume__c,CHCRM_Workshop__c,LastModifiedDate 
                                                           FROM CHCRM_WSP_Yearly_Stats__c WHERE Id = :wspYearlyStatsId LIMIT 1];
        String requestBody = generateWorkshopYearlyStatsRequestBody(wspYearlyStats,token);
        System.debug('*** Request Body:' + requestBody);
        if(!Test.isRunningTest()) {
            doCallout('WorkshopYearlyStats',requestBody);
        }
    }

    public static String generateWorkshopYearlyStatsRequestBody(CHCRM_WSP_Yearly_Stats__c wspYearlyStats, String pToken) {
        WSPYearlyStatsItems wspYearlyStatsItems = new WSPYearlyStatsItems();
        wspYearlyStatsItems.Token = pToken;
        List<WSPYearlyStatsItem> idList = new List<WSPYearlyStatsItem>();
        WSPYearlyStatsItem item = new WSPYearlyStatsItem();
        item.code = wspYearlyStats.Id;
        item.year = wspYearlyStats.CHCRM_Year__c;
        item.shopYearOilTotal = wspYearlyStats.CHCRM_Workshop_Lubes_Volume__c;
        item.outPurchase = wspYearlyStats.CHCRM_Externally_Procured__c;
        item.outPurchasePercent = wspYearlyStats.CHCRM_Procured_from_Castrol__c;
        item.castrolOilTotal = wspYearlyStats.CHCRM_Castrol_Total_Volume__c;
        item.modifyTime = wspYearlyStats.LastModifiedDate;
        idList.add(item);
        wspYearlyStatsItems.parentCode = wspYearlyStats.CHCRM_Workshop__c;
        wspYearlyStatsItems.data = idList;
        return JSON.serialize(wspYearlyStatsItems);
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      WSPYearlyStatsItems Class
    ************************************************************************************************/
    public with sharing class WSPYearlyStatsItems{
        public String token { get; set; }
        public List<WSPYearlyStatsItem> data { get; set; }
        public String parentCode { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      WSPYearlyStatsItem Class
    ************************************************************************************************/
    public with sharing class WSPYearlyStatsItem{
        public String code { get; set; }
        public String year { get; set; }
        public Decimal shopYearOilTotal { get; set; }
        public Boolean outPurchase { get; set; }
        public Double outPurchasePercent { get; set; }
        public Decimal castrolOilTotal { get; set; }
        public DateTime modifyTime { get; set; }
    }
    
    //Workshop Yearly Sales Reference
    //@future(callout=true)
    public static void sendWorkshopSalesReferences(String salesRefId, String token) {
        if(isMuleSoftIntegrateProfile()){
            return;
        }
        CHCRM_WSP_Yearly_SalesRef__c salesRef = [SELECT Id,
                                            CHCRM_April_Sell_In__c,CHCRM_April_Sell_Out__c,
                                            CHCRM_August_Sell_In__c,CHCRM_August_Sell_Out__c,
                                            CHCRM_Business_Type__c,CHCRM_December_Sell_In__c,
                                            CHCRM_December_Sell_Out__c,CHCRM_February_Sell_In__c,
                                            CHCRM_February_Sell_Out__c,CHCRM_January_Sell_In__c,
                                            CHCRM_January_Sell_Out__c,CHCRM_July_Sell_In__c,
                                            CHCRM_July_Sell_Out__c,CHCRM_June_Sell_In__c,
                                            CHCRM_June_Sell_Out__c,CHCRM_March_Sell_In__c,
                                            CHCRM_March_Sell_Out__c,CHCRM_May_Sell_In__c,
                                            CHCRM_May_Sell_Out__c,CHCRM_November_Sell_In__c,
                                            CHCRM_November_Sell_Out__c,CHCRM_October_Sell_In__c,
                                            CHCRM_October_Sell_Out__c,CHCRM_OEM_Brand__c,
                                            CHCRM_Q1_Target__c,CHCRM_Q2_Target__c,CHCRM_Q3_Target__c,
                                            CHCRM_Q4_Target__c,CHCRM_September_Sell_In__c,
                                            CHCRM_September_Sell_Out__c,CHCRM_Workshop__c,
                                            LastModifiedDate,
                                            CHCRM_Year__c  
                                            FROM CHCRM_WSP_Yearly_SalesRef__c WHERE Id = :salesRefId LIMIT 1];
        String requestBody = generateSalesRefRequestBody(salesRef,token);
        System.debug('*** Request Body:' + requestBody);
        if(!Test.isRunningTest()) {
            doCallout('WorkshopYearlySalesRef',requestBody);
        }
    }

    public static String generateSalesRefRequestBody(CHCRM_WSP_Yearly_SalesRef__c wsr, String pToken) {
        WorkshopYearlySalesRef workshopSalesRef = new WorkshopYearlySalesRef();
        List<WorkshopYearlySalesRefItem> items = new List<WorkshopYearlySalesRefItem>();
        workshopSalesRef.token = pToken;
        workshopSalesRef.parentCode = wsr.CHCRM_Workshop__c;
        WorkshopYearlySalesRefItem item = new WorkshopYearlySalesRefItem();
        item.code = wsr.Id;
        item.year = wsr.CHCRM_Year__c;
        item.q1 = wsr.CHCRM_Q1_Target__c;
        item.q2 = wsr.CHCRM_Q2_Target__c;
        item.q3 = wsr.CHCRM_Q3_Target__c;
        item.q4 = wsr.CHCRM_Q4_Target__c;
        item.janIn = wsr.CHCRM_January_Sell_In__c;
        item.janOut = wsr.CHCRM_January_Sell_Out__c;
        item.febIn = wsr.CHCRM_February_Sell_In__c;
        item.febOut = wsr.CHCRM_February_Sell_Out__c;
        item.marIn = wsr.CHCRM_March_Sell_In__c;
        item.marOut = wsr.CHCRM_March_Sell_Out__c;
        item.aprIn = wsr.CHCRM_April_Sell_In__c;
        item.aprOut = wsr.CHCRM_April_Sell_Out__c;
        item.mayIn = wsr.CHCRM_May_Sell_In__c;
        item.mayOut = wsr.CHCRM_May_Sell_Out__c;
        item.junIn = wsr.CHCRM_June_Sell_In__c;
        item.junOut = wsr.CHCRM_June_Sell_Out__c;
        item.julIn = wsr.CHCRM_July_Sell_In__c;
        item.julOut = wsr.CHCRM_July_Sell_Out__c;
        item.augIn = wsr.CHCRM_August_Sell_In__c;
        item.augOut = wsr.CHCRM_August_Sell_Out__c;
        item.sepIn = wsr.CHCRM_September_Sell_In__c;
        item.sepOut = wsr.CHCRM_September_Sell_Out__c;
        item.octIn = wsr.CHCRM_October_Sell_In__c;
        item.octOut = wsr.CHCRM_October_Sell_Out__c;
        item.novIn = wsr.CHCRM_November_Sell_In__c;
        item.novOut = wsr.CHCRM_November_Sell_Out__c;
        item.decIn = wsr.CHCRM_December_Sell_In__c;
        item.decOut = wsr.CHCRM_December_Sell_Out__c;
        item.modifyTime = wsr.LastModifiedDate;
        items.add(item);
        workshopSalesRef.data = items;
        return JSON.serialize(workshopSalesRef);
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      WorkshopYearlySalesRef Class
    ************************************************************************************************/
    public with sharing class WorkshopYearlySalesRef {
        public String token { get; set; }
        public String parentCode { get; set; }
        public List<WorkshopYearlySalesRefItem> data { get; set; }
    }

    /***********************************************************************************************
    * @author           Xc
    * @date             2020/08/11
    * @group            CHCRM
    * @description      Integration Utility Class
    ************************************************************************************************/
    public with sharing class WorkshopYearlySalesRefItem {
        public String code { get; set; }
        public String year { get; set; }
        public Decimal q1 { get; set; }
        public Decimal q2 { get; set; }
        public Decimal q3 { get; set; }
        public Decimal q4 { get; set; }
        public Decimal janIn { get; set; }
        public Decimal janOut { get; set; }
        public Decimal febIn { get; set; }
        public Decimal febOut { get; set; }
        public Decimal marIn { get; set; }
        public Decimal marOut { get; set; }
        public Decimal aprIn { get; set; }
        public Decimal aprOut { get; set; }
        public Decimal mayIn { get; set; }
        public Decimal mayOut { get; set; }
        public Decimal junIn { get; set; }
        public Decimal junOut { get; set; }
        public Decimal julIn { get; set; }
        public Decimal julOut { get; set; }
        public Decimal augIn { get; set; }
        public Decimal augOut { get; set; }
        public Decimal sepIn { get; set; }
        public Decimal sepOut { get; set; }
        public Decimal octIn { get; set; }
        public Decimal octOut { get; set; }
        public Decimal novIn { get; set; }
        public Decimal novOut { get; set; }
        public Decimal decIn { get; set; }
        public Decimal decOut { get; set; }
        public DateTime modifyTime { get; set; }
    }
    
    public static Boolean isMuleSoftIntegrateProfile(){
        CHCRM_BP_Integration_Profile_Setting__mdt mdt = [SELECT Id,Integrate_Profile__c 
                                                         FROM CHCRM_BP_Integration_Profile_Setting__mdt 
                                                         WHERE DeveloperName = 'MuleSoftIntegrateProfile' LIMIT 1];
        String profileId = UserInfo.getProfileId();
        Profile profile = [SELECT Id,Name FROM Profile WHERE Id = :profileId LIMIT 1];
        System.debug('The User Profile is :'+profile.Name);
        System.debug('The Setting Profile is :'+mdt.Integrate_Profile__c);
        if(profile.Name == mdt.Integrate_Profile__c){
            System.debug('The Profile is mulesoft integrate');
            return true;
        }
        return false;
    }
}