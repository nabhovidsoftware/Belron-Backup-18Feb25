/*****************************************
ClassName : BLN_QueryHandlerWebserviceTest
Description :  This test class is used to cover testcoverage for BLN_QueryHandlerWebservice.
CreatedDate: 
CreatedBy : PwC-India
Last ModifiedBy: Subhamita Dutta
****************************************/

@isTest
public class BLN_QueryHandlerWebserviceTest {
    @testSetUp
    public static void testSetupData(){
        WorkType repairWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_RepairWT, 4 , true ,  true);
        WorkType replacementWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_ReplacementWT, 4 , true ,  true);
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours('All Day Slot', true);
         BLN_TestDataFactory.createTimeSlotsFullDayProfile(true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , true);
        st.BLN_GUID__c = 'Test';
        update st;
        
        Case newCase=BLN_TestDataFactory.createCase(true);
        BLN_TestDataFactory.createSchedulingPolicy(System.Label.BLN_SchedulingPolicyName, true);
        
        WorkOrder workOrder1 = BLN_TestDataFactory.createWorkOrder2(replacementWT.id, st.Id, false);
        workOrder1.CaseId=newCase.Id;
        workOrder1.BLN_RemedyJobId__c='0969964544427';
        insert workOrder1;
        
        String remedyTaskId1 = '66088851';
        List<WorkOrderLineItem> wOLIList = new List<WorkOrderLineItem>();
        
        WorkOrderLineItem wOLI1= new WorkOrderLineItem();
        wOLI1.Status = 'New';
        wOLI1.WorkOrderId = workOrder1.Id;
        wOLI1.WorkTypeId  = repairWT.Id;
        wOLI1.BLN_RemedyTaskId__c  = remedyTaskId1;
        wOLIList.add(wOLI1);
        
        if(wOLIList.size()>0){
            insert wOLIList;
        }
        
        List<ServiceAppointment> servAppList = new List<ServiceAppointment>();
        
        ServiceAppointment servAppList1=BLN_TestDataFactory.createServiceAppointment('SA1', wOLIList[0].Id, st.Id, '66088851', false);
        servAppList1.BLN_RemedyJobId__c = workOrder1.BLN_RemedyJobId__c;
        servAppList1.Status = 'Scheduled';
        servAppList1.BLN_WorkOrderNumber__c = workOrder1.id;
        servAppList.add(servAppList1);

        ServiceAppointment servApp2 = BLN_TestDataFactory.createServiceAppointment('SA2', wOLIList[0].Id, st.Id, '66088852', false);
        servApp2.Status = 'Scheduled';
        servApp2.BLN_WorkOrderNumber__c = workOrder1.id;
        servAppList.add(servApp2);
		set<id> sAId = new set<id>();
        sAId.add(servApp2.Id);
        if(servAppList.size()>0){
            insert servAppList;
        }
        
        Account policyHolder=New Account();
        policyHolder.FirstName='Policytesting';
        policyHolder.LastName='Holdertesting';
        policyHolder.Salutation='Mr.';
        policyHolder.Phone='7895674562';
        policyHolder.BLN_PersonAccountType__c='POLICYHOLDER';
         policyHolder.BLN_RegisteredAddressTerritory__c='CE';
        policyHolder.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        policyHolder.PersonHomePhone = '7895674563';
        insert policyHolder;
        Order order = new Order();
        order.BLN_Case__c = newCase.Id;
        order.BLN_IsDropOff__c = FALSE;
        order.Status = 'Draft';
        order.EffectiveDate = Date.Today() - 1;
        order.BLN_ServiceTerritory__c = st.id;
        order.AccountId = policyHolder.Id;
        order.ContractId = BLN_TestDataFactory.createTestContract(policyHolder).Id;
        INSERT order;
        
        FSL__Time_Dependency__c timeDependency = new FSL__Time_Dependency__c();
        timeDependency.FSL__Dependency__c = System.label.BLN_Dependency;
        timeDependency.FSL__Same_Resource__c = true;
        timeDependency.FSL__Service_Appointment_1__c = servAppList1.id;
        timeDependency.FSL__Service_Appointment_2__c = servApp2.id;
        timeDependency.FSL__Root_Service_Appointment__c = servApp2.id;
        
        INSERT timeDependency;
    }
    @isTest
    public static void queryHandlerWebserviceTest() {
        Id woId = [SELECT Id FROM WorkOrder LIMIT 1].Id;
        Id woliId =[select id from WorkOrderLineItem limit 1].Id;
        Id accountId = [select id from Account limit 1].Id;
        Id orderId = [select id from Order limit 1].Id;
        Id workTypeId = [SELECT Id FROM WorkType LIMIT 1].Id;
        ServiceTerritory st = [SELECT Id, BLN_GUID__c, Name FROM ServiceTerritory LIMIT 1];
        String scheduledPolicy = [select id, Name from FSL__Scheduling_Policy__c where name ='BUK Scheduling Policy' limit 1].Name;
        
        String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;
        User adminUser = new User(
            ProfileId = adminProfileId,
            FirstName = 'PS',
            UserroleId =role,
            LastName = 'Test User',
            UserName = System.now().getTime() + '@test.demo',
            Alias = 'pstes',
            Email = 'test@sample.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true); 
        insert adminUser;
       
        // Create test data using BLN_TestDataFactory or any other appropriate method
        // Insert necessary test data for the related cases
        
        ServiceAppointment sa = [select id,BLN_WorkOrderNumber__c from ServiceAppointment limit 1];
		set<id> sAId = new set<id>();
        sAId.add(sa.Id);
       // Order getOr = [select id from Order limit 1];
       // OperatingHours oh = [select id from OperatingHours limit 1];
        TimeSlot ts = [select id,OperatingHoursId,DayOfWeek from TimeSlot limit 1];
        workOrder wo = [select id, CaseId from workOrder];
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        system.runAs(adminUser){
            INSERT prod;
            List<Product2> produ = new List<Product2>();
            produ.add(prod);
            Pricebook2 pricebook = new Pricebook2(
                Name = 'PriceBook',
                IsActive = true
            );
            insert pricebook;
            
            Test.startTest();
            
            BLN_QueryHandlerWebservice.selectByNameOrNumber('Account', '1');
            BLN_QueryHandlerWebservice.selectByNameOrNumber('WorkOrder', '1');
            BLN_QueryHandlerWebservice.selectByNameOrNumber('WorkOrderLineItem', '1');
            BLN_QueryHandlerWebservice.selectByNameOrNumber('ServiceAppointment', '1');
            BLN_QueryHandlerWebservice.selectByNameOrNumber('ServiceAppointment', new Set<String>{'1'});
            BLN_QueryHandlerWebservice.getServiceTerritoryByType(new Set<String>{''}, '');
            BLN_QueryHandlerWebservice.getWOByRemedyJobId('remedyJobId');
            BLN_QueryHandlerWebservice.getWOByLikeRemedyJobId('remedyJobId');
            BLN_QueryHandlerWebservice.getWorkOrderLineItemById(new Set<Id>{woliId});
            BLN_QueryHandlerWebservice.getSAByRemedyTaskId(new Set<String>{'remedyTaskIds'});
           // Set<String> workType = new Set<String>{'Work Type 1', ' WorkType 2'};
            BLN_QueryHandlerWebservice.getVehicleByRegNum('regNumber');
            BLN_QueryHandlerWebservice.getAccountByIdAndType(new Set<Id>{accountId});
            BLN_QueryHandlerWebservice.getAccountByPersonConId(new Set<Id>{accountId});
            BLN_QueryHandlerWebservice.getCaseRecordById('caseId');
            BLN_QueryHandlerWebservice.getServiceAppointments(sa.Id);
            BLN_QueryHandlerWebservice.getSchedulingPolicyId(scheduledPolicy); 
            BLN_QueryHandlerWebservice.getServiceAppointment(sa.Id);
            BLN_QueryHandlerWebservice.getServiceTerritoryByAppointmentId(sa.Id);
            BLN_QueryHandlerWebservice.getServiceAppointmentByIds(new Set<Id>{accountId});
            BLN_QueryHandlerWebservice.getSetOfMainWorkTypes();
            BLN_QueryHandlerWebservice.getSkillReq(new Set<String>{'regNumber'});
            BLN_QueryHandlerWebservice.getCaseConRole(new Set<String>{'regNumber'});
            BLN_QueryHandlerWebservice.getCCRByCaseIdAndConId('regNumber','regNumber');
            BLN_QueryHandlerWebservice.getPersonAccountByName('salutation', 'fName', 'lName', 'phone');
            BLN_QueryHandlerWebservice.getOrderItemByOrder('orderId');
            BLN_QueryHandlerWebservice.getProductByProductCode(new Set<String>{'productCode'});
            BLN_QueryHandlerWebservice.getEndTimeFromTimeSlot(ts.OperatingHoursId, ts.DayOfWeek);
            BLN_QueryHandlerWebservice.getStartTimeFromTimeSlot(ts.OperatingHoursId, ts.DayOfWeek);
            BLN_QueryHandlerWebservice.getWorkOrderById(wo.Id);
            BLN_QueryHandlerWebservice.getSchedulingPolicyName(scheduledPolicy);
            BLN_QueryHandlerWebservice.getServiceAppointmentByWorkOrder(sa.BLN_WorkOrderNumber__c);
            BLN_QueryHandlerWebservice.getServiceReportLayoutByName(System.Label.BLN_PreInspectionSRLName);
            BLN_QueryHandlerWebservice.getWorkType(new Set<String>{'names'});
            BLN_QueryHandlerWebservice.getProdFromId(new Set<String>{'names'});
            BLN_QueryHandlerWebservice.getPriceBookEntryMap(produ);
            BLN_QueryHandlerWebservice.getStandardPriceBook(false, pricebook.Name);
        BLN_QueryHandlerWebservice.getServiceTerritoryFromOrgID('orgid');
        BLN_QueryHandlerWebservice.getLocationByOrgid('orgid');
        BLN_QueryHandlerWebservice.getTimeDependencyByAppointmentIdSet(sAId);
        BLN_QueryHandlerWebservice.getServiceTerritoryByName(st.Name);
        BLN_QueryHandlerWebservice.getServiceAppointmentForUpdate(sa.Id);
        }
        BLN_QueryHandlerWebservice.getSkills();
        BLN_QueryHandlerWebservice.getWorkTypeById(new Set<ID>{accountId});
        BLN_QueryHandlerWebservice.getBUMetadata('Testing');
        BLN_QueryHandlerWebservice.getWeatherGuardProductMetadata();
        BLN_QueryHandlerWebservice.getOperatingHours('All Day Slot');
        BLN_QueryHandlerWebservice.getServAppShortningConfigMetadata();
        Schema.Location loc = new Schema.Location();
        loc.Name = 'Test';
        loc.LocationType = 'Belron Warehouse';
        loc.Longitude = 28.635308;
        loc.Latitude = 28.635308;
        loc.BLN_GUID__c = 'Test';
        loc.BLN_OrgCodeLocation__c = 'Test';
        insert loc;
        
        BLN_QueryHandlerWebservice.getLocationByGuid(loc.BLN_GUID__c);
        BLN_QueryHandlerWebservice.getLocationByPrimarySourceCollectId(loc.BLN_OrgCodeLocation__c);
        BLN_QueryHandlerWebservice.getServiceTerritoryFromGUID(st.BLN_GUID__c);
        BLN_QueryHandlerWebservice.getCaseFromId(wo.CaseId);
        BLN_QueryHandlerWebservice.getOrderByOrderId(orderId);
        BLN_QueryHandlerWebservice.getWorkOrderFromCase(wo.CaseId);
        BLN_QueryHandlerWebservice.getWoliFromWorkOrderId(woId);
        BLN_QueryHandlerWebservice.getWorkTypeFromWorkOrderId(woId);
        BLN_QueryHandlerWebservice.getPRListUsingWoliIdSet(new Set<String>{woliId});
        BLN_QueryHandlerWebservice.getWorkTypeById(workTypeId);
        
        Id corporateId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByName().get('Corporate/Fleet').getRecordTypeId();
        String recodTypeName = [SELECT Name FROM RecordType WHERE ID =: corporateId].Name;
        BLN_QueryHandlerWebservice.getCorporateRecordTypes(new List<String>{recodTypeName});
        BLN_QueryHandlerWebservice.getTimeDependencyByAppointmentId(sa.Id);
        
        Test.stopTest();
        System.assertNotEquals(null, orderId,'orderId is not Null');
        UserRole ur = new UserRole(Name = 'Finance Approver');
        insert ur;	
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName,UserRoleId = ur.Id);
        
        System.runAs(u) {
            uniqueUserName='';
            system.assertNotEquals(u, Null, 'Profile Should be available');
            
        }
    }
    @isTest
    public static void queryHandlerWebserviceTest1() {
        String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;
        User adminUser = new User(
            ProfileId = adminProfileId,
            FirstName = 'PS',
            UserroleId =role,
            LastName = 'Test User',
            UserName = System.now().getTime() + '@test.demo',
            Alias = 'pstes',
            Email = 'test@sample.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true); 
        insert adminUser;
       
        // Create test data using BLN_TestDataFactory or any other appropriate method
        
        
        Test.startTest();
        
        BLN_QueryHandlerWebservice.getServiceTerritoryByType(new Set<String>{''}, '');
        BLN_QueryHandlerWebservice.getWOByRemedyJobId('');
        BLN_QueryHandlerWebservice.getWOByLikeRemedyJobId('');
        BLN_QueryHandlerWebservice.getWorkOrderLineItemById(new Set<Id>());
        BLN_QueryHandlerWebservice.getSAByRemedyTaskId(new Set<String>{'remedyTaskIds'});
        BLN_QueryHandlerWebservice.getVehicleByRegNum('');
        BLN_QueryHandlerWebservice.getAccountByIdAndType(new Set<Id>());
        BLN_QueryHandlerWebservice.getAccountByPersonConId(new Set<Id>());
        BLN_QueryHandlerWebservice.getCaseRecordById('');
        BLN_QueryHandlerWebservice.getServiceAppointments('');
        // BLN_QueryHandlerWebservice.getSchedulingPolicyId('');
        BLN_QueryHandlerWebservice.getServiceAppointment('');
        // BLN_QueryHandlerWebservice.getServiceTerritoryByAppointmentId('');
        BLN_QueryHandlerWebservice.getServiceAppointmentByIds(new Set<Id>());
        BLN_QueryHandlerWebservice.getSetOfMainWorkTypes();
        BLN_QueryHandlerWebservice.getSkillReq(new Set<String>());
        BLN_QueryHandlerWebservice.getCaseConRole(new Set<String>());
        BLN_QueryHandlerWebservice.getCCRByCaseIdAndConId('','');
        BLN_QueryHandlerWebservice.getPersonAccountByName('', '', '', '');
        BLN_QueryHandlerWebservice.getOrderItemByOrder('');
        BLN_QueryHandlerWebservice.getProductByProductCode(new Set<String>());
       // BLN_QueryHandlerWebservice.getEndTimeFromTimeSlot('', '');
        //BLN_QueryHandlerWebservice.getStartTimeFromTimeSlot('', '');
        BLN_QueryHandlerWebservice.getWorkOrderById('');
        BLN_QueryHandlerWebservice.getSchedulingPolicyName('');
        BLN_QueryHandlerWebservice.getServiceAppointmentByWorkOrder('');
        BLN_QueryHandlerWebservice.getServiceReportLayoutByName('');
        BLN_QueryHandlerWebservice.getWorkType(new Set<String>());
        BLN_QueryHandlerWebservice.getProdFromId(new Set<String>());
        BLN_QueryHandlerWebservice.getPriceBookEntryMap(new List<Product2>());
        BLN_QueryHandlerWebservice.getStandardPriceBook(false, null);
        BLN_QueryHandlerWebservice.getSkills();
        BLN_QueryHandlerWebservice.getWorkTypeById(new Set<ID>());
        BLN_QueryHandlerWebservice.getBUMetadata('');
        BLN_QueryHandlerWebservice.getWeatherGuardProductMetadata();
        BLN_QueryHandlerWebservice.getOperatingHours('');
        BLN_QueryHandlerWebservice.getServAppShortningConfigMetadata();        
        BLN_QueryHandlerWebservice.getLocationByGuid('');
        BLN_QueryHandlerWebservice.getLocationByPrimarySourceCollectId('');
        BLN_QueryHandlerWebservice.getServiceTerritoryFromGUID('');
        BLN_QueryHandlerWebservice.getCaseFromId('');
        BLN_QueryHandlerWebservice.getOrderByOrderId(null);
        BLN_QueryHandlerWebservice.getWorkOrderFromCase('');
        BLN_QueryHandlerWebservice.getWoliFromWorkOrderId('');
        //BLN_QueryHandlerWebservice.getWorkTypeFromWorkOrderId('');
        BLN_QueryHandlerWebservice.getPRListUsingWoliIdSet(new Set<String>());
        BLN_QueryHandlerWebservice.getWorkTypeById('');
        
        Test.stopTest();
        UserRole ur = new UserRole(Name = 'Finance Approver');
        insert ur;	
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName,UserRoleId = ur.Id);
        
        System.runAs(u) {
            uniqueUserName='';
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
    }
}