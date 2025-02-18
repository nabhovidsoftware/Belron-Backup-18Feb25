/** @description : This test class is used to cover testcoverage for BLN_SearchAndGetMotoristController..
*   @Story : FOUK-1175
*   @author: Shailendra Tiwari (PwC)
*   @CreatedDate: 25-11-2023
*/

@isTest
public class BLN_SearchAndGetMotoristControllerTest {
  
/*  *@description:This method is used to test BLN_SearchAndGetMotoristController's createAccount method  .
    
*/
    @TestSetup
    public static void setupTestData () {
        Account testAccount = BLN_TestDataFactory.createAccountforAPI();
        testAccount.FirstName ='Nominated Person';
        insert testAccount;
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        INSERT caseObj;
    }


    @isTest
    static void testSearchAndGetMotoristsEx() {

        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;
         String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        User adminUser = new User(
            UserroleId =role,
            ProfileId = adminProfileId,
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
            Account testAccount1 = [Select Id, Name, firstname, lastname, PersonEmail, PersonMobilephone, BLN_PreferredContactMethod__c, PersonMailingStreet, PersonMailingPostalCode, PersonMailingState, PersonMailingCountry, PersonMailingCity, recordtypeId from Account LIMIT 1];
            Case caseObj = [Select Id from Case LIMIT 1];

           // BLN_SearchAndGetMotoristController.MotoristWrapper wrap = new BLN_SearchAndGetMotoristController.MotoristWrapper();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // List<BLN_SearchAndGetMotoristController.MotoristWrapper> result = BLN_SearchAndGetMotoristController.searchAndGetMotorists(testAccount1.FirstName,testAccount1.LastName,testAccount1.PersonEmail,testAccount1.PersonMobilephone, 'Nominated Person'  );
        // BLN_SearchAndGetMotoristController.createAccount(wrap,'Nominated Person',caseObj.Id, false);
        // BLN_SearchAndGetMotoristController.createAccount(wrap,'Nominated Person', testAccount1.Id, true);
        BLN_SearchAndGetMotoristController.MotoristWrapper motoristWrap = new BLN_SearchAndGetMotoristController.MotoristWrapper();
         List<BLN_SearchAndGetMotoristController.MotoristWrapper> result = BLN_SearchAndGetMotoristController.searchAndGetMotorists(motoristWrap);
        BLN_SearchAndGetMotoristController.createAccount(motoristWrap,caseObj.Id, false);
        BLN_SearchAndGetMotoristController.createAccount(motoristWrap, testAccount1.Id, true);
        Test.stopTest();
        System.assertNotEquals(0, result.size(),'result is not empty');
        }
        
    }

     @isTest
    static void testSearchAndGetMotorists() {

        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;
         String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        User adminUser = new User(
            UserroleId =role,
            ProfileId = adminProfileId,
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
            Account testAccount1 = [Select Id, Name, firstname, lastname, PersonEmail, PersonMobilephone, BLN_PreferredContactMethod__c, PersonMailingStreet, PersonMailingPostalCode, PersonMailingState, PersonMailingCountry, PersonMailingCity, recordtypeId from Account LIMIT 1];
            Case caseObj = [Select Id from Case LIMIT 1];

           // BLN_SearchAndGetMotoristController.MotoristWrapper wrap = new BLN_SearchAndGetMotoristController.MotoristWrapper();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // List<BLN_SearchAndGetMotoristController.MotoristWrapper> result = BLN_SearchAndGetMotoristController.searchAndGetMotorists(testAccount1.FirstName,testAccount1.LastName,testAccount1.PersonEmail,testAccount1.PersonMobilephone, 'Nominated Person'  );
        // BLN_SearchAndGetMotoristController.createAccount(wrap,'Nominated Person',caseObj.Id, false);
        // BLN_SearchAndGetMotoristController.createAccount(wrap,'Nominated Person', testAccount1.Id, true);
        BLN_SearchAndGetMotoristController.MotoristWrapper motoristWrap = new BLN_SearchAndGetMotoristController.MotoristWrapper();
         List<BLN_SearchAndGetMotoristController.MotoristWrapper> result = BLN_SearchAndGetMotoristController.searchAndGetMotorists(motoristWrap);
        BLN_SearchAndGetMotoristController.createAccount(null,caseObj.Id, false);
        BLN_SearchAndGetMotoristController.createAccount(null, testAccount1.Id, true);
        Test.stopTest();
        System.assertNotEquals(0, result.size(),'result is not empty');
        }
        
    }

/*  *@description:This method is used to test BLN_SearchAndGetMotoristController's searchAndGetMotorists method  .
    *return : void
*/
    @isTest
    static void testSearchNegativeAndGetMotorists() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        BLN_SearchAndGetMotoristController.MotoristWrapper motoristWrap = new BLN_SearchAndGetMotoristController.MotoristWrapper();
        List<BLN_SearchAndGetMotoristController.MotoristWrapper> result = BLN_SearchAndGetMotoristController.searchAndGetMotorists(motoristWrap);
       // List<BLN_SearchAndGetMotoristController.MotoristWrapper> result = BLN_SearchAndGetMotoristController.searchAndGetMotorists('TestFirstName','TestLastName','test@test.com', '9878787879','Nominated');
        Test.stopTest();
        System.assertEquals(1, result.size(),'result is not empty');
        
    }
       
