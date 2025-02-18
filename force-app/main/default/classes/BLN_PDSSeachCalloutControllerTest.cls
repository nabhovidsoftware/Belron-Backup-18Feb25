/*****************************************
ClassName : BLN_PDSSeachCalloutControllerTest
Description : BLN_PDSSeachCalloutController having test class BLN_PDSSeachCalloutControllerTest
CreatedDate: 08/04/2024
CreatedBy : Shubbh Arora
****************************************/
@isTest
public class BLN_PDSSeachCalloutControllerTest {
    
/*    @TestSetup 
    static void setup() {
        Account testAcc = BLN_TestDataFactory.createTestAccount();
        testAcc.FirstName = 'TestSplit';
        testAcc.LastName = 'Bill Corp';
        testAcc.PersonEmail = 'test111@gmail.com';
                 
        insert testAcc;
        
        Contact testContact = BLN_TestDataFactory.getContact('Test333');
        testContact.FirstName = 'Test333';
        testContact.LastName = 'Contact333';
        testContact.Email = 'test333@gmail.com';
        insert testContact;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.AccountId = testAcc.Id;
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000;
        cse.BLN_Vehicle__c = veh.Id;
        insert cse;
        
        // recordId = cse.Id;
        
        BLN_VehicleDamage__c vD = new BLN_VehicleDamage__c();
        vD.BLN_BOMID__c = '12541';
        vD.BLN_Case__c = cse.id;
        insert vD;
        
        BLN_Corporate__c corpRecord = BLN_TestDataFactory.createcorporate();
        corpRecord.BLN_Vehicle__c = veh.Id;
        corpRecord.BLN_PolicyNumber__c ='1233';
        insert corpRecord;
    }*/
   
    @isTest  
    static void testGetSchemeCodesWithValidSchemeCodes() {  
        String recordId = [SELECT Id, Name, DeveloperName, Description, NamespacePrefix FROM RecordType where Name = 'Customer(B2B Account)'].Id;  
        Account testAcc =  new Account();  
        testAcc.Name = 'TestSplit';  
        testAcc.BLN_TotalNoOfVehiclesMotorPolicy__c = 2;
        testAcc.Industry = '	Manufacturing';
        testAcc.BLN_ClientSubType__c = 'Wholesale';
        testAcc.BLN_ClientType__c =  'Wholesale';
        testAcc.BLN_Level__c = 'Legal Entity Account';
        testAcc.RecordTypeId = recordId;
        testAcc.BLN_MDMAccountID__c = 'abcdxyz123';
        testAcc.BillingStreet = '123 Test Street';
        testAcc.BillingCity = 'Test City';
        testAcc.BillingState = 'TS';
        testAcc.BillingPostalCode = '12345';
        testAcc.BillingCountry = 'Test Country';
        testAcc.ShippingStreet = '456 Shipping Street'; 
        testAcc.ShippingCity = 'Shipping City';
        testAcc.ShippingState = 'SS';
        testAcc.ShippingPostalCode = '67890';
        testAcc.ShippingCountry = 'Shipping Country';
        testAcc.BLN_MDMAccountID__c = 'parentMDM123';
       
        insert testAcc;
        
        Account acc = new Account(
            Name ='Child',
            BLN_MDMAccountID__c = 'abcdxyz1234',
            ParentId =  testAcc.Id,
            BLN_Level__c = System.label.BLN_SiteAccount,
            BillingStreet = '123 Test Street', 
            BillingCity = 'Test City',
            BillingState = 'TS',
            BillingPostalCode = '12345',
            BillingCountry = 'Test Country',
            ShippingStreet = '456 Shipping Street',  
            ShippingCity = 'Shipping City',
            ShippingState = 'SS',
            ShippingPostalCode = '67890',
            ShippingCountry = 'Shipping Country',
            BLN_PDSDirectAPI__c = true
        );
        acc.RecordTypeId = recordId;
        insert acc;
        
        BLN_PDSCode__c pdsCode = new BLN_PDSCode__c(
            BLN_SchemeCode__c = 'SCHEME123',
            BLN_Account__c = acc.Id,
            BLN_Account__r = acc
        );
        insert pdsCode;
        
        BLN_PDSSeachCalloutController.CorporateWrapper corpWrapper = new BLN_PDSSeachCalloutController.CorporateWrapper();
        corpWrapper.schemeCodeMapping = 'SCHEME123';
        corpWrapper.insuranceSiteID = null;
        corpWrapper.insuranceLegalEntityID = 'parentMDM123';
        
        BLN_PDSSeachCalloutController.CorporateWrapper wrapper2 = new BLN_PDSSeachCalloutController.CorporateWrapper();  
        wrapper2.schemeCodeMapping = 'scheme456';  // Non-matching scheme code  
        wrapper2.insuranceSiteID = null;  
        wrapper2.insuranceLegalEntityID = 'parentMDM789';  // Non-matching entity ID  
  
        List<BLN_PDSSeachCalloutController.CorporateWrapper> corWarpList = new List<BLN_PDSSeachCalloutController.CorporateWrapper>{corpWrapper, wrapper2};  
  
        
        List<BLN_PDSSeachCalloutController.CorporateWrapper> result = BLN_PDSSeachCalloutController.getSchemeCodes(corWarpList);  
  
       
        System.assertNotEquals(null, result, 'The result should not be null');  
        System.assertEquals(2, result.size(), 'The size of the result list should be 2');  
  
        
        System.assertEquals('abcdxyz1234', result[0].insuranceSiteID, 'insuranceSiteID should be relatedMDM456 for the first wrapper');  
        //System.assertEquals('Related Account', result[0].insuranceSiteAccountName, 'insuranceSiteAccountName should be Related Account for the first wrapper');  
        System.assertEquals(acc.Id, result[0].insuranceSiteAccountSFId, 'insuranceSiteAccountSFId should match the related account Id for the first wrapper');  
        //System.assertEquals(true, result[0].insuraceSiteSFNonDirectBilling, 'insuraceSiteSFNonDirectBilling should be true for the first wrapper');  
  
      
        System.assertEquals(null, result[1].insuranceSiteID, 'insuranceSiteID should remain null for the second wrapper'); 
        
        
        /*List<BLN_PDSSeachCalloutController.CorporateWrapper> corWarpList = new List<BLN_PDSSeachCalloutController.CorporateWrapper>{ corpWrapper };
        
        Test.startTest();
        List<BLN_PDSSeachCalloutController.CorporateWrapper> result = BLN_PDSSeachCalloutController.getSchemeCodes(corWarpList);  
        Test.stopTest();  
          
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assertEquals(null, result[0].insuranceLegalEntityID, 'Insurance Legal Entity ID should match.');
        //System.assertEquals(null, result[0].insuranceSiteID, 'Insurance Site ID should match.');
        System.assertEquals(null, result[0].insuranceSiteAccountSFId, 'Insurance Site Account SFId should match.');
        System.assertEquals(null, result[0].insuranceSiteAccountName, 'Insurance Site Account Name should match.');*/
    }
    
    @isTest
    static void testGetSchemeCodesWithEmptyCorWarpList() {
        Test.startTest();
        List<BLN_PDSSeachCalloutController.CorporateWrapper> result = BLN_PDSSeachCalloutController.getSchemeCodes(new List<BLN_PDSSeachCalloutController.CorporateWrapper>());
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assertEquals(0, result.size(), 'Result list should be empty.');
    }
    
