/** @description : BLN_AuthenticationRequestTest Class used for testing BLN_AuthenticationRequest.
*   @author: Sourabh Bhattacharjee
*   @Story: FOUK-10605
*   @Created Date: 06/06/2024
*/
@isTest
private class BLN_AuthenticationRequestTest {
    @testSetup
    static void setupTestData() {
        Contact con = BLN_TestDataFactory.getContact('test');
        insert con;

        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;

        Case cases = BLN_TestDataFactory.getCase('Job Request', 'New');
        cases.ContactId = con.Id;
        cases.BLN_Vehicle__c = veh.Id;
        insert cases;

        BLN_Payment__c testPayment = BLN_TestDataFactory.createPayments( );
        testPayment.BLN_PaymentAmountTaken__c = 250;
    testPayment.BLN_Case__c = cases.Id;
    testPayment.BLN_InitiatedBy__c = 'Portal';
    testPayment.BLN_InitiatedDateTime__c = Datetime.now();
    testPayment.BLN_PaymentStatus__c = 'Initiated';
    testPayment.BLN_Status__c = 'Initiated';
    testPayment.BLN_PaymentType__c = 'Online Payment';
    testPayment.BLN_WorldPay_Token__c = 'testtoken';
    testPayment.BLN_challengereference__c = 'test';
    insert testPayment;
    }

    @isTest
    static void testPerformCallout() {
        // Define mock HTTP response
        HttpCalloutMock mock = new BLN_AuthenticationRequestMock();
        Test.setMock(HttpCalloutMock.class, mock);

        // Retrieve test data
        List<BLN_Payment__c> testPayment = [SELECT Id FROM BLN_Payment__c LIMIT 1];
        if(!testPayment.isEmpty()){
        Decimal amount = 100.00;

      /*Map<String, String> devicedata = new Map<String, String>{
    'collectionReference' => '0_3XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX6b5',
    'acceptHeader' => 'text/html',
    'userAgentHeader' => 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0)',
    'browserLanguage' => 'en-GB',
    'ipAddress' => '192.0.0.0'
};*/
        
        // Call the method to test
        Test.startTest();
        Map<String, String> returnmap = BLN_AuthenticationRequest.performCallout(testPayment[0].Id, amount, 'testtoken','','');
        Test.stopTest();

        // Assert the response
        System.assertEquals('challenged', returnmap.get('outcome'), 'Expected outcome to be challenged');
        // Add more assertions as needed
        }}

    private class BLN_AuthenticationRequestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"outcome":"challenged","transactionReference":"Memory265-13/08/1876","authentication":{"version":"2.1.0"},"challenge":{"reference":"123456789","url":"https://ChallengePageUrl.example.com","jwt":"VGhpcyBpcyBhIGJhc2UgNjQgZW5jb2RlZCBleGFtcGxlIG9mIGEgM0RTICJwYXlsb2FkIg==","payload":"eyJtZXNzYWdlVHlwZSI6IkNSZXEiLCJtZXNzYWdlVmVyc2lvbiI6IjIuMS4wIiwidGhyZWVE"},"_links":{"3ds:verify":{"href":"https://try.access.worldpay.com/verifications/customers/3ds/verification"},"curies":[{"href":"https://try.access.worldpay.com/rels/verifications/customers/3ds/{rel}","templated":true,"name":"3ds"}]}}');
            res.setStatusCode(200);
            return res;
        }
    }
}