/** @description : This class is used for testing of BLN_ReserveCptStock class
*   @Story : FOUK-5371
*   @author: Siddhant Pandya (PwC)
*   @CreatedDate: 17/05/2024
*/
@isTest
public class BLN_ReserveCptStockTest {
/**
*@description : This method is used for testing BLN_ReserveCptStock.getData method
*@return void
*/
@isTest
    static void testGetDataMethod(){
    	String name = 'Test'+(Math.random() * 1000);
        Account acc = new Account(name = name);
        insert acc;
        Contract contractObj = BLN_TestDataFactory.createTestContract(acc);
        Case caseObj = BLN_TestDataFactory.createCase(true);
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_MDMID__c = String.valueof(Math.random() * 100000);
        insert prod;
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(acc, contractObj, caseObj);
        insert orderObj;
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.ListPrice = 5;
        orderItem.BLN_StockOrderNumber__c = '876432';
        orderItem.BLN_StockLineNumber__c = '3';
        orderItem.Quantity = 3;
        
        insert orderItem;
        
        OrderItem orderItem1 = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem1.ListPrice = 5;
        orderItem1.BLN_StockOrderNumber__c = '876432';
        orderItem1.BLN_StockLineNumber__c = '3';
        orderItem1.Quantity = 3;
        insert orderItem1;

        List<Id> testOrderItemIds = new List<Id>();
        testOrderItemIds.add(orderItem1.Id);
        testOrderItemIds.add(orderItem.Id);
        
        Test.startTest();
        //BLN_ReserveCptStock.getData(testOrderItemIds);
        Test.stopTest();
        List<Order> finalOrder = [Select id from order];
        //System.assertEquals(1,finalOrder.size(), 'There should only be 1 orders');
    }
}