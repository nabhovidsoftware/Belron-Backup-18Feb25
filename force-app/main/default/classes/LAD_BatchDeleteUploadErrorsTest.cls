/* description :  LAD_BatchDeleteUploadErrorsTest
 				  This test class for LAD_BatchDeleteUploadErrors batch class used for record deletion. 	
	author:       (punam.patil@pwc.com (IN))
    Story:         FOUK-10117
    Create Date : 20/08/2024
*/

@isTest
public class LAD_BatchDeleteUploadErrorsTest {
     
        
        // Create test data
         private static void createTestData() {
        List<LAD_Upload_Error__c> errorsToInsert = new List<LAD_Upload_Error__c>();
        
        for (Integer i = 0; i < 10; i++) {
            errorsToInsert.add(new LAD_Upload_Error__c());
        }
        
        insert errorsToInsert;
             
             // Adjust CreatedDate using Test.loadData or by using another workaround
      
        List<LAD_Upload_Error__c> errorsToUpdate = [SELECT Id FROM LAD_Upload_Error__c ];
        for (LAD_Upload_Error__c error : errorsToUpdate) {
        
        Test.setCreatedDate(error.Id, Date.today().addYears(-2));
		
        }
        update errorsToUpdate;
         }
        
          @isTest
    static void LAD_BatchDeleteUploadErrorsTest() {
        // Verify the records are inserted
         createTestData();
        List<LAD_Upload_Error__c> insertedErrors = [SELECT Id FROM LAD_Upload_Error__c where createdDate < LAST_N_YEARS : 1];
        System.assertEquals(10, insertedErrors.size(), 'There should be 10 records before batch execution');
        
        // Execute the batch
        Test.startTest();
        LAD_BatchDeleteUploadErrors batch = new LAD_BatchDeleteUploadErrors();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify records are deleted
        List<LAD_Upload_Error__c> remainingErrors = [SELECT Id FROM LAD_Upload_Error__c];
        system.debug('errors'+remainingErrors);
        System.assertEquals(0, remainingErrors.size(), 'There should be no records left after batch execution');
    }
    
    @isTest
    static void testScheduleBatchDeleteUploadErrors() {
        // Setup test data
        createTestData();

        // Verify that records are created
        Test.startTest();
       
        Integer cartCountBefore = [SELECT count() FROM LAD_Upload_Error__c where createdDate < LAST_N_YEARS : 1];
        System.assertEquals(10, cartCountBefore);
        
        
        // Schedule the batch job
        String cronExp = '0 0 0 1/2 * ? *';
        LAD_ScheduleBatchDeleteUploadErrors schedulableJob = new LAD_ScheduleBatchDeleteUploadErrors();
        System.schedule('TestBatchDeleteInactiveCartsEvery48Hours', cronExp, schedulableJob);
        Test.stopTest();

        // Verify that the scheduled job exists
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'TestBatchDeleteInactiveCartsEvery48Hours'];
        System.assertEquals(cronExp, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }

}