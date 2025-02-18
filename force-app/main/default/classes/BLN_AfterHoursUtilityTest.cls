/**@description : This Apex class used to cover BLN_AfterHoursUtility class.
*  @author: PwC India
*  @Story: FOUK-3762
*  @CreatedDate: 29/05/2024
*/

@isTest
public class BLN_AfterHoursUtilityTest {
    static FSL__Scheduling_Policy__c schedulingPolicy;
    static OperatingHours operatingHours;
    static ServiceTerritory st;
    static Account acc;
    static Case newCase;
    static WorkType repairWT;
    static WorkOrder workOrder1;
    static WorkOrderLineItem wOLI1;
    static  String remedyTaskId1 = '66088851';
    static BLN_AccountRuleParameter__c arp;
    static BusinessHours businessHour;
    static String jsonProductData = '{"quotes":[{"quoteId":"1","lineItems":[{"partNumber":"ABC123","netPriceIncludingTax":100.00}]}]}';
    static String slotdate = '[{"appointments":[{"slotDateTimeEndString":"2024-06-03T10:00:00Z" , "slotDateTimeFinish":"2024-06-03T10:00:00Z" ,"slotDateTimeStart":"2024-06-03T10:00:00Z","productAvailibilities":[{"products":[{"productEnable":true,"prodCategory":"Category"}]}]}]}]';
    static String selectedProductJson = '[{"prodCategory":"REAR DOOR LEFT GLASS"}]';
    
    
    // this method is used to setup data.
    @testsetup
    static void afterHourUtility() {
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = 'Test Scheduling Policy';
        insert schedulingPolicy;
        
        // Create operating hours and service territory
        operatingHours = BLN_TestDataFactory.createOperatingHours('Test Operating Hours', true);
        st = BLN_TestDataFactory.createServiceTerritory('Bedford123', operatingHours.Id, false);
        st.BLN_SchedulingPolicy__c = schedulingPolicy.Id;
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = 'Mobile'; 
        st.street = '';
        st.city = 'Bedford123';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        insert st;
        
        // Create an account
        acc = new Account(Name = 'Test AccountAfterHourUtility', BLn_ClientType__c = 'Insurance');
        insert acc;
        
        // Create a case
        newCase = new Case(Status='New', Origin='Phone', AccountId=acc.Id);
        insert newCase;
        
        // Create a repair work type
        repairWT = BLN_TestDataFactory.createWorkType('Repair Work Type', 4, true, true);
        
        // Create a work order associated with the case
        workOrder1 = BLN_TestDataFactory.createWorkOrder2(repairWT.Id, st.Id, false);
        workOrder1.CaseId = newCase.Id;
        workOrder1.accountId = newCase.AccountId;
        workOrder1.BLN_RemedyJobId__c = '0969964544427';
        insert workOrder1;
        
        // Create a work order line item
        wOLI1 = new WorkOrderLineItem(
            Status = 'New',
            WorkOrderId = workOrder1.Id,
            WorkTypeId = repairWT.Id,
            BLN_RemedyTaskId__c = remedyTaskId1
        );
        insert wOLI1;
        
        // Create account rule parameter
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('After Hours').getRecordTypeId();
        String productAllowanceRecTypId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Product Allowance').getRecordTypeId();

        businessHour = [SELECT Id,Name, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
                        WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, 
                        FridayStartTime, FridayEndTime,SaturdayStartTime, SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours LIMIT 1];
        arp = new BLN_AccountRuleParameter__c(
            BLN_Account__c = acc.Id,
            RecordTypeId = arpRecordTypeId,
            BLN_ProductCategory__c = 'Test Product',
            BLN_AfterHours__c = businessHour.Id,
            BLN_ActiveFrom__c = System.now().addDays(-1).date(),
            BLN_ActiveTo__c = System.now().addDays(1).date(),
            BLN_InheritanceBehaviour__c='Lowest Level'
        );
        insert arp;
        
        

    }
    
