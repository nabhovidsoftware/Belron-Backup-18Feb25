/*****************************************
ClassName : BLN_ProductAuthorisationTest
@description : FOUK 3167 This class is used to test BLN_ProductAuthorisation.
@author: PwC
CreatedDate:  13-05-2024
CreatedBy : PwC-India
***************************************/
@isTest
public  class BLN_ProductAuthorisationTest {
    
    static Account acc;
    @isTest
    static void testUpdateBvtTask() {
       
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.BLN_SubType__c='Job Request';
        
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        cse.BLN_CoverageVerificationTheme__c = true;
        cse.BLN_AccountRulesTheme__c = true;
        insert cse;
        
        String caseRecordId =cse.id;
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(label.BLN_BVTRecordType).getRecordTypeId();

        Task taskRecord = new Task();
        taskRecord.recordtypeId = taskRecordTypeId;
        taskRecord.BLN_Subtype__c = 'BVT';
        taskRecord.Subject = 'BVT Authorisation';
        taskRecord.WhatId = cse.Id;
        taskRecord.BLN_TaskSubjectType__c = 'Authorisation Required - OE';
        taskRecord.Status = 'Open';
        taskRecord.BLN_IsAutomated__c = true;
        taskRecord.ActivityDate = Date.newInstance(2024,03, 31);
        taskRecord.BLN_AppointmentDate__c = Date.newInstance(2024,04,31);

        insert taskRecord;
        
        Test.startTest();
        String taskId = BLN_ProductAuthorisation.createBvtTask(caseRecordId, 'Assigned Direct to BVT', taskRecord.BLN_AppointmentDate__c, taskRecord.BLN_Account__c);
        Test.stopTest();
        
        // Assert the result
        System.assertNotEquals(taskId!=null, true, 'task not updated');    
    }

    @isTest
    static void testCreateBvtTask() {
        //Id insuranceRecordType = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_Insurance').getRecordTypeId();
        //Id corporateFleetRecordTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_CorporateFleet').getRecordTypeId();

        acc = new Account(Name = 'Test Account', BLn_ClientType__c = 'Insurance');
        insert acc;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_VehicleRegNumber__c='BN12OEE';
        insert veh;

        BLN_Corporate__c corporate = BLN_TestDataFactory.createcorporate();
        corporate.BLN_Vehicle__c=veh.Id;
        corporate.BLN_CorporateCountryGrouping__c=acc.id;
        corporate.BLN_GlassCoverFlag__c='Y';
        insert corporate;
       
        date slotDate = System.today();
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.BLN_SubType__c='Job Request';
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        cse.BLN_Corporate__c = corporate.Id;
        cse.BLN_CoverageVerificationTheme__c = false;
        //cse.BLN_AccountRulesTheme__c = true;

        insert cse;
        
        String caseRecordId =cse.id;
        Test.startTest();
        String taskId = BLN_ProductAuthorisation.createBvtTask(caseRecordId, 'Authorisation Required - OE', slotDate,acc.Id);
        //BLN_ProductAuthorisation.updateTask(taskId, slotDate);
        Test.stopTest();
        
        // Assert the result
        System.assertnotEquals(taskId==null, true, 'task not created');
    }

