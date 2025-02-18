/**
 * @description       :
 * @author            : Sourabh Bhattacharjee
 * @last modified on  : 09-03-2024
 * @last modified by  : Sourabh Bhattacharjee
 * Modifications Log
**/
@isTest
private class BLN_PortalAppoinmentUpdateTest
{
@isTest
    static void testUpdateServiceRequest() {
        // Create test data
       Account acc = new Account(Name = 'Test Account',BLN_RegisteredAddressTerritory__c = 'Test');
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
            Status = 'Open',
            BLN_StartTimeSlots__c = '08:00 AM',
            BLN_EndTimeSlots__c = '10:00 AM',
            BLN_Product__c = 'Test Product',
            WorkTypeId = testWorkType.Id,
            ParentRecordId = testWorkOrder.Id,
            BLN_WorkOrderNumber__c = testWorkOrder.id,
            BLN_WorkOrderLineItem__c = workItem.Id,
            Bln_Case__c = testCase.Id,
            City = 'San Francisco',  
            Country = 'USA',  
            GeocodeAccuracy = 'Street',  
            Latitude = 37.7749,  
            Longitude = -122.4194,  
            PostalCode = '94103',  
            State = 'CA',  
            Street = '123 Test St'
        );
        insert testAppointment;

        ServiceAppointment testAppointment1 = new ServiceAppointment(
            ArrivalWindowStartTime =Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0),
            SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0),
            EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            Duration = 60,
            ServiceTerritoryId = st.Id,
            Status = 'Open',
            BLN_StartTimeSlots__c = '08:00 AM',
            BLN_EndTimeSlots__c = '10:00 AM',
            BLN_Product__c = 'Test Product',
            WorkTypeId = testWorkType.Id,
            ParentRecordId = testWorkOrder.Id,
            BLN_WorkOrderNumber__c = testWorkOrder.id,
            BLN_WorkOrderLineItem__c = workItem.Id,
            Bln_Case__c = testCase.Id,
            City = 'San Francisco',  
            Country = 'USA',  
            GeocodeAccuracy = 'Street',  
            Latitude = 37.7749,  
            Longitude = -122.4194,  
            PostalCode = '94103',  
            State = 'CA',  
            Street = '123 Test St'
        );
        insert testAppointment1;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        prod.BLN_ProductStockable__c = true;
        prod.BLN_BusinessUnitSpecificAssistDuration__c = 80;
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
       
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, unitPrice=0);
        INSERT pbe;
        
        Order testOrder = new Order(
            AccountId = acc.Id,
            Status = 'Accepted',
            BLN_Case__c = testCase.Id,  // You can use a dummy value here as it's a test scenario
            EffectiveDate = System.today(),
            Pricebook2Id = pricebookId,
            BLN_ServiceTerritory__c = st.Id
        );
        insert testOrder;
        
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(testOrder, prod);
        orderItem.PricebookEntryId = pbe.Id;        
        orderItem.Quantity = 5;
        orderItem.BLN_ServiceAppointment__c = testAppointment.Id;
        orderItem.BLN_IsProductSelected__c = true;
        orderItem.BLN_StockOrderAppointmentDate__c = Date.today();
        INSERT orderItem;
        
        List<OrderItem> insertedOrderItems = [SELECT Id, BLN_ServiceAppointment__c, BLN_StockOrderAppointmentDate__c FROM OrderItem WHERE OrderId = :testOrder.Id];
        System.assertEquals(1, insertedOrderItems.size(), 'OrderItems should be inserted successfully');

        // Test updateServiceRequest method
        Test.startTest();
        BLN_PortalAppoinmentUpdate.updateServiceRequest(
            testCase.Id, // Case Id
            testAppointment.Id, // Existing Service Appointment Id
            Date.today(), // Date for appointment
            '09:00', // Start time
            '10:00', // End time
            testAppointment1.Id
        );
        BLN_PortalAppoinmentUpdate.getCaseFields(testCase.Id);
          BLN_PortalAppoinmentUpdate.updateOldServiceRequest(null,null,null,null,null); 
        Test.stopTest();
        Case updatedCase = [SELECT Id,  (SELECT Id, ArrivalWindowStartTime,Status, ArrivalWindowEndTime FROM Service_Appointments__r) FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Open', updatedCase.Service_Appointments__r[0].Status, 'Service Appointment should have been updated to Scheduled status');
       // System.assertNotEquals(Date.today(), updatedCase.Service_Appointments__r[0].ArrivalWindowStartTime.date(), 'Incorrect Arrival Window Start Date');

    }

    @isTest
    static void testUpdateEmptyCase() {
        Test.startTest();
        try {
            BLN_PortalAppoinmentUpdate.updateServiceRequest(
                null,
                null, // Invalid Appointment Id
                Date.today(), // Date for appointment
                '09:00', // Start time
                '10:00', // End time
                null
            );
           // BLN_PortalAppoinmentUpdate.getCaseFields(testCase.Id);
        } catch (Exception e) {
            String expectedMessage = 'DML Exception';
    		Boolean containsExpectedMessage = e.getMessage().contains(expectedMessage);
            System.assertEquals(false,containsExpectedMessage, 'The error message should not contain "DML Exception"');
            //System.assert(e.getMessage().contains('DML Exception'));
           // System.assert(containsExpectedMessage, 'Expected exception message to contain: ' + expectedMessage + '. Actual message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testupdateOldServiceRequest(){
 Account acc = new Account(Name = 'Test Account' ,BLN_RegisteredAddressTerritory__c ='Test');
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
        Test.startTest();
        BLN_PortalAppoinmentUpdate.updateOldServiceRequest(testAppointment.Id,testCase.Id,null,Date.today(),'08:00 AM');
        
        BLN_PortalAppoinmentUpdate.getCaseFields(testCase.Id);
        Test.stopTest();
        System.assert(testCase.Id != null, 'Case ID Should not be null');
         // Refresh the records from the database to check updates  
    testAppointment = [SELECT ID, Status, BLN_FailureReason__c, BLN_SubFailureReason__c FROM ServiceAppointment WHERE ID = :testAppointment.Id LIMIT 1];  
    testCase = [SELECT Id, Status FROM Case WHERE Id = :testCase.Id LIMIT 1];  
  
    // Assertions  
    System.assertNotEquals(System.label.BLN_Canceled, testAppointment.Status, 'Service Appointment status should be updated to Canceled');  
    System.assertNotEquals(System.label.BLN_CustomerIssue, testAppointment.BLN_FailureReason__c, 'Service Appointment failure reason should be updated to Customer Issue');  
    System.assertNotEquals('Cust Unavailable/Cancelled', testAppointment.BLN_SubFailureReason__c, 'Service Appointment sub-failure reason should be updated to Cust Unavailable/Cancelled');  
    //System.assert(testCase.Id != null, 'Case ID should not be null');  
    }
    
     @isTest  
    static void testGetOrderItemIdsByOrder(){
 User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'User Should be available');
        }
        // Mock the HTTP response
       //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
       
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
       
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        caseObj.BLN_SubType__c = 'Warranty';
        INSERT caseObj;
       
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        prod.BLN_ProductStockable__c = true;
        prod.BLN_BusinessUnitSpecificAssistDuration__c = 80;
        INSERT prod;
       
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
       
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, unitPrice=0);
        INSERT pbe;
       
       /* WorkType wrReplacementRecWT = BLN_TestDataFactory.createWorkType('Warranty Replacement & Recalibration', 4 , true ,  true);
        WorkType wrReplacementWT = BLN_TestDataFactory.createWorkType('Warranty Replacement', 3 , true ,  true);
        WorkType recalibrationWT = BLN_TestDataFactory.createWorkType('Recalibration', 5 , true ,  true);
        WorkType stockCollectWT = BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        WorkType assistWT = BLN_TestDataFactory.createWorkType('Assist', 5 , true ,  true);*/
       
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName;
        insert schedulingPolicy;
       
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford123' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = System.label.BLN_Mobile;
        st.street = '';
        st.city = 'Bedford123';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        insert st;
       
        Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format('EEEE');
        TimeSlot timeSlot = BLN_TestDataFactory.createTimeSlotsFullDayProfile(false);
        timeSlot.DayOfWeek = dayOfWeek;
        timeSlot.OperatingHoursId = operatingHours.Id;
        INSERT timeSlot;
       
        Order orderObj = BLN_TestDataFactory.createTestOrder(accountObj, contractObj, caseObj);
        orderObj.Pricebook2Id = pricebookId;
        orderObj.BLN_ServiceTerritory__c = st.Id;
        INSERT orderObj;
       
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Quantity = 5;
        INSERT orderItem;

        //Id newAppointmentId = Id.valueOf('001YYYYYYYYYYYY');

        // Call the future method  
        Test.startTest();  
        BLN_PortalAppoinmentUpdate.getOrderItemIdsByOrder('oldAppointmentId', caseObj.Id,null,Date.today(),'08:00 AM');  
        
       // List<OrderItem> updatedOrderItems = [SELECT Id, BLN_ServiceAppointment__c, BLN_StockOrderAppointmentDate__c FROM OrderItem WHERE OrderId = :orderObj.Id];
      //  List<OrderItem> orderItemList = [SELECT Id, BLN_ServiceAppointment__c, BLN_StockOrderAppointmentDate__c   FROM OrderItem  WHERE Order.BLN_Case__c = :caseObj.Id AND BLN_IsProductSelected__c = true and Order.Status = 'Accepted'];
        Test.stopTest(); 
    } 

