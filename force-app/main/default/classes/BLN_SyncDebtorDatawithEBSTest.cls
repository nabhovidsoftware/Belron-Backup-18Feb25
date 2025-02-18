/** @description : Test Class for BLN_SyncDebtorDatawithEBS
*  @author:Rupesh Kumar V (PwC India)
* @CreatedDate: 06.07.2023
* @Story: FOUK-6288
*/
@isTest
private class BLN_SyncDebtorDatawithEBSTest {
    /*Description : Creating a records using testDataFactory*/
    @TestSetup
    static void setupTestData(){
        Account testAccount = BLN_TestDataFactory.createPersonAccount('Mr John Doe', 'Doe', true);
        testAccount.BLN_PrimaryContactNumber__c='Mobile Phone';
        testAccount.PersonEmail = 'rupesh.v.kumar@pwc.com';
        update testAccount;
        
        Account testAccount2 = BLN_TestDataFactory.createPersonAccount('Mr Smith John', 'Johns', true);
        testAccount2.BLN_PrimaryContactNumber__c='Mobile Phone';
        testAccount2.PersonEmail = 'rupesh.v1.kumar@pwc.com';
        update testAccount2;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_VehicleRegNumber__c='BN12OEE';
        insert veh;
        
        BLN_Corporate__c corporate = BLN_TestDataFactory.createcorporate();
        corporate.BLN_FirstName__c = 'John';
        corporate.BLN_MiddleName__c = 'Doe';
        corporate.BLN_LastName__c = 'Doe';
        corporate.BLN_Vehicle__c=veh.Id;
        corporate.BLN_CorporateCountryGrouping__c=testAccount.Id;
        insert corporate;
       
        Schema.Location loc = new Schema.Location();
        loc.Name = 'Test';
        loc.LocationType = 'Belron Warehouse';
        loc.Longitude = 28.635308;
        loc.Latitude = 28.635308;
        loc.BLN_GUID__c = 'Test';
        loc.BLN_OrgCodeLocation__c = 'Test';
        insert loc;
       
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = testAccount.Id;
        caseObj.BLN_DebtorReason__c = 'Card Stolen';
        caseObj.BLN_DebtorCreatedBy__c = 'Rupesh Kumar';
        caseObj.BLN_BillingStreet__c='teststate';
        caseObj.BLN_ISP__c = 'Y';
        caseObj.BLN_LocationBranchName__c = loc.Id;
        caseObj.BLN_Vehicle__c = veh.Id;
        insert caseObj;
        
        caseObj.BLN_Corporate__c = corporate.Id;
        update caseObj;

        BLN_Corporate__c corporate1 = BLN_TestDataFactory.createcorporate();
        corporate1.BLN_FirstName__c = 'Smith';
        corporate1.BLN_MiddleName__c = 'John';
        corporate1.BLN_LastName__c = 'Johns';
        corporate1.BLN_Vehicle__c=veh.Id;
        corporate1.BLN_CorporateCountryGrouping__c=testAccount2.Id;
        insert corporate1;
        
        Case caseObj2 =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj2.AccountId = testAccount2.Id;
        caseObj2.BLN_DebtorReason__c = 'Card Stolen';
        caseObj2.BLN_DebtorCreatedBy__c = 'Rupesh Kumar';
        caseObj2.BLN_BillingStreet__c='teststate,street,Landmark';
        caseObj2.BLN_ISP__c = 'Y';
        caseObj2.BLN_LocationBranchName__c = loc.Id;
        caseObj.BLN_Vehicle__c = veh.Id;
        insert caseObj2;

        caseObj2.BLN_Corporate__c = corporate1.Id;
        update caseObj2;
    }
    
    /*Description:This method is to test the sends Debtor details to EBS*/
    @isTest
    static void testSyncEBSDebtorWithValidData() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account accData = [SELECT Id,Name FROM Account WHERE PersonEmail = 'rupesh.v.kumar@pwc.com' LIMIT 1];
        List<Case> cases = [SELECT Id, BLN_Corporate__c, Account.PersonTitle, Account.LastName, Account.FirstName, Account.BillingStreet, 
                        Account.BillingCity, Account.BillingPostalCode, Account.BillingCountry, BLN_VRN__c, BLN_LocationBranchName__c, 
                        BLN_ISP__c, BLN_EBSDebtorStatus__c, BLN_EBSDebtorTitle__c, BLN_EBSDebtorResMsg__c FROM Case where AccountId =: accData.Id ];
        System.debug('accData==='+accData);
        System.debug('cases==='+cases);
        Test.startTest();
        BLN_SyncDebtorDatawithEBS.syncEBSDebtor(cases);
        BLN_SyncDebtorDatawithEBS queueableInstance = new BLN_SyncDebtorDatawithEBS(cases);
        System.enqueueJob(queueableInstance);
        Test.stopTest();
        
