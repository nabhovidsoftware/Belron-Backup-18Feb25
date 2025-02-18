/** @description : BLN_AppointmentCreateUpdateTest Class used for testing BLN_AppointmentCreateUpdate.
*  	@author: Wasim Akram
* 	@Story: 
*	@Created Date: 11/12/2023
*/
@isTest
public class BLN_AppointmentCreateUpdateTest {
    public static DateTime todayDate = System.now();
    public static String json = ''; 

    @isTest
    public static void unitTest(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        caseObj.Priority = System.label.BLN_Critical;
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.Name = 'Test';
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_MdMID__c = '43422';
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        BLN_TestDataFactory.createWorkType('Replacement & Recalibration', 4 , true ,  true);
        BLN_TestDataFactory.createWorkType('Replacement', 6 , true ,  true);
        BLN_TestDataFactory.createWorkType('Recalibration', 3 , true ,  true);
        BLN_TestDataFactory.createWorkType('Repair', 7 , true ,  true);
        WorkType stockWT = BLN_TestDataFactory.createWorkType('Stock Collect', 7 , true ,  true);
        BLN_TestDataFactory.createWorkType(System.label.BLN_SideRearReplacementWT, 5 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = new ServiceTerritory();
        System.runAs(u) {
            PermissionSet ps = [SELECT Id 
                                FROM PermissionSet 
                                WHERE Name = 'BLN_BypassFlows'];
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
            st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
            st.BLN_GUID__c = '9y8avfh9';
            st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
            st.BLN_IsBranch__c = true;
            st.BLN_Type__c = System.label.BLN_Branch;
            st.BLN_SplitReplaceAndRecalibration__c = true;
            st.street = '';
            st.city = 'Bedford';
            st.State = '';
            st.postalcode = 'MK44 3US';
            st.Country = 'United Kingdom';
            st.BLN_MaxGapMin__c = 10;
            
            insert st;
        }
        
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
        
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = stockWT.Id;
        workOrders.ServiceTerritoryId = st.id;
        workOrders.CaseId = caseObj.id;
        insert workOrders;
        String errors;
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Quantity = 5;
        INSERT orderItem;
        try{
        	BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
            List<Object> objList = new List<Object>();
            Map<String, Object> obj = new Map<String, Object>{
                'productCode' => prod.BLN_MdMId__c,
                    'quantity' => 5
                    };
                        objList.add(obj);
            BLN_AppointmentCreateUpdate.prepData(objList, caseObj.Id, System.now(), st.BLN_GUID__c);
        } catch (Exception e){
            errors = 'ERROR';
        }
        system.assertEquals(caseObj.Priority, System.label.BLN_Critical, 'Priority Should be same');
    }
    
    @isTest
    public static void unitTest0(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        caseObj.Priority = System.label.BLN_Critical;
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.Name = 'Test';
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_MdMID__c = '43422';
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        BLN_TestDataFactory.createWorkType('Replacement & Recalibration', 4 , true ,  true);
        BLN_TestDataFactory.createWorkType('Replacement', 6 , true ,  true);
        BLN_TestDataFactory.createWorkType('Recalibration', 3 , true ,  true);
        BLN_TestDataFactory.createWorkType('Repair', 7 , true ,  true);
        //WorkType stockWT = BLN_TestDataFactory.createWorkType('Stock Collect', 7 , true ,  true);
        BLN_TestDataFactory.createWorkType(System.label.BLN_SideRearReplacementWT, 5 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = new ServiceTerritory();
        System.runAs(u) {
            PermissionSet ps = [SELECT Id 
                                FROM PermissionSet 
                                WHERE Name = 'BLN_BypassFlows'];
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
            st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
            st.BLN_GUID__c = '9y8avfh9';
            st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
            st.BLN_IsBranch__c = true;
            st.BLN_Type__c = System.label.BLN_Branch;
            st.BLN_SplitReplaceAndRecalibration__c = true;
            st.street = '';
            st.city = 'Bedford';
            st.State = '';
            st.postalcode = 'MK44 3US';
            st.Country = 'United Kingdom';
            st.BLN_MaxGapMin__c = 10;
            
            insert st;
        }
        
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
        
        // WorkOrder workOrders = new WorkOrder();
        // workOrders.BLN_RemedyJobId__c = '001005';
        // workOrders.WorkTypeId = stockWT.Id;
        // workOrders.ServiceTerritoryId = st.id;
        // workOrders.CaseId = caseObj.id;
        // insert workOrders;
        String errors;
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Quantity = 5;
        INSERT orderItem;
        try{
        	BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
            List<Object> objList = new List<Object>();
            Map<String, Object> obj = new Map<String, Object>{
                'productCode' => prod.BLN_MdMId__c,
                    'quantity' => 5
                    };
                        objList.add(obj);
            BLN_AppointmentCreateUpdate.prepData(objList, caseObj.Id, System.now(), st.BLN_GUID__c);
        } catch (Exception e){
            errors = 'ERROR';
        }
        system.assertEquals(caseObj.Priority, System.label.BLN_Critical, 'Priority Should be same');
    }
    
    @isTest
    public static void unitTest1(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        caseObj.BLN_SubType__c = 'Warranty';
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        BLN_TestDataFactory.createWorkType('Warranty Replacement & Recalibration', 4 , true ,  true);
        BLN_TestDataFactory.createWorkType('Warranty Replacement', 3 , true ,  true);
        BLN_TestDataFactory.createWorkType('Recalibration', 5 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours oneHour = new OperatingHours();
        oneHour.Name = label.BLN_30MinutesSlot;
        oneHour.TimeZone = UserInfo.getTimeZone().toString();
        insert oneHour;
        
        // Timezone tz = Timezone.getTimeZone(oneHour.TimeZone);
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        BLN_TestDataFactory.createTimeSlot(System.label.BLN_OneHourSlot, operatingHours.Id, true);
        
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_IsBranch__c = true;
        st.BLN_SplitReplaceAndRecalibration__c = false;
        st.BLN_Type__c = System.label.BLN_Mobile;
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.street = '';
        st.city = 'Bedford';
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
        
        //BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
        system.assertEquals(st.BLN_Type__c, System.label.BLN_Mobile, 'Type Should be same');
    }

    @isTest
    public static void unitTest2(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        caseObj.BLN_SubType__c = 'Warranty';
        //caseObj.BLN_BufferDays__c = 0;
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
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        BLN_TestDataFactory.createWorkType('Warranty Replacement & Recalibration', 4 , true ,  true);
        BLN_TestDataFactory.createWorkType('Warranty Replacement', 3 , true ,  true);
        BLN_TestDataFactory.createWorkType('Recalibration', 5 , true ,  true);
        BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        BLN_TestDataFactory.createWorkType('Assist', 5 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = System.label.BLN_Mobile;
        st.street = '';
        st.city = 'Bedford';
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
        //BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
        system.assertEquals(st.BLN_Type__c, System.label.BLN_Mobile, 'Type Should be same');
    }
    
    @isTest
    public static void unitTest3(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        caseObj.BLN_SubType__c = 'Warranty';
        //caseObj.BLN_BufferDays__c = 1;

        INSERT caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = false;
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        BLN_TestDataFactory.createWorkType('Warranty Replacement & Recalibration', 4 , true ,  true);
        BLN_TestDataFactory.createWorkType('Warranty Replacement', 3 , true ,  true);
        BLN_TestDataFactory.createWorkType('Recalibration', 5 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = System.label.BLN_Branch;
        st.BLN_SplitReplaceAndRecalibration__c = true;
        st.street = '';
        st.city = 'Bedford';
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
        
        //BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
        system.assertEquals(st.BLN_Type__c, System.label.BLN_Branch, 'Type Should be same');
    }
    
    @isTest
    public static void unitTest4(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '14';
        //prod.BLN_ProductCategory__c = 'Side Glass';
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        WorkType wrRepairWT = BLN_TestDataFactory.createWorkType('Repair', 3 , true ,  true);
        BLN_TestDataFactory.createWorkType('Replacement', 3 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_SplitReplaceAndRecalibration__c = false;
        st.street = '';
        st.city = 'Bedford';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        st.OperatingHoursId = operatingHours.Id;
        st.BLN_Type__c = System.Label.BLN_Mobile;
        insert st;
        Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format(System.label.BLN_EEEEText);
        TimeSlot timeSlot = BLN_TestDataFactory.createTimeSlotsFullDayProfile(false);
        timeSlot.DayOfWeek = dayOfWeek;
        timeSlot.OperatingHoursId = operatingHours.Id;
        INSERT timeSlot;
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(accountObj, contractObj, caseObj);
        orderObj.Pricebook2Id = pricebookId;
        orderObj.BLN_ServiceTerritory__c = st.Id;
        orderObj.BLN_IsDropOff__c = true;
        INSERT orderObj;
        
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Quantity = 5;
        INSERT orderItem;
        
        String appointmentId = BLN_TestDataFactory.createServiceAppointment('Repair', true);
        ServiceAppointment sA = [select id, ServiceTerritoryId, BLN_WorkOrderNumber__c from ServiceAppointment where id = :appointmentId];
        sA.ServiceTerritoryId = st.Id;
        update sA;
        
        Datetime now = Datetime.now();
        ServiceAppointment sApp =new ServiceAppointment();
        sApp.ParentRecordId = accountObj.id;
        sApp.status= 'open';
        sApp.EarliestStartTime = now;
        sApp.DueDate = now.addminutes(30);
        sApp.worktypeid = wrRepairWT.id;
        sApp.ServiceTerritoryId = st.Id;
        insert sApp;
        
        FSL__Time_Dependency__c timeDependency = new FSL__Time_Dependency__c();
        timeDependency.FSL__Dependency__c = System.label.BLN_Dependency;
        timeDependency.FSL__Same_Resource__c = true;
        timeDependency.FSL__Service_Appointment_1__c = sA.id;
        timeDependency.FSL__Service_Appointment_2__c = sApp.id;
        timeDependency.FSL__Root_Service_Appointment__c = sApp.id;
        INSERT timeDependency;
        
		Workorder wO = [Select id, BLN_Order__c from Workorder where id = :sA.BLN_WorkOrderNumber__c];
        wO.BLN_Order__c = orderObj.Id;
        update wO;
        
        // BLN_AppointmentCreateUpdate.getMobileSlots(appointmentId);
        
        DateTime startTime = Datetime.newInstance(System.Today(), Time.newInstance(9,0,0,0));
        DateTime endTime = Datetime.newInstance(System.Today(), Time.newInstance(10,0,0,0));
        FSL.TimeInterval timeIntervalObj = new FSL.TimeInterval(startTime, endTime);
        FSL.AppointmentBookingSlot slot = new FSL.AppointmentBookingSlot();
        slot.Grade = 85.1851851851851851851851851851852;
        slot.Interval = timeIntervalObj;
        
        FSL.AppointmentBookingSlot slot1 = new FSL.AppointmentBookingSlot();
        slot1.Grade = 86.1851851851851851851851851851852;
        slot1.Interval = timeIntervalObj;
        BLN_AppointmentSlots.appointmentBookingSlots = new List<FSL.AppointmentBookingSlot>();
        BLN_AppointmentSlots.appointmentBookingSlots.add(slot);
        BLN_AppointmentSlots.appointmentBookingSlots.add(slot1);

        Test.startTest();
            BLN_AppointmentCreateUpdate.updateAppointment(appointmentId, System.today().addDays(1), true);
            BLN_AppointmentCreateUpdate.getBranchSlots(appointmentId);
            BLN_AppointmentCreateUpdate.getMobileSlots(appointmentId);
        Test.stopTest();
        orderObj.BLN_IsDropOff__c = false;
        UPDATE orderObj;
        BLN_AppointmentCreateUpdate.updateAppointment(appointmentId, System.today().addDays(1), false);
        BLN_AppointmentCreateUpdate.getBranchSlots(appointmentId);
        BLN_AppointmentCreateUpdate.deleteAppointment(appointmentId);
        system.assertEquals(st.BLN_IsBranch__c, true, 'IsBranch Should be true');
    }
    
    public class Interval{
        DateTime start = System.now();
        DateTime finish = System.now().addMinutes(360);
    }
    
    @isTest
    public static void unitTest5(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        accountObj.PersonMobilePhone = '';
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        caseObj.Priority = System.label.BLN_Critical;
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ProductCategory__c = 'Windscreen';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        BLN_TestDataFactory.createWorkType('Replacement & Recalibration', 4 , true ,  true);
        BLN_TestDataFactory.createWorkType('Warranty Replacement', 3 , true ,  true);
        BLN_TestDataFactory.createWorkType('Recalibration', 5 , true ,  true);
        BLN_TestDataFactory.createWorkType('Replacement', 3 , true ,  true);
        BLN_TestDataFactory.createWorkType('Assist', 3 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = System.label.BLN_Branch;
        st.BLN_SplitReplaceAndRecalibration__c = false;
        st.street = '';
        st.city = 'Bedford';
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
        
        /*BLN_AppointmentDataCreationService.TimeSlotWrapper wrapper = new BLN_AppointmentDataCreationService.TimeSlotWrapper();
        wrapper = BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
        String appointmentId = wrapper.appointmentId;
        BLN_AppointmentCreateUpdate.updateAppointment(appointmentId, System.today(), true);
        BLN_AppointmentCreateUpdate.getslots(appointmentId);
        Test.startTest();
       		BLN_AppointmentCreateUpdate.getBranchSlots(appointmentId);
        Test.stopTest();
        system.assertEquals(st.BLN_Type__c, System.label.BLN_Branch, 'Type Should be same');*/
    }
    
    @istest
    public static void unittest7(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        Id pricebookId = Test.getStandardPricebookId();
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_SplitReplaceAndRecalibration__c = false;
        st.OperatingHoursId= operatingHours.id;
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
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ProductCategory__c = 'Windscreen';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        INSERT prod;
        
        WorkType replacementWT = BLN_TestDataFactory.createWorkType('Replacement', 4 , true ,  true);
        
        //ServiceAppointment sARecord = BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
        Datetime now = Datetime.now();
        ServiceAppointment sApp =new ServiceAppointment();
        sApp.ParentRecordId = accountObj.id;
        sApp.ArrivalWindowStartTime = now;
        sApp.status= 'open';
        sApp.EarliestStartTime = now;
        sApp.DueDate = now.addminutes(30);
        sApp.worktypeid = replacementWT.id;
        sApp.ServiceTerritoryId = st.Id;
        insert sApp;
        
        // Boolean isDependencyCreated=true;
        // String orderid= orderobj.id;
        // String opname=operatingHours.name;
        BLN_AppointmentCreateUpdate.getBranchSlots(sApp.Id);
        system.assertEquals(prod.BLN_ADASRecalibrationNeeded__c, true, 'ADAS Should be same');
    }
    
    @istest
    public static void unittest8(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_SplitReplaceAndRecalibration__c = false;
        st.OperatingHoursId= operatingHours.id;
        insert st;
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(accountObj, contractObj, caseObj);
        orderObj.Pricebook2Id = pricebookId;
        orderObj.BLN_ServiceTerritory__c = st.Id;
        INSERT orderObj;
        
        WorkType stockWT = BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = stockWT.Id;
        workOrders.ServiceTerritoryId = st.id;
        insert workOrders;
        
        //BLN_AppointmentCreateUpdate.generateWoLi(workOrders, orderObj.id, stockWT);
        system.assertEquals(st.BLN_SplitReplaceAndRecalibration__c, false, 'Split Should be same');
    }
    
    @istest
    public static void unittest9(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_ProductCategory__c = 'Test';
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_MdMId__c = '245321';
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        BLN_TestDataFactory.createWorkType('Replacement & Recalibration', 4 , true ,  true);
        // WorkType stockWT = BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        BLN_TestDataFactory.createWorkType(System.label.BLN_SideRearReplacementWT, 5 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = 'Branch';
        st.BLN_SplitReplaceAndRecalibration__c = true;
        st.street = '';
        st.city = 'Bedford';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        st.BLN_ExcludedProductCategory__c = 'Test;11;%Tes;%est%';
        st.BLN_ExcludedProduct__c = 'Trim;demo;%Tr;%demo%';
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
        BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
        List<Object> objList = new List<Object>();
        Map<String, Object> obj = new Map<String, Object>{
            'productCode' => prod.BLN_MdMId__c,
            'quantity' => 5
        };
        objList.add(obj);
        BLN_AppointmentCreateUpdate.prepData(objList, caseObj.Id, System.now(), st.BLN_GUID__c);
        system.assertEquals(st.BLN_Type__c, System.label.BLN_Branch, 'Type Should be same');
    }
    
    @isTest
    public static void unitTest10(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.Name = 'Test';
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_MDMID__c = '342354345';
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        BLN_TestDataFactory.createWorkType('Replacement & Recalibration', 4 , true ,  true);
        // WorkType stockWT = BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        BLN_TestDataFactory.createWorkType(System.label.BLN_SideRearReplacementWT, 5 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = 'Branch';
        st.BLN_SplitReplaceAndRecalibration__c = false;
        st.street = '';
        st.city = 'Bedford';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        st.BLN_ExcludedWorkType__c = 'Replacement & Recalibration;%Recalibration%;%Replacement';
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
        BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
        List<Object> objList = new List<Object>();
        Map<String, Object> obj = new Map<String, Object>{
            'productCode' => prod.BLN_MDMId__c,
            'quantity' => 5
        };
        objList.add(obj);
        BLN_AppointmentCreateUpdate.prepData(objList, caseObj.Id, System.now(), st.BLN_GUID__c);
        system.assertEquals(st.BLN_Type__c, System.label.BLN_Branch, 'Type Should be same');
    }
    
    @isTest
    public static void unitTest11(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.Name = 'Test';
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_BusinessUnitSpecificBranchOnly__c = True;
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        BLN_TestDataFactory.createWorkType('Replacement & Recalibration', 4 , true ,  true);
        // WorkType stockWT = BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        BLN_TestDataFactory.createWorkType(System.label.BLN_SideRearReplacementWT, 5 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = 'Mobile';
        st.BLN_SplitReplaceAndRecalibration__c = false;
        st.street = '';
        st.city = 'Bedford';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        st.BLN_ExcludedWorkType__c = 'Replacement & Recalibration;%Recalibration%;%Replacement';
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
        BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
        List<Object> objList = new List<Object>();
        Map<String, Object> obj = new Map<String, Object>{
            'productCode' => prod.BLN_MdMId__c,
            'quantity' => 5
        };
        objList.add(obj);
        BLN_AppointmentCreateUpdate.prepData(objList, caseObj.Id, System.now(), st.BLN_GUID__c);
        system.assertEquals(st.BLN_Type__c, System.label.BLN_Mobile, 'Type Should be same');
        BLN_AppointmentCreateUpdate.createAppointmentData('', json);
    }
    
    @isTest
    public static void unitTest12(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        caseObj.Priority = 'Critical';
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.Name = 'Test';
        prod.ProductCode = 'Test1234';
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '14';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_ProductStockable__c = true;
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        prod.BLN_MDMID__c = '4353421';
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        Product2 prod1 = BLN_TestDataFactory.createTestProduct();
        prod1.Name = 'Testing';
        prod1.ProductCode = 'Test123';
        prod1.BLN_BelronFittingTime__c = 10;
        prod1.BLN_ProductCategory__c = '29';
        prod1.BLN_ADASRecalibrationNeeded__c = false;
        prod1.BLN_ProductStockable__c = true;
        prod1.BLN_NumberofTechnicianNeeded__c = 0;
        prod1.BLN_MDMID__c = '435421';
        INSERT prod1;
               
        //PricebookEntry pbe1 = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod1.ID, isActive=true, UnitPrice=0);
        //INSERT pbe1;
        
        WorkType replacementWT = BLN_TestDataFactory.createWorkType('Replacement & Recalibration', 4 , true ,  true);
        WorkType repairWT = BLN_TestDataFactory.createWorkType('Repair', 4 , true ,  true);
        WorkType warentyReplacementWT = BLN_TestDataFactory.createWorkType(System.label.BLN_WarrantyReplacementRecalibration, 4 , true ,  true);
        WorkType stockWT = BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        BLN_TestDataFactory.createWorkType(System.label.BLN_SideRearReplacementWT, 5 , true ,  true); 
        BLN_TestDataFactory.createWorkType(System.label.BLN_Recalibration, 5 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_GUID__c = '9y8avfh9';
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = 'Mobile';
        st.BLN_SplitReplaceAndRecalibration__c = false;
        st.street = '';
        st.city = 'Bedford';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        st.BLN_ExcludedWorkType__c = 'Replacement & Recalibration;%Recalibration%;%Replacement';
        st.BLN_SplitReplaceAndRecalibration__c = false;
        st.BLN_ExcludedProductCategory__c = 'Test;11;%Tes;%est%';
        st.BLN_ExcludedProduct__c = 'Trim;demo;%Tr;%demo%;%Test1%';
        st.BLN_IsPrioritized__c = true;
        insert st;
        
        Schema.Location loc = new Schema.Location();
        loc.BLN_GUID__c = st.BLN_GUID__c;
        loc.Name = 'Test';
        loc.LocationType = 'OFFICE';
        INSERT loc;
        
        Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format('EEEE');
        TimeSlot timeSlot = BLN_TestDataFactory.createTimeSlotsFullDayProfile(false);
        timeSlot.DayOfWeek = dayOfWeek;
        timeSlot.OperatingHoursId = operatingHours.Id;
        INSERT timeSlot;
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(accountObj, contractObj, caseObj);
        orderObj.Pricebook2Id = pricebookId;
        orderObj.BLN_ServiceTerritory__c = st.Id;
        orderObj.BLN_Case__c = caseObj.id; 
        INSERT orderObj;
        
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Quantity = 5;
        orderItem.BLN_IsProductSelected__c = true;
        INSERT orderItem;
        
        BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
        
        List<Object> objList = new List<Object>();
        Map<String, Object> obj = new Map<String, Object>{
            'productCode' => prod.BLN_MDMID__c,
            'quantity' => 5,
            'productOLIKey' => 'test'   
        };
        objList.add(obj);
        BLN_AppointmentCreateUpdate.prepData(objList, caseObj.Id, System.now(), st.BLN_GUID__c);
        Test.startTest();
        	WorkOrder wO = BLN_TestDataFactory.createWorkOrder2(stockWT.Id , st.Id , true);
            wo.CaseId = caseObj.id; 
            update wo;
            WorkOrderLineItem woLi = BLN_AppointmentDataCreationService.generateWoLi(wO, stockWT);
            woLi.workTypeId = stockWT.Id;
            insert woLi;
            WorkOrderLineItem woLi2 = BLN_AppointmentDataCreationService.generateWoLi(wO, warentyReplacementWT);
            woLi2.workTypeId = warentyReplacementWT.Id;
            insert woLi2;
            WorkOrderLineItem woLi3 = BLN_AppointmentDataCreationService.generateWoLi(wO, replacementWT);
            woLi3.workTypeId = replacementWT.Id;
            insert woLi3;
        	WorkOrderLineItem woLi4 = BLN_AppointmentDataCreationService.generateWoLi(wO, repairWT);
            woLi4.workTypeId = repairWT.Id;
            insert woLi4;
		Test.stopTest();
        String errors;
        BLN_AppointmentDataCreationService.workTypeMap.put((String)stockWT.Id,stockWT);
        BLN_AppointmentDataCreationService.workTypeMap.put((String)replacementWT.Id,replacementWT);
        BLN_AppointmentDataCreationService.workTypeMap.put((String)warentyReplacementWT.Id,warentyReplacementWT);
        BLN_AppointmentDataCreationService.workTypeMap.put((String)repairWT.Id,repairWT);
        try{
            ServiceAppointment sA = BLN_AppointmentDataCreationService.generateSA(woLi, 5.5, 'Stock Collect', true);
            BLN_AppointmentDataCreationService.mainAndStockOrAssistSADependency(sA.Id, sA.Id, true, 'Start After Finish And Same Day');
        } catch(Exception e){
            errors = 'ERROR';
        }
        
        Map<String, Decimal> productMap = new Map<String, Decimal>();
        Map<String, String> productOLIKeyMap = new Map<String, String>();
        productMap.put(prod.BLN_MDMID__c, 5);
        productOLIKeyMap.put(prod.BLN_MDMID__c, 'test');
        Map<String, Decimal> productMap1 = new Map<String, Decimal>();
        Map<String, String> productOLIKeyMap1 = new Map<String, String>();
        productMap1.put(prod1.BLN_MDMID__c, 5);
        productOLIKeyMap1.put(prod1.BLN_MDMID__c, 'test');

        BLN_AppointmentDataCreationService.generateProductRequired(woLi2,warentyReplacementWT, prod, warentyReplacementWT, st, productMap, productOLIKeyMap, 0);
        BLN_AppointmentDataCreationService.generateProductRequired(woLi4,repairWT, prod1, repairWT, st, productMap1, productOLIKeyMap1, 0);
        //BLN_AppointmentDataCreationService.generateProductRequired(woLi4, prod, warentyReplacementWT, st);
        st.BLN_SplitReplaceAndRecalibration__c = false;
        update st;
        BLN_AppointmentDataCreationService.generateProductRequired(woLi3,replacementWT, prod, replacementWT, st, productMap, productOLIKeyMap, 0);
        BLN_AppointmentDataCreationService.updateWOwithOrder(orderObj.Id);
        system.assertEquals(st.BLN_Type__c, System.label.BLN_Mobile, 'Type Should be same');
    }

    @isTest
    public static void unitTest122(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        caseObj.Priority = 'Critical';
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.Name = 'Test';
        prod.ProductCode = 'Test1234';
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '12';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_ProductStockable__c = true;
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        prod.BLN_MDMID__c = '4353421';
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        Product2 prod1 = BLN_TestDataFactory.createTestProduct();
        prod1.Name = 'Testing';
        prod1.ProductCode = 'Test123';
        prod1.BLN_BelronFittingTime__c = 10;
        prod1.BLN_ProductCategory__c = '29';
        prod1.BLN_ADASRecalibrationNeeded__c = false;
        prod1.BLN_ProductStockable__c = true;
        prod1.BLN_NumberofTechnicianNeeded__c = 0;
        prod1.BLN_MDMID__c = '435421';
        INSERT prod1;
               
        //PricebookEntry pbe1 = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod1.ID, isActive=true, UnitPrice=0);
        //INSERT pbe1;
        
        WorkType replacementWT = BLN_TestDataFactory.createWorkType('Replacement & Recalibration', 4 , true ,  true);
        WorkType repairWT = BLN_TestDataFactory.createWorkType('Repair', 4 , true ,  true);
        WorkType warentyReplacementWT = BLN_TestDataFactory.createWorkType(System.label.BLN_WarrantyReplacementRecalibration, 4 , true ,  true);
        WorkType stockWT = BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        BLN_TestDataFactory.createWorkType(System.label.BLN_SideRearReplacementWT, 5 , true ,  true); 
        BLN_TestDataFactory.createWorkType(System.label.BLN_Recalibration, 5 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_GUID__c = '9y8avfh9';
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = 'Mobile';
        st.BLN_SplitReplaceAndRecalibration__c = false;
        st.street = '';
        st.city = 'Bedford';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        st.BLN_ExcludedWorkType__c = 'Replacement & Recalibration;%Recalibration%;%Replacement';
        st.BLN_SplitReplaceAndRecalibration__c = false;
        st.BLN_ExcludedProductCategory__c = 'Test;11;%Tes;%est%';
        st.BLN_ExcludedProduct__c = 'Trim;demo;%Tr;%demo%;%Test1%';
        st.BLN_IsPrioritized__c = true;
        insert st;
        
        Schema.Location loc = new Schema.Location();
        loc.BLN_GUID__c = st.BLN_GUID__c;
        loc.Name = 'Test';
        loc.LocationType = 'OFFICE';
        loc.BLN_PrimarySourceCollectId__c = '88';
        loc.BLN_OrgCodeLocation__c = '88';
        INSERT loc;
        
        Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format('EEEE');
        TimeSlot timeSlot = BLN_TestDataFactory.createTimeSlotsFullDayProfile(false);
        timeSlot.DayOfWeek = dayOfWeek;
        timeSlot.OperatingHoursId = operatingHours.Id;
        INSERT timeSlot;
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(accountObj, contractObj, caseObj);
        orderObj.Pricebook2Id = pricebookId;
        orderObj.BLN_ServiceTerritory__c = st.Id;
        orderObj.BLN_Case__c = caseObj.id; 
        INSERT orderObj;
        
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Quantity = 5;
        orderItem.BLN_IsProductSelected__c = true;
        INSERT orderItem;
        
        BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
        
        List<Object> objList = new List<Object>();
        Map<String, Object> obj = new Map<String, Object>{
            'productCode' => prod.BLN_MDMID__c,
            'quantity' => 5,
            'productOLIKey' => 'test'   
        };
        objList.add(obj);
        BLN_AppointmentCreateUpdate.prepData(objList, caseObj.Id, System.now(), st.BLN_GUID__c);
        Test.startTest();
        	WorkOrder wO = BLN_TestDataFactory.createWorkOrder2(stockWT.Id , st.Id , true);
            wO.CaseId = caseObj.id; 
            update wO;
            WorkOrderLineItem woLi = BLN_AppointmentDataCreationService.generateWoLi(wO, stockWT);
            woLi.workTypeId = stockWT.Id;
            insert woLi;
            WorkOrderLineItem woLi2 = BLN_AppointmentDataCreationService.generateWoLi(wO, warentyReplacementWT);
            woLi2.workTypeId = warentyReplacementWT.Id;
            insert woLi2;
            WorkOrderLineItem woLi3 = BLN_AppointmentDataCreationService.generateWoLi(wO, replacementWT);
            woLi3.workTypeId = replacementWT.Id;
            insert woLi3;
        	WorkOrderLineItem woLi4 = BLN_AppointmentDataCreationService.generateWoLi(wO, repairWT);
            woLi4.workTypeId = repairWT.Id;
            insert woLi4;
		Test.stopTest();
        String errors;
        BLN_AppointmentDataCreationService.workTypeMap.put((String)stockWT.Id,stockWT);
        BLN_AppointmentDataCreationService.workTypeMap.put((String)replacementWT.Id,replacementWT);
        BLN_AppointmentDataCreationService.workTypeMap.put((String)warentyReplacementWT.Id,warentyReplacementWT);
        BLN_AppointmentDataCreationService.workTypeMap.put((String)repairWT.Id,repairWT);
        try{
            ServiceAppointment sA = BLN_AppointmentDataCreationService.generateSA(woLi, 5.5, 'Stock Collect', true);
            BLN_AppointmentDataCreationService.mainAndStockOrAssistSADependency(sA.Id, sA.Id, true, 'Start After Finish And Same Day');
        } catch(Exception e){
            errors = 'ERROR';
        }
        
        Map<String, Decimal> productMap = new Map<String, Decimal>();
        Map<String, String> productOLIKeyMap = new Map<String, String>();
        productMap.put(prod.BLN_MDMID__c, 5);
        productOLIKeyMap.put(prod.BLN_MDMID__c, 'test');
        Map<String, Decimal> productMap1 = new Map<String, Decimal>();
        Map<String, String> productOLIKeyMap1 = new Map<String, String>();
        productMap1.put(prod1.BLN_MDMID__c, 5);
        productOLIKeyMap1.put(prod1.BLN_MDMID__c, 'test');

        BLN_AppointmentDataCreationService.generateProductRequired(woLi2,warentyReplacementWT, prod, warentyReplacementWT, st, productMap, productOLIKeyMap, 0);
        BLN_AppointmentDataCreationService.generateProductRequired(woLi4,repairWT, prod1, repairWT, st, productMap1, productOLIKeyMap1, 0);
        //BLN_AppointmentDataCreationService.generateProductRequired(woLi4, prod, warentyReplacementWT, st);
        st.BLN_SplitReplaceAndRecalibration__c = false;
        update st;
        BLN_AppointmentDataCreationService.generateProductRequired(woLi3,replacementWT, prod, replacementWT, st, productMap, productOLIKeyMap, 0);
        BLN_AppointmentDataCreationService.updateWOwithOrder(orderObj.Id);
        system.assertEquals(st.BLN_Type__c, System.label.BLN_Mobile, 'Type Should be same');
    }

    @isTest
    public static void unitTest13(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        caseObj.Priority = 'Critical';
        caseObj.BLN_SubType__c = System.label.BLN_Warranty;
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.Name = 'Test';
        prod.ProductCode = 'Test1234';
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '14';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_ProductStockable__c = true;
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        prod.BLN_MDMID__c = '4353421';
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        Product2 prod1 = BLN_TestDataFactory.createTestProduct();
        prod1.Name = 'Testing';
        prod1.ProductCode = 'Test123';
        prod1.BLN_BelronFittingTime__c = 10;
        prod1.BLN_ProductCategory__c = '29';
        prod1.BLN_ADASRecalibrationNeeded__c = false;
        prod1.BLN_ProductStockable__c = true;
        prod1.BLN_NumberofTechnicianNeeded__c = 0;
        prod1.BLN_MDMID__c = '435421';
        INSERT prod1;
               
        //PricebookEntry pbe1 = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod1.ID, isActive=true, UnitPrice=0);
        //INSERT pbe1;
        
        WorkType replacementWT = BLN_TestDataFactory.createWorkType('Replacement & Recalibration', 4 , true ,  true);
        WorkType repairWT = BLN_TestDataFactory.createWorkType('Repair', 4 , true ,  true);
        WorkType warentyReplacementWT = BLN_TestDataFactory.createWorkType(System.label.BLN_WarrantyReplacementRecalibration, 4 , true ,  true);
        WorkType stockWT = BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        BLN_TestDataFactory.createWorkType(System.label.BLN_SideRearReplacementWT, 5 , true ,  true); 
        BLN_TestDataFactory.createWorkType(System.label.BLN_Recalibration, 5 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_GUID__c = '9y8avfh9';
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = 'Branch';
        st.BLN_SplitReplaceAndRecalibration__c = true;
        st.street = '';
        st.city = 'Bedford';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        st.BLN_ExcludedWorkType__c = 'Replacement & Recalibration;%Recalibration%;%Replacement';
        st.BLN_SplitReplaceAndRecalibration__c = true;
        st.BLN_ExcludedProductCategory__c = 'Trim;demo;%Tr;%demo%';
        st.BLN_ExcludedProduct__c = 'Test;11;%Tes;%est%;%Test1%';
        st.BLN_IsPrioritized__c = true;
        insert st;
        
        Schema.Location loc = new Schema.Location();
        loc.BLN_GUID__c = st.BLN_GUID__c;
        loc.Name = 'Test';
        loc.LocationType = 'OFFICE';
        INSERT loc;
        
        Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format('EEEE');
        TimeSlot timeSlot = BLN_TestDataFactory.createTimeSlotsFullDayProfile(false);
        timeSlot.DayOfWeek = dayOfWeek;
        timeSlot.OperatingHoursId = operatingHours.Id;
        INSERT timeSlot;
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(accountObj, contractObj, caseObj);
        orderObj.Pricebook2Id = pricebookId;
        orderObj.BLN_ServiceTerritory__c = st.Id;
        orderObj.BLN_Case__c = caseObj.id; 
        INSERT orderObj;
        
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Quantity = 5;
        orderItem.BLN_IsProductSelected__c = true;
        INSERT orderItem;
        
        BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
        
        List<Object> objList = new List<Object>();
        Map<String, Object> obj = new Map<String, Object>{
            'productCode' => prod.BLN_MDMID__c,
            'quantity' => 5,
            'productOLIKey' => 'test'   
        };
        objList.add(obj);
        BLN_AppointmentCreateUpdate.prepData(objList, caseObj.Id, System.now(), st.BLN_GUID__c);
        Test.startTest();
        	WorkOrder wO = BLN_TestDataFactory.createWorkOrder2(stockWT.Id , st.Id , true);
            wo.CaseId = caseObj.id; 
            update wo;
            WorkOrderLineItem woLi = BLN_AppointmentDataCreationService.generateWoLi(wO, stockWT);
            woLi.workTypeId = stockWT.Id;
            insert woLi;
            WorkOrderLineItem woLi2 = BLN_AppointmentDataCreationService.generateWoLi(wO, warentyReplacementWT);
            woLi2.workTypeId = warentyReplacementWT.Id;
            insert woLi2;
            WorkOrderLineItem woLi3 = BLN_AppointmentDataCreationService.generateWoLi(wO, replacementWT);
            woLi3.workTypeId = replacementWT.Id;
            insert woLi3;
        	WorkOrderLineItem woLi4 = BLN_AppointmentDataCreationService.generateWoLi(wO, repairWT);
            woLi4.workTypeId = repairWT.Id;
            insert woLi4;
		Test.stopTest();
        String errors;
        BLN_AppointmentDataCreationService.workTypeMap.put((String)stockWT.Id,stockWT);
        BLN_AppointmentDataCreationService.workTypeMap.put((String)replacementWT.Id,replacementWT);
        BLN_AppointmentDataCreationService.workTypeMap.put((String)warentyReplacementWT.Id,warentyReplacementWT);
        BLN_AppointmentDataCreationService.workTypeMap.put((String)repairWT.Id,repairWT);
        try{
            ServiceAppointment sA = BLN_AppointmentDataCreationService.generateSA(woLi, 5.5, 'Stock Collect', true);
            BLN_AppointmentDataCreationService.mainAndStockOrAssistSADependency(sA.Id, sA.Id, true, 'Start After Finish And Same Day');
        } catch(Exception e){
            errors = 'ERROR';
        }
        
        Map<String, Decimal> productMap = new Map<String, Decimal>();
        Map<String, String> productOLIKeyMap = new Map<String, String>();
        productMap.put(prod.BLN_MDMID__c, 5);
        productOLIKeyMap.put(prod.BLN_MDMID__c, 'test');
        Map<String, Decimal> productMap1 = new Map<String, Decimal>();
        Map<String, String> productOLIKeyMap1 = new Map<String, String>();
        productMap1.put(prod1.BLN_MDMID__c, 5);
        productOLIKeyMap1.put(prod1.BLN_MDMID__c, 'test');

        BLN_AppointmentDataCreationService.generateProductRequired(woLi2,warentyReplacementWT, prod, warentyReplacementWT, st, productMap, productOLIKeyMap, 0);
        BLN_AppointmentDataCreationService.generateProductRequired(woLi4,repairWT, prod1, repairWT, st, productMap1, productOLIKeyMap1, 0);
        //BLN_AppointmentDataCreationService.generateProductRequired(woLi4, prod, warentyReplacementWT, st);
        st.BLN_SplitReplaceAndRecalibration__c = false;
        update st;
        BLN_AppointmentDataCreationService.generateProductRequired(woLi3,replacementWT, prod, replacementWT, st, productMap, productOLIKeyMap, 0);
        BLN_AppointmentDataCreationService.updateWOwithOrder(orderObj.Id);
        system.assertEquals(st.BLN_Type__c, System.label.BLN_Branch, 'Type Should be same');
    }
    @isTest
    public static void unitTest14(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        caseObj.Priority = 'Critical';
        caseObj.BLN_SubType__c = System.label.BLN_Warranty;
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.Name = 'Test';
        prod.ProductCode = 'Test1234';
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '14';
        prod.BLN_ADASRecalibrationNeeded__c = false;
        prod.BLN_ProductStockable__c = true;
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        prod.BLN_MDMID__c = '4353421';
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        INSERT pbe;
        
        Product2 prod1 = BLN_TestDataFactory.createTestProduct();
        prod1.Name = 'Testing';
        prod1.ProductCode = 'Test123';
        prod1.BLN_BelronFittingTime__c = 10;
        prod1.BLN_ProductCategory__c = '29';
        prod1.BLN_ADASRecalibrationNeeded__c = false;
        prod1.BLN_ProductStockable__c = true;
        prod1.BLN_NumberofTechnicianNeeded__c = 0;
        prod1.BLN_MDMID__c = '435421';
        INSERT prod1;
               
        //PricebookEntry pbe1 = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod1.ID, isActive=true, UnitPrice=0);
        //INSERT pbe1;
        
        WorkType replacementWT = BLN_TestDataFactory.createWorkType('Replacement & Recalibration', 4 , true ,  true);
        WorkType repairWT = BLN_TestDataFactory.createWorkType('Repair', 4 , true ,  true);
        WorkType warentyReplacementWT = BLN_TestDataFactory.createWorkType(System.label.BLN_WarrantyReplacementRecalibration, 4 , true ,  true);
        WorkType stockWT = BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        BLN_TestDataFactory.createWorkType(System.label.BLN_SideRearReplacementWT, 5 , true ,  true); 
        BLN_TestDataFactory.createWorkType(System.label.BLN_Recalibration, 5 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_GUID__c = '9y8avfh9';
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = 'Branch';
        st.BLN_SplitReplaceAndRecalibration__c = true;
        st.street = '';
        st.city = 'Bedford';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        st.BLN_ExcludedWorkType__c = 'Replacement & Recalibration;%Recalibration%;%Replacement';
        st.BLN_SplitReplaceAndRecalibration__c = true;
        st.BLN_ExcludedProductCategory__c = 'Trim;demo;%Tr;%demo%';
        st.BLN_ExcludedProduct__c = 'Test;11;%Tes;%est%;%Test1%';
        st.BLN_IsPrioritized__c = true;
        insert st;
        
        Schema.Location loc = new Schema.Location();
        loc.BLN_GUID__c = st.BLN_GUID__c;
        loc.Name = 'Test';
        loc.LocationType = 'OFFICE';
        INSERT loc;
        
        Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format('EEEE');
        TimeSlot timeSlot = BLN_TestDataFactory.createTimeSlotsFullDayProfile(false);
        timeSlot.DayOfWeek = dayOfWeek;
        timeSlot.OperatingHoursId = operatingHours.Id;
        INSERT timeSlot;
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(accountObj, contractObj, caseObj);
        orderObj.Pricebook2Id = pricebookId;
        orderObj.BLN_ServiceTerritory__c = st.Id;
        orderObj.BLN_Case__c = caseObj.id; 
        INSERT orderObj;
        
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Quantity = 5;
        orderItem.BLN_IsProductSelected__c = true;
        INSERT orderItem;
        
        BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
        
        List<Object> objList = new List<Object>();
        Map<String, Object> obj = new Map<String, Object>{
            'productCode' => prod.BLN_MDMID__c,
            'quantity' => 5,
            'productOLIKey' => 'test'   
        };
        objList.add(obj);
        BLN_AppointmentCreateUpdate.prepData(objList, caseObj.Id, System.now(), st.BLN_GUID__c);
        Test.startTest();
        	WorkOrder wO = BLN_TestDataFactory.createWorkOrder2(stockWT.Id , st.Id , true);
            wo.CaseId = caseObj.id; 
            update wo;
            WorkOrderLineItem woLi = BLN_AppointmentDataCreationService.generateWoLi(wO, stockWT);
            woLi.workTypeId = stockWT.Id;
            insert woLi;
            WorkOrderLineItem woLi2 = BLN_AppointmentDataCreationService.generateWoLi(wO, warentyReplacementWT);
            woLi2.workTypeId = warentyReplacementWT.Id;
            insert woLi2;
            WorkOrderLineItem woLi3 = BLN_AppointmentDataCreationService.generateWoLi(wO, replacementWT);
            woLi3.workTypeId = replacementWT.Id;
            insert woLi3;
        	WorkOrderLineItem woLi4 = BLN_AppointmentDataCreationService.generateWoLi(wO, repairWT);
            woLi4.workTypeId = repairWT.Id;
            insert woLi4;
		Test.stopTest();
        String errors;
        BLN_AppointmentDataCreationService.workTypeMap.put((String)stockWT.Id,stockWT);
        BLN_AppointmentDataCreationService.workTypeMap.put((String)replacementWT.Id,replacementWT);
        BLN_AppointmentDataCreationService.workTypeMap.put((String)warentyReplacementWT.Id,warentyReplacementWT);
        BLN_AppointmentDataCreationService.workTypeMap.put((String)repairWT.Id,repairWT);
        try{
            ServiceAppointment sA = BLN_AppointmentDataCreationService.generateSA(woLi, 5.5, 'Stock Collect', true);
            BLN_AppointmentDataCreationService.mainAndStockOrAssistSADependency(sA.Id, sA.Id, true, 'Start After Finish And Same Day');
        } catch(Exception e){
            errors = 'ERROR';
        }
        
        Map<String, Decimal> productMap = new Map<String, Decimal>();
        Map<String, String> productOLIKeyMap = new Map<String, String>();
        productMap.put(prod.BLN_MDMID__c, 5);
        productOLIKeyMap.put(prod.BLN_MDMID__c, 'test');
        Map<String, Decimal> productMap1 = new Map<String, Decimal>();
        Map<String, String> productOLIKeyMap1 = new Map<String, String>();
        productMap1.put(prod1.BLN_MDMID__c, 5);
        productOLIKeyMap1.put(prod1.BLN_MDMID__c, 'test');

        BLN_AppointmentDataCreationService.generateProductRequired(woLi2,warentyReplacementWT, prod, warentyReplacementWT, st, productMap, productOLIKeyMap, 0);
        BLN_AppointmentDataCreationService.generateProductRequired(woLi4,repairWT, prod1, repairWT, st, productMap1, productOLIKeyMap1, 0);
        //BLN_AppointmentDataCreationService.generateProductRequired(woLi4, prod, warentyReplacementWT, st);
        st.BLN_SplitReplaceAndRecalibration__c = false;
        update st;
        BLN_AppointmentDataCreationService.generateProductRequired(woLi3,replacementWT, prod, replacementWT, st, productMap, productOLIKeyMap, 0);
        BLN_AppointmentDataCreationService.updateWOwithOrder(orderObj.Id);
        system.assertEquals(st.BLN_Type__c, System.label.BLN_Branch, 'Type Should be same');
    }
    @isTest
    public static void unitTest15(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','86980238');
        upsert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        caseObj.Priority = System.label.BLN_Critical;
        caseObj.BLN_SubType__c = 'Warranty';
        //caseObj.BLN_BufferDays__c = 1;
        INSERT caseObj;
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.Name = 'Test';
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '15';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_ProductStockable__c = true;
        prod.BLN_MdMID__c = '43422';
        INSERT prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Name = System.label.BLN_StandardPriceBook
        );
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=standardPricebook.Id, Product2id=prod.ID, isActive=true, UnitPrice=0);
        upsert pbe;
        
        BLN_TestDataFactory.createWorkType('Replacement & Recalibration', 4 , true ,  true);
        BLN_TestDataFactory.createWorkType('Replacement', 6 , true ,  true);
        BLN_TestDataFactory.createWorkType('Recalibration', 3 , true ,  true);
        BLN_TestDataFactory.createWorkType('Repair', 7 , true ,  true);
        WorkType stockWT = BLN_TestDataFactory.createWorkType('Stock Collect', 7 , true ,  true);
        BLN_TestDataFactory.createWorkType(System.label.BLN_SideRearReplacementWT, 5 , true ,  true);
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = new ServiceTerritory();
        PermissionSetAssignment psAssignment;
        System.runAs(u) {
            PermissionSet ps = [SELECT Id 
                                FROM PermissionSet 
                                WHERE Name = 'BLN_BypassFlows'];
            psAssignment=new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
            insert psAssignment;
            st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
            st.BLN_GUID__c = '9y8avfh9';
            st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
            st.BLN_IsBranch__c = true;
            st.BLN_Type__c = System.label.BLN_Branch;
            st.BLN_SplitReplaceAndRecalibration__c = true;
            st.street = '';
            st.city = 'Bedford';
            st.State = '';
            st.postalcode = 'MK44 3US';
            st.Country = 'United Kingdom';
            st.BLN_MaxGapMin__c = 10;
            
            insert st;
        }
        
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
        
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = stockWT.Id;
        workOrders.ServiceTerritoryId = st.id;
        workOrders.CaseId = caseObj.id;
        insert workOrders;
        String errors;
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Quantity = 5;
        INSERT orderItem;
        try{
        	BLN_AppointmentCreateUpdate.createAppointmentData(orderObj.Id, json);
            List<Object> objList = new List<Object>();
            Map<String, Object> obj = new Map<String, Object>{
                'productCode' => prod.BLN_MdMId__c,
                    'quantity' => 5
                    };
                        objList.add(obj);
            BLN_AppointmentCreateUpdate.prepData(objList, caseObj.Id, System.now(), st.BLN_GUID__c);
        } catch (Exception e){
            errors = 'ERROR';
        }
        system.assertEquals(st.BLN_Type__c, System.label.BLN_Branch, 'Type Should be same');
    }
    @isTest
    public static void unitTestContainsOrBeginWith(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        Test.startTest();
        String stringItem = 'testString';
        Set<String> listToFilter = new Set<String>();
        listToFilter.add('testString');
        listToFilter.add('%test');
        listToFilter.add('%test%');
        Boolean result = BLN_AppointmentDataCreationService.containsOrBeginWith(stringItem, listToFilter);
        Test.stopTest();
        system.assertEquals(result, true, 'Type Should be same');
    }
}