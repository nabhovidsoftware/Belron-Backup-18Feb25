/*  description :   This is Test class for LAD_BatchDeleteInactiveCarts class
    author:         (punam.patil@pwc.com (IN))
    Story:          FOUK-8504
*/

@isTest
public class LAD_BatchDeleteInactiveCartsTest {
    
    // Helper method to create test data
    private static void createTestData() {
         Account acc = new Account(Name='Test', CurrencyIsoCode='');
        insert acc;
         WebStore store= new WebStore(Name='Test');
        insert store;
        
       /* List<WebCart> testCarts = new List<WebCart>();
        for (Integer i = 0; i < 1; i++) {
            WebCart cart = new WebCart();
            cart.Name = 'Test Cart '+i;
            cart.AccountId=acc.id;
            cart.WebStoreId=store.id;
            cart.PoNumber='A-010'+i;
            cart.Status='Active';
            cart.Type='Cart';
           
            cart.CurrencyIsoCode='';
            
            testCarts.add(cart);
        }
       
        insert testCarts;*/
                
        WebCart newcart = new WebCart(Name = 'Test Cart', 
            AccountId=acc.id,
            WebStoreId=store.id,
            PoNumber='A-010',
            Status='Active',
            Type='Cart',           
            CurrencyIsoCode='');
        insert newcart;
        // Adjust CreatedDate using Test.loadData or by using another workaround
      
        List<WebCart> cartsToUpdate = [SELECT Id FROM WebCart WHERE Name = 'Test Cart'];
        for (WebCart cart : cartsToUpdate) {
        
        Test.setCreatedDate(cart.Id, Date.today().addDays(-2));
		
        }
        update cartsToUpdate;
       
    }

    @isTest
    static void testBatchDeleteInactiveCarts() {
        // Setup test data
        createTestData();

        // Verify that records are created
        Test.startTest();
        Integer cartCountBefore = [SELECT count() FROM WebCart WHERE CreatedDate < :Datetime.now().addHours(-48)];
        System.assertEquals(1, cartCountBefore);
        
        
        // Execute the batch job
         LAD_BatchDeleteInactiveCarts batchJob = new LAD_BatchDeleteInactiveCarts(false);
         ID batchJobId = Database.executeBatch(batchJob);
        Test.stopTest();

        // Verify that records are deleted
        Integer cartCount = [select  COUNT() from WebCart where CreatedDate < :Datetime.now().addHours(-48) AND WebStore.Name ='Test' AND Status !='Closed'];
        System.assertEquals(0, cartCount);
    }

    @isTest
    static void testScheduleBatchDeleteInactiveCarts() {
        // Setup test data
        createTestData();

        // Verify that records are created
        Test.startTest();
       
        Integer cartCountBefore = [SELECT count() FROM WebCart WHERE CreatedDate < :Datetime.now().addHours(-48)];
        System.assertEquals(1, cartCountBefore);
        
        
        // Schedule the batch job
        String cronExp = '0 0 0 1/2 * ? *';
        LAD_ScheduleBatchDeleteInactiveCarts schedulableJob = new LAD_ScheduleBatchDeleteInactiveCarts();
        System.schedule('TestBatchDeleteInactiveCartsEvery48Hours', cronExp, schedulableJob);
        Test.stopTest();

        // Verify that the scheduled job exists
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'TestBatchDeleteInactiveCartsEvery48Hours'];
        System.assertEquals(cronExp, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }

    @isTest
    static void testBatchWithNoRecords() {
        // Ensure no records are present
        Test.startTest();
        LAD_BatchDeleteInactiveCarts batchJob = new LAD_BatchDeleteInactiveCarts(false);
        Database.executeBatch(batchJob);
        Test.stopTest();

        // Verify that no records are processed
        // There is no direct assertion for no records found to delete, but you can assert no exceptions occurred
        System.assert(true); // If no exceptions were thrown, the test passes
    }
}