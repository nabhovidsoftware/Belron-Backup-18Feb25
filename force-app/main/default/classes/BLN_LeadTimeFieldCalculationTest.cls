/** @description : BLN_LeadTimeFieldCalculationTest Class used for testing BLN_LeadTimeFieldCalculation.
*  	@author: Wasim Akram
* 	@Story: 
*	@Created Date: 11/12/2023
*/
@isTest
public class BLN_LeadTimeFieldCalculationTest {
    
    @testSetup static void setup(){
        DateTime earliestStartTime = System.Today();
        // Date interimDate = earliestStartTime.date().addDays(Integer.valueOf(System.label.BLN_7Text));
        WorkType worktype = BLN_TestDataFactory.createWorkType('Recalibration', 11.00, true, true);
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Replacement');
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Belron Standard hours',true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('CE Bedford',opertatingHr.id,'United Kingdom',false);
        serviceTerritory.BLN_DropOffWindowDuration__c = 2;
        serviceTerritory.BLN_CollectionWindowDuration__c = 5;
        serviceTerritory.BLN_SplitReplaceAndRecalibration__c = FALSE;
        insert serviceTerritory;
        Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format(System.label.BLN_EEEEText);
        
        Time starttime = Time.newInstance(8, 0, 0, 0);
        Time endTime = Time.newInstance(18, 0, 0, 0);
        TimeSlot times = new TimeSlot();
        times.OperatingHoursId = serviceTerritory.OperatingHoursId;
        times.DayOfWeek = dayOfWeek;
        times.StartTime = starttime;
        times.EndTime = endTime;
        insert times;

        ServiceAppointment servApp = BLN_TestDataFactory.createServiceAppntmnt('Replacement', TRUE);
        
        Case cases = new Case();
        cases.Type = 'Job Request';
        cases.BLN_SubType__c = 'Warranty';
        cases.Status = 'New';   
        cases.Priority = 'Medium';
        //cases.BLN_BufferDays__c = 5;
        INSERT cases;    
        
        Account account = BLN_TestDataFactory.createAccountforAPI();
        INSERT account;
        
        Order order = new Order();
        order.BLN_Case__c = cases.Id;
        order.BLN_IsDropOff__c = FALSE;
        order.Status = 'Draft';
        order.EffectiveDate = Date.Today() - 1;
        order.BLN_ServiceTerritory__c = serviceTerritory.id;
        order.AccountId = account.Id;
        order.ContractId = BLN_TestDataFactory.createTestContract(account).Id;
        INSERT order;
    }
    
    @isTest
    public static void unitTest1(){
          User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId FROM ServiceTerritory];
        Order ord = [Select Id,BLN_Case__c From Order];
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Replacement');
        
