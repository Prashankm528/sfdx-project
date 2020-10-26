/*************************************************************************
 * @author         Sean
 * @date           2020/03/30
 * @description    virtual class holds methods creation of test data

 * history
 * 2020/03/30  Sean  Created 
 *************************************************************************/
public with sharing class CHCRM_TestSetup {
    public static final Id CHCRM_ACCOUNT_WORKSHOP_RECORDTYPE = getAccRecordTypeIdByDevName('CHCRM_Workshop');
    
    public static final Id CHCRM_HQASSGMNTOBJ_OEMHQ_RECORDTYPE = Schema.SObjectType.CHCRM_HQ_Monthly_Assgmnt_Obj__c.getRecordTypeInfosByDeveloperName().get('CHCRM_OEM_Monthly_Assignment_Obj').getRecordTypeId();
    
    public static final Id CHCRM_HQASSGMNTOBJ_SUPERDEALER_RECORDTYPE = Schema.SObjectType.CHCRM_HQ_Monthly_Assgmnt_Obj__c.getRecordTypeInfosByDeveloperName().get('CHCRM_SD_Monthly_Assignment_Obj').getRecordTypeId();
    
    public static final Id CHCRM_CONTACT_RECORDTYPE = getContactRecordTypeIdByDevName('CHCRM_Contact');
    
    public static final Id CHCRM_HQASSGMNT_OEMHQ_RECORDTYPE = getHQMonthRecordTypeIdByDevName('CHCRM_OEM_Monthly_Assignment');
    
    public static final Id CHCRM_HQASSGMNT_SUPERDEALER_RECORDTYPE = getHQMonthRecordTypeIdByDevName('CHCRM_SD_Monthly_Assignment');
    
    
    
    public static Id getAccRecordTypeIdByDevName(string devName){
		return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(devName).getRecordTypeId();
    }
    
    public static Id getContactRecordTypeIdByDevName(string developerName){
		return Schema.SObjectType.Contact
            .getRecordTypeInfosByDeveloperName()
            .get(developerName).getRecordTypeId();
    }
    
    public static Id getHQMonthRecordTypeIdByDevName(string dName){
		return Schema.SObjectType.CHCRM_HQ_Monthly_Assgmnt__c
            .getRecordTypeInfosByDeveloperName()
            .get(dName)
            .getRecordTypeId();
    }

    /**
     * @description create Event records
     * @param size of type integer
     * @return List collection of Event
     */
    public static List<Event> createEvents(Integer size){
        Id CHCRM_EVENT_RECORDTYPE = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('CHCRM_Event').getRecordTypeId();

        List<Event> result = new List<Event>();
        for (Integer index = 0; index < size; index++) {
            Event iterationEvent = new Event();
            iterationEvent.Subject = 'Test Subject' + size;
            iterationEvent.OwnerId = UserInfo.getUserId();
            iterationEvent.StartDateTime = Datetime.now();
            iterationEvent.EndDateTime = Datetime.now().addMinutes(30);
            iterationEvent.RecordTypeId = CHCRM_EVENT_RECORDTYPE;
            iterationEvent.Description = 'Test Description' + index;
            result.add(iterationEvent);
        }
        return result;
    }

    /**
     * @description create ContentVersion records
     * @param size of type integer
     * @return List collection of ContentVersion
     */
    public static List<ContentVersion> createContentVersions(Integer size){
        List<ContentVersion> result = new List<ContentVersion>();
        for (Integer index = 0; index < size; index++) {
            ContentVersion cv = new ContentVersion();
            cv.versionData = Blob.valueOf('Test Content' + size);
            cv.title = 'Test File' + size;
            cv.PathOnClient = 'Test' + size;
            cv.IsMajorVersion = true;
            result.add(cv);
        }
        return result;
    }

    /**
     * @description create ContentDocumentLink record
     * @param entityId of type Id
     * @return ContentDocumentLink
     */
    public static ContentDocumentLink createContentDocumentLink(Id entityId,Id contentId){
        ContentDocumentLink result = new ContentDocumentLink();
        result.LinkedEntityId = entityId;
        result.ContentDocumentId = contentId;
        return result;
    }

    /**
     * @description create Account record
     * @param 
     * @return Account
     */
    public static Account createWorkshopAccount(String name){
        Account result = new Account();
        result.RecordTypeId = CHCRM_ACCOUNT_WORKSHOP_RECORDTYPE;
        result.Name = name;
        return result;
    }

    /**
     * @description create HQ Monthly Assignment Objective record
     * @param recordTypeId of type Id, status of type string, objective of type string,oemBrandId of type Id
     * @return CHCRM_HQ_Monthly_Assgmnt_Obj__c
     */
    public static CHCRM_HQ_Monthly_Assgmnt_Obj__c createHQMonthlyAssgmntObj(Id recordTypeId,String status,String objective,Id oemBrandId){
        CHCRM_HQ_Monthly_Assgmnt_Obj__c result = new CHCRM_HQ_Monthly_Assgmnt_Obj__c();
        result.RecordTypeId = recordTypeId;
        result.CHCRM_Year__c = String.valueOf(Date.Today().Year());
        result.CHCRM_Month__c = String.valueOf(Date.Today().Month());
        result.CHCRM_Plan_Status__c = status;
        result.CHCRM_Visit_Objective__c = objective;
        result.CHCRM_OEM_Brand__c = oemBrandId;
        return result;
    }


    /**
     * @description create HQ Monthly Assignment record
     * @param recordtypeId of type Id,objectiveId of type Id,workshopId of type Id,acceptanceStatus of type string,coveredStatus of type string
     * @return CHCRM_HQ_Monthly_Assgmnt__c
     */
    public static CHCRM_HQ_Monthly_Assgmnt__c createHQMonthlyAssgmnt(Id recordtypeId,Id objectiveId,Id workshopId,String acceptanceStatus,String coveredStatus){
        CHCRM_HQ_Monthly_Assgmnt__c result = new CHCRM_HQ_Monthly_Assgmnt__c();
        result.RecordTypeId = recordtypeId;
        result.CHCRM_HQ_Mnthly_Assgmnt_Obj__c = objectiveId;
        result.CHCRM_Workshop__c = workshopId;
        result.CHCRM_Acceptance_Status__c = acceptanceStatus;
        result.CHCRM_Covered_Status__c = coveredStatus;
        return result;
    }

    /**
     * @description create OEM Brand record
     * @param name of type String, headquarterId of type string
     * @return CHCRM_OEM_Brand__c
     */
    public static CHCRM_OEM_Brand__c createOEMBrand(String name,String headquarterId){
        CHCRM_OEM_Brand__c result = new CHCRM_OEM_Brand__c();
        result.Name = name;
        result.CHCRM_Headquarter__c = headquarterId;
        result.CurrencyIsoCode = 'CNY';
        return result;
    }

    /**
     * @description create user
     * @param name of type String, profileName of type String, roleDevName of type String
     * @return User
     */
    public static User createUser(String name,String profileName,String roleDevName){
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = :roleDevName LIMIT 1];

        User result = new User();
        result.profileId = p.Id;
        result.LastName = name;
        result.Username = 'testchcrm' + name + '@bpchcrmtestclass.com.bptestclass';
        result.Email = 'testchcrm' + name + '@bpchcrmtestclass.com';
        result.CommunityNickname = 'testchcrm' + name;
        result.UserRoleId = r.Id;
        result.CurrencyIsoCode = 'CNY';
        result.Alias = 'talias';
        result.TimeZoneSidKey = 'Asia/Shanghai';
        result.LocaleSidKey = 'zh_CN';
        result.EmailEncodingKey = 'UTF-8';
        result.LanguageLocaleKey = 'zh_CN';
        return result;
    }

    /**
     * @description create CHCRM WSP Yearly Stats record
     * @param WorkshopId of type Id,year of type string,shopYearOilTotal of type Decimal,outPurchasePercent of type Double
     * @return CHCRM_WSP_Yearly_Stats__c
     */
    public static CHCRM_WSP_Yearly_Stats__c createWSPYearlyStats(Id WorkshopId,String year,Decimal shopYearOilTotal,Double outPurchasePercent){
        CHCRM_WSP_Yearly_Stats__c stats = new CHCRM_WSP_Yearly_Stats__c();
        stats.CHCRM_Workshop__c = WorkshopId;
        stats.CHCRM_Year__c = year;
        stats.CHCRM_Workshop_Lubes_Volume__c = shopYearOilTotal;
        stats.CHCRM_Procured_from_Castrol__c = outPurchasePercent;
        return stats;
    }

    /**
     * @description create contact record
     * @param lastName of type string,phone of type string,title of type string
     * @return CHCRM_WSP_Yearly_Stats__c
     */
    public static Contact createContact(String lastName,String phone,String title){
        Contact contact = new Contact();
        contact.RecordTypeId = CHCRM_CONTACT_RECORDTYPE;
        contact.LastName = lastName;
        contact.Phone = phone;
        contact.Title = title;
        return contact;
    }

    /**
     * @description create  WSP Yearly SalesRef  record
     * @return CHCRM_WSP_Yearly_SalesRef__c
     */
    public static CHCRM_WSP_Yearly_SalesRef__c createWSPYearlySalesRef(Id WorkshopId){
        CHCRM_WSP_Yearly_SalesRef__c wsr = new CHCRM_WSP_Yearly_SalesRef__c();
        wsr.CHCRM_Workshop__c = WorkshopId;
        wsr.CHCRM_Year__c = '2022';
        wsr.CHCRM_Q1_Target__c = 3;
        wsr.CHCRM_Q2_Target__c = 3;
        wsr.CHCRM_Q3_Target__c = 3;
        wsr.CHCRM_Q4_Target__c = 3;
        wsr.CHCRM_January_Sell_In__c = 1;
        wsr.CHCRM_January_Sell_Out__c = 1;
        wsr.CHCRM_February_Sell_In__c = 1;
        wsr.CHCRM_February_Sell_Out__c = 1;
        wsr.CHCRM_March_Sell_In__c = 1;
        wsr.CHCRM_March_Sell_Out__c = 1;
        wsr.CHCRM_April_Sell_In__c = 1;
        wsr.CHCRM_April_Sell_Out__c = 1;
        wsr.CHCRM_May_Sell_In__c = 1;
        wsr.CHCRM_May_Sell_Out__c = 1;
        wsr.CHCRM_June_Sell_In__c = 1;
        wsr.CHCRM_June_Sell_Out__c = 1;
        wsr.CHCRM_July_Sell_In__c = 1;
        wsr.CHCRM_July_Sell_Out__c = 1;
        wsr.CHCRM_August_Sell_In__c = 1;
        wsr.CHCRM_August_Sell_Out__c = 1;
        wsr.CHCRM_September_Sell_In__c = 1;
        wsr.CHCRM_September_Sell_Out__c = 1;
        wsr.CHCRM_October_Sell_In__c = 1;
        wsr.CHCRM_October_Sell_Out__c = 1;
        wsr.CHCRM_November_Sell_In__c = 1;
        wsr.CHCRM_November_Sell_Out__c = 1;
        wsr.CHCRM_December_Sell_In__c = 1;
        wsr.CHCRM_December_Sell_Out__c = 1;
        return wsr;
    }
    
    
    /**
     * @description create  Sub Channel Account  record
     * @return CHCRM_Sub_Channel_Account__c
     */
    public static CHCRM_Sub_Channel_Account__c createSubChannelAccount(Id accountId , String name , String code){
        CHCRM_Sub_Channel_Account__c subChannelAccount = new CHCRM_Sub_Channel_Account__c();
        subChannelAccount.CHCRM_Account__c = accountId;
        subChannelAccount.Name = name;
        subChannelAccount.CHCRM_Sub_Channel_Account_Code__c = code;
        return subChannelAccount;
    }
    
    /**
     * @description create  Sub Channel Sub Account  record
     * @return CHCRM_Sub_Channel_Sub_Account__c
     */
    public static CHCRM_Sub_Channel_Sub_Account__c createSubChannelSubAccount(Id subChannelAccountId , String name , String code , String billTo){
        CHCRM_Sub_Channel_Sub_Account__c subChannelSubAccount = new CHCRM_Sub_Channel_Sub_Account__c();
        subChannelSubAccount.CHCRM_Sub_Channel_Account__c = subChannelAccountId;
        subChannelSubAccount.Name = name;
        subChannelSubAccount.CHCRM_Sub_Channel_Sub_Account_Code__c = code;
        subChannelSubAccount.CHCRM_Bill_To__c = billTo;
        return subChannelSubAccount;
    }
    
    /**
     * @description create  Key Account Plan  record
     * @return CHCRM_Key_Account_Plan__c
     */
    public static CHCRM_Key_Account_Plan__c createKap(Id subChannelAccountId , String year){
        CHCRM_Key_Account_Plan__c kap = new CHCRM_Key_Account_Plan__c();
        Id chcrmId = Schema.SObjectType.CHCRM_Key_Account_Plan__c.getRecordTypeInfosByDeveloperName().get('CHCRM_Key_Account_Plan').getRecordTypeId();
        kap.RecordTypeId = chcrmId;
        kap.CHCRM_Sub_Channel_Account__c = subChannelAccountId;
        kap.CHCRM_Year__c = year;
        kap.KAP_Start_Date__c = System.today() - 10;
        kap.KAP_End_Date__c = System.today() + 10;
        kap.CHCRM_Status__c = 'Draft';
        return kap;
    }

    /**
     * @description create Product Structure record
     * @return CHCRM_Product_Structure__c
     */
    public static CHCRM_Product_Structure__c createProductStructure(String name , Id parentId){
        CHCRM_Product_Structure__c structure = new CHCRM_Product_Structure__c();
        if(!String.isBlank(parentId)){
            structure.CHCRM_Parent_Product__c = parentId;
        }
        structure.CHCRM_Priority__c = '1';
        structure.Name = name;
        return structure;
    }

    /**
     * @description create PBV record
     * @return CHCRM_PBV_Detail__c
     */
    public static CHCRM_PBV_Detail__c createPBV(String name , Id parentId){
        CHCRM_PBV_Detail__c pbv = new CHCRM_PBV_Detail__c();
        if(!String.isBlank(parentId)){
            pbv.CHCRM_Parent_PBV__c = parentId;
        }
        pbv.Name = name;
        return pbv;
    }

    /**
     * @description create SKU record
     * @return CHCRM_SKU_Detail__c
     */
    public static CHCRM_SKU_Detail__c createSKU(Id productStructureId , String name){
        CHCRM_SKU_Detail__c sku = new CHCRM_SKU_Detail__c();
        sku.CHCRM_Product_Brand_Variant__c = productStructureId;
        sku.Name = name;
        sku.CHCRM_SKU_Code__c = name;
        return sku;
    }
    
    /**
     * @description create Power Map record
     * @return CHCRM_KAP_Power_Map__c
     */
    public static CHCRM_KAP_Power_Map__c createPowerMap(Id subChannelAccountId){
        CHCRM_KAP_Power_Map__c powerMap = new CHCRM_KAP_Power_Map__c();
        powerMap.CHCRM_Sub_Channel_Account__c = subChannelAccountId;        
        return powerMap;
    }
    
    /**
     * @description create KAP Sales Target record
     * @return CHCRM_KAP_Sales_Target__c
     */
    public static CHCRM_KAP_Sales_Target__c createSalesTarget(Id subChannelAccountId ,Id kapId , Id subChannelSubAccountId , Id pbvId , Id skuId , String category , String year){
        CHCRM_KAP_Sales_Target__c salesTarget = new CHCRM_KAP_Sales_Target__c();
        salesTarget.CHCRM_Sub_Channel_Account__c = subChannelAccountId;
        salesTarget.CHCRM_Category__c = category;
        salesTarget.CHCRM_Key_Account_Plan__c = kapId;
        salesTarget.CHCRM_Sub_Channel_Sub_Account__c = subChannelSubAccountId;
        salesTarget.CHCRM_Year__c = year;
        if(category == 'PBV'){
            salesTarget.CHCRM_PBV__c = pbvId;
        }
        if(category == 'SKU'){
            salesTarget.CHCRM_SKU_Detail__c = skuId;
        }
        return salesTarget;
    }
    
    /**
     * @description create KAP Business Volume Actual
     * @return CHCRM_KAP_Business_Volume_Actual__c
     */
    public static CHCRM_KAP_Business_Volume_Actual__c createBusinessVolumeAc(Id subChannelAccountId , String year){
        CHCRM_KAP_Business_Volume_Actual__c ac = new CHCRM_KAP_Business_Volume_Actual__c();
        ac.CHCRM_Sub_Channel_Account__c = subChannelAccountId;
        ac.CHCRM_Year__c = year;
        ac.CHCRM_Coverage_Percent__c = 20;
        ac.CHCRM_GM_RMB__c = 10000;
        ac.CHCRM_GP_RMB__c = 10000;
        ac.CHCRM_In_Store_Share_Percent__c = 20;
        ac.CHCRM_Return_On_Investment__c = 20;
        ac.CHCRM_Turnover_RMB__c = 10000;
        ac.CHCRM_Volume_L__c = 10000;
        return ac;
    }
    
    /**
     * @description create SOV Title Project Information
     * @return CHCRM_KAP_Sov_AUTO_Project_Information__c
     */
    public static CHCRM_KAP_Sov_AUTO_Project_Information__c createSovProjectInfo(Id titleId){
        CHCRM_KAP_Sov_AUTO_Project_Information__c project = new CHCRM_KAP_Sov_AUTO_Project_Information__c();
        project.CHCRM_KAP_Sov_AUTO_Title__c = titleId;
        return project;
    }
    
    /**
     * @description create KAP Action Plan
     * @return CHCRM_KAP_Action_Plan__c
     */
    public static CHCRM_KAP_Action_Plan__c createKAPActionPlan(Id kapId , String name){
        CHCRM_KAP_Action_Plan__c plan = new CHCRM_KAP_Action_Plan__c();
        plan.CHCRM_Key_Account_Plan__c = kapId;
        plan.Name = name;
        return plan;
    }
    
    /**
     * @description create Competitor
     * @return Competitor__c
     */
    public static Competitor__c createCompetitor(Id accoutId , String name , Boolean mainStream){
        Competitor__c c = new Competitor__c();
        c.Name = name;
        c.CHCRM_Main_Stream__c = mainStream;
        c.CHCRM_Description__c = '测试嘉实多';
        c.RecordTypeId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('CHCRM_Competitor').getRecordTypeId();
        c.CHCRM_Workshop__c = accoutId;
        return c;
    }
    
}