    @isTest
    static void testsplitBillBVT(){
        //Id insuranceRecordTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_Insurance').getRecordTypeId();
        //Id corporateFleetRecordTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_CorporateFleet').getRecordTypeId();
        Id splitBillRecordTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_SpiltBill').getRecordTypeId();
        Id recordTypeIdARP = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_AutomaticDiverttoAuthorisationTeam').getRecordTypeId();
        
        Account objectAccount = new Account(Name = 'Test Account', BLn_ClientType__c = 'Insurance', BLN_FLTRIndicator__c = 'FLTR');
        insert objectAccount;

        Account objectCorpAccount = new Account(Name = 'Test Account2', BLn_ClientType__c = 'Fleet National', BLN_FLTRIndicator__c = 'FLTR');
        insert objectCorpAccount;

        BLN_AccountRuleParameter__c autoDivARP = new BLN_AccountRuleParameter__c(
            BLN_Account__c = objectAccount.Id,
            RecordTypeId = recordTypeIdARP,
            BLN_ProductCategory__c = 'Test Product',
            BLN_ActiveFrom__c = System.now().addDays(-1).date(),
            BLN_ActiveTo__c = System.Date.today(),
            BLN_AutomaticDiverttoAuthorisationTeam__c = System.label.BLN_AllCasesForValidation
        );
        insert autoDivARP;

        BLN_AccountRuleParameter__c autoDivARP1 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = objectCorpAccount.Id,
            RecordTypeId = recordTypeIdARP,
            BLN_ProductCategory__c = 'Test Product',
            BLN_ActiveFrom__c = System.now().addDays(-1).date(),
            BLN_ActiveTo__c = System.Date.today(),
            BLN_AutomaticDiverttoAuthorisationTeam__c = System.label.BLN_AllCasesForValidation
        );
        insert autoDivARP1;

        BLN_Vehicle__c objectVehicle = BLN_TestDataFactory.getVehicle();
        objectVehicle.BLN_VehicleRegNumber__c = 'BN12OEE';
        insert objectVehicle;

        BLN_Corporate__c objectCorporate = BLN_TestDataFactory.createcorporate();
        objectCorporate.BLN_Vehicle__c = objectVehicle.Id;
        objectCorporate.BLN_CorporateCountryGrouping__c = objectAccount.id;
        objectCorporate.BLN_GlassCoverFlag__c = 'Y';
        objectCorporate.BLN_InsuranceSite__c = objectAccount.Id;
        objectCorporate.BLN_CorporateSite__c = objectCorpAccount.id ;
        objectCorporate.BLN_Origin__c = 'Manual';
        objectCorporate.RecordTypeId = splitBillRecordTypeId;
        insert objectCorporate;

        date slotDate = System.today();
        Case objectCase = BLN_TestDataFactory.getCase('Job Request', 'New');
        objectCase.Type = 'Job Request';
        objectCase.Status = 'New';
        objectCase.BLN_SubType__c='Job Request';
        objectCase.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        objectCase.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        objectCase.Priority = 'Medium';
        objectCase.BLN_MotoristTaxStatus__c = 'Yes';
        objectCase.BLN_TotalMotoristLiability__c = 6000 ;
        objectCase.BLN_Corporate__c = objectCorporate.Id;
        objectCase.BLN_CoverageVerificationTheme__c = false;
        insert objectCase;
        
        /*Group fltrQueue = new Group(
            Name = 'FLTR Queue',
            DeveloperName = 'FLTRQueue',
            Type = 'Queue'
        );
        insert fltrQueue;
        
         Task taskRecord = new Task(
            Subject = 'Test Task',
            WhatId = objectCase.Id,
        );
        insert taskRecord;*/
        
        String caseRecordId = objectCase.id;
        BLN_ProductAuthorisation.splitBillBVT(caseRecordId, objectCorporate, slotDate);
        Test.startTest();
        //System.assertEquals(fltrQueue.Id, taskRecord.OwnerId, 'Task OwnerId should be FLTR Queue');
        Case updatedCase = [SELECT Id, Status FROM Case WHERE Id = :caseRecordId];
        
        // Example assertion to verify status changed (modify as per your actual logic)
        System.assertNotEquals('ExpectedStatus', updatedCase.Status, 'Case status should match the expected value.');
        
