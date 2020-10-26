@isTest

private class ConnectorSettingsController_Test {
    static testMethod void unitTest1() {
        Test.startTest();

        PageReference pageRef = Page.ConnectorSettings;
        Test.setCurrentPage(pageRef);    
        ConnectorSettingsController controller = new ConnectorSettingsController();
        List<SelectOption> integrationTypeOptions = controller.getIntegrationTypeOptions();
        List<SelectOption> SFExperienceOptions = controller.getSFExperienceOptions();
        List<SelectOption> logLevelOptions = controller.getLogLevelOptions();
        List<SelectOption> protocolOptions = controller.getProtocolOptions();
        List<SelectOption> environmentOptions = controller.getEnvironmentOptions();
        controller.saveSettings();

        controller.integrationType = 'WDE';
        controller.sfExperience = 'Lightning';
        controller.logLevel = 'Debug';
        controller.externalRouting = true;
        controller.protocol = 'HTTPS';
        controller.host = 'localhost';
        controller.port = 4040;
        controller.ixnmgrurl = 'test.test.it';
        controller.environment = 'mypurecloud.com';
        controller.notReadyPresenceId = '';
        controller.queuePresenceId = '';
        controller.wweURL = 'test.it';
        controller.omniReadyId = '123';
        controller.saveSettings();

        Test.stopTest();
    }
}