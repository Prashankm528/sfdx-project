/**
 * @author          Jan Majling
 * @date            27/09/2018
 * @group           CAJBP
 * @description     controller for lightning component CAJBP_PdfExportButton
 *
 * history
 * 27/09/2018   Jan Majling         Created 
 */
public with sharing class CAJBP_PdfExportButtonController {
    private static final String PARTNER_SERVER_URL_REGEX = '\\{!API\\.Partner_Server_URL_(\\d{3})\\}';
    /**
     * @description gets map of CAJBP_Rebate__c record types except master record type
     * @param recordId of type Id
     * @return String
     */
    @AuraEnabled
    public static String getButtonUrl(Id recordId) {
        String recordObjectName = recordId.getSobjectType().getDescribe().getName();
       
         string fieldlabel;
         if(!Schema.sObjectType.APXTConga4__Conga_Solution__c.fields.APXTConga4__Button_body_field__c.isAccessible()){
            fieldlabel = Schema.sObjectType.APXTConga4__Conga_Solution__c.fields.APXTConga4__Button_body_field__c.getLabel();
            throw new AuraHandledException('Insufficient access to' + fieldlabel+ ' field.');
                   
        }
         
              
        List<APXTConga4__Conga_Solution__c> congaSolutions = [
            SELECT APXTConga4__Button_body_field__c
            FROM APXTConga4__Conga_Solution__c
            WHERE APXTConga4__Master_Object_Type__c = :recordObjectName
        ];
        
        if(congaSolutions.isEmpty()) {
           throw new AuraHandledException(Label.CAJBP_MissingCongaSolution);
        }

        String buttonUrl = congaSolutions.get(0).APXTConga4__Button_body_field__c;
        if(buttonUrl == null) {
           throw new AuraHandledException(Label.CAJBP_MissingCongaButtonUrl);
        }

        buttonUrl = buttonUrl.replace('\n', '');
        buttonUrl = buttonUrl.replace('{!' + recordObjectName + '.Id}', (String) recordId);
       
        return CAJBP_PdfExportButtonController.replaceServerUrl(buttonUrl);
        
    }

    /**
     * @description replace server url with the actual value
     * @param buttonUrl of type String
     * @return String
     */
    private static String replaceServerUrl(String buttonUrl) {
        Pattern pattern = Pattern.compile('.*' + PARTNER_SERVER_URL_REGEX + '.*');
        Matcher matcher = pattern.matcher(buttonUrl);
        if(!matcher.matches() || matcher.groupCount() == 0) {
            return buttonUrl;
        }

        String version = matcher.group(1);
        String partnerServerUrl = System.URL.getSalesforceBaseUrl().toExternalForm() +
            '/services/Soap/u/' + version.left(2) + '.' + version.right(1) +
            '/' + UserInfo.getOrganizationId();
        return buttonUrl.replaceFirst(PARTNER_SERVER_URL_REGEX, partnerServerUrl);
    }
}