    @isTest
    static void testAfterHourChargesWeekdays() {
        Boolean isCashJourney = false;
        
        WorkOrderLineItem wOLI1 = [SELECT Id,Status FROM WorkOrderLineItem WHERE Status='New'  LIMIT 1];
        ServiceTerritory st = [SELECT Id,city FROM ServiceTerritory WHERE city = 'Bedford123' LIMIT 1];
        Case newCase =[select id,Origin from case where Origin='Phone' limit 1];
        ServiceAppointment serviceAppointment = BLN_TestDataFactory.createServiceAppointment('SA1', wOLI1.Id, st.Id, '66088851', true);
        serviceAppointment.BLN_Case__c = newCase.Id;
        serviceAppointment.ArrivalWindowStartTime = Datetime.newInstance(2024, 05, 21, 9, 0, 0);
        update serviceAppointment;
        
        List<ServiceAppointment> serviceAppointments = new List<ServiceAppointment>();
        serviceAppointments.add(serviceAppointment);
        // Create a list to hold the ServiceAppointment IDs
        List<String> saList = new List<String>();
        for(ServiceAppointment sa : serviceAppointments) {
            saList.add(sa.Id);
        }
        
        Test.startTest();
        BLN_AfterHoursUtility.afterHourUtility(saList,  jsonProductData, selectedProductJson,isCashJourney,newCase.id,slotdate);
        Test.stopTest();
        System.assertEquals(1, saList.size(),'saList is greater than zero'); 
    }
    
    // This method covers for Sunday and call main method
    @isTest
    static void testAfterHourProdcategory() {
        acc = new Account(Name = 'Test AccountAfterHourProdcategory', BLn_ClientType__c = 'Insurance');
        insert acc;
        Boolean isCashJourney = true;
        String dayofweek='Sunday';
        String prodCategory='1210,1211,1215,1216,1217,1218,1220,1225,1226,1227,1228,1229,1230,1235,1240,1250,1255,1256,1258,1260,1265,1266,1268,1270,1280';
        Time appointmentTime= Time.newInstance(14, 0, 0, 0);
        //Time appointmentTimeEND = Time.newInstance(16, 0, 0, 0);
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_VehicleRegNumber__c='BN12OEE';
        insert veh;
        Id corpRecTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_CorporateFleet').getRecordTypeId();
        BLN_Corporate__c corporate = BLN_TestDataFactory.createcorporate();
        corporate.BLN_Vehicle__c=veh.Id;
        corporate.BLN_CorporateCountryGrouping__c=acc.id;
        corporate.BLN_CorporateLegalEntity__c=acc.id;
        corporate.RecordTypeId =corpRecTypeId;
        insert corporate;
        
        Id splitCorpRecTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get(System.label.BLN_SpiltBill).getRecordTypeId();
        BLN_Corporate__c splitCorporate = BLN_TestDataFactory.createcorporate();
        splitCorporate.BLN_Vehicle__c=veh.Id;
        splitCorporate.BLN_InsuranceSite__c=acc.id;
        splitCorporate.BLN_InsuranceLegalEntity__c=acc.id;
        splitCorporate.RecordTypeId =splitCorpRecTypeId;
        insert splitCorporate;
        
         Id corpInsuranceRecTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_CorporateFleet').getRecordTypeId();
        BLN_Corporate__c corporateInsurance = BLN_TestDataFactory.createcorporate();
        corporateInsurance.BLN_Vehicle__c=veh.Id;
        corporateInsurance.BLN_InsuranceSite__c=acc.id;
        corporateInsurance.BLN_InsuranceLegalEntity__c=acc.id;
        corporateInsurance.RecordTypeId =corpInsuranceRecTypeId;
        insert corporateInsurance;
        
        newCase = new Case(Status='New', Origin='Phone', AccountId=acc.Id,BLN_Corporate__c = corporate.id ,BLN_IncidentDate__c = Date.today());
        insert newCase;
        Date myDate =Date.today();
        Test.startTest();
        List<BLN_AfterHoursUtility.AfterHourWrapper> result  = BLN_AfterHoursUtility.checkBusinessHours( isCashJourney,  jsonProductData,  dayofweek,  appointmentTime, prodCategory , newCase.id, myDate);
        
        System.assertNOTEquals(1, result.size(),'result is zero'); 
        
        Case newTestCase = new Case(Status='New', Origin='Phone', AccountId=acc.Id,BLN_Corporate__c = corporate.id);
        insert newTestCase;
        
        List<BLN_AfterHoursUtility.AfterHourWrapper> resultCheck  = BLN_AfterHoursUtility.checkBusinessHours( isCashJourney,  jsonProductData,  dayofweek,  appointmentTime, prodCategory , newTestCase.id, myDate);
        
        System.assertNOTEquals(1, resultCheck.size(),'result is zero'); 

         newCase.BLN_Corporate__c = splitCorporate.Id;
         update newCase;
         isCashJourney = false;
         List<BLN_AfterHoursUtility.AfterHourWrapper> splitResult  = New List<BLN_AfterHoursUtility.AfterHourWrapper> ();
         splitResult = BLN_AfterHoursUtility.checkBusinessHours( isCashJourney,  jsonProductData,  dayofweek,  appointmentTime, prodCategory , newCase.id, myDate);
         
          newCase.BLN_Corporate__c = corporateInsurance.Id;
       	  update newCase;
          isCashJourney = false;
          List<BLN_AfterHoursUtility.AfterHourWrapper> insuranceResult  = BLN_AfterHoursUtility.checkBusinessHours( isCashJourney,  jsonProductData,  dayofweek,  appointmentTime, prodCategory , newCase.id, myDate);
         
        Test.stopTest();
    }
    
