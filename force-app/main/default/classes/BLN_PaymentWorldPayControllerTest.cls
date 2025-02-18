/*****************************************
ClassName : BLN_PaymentWorldPayControllerTest
Description : This class is used as a Test Class of BLN_PaymentWorldPayController.
CreatedBy : Pwc-India
****************************************/
@isTest
private class BLN_PaymentWorldPayControllerTest {
    /*****************************************
MethodName : testJwtProperty
Description : This is test method.
****************************************/    
    @isTest
static void testJwtProperty() {
    BLN_PaymentWorldPayController.jwt = 'testJwt';
    System.assertEquals('testJwt', BLN_PaymentWorldPayController.jwt,'test');
}

        /*****************************************
MethodName : testUrlProperty
Description : This is test method.
****************************************/
    @isTest
static void testUrlProperty() {
    BLN_PaymentWorldPayController.url = 'testUrl';
    System.assertEquals('testUrl', BLN_PaymentWorldPayController.url,'test');
}

        /*****************************************
MethodName : testBinProperty
Description : This is test method.
****************************************/
@isTest
static void testBinProperty() {
    BLN_PaymentWorldPayController.bin = 'testBin';
    System.assertEquals('testBin', BLN_PaymentWorldPayController.bin,'test');
}

        /*****************************************
MethodName : testShowCheckoutProperty
Description : This is test method.
****************************************/
    @isTest
static void testShowCheckoutProperty() {
    BLN_PaymentWorldPayController.showcheckout = true;
    System.assertEquals(true, BLN_PaymentWorldPayController.showcheckout,'test');
}

        /*****************************************
MethodName : testShowDDCProperty
Description : This is test method.
****************************************/
    @isTest
static void testShowDDCProperty() {
    BLN_PaymentWorldPayController.showDDC = true;
    System.assertEquals(true, BLN_PaymentWorldPayController.showDDC,'test');
}


        /*****************************************
MethodName : testTokenProperty
Description : This is test method.
****************************************/
@isTest
static void testTokenProperty() {
    BLN_PaymentWorldPayController.token = true;
    System.assertEquals(true, BLN_PaymentWorldPayController.token,'test');
}

        /*****************************************
MethodName : testPaymentIdProperty
Description : This is test method.
****************************************/
@isTest
static void testPaymentIdProperty() {
    BLN_PaymentWorldPayController.paymentid = true;
    System.assertEquals(true, BLN_PaymentWorldPayController.paymentid,'test');
}

        /*****************************************
MethodName : testChallengeUrlProperty
Description : This is test method.
****************************************/
@isTest
static void testChallengeUrlProperty() {
    BLN_PaymentWorldPayController.challengeUrl = 'testChallengeUrl';
    System.assertEquals('testChallengeUrl', BLN_PaymentWorldPayController.challengeUrl,'test');
}

        /*****************************************
MethodName : testChallengejwtTokenProperty
Description : This is test method.
****************************************/
     @isTest
    static void testChallengejwtTokenProperty() {
        BLN_PaymentWorldPayController.jwtToken = 'testjwtToken';
        System.assertEquals('testjwtToken', BLN_PaymentWorldPayController.jwtToken,'test');
    }
    

        /*****************************************
MethodName : testChallengeProperty
Description : This is test method.
****************************************/
    @IsTest
    static void testChallengeProperty() {
        // Create an instance of the class you want to test
        BLN_PaymentWorldPayController instance = new BLN_PaymentWorldPayController();
        instance.challenge = 'Test Challenge';
        System.assertEquals('Test Challenge', instance.challenge, 'Challenge property should be set correctly');
        instance.challenge = 'Another Challenge';
        System.assertEquals('Another Challenge', instance.challenge, 'Challenge property should be updated correctly');
    }

