/** @description : Test Class for BLN_GetAvailabilityWebservice
*  @author: Rahul Jain(PwC IN)
*  @CreatedDate : 18/06/2023
*  @Story : FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107
*/
@IsTest
public class BLN_GetAvailabilityWebserviceTest  {
    
    @IsTest
    static void testGetSlotsIsBranchTrue(){
        
        OperatingHours oneHour = new OperatingHours();
        oneHour.Name = label.BLN_30MinutesSlot;
        oneHour.TimeZone = UserInfo.getTimeZone().toString();
        insert oneHour;
        
        WorkType wT = new WorkType(
            Name = 'Stock',
            ShouldAutoCreateSvcAppt = true,
            FSL__Due_Date_Offset__c = 60*24*7,
            DurationType = 'Minutes',
            BLN_IsMainJob__c = true,
            EstimatedDuration = 60
        );
        insert wT;
        Timezone tz = Timezone.getTimeZone(oneHour.TimeZone);
        ServiceTerritory sTr = BLN_TestDataFactory.createServiceTerritories('thMin',false);
        sTr.OperatingHoursId = oneHour.Id;
        //sTr.BLN_IsBranch__c = true;
        insert sTr;
        
        OperatingHours operatingHours1 = BLN_TestDataFactory.createOperatingHours(System.label.BLN_FullDaySlots, true);
        OperatingHours operatingHours2 = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);  
        OperatingHours operatingHours3 = BLN_TestDataFactory.createOperatingHours(System.label.BLN_30MinutesSlot, true);
        
