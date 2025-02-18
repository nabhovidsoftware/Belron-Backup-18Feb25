@isTest  
public class BLN_PortalSACreateSharingBatchTest {  
  
    @testSetup  
    static void setupTestData() {  
        // Create a test Account  
        Account testAccount = new Account(Name = 'Test Account');  
        insert testAccount;  
  
        // Create a test Contact associated with the test Account  
         
          
        // Create a test Case associated with the test Account  
        Case testCase = new Case(  
            AccountId = testAccount.Id,  
            Subject = 'Test Case',  
            Status = 'New'  
        );  
        insert testCase;  
       
        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = 'abc';
        operatingHours.TimeZone = 'Europe/London';
        insert operatingHours;
        
         //id said = BLN_TestDataFactory.createServiceAppointment('Cardington',true)
        
        ServiceTerritory servicesTerritories = new ServiceTerritory();
        servicesTerritories.Name = 'Cardington';
        servicesTerritories.IsActive = TRUE;
        servicesTerritories.OperatingHoursId = operatingHours.id;

          insert servicesTerritories;
        // Insert Groups  
        Group group1 = new Group(Name = 'Cardington', Type = 'Regular');  
        Group group2 = new Group(Name = 'CE York', Type = 'Regular');  
        insert new List<Group>{group1, group2};  
  
        // Insert ServiceAppointment records  
        List<ServiceAppointment> serviceAppointments = new List<ServiceAppointment>{  
            new ServiceAppointment(  
                ArrivalWindowStartTime = System.now(),  
                Subject = 'Test Appointment 1',  
                BLN_Case__c = testCase.Id,  
                //ContactId = testContact.Id,  
                Status = 'Scheduled',  
                ParentRecordId = testAccount.Id,  
                DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),  
                EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),  
                BLN_RebookSource__c = 'portal',   
                ServiceTerritoryId = servicesTerritories.id,   
                BLN_ReadyToDispatch_Portal__c = false  
            ),  
            new ServiceAppointment(  
                ArrivalWindowStartTime = System.now(),  
                Subject = 'Test Appointment 2',  
                BLN_Case__c = testCase.Id,  
               // ContactId = testContact.Id,  
                Status = 'Scheduled',  
                ParentRecordId = testAccount.Id,  
                DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),  
                EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),  
                BLN_RebookSource__c = 'portal',   
                ServiceTerritoryId = servicesTerritories.id,   
                BLN_ReadyToDispatch_Portal__c = false  
            ),  
            new ServiceAppointment(  
                ArrivalWindowStartTime = System.now(),  
                Subject = 'Test Appointment 3',  
                BLN_Case__c = testCase.Id,  
               // ContactId = testContact.Id,  
                Status = 'Scheduled',  
                ParentRecordId = testAccount.Id,  
                DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),  
                EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),  
                BLN_RebookSource__c = 'portal',   
               ServiceTerritoryId = servicesTerritories.id,   
                BLN_ReadyToDispatch_Portal__c = false  
            ), // This one should not create a share because there is no matching group  
            new ServiceAppointment(  
                ArrivalWindowStartTime = System.now(),  
                Subject = 'Test Appointment 4',  
                BLN_Case__c = testCase.Id,  
               // ContactId = testContact.Id,  
                Status = 'Completed',  
                ParentRecordId = testAccount.Id,  
                DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),  
                EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),  
                BLN_RebookSource__c = 'portal',   
               ServiceTerritoryId = servicesTerritories.id,  
                BLN_ReadyToDispatch_Portal__c = false  
            ), // This one should be skipped due to status  
            new ServiceAppointment(  
                ArrivalWindowStartTime = System.now(),  
                Subject = 'Test Appointment 5',  
                BLN_Case__c = testCase.Id,  
               // ContactId = testContact.Id,  
                Status = 'Scheduled',  
                ParentRecordId = testAccount.Id,  
                DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),  
                EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),  
                BLN_RebookSource__c = 'Salesforce',   
               ServiceTerritoryId = servicesTerritories.id,  
                BLN_ReadyToDispatch_Portal__c = false  
            ) // This one should be skipped due to rebook source  
        };  
        insert serviceAppointments;  
    }  
  
    @isTest  
    static void testBatchProcessing() {  
        Test.startTest();  
  
        // Execute the batch  
        BLN_PortalSACreateSharingBatch batch = new BLN_PortalSACreateSharingBatch();  
        Database.executeBatch(batch);  
  
        Test.stopTest();  
  
        // Verify that the ServiceAppointmentShare records were created  
        List<ServiceAppointmentShare> shares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM ServiceAppointmentShare];  
        System.assertnotEquals(0, shares.size(), 'Two ServiceAppointmentShare records should have been created.');  
  
        // Verify that the ServiceAppointment records were updated  
        List<ServiceAppointment> updatedAppointments = [SELECT Id, BLN_ReadyToDispatch_Portal__c FROM ServiceAppointment WHERE BLN_ReadyToDispatch_Portal__c = true];  
        System.assertnotEquals(2, updatedAppointments.size(), 'Two ServiceAppointment records should have been updated.');  
    }  
}