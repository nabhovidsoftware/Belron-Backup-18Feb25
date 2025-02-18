@isTest
public class BLN_PurgeIdleCasesFromEWP_Test {
	
    @isTest
    static void scenario1(){
        
        Test.startTest();
        User belronIntegrationUser = [SELECT Id FROM User WHERE Name = 'Belron Integration User' LIMIT 1];
        Account account1 = new Account(Name = 'Test Account 1');
        insert account1;
        
        Contact testContact = BLN_TestDataFactory.getContact('Test333');
        testContact.FirstName = 'Test333';
        testContact.LastName = 'Contact333';
        testContact.Email = 'test333@gmail.com';
        insert testContact;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;
        
        Case cse1 = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse1.Type = 'Job Request';
        cse1.BLN_SubType__c = 'Job Request';
        cse1.Status = 'New';
        cse1.AccountId = account1.Id;
        cse1.ContactId = testContact.Id;
      	cse1.BLN_Vehicle__c = veh.Id;
        cse1.Priority = 'Medium';
        cse1.BLN_MotoristTaxStatus__c = 'Yes';
        cse1.BLN_TotalMotoristLiability__c = 6000;
        cse1.BLN_AbandonedOnlineBookingConsent__c = TRUE;
        cse1.OwnerId = belronIntegrationUser.Id;
        
        insert cse1;
        
		cse1.AccountId = account1.Id;
        update cse1;
       
        BLN_PurgeIdleCasesFromEWP batch = new BLN_PurgeIdleCasesFromEWP();
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify results
        List<Account> remainingAccounts = [SELECT Id FROM Account where name = 'Test Account 1'];
        List<Case> remainingCases = [SELECT Id FROM Case where BLN_AbandonedOnlineBookingConsent__c = TRUE and OwnerId =:belronIntegrationUser.Id];
        
        System.assertEquals(0, remainingAccounts.size(), 'Account should delete.');
    }

	@isTest
    static void scenario02(){
        
        Test.startTest();
        User belronIntegrationUser = [SELECT Id FROM User WHERE Name = 'Belron Integration User' LIMIT 1];
        Account account1 = new Account(Name = 'Test Account 1');
        insert account1;
        
        Contact testContact = BLN_TestDataFactory.getContact('Test333');
        testContact.FirstName = 'Test333';
        testContact.LastName = 'Contact333';
        testContact.Email = 'test333@gmail.com';
        testContact.AccountId = account1.Id;
        insert testContact;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;
        
        Case cse1 = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse1.Type = 'Job Request';
        cse1.BLN_SubType__c = 'Job Request';
        cse1.Status = 'New';
        cse1.ContactId = testContact.Id;
      	cse1.BLN_Vehicle__c = veh.Id;
        cse1.Priority = 'Medium';
        cse1.BLN_MotoristTaxStatus__c = 'Yes';
        cse1.BLN_TotalMotoristLiability__c = 6000;
        cse1.BLN_AbandonedOnlineBookingConsent__c = TRUE;
        cse1.OwnerId = belronIntegrationUser.Id;
        insert cse1;
        
        cse1.AccountId = account1.Id;
        update cse1;
        
		Case cse2 = BLN_TestDataFactory.getCase('Feedback', 'New');
        cse2.BLN_SubType__c = 'Complaint';
        cse2.Priority = 'Medium';
        cse2.BLN_MotoristTaxStatus__c = 'No';
        cse2.BLN_TotalMotoristLiability__c = 8000;
        cse2.BLN_AbandonedOnlineBookingConsent__c = TRUE;
        cse2.OwnerId = belronIntegrationUser.Id;
        insert cse2;
        
		cse2.AccountId = account1.Id;
        update cse2;

        BLN_PurgeIdleCasesFromEWP batch = new BLN_PurgeIdleCasesFromEWP();
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify results
        List<Case> remainingCases = [SELECT Id FROM Case where AccountId =:account1.Id];
        System.assertEquals(0, remainingCases.size(), 'No cases should remain.');
    }
    
     @isTest
    static void scenario3(){
        
        Test.startTest();
        User belronIntegrationUser = [SELECT Id FROM User WHERE Name = 'Belron Integration User' LIMIT 1];
        Account account1 = new Account(Name = 'Test Account 1');
        insert account1;
        
        Contact testContact = BLN_TestDataFactory.getContact('Test333');
        testContact.FirstName = 'Test333';
        testContact.LastName = 'Contact333';
        testContact.Email = 'test333@gmail.com';
        insert testContact;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;

        BLN_PurgeIdleCasesFromEWP batch = new BLN_PurgeIdleCasesFromEWP();
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify results
        List<Account> remainingAccounts = [SELECT Id FROM Account where name = 'Test Account 1'];
        
        System.assertEquals(1, remainingAccounts.size(), 'Account should not delete.');
    }
}