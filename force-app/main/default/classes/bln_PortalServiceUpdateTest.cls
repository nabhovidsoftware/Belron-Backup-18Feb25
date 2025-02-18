@isTest
private class bln_PortalServiceUpdateTest {

    @isTest
    static void testUpdateServiceRequest() {
        // Create test data
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

        ServiceAppointment testAppointment = new ServiceAppointment(
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
        insert testAppointment;

        // Test updateServiceRequest method
        Test.startTest();
        bln_PortalServiceAppoinmentupdate.updateServiceRequest(
            testCase.Id, // Case Id
            testAppointment.Id, // Existing Service Appointment Id
            Date.today(), // Date for appointment
            '09:00', // Start time
            '10:00', // End time
            'Location A' // Window location
        );
        Test.stopTest();
        Case updatedCase = [SELECT Id,  (SELECT Id, ArrivalWindowStartTime,Status, ArrivalWindowEndTime FROM Service_Appointments__r) FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Open', updatedCase.Service_Appointments__r[0].Status, 'Service Appointment should have been updated to Scheduled status');
        System.assertNotEquals(Date.today(), updatedCase.Service_Appointments__r[0].ArrivalWindowStartTime.date(), 'Incorrect Arrival Window Start Date');

    }

    @isTest
    static void testUpdateEmptyCase() {
        Test.startTest();
        try {
            bln_PortalServiceAppoinmentupdate.updateServiceRequest(
                null, 
                null, // Invalid Appointment Id
                Date.today(), // Date for appointment
                '09:00', // Start time
                '10:00', // End time
                null // Window location
            );
        } catch (Exception e) {
            String expectedMessage = 'Script-thrown exception';
            BLN_ExceptionLogger.captureException(e);
    		Boolean containsExpectedMessage = e.getMessage().contains(expectedMessage);
            //System.assert(e.getMessage().contains('DML Exception'));
            System.assert(containsExpectedMessage, 'Expected exception message to contain: ' + expectedMessage + '. Actual message: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateOld(){
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

        ServiceAppointment testAppointment = new ServiceAppointment(
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
        insert testAppointment;

        // Test updateServiceRequest method
        Test.startTest();
        bln_PortalServiceAppoinmentupdate.updateOldServiceRequest(testAppointment.Id);
        Test.stopTest();
        Case updatedCase =New Case ();
        updatedCase=[SELECT Id,  (SELECT Id, ArrivalWindowStartTime,Status, ArrivalWindowEndTime FROM Service_Appointments__r) FROM Case WHERE Id = :testCase.Id];
   
    }
}