    @isTest
    static void testAfterHourChargesSunday() {
        Boolean isCashJourney = true;
        String dayofweek='Sunday';
       // String prodCategory='Windscreen';
         String prodCategory='1110,1111,1115,1120,1130,1140,1145,1150,1155,1156,1157,1420';
        Time appointmentTime= Time.newInstance(14, 0, 0, 0);
        //Time appointmentTimeEND = Time.newInstance(16, 0, 0, 0);

        acc = new Account(Name = 'Test AccountAfterHourChargesSunday', BLn_ClientType__c = 'Insurance');
        insert acc;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_VehicleRegNumber__c='BN12OEE';
        insert veh;
        
        BLN_Corporate__c corporate = BLN_TestDataFactory.createcorporate();
        corporate.BLN_Vehicle__c=veh.Id;
        corporate.BLN_CorporateCountryGrouping__c=acc.id;
        insert corporate;
        
        newCase = new Case(Status='New', Origin='Phone', AccountId=acc.Id,BLN_Corporate__c = corporate.id,BLN_IncidentDate__c = Date.today() );
        insert newCase;
        Date myDate =Date.today();
        Test.startTest();
        List<BLN_AfterHoursUtility.AfterHourWrapper> result  = BLN_AfterHoursUtility.checkBusinessHours( isCashJourney,  jsonProductData,  dayofweek,  appointmentTime,  prodCategory , newCase.id, myDate);
        Test.stopTest();
        System.assertNOTEquals(1, result.size(),'result is zero'); 
    }
    
    @isTest
    static void testAfterHourSunday() {
        Boolean isCashJourney = true;
        String dayofweek='Friday';
        String prodCategory='1110,1111,1115,1120,1130,1140,1145,1150,1155,1156,1157,1420';
        Time appointmentTime= Time.newInstance(14, 0, 0, 0);
        //Time appointmentTimeEND = Time.newInstance(16, 0, 0, 0);
        acc = new Account(Name = 'Test AccountAfterHourSunday', BLn_ClientType__c = 'Insurance');
        insert acc;
        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_VehicleRegNumber__c='BN12OEE';
        insert veh;
        
        BLN_Corporate__c corporate = BLN_TestDataFactory.createcorporate();
        corporate.BLN_Vehicle__c=veh.Id;
        corporate.BLN_CorporateCountryGrouping__c=acc.id;
        insert corporate;
        
        Case newCase = new Case(Status='New', Origin='Phone', AccountId=acc.Id,BLN_Corporate__c = corporate.id,BLN_IncidentDate__c = Date.today() );
        insert newCase;
        Test.startTest();
         Date myDate =Date.today();
        List<BLN_AfterHoursUtility.AfterHourWrapper> result  = BLN_AfterHoursUtility.checkBusinessHours( isCashJourney,  jsonProductData,  dayofweek,  appointmentTime, prodCategory , newCase.id, myDate);
        Test.stopTest();
        System.assertNOTEquals(1, result.size(),'result is zero'); 
    }
    