        /*****************************************
MethodName : testGenerateToken
Description : This is test method.
****************************************/
@isTest
static void testGenerateToken() {
    // Test data setup
    String sessionId = 'session123';
    String fullname = 'ABCDEFG';
        String said = 'said';
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
        //Decimal amount = 250;

    // Mock HTTP callout
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Call the method to test
        Test.startTest();
        BLN_PaymentWorldPayController.generateToken(sessionId, paymentId,fullname,said);
        Test.stopTest();
    System.assert(paymentId != null, 'paymentId ID Should not be null');
        // Verify the results
    //System.assertEquals(null, result.get('outcome'), 'Test');
    // Add more assertions based on the expected behavior of your method
}

    
// Mock HTTP callout
private class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
            res.setBody('{"_embedded":{"verification":{"outcome":"verified","checkedAt":"2020-08-18T14:29:10.641180Z","riskFactors":[{"risk":"matched","type":"cvc"},{"risk":"matched","detail":"postcode","type":"avs"},{"risk":"matched","detail":"address","type":"avs"}],"paymentInstrument":{"type":"card/plain","card":{"expiryDate":{"month":5,"year":2035},"brand":"visa","fundingType":"debit","paymentAccountReference":"reference"}},"_links":{"verifications:verification":{"href":"https://try.access.worldpay.com/verifications/accounts/{resource}"},"curies":[{"href":"https://try.access.worldpay.com/rels/verifications/accounts/{rel}","name":"verifications","templated":true}]}},"token":{"tokenId":"9902480679618049603","description":"Test Token Description","tokenExpiryDateTime":"2021-08-18T14:30:40Z","tokenPaymentInstrument":{"type":"card/tokenized","href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0NzI0NE1rdUtjMUFJdjYxVnlibWZuUT0ifQ"},"paymentInstrument":{"type":"card/masked","cardNumber":"4444********1111","cardHolderName":"Sherlock Holmes","cardExpiryDate":{"month":5,"year":2035},"billingAddress":{"address1":"221B Baker Street","address2":"Marylebone","address3":"Westminster","postalCode":"NW1 6XE","city":"London","state":"Greater London","countryCode":"GB"},"bin":"444433","brand":"VISA"},"_links":{"tokens:token":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0NzI0NE1rdUtjMUFJdjYxVnlibWZuUT0ifQ"},"tokens:description":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0MWJVbkh1WTFGZExUNXJxc04va1ZoTFVzYW1OU1lxSFE2NHI1c2JkY1pWaSJ9"},"tokens:cardHolderName":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0d3ltd21ieGo3TlZLYzRYSkExOUhSdUpLN2N3VVc5WUk3czRUTW1RQ2JLdjFnVXlzakdPSXdWWkRhZkZyUmlMd3c9PSJ9"},"tokens:cardExpiryDate":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0d3ltd21ieGo3TlZLYzRYSkExOUhSdUpLN2N3VVc5WUk3czRUTW1RQ2JLdkVpVW5GNnBsZThNTXNQWTRGbzFzTXc9PSJ9"},"tokens:billingAddress":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0d3ltd21ieGo3TlZLYzRYSkExOUhSdFpSdXFxbWZlNVl1TkpHZEVvZXN3MTlCU0lmdCtxSTUyVDJSdXlmSTIwM3c9PSJ9"},"tokens:schemeTransactionReference":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoiSENXWFZQZjNIZ1V3dnpDMElJZS9Zdmc4M0pYM3dDWEJTVnQrWVlacXdDUXFFKzhzaC8xNSs2d3NkTTdFWUFNVU9tdXBmUlZGeVNDY2dPMkhKV2NIcGc9PSJ9"},"curies":[{"href":"https://try.access.worldpay.com/rels/tokens/{rel}.json","name":"tokens","templated":true}]}}}}');
        res.setStatusCode(200);
        return res;
    }
}