/*  *@description:This method is used to generate mock response for callout.
    *return : response
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
    
/*  *@description:This method is used to generate mock response for callout.
    *return : response
*/  
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"data": [{"firstName": "John", "lastName": "Doe", "primaryEmail": "john@example.com", "primaryContactNumber": "1234567890", "mdmMotoristId": "12345", "title": "Mr.", "homeStreet": "123 Main St", "homePostalCode": "12345", "homeState": "CA", "homeCountry": "USA", "homeTown": "Anytown", "suffix":"MR", "preferredName": "Testdemo","middleName":"JO", "personType":"Nominated"}]}');
            return res;
        }

    }
    @isTest
    static void testCallExternalAPISuccess() {
        // Test data setup
        BLN_SearchAndGetMotoristController.MotoristWrapper motoristWrap = new BLN_SearchAndGetMotoristController.MotoristWrapper();
        motoristWrap.firstName = 'John'; 
        motoristWrap.lastName = 'Doe';
        motoristWrap.primaryEmail = 'john@example.com';
        motoristWrap.mobilePhone = '1234567890';

        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        List<BLN_SearchAndGetMotoristController.MotoristWrapper> result = BLN_SearchAndGetMotoristController.callExternalAPI(motoristWrap);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Expected');
    }

    @isTest
    static void testNegativeSearchAndGetMotorists() {
        // Test data setup
        BLN_SearchAndGetMotoristController.MotoristWrapper testMotorist = new BLN_SearchAndGetMotoristController.MotoristWrapper();
        testMotorist.firstName = 'Johnn';
        testMotorist.lastName = 'Doee';
        testMotorist.primaryEmail = 'johnn.doe@example.com';
        testMotorist.mobilePhone = '1204567890';

        Account testAccount = new Account(
            FirstName = testMotorist.firstName,
            LastName = testMotorist.lastName,
            PersonEmail = testMotorist.primaryEmail,
            PersonMobilePhone = testMotorist.mobilePhone,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
        );
        insert testAccount;

        Test.startTest();
        List<BLN_SearchAndGetMotoristController.MotoristWrapper> result = BLN_SearchAndGetMotoristController.searchAndGetMotorists(testMotorist);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        // System.assertEquals(1, result.size(), 'Result size should be 1');

        // // Verify the content of returned wrapper
        // MotoristWrapper returnedMotorist = result[0];
        // System.assertEquals(testMotorist.firstName, returnedMotorist.firstName, 'First name should match');
        // System.assertEquals(testMotorist.lastName, returnedMotorist.lastName, 'Last name should match');
        // System.assertEquals(testMotorist.primaryEmail, returnedMotorist.primaryEmail, 'Primary email should match');
        // System.assertEquals(testMotorist.mobilePhone, returnedMotorist.mobilePhone, 'Mobile phone should match');
    }
    
    
}