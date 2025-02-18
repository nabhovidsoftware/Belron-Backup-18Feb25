@IsTest
public class BLN_BookingErrorPlatformEventTest {

    @IsTest
    public static void testBookingError() {
        Id serviceAppointmentId = BLN_TestDataFactory.createServiceAppointment('test Appointment', true);
        List<ServiceAppointment> appointments = new List<ServiceAppointment>();
        appointments.add(new ServiceAppointment(id = serviceAppointmentId));

        Test.startTest();
        BLN_TaskCreateUpdateWebService.sendBookingErrorPlatformEvent(appointments);
        Test.stopTest();

        Assert.areEqual(true, [SELECT Id, BLN_IsBookingFailed__c FROM ServiceAppointment WHERE Id = :serviceAppointmentId][0].BLN_IsBookingFailed__c);
    }
}