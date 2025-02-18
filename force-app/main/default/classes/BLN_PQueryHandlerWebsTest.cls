/** @description : The Service class Remedy Webservice used for BLN_WebservicePrepData  clone of BLN_HandlerWebserviceTest
*  @author: (PwC IN)
*  @Story : FOUK-4342
*  @CreatedDate : 31/05/2023
*/
@isTest
public class BLN_PQueryHandlerWebsTest {
    @testSetUp
    public static void testSetupData(){
        WorkType repairWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_RepairWT, 4 , true ,  true);
        WorkType replacementWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_ReplacementWT, 4 , true ,  true);
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours('All Day Slot', true);
       // TimeSlot ts = BLN_TestDataFactory.createTimeSlotsFullDayProfile(true);
       BLN_TestDataFactory.createTimeSlotsFullDayProfile(true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , true);
        st.BLN_GUID__c = 'Test';
        update st;
        
        Case newCase=BLN_TestDataFactory.createCase(true);
       //FSL__Scheduling_Policy__c schedulingPolicy =  BLN_TestDataFactory.createSchedulingPolicy(System.Label.BLN_SchedulingPolicyName, true);
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

        if(servAppList.size()>0){
            insert servAppList;
        }
        
        Account policyHolder=New Account();
        policyHolder.FirstName='Policytesting';
        policyHolder.LastName='Holdertesting';
        policyHolder.Salutation='Mr.';
        policyHolder.Phone='7895674562';
        policyHolder.BLN_PersonAccountType__c='POLICYHOLDER';
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
        ServiceTerritory st = [SELECT Id, BLN_GUID__c FROM ServiceTerritory LIMIT 1];
        String scheduledPolicy = [select id, Name from FSL__Scheduling_Policy__c where name ='BUK Scheduling Policy' limit 1].Name;
       // FSL__Scheduling_Policy__c  scheduledPolicyA = BLN_TestDataFactory.createSchedulingPolicy(System.Label.BLN_SchedulingPolicyName, true);
       // String scheduledPolicy = 'BUK Scheduling Policy';
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
       // Order getOr = [select id from Order limit 1];
      //  OperatingHours oh = [select id from OperatingHours limit 1];
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
            
            BLN_PortalQueryHandlerWebservice.selectByNameOrNumber('Account', '1');
            BLN_PortalQueryHandlerWebservice.selectByNameOrNumber('WorkOrder', '1');
            BLN_PortalQueryHandlerWebservice.selectByNameOrNumber('WorkOrderLineItem', '1');
            BLN_PortalQueryHandlerWebservice.selectByNameOrNumber('ServiceAppointment', '1');
            BLN_PortalQueryHandlerWebservice.selectByNameOrNumber('ServiceAppointment', new Set<String>{'1'});
            BLN_PortalQueryHandlerWebservice.getServiceTerritoryByType(new Set<String>{''}, '');
            BLN_PortalQueryHandlerWebservice.getWOByRemedyJobId('remedyJobId');
            BLN_PortalQueryHandlerWebservice.getWOByLikeRemedyJobId('remedyJobId');
            BLN_PortalQueryHandlerWebservice.getWorkOrderLineItemById(new Set<Id>{woliId});
            BLN_PortalQueryHandlerWebservice.getSAByRemedyTaskId(new Set<String>{'remedyTaskIds'});
           // Set<String> workType = new Set<String>{'Work Type 1', ' WorkType 2'};
            BLN_PortalQueryHandlerWebservice.getVehicleByRegNum('regNumber');
            BLN_PortalQueryHandlerWebservice.getAccountByIdAndType(new Set<Id>{accountId});
            BLN_PortalQueryHandlerWebservice.getAccountByPersonConId(new Set<Id>{accountId});
            BLN_PortalQueryHandlerWebservice.getCaseRecordById('caseId');
            BLN_PortalQueryHandlerWebservice.getServiceAppointments(sa.Id);
            BLN_PortalQueryHandlerWebservice.getSchedulingPolicyId(scheduledPolicy);
            BLN_PortalQueryHandlerWebservice.getServiceAppointment(sa.Id);
            BLN_PortalQueryHandlerWebservice.getServiceTerritoryByAppointmentId(sa.Id);
            BLN_PortalQueryHandlerWebservice.getServiceAppointmentByIds(new Set<Id>{accountId});
            BLN_PortalQueryHandlerWebservice.getSetOfMainWorkTypes();
            BLN_PortalQueryHandlerWebservice.getSkillReq(new Set<String>{'regNumber'});
            BLN_PortalQueryHandlerWebservice.getCaseConRole(new Set<String>{'regNumber'});
            BLN_PortalQueryHandlerWebservice.getCCRByCaseIdAndConId('regNumber','regNumber');
            BLN_PortalQueryHandlerWebservice.getPersonAccountByName('salutation', 'fName', 'lName', 'phone');
            BLN_PortalQueryHandlerWebservice.getOrderItemByOrder('orderId');
            BLN_PortalQueryHandlerWebservice.getProductByProductCode(new Set<String>{'productCode'});
            BLN_PortalQueryHandlerWebservice.getEndTimeFromTimeSlot(ts.OperatingHoursId, ts.DayOfWeek);
            BLN_PortalQueryHandlerWebservice.getStartTimeFromTimeSlot(ts.OperatingHoursId, ts.DayOfWeek);
            BLN_PortalQueryHandlerWebservice.getWorkOrderById(wo.Id);
            BLN_PortalQueryHandlerWebservice.getSchedulingPolicyName(scheduledPolicy);
            BLN_PortalQueryHandlerWebservice.getServiceAppointmentByWorkOrder(sa.BLN_WorkOrderNumber__c);
            BLN_PortalQueryHandlerWebservice.getServiceReportLayoutByName(System.Label.BLN_PreInspectionSRLName);
            BLN_PortalQueryHandlerWebservice.getWorkType(new Set<String>{'names'});
            BLN_PortalQueryHandlerWebservice.getProdFromId(new Set<String>{'names'});
            BLN_PortalQueryHandlerWebservice.getPriceBookEntryMap(produ);
            BLN_PortalQueryHandlerWebservice.getStandardPriceBook(false, pricebook.Name);
        }
        BLN_PortalQueryHandlerWebservice.getSkills();
        BLN_PortalQueryHandlerWebservice.getWorkTypeById(new Set<ID>{accountId});
        BLN_PortalQueryHandlerWebservice.getBUMetadata('Testing');
        BLN_PortalQueryHandlerWebservice.getWeatherGuardProductMetadata();
        BLN_PortalQueryHandlerWebservice.getOperatingHours('All Day Slot');
        BLN_PortalQueryHandlerWebservice.getServAppShortningConfigMetadata();
        Schema.Location loc = new Schema.Location();
        loc.Name = 'Test';
        loc.LocationType = 'Belron Warehouse';
        loc.Longitude = 28.635308;
        loc.Latitude = 28.635308;
        loc.BLN_GUID__c = 'Test';
        loc.BLN_OrgCodeLocation__c  = 'Test';
        insert loc;
        
        BLN_PortalQueryHandlerWebservice.getLocationByGuid(loc.BLN_GUID__c);
        BLN_PortalQueryHandlerWebservice.getLocationByPrimarySourceCollectId(loc.BLN_OrgCodeLocation__c);
        BLN_PortalQueryHandlerWebservice.getServiceTerritoryFromGUID(st.BLN_GUID__c);
        BLN_PortalQueryHandlerWebservice.getCaseFromId(wo.CaseId);
        BLN_PortalQueryHandlerWebservice.getOrderByOrderId(orderId);
        BLN_PortalQueryHandlerWebservice.getWorkOrderFromCase(wo.CaseId);
        BLN_PortalQueryHandlerWebservice.getWoliFromWorkOrderId(woId);
        BLN_PortalQueryHandlerWebservice.getWorkTypeFromWorkOrderId(woId);
        BLN_PortalQueryHandlerWebservice.getPRListUsingWoliIdSet(new Set<String>{woliId});
        BLN_PortalQueryHandlerWebservice.getWorkTypeById(workTypeId);
        
        Id corporateId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByName().get('Corporate/Fleet').getRecordTypeId();
        String recodTypeName = [SELECT Name FROM RecordType WHERE ID =: corporateId].Name;
        BLN_PortalQueryHandlerWebservice.getCorporateRecordTypes(new List<String>{recodTypeName});
        BLN_PortalQueryHandlerWebservice.getTimeDependencyByAppointmentId(sa.Id);
        
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
        // Insert necessary test data for the related cases
        
        Test.startTest();
        
        BLN_PortalQueryHandlerWebservice.getServiceTerritoryByType(new Set<String>{''}, '');
        BLN_PortalQueryHandlerWebservice.getWOByRemedyJobId('');
        BLN_PortalQueryHandlerWebservice.getWOByLikeRemedyJobId('');
        BLN_PortalQueryHandlerWebservice.getWorkOrderLineItemById(new Set<Id>());
        BLN_PortalQueryHandlerWebservice.getSAByRemedyTaskId(new Set<String>{'remedyTaskIds'});
        BLN_PortalQueryHandlerWebservice.getVehicleByRegNum('');
        BLN_PortalQueryHandlerWebservice.getAccountByIdAndType(new Set<Id>());
        BLN_PortalQueryHandlerWebservice.getAccountByPersonConId(new Set<Id>());
        BLN_PortalQueryHandlerWebservice.getCaseRecordById('');
        BLN_PortalQueryHandlerWebservice.getServiceAppointments('');
        // BLN_PortalQueryHandlerWebservice.getSchedulingPolicyId('');
        BLN_PortalQueryHandlerWebservice.getServiceAppointment('');
        // BLN_PortalQueryHandlerWebservice.getServiceTerritoryByAppointmentId('');
        BLN_PortalQueryHandlerWebservice.getServiceAppointmentByIds(new Set<Id>());
        BLN_PortalQueryHandlerWebservice.getSetOfMainWorkTypes();
        BLN_PortalQueryHandlerWebservice.getSkillReq(new Set<String>());
        BLN_PortalQueryHandlerWebservice.getCaseConRole(new Set<String>());
        BLN_PortalQueryHandlerWebservice.getCCRByCaseIdAndConId('','');
        BLN_PortalQueryHandlerWebservice.getPersonAccountByName('', '', '', '');
        BLN_PortalQueryHandlerWebservice.getOrderItemByOrder('');
        BLN_PortalQueryHandlerWebservice.getProductByProductCode(new Set<String>());
        BLN_PortalQueryHandlerWebservice.getEndTimeFromTimeSlot('', '');
        BLN_PortalQueryHandlerWebservice.getStartTimeFromTimeSlot('', '');
        BLN_PortalQueryHandlerWebservice.getWorkOrderById('');
        BLN_PortalQueryHandlerWebservice.getSchedulingPolicyName('');
        BLN_PortalQueryHandlerWebservice.getServiceAppointmentByWorkOrder('');
        BLN_PortalQueryHandlerWebservice.getServiceReportLayoutByName('');
        BLN_PortalQueryHandlerWebservice.getWorkType(new Set<String>());
        BLN_PortalQueryHandlerWebservice.getProdFromId(new Set<String>());
        BLN_PortalQueryHandlerWebservice.getPriceBookEntryMap(new List<Product2>());
        BLN_PortalQueryHandlerWebservice.getStandardPriceBook(false, null);
        BLN_PortalQueryHandlerWebservice.getSkills();
        BLN_PortalQueryHandlerWebservice.getWorkTypeById(new Set<ID>());
        BLN_PortalQueryHandlerWebservice.getBUMetadata('');
        BLN_PortalQueryHandlerWebservice.getWeatherGuardProductMetadata();
        BLN_PortalQueryHandlerWebservice.getOperatingHours('');
        BLN_PortalQueryHandlerWebservice.getServAppShortningConfigMetadata();        
        BLN_PortalQueryHandlerWebservice.getLocationByGuid('');
        BLN_PortalQueryHandlerWebservice.getLocationByPrimarySourceCollectId('');
        BLN_PortalQueryHandlerWebservice.getServiceTerritoryFromGUID('');
        BLN_PortalQueryHandlerWebservice.getCaseFromId('');
        BLN_PortalQueryHandlerWebservice.getOrderByOrderId(null);
        BLN_PortalQueryHandlerWebservice.getWorkOrderFromCase('');
        BLN_PortalQueryHandlerWebservice.getWoliFromWorkOrderId('');
        //BLN_PortalQueryHandlerWebservice.getWorkTypeFromWorkOrderId('');
        BLN_PortalQueryHandlerWebservice.getPRListUsingWoliIdSet(new Set<String>());
        BLN_PortalQueryHandlerWebservice.getWorkTypeById('');
        
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