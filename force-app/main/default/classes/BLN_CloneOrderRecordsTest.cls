/**
 * @description : Test class for BLN_CloneOrderRecords.
 * @author : PwC-India
 * @createdDate : 06/06/2024
 */
@isTest
public class BLN_CloneOrderRecordsTest {
    
    /**
     * @description : Sets up common test data for the test methods.
     */
    @TestSetup
    static void setupTestData() {
        // Create a test Account
        //String name = 'Test' + (Math.random() * 1000);
         Account acc =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert acc;
        
        // Create related test data using the factory methods
        Contract contractObj = BLN_TestDataFactory.createTestContract(acc);
        Case caseObj = BLN_TestDataFactory.createCase(true);
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        insert prod;
        
        PricebookEntry priceEntry = new PricebookEntry();
        priceEntry.IsActive = true;
        priceEntry.UnitPrice = 0;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        priceEntry.Product2Id = prod.Id;
        insert priceEntry;
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(acc, contractObj, caseObj);
        orderObj.Pricebook2Id = priceEntry.Pricebook2Id;
        insert orderObj;
        
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.ListPrice = 0;
        orderItem.PricebookEntryId = priceEntry.Id;
        insert orderItem;
    }
    
    /**
     * @description : Tests the cloneOrderRecords method.
     */
    @isTest
    static void testCloneRecords(){ 
        // Fetch the created Order
        Order orderObj = [SELECT Id FROM Order LIMIT 1];
        
        List<List<Id>> orderList = new List<List<Id>>();
        List<Id> orderID = new List<Id>();
        orderID.add(orderObj.Id);
        orderList.add(orderID);
        
        Test.startTest();
        // Invoke the method to test
        BLN_CloneOrderRecords.cloneOrderRecords(orderList);
        Test.stopTest();
        
        // Verify the number of orders in the system
        List<Order> finalOrderList = [SELECT Id FROM Order];
        System.assertEquals(2, finalOrderList.size(), 'There should be exactly 2 orders after cloning.');
        
        //  assertions to verify the correct data cloning
        Order clonedOrder = [SELECT Id FROM Order WHERE Id != :orderObj.Id LIMIT 1];
        System.assertNotEquals(orderObj.Id, clonedOrder.Id, 'The cloned order should have a different Id.');
        
    }
}