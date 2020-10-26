/***********************************************************************************************
 * @author           Sean
 * @date             2020/03/16
 * @group            CHCRM
 * @description      controller class used by vf page to sign-in in event

 * history
 * 2020/03/16  Sean  Created 
 ************************************************************************************************/
public with sharing class CHCRM_SignIn_Controller {

    /**
     * @description main function
     * @param e of type custom event object record
     * @return void
     */
    public CHCRM_SignIn_Controller(ApexPages.StandardController controller){
        
    }

    /**
     * @description update location info in event record
     * @param eid,lng,lat,address,signInTime of type String
     * @return void
    */
    @RemoteAction
    public static Id updateRecord(String eid,String lng,String lat,String address,String signInTime){
        Event e = [Select Id,CHCRM_Event__c From Event WHERE Id =: eid];
        e.SOM_Status__c = 'Completed';
        update e;

        CHCRM_Event__c custom_e = new CHCRM_Event__c();
        custom_e.Id = e.CHCRM_Event__c;
        custom_e.CHCRM_Check_In_Location__Longitude__s = Decimal.valueOf(lng);
        custom_e.CHCRM_Check_In_Location__Latitude__s = Decimal.valueOf(lat);
        custom_e.CHCRM_Check_In_Address__c = address;
        custom_e.CHCRM_Check_In_Time__c = DateTime.newInstance(Long.valueOf(signInTime));
        update custom_e;

        return e.Id;
    }

    /**
     * @description Get the operating platform of the current user
     * @param null
     * @return String
    */
    @RemoteAction
    public static String getOperationPlatform(){
        return UserInfo.getUiTheme() == 'Theme4t' ? 'Mobile' : 'PC';
    }
}