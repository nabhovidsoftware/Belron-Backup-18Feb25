/**@description : The Apex class Generate file name
*  @author: Wasim Akram
*  @Story: FOUK-4520
*  @CreatedDate: 30/01/2024
*/
@isTest
public class BLN_ImageCaptureTest {
    /* @description: This is a test setup method to provide required data for test methods.
    *  This setup will call before execution of every test method.
    */
    @testSetup
    public static void testSetup(){

        // Creating a WorkType, Service Territory, OperatingHours, WorkOrder, ServiceAppointment using a Test Data Factory
        WorkType worktype = BLN_TestDataFactory.createWorkType('Stock Collect', 11.00, true, true);
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Test op',true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('Test Territory',opertatingHr.id,'United Kingdom',true);
        WorkOrder workOrd = BLN_TestDataFactory.createWorkOrder2(worktype.Id, serviceTerritory.Id, true);
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = '6565653';
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrd.id;
        insert wOLI;
        ServiceAppointment sa = BLN_TestDataFactory.createServiceAppointment('Test', wOLI.Id, serviceTerritory.Id, 'test', true);
        // Assert that the ServiceAppointment was created correctly
        System.assertNotEquals(sa, null, 'ServiceAppointment should not be null');
    }

     /**
    * @description: Unit test method for testing the BLN_ImageCapture class
    */
	@isTest
    public static void unitTest(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'User Should be available');
        }
        WorkOrderLineItem wOLI = [SELECT Id FROM WorkOrderLineItem LIMIT 1];
        System.assertNotEquals(wOLI, null, 'Service Appointment Record Found');
        ServiceAppointment serviceAppointments = [SELECT Id FROM ServiceAppointment LIMIT 1];
        System.assertNotEquals(serviceAppointments, null, 'Service Appointment Record Found');
        
        // Start Test Execution
        Test.startTest();
        BLN_ImageCapture.populateFileName(wOLI.Id);
        BLN_ImageCapture.checkSTRelease(wOLI.Id);
        BLN_ImageCapture.checkSTRelease(null);
        // Stop Test Execution
        Test.stopTest();
        System.assertNotEquals(null, wOLI.Id, 'Wrapper object should not be null');
        
    }
}