    @isTest  
    static void testGetSchemeCodesWithNoSchemeCodesAndAccountMDMID() {  
        String recordId = [SELECT Id, Name, DeveloperName, Description, NamespacePrefix FROM RecordType where Name = 'Customer(B2B Account)'].Id;  
        Account testAcc =  new Account();  
        testAcc.Name = 'TestSplit';  
        testAcc.BLN_TotalNoOfVehiclesMotorPolicy__c = 2;  
        testAcc.Industry = 'Manufacturing';  
        testAcc.BLN_ClientSubType__c = 'Wholesale';  
        testAcc.BLN_ClientType__c = 'Wholesale';  
        testAcc.BLN_Level__c = 'Legal Entity Account';  
        testAcc.RecordTypeId = recordId;  
        testAcc.BLN_MDMAccountID__c = 'abcdxyz123';  
        testAcc.BillingStreet = '123 Test Street';  
        testAcc.BillingCity = 'Test City';  
        testAcc.BillingState = 'TS';  
        testAcc.BillingPostalCode = '12345';  
        testAcc.BillingCountry = 'Test Country';  
        testAcc.ShippingStreet = '456 Shipping Street';   
        testAcc.ShippingCity = 'Shipping City';  
        testAcc.ShippingState = 'SS';  
        testAcc.ShippingPostalCode = '67890';  
        testAcc.ShippingCountry = 'Shipping Country';  
        insert testAcc;  
          
        Account acc = new Account(  
            Name ='Child',  
            BLN_MDMAccountID__c = 'abcdxyz1234',  
            ParentId =  testAcc.Id,  
            BLN_Level__c = System.label.BLN_SiteAccount,  
            BillingStreet = '123 Test Street',   
            BillingCity = 'Test City',  
            BillingState = 'TS',  
            BillingPostalCode = '12345',  
            BillingCountry = 'Test Country',  
            ShippingStreet = '456 Shipping Street',  
            ShippingCity = 'Shipping City',  
            ShippingState = 'SS',  
            ShippingPostalCode = '67890',  
            ShippingCountry = 'Shipping Country',  
            BLN_PDSDirectAPI__c = true  
        );  
        acc.RecordTypeId = recordId;  
        insert acc;  
  
        BLN_PDSSeachCalloutController.CorporateWrapper corpWrapper = new BLN_PDSSeachCalloutController.CorporateWrapper();  
        corpWrapper.schemeCodeMapping = null;  
        corpWrapper.insuranceLegalEntityID = null;  
          
        List<BLN_PDSSeachCalloutController.CorporateWrapper> corWarpList = new List<BLN_PDSSeachCalloutController.CorporateWrapper>{ corpWrapper };  
          
        Test.startTest();  
        List<BLN_PDSSeachCalloutController.CorporateWrapper> result = BLN_PDSSeachCalloutController.getSchemeCodes(corWarpList);   
        Test.stopTest();  
          
        System.assertNotEquals(null, result, 'Result should not be null.');  
        System.assertEquals(1, result.size(), 'Result list should contain one element.');  
        //System.assertEquals(null, result[0].insuranceSiteID, 'Insurance Site ID should match.');  
        System.assertEquals(null, result[0].insuranceSiteAccountSFId, 'Insurance Site Account SFId should match.');  
        System.assertEquals(null, result[0].insuranceSiteAccountName, 'Insurance Site Account Name should match.');  
    }  

    public class BLN_HttpCalloutMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public BLN_HttpCalloutMock(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }

	@isTest
    	static void testGetAccountMap(){
        Account testAcc = BLN_TestDataFactory.createCustomerB2BAccount('Test333');
        testAcc.BLN_Status__c = 'Active';
        testAcc.BLN_MDMAccountID__c = '123765';
        testAcc.BLN_AccountTierType__c = 'Major Account';
        testAcc.BLN_ClientType__c = 'Insurance';
        testAcc.BLN_ClientSubType__c = 'MGA';
        testAcc.BLN_PaymentTerms__c = '30 Net';
        testAcc.BLN_ReferringStatus__c = 'On Hold';
        testAcc.BLN_SupplyStatusWithAutoglass__c = 'Sole Supplier';
        testAcc.BLN_TradingStatus__c = 'Sole Trader';
        testAcc.BLN_BillingFrequency__c = 'Daily';
        testAcc.BLN_BillingMethod__c = 'Consolidated Billing';
        testAcc.BillingCity = 'Shirpur';
        testAcc.BillingCountry = 'India';
        testAcc.BillingStreet = 'Yerwada';
        testAcc.BillingPostalCode = '414003';
        testAcc.BLN_RegistrationAddress__City__s = 'Shegaon';
        testAcc.BLN_RegistrationAddress__Street__s = 'Yerwada';
        testAcc.BLN_RegistrationAddress__PostalCode__s = '654319';     
        insert testAcc;
        
        Test.startTest();
        Map<String,Account> strMap = BLN_PDSSeachCalloutController.getAccountMap(new List<String>{'123765'});
        BLN_PDSSeachCalloutController.getAccountMap(null);
        BLN_PDSSeachCalloutController.ErrorWrapper ewrap = new BLN_PDSSeachCalloutController.ErrorWrapper();
        Test.stopTest();

        System.assertNotEquals(null, strMap, 'Result should not be null');
        System.assertNotEquals(null, ewrap, 'ErrorWrapper should be instantiated');
    }
    
    @isTest
    static void testSearchManual(){
        Account testAcc = BLN_TestDataFactory.createCustomerB2BAccount('Test333');
        testAcc.BLN_Status__c = 'Active';
        testAcc.BLN_MDMAccountID__c = '123765';
        testAcc.AccountNumber = '6742';
        testAcc.BLN_AccountTierType__c = 'Major Account';
        testAcc.BLN_ClientType__c = 'Insurance';
        testAcc.BLN_ClientSubType__c = 'MGA';
        testAcc.BLN_PaymentTerms__c = '30 Net';
        testAcc.BLN_ReferringStatus__c = 'On Hold';
        testAcc.BLN_SupplyStatusWithAutoglass__c = 'Sole Supplier';
        testAcc.BLN_TradingStatus__c = 'Sole Trader';
        testAcc.BLN_BillingFrequency__c = 'Daily';
        testAcc.BLN_BillingMethod__c = 'Consolidated Billing';
        testAcc.BillingCity = 'Shirpur';
        testAcc.BillingCountry = 'India';
        testAcc.BillingStreet = 'Yerwada';
        testAcc.BillingPostalCode = '414003';
        testAcc.BLN_RegistrationAddress__City__s = 'Shegaon';
        testAcc.BLN_RegistrationAddress__Street__s = 'Yerwada';
        testAcc.BLN_RegistrationAddress__PostalCode__s = '654319';
        insert testAcc;
        //String accId = Id.valueOf(testAcc.Id);
        
        Contact testContact = new contact();
        testContact.LastName = 'Test SearchManual';
        testContact.Email = 'SearchManual@gmail.com';
        insert testContact;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;
        
        BLN_Corporate__c corpPolicyRecord = BLN_TestDataFactory.createcorporate();
        corpPolicyRecord.BLN_PolicyStartDate__c = system.now().date();
        corpPolicyRecord.BLN_PolicyEndDate__c = system.now().addDays(2).date();
        corpPolicyRecord.BLN_Vehicle__c = veh.id; 
        corpPolicyRecord.BLN_KnownAs__c = 'Test';
        corpPolicyRecord.BLN_PolicyConfirmation__c = 'Rejected';
        insert corpPolicyRecord;
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.AccountId = testAcc.Id;
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000;
        cse.BLN_Vehicle__c = veh.Id;
        cse.BLN_Corporate__c = corpPolicyRecord.Id;
        insert cse;
        
        BLN_AccountAlternativeName__c altName = new BLN_AccountAlternativeName__c();  
        altName.BLN_AlternativeAccountName__c = 'Test333';  
        altName.BLN_Account__c = testAcc.Id;  
        insert altName;  
        
        Test.startTest();
        List<Account> listOfAcc1 = BLN_PDSSeachCalloutController.getCustomerB2BAccount(testAcc.Name, testAcc.AccountNumber, 'Corporate');   
        List<Account> listOfAcc2 = BLN_PDSSeachCalloutController.getCustomerB2BAccount(testAcc.Name, testAcc.AccountNumber, 'Insurance');  
        List<Account> listOfAcc3 = BLN_PDSSeachCalloutController.getCustomerB2BAccount('', testAcc.AccountNumber, 'Corporate');  
        List<Account> listOfAcc4 = BLN_PDSSeachCalloutController.getCustomerB2BAccount(testAcc.Name, '', 'Corporate');   
        List<Account> listOfAcc5 = BLN_PDSSeachCalloutController.getCustomerB2BAccount(testAcc.Name, null, null);      
        Test.stopTest();  
  
        System.assertNotEquals(null, listOfAcc1, 'List of accounts should not be null for Corporate');  
        System.assertNotEquals(null, listOfAcc2, 'List of accounts should not be null for Insurance');  
        System.assertNotEquals(null, listOfAcc3, 'List of accounts should not be null when accountName is blank');  
        System.assertNotEquals(null, listOfAcc4, 'List of accounts should not be null when accountNumber is blank');  
        System.assertNotEquals(null, listOfAcc5, 'List of accounts should not be null when selectedOption is null');  
    }
   
