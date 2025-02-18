/** @description : This test class is used to cover testcoverage for BLN_ManageMDCStockCollectController
*   @author: Wasim Akram (PwC)
*   @CreatedDate: 10 July 2024
*/


@IsTest
public with sharing class BLN_ManageMDCStockCollectControllerTest {
    @TestSetup
    public static void setupTestData() {
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours('All Day Slot', true);
        
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford', (String) operatingHours.Id, false);
        st.BLN_SchedulingPolicy__c= SchedulingPolicy.id;
        st.BLN_IsBranch__c = true;
        st.BLN_SplitReplaceAndRecalibration__c = false;
        st.OperatingHoursId= operatingHours.id;
        st.BLN_GUID__c = '2552';
        st.BLN_OrgCodeLocation__c = '2552';
        insert st;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.Status = 'New';
        INSERT caseObj;
        
        String appointmentId = BLN_TestDataFactory.createServiceAppointment('Repair', true);
        ServiceAppointment sA = [select id, ServiceTerritoryId, BLN_WorkOrderNumber__c from ServiceAppointment where id = :appointmentId];
        sA.ServiceTerritoryId = st.id;
        sA.BLN_Case__c = caseObj.Id;
        UPDATE sA;
        
        WorkType stockWT = BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        System.assertEquals('Stock Collect', stockWT.Name, 'The WorkType name should be Stock Collect.');
        
        Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format('EEEE');
        TimeSlot timeSlot = BLN_TestDataFactory.createTimeSlotsFullDayProfile(false);
        timeSlot.DayOfWeek = dayOfWeek;
        timeSlot.OperatingHoursId = operatingHours.Id;
        INSERT timeSlot;
        
        Schema.Location loc = new Schema.Location();
        loc.Name = 'Cardington';
        loc.LocationType = 'Branch';
        loc.BLN_GUID__c = '2552';
        loc.BLN_OrgCodeLocation__c = '2552';
        insert loc;

        Schema.Address address = new Schema.Address();
        address.country =  'United Kingdom';
        address.latitude = 52.12529;
        address.longitude = -0.42229;
        address.postalCode = 'MK44 3US';
        address.street = 'Mount Vernon Youth Club 2A Mount Vernon Road';
        address.ParentId = loc.Id;
        insert address;
		
        loc.visitorAddressId = address.id;
        update loc;
    }

    @IsTest
    public static void createMDCStock() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }

        ServiceAppointment servApp = [SELECT Id FROM ServiceAppointment LIMIT 1];
        BLN_ManageMDCStockCollectController.generateMDCStock(servApp.Id, '2552');
    }
    @IsTest
    public static void updateExistingStock() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }

        ServiceAppointment servApp = [SELECT Id FROM ServiceAppointment LIMIT 1];
        
        WorkType stockWT = BLN_TestDataFactory.createWorkType('Stock Collect', 5 , true ,  true);
        
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];
        
        WorkOrder wO = BLN_TestDataFactory.createWorkOrder2(stockWT.Id , st.Id , true);
        
        WorkOrderLineItem woLi = BLN_AppointmentDataCreationService.generateWoLi(wO, stockWT);
        woLi.workTypeId = stockWT.Id;
        insert woLi;
        
        Datetime now = Datetime.now();
        ServiceAppointment sApp =new ServiceAppointment();
        sApp.ParentRecordId = woLi.id;
        sApp.status= 'open';
        sApp.EarliestStartTime = now;
        sApp.DueDate = now.addminutes(30);
        sApp.worktypeid = stockWT.id;
        sApp.ServiceTerritoryId = st.Id;
        insert sApp;
        
        FSL__Time_Dependency__c timeDependency = new FSL__Time_Dependency__c();
        timeDependency.FSL__Dependency__c = System.label.BLN_Dependency;
        timeDependency.FSL__Same_Resource__c = true;
        timeDependency.FSL__Service_Appointment_1__c = servApp.id;
        timeDependency.FSL__Service_Appointment_2__c = sApp.id;
        timeDependency.FSL__Root_Service_Appointment__c = sApp.id;
        INSERT timeDependency;

        BLN_ManageMDCStockCollectController.generateMDCStock(servApp.Id, '2552');
    }
    
    @IsTest
    public static void coverNull() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }

        ServiceAppointment servApp = [SELECT Id FROM ServiceAppointment LIMIT 1];
        BLN_ManageMDCStockCollectController.generateMDCStock(servApp.Id, Null);
    }
}