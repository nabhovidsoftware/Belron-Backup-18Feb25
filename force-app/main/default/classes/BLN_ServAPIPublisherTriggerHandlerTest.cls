/** @description : Test class for BLN_ServCertAPIPublisherTriggerHandler.
*   @Story : FOUK-4365
*   @Author: PwC-India
*   @CreatedDate: 11/01/2024
*/
@isTest
public class BLN_ServAPIPublisherTriggerHandlerTest {
    /**
* @description Sets up test data for the test methods
*/
    @TestSetup
    static void setupTestData() {
        // Create common test data
        ServiceTerritory services = BLN_TestDataFactory.createServiceTerritories('Test Certainty', true);
        WorkType types = BLN_TestDataFactory.createWorkType('test certainty', true);
        BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();
        Account testAcc = BLN_TestDataFactory.createTestAccount();
        testAcc.FirstName = 'Test';
        testAcc.LastName = 'Contact';
        testAcc.PersonEmail = 'test123@gmail.com';
        insert testAcc;
        
        Contact testContact = BLN_TestDataFactory.getContact('Test');
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'test123@gmail.com';
        insert testContact;
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.AccountId = testAcc.Id;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000;
        insert cse;
        
        WorkOrder works = BLN_TestDataFactory.createWorkOrder2(types.id, services.id, true);
        works.AccountId = testAcc.Id;
        works.CaseId = cse.Id;
        works.ContactId = testContact.Id;
        update works;
        
        ServiceAppointment sA = new ServiceAppointment();
        sA.ContactId = testContact.Id;
        sA.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA.Duration = 1;
        sA.BLN_Vehicle__c = vehicles.Id;
        sA.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA.Status = 'Completed';
        sA.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.ParentRecordId = works.Id;
        sA.BLN_WorkOrderNumber__c = works.Id;
        insert sA;
    }
    
    /*****************************************
MethodName : testPositive
@description : This method is used to test BLN_ServCertAPIPublisherTriggerHandler class.
Input Parameter : 
Output Parameter : void
CreatedDate: 11-01-2024
CreatedBy : Pwc-India
Change log :
****************************************/
     @isTest
    static void testPositive() {
        /* @description: testPositive method is used to test the Positive Scenarios of Apex Class BLN_ServCertAPIPublisherTriggerHandler */
        List<String> recordId = new List<String>();
        recordId.add([SELECT Id FROM ServiceAppointment LIMIT 1].Id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseToken());
        // Call the method to be tested
        BLN_ServCertAPIPublisherTriggerHandler.syncCasewithServCertainty(recordId);
        // Add assertions to validate results
        Case cse = [SELECT BLN_VRN__c,BLN_ApplicationImpacted__c FROM Case LIMIT 1];
        System.assertEquals(null, cse.BLN_ApplicationImpacted__c, 'BLN_ServCertId__c should be populated');
        Test.stopTest();
    }
    
    /*****************************************
MethodName : testNegative
@description : This method is used to test BLN_ServCertAPIPublisherTriggerHandler class.
Input Parameter : 
Output Parameter : void
CreatedDate: 11-01-2024
CreatedBy : Pwc-India
Change log :
****************************************/
    @isTest
    public static void testNegative(){
        /* @description: testNegative method is used to test the Negative Scenarios of Apex Class BLN_ServCertAPIPublisherTriggerHandler */
        List<String> recordId = new List<String>();
        recordId.add([SELECT Id FROM ServiceAppointment LIMIT 1].Id);
        
        Test.startTest();
        // Call the method to be tested
        BLN_ServCertAPIPublisherTriggerHandler.syncCasewithServCertainty(recordId);
        // Add assertions to validate results
        Case cse = [SELECT BLN_ApplicationImpacted__c FROM Case LIMIT 1];
        System.assertEquals(null, cse.BLN_ApplicationImpacted__c, 'BLN_ServCertId__c should be populated');
        Test.stopTest();
    }
    
    /*****************************************
MethodName : testNegative1
@description : This method is used to test BLN_ServCertAPIPublisherTriggerHandler class.
Input Parameter : 
Output Parameter : void
CreatedDate: 11-01-2024
CreatedBy : Pwc-India
Change log :
****************************************/
    @isTest
    public static void testNegative1(){
        /* @description: testNegative1 method is used to test the Negative Scenarios of Apex Class BLN_ServCertAPIPublisherTriggerHandler */
        List<String> recordId = new List<String>();
        recordId.add('sA.id');
        
        Test.startTest();
        // Call the method to be tested
        BLN_ServCertAPIPublisherTriggerHandler.syncCasewithServCertainty(recordId);
        // Add assertions to validate results
        System.assertEquals('sA.id', recordId[0], 'BLN_ServCertId__c should be populated');
        Test.stopTest();
    }
    
    /*  *@description: This method is used for Mock call out.
    *return : void
*/
    private class MockResponseToken implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String json=		'{'+
		'    "glassDamageDocumentID": "a2fbfb78-8372-4788-b669-36b0d1887e2c",'+
		'    "uploadURL": "https://2000/clientportal/a2fbfb78-8372-4788-b669-36b0d1887e2c"'+
		'}';
            if (req.getEndpoint() == 'callout:BLN_OktaAuthToken') {
            HttpResponse response = new HttpResponse();
            response.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"eyJraWQiOiJEcXBZVndSVVh3Vmo1SHVSb0xtZ0N3T2J4b1pDNUZsQUxRQjlEMmJPR1NFIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULmtUaTh3cFItR3ZwdlhSSGJ0V3pNU1hjc0tsOHVXUmxqbFZiS21VT2xobzAiLCJpc3MiOiJodHRwczovL2JlbHJvbi1xYS5va3RhcHJldmlldy5jb20vb2F1dGgyL2F1czN5NGQ2MThmb1hRY0ZhMHg3IiwiYXVkIjoiYXBpOi8vand0YXV0aCIsImlhdCI6MTY5NzIwNDU4OSwiZXhwIjoxNjk3MjA4MTg5LCJjaWQiOiIwb2EzeTRlM2dvTzdrUWlaYTB4NyIsInNjcCI6WyJyZWFkIl0sInN1YiI6IjBvYTN5NGUzZ29PN2tRaVphMHg3In0.IqHWRVQAm2eW0NAeORb2rJO_jyHrq1-cdeCDjg4yiZXZQVc0vL1EqT1to4zdSj_yNQmGeRYPFActpY73HE6CN_YQNZ8AeoJ462bReuwb9VuL0RBCqxG68J2p2K4sfBElh4S4tKQhPG-K7W7QjaWMmqYk9bluRrWb_ye7tV9IeuzE9fGO6knM6zlMtTcEX0IIoO1oTEudeVsYCymy24vMCSRbzMg05Bexxj9CQ4Q2XqU016PiYBd5giWP5h3ko_6AXTyQv4JUy-C2YW2x5toiqJqUW5kZtNjrB8IkGnMRNXxvGX5yKZjivyTrU6KCSPNU3GE-rNpbjPRIKB8P2KG2Pg","scope":"read"}');
            response.setStatusCode(200);
                return response;  
        }else{
            HttpResponse response = new HttpResponse();
            response.setBody(json);
            response.setStatusCode(200);
            return response; 
        }
        }
    }
}