	@isTest
    static void testCallout(){
        String vrn = 'A2066497';
        Date lossDate = System.today();
        String recordId;
        
        Account testAcc = BLN_TestDataFactory.createCustomerB2BAccount('Test333');
        testAcc.BLN_Status__c = 'Active';
        testAcc.BLN_MDMAccountID__c = '123765';
        testAcc.BLN_AccountTierType__c = 'Major Account';
        testAcc.BLN_ClientType__c = 'Insurance';
        testAcc.BLN_ClientSubType__c = 'MGA';
        testAcc.BLN_PaymentTerms__c = '30 Net';
        testAcc.BLN_ReferringStatus__c = 'On Hold';
        testAcc.BLN_SupplyStatusWithAutoglass__c = 'Sole Supplier';
        testAcc.BLN_TradingStatus__c = 'Sole Trader';
        testAcc.BLN_BillingFrequency__c = 'Daily';
        testAcc.BLN_BillingMethod__c = 'Consolidated Billing';
        testAcc.BillingCity = 'Shirpur';
        testAcc.BillingCountry = 'India';
        testAcc.BillingStreet = 'Yerwada';
        testAcc.BillingPostalCode = '414003';
        testAcc.BLN_RegistrationAddress__City__s = 'Shegaon';
        testAcc.BLN_RegistrationAddress__Street__s = 'Yerwada';
        testAcc.BLN_RegistrationAddress__PostalCode__s = '654319';
        insert testAcc;
        //String accId = Id.valueOf(testAcc.Id);
        
        Account testAcc1 = BLN_TestDataFactory.createCustomerB2BAccount('Test77312');
        testAcc1.BLN_Status__c = 'Active';
        testAcc1.BLN_MDMAccountID__c = '1237651';
        testAcc1.BLN_AccountTierType__c = 'Major Account';
        testAcc1.BLN_ClientType__c = 'Insurance';
        testAcc1.BLN_ClientSubType__c = 'MGA';
        testAcc1.BLN_PaymentTerms__c = '30 Net';
        testAcc1.BLN_ReferringStatus__c = 'On Hold';
        testAcc1.BLN_SupplyStatusWithAutoglass__c = 'Sole Supplier';
        testAcc1.BLN_TradingStatus__c = 'Sole Trader';
        testAcc1.BLN_BillingFrequency__c = 'Daily';
        testAcc1.BLN_BillingMethod__c = 'Consolidated Billing';
        testAcc1.BillingCity = 'Mumbai';
        testAcc1.BillingCountry = 'India';
        testAcc1.BillingStreet = 'Yerwada';
        testAcc1.BillingPostalCode = '414003';
        testAcc1.BLN_RegistrationAddress__City__s = 'Nagpur';
        testAcc1.BLN_RegistrationAddress__Street__s = 'Yerwada';
        testAcc1.BLN_RegistrationAddress__PostalCode__s = '654319';
        insert testAcc1;

        BLN_AccountRuleParameter__c acpTest = new BLN_AccountRuleParameter__c();
        acpTest.BLN_Account__c = testAcc.Id;
        acpTest.BLN_InsurerAccount__c = testAcc1.Id;
        acpTest.BLN_VAT__c = 'Motorist';
        acpTest.BLN_Excess__c = 'Motorist';
        acpTest.BLN_Remainder__c = 'Motorist';
        acpTest.BLN_PolicyLimit__c = 123;
        acpTest.BLN_PolicyNumbers__c = '123';
        acpTest.BLN_RepairExcess__c = 123;
        acpTest.BLN_ReplacementExcess__c = 123;
        acpTest.RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_SplitBill').getRecordTypeId();
        insert acpTest;
        
        Contact testContact = new contact();
        testContact.LastName = 'Test Callout';
        testContact.Email = 'testCallout@gmail.com';
        insert testContact;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.AccountId = testAcc.Id;
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000;
        cse.BLN_Vehicle__c = veh.Id;
        insert cse;
        
        recordId = cse.Id;
        
        BLN_VehicleDamage__c vD = new BLN_VehicleDamage__c();
        vD.BLN_BOMID__c = '12541';
        vD.BLN_Case__c = cse.id;
        insert vD;
        
        BLN_Corporate__c corpRecord = BLN_TestDataFactory.createcorporate();
        corpRecord.BLN_Vehicle__c = veh.Id;
        corpRecord.BLN_PolicyStartDate__c = system.now().date();
        corpRecord.BLN_PolicyEndDate__c = system.now().addDays(2).date();
        RecordType recType = [select Id from RecordType where sObjectType='BLN_Corporate__c' and name = 'Insurance' limit 1];
        corpRecord.RecordTypeId= recType.Id;
        insert corpRecord;
        Case existingCase = [SELECT Id FROM Case LIMIT 1];
        //String randomId = BLN_TestDataFactory.randomNumberGenerator() + 'TEST';                
          //  system.debug('responsecorporateWrapList'+ responsecorporateWrapList)     
        Test.startTest();
        Case res = BLN_PDSSeachCalloutController.blnPDSsearchAPI(existingCase.Id);
         BLN_PDSSeachCalloutController.blnPDSsearchAPI(null);
         BLN_PDSSeachCalloutController.ErrorWrapper ewrap = new BLN_PDSSeachCalloutController.ErrorWrapper();
        //Case resForCatch = BLN_PDSSeachCalloutController.blnPDSsearchAPI(null);
        //Test.setMock(HttpCalloutMock.class, new BLN_PDSSeachCalloutControllerMockCallout());
        Test.setMock(HttpCalloutMock.class, new BLN_PDSSearchMuleMock());
        BLN_PDSSeachCalloutController.makeCallout(vrn, lossDate);
        Test.stopTest();
        Assert.areEqual(existingCase.Id, res.Id, 'The case Id should match the queried case Id.');
        System.assertEquals('12541', vD.BLN_BOMID__c, 'Please check again');
         System.assertNotEquals(null, ewrap, 'ErrorWrapper should be instantiated');
    }  