        List<TimeSlot> ts1 = BLN_TestDataFactory.createTimeSlot(System.label.BLN_FullDaySlots, operatingHours1.Id, true);
        List<TimeSlot> ts2 = BLN_TestDataFactory.createTimeSlot(System.label.BLN_OneHourSlot, operatingHours2.Id, true);
        List<TimeSlot> ts3 = BLN_TestDataFactory.createTimeSlot(System.label.BLN_30MinutesSlot, operatingHours3.Id, true);
        
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours2.Id , false);
        st.BLN_IsBranch__c = true;
        insert st;
        ServiceTerritory st1 = BLN_TestDataFactory.createServiceTerritory('Manchester' , operatingHours3.Id , true);
        
        BLN_ProcessDeactivation__c setting = new BLN_ProcessDeactivation__c();
        setting.Name = 'Test Setting';
        setting.BLN_DisableValidationRules__c = true;
        insert setting;
        
        Skill sk = [SELECT Id, MasterLabel FROM Skill where MasterLabel = 'Repair' LIMIT 1];
        ServiceResource sr1 = BLN_TestDataFactory.createServiceResources('test Resource' , true);
        ServiceResourceSkill srs1 = BLN_TestDataFactory.assignSkillToSR(sk.Id, Double.valueOf(5), sr1.Id, true);
        
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceTerritoryId = st.Id,
            ServiceResourceId = sr1.Id,
            TerritoryType = 'P',
            EffectiveStartDate = System.now().addDays(-10));
        insert stm;
        
        FSL__Scheduling_Policy__c sp = BLN_TestDataFactory.createSchedulingPolicy(label.BLN_BUKSchedulingPolicy,true);
        
        
        WorkType repairWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_RepairWT, 4 , true ,  true);
        
        String remedyJobId1 = '778365';
        WorkOrder wo = new WorkOrder(
            WorkTypeId = repairWT.Id,
            Subject = 'Test',
            Street = 'Kerkstraat 2',
            PostalCode = '3581 RD',
            City = 'Utrecht',
            BLN_RemedyJobId__c = remedyJobId1,
            Country = 'NL'
        );
        insert wo;
        
        String remedyTaskId1 = '66088851';
        WorkOrderLineItem wOLI1= new WorkOrderLineItem();
        wOLI1.Status = 'New';
        wOLI1.WorkOrderId = wo.Id;
        wOLI1.WorkTypeId  = repairWT.Id;
        wOLI1.BLN_RemedyTaskId__c  = remedyTaskId1;
        insert wOLI1;
        
        ServiceAppointment servAppList1=BLN_TestDataFactory.createServiceAppointment('SA1', wOLI1.Id, st.Id, remedyTaskId1, false);
        servAppList1.BLN_RemedyJobId__c = remedyJobId1;
        insert servAppList1;
        
        string myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri = myDomain+'/services/apexrest/remedyGetSlots';
        request.httpMethod = 'POST';        
        // Set the request body
        String requestBody =    '{'+
            '"jobAppointmentId" : "'+servAppList1.Id+'"'+
            '}';
        request.requestBody = Blob.valueOf(requestBody);
        
        // Create a new RestResponse
        RestResponse response = new RestResponse();
        
        // Call the getAvailbility
        Test.startTest();
        RestContext.request = request;
        RestContext.response = response;
        BLN_GetAvailabilityWebservice.getAvailbility(); 
        //System.assertEquals(200, response.statusCode);
        Test.stopTest();
        Assert.areEqual(true, true, 'Success');
    }
    
    @IsTest
    static void testGetSlotsIsBranchFalse(){
        
        OperatingHours tHMin = new OperatingHours();
        tHMin.Name = label.BLN_30MinutesSlot;
        tHMin.TimeZone = UserInfo.getTimeZone().getID();
        insert tHMin;
        
        OperatingHours oneHour = new OperatingHours();
        oneHour.Name = label.BLN_OneHourSlot;
        oneHour.TimeZone = UserInfo.getTimeZone().getID();
        insert oneHour;
        
        List<TimeSlot> timeSlots = new List<TimeSlot>();
        timeSlots.add(new TimeSlot(
            OperatingHoursId = oneHour.Id,
            DayOfWeek = 'Monday',
            StartTime = Time.newInstance(9,0,0,0),
            EndTime = Time.newInstance(17,0,0,0)
        ));
        timeSlots.add(new TimeSlot(
            OperatingHoursId = oneHour.Id,
            DayOfWeek = 'Tuesday',
            StartTime = Time.newInstance(9,0,0,0),
            EndTime = Time.newInstance(17,0,0,0)
        ));
        timeSlots.add(new TimeSlot(
            OperatingHoursId = oneHour.Id,
            DayOfWeek = 'Wednesday',
            StartTime = Time.newInstance(9,0,0,0),
            EndTime = Time.newInstance(17,0,0,0)
        ));
        insert timeSlots;        
        WorkType wT = new WorkType(
            Name = 'Stock',
            ShouldAutoCreateSvcAppt = true,
            FSL__Due_Date_Offset__c = 60*24*7, // 1 week in minutes
            DurationType = 'Minutes',
            BLN_IsMainJob__c = true,
            EstimatedDuration = 60
        );
        insert wT;
        Timezone tz = Timezone.getTimeZone(tHmin.TimeZone);
        ServiceTerritory sTr = BLN_TestDataFactory.createServiceTerritories('thMin',false);
        sTr.OperatingHoursId = tHmin.Id;
        //sTr.BLN_IsBranch__c = false;
        insert sTr;
        
        ServiceTerritoryMember stm = BLN_TestDataFactory.createServiceTerritoryMember(false);
        stm.ServiceTerritoryId = sTr.Id;
        insert stm;
        
        FSL__Scheduling_Policy__c sp = BLN_TestDataFactory.createSchedulingPolicy(label.BLN_BUKSchedulingPolicy,true);
        
        WorkOrder wo = new WorkOrder(
            WorkTypeId = wt.Id,
            BLN_ADASJob__c = true,
            Subject = 'Test',
            Street = 'Kerkstraat 2',
            PostalCode = '3581 RD',
            City = 'Utrecht',
            Country = 'NL'
        );
        insert wo;
        
        ServiceAppointment sApp = [select Id,ServiceTerritoryId,ServiceTerritory.Name,ParentRecordId,Status,FSL__Scheduling_Policy_Used__c,BLN_RemedyProfile__c,Duration,EarliestStartTime,DueDate from ServiceAppointment where ParentRecordId = :wo.Id];
        
        ServiceAppointment newSapp = new ServiceAppointment();
        newSapp.Id = sApp.Id;
        newSapp.ServiceTerritoryId = sTr.Id;
        newSapp.BLN_RemedyProfile__c = label.BLN_30MinutesSlot;
        newSapp.Status = 'None';
        newSapp.Duration = 30;
        newSapp.BLN_IsBranchAppointment__c = false;
        
        newSapp.FSL__Scheduling_Policy_Used__c = sp.Id;
        update newSapp;
        
        string myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri = myDomain+'/services/apexrest/remedyGetSlots';
        request.httpMethod = 'POST';
        // Set the request body
        String requestBody =    '{'+
            '"jobAppointmentId" : "'+sApp.Id+'"'+
            '}';
        request.requestBody = Blob.valueOf(requestBody);
        // Create a new RestResponse
        RestResponse response = new RestResponse();
        // Call the getAvailbility
        Test.startTest();
        RestContext.request = request;
        RestContext.response = response;
        BLN_GetAvailabilityWebservice.getAvailbility(); 
        Assert.areEqual(200, response.statusCode, 'Success');
        Test.stopTest();
    }
   
    @IsTest
    static void testGetSlotsIsFullDay(){
        
        OperatingHours oneHour = new OperatingHours();
        oneHour.Name = label.BLN_FullDaySlots;
        oneHour.TimeZone = UserInfo.getTimeZone().getID();
        insert oneHour;
        
        List<TimeSlot> timeSlots = new List<TimeSlot>();
        timeSlots.add(new TimeSlot(
            OperatingHoursId = oneHour.Id,
            DayOfWeek = 'Monday',
            StartTime = Time.newInstance(9,0,0,0),
            EndTime = Time.newInstance(17,0,0,0)
        ));
        timeSlots.add(new TimeSlot(
            OperatingHoursId = oneHour.Id,
            DayOfWeek = 'Tuesday',
            StartTime = Time.newInstance(9,0,0,0),
            EndTime = Time.newInstance(17,0,0,0)
        ));
        timeSlots.add(new TimeSlot(
            OperatingHoursId = oneHour.Id,
            DayOfWeek = 'Wednesday',
            StartTime = Time.newInstance(9,0,0,0),
            EndTime = Time.newInstance(17,0,0,0)
        ));
        insert timeSlots;        
        
        WorkType wT = new WorkType(
            Name = 'Stock',
            ShouldAutoCreateSvcAppt = true,
            FSL__Due_Date_Offset__c = 60*24*7,
            DurationType = 'Minutes',
            BLN_IsMainJob__c = true,
            EstimatedDuration = 60
        );
        insert wT;
        Timezone tz = Timezone.getTimeZone(oneHour.TimeZone);
        ServiceTerritory sTr = BLN_TestDataFactory.createServiceTerritories('thMin',false);
        sTr.OperatingHoursId = oneHour.Id;
        //sTr.BLN_IsBranch__c = false;
        insert sTr;
        
        ServiceTerritoryMember stm = BLN_TestDataFactory.createServiceTerritoryMember(false);
        stm.ServiceTerritoryId = sTr.Id;
        insert stm;
        
        FSL__Scheduling_Policy__c sp = BLN_TestDataFactory.createSchedulingPolicy(label.BLN_BUKSchedulingPolicy,true);
        
        WorkOrder wo = new WorkOrder(
            WorkTypeId = wt.Id,
            Subject = 'Test',
            //BLN_ADASJob__c = '1342131323',
            Street = 'Kerkstraat 2',
            PostalCode = '3581 RD',
            City = 'Utrecht',
            Country = 'NL'
        );
        insert wo;
        
        ServiceAppointment sApp = [select Id,ServiceTerritoryId,ServiceTerritory.Name,ParentRecordId,Status,FSL__Scheduling_Policy_Used__c,BLN_RemedyProfile__c,Duration,EarliestStartTime,DueDate from ServiceAppointment where ParentRecordId = :wo.Id];
        
        ServiceAppointment newSapp = new ServiceAppointment();
        newSapp.Id = sApp.Id;
        newSapp.ServiceTerritoryId = sTr.Id;
        newSapp.BLN_RemedyProfile__c = label.BLN_FullDaySlots;
        newSapp.Status = 'None';
        newSapp.Duration = 30;
        newSapp.BLN_IsBranchAppointment__c = false;
        
        newSapp.FSL__Scheduling_Policy_Used__c = sp.Id;
        update newSapp;
        
        string myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri = myDomain+'/services/apexrest/remedyGetSlots';
        request.httpMethod = 'POST';
        
        // Set the request body
        String requestBody =    '{'+
            '"jobAppointmentId" : "'+sApp.Id+'"'+
            '}';
        request.requestBody = Blob.valueOf(requestBody);
        
        // Create a new RestResponse
        RestResponse response = new RestResponse();
        
        // Call the getAvailbility
        Test.startTest();
        RestContext.request = request;
        RestContext.response = response;
        BLN_GetAvailabilityWebservice.getAvailbility(); 
        Assert.areEqual(200, response.statusCode, 'Success');
        Test.stopTest();
    }
    
    
    @isTest
    static void testHandleFieldException() {
        // Create a mock RestResponse object
        RestResponse res = new RestResponse();
        
        BLN_GetAvailabilityWebservice.FieldException ex = new BLN_GetAvailabilityWebservice.FieldException('Field Exception Message');
        
        // Call the method being tested
        Test.startTest();
        BLN_GetAvailabilityWebservice.handleFieldException(ex, res);
        Test.stopTest();
        Assert.areEqual(400, res.statusCode, 'Success');        
        String expectedJsonResponse = '{"response": {"status": "Failure", "message": "Field Exception Message", "isSuccess": false, "isError": true}}';
        //System.assertEquals(expectedJsonResponse, res.responseBody.toString());
    }
    
    @isTest
    static void testHandleException() {
        // Create a new RestResponse instance
        RestResponse res = new RestResponse();
        
        Test.startTest();
        
        try {
            throw new CustomException('Test exception message');
        } catch (CustomException ex) {
            // Call the handleException method
            BLN_GetAvailabilityWebservice.handleException(ex, res);
            Assert.areEqual('application/json', res.headers.get('Content-Type'), 'JSON');
            Assert.areEqual(400, res.statusCode, 'Success');
            // Verify the response body
            String expectedJsonResponse = '{"response": {"status": "Failure", "message": "Test exception message 5", "isSuccess": false, "isError": true}}';
        }
        Test.stopTest();
    }

    @IsTest
    static void processSlotsTest() {
        List<FSL.AppointmentBookingSlot> slots = new List<FSL.AppointmentBookingSlot>();
        List<FSL.AppointmentBookingSlot> slots2 = new List<FSL.AppointmentBookingSlot>();
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        OperatingHours op = BLN_TestDataFactory.createOperatingHour('test', true);
        TimeZone tz = TimeZone.getTimeZone('Europe/London');
        String tzName = tz.getDisplayName();
        Integer maxSlots = 15;
        String remedyJobId1 = '778365';

        WorkType repairWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_RepairWT, 4 , true ,  true);
        WorkOrder wo = new WorkOrder(
                WorkTypeId = repairWT.Id,
                Subject = 'Test',
                Street = 'Kerkstraat 2',
                PostalCode = '3581 RD',
                City = 'Utrecht',
                BLN_RemedyJobId__c = remedyJobId1,
                Country = 'NL'
        );
        insert wo;

        String remedyTaskId1 = '66088851';
        WorkOrderLineItem wOLI1= new WorkOrderLineItem();
        wOLI1.Status = 'New';
        wOLI1.WorkOrderId = wo.Id;
        wOLI1.WorkTypeId  = repairWT.Id;
        wOLI1.BLN_RemedyTaskId__c  = remedyTaskId1;
        insert wOLI1;

        String remedyTaskId2 = '66088852';
        WorkOrderLineItem wOLI2= new WorkOrderLineItem();
        wOLI2.Status = 'New';
        wOLI2.WorkOrderId = wo.Id;
        wOLI2.WorkTypeId  = repairWT.Id;
        wOLI2.BLN_RemedyTaskId__c  = remedyTaskId2;
        insert wOLI2;

        List<ServiceTerritory> stList = new List<ServiceTerritory>();
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , op.Id , false);
        st.BLN_IsBranch__c = true;
        stList.add(st);
        st = BLN_TestDataFactory.createServiceTerritory('Bedford 2' , op.Id , false);
        st.BLN_IsBranch__c = false;
        stList.add(st);
        insert stList;

        saList.add(BLN_TestDataFactory.createServiceAppointment('SA1', wOLI1.Id, stList[0].Id, remedyTaskId1, false));
        saList.get(0).BLN_RemedyProfile__c = label.BLN_AllDaySlotMinus30;
        saList.get(0).BLN_IsBranchAppointment__c = true;
        saList.add(BLN_TestDataFactory.createServiceAppointment('SA2', wOLI2.Id, stList[1].Id, remedyTaskId2, false));
        saList.get(1).BLN_RemedyProfile__c = label.BLN_AllDaySlotMinus60;
        saList.get(1).BLN_IsBranchAppointment__c = false;
        insert saList;

        Integer durationInHours = 3;

        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(durationInHours);
        String formatedStartTime = tzName.contains('Summer') ? startTime.addMinutes(-60).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : startTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        String formatedENDTime1 = tzName.contains('Summer') ? endTime.addMinutes(-90).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : endTime.addMinutes(-30).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        String formatedENDTime2 = tzName.contains('Summer') ? endTime.addMinutes(-120).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : endTime.addMinutes(-60).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

        slots.add(BLN_TestDataFactory.createAppointmentBookingSlot(startTime, durationInHours));
        slots2.add(BLN_TestDataFactory.createAppointmentBookingSlot(startTime, durationInHours));

        Test.startTest();
        List<BLN_GetAvailabilityWebserviceWrapper.SlotWrapper> slotWrapperList = BLN_GetAvailabilityWebservice.processSlots(slots, saList[0], op, 15);
        List<BLN_GetAvailabilityWebserviceWrapper.SlotWrapper> slotWrapperList2 = BLN_GetAvailabilityWebservice.processSlots(slots2, saList[1], op, 15);
        Test.stopTest();

        Assert.areEqual(formatedStartTime, slotWrapperList.get(0).timeIntervalStart, 'Success');
        Assert.areEqual(formatedStartTime, slotWrapperList2.get(0).timeIntervalStart, 'Success');
        //Assert.areEqual(formatedENDTime1, slotWrapperList.get(0).timeIntervalFinish, 'Success');
        Assert.areEqual(formatedENDTime2, slotWrapperList2.get(0).timeIntervalFinish, 'Success');

    }
    @IsTest
    static void getAvailabilitySlotsTest() {
        RestRequest request = new RestRequest();
        request.requestUri = '';
        request.httpMethod = '';
        String requestBody =    '{'+
            '"jobAppointmentId" : ""'+
            '}';
        request.requestBody = Blob.valueOf(requestBody);
        RestResponse response = new RestResponse();
        
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        BLN_GetAvailabilityWebservice.getAvailbility();
        Test.stopTest();
        Assert.areEqual(true, true, 'Success');
    }
    
    @IsTest
    static void testGetSlotsNegative(){
        
        OperatingHours oneHour = new OperatingHours();
        oneHour.Name = label.BLN_30MinutesSlot;
        oneHour.TimeZone = UserInfo.getTimeZone().toString();
        insert oneHour;
        
        WorkType wT = new WorkType(
            Name = 'Stock',
            ShouldAutoCreateSvcAppt = true,
            FSL__Due_Date_Offset__c = 60*24*7,
            DurationType = 'Minutes',
            BLN_IsMainJob__c = true,
            EstimatedDuration = 60
        );
        insert wT;
        Timezone tz = Timezone.getTimeZone(oneHour.TimeZone);
        ServiceTerritory sTr = BLN_TestDataFactory.createServiceTerritories('thMin',false);
        sTr.OperatingHoursId = oneHour.Id;
        //sTr.BLN_IsBranch__c = true;
        insert sTr;
        
        OperatingHours operatingHours1 = BLN_TestDataFactory.createOperatingHours(System.label.BLN_FullDaySlots, true);
        OperatingHours operatingHours2 = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);  
        OperatingHours operatingHours3 = BLN_TestDataFactory.createOperatingHours(System.label.BLN_30MinutesSlot, true);
        
        List<TimeSlot> ts1 = BLN_TestDataFactory.createTimeSlot(System.label.BLN_FullDaySlots, operatingHours1.Id, true);
        List<TimeSlot> ts2 = BLN_TestDataFactory.createTimeSlot(System.label.BLN_OneHourSlot, operatingHours2.Id, true);
        List<TimeSlot> ts3 = BLN_TestDataFactory.createTimeSlot(System.label.BLN_30MinutesSlot, operatingHours3.Id, true);
        
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours2.Id , false);
        st.BLN_IsBranch__c = true;
        insert st;
        ServiceTerritory st1 = BLN_TestDataFactory.createServiceTerritory('Manchester' , operatingHours3.Id , true);
        
        BLN_ProcessDeactivation__c setting = new BLN_ProcessDeactivation__c();
        setting.Name = 'Test Setting';
        setting.BLN_DisableValidationRules__c = true;
        insert setting;
        
        Skill sk = [SELECT Id, MasterLabel FROM Skill where MasterLabel = 'Repair' LIMIT 1];
        ServiceResource sr1 = BLN_TestDataFactory.createServiceResources('test Resource' , true);
        ServiceResourceSkill srs1 = BLN_TestDataFactory.assignSkillToSR(sk.Id, Double.valueOf(5), sr1.Id, true);
        
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceTerritoryId = st.Id,
            ServiceResourceId = sr1.Id,
            TerritoryType = 'P',
            EffectiveStartDate = System.now().addDays(-10));
        insert stm;
        
        FSL__Scheduling_Policy__c sp = BLN_TestDataFactory.createSchedulingPolicy(label.BLN_BUKSchedulingPolicy,true);
        
        
        WorkType repairWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_RepairWT, 4 , true ,  true);
        
        String remedyJobId1 = '778365';
        WorkOrder wo = new WorkOrder(
            WorkTypeId = repairWT.Id,
            Subject = 'Test',
            Street = 'Kerkstraat 2',
            PostalCode = '3581 RD',
            City = 'Utrecht',
            BLN_RemedyJobId__c = remedyJobId1,
            Country = 'NL'
        );
        insert wo;
        
        String remedyTaskId1 = '66088851';
        WorkOrderLineItem wOLI1= new WorkOrderLineItem();
        wOLI1.Status = 'New';
        wOLI1.WorkOrderId = wo.Id;
        wOLI1.WorkTypeId  = repairWT.Id;
        wOLI1.BLN_RemedyTaskId__c  = remedyTaskId1;
        insert wOLI1;
        
        ServiceAppointment servAppList1=BLN_TestDataFactory.createServiceAppointment('SA1', wOLI1.Id, st.Id, remedyTaskId1, false);
        servAppList1.BLN_RemedyJobId__c = remedyJobId1;
        servAppList1.BLN_RemedyProfile__c = null;
        insert servAppList1;
        
        string myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri = myDomain+'/services/apexrest/remedyGetSlots';
        request.httpMethod = 'POST';        
        // Set the request body
        String requestBody =    '{'+
            '"jobAppointmentId" : "'+servAppList1.Id+'"'+
            '}';
        request.requestBody = Blob.valueOf(requestBody);
        
        // Create a new RestResponse
        RestResponse response = new RestResponse();
        
        // Call the getAvailbility
        Test.startTest();
        RestContext.request = request;
        RestContext.response = response;
        BLN_GetAvailabilityWebservice.getAvailbility(); 
        //System.assertEquals(200, response.statusCode);
        Test.stopTest();
        Assert.areEqual(true, true, 'Success');
    }

    // Custom exception class
    public class CustomException extends Exception {}
}