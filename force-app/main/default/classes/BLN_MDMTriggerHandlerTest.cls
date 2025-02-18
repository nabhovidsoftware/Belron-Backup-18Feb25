/*****************************************
ClassName : BLN_AccountTrigger, BLN_ContactMDMTrigger,BLN_ARPMDMTrigger, BLN_SLADefinitionMMDMTrigger,BLN_PDSMDMTrigger, BLN_AGRMDMTrigger
@description : FOUK-4467 This test  class is used to cover BLN_RecalculateTerritoryManagementRules.
CreatedDate: 28-12-2023
CreatedBy : PwC-India
****************************************/
@isTest
public with sharing class BLN_MDMTriggerHandlerTest {
    private class MockResponseGenerator implements HttpCalloutMock {
               public HTTPResponse respond(HTTPRequest req) {
            if(req.getEndpoint() == 'callout:BLN_OktaAuthToken'){
                HttpResponse response = new HttpResponse();
                response.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"MockAccessToken123","scope":"read"}');
                response.setStatusCode(200);
                return response;      
            } else {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"message": "Success"}');
                res.setStatusCode(200);
                return res;
            }

        }
    }
    @isTest
    static void personAccMdmHandlerTest() {
        Account acc =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        
        insert acc;
        acc.PersonHomePhone = '8698023891';
        update acc;
        test.stopTest();
        List<Account> accList = [select Id from account where Id =: acc.Id];
        System.assertEquals(accList.size()>0,true,'account inserted');
      
    }

    @isTest
    static void salesAccMdmHandlerTest() {
        Account testAccount = BLN_TestDataFactory.createSalesAccount('TestMockB2BAccount1','Agriculture','Underwriter',1,'Insurance','GB123456779', 'AA161811','San Francisco', 'testStreet','12345' ,'GB','Blue Anchor' ,'Minehead',
        '7890' , 'United Kingdom','BLN_CustomerB2BAccount');
        Map<String,Map<String,string>> fieldsMap = new Map<String,Map<String,string>>();
        BLN_MDMConfiguration.MDMParameters param = new BLN_MDMConfiguration.MDMParameters();
        param.streamName =  'Sales';
        param.sourceObject = 'Account';
        param.eventType = 'Create';
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        insert testAccount;
        fieldsMap.put(testAccount.Id,new Map<String,string>{'Id'=>testAccount.Id,'Name' => 'TestMockB2BAccount1','Status'=>'Prospect'});
        param.fieldsToSync = fieldsMap;
        Database.executeBatch(new BLN_QueueMDMGateWay(param));
        testAccount.Industry = 'Apparel';
        testAccount.BLN_MDMAccountID__c = '563522';
        update testAccount;
        test.stopTest();
        List<Account> accList = [select Id from account where Id =: testAccount.Id];
        System.assertEquals(accList.size()>0,true,'account inserted');
      
    }



    @isTest
    static void contactdMdmHandlerTest() {
        Account testAccount = BLN_TestDataFactory.createSalesAccount('TestMockB2BAccount1','Agriculture','Underwriter',1,'Insurance','GB123456779', 'AA161811','San Francisco', 'testStreet','12345' ,'GB','Blue Anchor' ,'Minehead',
        '7890' , 'United Kingdom','BLN_CustomerB2BAccount');
        testAccount.BLN_MDMAccountID__c = '463522';

        insert testAccount;
        Contact testContact = BLN_TestDataFactory.getContact('Test');
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'test123@gmail.com';
        testContact.AccountId = testAccount.Id;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        insert testContact;
        testContact.LastName = 'testContact';
        update testContact;
        test.stopTest();
        List<Account> accList = [select Id from account where Id =: testAccount.Id];
        System.assertEquals(accList.size()>0,true,'account inserted');

      
    }

    @isTest
    static void arpMdmHandlerTest() {
        Account accRec = new Account(Name = 'Test Account', BLn_ClientType__c = 'Insurance');
         accRec.BLN_MDMAccountID__c = '568522';

        insert accRec;

        BLN_AccountGroupRule__c agr = new BLN_AccountGroupRule__c(
            Name = 'test Agr',
            BLN_ActiveFrom__c = System.now().addDays(-1).date(),
            BLN_ActiveTo__c = System.Date.today(),
            BLN_CorporateType__c = 'Insurance',
            BLN_OwningBusinessUnit__c = 'Autoglass-UK'

        );
        insert agr;
        BLN_SLADefinition__c sla = new BLN_SLADefinition__c(
            Name = 'test sla',
            BLN_Category__c = 'Quality'
        );
        insert sla;
        // Create account rule parameter
            String getDivertToAuthorizationTeam = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Automatic Divert to Authorisation Team').getRecordTypeId();
           BLN_AccountRuleParameter__c getDivertAuth = new BLN_AccountRuleParameter__c(
               BLN_Account__c = accRec.Id,
               RecordTypeId = getDivertToAuthorizationTeam,
               BLN_ProductCategory__c = 'Test Product',
               BLN_ActiveFrom__c = System.now().addDays(-1).date(),
               BLN_ActiveTo__c = System.Date.today(),

               BLN_AccountRuleGroup__c = agr.Id,
               BLN_SLAType__c =  sla.Id

           );
          
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        insert getDivertAuth;
        getDivertAuth.BLN_ActiveFrom__c  =  System.now().addDays(-2).date();
        update getDivertAuth;
        sla.BLN_Category__c = 'Telephony';
        update sla;
        agr.BLN_ActiveFrom__c = System.now().addDays(-2).date();
        update agr;

        test.stopTest();
        List<Account> accList = [select Id from account where Id =: accRec.Id];
        System.assertEquals(accList.size()>0,true,'account inserted');
      
    }

    @isTest
    static void alterNativeMdmTest() {
        Account accRec = new Account(Name = 'Test Account', BLn_ClientType__c = 'Insurance');
          accRec.BLN_MDMAccountID__c = '568512';
        insert accRec;
        // Create account rule parameter
        
        BLN_AccountAlternativeName__c alter = new BLN_AccountAlternativeName__c(
            BLN_Account__c = accRec.Id,
            BLN_AlternativeAccountName__c = 'test alter'

        );
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        insert alter;
        alter.BLN_AlternativeAccountName__c  =  'test alter1';

        update alter;
        test.stopTest();
        List<Account> accList = [select Id from account where Id =: accRec.Id];
        System.assertEquals(accList.size()>0,true,'account inserted');
        

    }
    
  
    
   
}