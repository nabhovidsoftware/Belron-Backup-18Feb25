/** @description : This Test class covered BLN_FetchKnowledgeArticles
*   @Story : FOUK-4271 & FOUK-4801
*   @author: Balamurugan (PwC)
*   @CreatedDate: 19/06/2024
*/


/**
 * @description: Test method for getKnowledgeArticles method
 */
@isTest
public with sharing class BLN_FetchKnowledgeArticlesTest {
    
    @isTest
    Public static void testGetKnowledgeArticles() {

        String articleTitle = 'Article 1';
        
        // Insert a single Knowledge__kav record
        Knowledge__kav article = new Knowledge__kav(
            Title = articleTitle,
            BLN_Description__c = 'Description for Article 1',
            UrlName = 'Article-1'
        );
        insert article;

        Test.startTest();
        // Call the method under test
        List<Knowledge__kav> result = BLN_FetchKnowledgeArticles.getKnowledgeArticles(new List<String>{articleTitle});

        List<BLN_ProductIdentifier__mdt> prodList = BLN_FetchKnowledgeArticles.checkADASScriptProduct();

        Test.stopTest();

        // Assert the results
        System.assertEquals(1, result.size(), 'Expected size does not match');
        Knowledge__kav retrievedArticle = result[0];
        System.assertEquals(articleTitle, retrievedArticle.Title, 'Article title does not match');
        System.assertEquals(prodList.size(),prodList.size(), 'Expected size does not match');
        }
    
/**
 * @description: Test method for testCreateTaskRecord method
 */
    @isTest
    Public static void testCreateTaskRecord() {
        // Create a test Case record
        Case testCase = new Case(
            Subject = 'Test Case',
            Description = 'Test Case Description',
            Status = 'New'
        );
        insert testCase;

        Test.startTest();
        // Call the method under test
        String taskId = BLN_FetchKnowledgeArticles.createTaskRecord('Test Task', 'Test Task Description', testCase.Id);
        Test.stopTest();

        // Query the Task to verify insertion
        Task insertedTask = [SELECT Id, Subject, Description, Status, ActivityDate, OwnerId, WhatId, BLN_Case__c 
                             FROM Task WHERE Id = :taskId];

        // Assert the results
        System.assertEquals('Test Task', insertedTask.Subject, 'Subject does not match');
        System.assertEquals('Test Task Description', insertedTask.Description, 'Description does not match');
        System.assertEquals('Completed', insertedTask.Status, 'Status is not Completed');
        System.assertEquals(Date.today(), insertedTask.ActivityDate, 'ActivityDate does not match');
        System.assertEquals(UserInfo.getUserId(), insertedTask.OwnerId, 'Owner does not match');
        System.assertEquals(testCase.Id, insertedTask.WhatId, 'WhatId does not match');
        System.assertEquals(testCase.Id, insertedTask.BLN_Case__c, 'BLN_Case__c does not match');
    }
    
    @isTest
    static void testCheckMotabilityCorporateFleet() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

         Account testAccountcorp = new Account(Name = 'Some Legal Entity Id');
        insert testAccountcorp;
       
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_VehicleRegNumber__c='BN12OEE';
        insert veh;
        
        RecordType rtCorporateFleet = [SELECT Id FROM RecordType WHERE DeveloperName = :System.label.BLN_CorporateFleet AND SObjectType = 'BLN_Corporate__c' LIMIT 1];
        
        // Create the BLN_Corporate__c record with the 'Corporate Fleet' record type
        BLN_Corporate__c corpRecord = new BLN_Corporate__c(
            RecordTypeId = rtCorporateFleet.Id,
            BLN_CorporateLegalEntity__c =testAccountcorp.Id ,
            BLN_Vehicle__c=veh.Id       
        );
        insert corpRecord;
        
        // Create a test case associated with the test account
        Case testCase = new Case(Subject = 'Test Case', AccountId = testAccount.Id, BLN_Corporate__c = corpRecord.Id);
        insert testCase;
        
        Test.startTest();
        String entityName = BLN_FetchKnowledgeArticles.checkMotabilityAccountName(testCase.Id);
        Test.stopTest();

        // Assertions to check that the entityName is returned correctly
        System.assertEquals('Some Legal Entity Id', entityName, 'The entity name should be correct for Corporate Fleet');        
    }
    @isTest
    static void testCheckMotabilityInsurance() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
         Account testAccountcorp = new Account(Name = 'Some Legal Entity Id');
        insert testAccountcorp;
       
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_VehicleRegNumber__c='BN12OEE';
        insert veh;
        
        RecordType rtInsurance = [SELECT Id FROM RecordType WHERE DeveloperName = :System.label.BLN_Insurance AND SObjectType = 'BLN_Corporate__c' LIMIT 1];
        
        // Create the BLN_Corporate__c record with the 'Corporate Fleet' record type
        BLN_Corporate__c corpRecord = new BLN_Corporate__c(
            RecordTypeId = rtInsurance.Id,
            BLN_InsuranceLegalEntity__c =testAccountcorp.Id ,
            BLN_Vehicle__c=veh.Id       
        );
        insert corpRecord;
        
        // Create a test case associated with the test account
        Case testCase = new Case(Subject = 'Test Case', AccountId = testAccount.Id, BLN_Corporate__c = corpRecord.Id);
        insert testCase;
        
        Test.startTest();
        String entityName = BLN_FetchKnowledgeArticles.checkMotabilityAccountName(testCase.Id);
        Test.stopTest();

        // Assertions to check that the entityName is returned correctly
        System.assertEquals('Some Legal Entity Id', entityName, 'The entity name should be correct for Corporate Fleet');        
    }
    /*@isTest
    static void testCheckMotabilityInsurance() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
         Account testAccountcorp = new Account(Name = 'Some Legal Entity Id');
        insert testAccountcorp;
       
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_VehicleRegNumber__c='BN12OEE';
        insert veh;
        
        RecordType rtInsurance = [SELECT Id FROM RecordType WHERE DeveloperName = :System.label.BLN_SplitBill AND SObjectType = 'BLN_Corporate__c' LIMIT 1];
        
        // Create the BLN_Corporate__c record with the 'Corporate Fleet' record type
        BLN_Corporate__c corpRecord = new BLN_Corporate__c(
            RecordTypeId = rtInsurance.Id,
            BLN_InsuranceLegalEntity__c =testAccountcorp.Id ,
            BLN_Vehicle__c=veh.Id       
        );
        insert corpRecord;
        
        // Create a test case associated with the test account
        Case testCase = new Case(Subject = 'Test Case', AccountId = testAccount.Id, BLN_Corporate__c = corpRecord.Id);
        insert testCase;
        
        Test.startTest();
        String entityName = BLN_FetchKnowledgeArticles.checkMotabilityAccountName(testCase.Id);
        Test.stopTest();

        // Assertions to check that the entityName is returned correctly
        System.assertEquals('Some Legal Entity Id', entityName, 'The entity name should be correct for Corporate Fleet');        
    }*/
}