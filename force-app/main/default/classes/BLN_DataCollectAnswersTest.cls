@isTest
private class BLN_DataCollectAnswersTest {

    @isTest
    static void testGetPreviousAnswers() {
        // Create a test Case
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        Case testCase =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        testCase.AccountId = accountObj.Id;
        testCase.BLN_SubType__c = 'Warranty';
        INSERT testCase;
        
        // Create test DataCollectAnswer records related to the test Case
        List<BLN_DataCollectAnswer__c> testAnswers = new List<BLN_DataCollectAnswer__c>();
        for(Integer i = 0; i < 5; i++) {
            testAnswers.add(new BLN_DataCollectAnswer__c(
                BLN_Case__c = testCase.Id
            ));
        }
        insert testAnswers;
        
        // Call the method to test
        Test.startTest();
        List<BLN_DataCollectAnswer__c> result = BLN_DataCollectAnswers.getPreviousAnswers(testCase.Id, '3');
        Test.stopTest();
        
       // System.assertEquals(3, result.size(), 'result matched');
        
    }
    @isTest
    static void getDataCollectAnswerTest() {
          // Create an account
        Account accRec= new Account();
        accRec.name = 'test';
        accRec.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BLN_CustomerB2BAccount').getRecordTypeId();        
        insert accRec;
           // Create account rule parameter
        String dataCollectRecType = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Data Collect').getRecordTypeId();
        
        BLN_AccountRuleParameter__c dataCollectArp = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec.Id,
            RecordTypeId = dataCollectRecType,
            BLN_ActiveFrom__c = System.now().addDays(-1).date(),
			BLN_ActiveTo__c = System.Date.today(),
            BLN_Mandatory__c = 'Mandatory for Quality Booking'
        );
        insert dataCollectArp;
        Case testCase =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        testCase.AccountId = accRec.Id;
        testCase.BLN_SubType__c = 'Job Request';
        INSERT testCase;
        
