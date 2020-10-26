public without sharing class ConnectorSettingsController {
    
    public Connector_Settings__c connectorSettings;

    public ConnectorSettingsController() {
        
        this.loadValues();
    }

    public void loadValues(){
        connectorSettings = Connector_Settings__c.getOrgDefaults();
        this.integrationType = connectorSettings.Integration_Type__c;
        this.sfExperience = connectorSettings.SF_Experience__c;
        this.logLevel = connectorSettings.Log_Level__c;
        this.externalRouting = connectorSettings.External_Routing__c;
        this.protocol = connectorSettings.WDE_Protocol__c;
        this.host = connectorSettings.WDE_Host__c;
        this.port = Integer.valueOf(connectorSettings.WDE_Port__c);
        this.ixnmgrurl = connectorSettings.IXN_MGR_URL__c;
        this.environment = connectorSettings.PureCloud_Environment__c;
        this.notReadyPresenceId = connectorSettings.PureCloud_Not_Ready_Presence_ID__c;
        this.queuePresenceId = connectorSettings.PureCloud_On_Queue_Presence_ID__c;
        this.wweURL = connectorSettings.WWE_URL__c;
        this.omniReadyId= connectorSettings.ER_OmniReadyID__c;
        this.omniNotReadyId= connectorSettings.ER_OmniNotReadyID__c;
        
        this.wdeChannelsToSynch= connectorSettings.Setup_Done__c ? connectorSettings.ER_WdeChannelsToSynch__c : 'workitem';
        this.hideWebRTCPopUpOption = connectorSettings.hideWebRTCPopUpOption__c;
        this.enableCallLogs = connectorSettings.Setup_Done__c ? connectorSettings.enableCallLogs__c : true;
        this.hideCallLogSubject = connectorSettings.hideCallLogSubject__c;
        this.hideCallLogContact = connectorSettings.hideCallLogContact__c;
        this.hideCallLogRelation = connectorSettings.hideCallLogRelation__c;
        this.dedicatedLoginWindow = connectorSettings.dedicatedLoginWindow__c;
        this.embedWebRTCByDefault = connectorSettings.Setup_Done__c ? connectorSettings.embedWebRTCByDefault__c : true;
    }

    public String integrationType {get;set;}
    public String sfExperience {get;set;}
    public String logLevel {get;set;}
    public Boolean externalRouting {get;set;}
    public String protocol {get;set;}
    public String host {get;set;}
    public Integer port {get;set;}
    public String ixnmgrurl {get;set;}
    public String environment {get;set;}
    public String notReadyPresenceId {get;set;}
    public String queuePresenceId {get;set;}
    public String wweURL {get;set;}
    public String omniReadyId {get;set;}
    public String omniNotReadyId {get;set;}
    public String wdeChannelsToSynch {get;set;}
    public Boolean hideWebRTCPopUpOption {get;set;}
    public Boolean enableCallLogs {get;set;}
    public Boolean hideCallLogSubject {get;set;}
    public Boolean hideCallLogContact {get;set;}
    public Boolean hideCallLogRelation {get;set;}
    public Boolean dedicatedLoginWindow {get;set;}
    public Boolean embedWebRTCByDefault {get;set;}

    public List<SelectOption> getIntegrationTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select-'));
        options.add(new SelectOption('WDE','WDE'));
        options.add(new SelectOption('PURECLOUD','Pure Cloud'));
        options.add(new SelectOption('WWE','WWE'));
        return options;
    }

    public List<SelectOption> getSFExperienceOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select-'));
        options.add(new SelectOption('Classic','Classic'));
        options.add(new SelectOption('Lightning','Lightning'));
        return options;
    }

    public List<SelectOption> getLogLevelOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select-'));
        options.add(new SelectOption('Debug','Debug'));
        options.add(new SelectOption('Error','Error'));
        return options;
    }

    public List<SelectOption> getProtocolOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select-'));
        options.add(new SelectOption('http','http'));
        options.add(new SelectOption('https','https'));
        options.add(new SelectOption('ws','ws'));
        options.add(new SelectOption('wss','wss'));
        return options;
    }

    public List<SelectOption> getEnvironmentOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('mypurecloud.com','mypurecloud.com'));
        options.add(new SelectOption('mypurecloud.com.au','mypurecloud.com.au'));
        options.add(new SelectOption('mypurecloud.de','mypurecloud.de'));
        options.add(new SelectOption('mypurecloud.jp','.mypurecloud.jp'));
        options.add(new SelectOption('mypurecloud.ie','.mypurecloud.ie'));
        return options;
    }

    public pageReference saveSettings(){
        system.debug('***' + integrationType);
        Connector_Settings__c connectorSettings = Connector_Settings__c.getOrgDefaults();
        if(
            this.integrationType == null
            || this.sfExperience == null
            || this.logLevel == null
            ||
                (
                    this.integrationType == 'WDE' &&
                        (
                            this.protocol == null
                            || String.isBlank(this.host)
                            || this.port == null
                            || String.isBlank(ixnmgrurl)
                        )
                )
            ||
                (
                    this.integrationType == 'WWE' && 
                        (
                            String.isBlank(ixnmgrurl)
                            || String.isBlank(this.wweURL)
                        )
                )
            || 
                (
                    this.externalRouting == true && 
                        (
                            String.isBlank(this.omniReadyId)
                            || this.integrationType == 'WDE' &&
                                (
                                    String.isBlank(wdeChannelsToSynch)
                                )
                        )
                )
        ){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Please fill all the required fields!');
            ApexPages.getMessages().clear();
            ApexPages.addMessage(errorMsg);
        }else{
            try{
                connectorSettings.Integration_Type__c = this.integrationType;
                connectorSettings.SF_Experience__c = this.sfExperience;
                connectorSettings.Log_Level__c = this.logLevel;
                connectorSettings.External_Routing__c = this.externalRouting;
                connectorSettings.WDE_Protocol__c = this.protocol;
                connectorSettings.WDE_Host__c = this.host;
                connectorSettings.WDE_Port__c = this.port;
                connectorSettings.IXN_MGR_URL__c = this.ixnmgrurl;
                connectorSettings.PureCloud_Environment__c = this.environment;
                connectorSettings.PureCloud_Not_Ready_Presence_ID__c = this.notReadyPresenceId;
                connectorSettings.PureCloud_On_Queue_Presence_ID__c = this.queuePresenceId;
                connectorSettings.WWE_URL__c = this.wweURL;
                connectorSettings.ER_OmniReadyID__c = this.omniReadyId;
                connectorSettings.ER_OmniNotReadyID__c = this.omniNotReadyId;
                connectorSettings.ER_WdeChannelsToSynch__c = this.wdeChannelsToSynch;
                connectorSettings.hideWebRTCPopUpOption__c = this.hideWebRTCPopUpOption;
                connectorSettings.enableCallLogs__c = this.enableCallLogs;
                connectorSettings.hideCallLogSubject__c = this.hideCallLogSubject;
                connectorSettings.hideCallLogContact__c = this.hideCallLogContact;
                connectorSettings.hideCallLogRelation__c = this.hideCallLogRelation;
                connectorSettings.dedicatedLoginWindow__c = this.dedicatedLoginWindow;
                connectorSettings.embedWebRTCByDefault__c = this.embedWebRTCByDefault;
                connectorSettings.Setup_Done__c = true;
                
                upsert connectorSettings;
                ApexPages.Message successMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, 'Saved');
                ApexPages.getMessages().clear();
                ApexPages.addMessage(successMsg);
            }catch(Exception e){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
                ApexPages.getMessages().clear();
                ApexPages.addMessage(errorMsg);
            }
        }
        return null;
    }
}