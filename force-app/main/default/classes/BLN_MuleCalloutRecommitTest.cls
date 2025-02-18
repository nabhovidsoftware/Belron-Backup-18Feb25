/**
 * Created by gciesielsk001 on 19.12.2023.
 */

@IsTest
private class BLN_MuleCalloutRecommitTest {
    private static final String JOB_NAME = 'test job';
    @IsTest
    static void testBehavior() {
        ServiceAppointment serviceAppointment = BLN_TestDataFactory.createServiceAppointmentRecord('test Appointment', true);
        BLN_TestDataFactory.createCalloutSettings(true);

        serviceAppointment.Status = System.Label.BLN_ScheduledStatus;
        serviceAppointment.BLN_MuleCalloutFailed__c = true;
        serviceAppointment.BLN_MuleCalloutFailedInStatus__c = System.Label.BLN_DispatchedStatus;
        update serviceAppointment;
        serviceAppointment.Status = System.Label.BLN_DispatchedStatus;
        update serviceAppointment;

        Test.startTest();
            BLN_ServiceAppointmentCallout.mockoktaToken = 'Testing';
            BLN_ServiceAppointmentCallout.forTest = true;
            BLN_MuleCalloutRecommit recommit = new BLN_MuleCalloutRecommit();
            Database.executeBatch(recommit,1);
        Test.stopTest();
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE MethodName = 'BLN_HTTPCallOutToMuleSoft'];
        for(AsyncApexJob job: jobs) {
            Assert.areEqual(job.Status, 'Completed', 'Success');
        }
    }

    @IsTest
    static void testSchedule() {
        Test.starTTest();
        BLN_MuleCalloutRecommit batch = new BLN_MuleCalloutRecommit();
        String cron = '0 0 23 * * ?';
        System.schedule(JOB_NAME, cron, batch);
        Test.stopTest();
        CronTrigger cronTrigger = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = :JOB_NAME];
        Assert.isNotNull(cronTrigger, 'Not Null');
    }
}