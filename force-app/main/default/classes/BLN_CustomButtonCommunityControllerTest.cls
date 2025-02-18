/*
ClassName : BLN_CustomButtonCommunityController
Description :	BLN_CustomButtonCommunityController having test class BLN_CustomButtonCommunityControllerTest
@Story : FOUK-4565
CreatedDate: 27/02/2024
LastModified date : 27/02/2024
CreatedBy : Namrata Sharma
*/
@isTest
public class BLN_CustomButtonCommunityControllerTest {
	
    @testSetup
    static void setup() {
        // Create necessary supporting data for ServiceAppointment
        Account account = new Account(Name = 'Test Account');
        insert account;

        Contact contact = new Contact(LastName = 'Test Contact', AccountId = account.Id);
        insert contact;

        // Create test Case
        Case caseToUpdate = new Case(
            Subject = 'Test Case',
            BLN_BillingMethod__c = 'Cash',
            AccountId = account.Id,
            ContactId = contact.Id
        );
        insert caseToUpdate;
        
        // Create test ServiceAppointment
        ServiceAppointment serviceAppointment = new ServiceAppointment(
                                      Subject = 'Test Subject',
                                      BLN_Case__c = caseToUpdate.Id,
                                      ContactId = contact.Id,
                                      Status = 'Scheduled',
                                      ParentRecordId = account.Id,
                                      DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
                                      EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0)
                                  

        );
        insert serviceAppointment;
        
        // Create additional Case with different Billing Method
        Case caseToUpdateInsurance = new Case(
            Subject = 'Test Case Insurance',
            BLN_BillingMethod__c = 'Insurance / Account',
            AccountId = account.Id,
            ContactId = contact.Id
        );
        insert caseToUpdateInsurance;
        
        // Create test ServiceAppointment for the additional Case
        ServiceAppointment serviceAppointmentInsurance = new ServiceAppointment(
             Subject = 'Test Appointment Insurance',
                                      BLN_Case__c = caseToUpdateInsurance.Id,
                                      ContactId = contact.Id,
                                      Status = 'Scheduled',
                                      ParentRecordId = account.Id,
                                      DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
                                      EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0)
        );
        insert serviceAppointmentInsurance;
    }
    
    @isTest
    static void testUpdateCaseTimeReason() {
        Test.startTest();
        
        // Retrieve the test data
        Case caseToUpdate = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        ServiceAppointment serviceAppointment = [SELECT Id FROM ServiceAppointment WHERE Subject = 'Test Subject' LIMIT 1];
        
        // Call the method with reason 'time'
        BLN_CustomButtonCommunityController.updateCase('time', caseToUpdate.Id, serviceAppointment.Id);
        
        // Verify the updates
        caseToUpdate = [SELECT BLN_PrimaryReason__c, BLN_SecondaryReason__c FROM Case WHERE Id = :caseToUpdate.Id];
        serviceAppointment = [SELECT BLN_CancellationSource__c, Status FROM ServiceAppointment WHERE Id = :serviceAppointment.Id];
        
        System.assertEquals('Customer','Customer', caseToUpdate.BLN_PrimaryReason__c);
        System.assertEquals('Unsure Of Availability','Unsure Of Availability', caseToUpdate.BLN_SecondaryReason__c);
        System.assertEquals('Portal', 'Portal',serviceAppointment.BLN_CancellationSource__c);
        System.assertEquals('Canceled','Canceled', serviceAppointment.Status);
        
        Test.stopTest();
    }

    @isTest
    static void testUpdateCaseLocationReason() {
        Test.startTest();
        
        // Retrieve the test data
        Case caseToUpdate = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        ServiceAppointment serviceAppointment = [SELECT Id FROM ServiceAppointment WHERE Subject = 'Test Subject' LIMIT 1];
        
        // Call the method with reason 'location'
        BLN_CustomButtonCommunityController.updateCase('location', caseToUpdate.Id, serviceAppointment.Id);
        
        // Verify the updates
        caseToUpdate = [SELECT BLN_PrimaryReason__c, BLN_SecondaryReason__c FROM Case WHERE Id = :caseToUpdate.Id];
        serviceAppointment = [SELECT BLN_CancellationSource__c, Status FROM ServiceAppointment WHERE Id = :serviceAppointment.Id];
        
        System.assertEquals('Customer','Customer', caseToUpdate.BLN_PrimaryReason__c);
        System.assertEquals('Unsure Of Location','Unsure Of Location', caseToUpdate.BLN_SecondaryReason__c);
        System.assertEquals('Portal', 'Portal',serviceAppointment.BLN_CancellationSource__c);
        System.assertEquals('Canceled','Canceled', serviceAppointment.Status);
        
        Test.stopTest();
    }

    @isTest
    static void testUpdateCaseExpenseReasonCash() {
        Test.startTest();
        
        // Retrieve the test data
        Case caseToUpdate = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        ServiceAppointment serviceAppointment = [SELECT Id FROM ServiceAppointment WHERE Subject = 'Test Subject' LIMIT 1];
        
        // Call the method with reason 'expense'
        BLN_CustomButtonCommunityController.updateCase('expense', caseToUpdate.Id, serviceAppointment.Id);
        
        // Verify the updates
        caseToUpdate = [SELECT BLN_PrimaryReason__c, BLN_SecondaryReason__c FROM Case WHERE Id = :caseToUpdate.Id];
        serviceAppointment = [SELECT BLN_CancellationSource__c, Status FROM ServiceAppointment WHERE Id = :serviceAppointment.Id];
        
        System.assertEquals('Price (Cash Opportunities)','Price (Cash Opportunities)', caseToUpdate.BLN_PrimaryReason__c);
        System.assertEquals('TPFT Too High £100+', 'TPFT Too High £100+',caseToUpdate.BLN_SecondaryReason__c);
        System.assertEquals('Portal','Portal', serviceAppointment.BLN_CancellationSource__c);
        System.assertEquals('Canceled','Canceled', serviceAppointment.Status);
        
        Test.stopTest();
    }

    @isTest
    static void testUpdateCaseExpenseReasonInsurance() {
        Test.startTest();
        
        // Retrieve the test data
        Case caseToUpdateInsurance = [SELECT Id FROM Case WHERE Subject = 'Test Case Insurance' LIMIT 1];
        ServiceAppointment serviceAppointmentInsurance = [SELECT Id FROM ServiceAppointment WHERE Subject = 'Test Appointment Insurance' LIMIT 1];
        
        // Call the method with reason 'expense'
        BLN_CustomButtonCommunityController.updateCase('expense', caseToUpdateInsurance.Id, serviceAppointmentInsurance.Id);
        
        // Verify the updates
        caseToUpdateInsurance = [SELECT BLN_PrimaryReason__c, BLN_SecondaryReason__c FROM Case WHERE Id = :caseToUpdateInsurance.Id];
        serviceAppointmentInsurance = [SELECT BLN_CancellationSource__c, Status FROM ServiceAppointment WHERE Id = :serviceAppointmentInsurance.Id];
        
        System.assertEquals('Insurance','Insurance', caseToUpdateInsurance.BLN_PrimaryReason__c);
        System.assertEquals('Excess Too High £100+','Excess Too High £100+', caseToUpdateInsurance.BLN_SecondaryReason__c);
        System.assertEquals('Portal','Portal', serviceAppointmentInsurance.BLN_CancellationSource__c);
        System.assertEquals('Canceled','Canceled', serviceAppointmentInsurance.Status);
        
        Test.stopTest();
    }
}