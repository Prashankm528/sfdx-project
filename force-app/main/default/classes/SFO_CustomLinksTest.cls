@IsTest
private class SFO_CustomLinksTest {

    private class LinkMockService extends SFO_CustomLinksService {

        public override List<SFO_Custom_Link__mdt> getCustomLinks(String config, Set<String> names) {
            List<SFO_Custom_Link__mdt> links = new List<SFO_Custom_Link__mdt>();
            super.getCustomLinks(config, names);

            SFO_Custom_Link__mdt item = new SFO_Custom_Link__mdt();
            item.SFO_Active__c = true;
            item.SFO_Config__c = 'test1';
            item.SFO_Order__c = 1;
            item.SFO_Target__c = '_blank';
            item.SFO_Title__c = 'test';
            item.SFO_URL__c = 'https//customer.bp.com';
            item.SFO_Sales_Organisation__c = 'UK01';
            item.SFO_Business_Unit__c = null;
            links.add(item);

            item = new SFO_Custom_Link__mdt();
            item.SFO_Active__c = true;
            item.SFO_Config__c = 'test2';
            item.SFO_Order__c = 1;
            item.SFO_Target__c = '_blank';
            item.SFO_Title__c = 'test2';
            item.SFO_URL__c = 'https//community.bp.com';
            item.SFO_Sales_Organisation__c = null;
            item.SFO_Business_Unit__c = 'Lubricants - Industrial';
            links.add(item);
            
            item = new SFO_Custom_Link__mdt();
            item.SFO_Active__c = true;
            item.SFO_Config__c = 'test3';
            item.SFO_Order__c = 1;
            item.SFO_Target__c = '_blank';
            item.SFO_Title__c = 'test3';
            item.SFO_URL__c = 'https//community.bp.com';
            item.SFO_Sales_Organisation__c = 'UK01';
            item.SFO_Business_Unit__c = 'Lubricants - Industrial';
            links.add(item);
            
            item = new SFO_Custom_Link__mdt();
            item.SFO_Active__c = true;
            item.SFO_Config__c = 'test4';
            item.SFO_Order__c = 1;
            item.SFO_Target__c = '_blank';
            item.SFO_Title__c = 'test3';
            item.SFO_URL__c = 'https//community.bp.com';
            item.SFO_Sales_Organisation__c = 'UK01';
            item.SFO_Business_Unit__c = 'Lubricants - Industrial,Lubricants - Automative';
            links.add(item);
            
            return links;
        }
    }

    private class ErrorMockService extends SFO_CustomLinksService {
        public override List<SFO_Custom_Link__mdt> getCustomLinks(String config, Set<String> names) {
            throw new MockException('Invalid param');
        }
    }

    @IsTest
    private static void itShouldReturnLinks() {
        SFO_CustomLinksService service = new LinkMockService();

        Test.startTest();
            List<SFO_Custom_Link__mdt> links = service.getCustomLinks('test', new Set<String>{'test'});
            System.assertEquals(4, links.size());

            links = service.filter('US01', null,  links);
            System.assertEquals(0, links.size());
            

            links = service.getCustomLinks('test', new Set<String>{'test'});
            links = service.filter('UK01', null, links);
            System.assertEquals(1, links.size());

            links = service.getCustomLinks('test', new Set<String>{'test'});
            links = service.filter(null, 'Lubricants - Industrial',  links);
            System.assertEquals(1, links.size());
        
            links = service.getCustomLinks('test', new Set<String>{'test'});
            links = service.filter('UK01', 'Lubricants - Industrial',  links);
            System.assertEquals(4, links.size());
            
            links = service.getCustomLinks('test4', new Set<String>{'test4'});
            links = service.filter('UK01', 'Lubricants - Automative',  links);
            System.assertEquals(2, links.size());
    }

    @IsTest
    private static void itShouldReturnLinksDataFromController() {
        SFO_CustomLinksService service = new LinkMockService();
        SFO_CustomLinksController.LinkService = service;

        //Blank out the Sales_Organisation__c on user.
        User admin = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        admin.Sales_Organisation__c = null;
        admin.Business_Unit__c = 'Lubricants - Industrial';
        update admin;

        Test.startTest();
            Map<String, Object> response = SFO_CustomLinksController.getCustomLinksData('test', new List<String>{'test'});
            User currentUser = (User)response.get('currentUser');
            System.assertEquals(null, currentUser.Sales_Organisation__c);
            System.assertEquals(UserInfo.getUserId(), currentUser.Id);

            //We expect 1 as only one link is configured for industrial users with no sales org
            List<SFO_Custom_Link__mdt> links = (List<SFO_Custom_Link__mdt>)response.get('links');
            System.assertEquals(1, links.size());

            //Assign Sales_Organisation__c [UK01] on user.            
            admin = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            admin.Sales_Organisation__c = 'UK01';
            update admin;

            response = SFO_CustomLinksController.getCustomLinksData('test', new List<String>{'test'});

            currentUser = (User)response.get('currentUser');
            System.assertEquals('UK01', currentUser.Sales_Organisation__c);
            System.assertEquals(UserInfo.getUserId(), currentUser.Id);

            //We expect 3 links as user has UK01 sales org and he is an industrial user
            links = (List<SFO_Custom_Link__mdt>)response.get('links');
            System.assertEquals(4, links.size());

            //aura handled error.
            service = new ErrorMockService();
            SFO_CustomLinksController.LinkService = service;

            try {
                response = SFO_CustomLinksController.getCustomLinksData('test', new List<String>{'test'});
                System.assert(false, 'Expecting AuraHandledException ...');
            } catch(System.AuraHandledException ex) {
                System.assert(true);
            }
    }

    @IsTest
    private static void itShouldGetCurrentUser() {
        SFO_CustomLinksService service = new LinkMockService();

        Test.startTest();
            User currentUser = service.getUserInfo(UserInfo.getUserId());
            System.assertNotEquals(null, currentUser);
            System.assertEquals(UserInfo.getUserId(), currentUser.Id);
    }

    @IsTest
    private static void itShouldGenerateValidInQuery() {
        SFO_CustomLinksService service = new SFO_CustomLinksService();
        Set<String> data = new Set<String>{'captain', 'marvel'};
        String expectedInQuery = '(\'captain\', \'marvel\')';

        Test.startTest();
            String result = service.generateInQuery((Iterable<String>)data);
            System.assertEquals(expectedInQuery, result);
    }

    private class MockException extends Exception {}
}