// Mock HTTP callout
// Mock HTTP callout for generateToken
private class MockHttpResponseGenerators implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"_embedded":{"verification":{"outcome":"verified","checkedAt":"2020-08-18T14:29:10.641180Z","riskFactors":[{"risk":"matched","type":"cvc"},{"risk":"matched","detail":"postcode","type":"avs"},{"risk":"matched","detail":"address","type":"avs"}],"paymentInstrument":{"type":"card/plain","card":{"expiryDate":{"month":5,"year":2035},"brand":"visa","fundingType":"debit","paymentAccountReference":"reference"}},"_links":{"verifications:verification":{"href":"https://try.access.worldpay.com/verifications/accounts/{resource}"},"curies":[{"href":"https://try.access.worldpay.com/rels/verifications/accounts/{rel}","name":"verifications","templated":true}]}},"token":{"tokenId":"9902480679618049603","description":"Test Token Description","tokenExpiryDateTime":"2021-08-18T14:30:40Z","tokenPaymentInstrument":{"type":"card/tokenized","href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0NzI0NE1rdUtjMUFJdjYxVnlibWZuUT0ifQ"},"paymentInstrument":{"type":"card/masked","cardNumber":"4444********1111","cardHolderName":"Sherlock Holmes","cardExpiryDate":{"month":5,"year":2035},"billingAddress":{"address1":"221B Baker Street","address2":"Marylebone","address3":"Westminster","postalCode":"NW1 6XE","city":"London","state":"Greater London","countryCode":"GB"},"bin":"444433","brand":"VISA"},"_links":{"tokens:token":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0NzI0NE1rdUtjMUFJdjYxVnlibWZuUT0ifQ"},"tokens:description":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0MWJVbkh1WTFGZExUNXJxc04va1ZoTFVzYW1OU1lxSFE2NHI1c2JkY1pWaSJ9"},"tokens:cardHolderName":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0d3ltd21ieGo3TlZLYzRYSkExOUhSdUpLN2N3VVc5WUk3czRUTW1RQ2JLdjFnVXlzakdPSXdWWkRhZkZyUmlMd3c9PSJ9"},"tokens:cardExpiryDate":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0d3ltd21ieGo3TlZLYzRYSkExOUhSdUpLN2N3VVc5WUk3czRUTW1RQ2JLdkVpVW5GNnBsZThNTXNQWTRGbzFzTXc9PSJ9"},"tokens:billingAddress":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0d3ltd21ieGo3TlZLYzRYSkExOUhSdFpSdXFxbWZlNVl1TkpHZEVvZXN3MTlCU0lmdCtxSTUyVDJSdXlmSTIwM3c9PSJ9"},"tokens:schemeTransactionReference":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoiSENXWFZQZjNIZ1V3dnpDMElJZS9Zdmc4M0pYM3dDWEJTVnQrWVlacXdDUXFFKzhzaC8xNSs2d3NkTTdFWUFNVU9tdXBmUlZGeVNDY2dPMkhKV2NIcGc9PSJ9"},"curies":[{"href":"https://try.access.worldpay.com/rels/tokens/{rel}.json","name":"tokens","templated":true}]}}}}');
        res.setStatusCode(201);
        return res;
    }
}
    
   /* @isTest
static void testVerification() {
    // Test data setup
        Case c = new Case(Status = 'New', Type = 'Job Request', BLN_SubType__c = 'Job Request');
    insert c;
    
    BLN_Payment__c payment = new BLN_Payment__c(
        BLN_PaymentAmountTaken__c = 250,
        BLN_InitiatedDateTime__c = System.Now(),
        BLN_PaymentStatus__c = 'Initiated',
        BLN_Case__c = c.Id
    );
    insert payment;
        String sessionId = 'session123';
        String fullname = 'ABCDEFG';
    Id paymentId = payment.Id;
    String challengeUrl = 'testUrl';
    String token;

    // Mock HTTP callout for BLN_WorldPayVerification
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerators());

    // Call the method to test
    Test.startTest();
        //Map<String, String> result = BLN_PaymentWorldPayController.generateToken(sessionId, paymentId, fullname);
        Test.stopTest();
        
        //System.assertEquals(null , result.get('outcome'), 'Result should not be null');
        //if (result != null ) {
        //System.assertEquals(null, result.get('key'), 'Expected key value not found in result');
        // }
        
        
    }*/

        /*****************************************
MethodName : testShowOutstandingBalance
Description : This is test method.
****************************************/
// Mock HTTP callout for BLN_WorldPayVerification
	@isTest
static void testShowOutstandingBalance() {
    // Test data setup
        Case c = new Case(Status = 'New', Type = 'Job Request', BLN_TotalMotoristLiability__c = 100,BLN_SubType__c = 'Job Request'); // Set outstanding balance to 100 for testing
    insert c;
    
    // Call the RemoteAction method
    Test.startTest();
    String outstandingBalance = BLN_PaymentWorldPayController.showoutstandingBalance(c.Id);
    Test.stopTest();
    
    // Verify the result
    System.assertEquals('100.00', outstandingBalance, 'Outstanding balance should match');
}

    
        /*****************************************
MethodName : testAuthorizeAPayment
Description : This is test method.
****************************************/
@isTest
static void testAuthorizeAPayment() {
    // Test data setup
        Case c = new Case();
        c.Status='New';
        c.Type = 'Job Request';
        C.BLN_SubType__c = 'Job Request';
        insert c;
    
        BLN_Payment__c payment = new BLN_Payment__c();
        payment.BLN_PaymentAmountTaken__c = 250;
        payment.BLN_InitiatedDateTime__c = System.Now();
        payment.BLN_PaymentStatus__c = 'Initiated';
        payment.BLN_Case__c = c.Id;
        insert payment;

        Id paymentId = payment.Id;
        Decimal amount = 250;
        String token = 'token123';

        // Mock HTTP callout for authorizeAPayment
        Test.setMock(HttpCalloutMock.class, new MockAuthorizePaymentHttpResponseGenerator());

    // Call the method to test
    Test.startTest();
        Map<String, String> result = BLN_PaymentWorldPayController.authorizeAPayment(String.valueOf(paymentId), token, amount,'123456******7654');
    Test.stopTest();

    // Verify the results
    System.assertEquals(null, result.get('outcome'), 'Outcome should be "Success"');
    // Add more assertions based on your requirements
}

