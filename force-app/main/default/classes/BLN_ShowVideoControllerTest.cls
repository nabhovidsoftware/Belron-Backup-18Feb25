/** @description : BLN_ShowVideoControllerTest Class used for testing BLN_ShowVideoController.
*  	@author: Rageena Makkar
* 	@Story: BLN_ShowVideoController
*	@Created Date: 30/01/2024
*/
@isTest
private class BLN_ShowVideoControllerTest {
     static Case testCase;
    static ServiceAppointment testServiceAppointment;

    @testSetup
    static void setup() {
        // Create test data for Case and ServiceAppointment
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create Contact
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
        
         BLN_Vehicle__c vehicleRec = new BLN_Vehicle__c( 
            BLN_Year__c = 2020,
            BLN_VehicleRegNumber__c = 'ABC123',
            BLN_MakeOfVehicle__c = 'Test Make',
            BLN_ModelOfVehicle__c = 'Test Model'
        );
        insert vehicleRec;
        
        OperatingHours oh = new OperatingHours(
            Name = 'Test Operating Hours'
        );
        insert oh;
        
         // Create Service Territory and Operating Hours
        ServiceTerritory st = new ServiceTerritory
            (Name = 'Test Territory', 
             OperatingHoursId = oh.Id , 
             IsActive = true
            );
	        insert st;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountID = acc.Id,
            ContactId = con.Id,
            Status = 'New',
            Origin = 'Web',
            BLN_Vehicle__c = vehicleRec.Id,
            BLN_BookingStatus__c = 'Confirmed',
            BLN_SubType__c='Job Request',
            Type = 'Job Request',
            Priority = 'Medium',
            BLN_TotalMotoristLiability__c = 6000
        );
        insert testCase;
        
        WorkType testWorkType = new WorkType(Name = 'Test Work Type', EstimatedDuration = 60);
        insert testWorkType;
        
        WorkOrder testWorkOrder = new WorkOrder(AccountId = acc.Id, ContactId = con.Id, CaseId = testCase.Id, WorkTypeId = testWorkType.Id);
        insert testWorkOrder;
        WorkOrderLineItem workItem = new WorkOrderLineItem();
        workItem.WorkOrderId = testWorkOrder.Id;
        insert workItem;

        ServiceAppointment testServiceAppointment = new ServiceAppointment(
           ArrivalWindowStartTime =Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0),
            SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0),
            EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            Duration = 60,
            ServiceTerritoryId = st.Id,
            Street = '123 Test St',
            City = 'Test City',
            State = 'Test State',
            Country = 'Test Country',
            PostalCode = '12345',
            Status = 'Open',
            BLN_StartTimeSlots__c = '08:00 AM',
            BLN_EndTimeSlots__c = '10:00 AM',
            BLN_Product__c = 'Test Product',
            WorkTypeId = testWorkType.Id,
            ParentRecordId = testWorkOrder.Id,
            BLN_WorkOrderNumber__c = testWorkOrder.id,
            BLN_WorkOrderLineItem__c = workItem.Id,
            Bln_Case__c = testCase.Id
        );
        insert testServiceAppointment;
    }
     @isTest
     private static void testGetCaseRecord() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        ServiceAppointment sa = [Select Id from ServiceAppointment Limit 1];
        String recordId = c.Id;
        String windowLocation = 'https://testorg.com/case/' + c.Id + sa.id;
        // Call the method to test
        Test.startTest();
        BLN_ShowVideoController.CaseWrapper result = BLN_ShowVideoController.getCaseRecord(recordId, windowLocation);
        Test.stopTest();
        // Verify the results
        System.assertEquals(c.Id, result.caseRecord.Id , 'Test case Id');
        //System.assertEquals('Test Service Type', result.caseRecord.BLN_ServiceType__c);
        System.assertEquals(1, result.serviceAppointments.size(),'Test');
        System.assertEquals('Test','Test',result.serviceAppointments[0].WorkTypeFormula__c);
    }
   /* @isTest
    private static void testGetCaseRecordException() {
        String windowLocation = 'https://example.com/somepage?sid=123456789012345678';	
        // Cause an exception by passing an invalid recordId
        Test.startTest();
        BLN_ShowVideoController.getCaseRecord('invalidId', windowLocation);
        Test.stopTest();
        System.assert(windowLocation != null, 'windowLocation should not be null.');  
    }*/
}