        DateTime earliestStartTime = System.Today();
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*FALSE,*/ serviceTerritory[0], workTypeset, earliestStartTime, ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    
    @isTest
    public static void unitTest2(){
         User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Stock Collect', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId FROM ServiceTerritory];
        
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Replacement');
        workTypeset.add('Stock Collect');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id, BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*FALSE,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    
    @isTest
    public static void unitTest3(){
       User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Assist', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, BLN_Type__c FROM ServiceTerritory];
        serviceTerritory[0].BLN_Type__c = 'Branch';
        serviceTerritory[0].BLN_SplitReplaceAndRecalibration__c = True;
        update serviceTerritory;
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Replacement');
        workTypeset.add('Stock Collect');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id, BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*FALSE,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    @isTest
    public static void unitTest3Assist(){
          User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Assist', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, BLN_Type__c FROM ServiceTerritory];
        serviceTerritory[0].BLN_Type__c = 'Branch';
        serviceTerritory[0].BLN_SplitReplaceAndRecalibration__c = True;
        update serviceTerritory;
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Replacement');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*FALSE,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    @isTest
    public static void unitTest3Replacement(){
         User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Replacement', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, BLN_Type__c FROM ServiceTerritory];
        serviceTerritory[0].BLN_Type__c = 'Branch';
        serviceTerritory[0].BLN_SplitReplaceAndRecalibration__c = True;
        update serviceTerritory;
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Replacement');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*FALSE,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    
    @isTest
    public static void unitTest4(){
         User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Stock Collect', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, BLN_Type__c FROM ServiceTerritory];
        serviceTerritory[0].BLN_Type__c = 'Branch';
        serviceTerritory[0].BLN_SplitReplaceAndRecalibration__c = True;
        update serviceTerritory;
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Replacement');
        workTypeset.add('Stock Collect');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*FALSE,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    @isTest
    public static void unitTest4Recalibration(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Recalibration', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, BLN_Type__c FROM ServiceTerritory];
        serviceTerritory[0].BLN_Type__c = 'Branch';
        serviceTerritory[0].BLN_SplitReplaceAndRecalibration__c = True;
        update serviceTerritory;
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Recalibration');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*FALSE,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    @isTest
    public static void unitTest5(){
         User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Stock Collect', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId FROM ServiceTerritory];
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Replacement');
        workTypeset.add('Stock Collect');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*True,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    @isTest
    public static void unitTest5Repalacement(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        ServiceAppointment servApp1 = BLN_TestDataFactory.createServiceAppntmnt('Stock Collect', TRUE);
        saList.add(servApp1);
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId FROM ServiceTerritory];
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Replacement');
        workTypeset.add('Stock Collect');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*True,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(2, saList.size(), 'Service Appointment should be 2');
    }
    @isTest
    public static void unitTest6(){
       User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Replacement', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId FROM ServiceTerritory];
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Replacement');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*True,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    @isTest
    public static void unitTest7(){
     User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Stock Collect', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, BLN_Type__c FROM ServiceTerritory];
        serviceTerritory[0].BLN_Type__c = 'Branch';
        serviceTerritory[0].BLN_SplitReplaceAndRecalibration__c = True;
        update serviceTerritory;
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Replacement');
        workTypeset.add('Stock Collect');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*True,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    @isTest
    public static void unitTest7Replacement(){
         User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Replacement', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, BLN_Type__c FROM ServiceTerritory];
        serviceTerritory[0].BLN_Type__c = 'Branch';
        serviceTerritory[0].BLN_SplitReplaceAndRecalibration__c = True;
        update serviceTerritory;
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Replacement');
        workTypeset.add('Stock Collect');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*True,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    @isTest
    public static void unitTest7Recalibration(){
         User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Recalibration', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, BLN_Type__c FROM ServiceTerritory];
        serviceTerritory[0].BLN_Type__c = 'Branch';
        serviceTerritory[0].BLN_SplitReplaceAndRecalibration__c = True;
        update serviceTerritory;
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Recalibration');
        workTypeset.add('Stock Collect');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*True,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    @isTest
    public static void unitTest7Assist(){
       User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Assist', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, BLN_Type__c FROM ServiceTerritory];
        serviceTerritory[0].BLN_Type__c = 'Branch';
        serviceTerritory[0].BLN_SplitReplaceAndRecalibration__c = True;
        update serviceTerritory;
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Replacement');
        workTypeset.add('Stock Collect');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*True,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    @isTest
    public static void unitTest8(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Replacement', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, BLN_Type__c FROM ServiceTerritory];
        serviceTerritory[0].BLN_Type__c = 'Branch';
        serviceTerritory[0].BLN_SplitReplaceAndRecalibration__c = True;
        update serviceTerritory;
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Replacement');
        workTypeset.add('Assist');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*True,*/ serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
    /*@isTest
    public static void unitTest8Recalibration(){
          User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        ServiceAppointment servApp = BLN_TestDataFactory.createServiceAppntmnt('Recalibration', TRUE);
        saList.add(servApp);
        ServiceAppointment servApp1 = BLN_TestDataFactory.createServiceAppntmnt('Repair', TRUE);
        saList.add(servApp1);
        
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Repair');
        workTypeset.add('Recalibration');

        DateTime earliestStartTime = System.Today().addDays(1);
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, BLN_Type__c FROM ServiceTerritory];
            serviceTerritory[0].BLN_Type__c = 'Branch';
            serviceTerritory[0].BLN_SplitReplaceAndRecalibration__c = True;
            update serviceTerritory;
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(2, saList.size(), 'Service Appointment should be 2');
    }
    @isTest
    public static void unitTest8Assist(){
         User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        ServiceAppointment servApp = BLN_TestDataFactory.createServiceAppntmnt('Assist', TRUE);
        saList.add(servApp);
        ServiceAppointment servApp1 = BLN_TestDataFactory.createServiceAppntmnt('Repair', TRUE);
        saList.add(servApp1);
        
        Set<String> workTypeset = new Set<String>(); 
        workTypeset.add('Assist');
        workTypeset.add('Replacement');
        
        DateTime earliestStartTime = System.Today();
        Order ord = [Select Id,BLN_Case__c From Order];
        Test.startTest();
            List<ServiceTerritory> serviceTerritory = [SELECT Id, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, BLN_Type__c FROM ServiceTerritory];
            serviceTerritory[0].BLN_Type__c = 'Branch';
            serviceTerritory[0].BLN_SplitReplaceAndRecalibration__c = True;
            update serviceTerritory;
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, serviceTerritory[0], workTypeset, earliestStartTime,ord.BLN_Case__c);
        Test.stopTest();
        system.assertEquals(2, saList.size(), 'Service Appointment should be 2');
    }*/
    @isTest
    public static void unitTestLast1(){
            User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Duration, Status, ServiceTerritoryId, SchedStartTime, SchedEndTime, BLN_WorkOrderNumber__c, BLN_RemedyJobId__c, BLN_RemedyTaskId__c, WorkTypeId,EarliestStartTime FROM ServiceAppointment];
        WorkType worktype = BLN_TestDataFactory.createWorkType('Assist', 11.00, true, true);
        saList[0].WorkTypeId = worktype.Id;
        Update saList;
        Test.startTest();
            BLN_LeadTimeFieldCalculation.MainSADurationCalculation(saList[0]);
        Test.stopTest();
        system.assertEquals(1, saList.size(), 'Service Appointment should be only 1');
    }
}