// Mock HTTP callout for authorizeAPayment
    private class MockHttpResponseGeneratorss1 implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"refusalCode": null, "refusalDescription": null, "outcome": "Success"}');
        res.setStatusCode(201);
        return res;
    }
}
 @isTest
static void testAccName() {
   // Set the current user context to null
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Call the method under test
            String result = BLN_PaymentWorldPayController.getCurrentUserAccountName();
            
            // Verify the result when there is no current user
            System.assertEquals(null, result, 'Account name should be null when there is no current user');
        }
}

        /*****************************************
MethodName : testCreatePaymentRecord
Description : This is test method.
****************************************/
    @isTest
    static void testCreatePaymentRecord() {
        // Test data setup
        Id caseId = createTestRecord();
        
        // Call the method to test
        Test.startTest();
        Id paymentId = BLN_PaymentWorldPayController.createPaymentRecord('sessionId', caseId);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, paymentId, 'Test');
        // Add more assertions based on your requirements
    }
    
    // Helper method to create a test record
    static Id createTestRecord() {
        Case testCase = new Case(
            BLN_TotalMotoristLiability__c = 100.0, // Set the required fields
            Type = 'Job Request',
            BLN_SubType__c = 'Job Request'
            // Add more fields as needed
        );
        insert testCase;
        return testCase.Id;
    }

        /*****************************************
MethodName : testSaveToken
Description : This is test method.
****************************************/
@isTest
static void testSaveToken() {
    // Test data setup

 Case c1 = new Case();
        c1.Status='New';
        c1.Type = 'Job Request';
        c1.BLN_SubType__c = 'Job Request';
        insert c1;
    BLN_Payment__c paymentRecord = new BLN_Payment__c(
        // Populate necessary fields
         BLN_Case__c = c1.Id
         
    );
    insert paymentRecord;

    // Call the method
    Test.startTest();
        BLN_PaymentWorldPayController.saveToken(paymentRecord.Id, 'testToken','123456******7654');
    Test.stopTest();

    // Retrieve the updated record
    paymentRecord = [SELECT BLN_WorldPay_Token__c FROM BLN_Payment__c WHERE Id = :paymentRecord.Id];

    // Assertions
    System.assertEquals('testToken', paymentRecord.BLN_WorldPay_Token__c, 'Not Null');
    // Add more assertions if necessary
}
     /* @isTest
    static void testDisplayOutstandingBalances() {
        // Create a test Case record
        Case testCase = new Case(
            Subject = 'Test Case',
            BLN_TotalMotoristLiability__c = 100.00 // Set the outstanding balance
        );
        insert testCase;

        // Set the page parameters
        ApexPages.currentPage().getParameters().put('id', testCase.Id);

        // Instantiate the class
        BLN_PaymentWorldPayController controller = new BLN_PaymentWorldPayController();

        // Call the method
        //controller.displayoutstandingBalance();

        // Verify the results
        System.assertEquals('id',testCase.Id,'The outstanding balance should be set correctly.');
    }*/

    // Inner class to mock HTTP callout for generateToken
    private class MockGenerateTokenHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"_embedded":{"verification":{"outcome":"verified","checkedAt":"2020-08-18T14:29:10.641180Z","riskFactors":[{"risk":"matched","type":"cvc"},{"risk":"matched","detail":"postcode","type":"avs"},{"risk":"matched","detail":"address","type":"avs"}],"paymentInstrument":{"type":"card/plain","card":{"expiryDate":{"month":5,"year":2035},"brand":"visa","fundingType":"debit","paymentAccountReference":"reference"}},"_links":{"verifications:verification":{"href":"https://try.access.worldpay.com/verifications/accounts/{resource}"},"curies":[{"href":"https://try.access.worldpay.com/rels/verifications/accounts/{rel}","name":"verifications","templated":true}]}},"token":{"tokenId":"9902480679618049603","description":"Test Token Description","tokenExpiryDateTime":"2021-08-18T14:30:40Z","tokenPaymentInstrument":{"type":"card/tokenized","href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0NzI0NE1rdUtjMUFJdjYxVnlibWZuUT0ifQ"},"paymentInstrument":{"type":"card/masked","cardNumber":"4444********1111","cardHolderName":"Sherlock Holmes","cardExpiryDate":{"month":5,"year":2035},"billingAddress":{"address1":"221B Baker Street","address2":"Marylebone","address3":"Westminster","postalCode":"NW1 6XE","city":"London","state":"Greater London","countryCode":"GB"},"bin":"444433","brand":"VISA"},"_links":{"tokens:token":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0NzI0NE1rdUtjMUFJdjYxVnlibWZuUT0ifQ"},"tokens:description":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0MWJVbkh1WTFGZExUNXJxc04va1ZoTFVzYW1OU1lxSFE2NHI1c2JkY1pWaSJ9"},"tokens:cardHolderName":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0d3ltd21ieGo3TlZLYzRYSkExOUhSdUpLN2N3VVc5WUk3czRUTW1RQ2JLdjFnVXlzakdPSXdWWkRhZkZyUmlMd3c9PSJ9"},"tokens:cardExpiryDate":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0d3ltd21ieGo3TlZLYzRYSkExOUhSdUpLN2N3VVc5WUk3czRUTW1RQ2JLdkVpVW5GNnBsZThNTXNQWTRGbzFzTXc9PSJ9"},"tokens:billingAddress":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoialRBL0FFelBzcnZpNCtzRGNRemh0d3ltd21ieGo3TlZLYzRYSkExOUhSdFpSdXFxbWZlNVl1TkpHZEVvZXN3MTlCU0lmdCtxSTUyVDJSdXlmSTIwM3c9PSJ9"},"tokens:schemeTransactionReference":{"href":"https://try.access.worldpay.com/tokens/eyJrIjoxLCJkIjoiSENXWFZQZjNIZ1V3dnpDMElJZS9Zdmc4M0pYM3dDWEJTVnQrWVlacXdDUXFFKzhzaC8xNSs2d3NkTTdFWUFNVU9tdXBmUlZGeVNDY2dPMkhKV2NIcGc9PSJ9"},"curies":[{"href":"https://try.access.worldpay.com/rels/tokens/{rel}.json","name":"tokens","templated":true}]}}}}');
            res.setStatusCode(200);
            return res;
        }
    }

    // Inner class to mock HTTP callout for authorizeAPayment
    private class MockAuthorizePaymentHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"outcome":"Sent for Settlement","riskFactors":[{"type":"cvc","risk":"notSupplied"},{"type":"avs","risk":"notSupplied","detail":"address"},{"type":"avs","risk":"notSupplied","detail":"postcode"}],"issuer":{"authorizationCode":"594996"},"scheme":{"reference":"060720116005062"},"paymentInstrument":{"type":"card/plain+masked","cardBin":"400000","lastFour":"1091","expiryDate":{"month":12,"year":2024},"cardBrand":"visa","paymentAccountReference":"Q1HJZ28RKA1EBL470G9XYG90R5D3E"},"_links":{"cardPayments:refund":{"href":"https://try.access.worldpay.com/payments/settlements/refunds/full/eyJrIjoiazNhYjYzMiIsImxpbmtWZXJzaW9uIjoiNS4wLjAifQ==.sN:g8wd64bwkbrp0md+bPxcanBnk2zLdsIqSa1pR99FJyBdF1UUYASlH0M2raCAHYD4kmramneC50NqKUV4vdShMHeJVoeH2lrBWCRyjZYR46NqvLdP:qjMwJk30UKWiPLoQQ3dWRT2fxt0r:V5VCSQ2eNjpmbXEwwFdzosFyXv05qNbhusXPMtACoxMT15E6076ZdnXFUQXCzmyoO5fYnNdvDHFS:l+qfAlnNRP2BdCnMzk2C7iamI1tOIdYFfYCvERwWWTa+80d:aJmIlSKgn3O0PHAq2Xi+sNlchm83h2J9B9mwlKgm3S:taO:ZbB3y1AvLhlqONPTncgw7kJtQbO4mK7ilAUiyabX7JxPJUOJG2qfJMFZL7yuMkxja1Vtn9WFEcXNtvDKZy5OJFs3A=="},"cardPayments:partialRefund":{"href":"https://try.access.worldpay.com/payments/settlements/refunds/partials/eyJrIjoiazNhYjYzMiIsImxpbmtWZXJzaW9uIjoiNS4wLjAifQ==.sN:g8wd64bwkbrp0md+bPxcanBnk2zLdsIqSa1pR99FJyBdF1UUYASlH0M2raCAHYD4kmramneC50NqKUV4vdShMHeJVoeH2lrBWCRyjZYR46NqvLdP:qjMwJk30UKWiPLoQQ3dWRT2fxt0r:V5VCSQ2eNjpmbXEwwFdzosFyXv05qNbhusXPMtACoxMT15E6076ZdnXFUQXCzmyoO5fYnNdvDHFS:l+qfAlnNRP2BdCnMzk2C7iamI1tOIdYFfYCvERwWWTa+80d:aJmIlSKgn3O0PHAq2Xi+sNlchm83h2J9B9mwlKgm3S:taO:ZbB3y1AvLhlqONPTncgw7kJtQbO4mK7ilAUiyabX7JxPJUOJG2qfJMFZL7yuMkxja1Vtn9WFEcXNtvDKZy5OJFs3A=="},"cardPayments:reverse":{"href":"https://try.access.worldpay.com/payments/sales/reversals/eyJrIjoiazNhYjYzMiIsImxpbmtWZXJzaW9uIjoiNS4wLjAifQ==.sN:g8wd64bwkbrp0md+bPxcanBnk2zLdsIqSa1pR99FJyBdF1UUYASlH0M2raCAHYD4kmramneC50NqKUV4vdShMHeJVoeH2lrBWCRyjZYR46NqvLdP:qjMwJk30UKWiPLoQQ3dWRT2fxt0r:V5VCSQ2eNjpmbXEwwFdzosFyXv05qNbhusXPMtACoxMT15E6076ZdnXFUQXCzmyoO5fYnNdvDHFS:l+qfAlnNRP2BdCnMzk2C7iamI1tOIdYFfYCvERwWWTa+80d:aJmIlSKgn3O0PHAq2Xi+sNlchm83h2J9B9mwlKgm3S:taO:ZbB3y1AvLhlqONPTncgw7kJtQbO4mK7ilAUiyabX7JxPJUOJG2qfJMFZL7yuMkxja1Vtn9WFEcXNtvDKZy5OJFs3A=="},"cardPayments:events":{"href":"https://try.access.worldpay.com/payments/events/eyJrIjoiazNhYjYzMiIsImxpbmtWZXJzaW9uIjoiNS4wLjAifQ==.sN:g8wd64bwkbrp0md+bPxcanBnk2zLdsIqSa1pR99FJyBdF1UUYASlH0M2raCAHYD4kmramneC50NqKUV4vdShMHeJVoeH2lrBWCRyjZYR46NqvLdP:qjMwJk30UKWiPLoQQ3dWRT2fxt0r:V5VCSQ2eNjpmbXEwwFdzosFyXv05qNbhusXPMtACoxMT15E6076ZdnXFUQXCzmyoO5fYnNdvDHFS:l+qfAlnNRP2BdCnMzk2C7iamI1tOIdYFfYCvERwWWTa+80d:aJmIlSKgn3O0PHAq2Xi+sNlchm83h2J9B9mwlKgm3S:taO:ZbB3y1AvLhlqONPTncgw7kJtQbO4mK7ilAUiyabX7JxPJUOJG2qfJMFZL7yuMkxja1Vtn9WFEcXNtvDKZy5OJFs3A=="},"curies":[{"name":"cardPayments","href":"https://try.access.worldpay.com/rels/cardPayments/{rel}","templated":true}]}}');
            res.setStatusCode(201);
            return res;
        }
    }
    
    @isTest
    static void testGetShowCode() {
        // Test when code is null
        String nullCode = null;
        Boolean result = BLN_PaymentWorldPayController.getShowCode(nullCode);
        System.assertEquals(false, result, 'Expected showCode to be false when code is null');
        String validCode = '400';
        result = BLN_PaymentWorldPayController.getShowCode(validCode);
        System.assertEquals(true, result, 'Expected showCode to be true when code is 400');
        String invalidCode = '500';
        result = BLN_PaymentWorldPayController.getShowCode(invalidCode);
        System.assertNotEquals(false, result, 'Expected showCode to be false when code is not 400');
    }
}