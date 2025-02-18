/** @description : Test class for BLN_WorldPayVerification.
*   @Story : FOUK-6328
*   @author:Abhishek Puranik
*   @CreatedDate:
*/
@isTest
public class BLN_WorldPayVerificationTest {

   /* @isTest
    public static void testPerformCallout() {
        // Create test data
        BLN_Payment__c testPayment =BLN_TestDataFactory.createPayments();
        insert testPayment;
        
        BLN_Payment__c p =[SELECT ID FROM BLN_Payment__c WHERE ID=:testPayment.Id];
        System.debug(testPayment.Id+'Payment test data--->'+p);
        if(p!=null){
    p.BLN_WorldPay_Token__c='ABCD123';
    p.BLN_PaymentAmountTaken__c = 100;
    p.BLN_PaymentId__c = 'abc353';
    //sa.BLN_RebookedServiceAppointment__c  = rebookId;
    }
    Database.update(p, false);
        // Start test
        Test.startTest();

        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new BLN_WorldPayVerificationMock());
        // Call the method to be tested
        Map<String,String> returnmap = BLN_WorldPayVerification.performCallout(p.Id);
        // Stop test
        Test.stopTest();

        // Add assertions here to verify the behavior of the method
       // System.assertEquals(null, returnmap, 'Success message');
    }*/

     @isTest
    public static void testPerformCallout2() {
        // Create test data

        BLN_Payment__c testPayment =BLN_TestDataFactory.createPayments();
        insert testPayment;

        // Start test
        Test.startTest();

        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new BLN_WorldPayVerificationMock2());

        // Call the method to be tested
        
        Map<String,String> returnmap = BLN_WorldPayVerification.performCallout(testPayment.Id);
	//	Map<String,String> returnmap1 = BLN_WorldPayVerification.performCallout(null);
        // Stop test
        Test.stopTest();

        // Add assertions here to verify the behavior of the method
        System.assert(returnmap!= null, 'Success message');
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
}

public class BLN_WorldPayVerificationMock2 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"outcome": "notauthenticated"}');
        res.setStatusCode(200);
        return res;
    }
}
}