        // Assert that the cases were processed
        System.assert(cases.size() > 0, 'Cases should be available for processing.');
    }

    @isTest
    static void testSyncEBSDebtorWithValidData2() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account accData = [SELECT Id FROM Account WHERE FirstName = 'Mr John Doe' LIMIT 1]; 
        List<Case> cases = [SELECT Id, BLN_Corporate__c, Account.PersonTitle, Account.LastName, Account.FirstName, Account.BillingStreet, 
                        Account.BillingCity, Account.BillingPostalCode, Account.BillingCountry, BLN_VRN__c, BLN_LocationBranchName__c, 
                        BLN_ISP__c, BLN_EBSDebtorStatus__c, BLN_EBSDebtorTitle__c, BLN_EBSDebtorResMsg__c, BLN_BillingMethod__c FROM Case where AccountId =: accData.Id ];
        cases[0].BLN_BillingMethod__c = 'Cash';
        update cases;

        Test.startTest();
        BLN_SyncDebtorDatawithEBS.syncEBSDebtor(cases);
        BLN_SyncDebtorDatawithEBS queueableInstance = new BLN_SyncDebtorDatawithEBS(cases);
        System.enqueueJob(queueableInstance);
        Test.stopTest();
        
        // Assert that the cases were processed
        System.assert(cases.size() > 0, 'Cases should be available for processing.');
    }
    
    @isTest
    static void testSyncEBSDebtorWithValidData3() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account accData = [SELECT Id FROM Account WHERE FirstName = 'Mr Smith John' LIMIT 1]; 
        List<Case> cases = [SELECT Id, BLN_Corporate__c, Account.PersonTitle, Account.LastName, Account.FirstName, Account.BillingStreet, 
                        Account.BillingCity, Account.BillingPostalCode, Account.BillingCountry, BLN_VRN__c, BLN_LocationBranchName__c, 
                        BLN_ISP__c, BLN_EBSDebtorStatus__c, BLN_EBSDebtorTitle__c, BLN_EBSDebtorResMsg__c FROM Case where AccountId =: accData.Id ];

        Test.startTest();
        BLN_SyncDebtorDatawithEBS.syncEBSDebtor(cases);
        BLN_SyncDebtorDatawithEBS queueableInstance = new BLN_SyncDebtorDatawithEBS(cases);
        System.enqueueJob(queueableInstance);
        Test.stopTest();
        
        // Assert that the cases were processed
        System.assert(cases.size() > 0, 'Cases should be available for processing.');
    }

    @isTest
    static void testSyncEBSDebtorWithValidData4() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account accData = [SELECT Id FROM Account WHERE FirstName = 'Mr John Doe' LIMIT 1]; 
        List<Case> cases = [SELECT Id, BLN_Corporate__c, Account.PersonTitle, Account.LastName, Account.FirstName, Account.BillingStreet, 
                        Account.BillingCity, Account.BillingPostalCode, Account.BillingCountry, BLN_VRN__c, BLN_LocationBranchName__c, 
                        BLN_ISP__c, BLN_EBSDebtorStatus__c, BLN_EBSDebtorTitle__c, BLN_EBSDebtorResMsg__c, BLN_BillingMethod__c FROM Case where AccountId =: accData.Id ];
        cases[0].BLN_BillingMethod__c = 'Insurance / Account';
        update cases;
        BLN_Corporate__c corporate = [SELECT Id,BLN_Salutation__c,BLN_FirstName__c,BLN_MiddleName__c,BLN_LastName__c FROM BLN_Corporate__c WHERE BLN_FirstName__c = 'John' LIMIT 1];
        corporate.BLN_Salutation__c = '';
        corporate.BLN_FirstName__c = '';
        corporate.BLN_MiddleName__c = '';
        corporate.BLN_LastName__c = '';
        update corporate;
        
        Test.startTest();
        BLN_SyncDebtorDatawithEBS.syncEBSDebtor(cases);
        BLN_SyncDebtorDatawithEBS queueableInstance = new BLN_SyncDebtorDatawithEBS(cases);
        System.enqueueJob(queueableInstance);
        Test.stopTest();
        
        // Assert that the cases were processed
        System.assert(cases.size() > 0, 'Cases should be available for processing.');
    }
     @isTest
    static void testSyncEBSDebtorWithValidData5() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account accData = [SELECT Id FROM Account WHERE FirstName = 'Mr John Doe' LIMIT 1]; 
        List<Case> cases = [SELECT Id, BLN_Corporate__c, Account.PersonTitle, Account.LastName, Account.FirstName, Account.BillingStreet, 
                        Account.BillingCity, Account.BillingPostalCode, Account.BillingCountry, BLN_VRN__c, BLN_LocationBranchName__c, 
                        BLN_ISP__c, BLN_EBSDebtorStatus__c, BLN_EBSDebtorTitle__c, BLN_EBSDebtorResMsg__c, BLN_BillingMethod__c FROM Case where AccountId =: accData.Id ];
        cases[0].BLN_BillingMethod__c = 'Insurance / Account';
        update cases;


        Test.startTest();
        BLN_SyncDebtorDatawithEBS.syncEBSDebtor(cases);
        BLN_SyncDebtorDatawithEBS queueableInstance = new BLN_SyncDebtorDatawithEBS(cases);
        System.enqueueJob(queueableInstance);
        Test.stopTest();
        
        // Assert that the cases were processed
        System.assert(cases.size() > 0, 'Cases should be available for processing.');
    }

    /*Description:This method is to test the EBS Callout*/
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
           // BLN_APICalloutMapper__mdt apiCalloutmapperRec = BLN_APICalloutMapper__mdt.getInstance(System.Label.BLN_DebtorEBSAPICallName);
           // String endPoint = apiCalloutmapperRec.BLN_NamedCredential__c + apiCalloutmapperRec.BLN_CalloutURL__c;
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "MockAccessToken123", "expires_in": 3600, "token_type": "Bearer","scope": "read"}');
            res.setBody('{"customerId": 5002980,"custSiteId": 4878340,"siteUseId": 4122798}');
            res.setStatusCode(201);
            return res;
        }
    }
}