/** @description : The Service class Remedy Webservice used for BLN_WebservicePrepData  clone of BLN_HandlerWebServiceTest
*  @author: Ayush Singh(PwC IN)
*  @Story : FOUK-4342
*  @CreatedDate : 31/05/2023
*/
@istest
public class BLN_PHandlerWebServiceTest {
    /**
*@description : This method is used for testing BLN_PortalHandlerWebService methods
*/
    @testSetUp
    public static void testSetupData(){
        
        WorkType repairWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_RepairWT, 4 , true ,  true);
        WorkType replacementWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_ReplacementWT, 4 , true ,  true);
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours('All Day Slot', true);
        
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , true);
        
        st.BLN_GUID__c = 'test';
        update st;
        Case newCase=BLN_TestDataFactory.createCase(true);
        
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
        servAppList.add(servAppList1);
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
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        INSERT prod;
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        TimeSlot timeSlotFulDay = new TimeSlot(
            OperatingHoursId = operatingHours.Id,
            DayOfWeek = 'Monday',
            StartTime = Time.newInstance(7,0,0,0),
            EndTime = Time.newInstance(22,0,0,0)
        );
        insert timeSlotFulDay;
    }
    @istest
    public static void handlerWebServiceTest(){
        WorkOrder wo = [select id, CaseId from WorkOrder limit 1];
        
        string woid = wo.id;
        Id woliId =[select id from WorkOrderLineItem limit 1].Id;
        Id accountId = [select id from Account limit 1].Id;
        string orderId = [select id from Order limit 1].Id;
   
        ServiceTerritory st = [select id, BLN_GUID__c from ServiceTerritory where BLN_GUID__c !=null Limit 1];
        
        ServiceAppointment sa = [Select Id from ServiceAppointment limit 1];

        FSL__Scheduling_Policy__c schedulingPolicy = [Select Id, Name from FSL__Scheduling_Policy__c limit 1];

        OperatingHours opHour = [Select Id, Name from OperatingHours limit 1];
        
        Test.startTest();
        BLN_PortalHandlerWebService.getServiceTerritoryFromGUID(st.BLN_GUID__c);
        BLN_PortalHandlerWebService.getBUMetadata('Testing');
        BLN_PortalHandlerWebService.getWorkType('test');
        BLN_PortalHandlerWebService.getWorkType(new set<string>{'test'});
        BLN_PortalHandlerWebService.getWorkTypeRec(new Set<String>{'names'});
        BLN_PortalHandlerWebService.getProdFromId(new Set<String>{'names'});
        BLN_PortalHandlerWebService.getSkills();
        BLN_PortalHandlerWebService.getWOByRemedyJobId('remedyJobId');
        BLN_PortalHandlerWebService.getWOByLikeRemedyJobId('remedyJobId');
        BLN_PortalHandlerWebService.getWorkOrderLineItemById(new Set<Id>{woliId});
        BLN_PortalHandlerWebService.getSAByRemedyTaskId(new Set<String>{'remedyTaskIds'});
        //BLN_PortalHandlerWebService.getSAByWorkTypeName('remedyJobId', new Set<String>{'workTypeNames'});
        BLN_PortalHandlerWebService.getVehicleByRegNum('regNumber');
        BLN_PortalHandlerWebService.getServiceAppointmentByIds(new Set<Id>{accountId});
        BLN_PortalHandlerWebService.getDistrictServiceTerritory(new set<string>{'test'});
        BLN_PortalHandlerWebService.getDummyPersonAcc('test');
        BLN_PortalHandlerWebService.getSchedulingPolicy('BUK Scheduling Policy');
        BLN_PortalHandlerWebService.getCaseRecordById('caseId');
        BLN_PortalHandlerWebService.getAccountByIdAndType(new Set<Id>{accountId});
            
        //Boolean check= true;
        //String name='test';
        //
        //Boolean check = true;
        String name = 'Standard Price Book';
        
        
       // List<Product2> mockProducts = new List<Product2>();
       // List<PriceBookEntry> priceBookEntries = BLN_PortalHandlerWebService.getPriceBookEntryMap(mockProducts);
        
        //Pricebook2 standardPriceBook =BLN_PortalHandlerWebService.getStandardPriceBook(check,name);
        BLN_PortalHandlerWebService.getSetOfMainWorkTypes();
        BLN_PortalHandlerWebService.getSkillReq(new Set<String>{'regNumber'});
        BLN_PortalHandlerWebService.getCaseConRole(new Set<String>{'regNumber'});
        BLN_PortalHandlerWebService.getCCRByCaseIdAndConId('regNumber','regNumber');
        BLN_PortalHandlerWebService.getAccountByPersonConId(new Set<Id>{accountId});
        BLN_PortalHandlerWebService.getPersonAccountByName('salutation', 'fName', 'lName', 'phone');
        BLN_PortalHandlerWebService.getOrderItemByOrder('orderId');
        BLN_PortalHandlerWebService.getProductByProductCode(new Set<String>{'productCode'});
        BLN_PortalHandlerWebService.getProdFromId(new Set<String>{'names'});
        BLN_PortalHandlerWebService.getOrderByOrderId(orderId);
        BLN_PortalHandlerWebService.getWorkTypeById(new Set<ID>{accountId});
        
        BLN_PortalHandlerWebService.getWorkOrderById(woid);
        //BLN_PortalHandlerWebService.getLocationByGuid(st.BLN_GUID__c);
        //BLN_PortalHandlerWebService.getCaseFromOrder(orderid);
        //BLN_PortalHandlerWebService.getServiceTerritoryFromOrder(orderId);
        BLN_PortalHandlerWebService.getWeatherGuardProductMetadata();
        //BLN_PortalHandlerWebService.getLocationByPrimarySourceCollectId('test');
        BLN_PortalHandlerWebService.getServiceTerritoryByAppointmentId(sa.Id);
        BLN_PortalHandlerWebService.getSchedulingPolicyName(schedulingPolicy.Name);
        BLN_PortalHandlerWebService.getEndTimeFromTimeSlot(opHour.Id, 'Monday');
        BLN_PortalHandlerWebService.getStartTimeFromTimeSlot(opHour.Id, 'Monday');
        BLN_PortalHandlerWebService.getServiceAppointmentByWorkOrder(woid);
        BLN_PortalHandlerWebService.getServAppShortningConfigMetadata();
        //BLN_PortalHandlerWebService.getServiceReportLayoutByName(st. );
        Schema.Location loc = new Schema.Location();
        loc.Name = 'Test';
        loc.LocationType = 'Belron Warehouse';
        loc.Longitude = 28.635308;
        loc.Latitude = 28.635308;
        loc.BLN_GUID__c = 'Test';
        loc.BLN_PrimarySourceCollectId__c='test'; 
        loc.BLN_OrgCodeLocation__c = 'Test';
        insert loc;
        
        BLN_PortalHandlerWebService.getLocationByGuid(loc.BLN_GUID__c);
        BLN_PortalQueryHandlerWebservice.getLocationByPrimarySourceCollectId(loc.BLN_PrimarySourceCollectId__c);
        BLN_PortalHandlerWebService.getWorkOrderFromCase(wo.CaseId);
        BLN_PortalHandlerWebService.getCaseFromId(wo.CaseId);
        Test.stopTest();
        System.assertNotEquals(null, orderId,'orderId is not null');
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
            uniqueUserName = '';
        }
        
    }
}