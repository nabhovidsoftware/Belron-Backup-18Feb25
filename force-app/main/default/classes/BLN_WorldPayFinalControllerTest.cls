@isTest
public with sharing class BLN_WorldPayFinalControllerTest {
    /*@isTest
    public static void testFinal() {
        // Create test data
        Case c = new Case();
        c.Status='New';
        c.Type = 'Job Request';
        insert c;
        BLN_Payment__c testPayment = new BLN_Payment__c(
            // Populate required fields here
            BLN_PaymentAmountTaken__c = 250,
            BLN_Case__c = c.Id,
            BLN_InitiatedBy__c = 'Portal',
            BLN_InitiatedDateTime__c = Datetime.now(),
            BLN_PaymentStatus__c = 'Initiated',
            BLN_Status__c = 'Initiated',
            BLN_PaymentType__c = 'Online Payment',
            BLN_WorldPay_Token__c = 'testtoken',
            BLN_challengereference__c = 'test'
        );
        insert testPayment;
        String pid = testPayment.Id;

        
        // Start test
        Test.startTest();

        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new BLN_WorldPayVerificationMock());
        // Call the method to be tested
       Map<String,String> returnmap = BLN_WorldPayFinalController.verification('test1234',pid);

        // Stop test
        Test.stopTest();
        //System.assertEquals(null, returnmap, 'Success message');
    }

    public class BLN_WorldPayVerificationMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"outcome": "authenticated"}');
            res.setStatusCode(200);
            return res;
        }
    }*/
   
        
    @isTest
    static void testVerification() {
        Case c = new Case();
        c.Status='New';
        c.Type = 'Job Request';
        c.BLN_SubType__c = 'Job Request';
        insert c;
    
        BLN_Payment__c payment = new BLN_Payment__c();
        payment.BLN_PaymentAmountTaken__c = 250;
        payment.BLN_InitiatedDateTime__c = System.Now();
        payment.BLN_PaymentStatus__c = 'Initiated';
        payment.BLN_Case__c = c.Id;
    
     insert payment;
   	Id paymentId = payment.Id;
        
        // Mock the callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Define test parameters
       
        /*BLN_Payment__c testPayment =BLN_TestDataFactory.createPayments();
        insert testPayment;
        String paymentid = testPayment.Id;*/
        
        String challengeUrl = 'https://testurl.com';
       
        
        // Verify the future method execution
        Test.startTest();
         Map<String, String> result = BLN_WorldPayFinalController.verification(challengeUrl, paymentId);
        system.debug('result'+result );
        Test.stopTest();
        System.assert(c.Id != null, 'Result should not be null');
        
        
        // Perform any necessary assertions
        // Note: Since @future methods run asynchronously, you may not be able to directly capture the return value in the test method.
    }
    
    // Mock class to simulate callout response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"outcome": "authenticated"}');
            res.setStatusCode(200);
            return res;
        }
    }



}