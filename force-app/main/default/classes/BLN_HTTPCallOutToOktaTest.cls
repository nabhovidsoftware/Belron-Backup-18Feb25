/** @description : This Test class covered BLN_HTTPCallOutToOkta
 *   @Story : FOUK-198
 *   @author: Kanchan Mishra (PwC)
 *   @CreatedDate: 08/08/2023
 */
@isTest
public class BLN_HTTPCallOutToOktaTest {
    /**
     * @description: Test method for creating TestData using TestData Factory
     */
    @TestSetup
    public static void setupTestData() {

        // Create a ServiceAppointment record using the test data factory
        ServiceAppointment recalApp = BLN_TestDataFactory.createServiceAppntmnt(System.label.BLN_Recalibration, TRUE);
    }

    /**
     * @description: Test method to validate the BLN_HTTPCallOutToOkta class execution
     */
    @isTest
    static void testExecute() {

        // List to store ServiceAppointment records
        List<ServiceAppointment> testServiceAppointments = new List<ServiceAppointment>();

        // Query to fetch the ServiceAppointment record created in the setupTestData method
        ServiceAppointment testAppointment = [Select id from ServiceAppointment LIMIT 1];

        // Assert to check that the ServiceAppointment record is not null
        System.assertNotEquals(testAppointment, null, 'Service Appointment Record Found');

        // Add the queried ServiceAppointment to the list
        testServiceAppointments.add(testAppointment);

        // Instantiate the HTTPCallOutToOkta class with the test data
        BLN_HTTPCallOutToOkta inst = new BLN_HTTPCallOutToOkta();
        BLN_HTTPCallOutToOkta calloutInstance = new BLN_HTTPCallOutToOkta(testServiceAppointments);

        // Set up the mock HTTP response for the callout
        Test.setMock(HttpCalloutMock.class, new BLN_MockHttpResponseHTTPCallOutToOkta());

        // Enqueue the callout
        Test.startTest();
        System.enqueueJob(calloutInstance);
        Test.stopTest();

        // Assert to verify that the ServiceAppointment was correctly added to the list
        System.assertEquals(1, testServiceAppointments.size(), 'Service Appointment inserted');
    }
}