    @isTest
    static void testAfterHourWindscreen() {
        Boolean isCashJourney = true;
        String dayofweek='Friday';
        String prodCategory='1110,1111,1115,1120,1130,1140,1145,1150,1155,1156,1157,1420';
        Time appointmentTime= Time.newInstance(14, 0, 0, 0);
        //Time appointmentTimeEND = Time.newInstance(16, 0, 0, 0);
        acc = new Account(Name = 'Test AccountAfterHourWindscreen', BLn_ClientType__c = 'Insurance');
        insert acc;
        Account acc2 = new Account(Name = 'Test AccountAfterHourWindscreen2', BLn_ClientType__c = 'Insurance');
        insert acc2;

        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_VehicleRegNumber__c='BN12OEE';
        insert veh;
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('After Hours').getRecordTypeId();
        String productAllowanceRecTypId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Product Allowance').getRecordTypeId();
        String splitBillRecTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByName().get('Split Bill').getRecordTypeId();
        
        BLN_Corporate__c corporate = BLN_TestDataFactory.createcorporate();
        corporate.BLN_Vehicle__c=veh.Id;
        corporate.BLN_CorporateCountryGrouping__c=acc.id;
        corporate.BLN_InsuranceSite__c =  acc.Id;
        corporate.BLN_CorporateSite__c = acc2.Id;
        corporate.RecordTypeId = splitBillRecTypeId;
        insert corporate;

        
        newCase = new Case(Status='New', Origin='Phone', AccountId=acc.Id,BLN_Corporate__c = corporate.id ,BLN_IncidentDate__c = Date.today());// BLN_IncidentDate__c = Date.today()
        insert newCase;

                businessHour = [SELECT Id,Name, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
                        WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, 
                        FridayStartTime, FridayEndTime,SaturdayStartTime, SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours LIMIT 1];
        BLN_AccountRuleParameter__c afterhourArp1 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = acc.Id,
            RecordTypeId = arpRecordTypeId,
            BLN_ProductCategory__c = 'Test Product',
            BLN_AfterHours__c = businessHour.Id,
            BLN_ActiveFrom__c = System.now().addDays(-1).date()
            
        );
        insert afterhourArp1;
            BLN_AccountRuleParameter__c afterhourArp2 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = acc2.Id,
            RecordTypeId = arpRecordTypeId,
            BLN_ProductCategory__c = 'Test Product',
            BLN_AfterHours__c = businessHour.Id,
            BLN_ActiveFrom__c = System.now().addDays(-1).date()
            
        );
        insert afterhourArp2;
        Product2 ahProduct = new Product2(Name = 'AHRS (WS & Repairs)',
        ProductCode = 'PSERUK00010A',
        BLN_ProductCategory__c = 'tes3t'

       );
        insert ahProduct;
        BLN_AccountRuleParameter__c productAllowanceArp1 = new BLN_AccountRuleParameter__c(BLN_Account__c = acc.Id,
        RecordTypeId = productAllowanceRecTypId,
        BLN_Product__c = ahProduct.Id,
        BLN_ActiveFrom__c = System.now().addDays(-1).date(),
        BLN_ProductAllowance__c = 'Pass Liability');
        insert productAllowanceArp1;
        
        BLN_AccountRuleParameter__c productAllowanceArp2 = new BLN_AccountRuleParameter__c(BLN_Account__c = acc2.Id,
        RecordTypeId = productAllowanceRecTypId,
        BLN_Product__c = ahProduct.Id,
        BLN_ActiveFrom__c = System.now().addDays(-1).date(),
        BLN_ProductAllowance__c = 'Allow');
        insert productAllowanceArp2;
        
        Date myDate = Date.newInstance(2024, 12, 25);
        Test.startTest(); 
        List<BLN_AfterHoursUtility.AfterHourWrapper> result  = BLN_AfterHoursUtility.checkBusinessHours( isCashJourney,  jsonProductData,  dayofweek,  appointmentTime, prodCategory , newCase.id ,myDate);
         BLN_AfterHoursUtility.checkBusinessHours( false,  jsonProductData,  dayofweek,  appointmentTime, prodCategory , newCase.id, myDate);
        
        Test.stopTest();
   
    
        System.assertNOTEquals(1, result.size(),'result is zero'); 
    }
    @isTest
    static void testAfterHourWindscreen2() {
        Boolean isCashJourney = true;
        String dayofweek='Friday';
        String prodCategory='1110,1111,1115,1120,1130,1140,1145,1150,1155,1156,1157,1420';
        Time appointmentTime= Time.newInstance(14, 0, 0, 0);
        //Time appointmentTimeEND = Time.newInstance(16, 0, 0, 0);
        acc = new Account(Name = 'Test AccountAfterHourWindscreen', BLn_ClientType__c = 'Insurance');
        insert acc;
        Account acc2 = new Account(Name = 'Test AccountAfterHourWindscreen2', BLn_ClientType__c = 'Insurance');
        insert acc2;

        
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_VehicleRegNumber__c='BN12OEE';
        insert veh;
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('After Hours').getRecordTypeId();
        String productAllowanceRecTypId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Product Allowance').getRecordTypeId();
        String splitBillRecTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByName().get('Split Bill').getRecordTypeId();

        BLN_Corporate__c corporate = BLN_TestDataFactory.createcorporate();
        corporate.BLN_Vehicle__c=veh.Id;
        corporate.BLN_CorporateCountryGrouping__c=acc.id;
        corporate.BLN_InsuranceSite__c =  acc.Id;
        corporate.BLN_CorporateSite__c = acc2.Id;
        corporate.RecordTypeId = splitBillRecTypeId;
        insert corporate;

        
        newCase = new Case(Status='New', Origin='Phone', AccountId=acc.Id,BLN_Corporate__c = corporate.id ,BLN_IncidentDate__c = Date.today());// BLN_IncidentDate__c = Date.today()
        insert newCase;

                businessHour = [SELECT Id,Name, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
                        WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, 
                        FridayStartTime, FridayEndTime,SaturdayStartTime, SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours LIMIT 1];
        BLN_AccountRuleParameter__c afterhourArp1 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = acc.Id,
            RecordTypeId = arpRecordTypeId,
            BLN_ProductCategory__c = 'Test Product',
            BLN_AfterHours__c = businessHour.Id,
            BLN_ActiveFrom__c = System.now().addDays(-1).date()
            
        );
        insert afterhourArp1;
            BLN_AccountRuleParameter__c afterhourArp2 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = acc2.Id,
            RecordTypeId = arpRecordTypeId,
            BLN_ProductCategory__c = 'Test Product',
            BLN_AfterHours__c = businessHour.Id,
            BLN_ActiveFrom__c = System.now().addDays(-1).date()
            
        );
        insert afterhourArp2;
        Product2 ahProduct = new Product2(Name = 'AHRS (WS & Repairs)',
        ProductCode = 'PSERUK00010A',
        BLN_ProductCategory__c = 'tes3t'

       );
        insert ahProduct;
        BLN_AccountRuleParameter__c productAllowanceArp1 = new BLN_AccountRuleParameter__c(BLN_Account__c = acc.Id,
        RecordTypeId = productAllowanceRecTypId,
        BLN_Product__c = ahProduct.Id,
        BLN_ActiveFrom__c = System.now().addDays(-1).date(),
        BLN_ProductAllowance__c = 'Pass Liability');
        insert productAllowanceArp1;
        
        BLN_AccountRuleParameter__c productAllowanceArp2 = new BLN_AccountRuleParameter__c(BLN_Account__c = acc2.Id,
        RecordTypeId = productAllowanceRecTypId,
        BLN_Product__c = ahProduct.Id,
        BLN_ActiveFrom__c = System.now().addDays(-1).date(),
        BLN_ProductAllowance__c = 'Do Not Show');
        insert productAllowanceArp2;
        
        Date myDate = Date.newInstance(2024, 12, 25);
        Test.startTest(); 
         BLN_AfterHoursUtility.checkBusinessHours( false,  jsonProductData,  dayofweek,  appointmentTime, prodCategory , newCase.id, myDate);
        
        Test.stopTest();
   
    
    }
    @isTest
    static void testCalculateAfterHourCharges() {
        
        Map<String, String> afterHourProductMap = new Map<String, String>();
        afterHourProductMap.put('After hours Weekday + Saturday (Windscreen & Repairs)', 'ABC123'); // Example data for afterHourProductMap
        Map<String, Decimal> partNumberToNetPriceMap = new Map<String, Decimal>();
        partNumberToNetPriceMap.put('ABC123', 100.00);
        List<Decimal> netTotalPrices = new List<Decimal>();
        List<BLN_AfterHoursUtility.AfterHourWrapper> ahwrapList = new List<BLN_AfterHoursUtility.AfterHourWrapper>();
        BLN_AfterHoursUtility.calculateAfterHourCharges(afterHourProductMap, partNumberToNetPriceMap, 'After hours Weekday + Saturday (Windscreen & Repairs)', netTotalPrices,ahwrapList);
        //BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        System.assertEquals(1, partNumberToNetPriceMap.values().size(),'The size of the map values is not as expected');
    }
    
     @isTest
    static void testGetBusinessHours() {
        List<BusinessHours> businessHour = new List<BusinessHours>();
        businessHour = [SELECT Id,Name, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
                        WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, 
                        FridayStartTime, FridayEndTime,SaturdayStartTime, SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours LIMIT 1];
        businessHour = BLN_AfterHoursUtility.getBusinessHours(businessHour[0].Id);
        System.assertEquals(1, businessHour.size(),'businessHour greater than zero'); 
        
    }
}