@isTest  
public class BLN_QueueMDMGateWayTest {  
    @testSetup
    @TestVisible static void createTestAccount() {
        Account acc =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert acc;
       // return acc.Id;
    }
    
    @isTest  
    static void testBatchExecution() {  
        Account acc=[select id from account limit 1];
        String accountId = acc.Id;
        // Mock MDM parameters  
        BLN_MDMConfiguration.MDMParameters mdmParams = new BLN_MDMConfiguration.MDMParameters();  
        mdmParams.streamName = System.Label.BLN_ServiceStream;   
        mdmParams.sourceObject = 'Account';   
        mdmParams.fieldsToSync = new Map<String, Map<String, String>>{  
            accountId => new Map<String, String>{  
                'field1' => 'value1',  
                'field2' => 'value2',  
                'accountId' => accountId,  
                'Name' => 'Test Account'  
            }  
        };  
        mdmParams.eventType = 'Update';  
  
        // Initialize the batch class  
        BLN_QueueMDMGateWay batchClass = new BLN_QueueMDMGateWay(mdmParams);  
  
        // Start the test  
        Test.startTest();  
        // Execute the batch  
        Id batchJobId = Database.executeBatch(batchClass, 1);  // 
        Test.stopTest();  
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :batchJobId];  
       
        System.assertEquals('Completed', job.Status, 'The batch job should complete successfully');  
        System.assertEquals(0, job.NumberOfErrors, 'The batch job should not have errors');  
    }  
    
    @isTest  
    static void testBatchExecutionSales() {  
        Account acc=[select id from account limit 1];
        String accountId = acc.Id;
        // Mock MDM parameters  
        BLN_MDMConfiguration.MDMParameters mdmParams = new BLN_MDMConfiguration.MDMParameters();  
        mdmParams.streamName = System.Label.BLN_SalesStream;   
        mdmParams.sourceObject = 'Account';   
        mdmParams.fieldsToSync = new Map<String, Map<String, String>>{  
            accountId => new Map<String, String>{  
                'field1' => 'value1',  
                'field2' => 'value2',  
                'accountId' => accountId,  
                'Name' => 'Test Account'  
            }  
        };  
        mdmParams.eventType = 'Update';  
  
        // Initialize the batch class  
        BLN_QueueMDMGateWay batchClass = new BLN_QueueMDMGateWay(mdmParams);  
  
        // Start the test  
        Test.startTest();  
        // Execute the batch  
        Id batchJobId = Database.executeBatch(batchClass, 1);  // 
        Test.stopTest();  

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :batchJobId];  
        
        System.assertEquals('Completed', job.Status, 'The batch job should complete successfully');  
        System.assertEquals(0, job.NumberOfErrors, 'The batch job should not have errors');  
    }  
}