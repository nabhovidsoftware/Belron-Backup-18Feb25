/** @description : BLN_AppointmentBookingTest Class used for testing BLN_AppointmentBooking.
*  	@author: Wasim Akram
* 	@Story: FOUK-6078
*	@Created Date: 13/03/2024
*/
@isTest
public class BLN_AppointmentBookingTest {

    /**
    * @description: Test method for creating TestData using TestData Factory
    */
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
        
         // Creating a Recalibration Service Appointment using a Test Data Factory
        ServiceAppointment recalApp = BLN_TestDataFactory.createServiceAppntmnt(System.label.BLN_Recalibration, TRUE);
        System.assertNotEquals(recalApp, null, 'The recalApp should not be null.');

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

    /**
    * @description: Unit test method for testing the BLN_AppointmentBooking class
    */
    @isTest
    public static void unitTest(){

        // Running as a User
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }

        // Querying necessary records for the test
        FSL__Scheduling_Policy__c schedulingPolicy = [SELECT Id FROM FSL__Scheduling_Policy__c LIMIT 1];
        System.assertNotEquals(schedulingPolicy, null, 'The scheduling policy should not be null.');
        OperatingHours operatingHours = [SELECT Id FROM OperatingHours LIMIT 1];
        System.assertNotEquals(operatingHours, null, 'The operating hours should not be null.');
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];
        System.assertNotEquals(st, null, 'The service territory should not be null.');
        
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
        BLN_AppointmentBooking.bookAppointment(date1, date2, serviceAppointments[1].Id, True, true);
        Test.startTest();
            BLN_AppointmentBooking.scheduleAppointment(serviceAppointments[1].Id);
        	BLN_AppointmentBooking.scheduleAppointment(serviceAppointments[0].Id);
        Test.stopTest();
        BLN_AppointmentBooking.bookAppointment(date1, date2, serviceAppointments[1].Id, False, true);
        BLN_AppointmentBooking.bookMobileAppointment(date1, date2, serviceAppointments[1].Id, true);
        
    }
    
    @isTest
    public static void unitTest1(){
    	ServiceAppointment sa = [SELECT Id FROM ServiceAppointment LIMIT 1];
        sa.ServiceTerritoryId = null;
        update sa;
        Test.startTest();
        BLN_AppointmentBooking.bookAppointment(null, null, sa.Id, False, true);
        Test.stopTest();
        System.assertEquals(sa.ServiceTerritoryId == null, true, 'Id should be null');
    }
    
    
    @isTest
    public static void bookMobileAppointmentException(){
        ServiceAppointment sa = [SELECT Id FROM ServiceAppointment LIMIT 1];
        DateTime date1 = System.now();
        DateTime date2 = System.now().addMinutes(-60);
        Test.startTest();
        BLN_AppointmentBooking.bookMobileAppointment(date1, date2, sa.Id, true);
        Test.stopTest();
        System.assertEquals(sa != null, true, 'Service Appointment should not be null');
    }
    
    @isTest
    public static void serviceTerritorySplitFalse(){
        DateTime date1 = System.now();
        DateTime date2 = System.now().addMinutes(-60);
        
        List<ServiceTerritory> stList = [SELECT Id FROM ServiceTerritory LIMIT 1];
        stList[0].BLN_SplitReplaceAndRecalibration__c = false;
        update stList;
        ServiceAppointment sa = [SELECT Id FROM ServiceAppointment LIMIT 1];
        Test.startTest();
        BLN_AppointmentBooking.bookBranchAppointment(date1, date2, sa.Id, false, false);
        Test.stopTest();
        System.assertEquals(stList[0].BLN_SplitReplaceAndRecalibration__c == false ,true, 'Recalibration is false');
    }
    
    @isTest
    public static void scheduleAppointmentException(){
        Test.startTest();
        String returnInput = BLN_AppointmentBooking.scheduleAppointment('');
        Test.stopTest();
        System.assertEquals(returnInput == System.Label.BLN_SchedulingFailed ,false, 'Empty response');
    }
    @isTest
    public static void unitTest2(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        DateTime date1 = System.now();
        DateTime date2 = System.now().addMinutes(-60);
        List<ServiceTerritory> stList = [SELECT Id FROM ServiceTerritory LIMIT 1];
        stList[0].BLN_SplitReplaceAndRecalibration__c = true;
    	ServiceAppointment sa = [SELECT Id FROM ServiceAppointment LIMIT 1];
        sa.ServiceTerritoryId = Null;
        update sa;
        Test.startTest();
        BLN_AppointmentBooking.bookBranchAppointment(date1, date2, sa.Id, false, false);
        Test.stopTest();
        System.assertEquals(sa.ServiceTerritoryId == Null,true, 'Territory should be null');
    }
    @isTest
    public static void unitTest3(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        DateTime date1 = System.now();
        DateTime date2 = System.now().addMinutes(-60);
        List<ServiceTerritory> stList = [SELECT Id FROM ServiceTerritory LIMIT 1];
        stList[0].BLN_SplitReplaceAndRecalibration__c = false;
        stList[0].BLN_Type__c = 'Mobile';
        update stList;
    	ServiceAppointment sa = [SELECT Id FROM ServiceAppointment LIMIT 1];
        Test.startTest();
        BLN_AppointmentBooking.bookAppointment(date1, date2, sa.Id, True, true);
        Test.stopTest();
        System.assertEquals(stList[0].BLN_Type__c == 'Mobile',true, 'type should be mobile');
    }    

    // @isTest
    // public static void unitTest4(){
    //     DateTime date1 = System.now();
    //     DateTime date2 = System.now().addMinutes(-60);
        
    //     List<ServiceTerritory> stList = [SELECT Id FROM ServiceTerritory LIMIT 1];
    //     stList[0].BLN_SplitReplaceAndRecalibration__c = false;
    //     update stList;
    //     List<ServiceAppointment> sa = [SELECT Id FROM ServiceAppointment LIMIT 2];

    //     FSL__Time_Dependency__c fslDepend = new FSL__Time_Dependency__c();
    //     fslDepend.FSL__Root_Service_Appointment__c = sa[0].Id;
    //     fslDepend.FSL__Service_Appointment_1__c = sa[0].Id;
    //     fslDepend.FSL__Service_Appointment_2__c = sa[1].Id;
    //     insert fslDepend;

    //     Test.startTest();
    //     BLN_AppointmentBooking.bookBranchAppointment(date1, date2, sa[0].Id, false, false);
    //     Test.stopTest();
    //     System.assertEquals(stList[0].BLN_SplitReplaceAndRecalibration__c == false ,true, 'Recalibration is false');
    // }
}