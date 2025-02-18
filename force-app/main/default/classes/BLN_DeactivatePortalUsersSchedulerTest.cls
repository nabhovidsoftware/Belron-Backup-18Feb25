@isTest
public class BLN_DeactivatePortalUsersSchedulerTest {

    @isTest
    static void testScheduler() {
        // Enqueue the job
        Test.startTest();
        BLN_DeactivatePortalUsersScheduler.scheduleJob();
        Test.stopTest();

        // Retrieve the scheduled job
        CronTrigger cronTrigger = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Batch'];
        
        // Validate that the job has been scheduled
        System.assertNotEquals(null, cronTrigger, 'Job not scheduled');
    }
}