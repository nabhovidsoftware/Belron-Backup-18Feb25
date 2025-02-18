/**@description : Test Class for BLN_MuleCalloutFailureHelper
 * Created by gciesielsk001 
 * Created date 21/03/2024
 */

@IsTest
private class BLN_MuleCalloutFailureHelperTest {
    
    /*Description : Creating a records using testDataFactory for ServiceAppointment */
    @IsTest
    static void testSingleServiceAppointment() {
        Id serviceAppointmentId = BLN_TestDataFactory.createServiceAppointment('test Appointment', true);
        ServiceAppointment appointment = [SELECT Id, Status FROM ServiceAppointment WHERE Id = :serviceAppointmentId][0];
        appointment.Status = System.Label.BLN_ScheduledStatus;
        update appointment;
		// Start the test context.
        Test.startTest();
            BLN_MuleCalloutFailureHelper.addMuleCalloutFailure(appointment);
        // Stop the test context.
        Test.stopTest();
        Assert.areEqual(System.Label.BLN_ScheduledStatus, [SELECT Id, Status, BLN_MuleCalloutFailedInStatus__c FROM ServiceAppointment WHERE Id = :serviceAppointmentId][0].BLN_MuleCalloutFailedInStatus__c,'Success');
    }

    @IsTest
    /*Description : Creating a records using testDataFactory for ServiceAppointment */
    static void testListServiceAppointment() {
        Id serviceAppointmentId = BLN_TestDataFactory.createServiceAppointment('test Appointment', true);
        List<ServiceAppointment> appointment = [SELECT Id, Status FROM ServiceAppointment WHERE Id = :serviceAppointmentId];
        appointment[0].Status = System.Label.BLN_ScheduledStatus;
        update appointment;
		// Start the test context.
        Test.startTest();
        BLN_MuleCalloutFailureHelper.addMuleCalloutFailure(appointment);
        // Stop the test context.
        Test.stopTest();
        Assert.areEqual(System.Label.BLN_ScheduledStatus, [SELECT Id, Status, BLN_MuleCalloutFailedInStatus__c FROM ServiceAppointment WHERE Id = :serviceAppointmentId][0].BLN_MuleCalloutFailedInStatus__c, 'Success');
    }

    @IsTest
    /*Description : Creating a records using testDataFactory for ServiceAppointment */
    static void testJSONListServiceAppointment() {
        Id serviceAppointmentId = BLN_TestDataFactory.createServiceAppointment('test Appointment', true);
        List<ServiceAppointment> appointment = [SELECT Id, Status FROM ServiceAppointment WHERE Id = :serviceAppointmentId];
        appointment[0].Status = System.Label.BLN_ScheduledStatus;
        update appointment;
        String json = JSON.serialize(appointment);
		// Start the test context.
        Test.startTest();
        BLN_MuleCalloutFailureHelper.addMuleCalloutFailure(json);
        // Stop the test context.
        Test.stopTest();
        Assert.areEqual(System.Label.BLN_ScheduledStatus, [SELECT Id, Status, BLN_MuleCalloutFailedInStatus__c FROM ServiceAppointment WHERE Id = :serviceAppointmentId][0].BLN_MuleCalloutFailedInStatus__c, 'Success');
    }

    @IsTest
    /*Description : Creating a records using testDataFactory for ServiceAppointment */
    static void testJSONListServiceAppointmentSuccess() {
        Id serviceAppointmentId = BLN_TestDataFactory.createServiceAppointment('test Appointment', true);
        List<ServiceAppointment> appointment = [SELECT Id, Status FROM ServiceAppointment WHERE Id = :serviceAppointmentId];
        appointment[0].Status = System.Label.BLN_ScheduledStatus;
        update appointment;
        String json = JSON.serialize(appointment);
		// Start the test context.
        Test.startTest();
        BLN_MuleCalloutFailureHelper.MuleCalloutSuccess(json);
        // Start the test context.
        Test.stopTest();
        Assert.areEqual(null, [SELECT Id, Status, BLN_MuleCalloutFailedInStatus__c FROM ServiceAppointment WHERE Id = :serviceAppointmentId][0].BLN_MuleCalloutFailedInStatus__c, 'Success');
    }
    
    @isTest
    static void testMuleCalloutSuccess() {
        // Step 1: Create test data - create a few ServiceAppointment records
        Id serviceAppointmentId = BLN_TestDataFactory.createServiceAppointment('Test Appointment', true);
        List<ServiceAppointment> appointment = [SELECT Id, Status FROM ServiceAppointment WHERE Id = :serviceAppointmentId];
        appointment[0].Status = System.Label.BLN_ScheduledStatus;
        update appointment;
        
		// Step 2: Call the method with the created ServiceAppointments
        Test.startTest();
        BLN_MuleCalloutFailureHelper.muleCalloutSuccess(appointment);
        Test.stopTest();

        // Step 3: Verify the behavior
        // Query the ServiceAppointment records after the update
        List<ServiceAppointment> updatedAppointments = [SELECT Id, BLN_MuleCalloutFailed__c, BLN_MuleCalloutFailedInStatus__c FROM ServiceAppointment WHERE Id IN :appointment];
		// Assert that the field BLN_MuleCalloutFailed__c is set to false
        for (ServiceAppointment updatedSa : updatedAppointments) {
            System.assertEquals(false, updatedSa.BLN_MuleCalloutFailed__c, 'BLN_MuleCalloutFailed__c should be false');
            System.assertNotEquals('', updatedSa.BLN_MuleCalloutFailedInStatus__c, 'BLN_MuleCalloutFailedInStatus__c should be an empty string');
        }
    }
}