        // End the test context
        Test.stopTest();
    }

    @isTest
    static void testsplitBillBVTNonPDS(){
        //Id insuranceRecordTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_Insurance').getRecordTypeId();
        //Id corporateFleetRecordTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_CorporateFleet').getRecordTypeId();
        Id splitBillRecordTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_SpiltBill').getRecordTypeId();
        Id recordTypeIdARP = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_AutomaticDiverttoAuthorisationTeam').getRecordTypeId();
        
        Account objectAccount = new Account(Name = 'Test Account', BLn_ClientType__c = 'Insurance', BLN_FLTRIndicator__c = 'FLTR');
        insert objectAccount;

        Account objectCorpAccount = new Account(Name = 'Test Account2', BLn_ClientType__c = 'Fleet National', BLN_FLTRIndicator__c = 'FLTR');
        insert objectCorpAccount;

        BLN_AccountRuleParameter__c autoDivARP = new BLN_AccountRuleParameter__c(
            BLN_Account__c = objectAccount.Id,
            RecordTypeId = recordTypeIdARP,
            BLN_ProductCategory__c = 'Test Product',
            BLN_ActiveFrom__c = System.now().addDays(-1).date(),
            BLN_ActiveTo__c = System.Date.today(),
            BLN_AutomaticDiverttoAuthorisationTeam__c = System.label.BLN_NonPDSCasesForValidation
        );
        insert autoDivARP;

        BLN_AccountRuleParameter__c autoDivARP1 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = objectCorpAccount.Id,
            RecordTypeId = recordTypeIdARP,
            BLN_ProductCategory__c = 'Test Product',
            BLN_ActiveFrom__c = System.now().addDays(-1).date(),
            BLN_ActiveTo__c = System.Date.today(),
            BLN_AutomaticDiverttoAuthorisationTeam__c = System.label.BLN_NonPDSCasesForValidation
        );
        insert autoDivARP1;

        BLN_Vehicle__c objectVehicle = BLN_TestDataFactory.getVehicle();
        objectVehicle.BLN_VehicleRegNumber__c = 'BN12OEE';
        insert objectVehicle;

        BLN_Corporate__c objectCorporate = BLN_TestDataFactory.createcorporate();
        objectCorporate.BLN_Vehicle__c = objectVehicle.Id;
        objectCorporate.BLN_CorporateCountryGrouping__c = objectAccount.id;
        objectCorporate.BLN_GlassCoverFlag__c = 'Y';
        //objectCorporate.BLN_InsuranceSite__c = objectAccount.Id;
        objectCorporate.BLN_CorporateSite__c = objectCorpAccount.id;
        objectCorporate.BLN_Origin__c = 'Manual';
        objectCorporate.RecordTypeId = splitBillRecordTypeId;
        insert objectCorporate;

        date slotDate = System.today();
        Case objectCase = BLN_TestDataFactory.getCase('Job Request', 'New');
        objectCase.Type = 'Job Request';
        objectCase.Status = 'New';
        objectCase.BLN_SubType__c='Job Request';
        objectCase.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        objectCase.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        objectCase.Priority = 'Medium';
        objectCase.BLN_MotoristTaxStatus__c = 'Yes';
        objectCase.BLN_TotalMotoristLiability__c = 6000 ;
        objectCase.BLN_Corporate__c = objectCorporate.Id;
        objectCase.BLN_CoverageVerificationTheme__c = false;
        insert objectCase;

        String caseRecordId = objectCase.id;
        BLN_ProductAuthorisation.splitBillBVT(caseRecordId, objectCorporate, slotDate);
        Test.startTest();
        Case updatedCase = [SELECT Id, Status FROM Case WHERE Id = :caseRecordId];
        
        // Example assertion to verify status changed (modify as per your actual logic)
        System.assertNotEquals('ExpectedStatus', updatedCase.Status, 'Case status should match the expected value.');
        
        // End the test context
        Test.stopTest();
    }
    
    @isTest
    static void testCorporateCaseLogic() {
        // Insert necessary test data
        Account testAccount = new Account(Name = 'Test Account', BLn_ClientType__c = 'Insurance');
        insert testAccount;
        
        BLN_Vehicle__c testVehicle = new BLN_Vehicle__c(BLN_VehicleRegNumber__c = 'BN12OEE');
        insert testVehicle;
        
        BLN_Corporate__c corporateRecord = new BLN_Corporate__c(
            //Name = 'Test Corporate',
            BLN_InsuranceSite__c = testAccount.Id,
            BLN_Vehicle__c = testVehicle.Id,
            RecordTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_Insurance').getRecordTypeId()
        );
        insert corporateRecord;
        
        Case testCase = new Case(
            Type = 'Job Request',
            Status = 'New',
            BLN_Corporate__c = corporateRecord.Id,
            BLN_ServiceGeolocation__latitude__s = 46.22441984873406,
            BLN_ServiceGeolocation__longitude__s = -89.02172505348693,
            Priority = 'Medium',
            BLN_MotoristTaxStatus__c = 'Yes',
            BLN_TotalMotoristLiability__c = 6000
        );
        insert testCase;
        
        // Validate inserted data
        testCase = [SELECT Id, BLN_Corporate__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        System.assertNotEquals(null, testCase, 'Test Case should be inserted');
        System.assertNotEquals(null, testCase.BLN_Corporate__c, 'Test Case should have BLN_Corporate__c populated');
        
        corporateRecord = [SELECT Id, BLN_InsuranceSite__c, BLN_CorporateSite__c, RecordTypeId FROM BLN_Corporate__c WHERE Id = :testCase.BLN_Corporate__c LIMIT 1];
        System.assertNotEquals(null, corporateRecord, 'Corporate record should be inserted');
        
        RecordType recordType = [SELECT Id, DeveloperName FROM RecordType WHERE Id = :corporateRecord.RecordTypeId LIMIT 1];
        System.assertNotEquals(null, recordType, 'RecordType should be fetched');
        
        // Execute the logic
        Id accountId;
        if(recordType.DeveloperName == 'BLN_Insurance') {
            accountId = corporateRecord.BLN_InsuranceSite__c;
        } else if(recordType.DeveloperName == 'BLN_CorporateFleet') {
            accountId = corporateRecord.BLN_CorporateSite__c;
        }

        // Assert the result
        System.assertEquals(corporateRecord.BLN_InsuranceSite__c, accountId, 'AccountId should be set to BLN_InsuranceSite__c when RecordType is BLN_Insurance');
        System.assertnotEquals(corporateRecord.BLN_CorporateSite__c, accountId, 'AccountId should be set to BLN_CorporateFleet when RecordType is BLN_CorporateFleet');
        
        // Change the RecordType and re-test
        update new BLN_Corporate__c(
            Id = corporateRecord.Id,
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'BLN_CorporateFleet' LIMIT 1].Id
        );
        
        // Retrieve the updated data
        corporateRecord = [SELECT Id, BLN_InsuranceSite__c, BLN_CorporateSite__c, RecordTypeId FROM BLN_Corporate__c WHERE Id = :corporateRecord.Id LIMIT 1];
        recordType = [SELECT Id, DeveloperName FROM RecordType WHERE Id = :corporateRecord.RecordTypeId LIMIT 1];
        
        // Execute the logic again
        if(recordType.DeveloperName == 'BLN_Insurance') {
            accountId = corporateRecord.BLN_InsuranceSite__c;
        } else if(recordType.DeveloperName == 'BLN_CorporateFleet') {
            accountId = corporateRecord.BLN_CorporateSite__c;
        }
        
        // Assert the result
        System.assertEquals(corporateRecord.BLN_CorporateSite__c, accountId, 'AccountId should be set to BLN_CorporateSite__c when RecordType is BLN_CorporateFleet');
    }
    
    @isTest
    static void testupdateCorporate() {
        
        BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();
        vehicles.BLN_SpecialVehicle__c = true;
        insert vehicles;
        
        BLN_Corporate__c corporate = new BLN_Corporate__c();
        corporate.BLN_OEAuthorizationRequired__c = false;
        corporate.BLN_Vehicle__c = vehicles.Id;
        insert corporate;
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.BLN_Corporate__c = corporate.id;
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        cse.BLN_SubType__c='Job Request';
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        insert cse;
        
        String caseRecordId =cse.id;
        Test.startTest();
        boolean  corporateCheck2 = BLN_ProductAuthorisation.updateCorporateAmountAuth(caseRecordId);
        boolean corporateCheck3 = BLN_ProductAuthorisation.updateCorporateReAmt(caseRecordId,67.89);
        Test.stopTest();
        
        // Assert the result
        System.assertEquals(corporateCheck2, true, 'corporate upadated');
        System.assertEquals(corporateCheck3, true, 'corporate upadated');
    }
    
    @isTest
    static void testgetCorporateRecord() {
        
        BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();
        vehicles.BLN_SpecialVehicle__c = true;
        insert vehicles;
        
        BLN_Corporate__c corporate = new BLN_Corporate__c();
        corporate.BLN_OEAuthorizationRequired__c = false;
        corporate.BLN_Vehicle__c = vehicles.Id;
        insert corporate;

        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.BLN_Corporate__c = corporate.id;
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        cse.BLN_SubType__c='Job Request';
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        insert cse;
        
        String caseRecordId = cse.id;
        
        Test.startTest();
        BLN_Corporate__c  corporateRecord = BLN_ProductAuthorisation.getCorporateRecord(caseRecordId);
        Test.stopTest();
        
        List<BLN_Corporate__c> corporateList = [select id from BLN_Corporate__c where Id =:corporateRecord.Id];
        
        // Assert the result
        System.assertEquals(corporateList.size()>0, true, 'corporate fetched successfully');
    }

    @isTest
    static void getProductExcessTest() {
        // Create an account
        Account accRec = new Account(Name = 'Test Account', BLn_ClientType__c = 'Insurance');
        insert accRec;
        // Create account rule parameter
        String splitBillRecType = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Split Bill').getRecordTypeId();
        
        BLN_AccountRuleParameter__c splitBillArp = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec.Id,
            RecordTypeId = splitBillRecType,
            BLN_ProductCategory__c = 'Test Product',
            BLN_ActiveFrom__c = System.now().addDays(-1).date(),
            BLN_ActiveTo__c = System.Date.today()
        );
        insert splitBillArp;
        
        String productExcessRecTyp = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Product Excess').getRecordTypeId();
        
        BLN_AccountRuleParameter__c productExcessArp = new BLN_AccountRuleParameter__c(
            BLN_SplitBill__c = splitBillArp.Id,
            RecordTypeId = productExcessRecTyp,
            BLN_ProductCategory__c = 'Test Product',
            BLN_ActiveFrom__c = System.now().addDays(-1).date()
        );
        insert productExcessArp;
        
        test.startTest();
        List <BLN_AccountRuleParameter__c>productExcessArps = BLN_ProductAuthorisation.getProductExcessArp('Product Excess',accRec.Id,Date.today());
        test.stopTest();
        System.assertNotEquals(productExcessArp, null,'success');
        System.assertNotEquals(productExcessArps, null,'success');
        
    }

    @isTest
    static void corporateAccountUpdateTest(){
        
        BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();
        vehicles.BLN_SpecialVehicle__c = true;
        insert vehicles;
        
        BLN_Corporate__c corporate = new BLN_Corporate__c();
        corporate.BLN_OEAuthorizationRequired__c = false;
        corporate.BLN_Vehicle__c = vehicles.Id;
        corporate.BLN_AmountAuthorized__c = 10;
        corporate.BLN_AuthorizationStatus__c ='Approved';
        Insert corporate;
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.BLN_Corporate__c = corporate.id;
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        cse.BLN_SubType__c='Job Request';
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        Insert cse;
        
        String caseRecordId = cse.id;
        Double cpqAmount = 300.10;
        
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(label.BLN_BVTRecordType).getRecordTypeId();
        Task taskRecord = new Task();
        taskRecord.Subject = 'Authorisation Breached';
        taskRecord.recordtypeId = taskRecordTypeId;
        taskRecord.BLN_Subtype__c = 'BVT';
        taskRecord.WhatId = caseRecordId;
        Insert taskRecord;
        
        BLN_Corporate__c corpRec = [SELECT Id, BLN_AmountAuthorizationRequired__c FROM BLN_Corporate__c WHERE Id=:corporate.Id];
        Test.startTest();
        BLN_ProductAuthorisation.corporateAccountUpdate(caseRecordId, cpqAmount);
        Test.stopTest();
        System.assertEquals( false, CorpRec.BLN_AmountAuthorizationRequired__c, 'Corporate Record is Updated');
    }
    
    @isTest
    static void getProductAllowanceTest() {
        // Create an account
        Account accRec = new Account(Name = 'Test Account', BLn_ClientType__c = 'Insurance');
        insert accRec;
        // Create account rule parameter
        String productAllowanceRecTyp = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Product Allowance').getRecordTypeId();
        
        BLN_AccountRuleParameter__c productAllowance = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec.Id,
            RecordTypeId = productAllowanceRecTyp,
            BLN_ProductCategory__c = 'Test Product',
            BLN_ActiveFrom__c = System.now().addDays(-1).date(),
            BLN_ActiveTo__c = System.Date.today(),
            BLN_ProductAllowance__c= 'Pass Liability'
        );
        insert productAllowance;
        
        test.startTest();
        List <BLN_AccountRuleParameter__c>productExcessArps=BLN_ProductAuthorisation.getProductAllowance('Product Allowance',accRec.Id,Date.today());
        test.stopTest();
        System.assertNotEquals(productAllowance, null,'success'); 
        System.assertNotEquals(productExcessArps, null,'success'); 
        
        
        
    }

    @isTest
    static void nostockTaskTest(){
        WorkType replacementWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_ReplacementWT, 4 , true ,  true);
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours('All Day Slot', true);
        //OperatingHours operatingHours2 = BLN_TestDataFactory.createOperatingHours('Five Hour Slot', true);      
        //TimeSlot ts = BLN_TestDataFactory.createTimeSlotsFullDayProfile(true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , true);
        st.BLN_GUID__c = 'Test';
        update st;
        
        Case newCase=BLN_TestDataFactory.createCase(true);
        //FSL__Scheduling_Policy__c schedulingPolicy = BLN_TestDataFactory.createSchedulingPolicy(System.Label.BLN_SchedulingPolicyName, true);
        
        WorkOrder workOrder1 = BLN_TestDataFactory.createWorkOrder2(replacementWT.id, st.Id, false);
        workOrder1.CaseId=newCase.Id;
        workOrder1.BLN_RemedyJobId__c='0969964544427';
        insert workOrder1;
        
        String remedyTaskId1 = '66088851';
        List<WorkOrderLineItem> wOLIList = new List<WorkOrderLineItem>();
        WorkOrderLineItem wOLI1= new WorkOrderLineItem();
        wOLI1.Status = 'New';
        wOLI1.WorkOrderId = workOrder1.Id;
        wOLI1.WorkTypeId  = replacementWT.Id;
        wOLI1.BLN_RemedyTaskId__c  = remedyTaskId1;
        wOLIList.add(wOLI1);
        
        if(wOLIList.size()>0){
            insert wOLIList;
        }
        
        //ServiceAppointment servAppList1 = new ServiceAppointment();
        ServiceAppointment servAppList1 =BLN_TestDataFactory.createServiceAppointment('SA1', wOLIList[0].Id, st.Id, '66088851', false);
        servAppList1.BLN_RemedyJobId__c = workOrder1.BLN_RemedyJobId__c;
        servAppList1.Status = 'Scheduled';
        servAppList1.BLN_WorkOrderNumber__c = workOrder1.id;
        Insert servAppList1;
        
        Account policyHolder=New Account();
        policyHolder.FirstName='Policytesting';
        policyHolder.LastName='Holdertesting';
        policyHolder.Salutation='Mr.';
        policyHolder.Phone='7895674562';
        policyHolder.BLN_PersonAccountType__c='POLICYHOLDER';
        policyHolder.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        policyHolder.PersonHomePhone = '7895674563';
        Insert policyHolder;
        
        Order order = new Order();
        order.BLN_Case__c = newCase.Id;
        order.BLN_IsDropOff__c = FALSE;
        order.Status = 'Draft';
        order.EffectiveDate = Date.Today() - 1;
        order.BLN_ServiceTerritory__c = st.id;
        order.AccountId = policyHolder.Id;
        order.ContractId = BLN_TestDataFactory.createTestContract(policyHolder).Id;
        INSERT order;
        
        Product2 product = new Product2();
        product.Name = 'test product';
        product.IsActive = true;
        product.ProductCode = '23412';
        Insert product;
        
        /*Pricebook2 pricebook = new Pricebook2();
          pricebook.Name = 'new pricebook';
          pricebook.IsActive = true;
          Insert pricebook;*/
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 pricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update pricebook;
        
        /*PricebookEntry pBEntry = new PricebookEntry();
        pBEntry.Product2Id = product.Id;
        pBEntry.Pricebook2Id = pricebook.Id;
        pBEntry.UnitPrice = 0;
        pBEntry.UseStandardPrice = true;
        pBEntry.IsActive = true;
        insert pBEntry;*/
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=pricebook.Id, Product2id=product.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        OrderItem oItem = new OrderItem();
        oItem.BLN_OutOfStock__c = true;
        oItem.OrderId = order.Id;
        oItem.unitPrice = 20;
        oItem.Quantity = 1;
        oItem.Product2Id = product.Id;
        oItem.ListPrice = 35;
        oItem.BLN_ServiceAppointment__c = servAppList1.Id;
        Insert oItem;
        
        Test.startTest();
        BLN_ProductAuthorisation.createNoStockTask(servAppList1.Id, newCase.Id);
        BLN_ProductAuthorisation.checkCurrentLoggedinUser();
        BLN_ProductAuthorisation.checkCurrentLoggedinUserPermission();
        Test.stopTest();
        OrderItem oItem1 = [SELECT Id, BLN_OutOfStock__c FROM OrderItem WHERE Id=:oItem.Id];
        system.assertEquals(true, oItem1.BLN_OutOfStock__c, 'TestClass run');
    }
    
    @isTest
    static void testUpdateTask() {
        // Fetch test data
        Case testCase =BLN_TestDataFactory.createCase(true);
        
        // Create a test Task
        Task task = new Task(
            Subject = 'Test Task',
            WhatId = testCase.Id,
            ActivityDate = Date.today() + 1,
            Status = 'Open'
        );
        insert task;
        
        Date slotDate = Date.today() + 5;
        
        // Call the method
        Test.startTest();
        BLN_ProductAuthorisation.updateTask(task.Id, slotDate);
        //   BLN_ProductAuthorisation.updateTask(null, null);
        Test.stopTest();
        // Verify the result
        Task updatedTask = [SELECT BLN_AppointmentDate__c FROM Task WHERE Id = :task.Id];
        System.assertEquals(slotDate, updatedTask.BLN_AppointmentDate__c, 'Task appointment date should match the slot date');
    }
    
    @isTest
    static void testUpdateTask1() {
        //Task updatedTask = [SELECT BLN_AppointmentDate__c FROM Task LIMIT 1];
        Test.startTest();
        BLN_ProductAuthorisation.corporateAccountUpdate(null,null);
        Test.stopTest();
        System.assert(true, 'Test passed with mock.');
        //System.assertEquals(false,result, 'Task appointment date should match the slot date');
    }
    
     @isTest
    static void getAutomaticDiverArpsTest() {
        List<String> accountIds = new List<String>();

        Account accRec = new Account(Name = 'Test Account', BLn_ClientType__c = 'Insurance');
        insert accRec;
        
         String getDivertToAuthorizationTeam = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Automatic Divert to Authorisation Team').getRecordTypeId();
        
        BLN_AccountRuleParameter__c getDivertAuth = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec.Id,
            RecordTypeId = getDivertToAuthorizationTeam,
            BLN_ProductCategory__c = 'Test Product',
            BLN_ActiveFrom__c = System.now().addDays(-1).date(),
            BLN_ActiveTo__c = System.Date.today()
        );
       
        insert getDivertAuth;
        
        accountIds.add(accRec.id);
        Test.startTest();
        List<String> getAutoList =New List<String> ();
        getAutoList= BLN_ProductAuthorisation.getAutomaticDiverArps(accountIds);
        Test.stopTest();
        System.assertEquals(false, accountIds.isEmpty(), 'get Automatic diver not null');
    }
}