/**  @description : This Test class is for BLN_IntegrationLogger.
*    @Story : FOUK-252
*    @author: Wasim(PwC IN)
*    @CreatedDate: 02/08/2023
*/

@IsTest
public class BLN_IntegrationLoggerTest {
    @IsTest
    public static void unitTest(){
         List<BLN_IntegrationLogger__c> integrationLoggerList = BLN_TestDataFactory.integrationLoggerData('test names', true);
        // Start the test context.
        Test.startTest();
        BLN_IntegrationLogger.logRequest(integrationLoggerList);
        // Stop the test context.
        Test.stopTest();
        List<BLN_IntegrationLogger__c> insertedLogs = [SELECT Id FROM BLN_IntegrationLogger__c];
        System.assertEquals(integrationLoggerList.size(), insertedLogs.size(), 'Number of inserted logs does not match');
    }
        @isTest
    public static void captureIntegrationLoggerTest(){
        // Start the test context.
        Test.startTest();
        Assert.isTrue(BLN_IntegrationLogger.captureIntegrationLogger('',System.label.BLN_True,'',System.now(),System.now(),new Map<String,String>(),new HttpRequest(),new HttpResponse()).isSuccess(),'');
       // Stop the test context.
        Test.stopTest();
    }
    @isTest
    public static void captureIntegrationLoggerFutureTest(){
        // Start the test context.
        Test.startTest();
        map<string, string> maps = new map<string,string>();
        maps.put(System.label.BLN_True, System.label.BLN_True);
        

        BLN_IntegrationLogger.captureIntegrationLoggerFuture('',System.label.BLN_True,'',System.now(),System.now(),maps,'','');
        System.assertEquals(1, Limits.getFutureCalls(), 'No future calls should be made during this test');
        // Stop the test context.
        Test.stopTest();
    }
    @isTest
    public static void createIntegrationLoggersTest(){
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
        //Timezone tz = Timezone.getTimeZone(oneHour.TimeZone);
        ServiceTerritory sTr = BLN_TestDataFactory.createServiceTerritories('thMin',false);
        sTr.OperatingHoursId = oneHour.Id;
        //sTr.BLN_IsBranch__c = true;
        insert sTr;
        
        //OperatingHours operatingHours1 = BLN_TestDataFactory.createOperatingHours(System.label.BLN_FullDaySlots, true);
        OperatingHours operatingHours2 = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);  
        //OperatingHours operatingHours3 = BLN_TestDataFactory.createOperatingHours(System.label.BLN_30MinutesSlot, true);
        
        //List<TimeSlot> ts1 = BLN_TestDataFactory.createTimeSlot(System.label.BLN_FullDaySlots, operatingHours1.Id, true);
        //List<TimeSlot> ts2 = BLN_TestDataFactory.createTimeSlot(System.label.BLN_OneHourSlot, operatingHours2.Id, true);
        //List<TimeSlot> ts3 = BLN_TestDataFactory.createTimeSlot(System.label.BLN_30MinutesSlot, operatingHours3.Id, true);
        
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours2.Id , false);
        st.BLN_IsBranch__c = true;
        insert st;
        //ServiceTerritory st1 = BLN_TestDataFactory.createServiceTerritory('Manchester' , operatingHours3.Id , true);
        
        BLN_ProcessDeactivation__c setting = new BLN_ProcessDeactivation__c();
        setting.Name = 'Test Setting';
        setting.BLN_DisableValidationRules__c = true;
        insert setting;
        
        //Skill sk = [SELECT Id, MasterLabel FROM Skill where MasterLabel = 'Repair' LIMIT 1];
        ServiceResource sr1 = BLN_TestDataFactory.createServiceResources('test Resource' , true);
        //ServiceResourceSkill srs1 = BLN_TestDataFactory.assignSkillToSR(sk.Id, Double.valueOf(5), sr1.Id, true);
        
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceTerritoryId = st.Id,
            ServiceResourceId = sr1.Id,
            TerritoryType = 'P',
            EffectiveStartDate = System.now().addDays(-10));
        insert stm;
        
        //FSL__Scheduling_Policy__c sp = BLN_TestDataFactory.createSchedulingPolicy(label.BLN_BUKSchedulingPolicy,true);
        
        
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
        
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        BLN_IntegrationLogger.createIntegrationLoggers('secondsGap', response, request, servAppList1.Id, 'auth', 'instanceUrl', 'countryCode','', false);
        BLN_IntegrationLogger.createIntegrationLoggers('secondsGap', response, request, servAppList1.Id, 'auth', 'instanceUrl','', false);
        system.assertEquals('Test', wo.Subject, 'Not Equal');
    }
    
}