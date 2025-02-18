/** @description : Test class for BLN_APICalloutPublisherTriggerHandler.
*   @Story : FOUK-867
*   @author: Shubhangi Patil (PwC)
*   @CreatedDate: 27/11/2023
*/
@isTest
public class BLN_APICalloutTriggerHandlerTest {
    private Static Id accountRecordID=schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    
/*  *@description: This method is used to test BLN_APICalloutPublisherTriggerHandler's syncMotoristDatawithMDM method.
    *return : void
*/
    @isTest
    static void testSyncMotoristDatawithMDM() {
         String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;
        User adminUser = new User(
            ProfileId = adminProfileId,
            UserroleId =role,
            FirstName = 'PS',
            LastName = 'Test User',
            UserName = System.now().getTime() + '@test.demo',
            Alias = 'pstes',
            Email = 'test@sample.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true); 
        insert adminUser;
        System.runAs(adminUser){
            List<BLN_APICalloutPublisher__e> events = new List<BLN_APICalloutPublisher__e>();
            Account testAccount = BLN_TestDataFactory.createAccountforAPI();
            insert testAccount;
            BLN_APICalloutPublisher__e testEvent = new BLN_APICalloutPublisher__e(
                BLN_ObjectName__c = 'Account',
                BLN_RecordId__c=testAccount.id,
                BLN_DMLEventType__c='Create'
            );
            events.add(testEvent);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            BLN_APICalloutPublisherTriggerHandler.syncMotoristDatawithMDM(events);
            System.assertNotEquals(null, testEvent,'testevent can not be null');
            Test.stopTest();
        }
    }
  
/*  *@description: This method is used to test BLN_APICalloutPublisherTriggerHandler's getEventType method.
    *return : void
*/
    static void testEventTypeCreate() {
        BLN_APICalloutPublisher__e testEvent = new BLN_APICalloutPublisher__e(BLN_DMLEventType__c = 'Create');
        String eventType = BLN_APICalloutPublisherTriggerHandler.getEventType(testEvent);
        System.assertEquals('Create', eventType,'event created');
    }
  
/*  *@description: This method is used to test BLN_APICalloutPublisherTriggerHandler's getEventType method negative scenario.
    *return : void
*/
    @isTest
    static void testEventTypenull() {
        BLN_APICalloutPublisher__e testEvent = new BLN_APICalloutPublisher__e(BLN_DMLEventType__c = 'Upsert');
        String eventType = BLN_APICalloutPublisherTriggerHandler.getEventType(testEvent);
        System.assertNOTEquals('Create', eventType,'event type is not created');
    }
    
/*  *@description: This method is used to test BLN_APICalloutPublisherTriggerHandler's getEventType method.
    *return : void
*/
    @isTest
    static void testEventTypeUpdate() {
        BLN_APICalloutPublisher__e testEvent = new BLN_APICalloutPublisher__e(BLN_DMLEventType__c = 'Update');
        String eventType = BLN_APICalloutPublisherTriggerHandler.getEventType(testEvent);
        System.assertEquals('Update', eventType, 'event updated');
    }

/*  *@description: This method is used to test BLN_APICalloutPublisherTriggerHandler's makeCallOut method.
    *return : void
*/
    @isTest
    static void testMakeCallOutSuccess() {
        Account testAccount = BLN_TestDataFactory.createAccountforAPI();
        String jsonResponse;
        insert testAccount;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        BLN_HTTPCallOutAccessToken.WrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();
        jsonResponse= BLN_APICalloutPublisherTriggerHandler.makeCallOut('{"key": "value"}',testAccount.Id);
        Test.stopTest();
        System.assertNotEquals(null, wrapperToken.accessToken,'Token can not be null');
    }

/*  *@description: This method is used to test BLN_APICalloutPublisherTriggerHandler's makeCallOut method nagative scenario.
    *return : void
*/
    @isTest      //(seeAllData=true)
    static void testMakeCallOutError() {
        Account testAccount = BLN_TestDataFactory.createAccountforAPI();
        String jsonResponse;
        insert testAccount;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        BLN_HTTPCallOutAccessToken.WrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();
        jsonResponse = BLN_APICalloutPublisherTriggerHandler.makeCallOut('null',null);
        Test.stopTest();
        System.assertNOTEquals(null, wrapperToken.accessToken,'Token can not be null');
    }
    
 /*  *@description: This method is used for Mock call out.
    *return : void
*/
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }
       
 /*  *@description: This method is used for Mock call out.
    *return : void
*/
    private class MockResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String contentType = 'application/x-www-form-urlencoded';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', contentType);
            res.setBody('{"access_token": "MockAccessToken123", "expires_in": 3600}');
            res.setStatusCode(200);
            return res;
        }
    }
 
    
}