        BLN_DataCollectAnswer__c dataCollAns = new BLN_DataCollectAnswer__c(
            BLN_Question__c = dataCollectArp.Id,
            BLN_Case__c = testCase.Id
           
        );
        insert dataCollAns;
        test.startTest();
        boolean archeck = BLN_DataCollectAnswers.getDataCollectAnswer(new List<String>{accRec.Id}, testCase.Id);
        test.stopTest();
        System.assertEquals(archeck, false, 'mandatory answers not given');
    }
    
    @isTest
    static void testSubmitButtonOnClick(){

        Account accountObj= new Account();
        accountObj.name = 'test';
        accountObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BLN_CustomerB2BAccount').getRecordTypeId();        
        insert accountObj;
        Case testCase =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        testCase.AccountId = accountObj.Id;
        testCase.BLN_SubType__c = 'Job Request';
        INSERT testCase;
        String dataCollectRecType = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Data Collect').getRecordTypeId();

        BLN_AccountRuleParameter__c dataCollectArp = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accountObj.Id,
            RecordTypeId = dataCollectRecType,
            BLN_ActiveFrom__c = System.now().addDays(-1).date(),
			BLN_ActiveTo__c = System.Date.today(),
            BLN_Mandatory__c = 'Mandatory for Quality Booking'
        );
        insert dataCollectArp;

        BLN_DataCollectAnswer__c dataCollAns = new BLN_DataCollectAnswer__c(
            BLN_Question__c = dataCollectArp.Id,
            BLN_Answer__c = 'Test Answer',
            BLN_Case__c = testCase.Id
        );
        insert dataCollAns;
        
        Test.startTest();
        BLN_DataCollectAnswers.submitButtonOnClick(testCase.Id, new List<String>{accountObj.Id});
        Test.stopTest();
        
        Case updatedCase = [SELECT BLN_ARCheck2__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(true, updatedCase.BLN_ARCheck2__c, 'Case Record updated');

    }


    @isTest
    static void getCaseClosureDataCollectAnsTest() {
          // Create an account
         Account accRec= new Account();
        accRec.name = 'test';
        accRec.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BLN_CustomerB2BAccount').getRecordTypeId();        
        insert accRec;
        
         BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;

        BLN_Corporate__c corporate=BLN_TestDataFactory.createcorporate();
        corporate.BLN_InsuranceSite__c = accRec.id;
         corporate.BLN_Vehicle__c = veh.id;
        insert corporate;
        
        Case testCase =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        testCase.AccountId = accRec.Id;
        testCase.BLN_Corporate__c = corporate.Id;
        testCase.BLN_SubType__c = 'Warranty';
        insert testCase;
           // Create account rule parameter
        String dataCollectRecType = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Data Collect').getRecordTypeId();
        
        BLN_AccountRuleParameter__c dataCollectArp = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec.Id,
            RecordTypeId = dataCollectRecType,
            BLN_ActiveFrom__c = System.now().addDays(-1).date(),
			BLN_ActiveTo__c = System.Date.today(),
            BLN_Mandatory__c = 'Mandatory for Case Closure'
        );
        insert dataCollectArp;

        BLN_DataCollectAnswer__c dataCollAns = new BLN_DataCollectAnswer__c(
            BLN_Question__c = dataCollectArp.Id

        );
        insert dataCollAns;
         List<String> caseIds = new List<String>{testCase.Id};
        test.startTest();
        List<string> isBlankAnswer = BLN_DataCollectAnswers.getCaseClosureDataCollectAns(caseIds);
        test.stopTest();
        System.assertNOTEquals(isBlankAnswer.size()>0, true, 'Data collect answer fetched');
    }
    
    @isTest
    static void testUpdateDataCollTask() {
       
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.BLN_SubType__c='Job Request';
        
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        insert cse;
        
         String caseRecordId =cse.id;
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(label.BLN_BVTRecordType).getRecordTypeId();

        Task taskRecord = new Task();
        taskRecord.recordtypeId = taskRecordTypeId;
        taskRecord.BLN_Subtype__c = 'BVT';
        taskRecord.Subject = 'BVT';
        taskRecord.WhatId = caseRecordId;
        taskRecord.BLN_TaskSubjectType__c = 'Data Collect';
        insert taskRecord;
        
        Test.startTest();
        String taskId = BLN_DataCollectAnswers.createdDataCollectTask(caseRecordId);
        Test.stopTest();
        
        // Assert the result
        System.assertNotEquals(taskId==null, true, 'task not updated');
        
    }

    @isTest
    static void testCreateDataCollTask() {
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.BLN_SubType__c='Job Request';
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        insert cse;
        
        String caseRecordId =cse.id;
        Test.startTest();
        String taskId = BLN_DataCollectAnswers.createdDataCollectTask(caseRecordId);
        Test.stopTest();
        
        // Assert the result
        System.assertNotEquals(taskId==null, true, 'task not created');
        
    }

    @isTest
    static void testGetSiteAccountNames(){
        Account accRec= new Account();
        accRec.name = 'test';
        accRec.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BLN_CustomerB2BAccount').getRecordTypeId();        
        insert accRec;

        Account accRec2= new Account();
        accRec2.name = 'test 2';
        accRec2.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BLN_CustomerB2BAccount').getRecordTypeId();        
        insert accRec2;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;

        String splitBillRecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'BLN_SpiltBill' WITH SECURITY_ENFORCED LIMIT 1].Id;
        String corporateRecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'BLN_CorporateFleet' WITH SECURITY_ENFORCED LIMIT 1].Id;
        String insuranceRecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'BLN_Insurance' WITH SECURITY_ENFORCED LIMIT 1].Id;



        BLN_Corporate__c corporate1=BLN_TestDataFactory.createcorporate();
        corporate1.BLN_CorporateSite__c = accRec.Id;
        corporate1.BLN_InsuranceSite__c = accRec2.id;
        corporate1.BLN_Vehicle__c = veh.id;
        corporate1.RecordTypeId = splitBillRecordTypeId;
        insert corporate1;

        BLN_Corporate__c corporate2 = BLN_TestDataFactory.createcorporate();
        corporate2.BLN_CorporateSite__c = accRec.Id;
        corporate2.BLN_InsuranceSite__c = accRec2.id;
        corporate2.BLN_Vehicle__c = veh.id;
        corporate2.RecordTypeId = corporateRecordTypeId;
        insert corporate2;

        BLN_Corporate__c corporate3 = BLN_TestDataFactory.createcorporate();
        corporate3.BLN_CorporateSite__c = accRec.Id;
        corporate3.BLN_InsuranceSite__c = accRec2.id;
        corporate3.BLN_Vehicle__c = veh.id;
        corporate3.RecordTypeId = insuranceRecordTypeId;
        insert corporate3;

        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.BLN_SubType__c='Job Request';
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        cse.BLN_Corporate__c = corporate1.Id;
        insert cse;

        Test.startTest();
        BLN_DataCollectAnswers.SiteAccountNameWrapper resultWrapper1 = BLN_DataCollectAnswers.getSiteAccountNames(accRec.Id, accRec2.Id, 'both');

        cse.BLN_Corporate__c = corporate2.Id;
        update cse;
        BLN_DataCollectAnswers.SiteAccountNameWrapper resultWrapper2 = BLN_DataCollectAnswers.getSiteAccountNames(accRec.Id, accRec2.Id, 'corporate');

        cse.BLN_Corporate__c = corporate3.Id;
        update cse;
        BLN_DataCollectAnswers.SiteAccountNameWrapper resultWrapper3 = BLN_DataCollectAnswers.getSiteAccountNames(accRec.Id, accRec2.Id, 'insurance');
        Test.stopTest();

        system.assertEquals('test', resultWrapper1.corporateSiteName, 'Corporate Site name should be test');
        system.assertEquals('test 2', resultWrapper1.insuranceSiteName, 'Insurance Site name should be test 2');

        system.assertEquals('test', resultWrapper2.corporateSiteName, 'Corporate Site name should be test');

        system.assertEquals('test', resultWrapper3.insuranceSiteName, 'Insurance Site name should be test 2');

    }

    @isTest
    static void testCheckAnswerRecords(){
        Account accRec= new Account();
        accRec.name = 'test';
        accRec.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BLN_CustomerB2BAccount').getRecordTypeId();        
        insert accRec;

        Account accRec2= new Account();
        accRec2.name = 'test 2';
        accRec2.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BLN_CustomerB2BAccount').getRecordTypeId();        
        insert accRec2;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;

        String splitBillRecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'BLN_SpiltBill' WITH SECURITY_ENFORCED LIMIT 1].Id;



        BLN_Corporate__c corporate1=BLN_TestDataFactory.createcorporate();
        corporate1.BLN_CorporateSite__c = accRec.Id;
        corporate1.BLN_InsuranceSite__c = accRec2.id;
        corporate1.BLN_Vehicle__c = veh.id;
        corporate1.RecordTypeId = splitBillRecordTypeId;
        insert corporate1;

        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.BLN_SubType__c='Job Request';
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        cse.BLN_Corporate__c = corporate1.Id;
        insert cse;


        Test.startTest();
        Boolean result = BLN_DataCollectAnswers.checkAnswerRecords(cse.Id, accRec.Id, accRec2.Id);

        BLN_AccountRuleParameter__c acpTest = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec.Id,
            BLN_InsurerAccount__c = accRec.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_DataCollect').getRecordTypeId()
        );
        insert acpTest;

        BLN_AccountRuleParameter__c acpTest2 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec2.Id,
            BLN_InsurerAccount__c = accRec.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_DataCollect').getRecordTypeId()
        );
        insert acpTest2;

        BLN_DataCollectAnswer__c newAnswerRecord = new BLN_DataCollectAnswer__c();
        newAnswerRecord.BLN_Case__c = cse.Id;
        newAnswerRecord.BLN_Question__c = acpTest.Id;
        insert newAnswerRecord;


        BLN_DataCollectAnswers.checkAnswerRecords(cse.Id, accRec.Id, accRec2.Id);

        Test.stopTest();

        system.assertEquals(false, result, 'Value should be false');
    }
}