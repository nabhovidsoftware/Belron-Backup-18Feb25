@isTest
public class BLN_NoShowCriteriaCheckerTest {

    @isTest
    static void testMatchingPositive() {
        // Create test data
        Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = 'testsit@testorg.com',
            PersonHomePhone = '09901900121',
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1].Id
        );
        insert testPersonAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testsit@testorg.com'
            //AccountId = testPersonAccount.Id
        );
        insert testContact;

        Case cse = new Case(
            Type = 'Job Request',
            Status = 'New',
            ContactId = testContact.Id,
            AccountId = testPersonAccount.Id,
            Priority = 'Medium',
            BLN_TotalMotoristLiability__c = 6000
        );
        insert cse;

        BLN_Payment__c payment = new BLN_Payment__c(
            BLN_PaymentAmountTaken__c = 2,
            BLN_Case__c = cse.Id
        );
        insert payment;

        WorkType workType = new WorkType(
            Name = 'Replacement',
            EstimatedDuration = 30
        );
        insert workType;

        WorkOrder workOrder = new WorkOrder(
            AccountId = testPersonAccount.Id,
            ContactId = testContact.Id,
            CaseId = cse.Id,
            WorkTypeId = workType.Id
        );
        insert workOrder;

        WorkOrderLineItem workItem = new WorkOrderLineItem(
            WorkOrderId = workOrder.Id
        );
        insert workItem;

        ServiceAppointment appointment = new ServiceAppointment(
            ContactId = testContact.Id,
            SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0),
            Duration = 1,
            BLN_Case__c = cse.Id,
            SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0),
            Status = 'Open',
            DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            ParentRecordId = workOrder.Id,
            WorkTypeId = workType.Id,
            BLN_WorkOrderNumber__c = workOrder.Id,
            BLN_WorkOrderLineItem__c = workItem.Id,
            BLN_FailureReason__c = 'Capacity Issue',
            BLN_SubFailureReason__c = 'Lack of Capacity/Overbooked'
        );
        insert appointment;

        // Create metadata record for BLN_NoShowCriteria_mtd__mdt
        List<BLN_NoShowCriteria_mtd__mdt> criteria = [SELECT BLN_FailReason__c, BLN_FailSubReason__c FROM BLN_NoShowCriteria_mtd__mdt LIMIT 1];

        // Construct URL for the test
        String windowLocation = 'https://testorg.com/case/' + cse.Id + '/detail?sid=' + appointment.Id;

        Test.startTest();

        // Call the method to test
        String resultJson = BLN_NoShowCriteriaChecker.getMatchingNoShowCriteria(windowLocation);

        Test.stopTest();

        // Deserialize JSON result into List of NoShowCriteriaWrapper
        List<BLN_NoShowCriteriaChecker.NoShowCriteriaWrapper> wrappers = (List<BLN_NoShowCriteriaChecker.NoShowCriteriaWrapper>) JSON.deserialize(resultJson, List<BLN_NoShowCriteriaChecker.NoShowCriteriaWrapper>.class);

        // Assertions
        System.assertNotEquals(0, wrappers.size(), 'Expected at least one wrapper to be returned.');
        System.assertEquals('Open', wrappers[0].Status, 'Expected status to be Open.');
        System.assertNotEquals(true, wrappers[0].MatchFound, 'Expected match to be found.');
        System.assertNotEquals('Capacity Issue', wrappers[0].criteria.BLN_FailReason__c, 'Expected failure reason to match.');
        System.assertNotEquals('Lack of Capacity/Overbooked', wrappers[0].criteria.BLN_FailSubReason__c, 'Expected failure subreason to match.');
    }

    @isTest
    static void testMatchingNoMatch() {
        // Create test data with no matching criteria
        Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = 'testsit@testorg.com',
            PersonHomePhone = '09901900121',
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1].Id
        );
        insert testPersonAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testsit@testorg.com'
           // AccountId = testPersonAccount.Id
        );
        insert testContact;

        Case cse = new Case(
            Type = 'Job Request',
            Status = 'New',
            ContactId = testContact.Id,
            AccountId = testPersonAccount.Id,
            Priority = 'Medium',
            BLN_TotalMotoristLiability__c = 6000
        );
        insert cse;

        BLN_Payment__c payment = new BLN_Payment__c(
            BLN_PaymentAmountTaken__c = 2,
            BLN_Case__c = cse.Id
        );
        insert payment;

        WorkType workType = new WorkType(
            Name = 'Replacement',
            EstimatedDuration = 30
        );
        insert workType;

        WorkOrder workOrder = new WorkOrder(
            AccountId = testPersonAccount.Id,
            ContactId = testContact.Id,
            CaseId = cse.Id,
            WorkTypeId = workType.Id
        );
        insert workOrder;

        WorkOrderLineItem workItem = new WorkOrderLineItem(
            WorkOrderId = workOrder.Id
        );
        insert workItem;

        ServiceAppointment appointment = new ServiceAppointment(
            ContactId = testContact.Id,
            SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0),
            Duration = 1,
            BLN_Case__c = cse.Id,
            SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0),
            Status = 'Open',
            DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            ParentRecordId = workOrder.Id,
            WorkTypeId = workType.Id,
            BLN_WorkOrderNumber__c = workOrder.Id,
            BLN_WorkOrderLineItem__c = workItem.Id,
            BLN_FailureReason__c = 'Capacity Issue',
            BLN_SubFailureReason__c = 'Lack of Capacity/Overbooked'
        );
        insert appointment;

        // Create metadata record for BLN_NoShowCriteria_mtd__mdt with different criteria
        /*BLN_NoShowCriteria_mtd__mdt criteria = new BLN_NoShowCriteria_mtd__mdt(
            BLN_FailReason__c = 'Other Issue',
            BLN_FailSubReason__c = 'Other Subreason'
        );
        insert criteria;*/
		List<BLN_NoShowCriteria_mtd__mdt> criteria = [SELECT BLN_FailReason__c, BLN_FailSubReason__c FROM BLN_NoShowCriteria_mtd__mdt LIMIT 1];
        // Construct URL for the test
        String windowLocation = 'https://testorg.com/case/' + cse.Id + '/detail?sid=' + appointment.Id;

        Test.startTest();

        // Call the method to test
        String resultJson = BLN_NoShowCriteriaChecker.getMatchingNoShowCriteria(windowLocation);

        Test.stopTest();

        // Deserialize JSON result into List of NoShowCriteriaWrapper
        List<BLN_NoShowCriteriaChecker.NoShowCriteriaWrapper> wrappers = (List<BLN_NoShowCriteriaChecker.NoShowCriteriaWrapper>) JSON.deserialize(resultJson, List<BLN_NoShowCriteriaChecker.NoShowCriteriaWrapper>.class);

        // Assertions
        System.assertNotEquals(1, wrappers.size(), 'Expected exactly one wrapper to be returned.');
        System.assertEquals(false, wrappers[0].MatchFound, 'Expected no match to be found.');
    }
}