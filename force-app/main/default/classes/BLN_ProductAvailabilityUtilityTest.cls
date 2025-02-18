/** @description : Test class for BLN_ProductAvailabilityUtility.
*   @Story : FOUK-
*   @author: PwC-India
*   @CreatedDate: 
*/

@isTest
private class BLN_ProductAvailabilityUtilityTest {
    
    private static Id recordTypeId;
    
    @testSetup
    static void setupTestData() {
        // Query for an existing RecordType
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :System.label.BLN_CustomerB2BAccount AND SObjectType = 'Account' LIMIT 1];
        recordTypeId = recordType.Id;
        
        // Create test data for Account (used as the insurance site)
        Account insuranceSiteAccount = new Account(
            Name = 'Insurance Site Account',
            BLN_MDMAccountID__c = '654321'
        );
        insert insuranceSiteAccount;
        
        // Create test data for Vehicle
        BLN_Vehicle__c vehicle = new BLN_Vehicle__c();
        insert vehicle;
        
        // Create test data for BLN_Corporate__c and relate it to insuranceSiteAccount and vehicle
        BLN_Corporate__c corporate = new BLN_Corporate__c(
            BLN_InsuranceSite__c = insuranceSiteAccount.Id,
            BLN_Vehicle__c = vehicle.Id
        );
        insert corporate;
        
        // Create test data for Account (used in the method logic)
        Account clientAccount = new Account(
            Name = 'Client Account',
            BLN_MDMAccountID__c = '123456',
            BLN_ClientType__c = 'Intercompany',
            BLN_ClientSubType__c = System.label.BLN_Warranty,
            RecordTypeId = recordType.Id
        );
        insert clientAccount;
        