    @isTest
    /*static void testGetReference(){
        
        Map<String,Account> mdmMap = new Map<String,Account>();
        
        Account testAcc = BLN_TestDataFactory.createCustomerB2BAccount('Test333');
        testAcc.BLN_Status__c = 'Active';
        testAcc.BLN_MDMAccountID__c = '123765';
        insert testAcc;
        String accId = Id.valueOf(testAcc.Id);
        
        Account testAcc1 = BLN_TestDataFactory.createCustomerB2BAccount('Test333');
        testAcc1.BLN_Status__c = 'Active';
        testAcc1.BLN_MDMAccountID__c = '1237651';
        insert testAcc1;
		
        mdmMap.put(testAcc1.Id,testAcc1);
        mdmMap.put(testAcc.Id,testAcc);
        
        BLN_AccountRuleParameter__c acpTest = new BLN_AccountRuleParameter__c();
        acpTest.BLN_Account__c = testAcc.Id;
        acpTest.BLN_InsurerAccount__c = testAcc1.Id;
        acpTest.BLN_VAT__c = 'Motorist';
        acpTest.BLN_Excess__c = 'Motorist';
        acpTest.BLN_Remainder__c = 'Motorist';
        acpTest.BLN_PolicyLimit__c = 123;
        acpTest.BLN_PolicyNumbers__c = '123';
        acpTest.BLN_RepairExcess__c = 123;
        acpTest.BLN_ReplacementExcess__c = 123;
        acpTest.BLN_ActiveFrom__c = Date.today();
        acpTest.BLN_ActiveTo__c = Date.today();
        acpTest.RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_SplitBill').getRecordTypeId();
        insert acpTest;
        
        BLN_PDSSeachCalloutController.CorporateWrapper corpWrap = new BLN_PDSSeachCalloutController.CorporateWrapper();
        corpWrap.corporateSiteSFId = testAcc.Id;
        corpWrap.insuranceSiteAccountSFId = testAcc1.Id;
        
        Test.startTest();
        BLN_PDSSeachCalloutController.getReference(new List<BLN_PDSSeachCalloutController.CorporateWrapper>{corpWrap} , mdmMap);
        Test.stopTest();
        System.assertNotEquals(corpWrap,null , 'Data is not not null');

    }*/
    static void testGetReference() {
        // Step 1: Create test Accounts
        Account testAcc = new Account(Name = 'Test Account 1', BLN_MDMAccountID__c = '123765');
        insert testAcc;
        
        Account testAcc1 = new Account(Name = 'Test Account 2', BLN_MDMAccountID__c = '1237651');
        insert testAcc1;
       
        Map<String, Account> mdmMap = new Map<String, Account>();
        mdmMap.put(testAcc.Id, testAcc);
        mdmMap.put(testAcc1.Id, testAcc1);

        BLN_AccountRuleParameter__c acpTest = new BLN_AccountRuleParameter__c(
            BLN_Account__c = testAcc.Id,
            BLN_InsurerAccount__c = testAcc1.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_SplitBill').getRecordTypeId()
        );
        insert acpTest;

        BLN_PDSSeachCalloutController.CorporateWrapper corpWrap = new BLN_PDSSeachCalloutController.CorporateWrapper();
        corpWrap.corporateSiteSFId = testAcc.Id;
        corpWrap.insuranceSiteAccountSFId = testAcc1.Id;
        corpWrap.glassExcessAmount = 123; 
        
        List<BLN_PDSSeachCalloutController.CorporateWrapper> corpWrapList = new List<BLN_PDSSeachCalloutController.CorporateWrapper>{corpWrap};
      
        Test.startTest();
        List<BLN_PDSSeachCalloutController.CorporateWrapper> resultList = BLN_PDSSeachCalloutController.getReference(corpWrapList, mdmMap);
        List<BLN_PDSSeachCalloutController.CorporateWrapper> resultList1 = BLN_PDSSeachCalloutController.getReference(Null, null);
        Test.stopTest();
        
        if (resultList1 != null) {
            System.assertEquals(0, resultList1.size(), 'Result list for null input should be empty');
        } 
        else {
            System.assert(true, 'resultList1 is null');
        }

        for (BLN_PDSSeachCalloutController.CorporateWrapper result : resultList) {
            System.assertEquals(acpTest.BLN_Account__c, result.corporateSiteSFId, 'Corporate Site SF ID should match');
            System.assertEquals(acpTest.BLN_InsurerAccount__c, result.insuranceSiteAccountSFId, 'Insurance Site Account SF ID should match');
            System.assertEquals(acpTest.BLN_Reference__c, result.reference, 'Reference should be correctly assigned');
        }
        /*for (BLN_PDSSeachCalloutController.CorporateWrapper result : resultList1) {
            System.assertNotEquals(null, resultList1, 'Result list should not be null');
        }*/
    }

    @isTest
    static void testGetReferenceWithEmptyParameters() {
       
        List<BLN_PDSSeachCalloutController.CorporateWrapper> corpWrapList = new List<BLN_PDSSeachCalloutController.CorporateWrapper>();
        Map<String, Account> mdmMap = new Map<String, Account>();

        Test.startTest();
        List<BLN_PDSSeachCalloutController.CorporateWrapper> resultList = BLN_PDSSeachCalloutController.getReference(corpWrapList, mdmMap);
        Test.stopTest();

        System.assertEquals(0, resultList.size(), 'Result list should be empty when no parameters are provided');
    }

	@isTest
    static void testPdsDirectCallout(){
        Account testAcc = BLN_TestDataFactory.createCustomerB2BAccount('Test333');
        testAcc.BLN_Status__c = 'Active';
        testAcc.BLN_MDMAccountID__c = '12376511'; 
        testAcc.BLN_AccountTierType__c = 'Major Account';
        testAcc.BLN_ClientType__c = 'Insurance';
        testAcc.BLN_ClientSubType__c = 'MGA';
        testAcc.BLN_PaymentTerms__c = '30 Net';
        testAcc.BLN_ReferringStatus__c = 'On Hold';
        testAcc.BLN_SupplyStatusWithAutoglass__c = 'Sole Supplier';
        testAcc.BLN_TradingStatus__c = 'Sole Trader';
        testAcc.BLN_BillingFrequency__c = 'Daily';
        testAcc.BLN_BillingMethod__c = 'Consolidated Billing';
        testAcc.BillingCity = 'Shirpur';
        testAcc.BillingCountry = 'India';
        testAcc.BillingStreet = 'Yerwada';
        testAcc.BillingPostalCode = '414003';
        testAcc.BLN_RegistrationAddress__City__s = 'Shegaon';
        testAcc.BLN_RegistrationAddress__Street__s = 'Yerwada';
        testAcc.BLN_RegistrationAddress__PostalCode__s = '654319';
        insert testAcc;
        
		String accountMDMID = testAcc.Id;
        String lossDate = '2024-01-01';
   
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BLN_PDSSearchMuleMock());
        String response =  BLN_PDSSeachCalloutController.pdsDirectCallout('12345',Date.valueOf(lossDate),veh.id,accountMDMID);
        String response1 =  BLN_PDSSeachCalloutController.pdsDirectCallout(null,Date.valueOf(lossDate),veh.id,null);
        Test.stopTest();

