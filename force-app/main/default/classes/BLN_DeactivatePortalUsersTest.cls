/********************************************************************************************
* Class Name        : BLN_DeactivatePortalUsersTest                                         *
* Description       : This test class covers the BLN_DeactivatePortalUsers.                 *
* @Story            : FOUK-5170/FOUK-12817                                                  *
* Created Date      : 11-02-2025                                                            *                                                         *
* Created By        : Sourabh Bhattacharjee                                                 *
* Last Modified by  : Sourabh Bhattacharjee                                                 *
* Coverage Achieved : 90%                                                                   *
********************************************************************************************/
@isTest
public class BLN_DeactivatePortalUsersTest {
 //private static Id testContactId;
    @testSetup
    static void testSetup() {
        Database.DMLOptions dml = new Database.DMLOptions();
		dml.duplicateRuleHeader.allowSave = true;
        Profile b2cProfile = [SELECT Id FROM Profile WHERE Name = :BLN_AppConstants.B2C_PROFILE LIMIT 1];
        //Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = :BLN_AppConstants.SYS_ADMIN LIMIT 1];
        Account acc = new Account(FirstName = 'Adolf',LastName='Stalin',PersonHomePhone='11111535',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType =:System.label.BLN_AccountObj AND DeveloperName =:BLN_AppConstants.PERSON_ACCOUNT LIMIT 1].Id);
        Database.insert(acc, dml);
        Account acc1 = new Account(FirstName = 'Joseph',LastName='Hitler',PersonHomePhone='11111546',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType =:System.label.BLN_AccountObj AND DeveloperName =:BLN_AppConstants.PERSON_ACCOUNT LIMIT 1].Id);
        Database.insert(acc1, dml);
        Case cse = new Case();
        cse.Type = System.label.BLN_RemedyCaseRecordTypeName;
        cse.Status = System.label.BLN_New;
        cse.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        cse.AccountId = acc.Id ;
        cse.Priority = System.label.BLN_Medium;
        cse.BLN_TotalMotoristLiability__c = 2.8 ;
        insert cse;
        Case cse1 = new Case();
        cse1.Type = System.label.BLN_RemedyCaseRecordTypeName;
        cse1.Status = System.label.BLN_New;
        cse1.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc1.Id LIMIT 1].Id;
        cse1.AccountId = acc1.Id ;
        cse1.Priority = System.label.BLN_Medium;
        cse1.BLN_TotalMotoristLiability__c = 3.8 ;
        insert cse1;
        WorkType workType =  new WorkType();
        workType.Name = System.label.BLN_ReplacementWT; 
        workType.EstimatedDuration = 30;
        insert workType;
        WorkType workType1 =  new WorkType();
        workType1.Name = System.label.BLN_ReplacementWT; 
        workType1.EstimatedDuration = 30;
        insert workType1;  
        WorkOrder workOrder = new WorkOrder();
        workOrder.AccountId = acc.id ;
        workOrder.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        workOrder.CaseId = cse.id ;
        workOrder.WorkTypeId = workType.Id;
        insert workOrder;
        WorkOrder workOrder1 = new WorkOrder();
        workOrder1.AccountId = acc1.id ;
        workOrder1.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc1.Id LIMIT 1].Id;
        workOrder1.CaseId = cse1.id ;
        workOrder1.WorkTypeId = workType1.Id;
        insert workOrder1;
        WorkOrderLineItem workItem = new WorkOrderLineItem();
        workItem.WorkOrderId = workOrder.Id;
        insert workItem;
        WorkOrderLineItem workItem1 = new WorkOrderLineItem();
        workItem1.WorkOrderId = workOrder1.Id;
        insert workItem1;
        ServiceAppointment sA = new ServiceAppointment();
        sA.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        sA.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA.Duration = 1;
        sA.BLN_Case__c=cse.id;
        sA.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA.Status = 'None';
        sA.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.ParentRecordId = WorkOrder.Id;
        sA.WorkTypeId = workType.Id;
        sA.BLN_WorkOrderNumber__c = workOrder.id;
        sA.BLN_WorkOrderLineItem__c = workItem.Id;
        insert sA;
        List<ServiceAppointment> appointmentsToUpdate = new List<ServiceAppointment>();
        ServiceAppointment updatedAppointment = new ServiceAppointment(Id = sA.Id);  
        updatedAppointment.Status = System.label.BLN_ScheduledStatus;  
        appointmentsToUpdate.add(updatedAppointment);
        update appointmentsToUpdate;
        ServiceAppointment sA1 = new ServiceAppointment();
        sA1.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc1.Id LIMIT 1].Id;
        sA1.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA1.Duration = 1;
        sA1.BLN_Case__c=cse1.id;
        sA1.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA1.Status = 'None';
        sA1.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA1.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA1.ParentRecordId = WorkOrder1.Id;
        sA1.WorkTypeId = workType1.Id;
        sA1.BLN_WorkOrderNumber__c = workOrder1.id;
        sA1.BLN_WorkOrderLineItem__c = workItem1.Id;
        insert sA1;
        List<ServiceAppointment> appointmentsToUpdate1 = new List<ServiceAppointment>();
        ServiceAppointment updatedAppointment1 = new ServiceAppointment(Id = sA1.Id);  
        updatedAppointment1.Status = System.label.BLN_ScheduledStatus;  
        appointmentsToUpdate1.add(updatedAppointment1);
        update appointmentsToUpdate1;
        Set<Id> appId = new Set<Id>();
        appId.add(sa.Id);
        appId.add(sa1.Id);
        List<ServiceAppointment> s = [SELECT ID,Status FROM ServiceAppointment WHERE ID IN :appId];
        for(ServiceAppointment sApp : s){
            sApp.Status =System.label.BLN_Canceled;
        }
        update s;
        User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdevhtfx26912'+acc.Id,
        Alias = 'adsa',
        Email = 'john.cena213@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Adolf',
        LastName = 'Stalin',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = b2cProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id,
        CommunityNickname=acc.Id 
    );
    insert portalUser;
        User portalUser1 = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdevhtfx26912'+acc1.Id,
        Alias = 'johi',
        Email = 'john.cena213@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Joseph',
        LastName = 'Hitler',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = b2cProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc1.Id LIMIT 1].Id,
        CommunityNickname=acc1.Id 
    );
    insert portalUser1;
         
    }
    
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        BLN_DeactivatePortalUsers batchJob = new BLN_DeactivatePortalUsers();
        Database.executeBatch(batchJob);
        Test.stopTest();
        List<AggregateResult> groupedResults = [SELECT AccountId, SUM(BLN_OutstandingBalance__c) totalBalance FROM Case
    WHERE AccountId IN :[SELECT Id FROM Account] GROUP BY AccountId];
        Boolean hasHighBalance = false;
        Boolean hasLowBalance = false;
        for (AggregateResult result : groupedResults) {
            Decimal balance = (Decimal) result.get('totalBalance');
            if (balance > 2.99) {
                hasHighBalance = true;
            } else {
                hasLowBalance = true;
            }
        }
        System.assert(hasHighBalance, 'There should be accounts with high balances.');
        System.assert(hasLowBalance, 'There should be accounts with low balances.');
    }

}