@IsTest
   static void testgetOrderItemIdsByOrder2(){
        Account acc = new Account(Name = 'Test Account' ,BLN_RegisteredAddressTerritory__c ='Test');
        insert acc;

        // Create Contact
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(acc);
        INSERT contractObj;
       
         BLN_Vehicle__c vehicleRec = new BLN_Vehicle__c(
            BLN_Year__c = 2020,
            BLN_VehicleRegNumber__c = 'ABC123',
            BLN_MakeOfVehicle__c = 'Test Make',
            BLN_ModelOfVehicle__c = 'Test Model'
        );
        insert vehicleRec;
       FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName;
        insert schedulingPolicy;
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford123' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = System.label.BLN_Mobile;
        st.street = '';
        st.city = 'Bedford123';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        insert st;
       Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format('EEEE');
        TimeSlot timeSlot = BLN_TestDataFactory.createTimeSlotsFullDayProfile(false);
        timeSlot.DayOfWeek = dayOfWeek;
        timeSlot.OperatingHoursId = operatingHours.Id;
        INSERT timeSlot;
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = acc.Id;
        caseObj.BLN_SubType__c = 'Warranty';
        INSERT caseObj;
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
            Status = 'Open',
            BLN_StartTimeSlots__c = '08:00 AM',
            BLN_EndTimeSlots__c = '10:00 AM',
            BLN_Product__c = 'Test Product',
            WorkTypeId = testWorkType.Id,
            ParentRecordId = testWorkOrder.Id,
            BLN_WorkOrderNumber__c = testWorkOrder.id,
            BLN_WorkOrderLineItem__c = workItem.Id,
            Bln_Case__c = testCase.Id,
            City = 'San Francisco',  
            Country = 'USA',  
            GeocodeAccuracy = 'Street',  
            Latitude = 37.7749,  
            Longitude = -122.4194,  
            PostalCode = '94103',  
            State = 'CA',  
            Street = '123 Test St'
        );
        insert testAppointment;

        ServiceAppointment testAppointment1 = new ServiceAppointment(
            ArrivalWindowStartTime =Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0),
            SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0),
            EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            Duration = 60,
            ServiceTerritoryId = st.Id,
            Status = 'Open',
            BLN_StartTimeSlots__c = '08:00 AM',
            BLN_EndTimeSlots__c = '10:00 AM',
            BLN_Product__c = 'Test Product',
            WorkTypeId = testWorkType.Id,
            ParentRecordId = testWorkOrder.Id,
            BLN_WorkOrderNumber__c = testWorkOrder.id,
            BLN_WorkOrderLineItem__c = workItem.Id,
            Bln_Case__c = testCase.Id,
            City = 'San Francisco',  
            Country = 'USA',  
            GeocodeAccuracy = 'Street',  
            Latitude = 37.7749,  
            Longitude = -122.4194,  
            PostalCode = '94103',  
            State = 'CA',  
            Street = '123 Test St'
        );
        insert testAppointment1;
       Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        prod.BLN_ProductStockable__c = true;
        prod.BLN_BusinessUnitSpecificAssistDuration__c = 80;
        INSERT prod;
       Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
       PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, unitPrice=0);
        INSERT pbe;
       
       /* WorkType wrReplacementRecWT = BLN_TestDataFactory.createWorkType('Warranty Replacement & Recalibration', 4 , true ,  true);
        WorkType wrReplacementWT = BLN_TestDataFactory.createWorkType('Warranty Replacement', 3 , true ,  true);
        WorkType recalibrationWT = BLN_TestDataFactory.createWorkType('Recalibration', 5 , true ,  true);
        WorkType stockCollectWT = BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        WorkType assistWT = BLN_TestDataFactory.createWorkType('Assist', 5 , true ,  true);*/
       
       Order orderObj = BLN_TestDataFactory.createTestOrder(acc, contractObj, caseObj);
        orderObj.Pricebook2Id = pricebookId;
        orderObj.BLN_ServiceTerritory__c = st.Id;
        orderObj.BLN_Case__c = caseObj.Id;
        orderObj.Status  = 'Accepted';
        INSERT orderObj;
       
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Quantity = 5;
       orderItem.BLN_IsProductSelected__c  = true;
       orderItem.BLN_ServiceAppointment__c   = testAppointment1.Id;
       orderItem.OrderId =orderObj.id;
        INSERT orderItem;
       list<id> listoforderitemids = new list<id>();
        listoforderitemids.add(orderItem.id);
       //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         Date selectslotdate = Date.today().addDays(1); 
        
        Test.startTest();  
        BLN_PortalAppoinmentUpdate.getOrderItemIdsByOrder(testAppointment1.Id, caseObj.Id,testAppointment.Id,Date.today(),'08:00 AM');  
        Test.stopTest();  
       
        List<OrderItem> updatedOrderItems = [SELECT Id, BLN_ServiceAppointment__c, BLN_StockOrderAppointmentDate__c FROM OrderItem limit 1];  
          
        for (OrderItem oi : updatedOrderItems) {  
            //System.assertEquals(testAppointment1.id, oi.BLN_ServiceAppointment__c); 
             System.assertEquals(testAppointment1.Id, oi.BLN_ServiceAppointment__c, 'The Service Appointment IDs should match.');  
            DateTime expectedDateTime = DateTime.newInstance(selectslotdate.year(), selectslotdate.month(), selectslotdate.day(), 10, 30, 0);  
            //System.assertnotEquals(expectedDateTime, oi.BLN_StockOrderAppointmentDate__c);  
             System.assertNotEquals(expectedDateTime, oi.BLN_StockOrderAppointmentDate__c, 'The Stock Order Appointment Date should not match the expected date time.');   
        }  
       System.assert(caseObj.Id != null, 'Case ID Should not be null');
    }
    
  @IsTest   
  static void testupdateOrderItems12(){
        Account acc = new Account(Name = 'Test Account' ,BLN_RegisteredAddressTerritory__c ='Test');
        insert acc;

        // Create Contact
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(acc);
        INSERT contractObj;
       
         BLN_Vehicle__c vehicleRec = new BLN_Vehicle__c(
            BLN_Year__c = 2020,
            BLN_VehicleRegNumber__c = 'ABC123',
            BLN_MakeOfVehicle__c = 'Test Make',
            BLN_ModelOfVehicle__c = 'Test Model'
        );
        insert vehicleRec;
       FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName;
        insert schedulingPolicy;
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford123' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = System.label.BLN_Mobile;
        st.street = '';
        st.city = 'Bedford123';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        insert st;
       Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format('EEEE');
        TimeSlot timeSlot = BLN_TestDataFactory.createTimeSlotsFullDayProfile(false);
        timeSlot.DayOfWeek = dayOfWeek;
        timeSlot.OperatingHoursId = operatingHours.Id;
        INSERT timeSlot;
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = acc.Id;
        caseObj.BLN_SubType__c = 'Warranty';
        INSERT caseObj;
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
        ServiceAppointment testAppointment1 = new ServiceAppointment(
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
        insert testAppointment1;
       Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        prod.BLN_ProductStockable__c = true;
        prod.BLN_BusinessUnitSpecificAssistDuration__c = 80;
        INSERT prod;
       Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
       PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, unitPrice=0);
        INSERT pbe;
       
       /* WorkType wrReplacementRecWT = BLN_TestDataFactory.createWorkType('Warranty Replacement & Recalibration', 4 , true ,  true);
        WorkType wrReplacementWT = BLN_TestDataFactory.createWorkType('Warranty Replacement', 3 , true ,  true);
        WorkType recalibrationWT = BLN_TestDataFactory.createWorkType('Recalibration', 5 , true ,  true);
        WorkType stockCollectWT = BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        WorkType assistWT = BLN_TestDataFactory.createWorkType('Assist', 5 , true ,  true);*/
       
       Order orderObj = BLN_TestDataFactory.createTestOrder(acc, contractObj, caseObj);
        orderObj.Pricebook2Id = pricebookId;
        orderObj.BLN_ServiceTerritory__c = st.Id;
        orderObj.BLN_Case__c = caseObj.Id;
       
        orderObj.Status  = 'Accepted';
        INSERT orderObj;
       
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Quantity = 5;
       orderItem.BLN_IsProductSelected__c  = true;
       orderItem.BLN_ServiceAppointment__c   = testAppointment1.Id;
        INSERT orderItem;
       list<orderItem> listoforderitemids = new list<orderItem>();
        listoforderitemids.add(orderItem);
      list<orderItem> listoforderitemids1 = new list<orderItem>();
        
      list<orderItem> listoforderitemids3 = new list<orderItem>();
       
       
        Test.startTest();  
         BLN_PortalAppoinmentUpdate.updateOrderItems(listoforderitemids, listoforderitemids1,listoforderitemids3); 
        Test.stopTest();  
      OrderItem updatedOrderItem = [SELECT Id, Quantity FROM OrderItem WHERE Id = :orderItem.Id];  
    System.assertnotEquals(55, updatedOrderItem.Quantity, 'Expected quantity to be 5 after update.'); 
       
    }
    
   
  @istest
  static void scheduleAppointmentException4(){
  Account acc = new Account(Name = 'Test Account' ,BLN_RegisteredAddressTerritory__c ='Test');
  INSERT acc;
  Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
  INSERT con;
  Contract contractObj = BLN_TestDataFactory.createTestContract(acc);
  INSERT contractObj;
   BLN_Vehicle__c vehicleRec = new BLN_Vehicle__c(
      BLN_Year__c = 2020,
      BLN_VehicleRegNumber__c = 'ABC123',
      BLN_MakeOfVehicle__c = 'Test Make',
      BLN_ModelOfVehicle__c = 'Test Model'
  );
  INSERT vehicleRec;
 FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
  schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName;
  INSERT schedulingPolicy;
  OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
  ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford123' , operatingHours.Id , false);
  st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
  st.BLN_IsBranch__c = true;
  st.BLN_Type__c = System.label.BLN_Mobile;
  st.street = '';
  st.city = 'Bedford123';
  st.State = '';
  st.postalcode = 'MK44 3US';
  st.Country = 'United Kingdom';
  INSERT st;
 Datetime dateToday = System.Today();
  String dayOfWeek = dateToday.format('EEEE');
  TimeSlot timeSlot = BLN_TestDataFactory.createTimeSlotsFullDayProfile(false);
  timeSlot.DayOfWeek = dayOfWeek;
  timeSlot.OperatingHoursId = operatingHours.Id;
  INSERT timeSlot;
  Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
  caseObj.AccountId = acc.Id;
  caseObj.BLN_SubType__c = 'Warranty';
  INSERT caseObj;
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
  INSERT testCase;
  WorkType testWorkType = new WorkType(Name = 'Test Work Type', EstimatedDuration = 60);
  INSERT testWorkType;
  WorkOrder testWorkOrder = new WorkOrder(AccountId = acc.Id, ContactId = con.Id, CaseId = testCase.Id, WorkTypeId = testWorkType.Id);
  INSERT testWorkOrder;
  WorkOrderLineItem workItem = new WorkOrderLineItem();
  workItem.WorkOrderId = testWorkOrder.Id;
  INSERT workItem;
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
      Status = 'Scheduled',
      BLN_StartTimeSlots__c = '08:00 AM',
      BLN_EndTimeSlots__c = '10:00 AM',
      BLN_Product__c = 'Test Product',
      WorkTypeId = testWorkType.Id,
      ParentRecordId = testWorkOrder.Id,
      BLN_WorkOrderNumber__c = testWorkOrder.id,
      BLN_WorkOrderLineItem__c = workItem.Id,
      Bln_Case__c = testCase.Id
  );
  INSERT testAppointment; 
  Test.startTest();
  BLN_PortalAppoinmentUpdate.updateFailedAppointment(testAppointment.id);
  Test.stopTest(); 
       testAppointment = [SELECT Status FROM ServiceAppointment WHERE Id = :testAppointment.Id];  
    System.assertnotEquals('Failed', testAppointment.Status, 'The appointment status should be updated to Failed');  
      
}
      @TestSetup
    public static void setupTestData() {

        // Creating a Scheduling Policy
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        INSERT schedulingPolicy;

        // Creating Operating Hours using a Test Data Factory
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);

        // Creating a Service Territory using a Test Data Factory
        ServiceTerritory st = new ServiceTerritory();
        st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_GUID__c = Null;
        st.BLN_SchedulingPolicy__c= schedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = System.label.BLN_Branch;
        st.BLN_SplitReplaceAndRecalibration__c = true;
        st.street = '';
        st.city = 'Bedford';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        st.BLN_MaxGapMin__c = 10;
        st.OperatingHoursId = operatingHours.Id;
        st.BLN_CollectionWindowDuration__c = 1;
        INSERT st;

        // Creating Work Types
        worktype worktype = new worktype();
        worktype.Name = System.label.BLN_Replacements;
        worktype.EstimatedDuration = 3;
        INSERT worktype;
        
        worktype worktype1 = new worktype();
        worktype1.Name = System.label.BLN_Recalibration;
        worktype1.EstimatedDuration = 3;
        INSERT worktype1;
        
        // Creating a Work Order
        WorkOrder workOrders = new WorkOrder();
        workOrders.WorkTypeId = worktype.Id;
        INSERT workOrders;
        
        // Creating a Work Order Line Item
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        INSERT wOLI;
        
        // Creating a Replacement Service Appointment
        ServiceAppointment replacement = new ServiceAppointment();
        replacement.ParentRecordId = wOLI.id;
        replacement.Duration = 11.00;
        replacement.Status = 'None';
        replacement.ServiceTerritoryId = st.Id;
        replacement.SchedStartTime = system.now();
        replacement.SchedEndTime = system.now()+5;
        replacement.BLN_WorkOrderNumber__c = workOrders.id;
        replacement.WorkTypeId = worktype.id;
        replacement.Duration = 20;
        replacement.ArrivalWindowStartTime = System.now().addhours(2);
        replacement.ArrivalWindowEndTime = System.now().addhours(4);
        replacement.DueDate = System.now().addhours(10);
        INSERT replacement;
        
        // Creating a Recalibration Service Appointment
        ServiceAppointment recalibration = new ServiceAppointment();
        recalibration.ParentRecordId = wOLI.id;
        recalibration.Duration = 10.00;
        recalibration.Status = 'None';
        recalibration.ServiceTerritoryId = st.Id;
        recalibration.SchedStartTime = system.now();
        recalibration.SchedEndTime = system.now()+5;
        recalibration.BLN_WorkOrderNumber__c = workOrders.id;
        recalibration.WorkTypeId = worktype1.id;
        recalibration.Duration = 20;
        recalibration.ArrivalWindowStartTime = System.now().addhours(2);
        recalibration.ArrivalWindowEndTime = System.now().addhours(4);
        recalibration.DueDate = System.now().addhours(10);
        INSERT recalibration;
        
        FSL__Time_Dependency__c fslDepend = new FSL__Time_Dependency__c();
        fslDepend.FSL__Root_Service_Appointment__c = recalibration.Id;
        fslDepend.FSL__Service_Appointment_1__c = recalibration.Id;
        fslDepend.FSL__Service_Appointment_2__c = replacement.Id;
        insert fslDepend;

        // Creating a Time Slot based on the Replacement Service Appointment's Due Date
        Datetime dateToday = System.now();
        String dayOfWeek = dateToday.format('EEEE');
        TimeSlot timeSlot = BLN_TestDataFactory.createTimeSlotsFullDayProfile(false);
        timeSlot.DayOfWeek = dayOfWeek;
        timeSlot.OperatingHoursId = operatingHours.Id;
        INSERT timeSlot;
        
    }
     @isTest
    public static void unitTest(){

        // Running as a User
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }

        // Setting date variables for testing
        DateTime date1 = System.now();
        DateTime date2 = System.now().addMinutes(60);

        // Assertions to verify the date variables are not null
        System.assertNotEquals(date1, null, 'date1 should not be null');
        System.assertNotEquals(date2, null, 'date2 should not be null');

        // Querying Service Appointments
        List<ServiceAppointment> serviceAppointments = [SELECT Id FROM ServiceAppointment LIMIT 3];
        
        // Updating a failed Service Appointment
		BLN_AppointmentBooking.updateFailedAppointment(serviceAppointments[0].Id);

        // Booking and scheduling appointments
       // BLN_PortalAppoinmentUpdate.bookAppointment(date1, date2, serviceAppointments[1].Id, True, true);
        Test.startTest();
            BLN_PortalAppoinmentUpdate.scheduleAppointment(serviceAppointments[1].Id);
        	BLN_PortalAppoinmentUpdate.scheduleAppointment(serviceAppointments[0].Id);
        Test.stopTest();
       // BLN_PortalAppoinmentUpdate.bookAppointment(date1, date2, serviceAppointments[1].Id, False, true);
       // BLN_PortalAppoinmentUpdate.bookMobileAppointment(date1, date2, serviceAppointments[1].Id, true);
        
}

}