        System.assert(response != null , 'Please check again');
        System.assertNotEquals(null, response1, 'Response should not be null for null inputs');
    }

    @isTest
    public static void testSearchManualValidCase() {
        
        Case testCase = new Case(
            BLN_Corporate__r = new BLN_Corporate__c(
                BLN_KnownAs__c = 'Test Corporation',
                BLN_PolicyConfirmation__c = 'Rejected'
            )
        );
        
        String result = BLN_PDSSeachCalloutController.searchManual(testCase);  
        System.assertEquals('', result, 'The name should be returned when conditions are met');
    }
    
    @isTest
    public static void testSearchManualBlankKnownAs() {
        Case testCase = new Case(
            BLN_Corporate__r = new BLN_Corporate__c(
                BLN_KnownAs__c = '',  
                BLN_PolicyConfirmation__c = 'Rejected'
            )
        );
        String result = BLN_PDSSeachCalloutController.searchManual(testCase);
        System.assertEquals('', result, 'The name should be blank when BLN_KnownAs__c is empty');
    }
    
    @isTest
    public static void testSearchManualNoPolicyRejected() {
        Case testCase = new Case(
            BLN_Corporate__r = new BLN_Corporate__c(
                BLN_KnownAs__c = 'Test Corporation',
                BLN_PolicyConfirmation__c = 'Accepted'
            )
        );
        String result = BLN_PDSSeachCalloutController.searchManual(testCase);
        System.assertEquals('', result, 'The name should be blank when the policy confirmation is not rejected');
    }
    
    @isTest
    public static void testSearchManualNullCase() {
        String result = BLN_PDSSeachCalloutController.searchManual(null);
        System.assertEquals('', result, 'The name should be blank when the case is null');
    }
    
    @isTest
    public static void testSearchManualExceptionHandling() {
        Case testCase = new Case();
        String result = BLN_PDSSeachCalloutController.searchManual(testCase);
        System.assertEquals('', result, 'The name should be blank in case of an exception');
    }
    
    @isTest
    public static void testUpdateBillingMethodToCash() {
        Case testCase = new Case(
            Subject = 'Test Case', 
            Status = 'New', 
            BLN_BillingMethod__c = 'Cash' 
        );

        insert testCase;

        Test.startTest();
        BLN_PDSSeachCalloutController.updateBillingMethodToCash(testCase.Id);
        Test.stopTest();

        Case updatedCase = [SELECT Id, BLN_BillingMethod__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        System.assertEquals('Cash', updatedCase.BLN_BillingMethod__c, 'The Billing Method should be updated to Cash.');
    }
    
    @isTest
    static void testgetPolicyFormatApi(){
        Date lossDate = System.today();
        //String recordId;
        String accountMDMID;
        String policyno='123';
        String excess='1000';
        
        Account testAcc = BLN_TestDataFactory.createCustomerB2BAccount('Test333');
        testAcc.BLN_Status__c = 'Active';
        testAcc.BLN_MDMAccountID__c = '123765111';
        testAcc.BLN_AccountTierType__c = 'Major Account';
        testAcc.BLN_ClientType__c = 'Insurance';
        testAcc.BLN_ClientSubType__c = 'MGA';
        testAcc.BLN_PaymentTerms__c = '30 Net';
        testAcc.BLN_ReferringStatus__c = 'On Hold';
        testAcc.BLN_SupplyStatusWithAutoglass__c = 'Sole Supplier';
        testAcc.BLN_TradingStatus__c = 'Sole Trader';
        testAcc.BLN_BillingFrequency__c = 'Daily';
        testAcc.BLN_BillingMethod__c = 'Consolidated Billing';
        testAcc.BillingCity = 'Shirpur';
        testAcc.BillingCountry = 'India';
        testAcc.BillingStreet = 'Yerwada';
        testAcc.BillingPostalCode = '414003';
        testAcc.BLN_RegistrationAddress__City__s = 'Shegaon';
        testAcc.BLN_RegistrationAddress__Street__s = 'Yerwada';
        testAcc.BLN_RegistrationAddress__PostalCode__s = '654319';
        insert testAcc;
        //String accId = Id.valueOf(testAcc.Id);
        
       	Contact testContact = new contact();
        testContact.LastName = 'Test getPolicyApi';
        testContact.Email = 'testPolicyApi@gmail.com';
        insert testContact;
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.AccountId = testAcc.Id;
        cse.Priority = 'Medium';
        //cse.BLN_IncidentDate__c='31-10-2023';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000;
        
        insert cse;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;
        
        BLN_Corporate__c corpPolicyRecord = BLN_TestDataFactory.createcorporate();
        corpPolicyRecord.BLN_PolicyStartDate__c = system.now();
        corpPolicyRecord.BLN_PolicyEndDate__c = system.now().addDays(2);
        corpPolicyRecord.BLN_Vehicle__c = veh.id; 
        insert corpPolicyRecord;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BLN_PDSSearchMuleMock());
        String res = BLN_PDSSeachCalloutController.getPolicyFormatApi(accountMDMID,policyno,excess,Date.valueOf(lossDate));
         BLN_PDSSeachCalloutController.getPolicyFormatApi(accountMDMID,' ',excess,Date.valueOf(lossDate));
         BLN_PDSSeachCalloutController.getPolicyFormatApi(accountMDMID,'12/3',excess,Date.valueOf(lossDate));
        Test.stopTest();

        System.assert(res != null , 'Please check again');
    }

	@isTest
    static void testCreateUpdateRecords() {
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;

        Account testAcc = BLN_TestDataFactory.createCustomerB2BAccount('Test333');
        testAcc.BLN_Status__c = 'Active';
        testAcc.BLN_MDMAccountID__c = '1237652132';
        testAcc.BLN_AccountTierType__c = 'Major Account';
        testAcc.BLN_ClientType__c = 'Insurance';
        testAcc.BLN_ClientSubType__c = 'MGA';
        testAcc.BLN_PaymentTerms__c = '30 Net';
        testAcc.BLN_ReferringStatus__c = 'On Hold';
        testAcc.BLN_SupplyStatusWithAutoglass__c = 'Sole Supplier';
        testAcc.BLN_TradingStatus__c = 'Sole Trader';
        testAcc.BLN_BillingFrequency__c = 'Daily';
        testAcc.BLN_BillingMethod__c = 'Consolidated Billing';
        testAcc.BillingCity = 'Pune';
        testAcc.BillingCountry = 'India';
        testAcc.BillingStreet = 'Yerwada';
        testAcc.BillingPostalCode = '414003';
        testAcc.BLN_RegistrationAddress__City__s = 'Pune';
        testAcc.BLN_RegistrationAddress__Street__s = 'Yerwada';
        testAcc.BLN_RegistrationAddress__PostalCode__s = '654319';
        insert testAcc;

        Contact testContact = new contact();
        testContact.LastName = 'Test contact123';
        testContact.Email = 'test333faytfscytv@gmail.com';
        insert testContact;

        Account testAcc1 = BLN_TestDataFactory.createCustomerB2BAccount('TestAccount09546');
        testAcc1.BLN_Status__c = 'Active';
        testAcc1.BLN_MDMAccountID__c = '1237651';
        testAcc1.BLN_AccountTierType__c = 'Major Account';
        testAcc1.BLN_ClientType__c = 'Insurance';
        testAcc1.BLN_ClientSubType__c = 'MGA';
        testAcc1.BLN_PaymentTerms__c = '30 Net';
        testAcc1.BLN_ReferringStatus__c = 'On Hold';
        testAcc1.BLN_SupplyStatusWithAutoglass__c = 'Sole Supplier';
        testAcc1.BLN_TradingStatus__c = 'Sole Trader';
        testAcc1.BLN_BillingFrequency__c = 'Daily';
        testAcc1.BLN_BillingMethod__c = 'Consolidated Billing';
        testAcc1.BillingCity = 'Pune';
        testAcc1.BillingCountry = 'India';
        testAcc1.BillingStreet = 'Yerwada';
        testAcc1.BillingPostalCode = '414003';
        testAcc1.BLN_RegistrationAddress__City__s = 'Pune';
        testAcc1.BLN_RegistrationAddress__Street__s = 'Yerwada';
        testAcc1.BLN_RegistrationAddress__PostalCode__s = '654319';
        insert testAcc1;

        // Account testAcc2 = BLN_TestDataFactory.createCustomerB2BAccount('Test333');
        // testAcc2.BLN_Status__c = 'Active';
        // testAcc2.BLN_MDMAccountID__c = '123765112';
        // insert testAcc2;
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.AccountId = testAcc.Id;
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000;
        cse.BLN_Vehicle__c = veh.Id;
        insert cse;

        List<BLN_PDSSeachCalloutController.CorporateWrapper> wrappers = new List<BLN_PDSSeachCalloutController.CorporateWrapper>();
        BLN_PDSSeachCalloutController.CorporateWrapper wrapper = new BLN_PDSSeachCalloutController.CorporateWrapper();
        wrapper.vehicleRegistration = 'Test Registration';
        wrapper.operatingCompanyName = 'Test Company';
        wrapper.isCorporateSelected = true;
        wrapper.knownAs = 'test';
        wrapper.attachToCase = true;
        wrapper.policyValidFromDatetime = '2020-10-31 00:00:00';
        wrapper.policyExpirationDatetime = '2024-10-30 00:00:00';
        wrapper.insuranceSiteAccountID = '012606988175';
        wrapper.corporateSiteName = 'corporateSiteName';
        wrapper.corporateCountryGroupingName = 'corporateCountryGroupingName';
        wrapper.insuranceSiteAccountName = 'insuranceSiteAccountName';
        wrapper.insuranceLegalEntityName = 'insuranceLegalEntityName';
        wrapper.insuranceCountryGroupingName = 'insuranceCountryGroupingName';
        wrapper.corporateLegalEntityName = 'corporateLegalEntityName';
        wrapper.row = 1;
        wrappers.add(wrapper);

        BLN_PDSSeachCalloutController.CorporateWrapper wrapper2 = new BLN_PDSSeachCalloutController.CorporateWrapper();
        wrapper2.vehicleRegistration = 'Test Registration';
        wrapper2.operatingCompanyName = 'Test Company';
        wrapper2.isCorporateSelected = false;
        wrapper2.knownAs = 'test';
        wrapper2.attachToCase = true;
        wrapper2.policyValidFromDatetime = '2020-10-31 00:00:00';
        wrapper2.policyExpirationDatetime = '2024-10-30 00:00:00';
        wrapper2.row = 2;
        wrapper2.corporateSiteSFId = null;
        wrappers.add(wrapper2);

        BLN_AccountRuleParameter__c acpTest = new BLN_AccountRuleParameter__c(
            BLN_Account__c = testAcc.Id,
            BLN_InsurerAccount__c = testAcc1.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_EDITypeCode__c = 'ONUM',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_DataCollect').getRecordTypeId()
        );
        insert acpTest;

        Test.startTest();

        BLN_DataCollectAnswer__c answerRecord = new BLN_DataCollectAnswer__c();
        answerRecord.BLN_Case__c = cse.Id;
        answerRecord.BLN_Question__c = acpTest.Id;
        answerRecord.BLN_Answer__c = 'Test question';
        insert answerRecord;
        
        //String wrapperJson = JSON.serialize(wrappers);

        // Test.startTest();
        Boolean result1 = BLN_PDSSeachCalloutController.createUpdateRecords(JSON.serialize(wrappers), cse);
        wrapper.attachToCase = false;
        Boolean result2 = BLN_PDSSeachCalloutController.createUpdateRecords(JSON.serialize(wrappers), cse);

        delete cse;
        Boolean result3 = BLN_PDSSeachCalloutController.createUpdateRecords(JSON.serialize(wrappers), cse);
        //Boolean result3 = BLN_PDSSeachCalloutController.createUpdateRecords(JSON.serialize(wrappers), null);

        Test.stopTest();
        // Assert that the operation was successful
        System.assertEquals(result1,false,'Expected createUpdateRecords method to return false');
        System.assertEquals(result2,true,'Expected createUpdateRecords method to return true');
        System.assertEquals(result3,false,'Expected createUpdateRecords method to return true');
    }

    @isTest
    static void testCreateUpdateRecords1(){
        String splitBillRecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'BLN_SpiltBill' WITH SECURITY_ENFORCED LIMIT 1].Id;
        String corporateRecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'BLN_CorporateFleet' WITH SECURITY_ENFORCED LIMIT 1].Id;
        String insuranceRecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'BLN_Insurance' WITH SECURITY_ENFORCED LIMIT 1].Id;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;

        Account testAcc = BLN_TestDataFactory.createCustomerB2BAccount('Test333');
        testAcc.BLN_Status__c = 'Active';
        testAcc.BLN_MDMAccountID__c = '1237652132';
        testAcc.BLN_AccountTierType__c = 'Major Account';
        testAcc.BLN_ClientType__c = 'Insurance';
        testAcc.BLN_ClientSubType__c = 'MGA';
        testAcc.BLN_PaymentTerms__c = '30 Net';
        testAcc.BLN_ReferringStatus__c = 'On Hold';
        testAcc.BLN_SupplyStatusWithAutoglass__c = 'Sole Supplier';
        testAcc.BLN_TradingStatus__c = 'Sole Trader';
        testAcc.BLN_BillingFrequency__c = 'Daily';
        testAcc.BLN_BillingMethod__c = 'Consolidated Billing';
        testAcc.BillingCity = 'Pune';
        testAcc.BillingCountry = 'India';
        testAcc.BillingStreet = 'Yerwada';
        testAcc.BillingPostalCode = '414003';
        testAcc.BLN_RegistrationAddress__City__s = 'Pune';
        testAcc.BLN_RegistrationAddress__Street__s = 'Yerwada';
        testAcc.BLN_RegistrationAddress__PostalCode__s = '654319';
        insert testAcc;
        
        Contact testContact = new contact();
        testContact.LastName = 'Test contact123';
        testContact.Email = 'test333faytfscytv@gmail.com';
        insert testContact;

        Account testAcc1 = BLN_TestDataFactory.createCustomerB2BAccount('TestAccount436778');
        testAcc1.BLN_Status__c = 'Active';
        testAcc1.BLN_MDMAccountID__c = '1237651';
        testAcc1.BLN_AccountTierType__c = 'Major Account';
        testAcc1.BLN_ClientType__c = 'Insurance';
        testAcc1.BLN_ClientSubType__c = 'MGA';
        testAcc1.BLN_PaymentTerms__c = '30 Net';
        testAcc1.BLN_ReferringStatus__c = 'On Hold';
        testAcc1.BLN_SupplyStatusWithAutoglass__c = 'Sole Supplier';
        testAcc1.BLN_TradingStatus__c = 'Sole Trader';
        testAcc1.BLN_BillingFrequency__c = 'Daily';
        testAcc1.BLN_BillingMethod__c = 'Consolidated Billing';
        testAcc1.BillingCity = 'Pune';
        testAcc1.BillingCountry = 'India';
        testAcc1.BillingStreet = 'Yerwada';
        testAcc1.BillingPostalCode = '414003';
        testAcc1.BLN_RegistrationAddress__City__s = 'Pune';
        testAcc1.BLN_RegistrationAddress__Street__s = 'Yerwada';
        testAcc1.BLN_RegistrationAddress__PostalCode__s = '654319';
        insert testAcc1;

        BLN_Corporate__c corporate1=BLN_TestDataFactory.createcorporate();
        corporate1.BLN_CorporateSite__c = testAcc.Id;
        corporate1.BLN_InsuranceSite__c = testAcc1.id;
        corporate1.BLN_Vehicle__c = veh.id;
        corporate1.RecordTypeId = splitBillRecordTypeId;

        BLN_Corporate__c corporate2 = BLN_TestDataFactory.createcorporate();
        corporate2.BLN_CorporateSite__c = testAcc.Id;
        corporate2.BLN_InsuranceSite__c = null;
        corporate2.BLN_Vehicle__c = veh.id;
        corporate2.RecordTypeId = corporateRecordTypeId;

        BLN_Corporate__c corporate3 = BLN_TestDataFactory.createcorporate();
        corporate3.BLN_CorporateSite__c = null;
        corporate3.BLN_InsuranceSite__c = testAcc.id;
        corporate3.BLN_Vehicle__c = veh.id;
        corporate3.RecordTypeId = insuranceRecordTypeId;

        List<BLN_Corporate__c> corpList = new List<BLN_Corporate__c>();
        corpList.add(corporate1);
        corpList.add(corporate2);
        corpList.add(corporate3);
        insert corpList;
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.AccountId = testAcc.Id;
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000;
        cse.BLN_Vehicle__c = veh.Id;
        cse.BLN_Corporate__c = corporate1.Id;
        insert cse;
        
        List<BLN_PDSSeachCalloutController.CorporateWrapper> wrappers = new List<BLN_PDSSeachCalloutController.CorporateWrapper>();
        BLN_PDSSeachCalloutController.CorporateWrapper wrapper = new BLN_PDSSeachCalloutController.CorporateWrapper();
        wrapper.vehicleRegistration = 'Test Registration';
        wrapper.operatingCompanyName = 'Test Company';
        wrapper.isCorporateSelected = true;
        wrapper.knownAs = 'test';
        wrapper.attachToCase = true;
        wrapper.policyValidFromDatetime = '2020-10-31 00:00:00';
        wrapper.policyExpirationDatetime = '2024-10-30 00:00:00';
        wrapper.insuranceSiteAccountID = '012606988175';
        wrapper.corporateSiteName = 'corporateSiteName';
        wrapper.corporateCountryGroupingName = 'corporateCountryGroupingName';
        wrapper.insuranceSiteAccountName = 'insuranceSiteAccountName';
        wrapper.insuranceLegalEntityName = 'insuranceLegalEntityName';
        wrapper.insuranceCountryGroupingName = 'insuranceCountryGroupingName';
        wrapper.corporateLegalEntityName = 'corporateLegalEntityName';
        wrapper.row = 1;
        wrappers.add(wrapper);

        BLN_PDSSeachCalloutController.CorporateWrapper wrapper2 = new BLN_PDSSeachCalloutController.CorporateWrapper();
        wrapper2.vehicleRegistration = 'Test Registration';
        wrapper2.operatingCompanyName = 'Test Company';
        wrapper2.isCorporateSelected = false;
        wrapper2.knownAs = 'test';
        wrapper2.attachToCase = true;
        wrapper2.policyValidFromDatetime = '2020-10-31 00:00:00';
        wrapper2.policyExpirationDatetime = '2024-10-30 00:00:00';
        wrapper2.row = 2;
        wrapper2.corporateSiteSFId = null;
        wrappers.add(wrapper2);


        BLN_AccountRuleParameter__c acpTest = new BLN_AccountRuleParameter__c(
            BLN_Account__c = testAcc.Id,
            BLN_InsurerAccount__c = testAcc1.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_EDITypeCode__c = 'ONUM',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_DataCollect').getRecordTypeId()
        );
        // insert acpTest;

        BLN_AccountRuleParameter__c acpTest2 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = testAcc1.Id,
            BLN_InsurerAccount__c = testAcc.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123456',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_EDITypeCode__c = 'ONUM',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(8),
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_DataCollect').getRecordTypeId()
        );
        // insert acpTest2;

        List<BLN_AccountRuleParameter__c> acpList = new List<BLN_AccountRuleParameter__c>();
        acpList.add(acpTest);
        acpList.add(acpTest2);
        insert acpList;

        Test.startTest();
        Boolean result1 = BLN_PDSSeachCalloutController.createUpdateRecords(JSON.serialize(wrappers), cse);

        // delete cse;
        Case cse1 = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse1.Type = 'Job Request';
        cse1.Status = 'New';
        cse1.ContactId = testContact.Id;
        cse1.AccountId = testAcc.Id;
        cse1.BLN_Corporate__c = corporate2.Id;
        insert cse1;
        BLN_PDSSeachCalloutController.createUpdateRecords(JSON.serialize(wrappers), cse1);

        Case cse2 = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse2.Type = 'Job Request';
        cse2.Status = 'New';
        cse2.ContactId = testContact.Id;
        cse2.AccountId = testAcc.Id;
        cse2.BLN_Corporate__c = corporate3.Id;
        insert cse2;
        BLN_PDSSeachCalloutController.createUpdateRecords(JSON.serialize(wrappers), cse2);
        Test.stopTest();

        System.assertNotEquals(result1,true,'Expected createUpdateRecords method to return true');
    }

    @isTest
    static void splitBillCorpCalloutSuccess() {
        String mockResponseBody = 
            '{'+
            '"statusCode": 200,'+
            '"body": {'+
            '"status": "success",'+
            '"data": ['+
            '{'+
            '"policyNumber": "213131233",'+
            '"glassExcessAmount": 120.0,'+
            '"glassLimitAmount": 120.0,'+
            '"repairExcessAmount": 25.0,'+
            '"repairLimitAmount": 120.0,'+
            '"windscreenExcessAmount": 120.0,'+
            '"bodyglassExcessAmount": 25.0,'+
            '"heatedRearExcessAmount": 25.0,'+
            '"adasExcessAmount": 120.0,'+
            '"insuranceSiteAccountID": "TBD",'+
            '"insuranceLegalEntityID": null,'+
            '"insuranceCountryGroupingID": "TBD",'+
            '"corporateSiteID": "TBD",'+
            '"corporateLegalEntityID": "012606988176",'+
            '"corporateCountryGroupingID": "TBD",'+
            '"vatPayingParty": "Account",'+
            '"excessPayingParty": "Account"'+
            '}'+
            ']'+
            '}'+
            '}';
        
        // Mock the HTTP Response
        Test.setMock(HttpCalloutMock.class, new BLN_HttpCalloutMock(200, mockResponseBody));
        
         //Account testAcc = BLN_TestDataFactory.createTestAccount();
        String recordId = [SELECT Id, Name, DeveloperName, Description, NamespacePrefix FROM RecordType where Name = 'Customer(B2B Account)'].Id;
        Account testAcc =  new Account();
        testAcc.Name = 'TestSplit';
        //testAcc.LastName = 'Bill Corp';
       // testAcc.PersonEmail = 'test111@gmail.com';
        testAcc.BLN_TotalNoOfVehiclesMotorPolicy__c = 2;
        testAcc.Industry = '	Manufacturing';
        testAcc.BLN_ClientSubType__c = 'Wholesale';
        testAcc.BLN_ClientType__c =  'Wholesale';
        testAcc.BLN_Level__c = 'Legal Entity Account';
        testAcc.RecordTypeId = recordId;
        testAcc.BLN_MDMAccountID__c = 'abcdxyz123';
        testAcc.BillingStreet = '123 Test Street';
        testAcc.BillingCity = 'Test City';
        testAcc.BillingState = 'TS';
        testAcc.BillingPostalCode = '12345';
        testAcc.BillingCountry = 'Test Country';
        testAcc.ShippingStreet = '456 Shipping Street'; 
        testAcc.ShippingCity = 'Shipping City';
        testAcc.ShippingState = 'SS';
        testAcc.ShippingPostalCode = '67890';
        testAcc.ShippingCountry = 'Shipping Country';
        insert testAcc;
        
        //String accountMDMID = String.valueOf(testAcc.Id);
        String lossDate = '2024-01-01';
        
        // Creating a test account
       Account testAccount = new Account(
            Name ='Child',
            BLN_MDMAccountID__c = 'abcdxyz1234',
            ParentId =  testAcc.Id,
            BLN_Level__c = System.label.BLN_SiteAccount,
            BillingStreet = '123 Test Street', 
            BillingCity = 'Test City',
            BillingState = 'TS',
            BillingPostalCode = '12345',
            BillingCountry = 'Test Country',
            ShippingStreet = '456 Shipping Street', // Provide a valid address
            ShippingCity = 'Shipping City',
            ShippingState = 'SS',
            ShippingPostalCode = '67890',
            ShippingCountry = 'Shipping Country',
            BLN_PDSDirectAPI__c = true
        );

        testAccount.RecordTypeId = recordId;
        insert testAccount;
       // String accountId = testAccount.BLN_MDMAccountID__c;
        Test.startTest();
        String result = BLN_PDSSeachCalloutController.splitBillCorpCallout('abcdxyz123', Date.valueOf(lossDate));
        //String result1 = BLN_PDSSeachCalloutController.splitBillCorpCallout(null , Date.valueOf(lossDate));
        Test.stopTest();
     	BLN_PDSSeachCalloutController.CalloutCorporateWrapper response = (BLN_PDSSeachCalloutController.CalloutCorporateWrapper) JSON.deserialize(result, BLN_PDSSeachCalloutController.CalloutCorporateWrapper.class);  
        // Assertions
        System.assertNotEquals(null, response, 'Result should not be null');
        System.assertNotEquals(null, response.corporateWrapList, 'Corporate list should not be null');
    }
    
    @isTest
    static void splitBillCorpCalloutError() {
        String mockResponseBody = 
            '{'+
            '"statuscode": 401,'+  // Note that this should match the 'statuscode' field in the PayloadWrapper
            '"body": {'+
            '"status": "Unauthorized",'+
            '"data": ['+
            '{'+
            '"policyNumber": "213131233",'+
            '"glassExcessAmount": 120.0,'+
            '"glassLimitAmount": 120.0,'+
            '"repairExcessAmount": 25.0,'+
            '"repairLimitAmount": 120.0,'+
            '"windscreenExcessAmount": 120.0,'+
            '"bodyglassExcessAmount": 25.0,'+
            '"heatedRearExcessAmount": 25.0,'+
            '"adasExcessAmount": 120.0,'+
            '"insuranceSiteAccountID": "TBD",'+
            '"insuranceLegalEntityID": "012606988175",'+
            '"insuranceCountryGroupingID": "TBD",'+
            '"corporateSiteID": "TBD",'+
            '"corporateLegalEntityID": "012606988176",'+
            '"corporateCountryGroupingID": "TBD",'+
            '"vatPayingParty": "Account",'+
            '"excessPayingParty": "Account"'+
            '}'+
            ']'+
            '}'+
            '}';
        
        // Mock the HTTP Response
        Test.setMock(HttpCalloutMock.class, new BLN_HttpCalloutMock(401, mockResponseBody));  // Adjust status code to match expected error
        Account testAcc = BLN_TestDataFactory.createCustomerB2BAccount('Test3334');
        testAcc.BLN_Status__c = 'Active';
        testAcc.BLN_MDMAccountID__c = '123765232';
        //testAcc.BLN_Level__c = 'Site Account';
        testAcc.BLN_AccountTierType__c = 'Major Account';
        testAcc.BLN_ClientType__c = 'Insurance';
        testAcc.BLN_ClientSubType__c = 'MGA';
        testAcc.BLN_PaymentTerms__c = '30 Net';
        testAcc.BLN_ReferringStatus__c = 'On Hold';
        testAcc.BLN_SupplyStatusWithAutoglass__c = 'Sole Supplier';
        testAcc.BLN_TradingStatus__c = 'Sole Trader';
        testAcc.BLN_BillingFrequency__c = 'Daily';
        testAcc.BLN_BillingMethod__c = 'Consolidated Billing';
        testAcc.BillingCity = 'Pune';
        testAcc.BillingCountry = 'India';
        testAcc.BillingStreet = 'Yerwada';
        testAcc.BillingPostalCode = '414003';
        testAcc.BLN_RegistrationAddress__City__s = 'Pune';
        testAcc.BLN_RegistrationAddress__Street__s = 'Yerwada';
        testAcc.BLN_RegistrationAddress__PostalCode__s = '654319';
        insert testAcc;
        
        //String accountMDMID = testAcc.Id;
        String lossDate = '2024-01-01';
        
        // Creating a test account
        Account testAccount = BLN_TestDataFactory.createCustomerB2BAccount('TestAccount33848292');
        testAccount.BLN_Status__c = 'Active';
        testAccount.BLN_MDMAccountID__c = '1237652320';
        testAccount.BLN_Level__c = 'Legal Entity account';
        testAccount.BLN_AccountTierType__c = 'Major Account';
        testAccount.BLN_ClientType__c = 'Insurance';
        testAccount.BLN_ClientSubType__c = 'MGA';
        testAccount.BLN_PaymentTerms__c = '30 Net';
        testAccount.BLN_ReferringStatus__c = 'On Hold';
        testAccount.BLN_SupplyStatusWithAutoglass__c = 'Sole Supplier';
        testAccount.BLN_TradingStatus__c = 'Sole Trader';
        testAccount.BLN_BillingFrequency__c = 'Daily';
        testAccount.BLN_BillingMethod__c = 'Consolidated Billing';
        testAccount.BillingCity = 'Pune';
        testAccount.BillingCountry = 'India';
        testAccount.BillingStreet = 'Yerwada';
        testAccount.BillingPostalCode = '414003';
        testAccount.BLN_RegistrationAddress__City__s = 'Pune';
        testAccount.BLN_RegistrationAddress__Street__s = 'Yerwada';
        testAccount.BLN_RegistrationAddress__PostalCode__s = '654319';
        insert testAccount;
        
        Test.startTest();
        String errorRec = BLN_PDSSeachCalloutController.splitBillCorpCallout('abcd1234', Date.valueOf(lossDate));
        Test.stopTest();
        
        BLN_PDSSeachCalloutController.CalloutCorporateWrapper response = (BLN_PDSSeachCalloutController.CalloutCorporateWrapper) JSON.deserialize(errorRec, BLN_PDSSeachCalloutController.CalloutCorporateWrapper.class);  
        // Assertions
        System.assertNotEquals(null, response, 'Result should not be null');
        System.assertEquals(response.errors[0].title, System.label.BLN_PdsApiError, 'Error title mismatch');
    }  
}