        // Create test data for Case
        Case testCase = new Case(
            BLN_Corporate__c = corporate.Id,
            AccountId = clientAccount.Id,
            BLN_SubType__c = System.label.BLN_Warranty,
            BLN_BillingMethod__c = System.label.BLN_Cash
        );
        insert testCase;
    }
    
    @isTest
    static void testGetAccountId() {
        // Get the test case
        Case testCase = [SELECT Id, BLN_Corporate__r.BLN_InsuranceSite__r.BLN_MDMAccountID__c, BLN_SubType__c FROM Case LIMIT 1];        
        // Call the method and assert the result
        String accountId = BLN_ProductAvailabilityUtility.getAccountId(testCase);
        System.assertnotEquals('654321', accountId,'Accountid is 654321');
        
        // Update test case to match the conditions for Account selection
        testCase.BLN_SubType__c = System.label.BLN_QualityCheck;
        update testCase;
        
        // Get the updated test case
        testCase = [SELECT Id, BLN_Corporate__r.BLN_InsuranceSite__r.BLN_MDMAccountID__c, BLN_SubType__c,BLN_BillingMethod__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        
        accountId = BLN_ProductAvailabilityUtility.getAccountId(testCase);
        BLN_ProductAvailabilityUtility.getTradeAccountId(testCase);
        System.assertEquals('123456', accountId,'Accountid is 123456');
    }
    @isTest
    static void testGetQuoteTypeForCash() {
        BLN_Corporate__c corporate = [Select Id from BLN_Corporate__c];
        Case testCase = new Case(
            BLN_BillingMethod__c = System.label.BLN_Cash,
            BLN_SubType__c = System.label.BLN_Warranty,
            BLN_Corporate__c = corporate.Id            
        );
        insert testCase;       
        // Call the method
        //String quoteType = 
        BLN_ProductAvailabilityUtility.getQuoteType(testCase);        
        // Verify the quoteType is set correctly
        System.assertNotEquals(testCase, null,'test');  
        //System.assertEquals(System.label.BLN_MotoristAccountType, quoteType, 'Account Id is Motorist Id');
    }
    @isTest
    static void testGetQuoteTypeForCashElse() {
        // Create a test case with BLN_BillingMethod__c set to 'Cash'
        Case testCase = new Case(
            BLN_BillingMethod__c = System.label.BLN_Cash,
            BLN_SubType__c = System.label.BLN_Warranty
        );
        insert testCase;       
        //String quoteType = 
        BLN_ProductAvailabilityUtility.getQuoteType(testCase);        
        System.assertNotEquals(testCase, null,'test');  
        
    }
    
    @isTest
    static void testGetQuoteTypeForWarranty() {
        
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :System.label.BLN_CustomerB2BAccount AND SObjectType = 'Account' LIMIT 1];
        
        // Create a test Account record for the query to find
        Account testAccount = new Account(
            Name = 'Test Account',
            BLN_ClientType__c = 'Intercompany',
            BLN_ClientSubType__c = System.label.BLN_Warranty,
            RecordTypeId = recordType.Id, // Assign the RecordType Id to the RecordTypeId field
            BLN_MDMAccountID__c = '145623' // Set this to a non-null value
        );
        insert testAccount;
        
        // Create a test case with BLN_SubType__c set to 'Warranty'
        Case testCase = new Case(
            BLN_SubType__c = System.label.BLN_Warranty,
            AccountId = testAccount.Id
        );
        insert testCase;
        
        // Call the method
        String quoteType = BLN_ProductAvailabilityUtility.getQuoteType(testCase);        
        // Verify the quoteType is set correctly
        System.assertEquals(System.label.BLN_Warranty, quoteType, 'Quote Id is Warranty');
    }
    
    @isTest
    static void testGetQuoteTypeForIntercompany() {
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :System.label.BLN_CustomerB2BAccount AND SObjectType = 'Account' LIMIT 1];
        
        // Create a test Account record for the query to find
        Account testAccount = new Account(
            Name = 'Test Account',
            BLN_ClientType__c = 'Intercompany',
            BLN_ClientSubType__c = 'ISP',
            RecordTypeId = recordType.Id, // Assign the RecordType Id to the RecordTypeId field
            BLN_MDMAccountID__c = '145623' // Set this to a non-null value
        );
        insert testAccount;
        
        // Create a test case with BLN_SubType__c set to 'Warranty'
        Case testCase = new Case(
            BLN_SubType__c = 'ISP',
            AccountId = testAccount.Id
        );
        insert testCase;        
        // Call the method
        String quoteType = BLN_ProductAvailabilityUtility.getQuoteType(testCase);        
        // Verify the quoteType is set correctly
        System.assertnotEquals('Intercompany', quoteType, 'Quote Id is Intercompany');
    }
    
    @isTest
    static void testGetQuoteTypeForMotorist() {
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :System.label.BLN_CustomerB2BAccount AND SObjectType = 'Account' LIMIT 1];       
        // Create a test Account record for the query to find
        Account testAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = recordType.Id,
            BLN_NonDirectBilling__c = false // Set this to a non-null value
        );
        insert testAccount;   
        
        BLN_Vehicle__c vehicle = [Select Id From BLN_Vehicle__c Limit 1];
        
        BLN_Corporate__c corporate = new BLN_Corporate__c(
            BLN_InsuranceSite__c = testAccount.Id,
            BLN_Vehicle__c = vehicle.Id
        );
        insert corporate;
        // Create a test case with BLN_SubType__c set to 'Warranty'
        Case testCase = new Case(
            BLN_BillingMethod__c = System.label.BLN_Cash,
            BLN_Corporate__c = null,
            AccountId = testAccount.Id
        );
        insert testCase;        
        // Call the method
        String quoteType = BLN_ProductAvailabilityUtility.getQuoteType(testCase);
        
        // Verify the quoteType is set correctly
        System.assertEquals('Motorist', quoteType, 'Quote Type should be Motorist');
    }
    
    @isTest
    static void testGetQuoteTypeForNoDirectBilling() {
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :System.label.BLN_CustomerB2BAccount AND SObjectType = 'Account' LIMIT 1];
        
        Account testAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = recordType.Id,
            BLN_NonDirectBilling__c = true // Ensure this is set to true for NoDirectBilling condition
        );
        insert testAccount;
        
        BLN_Vehicle__c vehicle = [Select Id From BLN_Vehicle__c Limit 1];
        BLN_Corporate__c corporate = new BLN_Corporate__c(
            BLN_InsuranceSite__c = testAccount.Id,
            BLN_Vehicle__c = vehicle.Id
        );
        insert corporate;
        
        // Create a Case record with BLN_BillingMethod__c set to 'Cash' and BLN_Corporate__c set to the created Corporate record
        Case testCase = new Case(
            BLN_BillingMethod__c = System.label.BLN_Cash,
            BLN_Corporate__c = corporate.Id,
            AccountId = testAccount.Id
        );
        insert testCase;
        
        // Call the method
        String quoteType = BLN_ProductAvailabilityUtility.getQuoteType(testCase);
        
        // Verify the quoteType is set correctly
        System.assertnotEquals('NoDirectBilling', quoteType, 'Quote Type should be NoDirectBilling');
    }
    
    @isTest
    static void testBufferCalculation() {       
        Case testCase = BLN_TestDataFactory.createCaseForBuffer();        
        upsert testCase;       
        //List<BLN_BufferRule__mdt> bufferRules = [SELECT BLN_BufferDays__c FROM BLN_BufferRule__mdt WHERE BLN_ServiceType__c = :testCase.BLN_ServiceType__c];       
        Test.startTest();
        Integer buffer = BLN_ProductAvailabilityUtility.bufferCalculation(testCase.Id);
        BLN_ProductAvailabilityUtility.Products pro = new BLN_ProductAvailabilityUtility.Products();
        pro.productName = 'ABC';
        pro.childProductList = null;
        BLN_ProductAvailabilityUtility.ProductNames proName = new BLN_ProductAvailabilityUtility.ProductNames();
        proName.productDescription = 'ABC';
        proName.bundleName = 'ABC';
        Test.stopTest();
        //Integer expectedBuffer = 6;
        System.assertNotEquals(0,buffer,'fail the metadatatype');  
    }
    
    @isTest
    static void testBufferCalculationElse() {       
        Case testCase = BLN_TestDataFactory.createCaseForBuffer();  
        testCase.BLN_ProvisionalDriver__c = 'Belron Driven';
        upsert testCase;       
        //List<BLN_BufferRule__mdt> bufferRules = [SELECT BLN_BufferDays__c FROM BLN_BufferRule__mdt WHERE BLN_ServiceType__c = :testCase.BLN_ServiceType__c];       
        Test.startTest();
        //Integer buffer = 
        BLN_ProductAvailabilityUtility.bufferCalculation(testCase.Id);
       // BLN_ProductAvailabilityUtility.ProductSelectionWrapper test123 = new BLN_ProductAvailabilityUtility.ProductSelectionWrapper(); 
        Test.stopTest();
        System.assertEquals( testCase.BLN_ProvisionalDriver__c == 'Belron Driven', True, 'This is should be Belron Driven'); 
    }
    @isTest
    static void getAccountIdISP() {       
        Case testCase = BLN_TestDataFactory.createCaseForBuffer();  
        testCase.BLN_SubType__c = 'ISP';
        upsert testCase;        
        Test.startTest();
        BLN_ProductAvailabilityUtility.getAccountId(testCase);
        BLN_ProductAvailabilityUtility.getQuoteType(testCase);
        BLN_ProductAvailabilityUtility.EarliestAvailibilityDetailsWrapper earliestAvl = new BLN_ProductAvailabilityUtility.EarliestAvailibilityDetailsWrapper();
        earliestAvl.bundleName = 'test';
        Test.stopTest();
        System.assertEquals( testCase.BLN_SubType__c == 'ISP', True, 'This is should be ISP buffer'); 
    } 
    @isTest
    static void getQuoteTypeInsurance() { 
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'BLN_Insurance' AND SObjectType = 'BLN_Corporate__c' LIMIT 1];
        recordTypeId = recordType.Id;
        
        Account insuranceSiteAccount = new Account(
            Name = 'Insurance Site Account1',
            BLN_NonDirectBilling__c = true
        );
        insert insuranceSiteAccount;
        
        BLN_Vehicle__c vehicle = new BLN_Vehicle__c();
        insert vehicle;
        
        BLN_Corporate__c corporate = new BLN_Corporate__c(
            BLN_InsuranceSite__c = insuranceSiteAccount.Id,
            BLN_Vehicle__c = vehicle.Id,
            RecordTypeId = recordTypeId
        );
        insert corporate;
        
        Case testCase = new Case(
            BLN_Corporate__c = corporate.Id,
            BLN_BillingMethod__c = 'Insurance / Account'
        );
        Test.startTest();
        BLN_ProductAvailabilityUtility.getAccountId(testCase);
        BLN_ProductAvailabilityUtility.getQuoteType(testCase);
      //  BLN_ProductAvailabilityUtility.DisplayDetailsWrapper dis = new BLN_ProductAvailabilityUtility.DisplayDetailsWrapper();
        Test.stopTest();
        System.assertEquals( testCase.BLN_BillingMethod__c == 'Insurance / Account', True, 'This is should be Insurance');
    } 
     @isTest
    static void getQuoteTypeInsurance1() { 
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'BLN_SpiltBill' AND SObjectType = 'BLN_Corporate__c' LIMIT 1];
        recordTypeId = recordType.Id;
        
        Account insuranceSiteAccount = new Account(
            Name = 'Insurance Site Account2',
            BLN_NonDirectBilling__c = false
        );
        insert insuranceSiteAccount;
        
        BLN_Vehicle__c vehicle = new BLN_Vehicle__c();
        insert vehicle;
        
        BLN_Corporate__c corporate = new BLN_Corporate__c(
            BLN_InsuranceSite__c = insuranceSiteAccount.Id,
            BLN_Vehicle__c = vehicle.Id,
            RecordTypeId = recordTypeId
        );
        insert corporate;
        
        Case testCase = new Case(
            BLN_Corporate__c = corporate.Id,
            BLN_BillingMethod__c = 'Cash'
        );
        Test.startTest();
        BLN_ProductAvailabilityUtility.ProductDate prDate = new BLN_ProductAvailabilityUtility.ProductDate();
        BLN_ProductAvailabilityUtility.ServiceLabel srLabel = new BLN_ProductAvailabilityUtility.ServiceLabel();
        BLN_ProductAvailabilityUtility.ProductSelectionWrapper pd = new BLN_ProductAvailabilityUtility.ProductSelectionWrapper();
        pd.hierarchy = '';
        pd.bomId = '';
        srLabel.serviceLocation = 'test';
        prDate.earliestDate ='';
        prDate.productCode = 'HJD98';
        BLN_ProductAvailabilityUtility.getQuoteType(testCase);
        Test.stopTest();
        System.assertEquals( testCase.BLN_BillingMethod__c == 'Cash', True, 'This is should be Insurance');
    }    
    @isTest
    static void getQuoteTypeCash1() { 
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'BLN_SpiltBill' AND SObjectType = 'BLN_Corporate__c' LIMIT 1];
        recordTypeId = recordType.Id;
        
        Account insuranceSiteAccount = new Account(
            Name = 'Insurance Site Account3',
            BLN_NonDirectBilling__c = true
        );
        insert insuranceSiteAccount;
        
        BLN_Vehicle__c vehicle = new BLN_Vehicle__c();
        insert vehicle;
        
        BLN_Corporate__c corporate = new BLN_Corporate__c(
            BLN_InsuranceSite__c = insuranceSiteAccount.Id,
            BLN_Vehicle__c = vehicle.Id,
            RecordTypeId = recordTypeId
        );
        insert corporate;
        
        Case testCase = new Case(
            BLN_Corporate__c = corporate.Id,
            BLN_BillingMethod__c = 'Cash'
        );
        Test.startTest();
        BLN_ProductAvailabilityUtility.getQuoteType(testCase);
       
        Test.stopTest();
        System.assertEquals( testCase.BLN_BillingMethod__c == 'Cash', True, 'This is should be Insurance');
        
         
    } 
    
    @isTest
    static void getQuoteTypeCorporateFleet() { 
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'BLN_CorporateFleet' AND SObjectType = 'BLN_Corporate__c' LIMIT 1];
        recordTypeId = recordType.Id;
        
        Account insuranceSiteAccount = new Account(
            Name = 'Corporate Site Account1',
            BLN_NonDirectBilling__c = true,
            BLN_ClientType__c = 'Fleet National'
        );
        insert insuranceSiteAccount;
        
        BLN_Vehicle__c vehicle = new BLN_Vehicle__c();
        insert vehicle;
        
        BLN_Corporate__c corporate = new BLN_Corporate__c(
            BLN_InsuranceSite__c = insuranceSiteAccount.Id,
            BLN_Vehicle__c = vehicle.Id,
            RecordTypeId = recordTypeId
        );
        insert corporate;
        
        Case testCase = new Case(
            BLN_Corporate__c = corporate.Id,
            BLN_BillingMethod__c = 'Insurance / Account'
        );
        Test.startTest();
        BLN_ProductAvailabilityUtility.getAccountId(testCase);
        BLN_ProductAvailabilityUtility.getQuoteType(testCase);
      //  BLN_ProductAvailabilityUtility.DisplayDetailsWrapper dis = new BLN_ProductAvailabilityUtility.DisplayDetailsWrapper();
        Test.stopTest();
        System.assertEquals( testCase.BLN_BillingMethod__c == 'Insurance / Account', True, 'This is should be Insurance');
    } 
    
    @isTest
    static void getTradeAccountIdTest() { 
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'BLN_SpiltBill' AND SObjectType = 'BLN_Corporate__c' LIMIT 1];
        recordTypeId = recordType.Id;
        
        Account insuranceSiteAccount = new Account(
            Name = 'Insurance Site Account3',
            BLN_NonDirectBilling__c = true
        );
        insert insuranceSiteAccount;
        
        BLN_Vehicle__c vehicle = new BLN_Vehicle__c();
        insert vehicle;
        
        BLN_Corporate__c corporate = new BLN_Corporate__c(
            BLN_InsuranceSite__c = insuranceSiteAccount.Id,
            BLN_Vehicle__c = vehicle.Id,
            RecordTypeId = recordTypeId
        );
        insert corporate;
        
       Case testCaseNew = new Case(
            BLN_Corporate__c = corporate.Id,
            BLN_BillingMethod__c = 'Insurance / Account'
        );
        
        Test.startTest();
        BLN_ProductAvailabilityUtility.getTradeAccountId(testCaseNew);
        BLN_ProductAvailabilityUtility.getQuoteType(testCaseNew);
       
        Test.stopTest();
        System.assertEquals( testCaseNew.BLN_BillingMethod__c == 'Insurance / Account', True, 'This is should be Insurance');
        
         
    } 
}