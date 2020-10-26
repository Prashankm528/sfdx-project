/**
* @author Nazim Aliyev
* @company bluewolf, an ibm company
* @date 02/2018
*
* Controller for Store Search Lightning Component
*/
public class REIDP_PAStoreSearchController {
    
    @AuraEnabled
    public static StoreConfig getStoreAcceptanceLocationConfig(String storeCode) {
        StoreConfig conf = new StoreConfig();
        conf.acceptanceLocation = REIDP_PAB2BApi.getStoreAcceptanceLocationConfig(storeCode);
        return conf;
    }
    
    @AuraEnabled
    public static Boolean setMobileEnabled(String storeCode, Boolean mobileEnabled) {
        StoreConfig conf = REIDP_PAStoreSearchController.getStoreAcceptanceLocationConfig(storeCode);
        conf.setMobileEnabled(mobileEnabled);
        REIDP_PAB2BApi.updateMerchantLocation(conf.acceptanceLocation);
        return true;
    }
    
    @AuraEnabled
    public static Boolean updateStoreAcceptanceLocationConfig(String aLocation, Boolean mobileEnabled, String goLiveDate) {
        REIDP_PAB2BApi.AcceptanceLocation acceptanceLocation = (REIDP_PAB2BApi.AcceptanceLocation) JSON.deserialize(aLocation, REIDP_PAB2BApi.AcceptanceLocation.class);
        StoreConfig newConfig = REIDP_PAStoreSearchController.getStoreAcceptanceLocationConfig(acceptanceLocation.storeCode);
        newConfig.setMobileEnabled(mobileEnabled);
        if(goLiveDate != null)
            newConfig.setGoLiveDate(goLiveDate);
        newConfig.acceptanceLocation.latitude = acceptanceLocation.latitude;
        newConfig.acceptanceLocation.longitude = acceptanceLocation.longitude;
        REIDP_PAB2BApi.updateMerchantLocation(newConfig.acceptanceLocation);
        return true;
    }
    
    public class StoreConfig {
        @AuraEnabled
        public REIDP_PAB2BApi.AcceptanceLocation acceptanceLocation;
        
        @AuraEnabled
        public Boolean mobileEnabled {
            public get {
                if(mobileEnabled == null && acceptanceLocation != null) {
                    String customAttributes = '';
                    Map<String, String> additionalInfo = new Map<String, String>();
                    for(REIDP_PAApi.KeyVal keyVal : acceptanceLocation.additionalInformation) {
                        if(keyVal != null && keyVal.key != null && keyVal.key.startsWith('SL_CUSTOM_ATTRIBUTES') && keyVal.value != null )
                            additionalInfo.put(keyVal.key, keyVal.value);
                    }
                    
                    customAttributes += additionalInfo.get('SL_CUSTOM_ATTRIBUTES');
                    
                    mobileEnabled = customAttributes.contains('MobileEnabled=TRUE');
                }
                return mobileEnabled;
            }
            private set;
        }
        
        @AuraEnabled
        public String goLiveDate {
            public get {
                if(goLiveDate == null && acceptanceLocation != null) {
                    for(REIDP_PAApi.KeyVal keyVal : acceptanceLocation.additionalInformation) {
                        if(keyVal != null && keyVal.key == 'SL_GO_LIVE_DATE' && keyVal.value != null ) {
                            goLiveDate = keyVal.value;
                        }
                    }
                }
                return goLiveDate;
            }
            private set;
        }
        
        public void setGoLiveDate(String goLiveDate) {
            if(acceptanceLocation == null || acceptanceLocation.additionalInformation == null)
                return;
            for(REIDP_PAApi.KeyVal keyVal : acceptanceLocation.additionalInformation) {
                if(keyVal != null && keyVal.key == 'SL_GO_LIVE_DATE') {
                    keyVal.value = goLiveDate;
                }
            }
        }
        
        public void setMobileEnabled(Boolean mobileEnable) {
            if(acceptanceLocation == null || acceptanceLocation.additionalInformation == null)
                return;
            
            String customAttributes = '';
            List<REIDP_PAApi.KeyVal> updatedAdditionalInformation = new List<REIDP_PAApi.KeyVal>();
            Map<String, String> additionalInfo = new Map<String, String>();
            for(REIDP_PAApi.KeyVal keyVal : acceptanceLocation.additionalInformation) {
                if(keyVal != null && keyVal.key != null && keyVal.key.startsWith('SL_CUSTOM_ATTRIBUTES') && keyVal.value != null )
                    additionalInfo.put(keyVal.key, keyVal.value);
                else
                    updatedAdditionalInformation.add(keyVal);
            }
            
            customAttributes += additionalInfo.get('SL_CUSTOM_ATTRIBUTES');
            
            customAttributes = mobileEnable ? customAttributes.replace('MobileEnabled=FALSE', 'MobileEnabled=TRUE') 
                							: customAttributes.replace('MobileEnabled=TRUE', 'MobileEnabled=FALSE');
            
            while(customAttributes.length() > 0) {
                REIDP_PAApi.KeyVal keyVal = new REIDP_PAApi.KeyVal();
                keyVal.key = 'SL_CUSTOM_ATTRIBUTES';
                if(customAttributes.length() > 255) {
                    keyVal.value = customAttributes.substring(0, 254);
                    customAttributes = customAttributes.substring(254);
                }
                else {
                    keyVal.value = customAttributes;
                    customAttributes = '';
                }
                updatedAdditionalInformation.add(keyVal);
                
            }
            acceptanceLocation.additionalInformation = updatedAdditionalInformation;
        }
    }
    
    
}