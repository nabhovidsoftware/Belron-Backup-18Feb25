/**@description : This is the Apex Test Class for BLN_QuotesAndStocksAPICallout
*  @author: PwC India
*  @CreatedDate: 28/05/2024
*/
@isTest
public class BLN_StockReservationControllerTest {

    private class MockResponseGenerator implements HttpCalloutMock {
        public Boolean err = false;
        public HTTPResponse respond(HTTPRequest req) {
            String jsonRes = '';
            if(err)
            {
                jsonRes =		'{'+
                '    "status": "success",'+
                '    "items": ['+
                '        {'+
                '            "lineId": "1234",'+
                '            "returnedQuantity": "2",'+
                '            "errorCode": "000000"'+
                '        }'+
                '    ]'+
                '}';
            }
            else {
                jsonRes =		'{'+
                '    "status": "success",'+
                '    "items": ['+
                '        {'+
                '            "lineId": "1234",'+
                '            "returnedQuantity": "2",'+
                '            "errorCode": "100019"'+
                '        }'+
                '    ]'+
                '}';
            }
            // String contentType = 'application/x-www-form-urlencoded';
            if(req.getEndpoint() == 'callout:BLN_OktaAuthToken'){
                HttpResponse response = new HttpResponse();
                response.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"MockAccessToken123","scope":"read"}');
                response.setStatusCode(200);
                return response;      
            }else {
                HttpResponse response = new HttpResponse();
                response.setBody(jsonRes);
                response.setStatusCode(200);
                return response; 
            }
        }
    }

    @isTest
    static void reserveStockCalloutTest() {
        String name = 'Test'+(Math.random() * 1000);
        Account acc = new Account(name = name);
        insert acc;
        Contract contractObj = BLN_TestDataFactory.createTestContract(acc);
        Case caseObj = BLN_TestDataFactory.createCase(true);
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_ProductStockable__c = true;
        prod.BLN_MDMID__c = String.valueof(Math.random() * 100000);
        insert prod;
        
        Id sAppointment = BLN_TestDataFactory.createServiceAppointment(name, true);
        
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(acc, contractObj, caseObj);
        insert orderObj;
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.ListPrice = 5;
        orderItem.BLN_StockOrderNumber__c = '876432';
        orderItem.BLN_ServiceAppointment__c = sAppointment;
        orderItem.BLN_StockLineNumber__c = '1234';
        orderItem.BLN_StockStatus__c = 'Cancellation';
        orderItem.Quantity = 3;
        
        insert orderItem;

        OrderItem orderItem1 = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem1.ListPrice = 5;
        orderItem1.BLN_StockOrderNumber__c = '876432';
        orderItem1.BLN_StockLineNumber__c = '1234';
        orderItem1.BLN_ServiceAppointment__c = sAppointment;
        orderItem1.Quantity = 3;
        insert orderItem1;

        List<Id> testOrderItemIds = new List<Id>();
        testOrderItemIds.add(orderItem1.Id);
        testOrderItemIds.add(orderItem.Id);
        
        List<List<Id>> testOrderItemList = new List<List<Id>>();
        testOrderItemList.add(testOrderItemIds);
        
        Test.setMock(HttpCalloutMock.class, new BLN_ReserveCptStockMock());
        Test.startTest();
        //BLN_StockReservationController.reserveStockCallout(testOrderItemIds);
        BLN_StockReservationController.stockMovementCallout(testOrderItemIds);
        BLN_StockReservationController.cancelOrderItem(testOrderItemList);
        BLN_StockReservationController.cancelStockCallout(testOrderItemIds);
        BLN_StockReservationController.cancelStockCallout(new List<Id>());
        // BLN_StockReservationController.rebookStocksCallout(caseObj.Id);
        Test.stopTest();
        List<Order> finalOrder = [Select id from order];
        System.assertEquals(1,finalOrder.size(), 'There should only be 1 orders');
    }
    
    @isTest
    static void reserveStockCalloutTest2() {
        String name = 'Test'+(Math.random() * 1000);
        Account acc = new Account(name = name);
        insert acc;
        Contract contractObj = BLN_TestDataFactory.createTestContract(acc);
        Case caseObj = BLN_TestDataFactory.createCase(true);
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_ProductStockable__c = true;
        prod.BLN_MDMID__c = String.valueof(Math.random() * 100000);
        insert prod;
        
        Id sAppointment = BLN_TestDataFactory.createServiceAppointment(name, true);
        
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(acc, contractObj, caseObj);
        insert orderObj;
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.ListPrice = 5;
        orderItem.BLN_StockOrderNumber__c = '876432';
        orderItem.BLN_ServiceAppointment__c = sAppointment;
        orderItem.BLN_StockLineNumber__c = '1234';
        orderItem.BLN_StockStatus__c = 'Cancellation';
        orderItem.Quantity = 3;
        orderItem.BLN_OutOfStock__c = true;
        insert orderItem;

        OrderItem orderItem1 = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem1.ListPrice = 5;
        orderItem1.BLN_StockOrderNumber__c = '876432';
        orderItem1.BLN_StockLineNumber__c = '1234';
        orderItem1.BLN_ServiceAppointment__c = sAppointment;
        orderItem1.Quantity = 3;
        orderItem1.BLN_OutOfStock__c = true;
        insert orderItem1;

        List<Id> testOrderItemIds = new List<Id>();
        testOrderItemIds.add(orderItem1.Id);
        testOrderItemIds.add(orderItem.Id);
        
        List<List<Id>> testOrderItemList = new List<List<Id>>();
        testOrderItemList.add(testOrderItemIds);
        
        Test.setMock(HttpCalloutMock.class, new BLN_ReserveCptStockMock());
        Test.startTest();
        //BLN_StockReservationController.reserveStockCallout(testOrderItemIds);
        BLN_StockReservationController.stockMovementCallout(testOrderItemIds);
        BLN_StockReservationController.cancelOrderItem(testOrderItemList);
        BLN_StockReservationController.cancelStockCallout(testOrderItemIds);
        BLN_StockReservationController.cancelStockCallout(new List<Id>());
        // BLN_StockReservationController.rebookStocksCallout(caseObj.Id);
        Test.stopTest();
        List<Order> finalOrder = [Select id from order];
        System.assertEquals(1,finalOrder.size(), 'There should only be 1 orders');
    }
    
    @isTest
    static void cancelStockCalloutTest() {
        String name = 'Test'+(Math.random() * 1000);
        Account acc = new Account(name = name);
        insert acc;
        Contract contractObj = BLN_TestDataFactory.createTestContract(acc);
        Case caseObj = BLN_TestDataFactory.createCase(true);
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_ProductStockable__c = true;
        prod.BLN_MDMID__c = String.valueof(Math.random() * 100000);
        insert prod;
        
        Id sAppointment = BLN_TestDataFactory.createServiceAppointment(name, true);
        
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(acc, contractObj, caseObj);
        insert orderObj;
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.ListPrice = 5;
        orderItem.BLN_StockOrderNumber__c = '876432';
        orderItem.BLN_ServiceAppointment__c = sAppointment;
        orderItem.BLN_StockLineNumber__c = '1234';
        orderItem.Quantity = 3;
        
        insert orderItem;

        OrderItem orderItem1 = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem1.ListPrice = 5;
        orderItem1.BLN_StockOrderNumber__c = '876432';
        orderItem1.BLN_StockLineNumber__c = '1234';
        orderItem1.BLN_ServiceAppointment__c = sAppointment;
        orderItem1.Quantity = 3;
        insert orderItem1;

        List<Id> testOrderItemIds = new List<Id>();
        testOrderItemIds.add(orderItem1.Id);
        testOrderItemIds.add(orderItem.Id);
        
        Test.setMock(HttpCalloutMock.class, new BLN_ReserveCptStockMock());
        Test.startTest();
        BLN_StockReservationController.cancelStockCallout(testOrderItemIds);
        BLN_StockReservationController.cancelStockCallout(null);
        Test.stopTest();
        List<Order> finalOrder = [Select id from order];
        System.assertEquals(1,finalOrder.size(), 'There should only be 1 orders');
    }
    
    @isTest
    static void reserveStockCaseCalloutTest() {
        String name = 'Test'+(Math.random() * 1000);
        Account acc = new Account(name = name);
        insert acc;
        Contract contractObj = BLN_TestDataFactory.createTestContract(acc);
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_SpecialVehicle__c = false;
        insert veh;
        Case caseObj = BLN_TestDataFactory.createCase(true);
        caseObj.BLN_Vehicle__c = veh.id;
        update caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_ProductStockable__c = true;
        prod.BLN_MDMID__c = String.valueof(Math.random() * 100000);
        insert prod;
        
        Id sAppointment = BLN_TestDataFactory.createServiceAppointment(name, true);
        
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(acc, contractObj, caseObj);
        insert orderObj;
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.ListPrice = 5;
        orderItem.BLN_StockOrderNumber__c = '876432';
        orderItem.BLN_ServiceAppointment__c = sAppointment;
        orderItem.BLN_StockLineNumber__c = '1234';
        orderItem.Quantity = 3;
        
        insert orderItem;

        OrderItem orderItem1 = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem1.ListPrice = 5;
        orderItem1.BLN_StockOrderNumber__c = '876432';
        orderItem1.BLN_StockLineNumber__c = '1234';
        orderItem1.BLN_ServiceAppointment__c = sAppointment;
        orderItem1.Quantity = 3;
        insert orderItem1;

        List<Id> testOrderItemIds = new List<Id>();
        testOrderItemIds.add(orderItem1.Id);
        testOrderItemIds.add(orderItem.Id);
        
        List<List<Id>> testOrderItemList = new List<List<Id>>();
        testOrderItemList.add(testOrderItemIds);
        
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        Test.startTest();
        BLN_StockReservationController.reserveStockCallout(testOrderItemIds);
        BLN_StockReservationController.cancelStockCallout(new List<Id>());
        // BLN_StockReservationController.stockMovementCallout(testOrderItemIds);
        // BLN_StockReservationController.cancelOrderItem(testOrderItemList);
        Test.stopTest();
        List<Order> finalOrder = [Select id from order];
        System.assertEquals(1,finalOrder.size(), 'There should only be 1 orders');
    }
    
    @isTest
    static void reserveStockCaseErrTest() {
        String name = 'Test'+(Math.random() * 1000);
        Account acc = new Account(name = name);
        insert acc;
        Contract contractObj = BLN_TestDataFactory.createTestContract(acc);
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_SpecialVehicle__c = false;
        insert veh;
        Case caseObj = BLN_TestDataFactory.createCase(true);
        caseObj.BLN_Vehicle__c = veh.id;
        update caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_ProductStockable__c = true;
        prod.BLN_MDMID__c = String.valueof(Math.random() * 100000);
        insert prod;
        
        Id sAppointment = BLN_TestDataFactory.createServiceAppointment(name, true);
        
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(acc, contractObj, caseObj);
        insert orderObj;
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.ListPrice = 5;
        orderItem.BLN_StockOrderNumber__c = '876432';
        orderItem.BLN_ServiceAppointment__c = sAppointment;
        orderItem.BLN_StockLineNumber__c = '1234';
        orderItem.Quantity = 3;
        
        insert orderItem;

        OrderItem orderItem1 = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem1.ListPrice = 5;
        orderItem1.BLN_StockOrderNumber__c = '876433';
        orderItem1.BLN_StockLineNumber__c = '1234';
        orderItem1.BLN_ServiceAppointment__c = sAppointment;
        orderItem1.Quantity = 3;
        insert orderItem1;

        List<Id> testOrderItemIds = new List<Id>();
        testOrderItemIds.add(orderItem1.Id);
        testOrderItemIds.add(orderItem.Id);
        
        List<List<Id>> testOrderItemList = new List<List<Id>>();
        testOrderItemList.add(testOrderItemIds);
        
        MockResponseGenerator mock = new MockResponseGenerator();
        mock.err = true;
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        BLN_StockReservationController.reserveStockCallout(testOrderItemIds);
        BLN_StockReservationController.cancelStockCallout(new List<Id>());
        // BLN_StockReservationController.stockMovementCallout(testOrderItemIds);
        // BLN_StockReservationController.cancelOrderItem(testOrderItemList);
        Test.stopTest();
        List<Order> finalOrder = [Select id from order];
        System.assertEquals(1,finalOrder.size(), 'There should only be 1 orders');
    }

    @isTest
    static void reserveStockSpecialCaseCalloutTest() {
        String name = 'Test'+(Math.random() * 1000);
        Account acc = new Account(name = name);
        insert acc;
        Contract contractObj = BLN_TestDataFactory.createTestContract(acc);
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_SpecialVehicle__c = true;
        insert veh;
        Case caseObj = BLN_TestDataFactory.createCase(true);
        caseObj.BLN_Vehicle__c = veh.id;
        update caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_ProductStockable__c = true;
        prod.BLN_MDMID__c = String.valueof(Math.random() * 100000);
        insert prod;
        
        Id sAppointment = BLN_TestDataFactory.createServiceAppointment(name, true);
        
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(acc, contractObj, caseObj);
        insert orderObj;
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.ListPrice = 5;
        orderItem.BLN_StockOrderNumber__c = '876432';
        orderItem.BLN_ServiceAppointment__c = sAppointment;
        orderItem.BLN_StockLineNumber__c = '1234';
        orderItem.Quantity = 3;
        
        insert orderItem;

        OrderItem orderItem1 = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem1.ListPrice = 5;
        orderItem1.BLN_StockOrderNumber__c = '876432';
        orderItem1.BLN_StockLineNumber__c = '1234';
        orderItem1.BLN_ServiceAppointment__c = sAppointment;
        orderItem1.Quantity = 3;
        insert orderItem1;

        List<Id> testOrderItemIds = new List<Id>();
        testOrderItemIds.add(orderItem1.Id);
        testOrderItemIds.add(orderItem.Id);
        
        List<List<Id>> testOrderItemList = new List<List<Id>>();
        testOrderItemList.add(testOrderItemIds);
        
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        Test.startTest();
        BLN_StockReservationController.reserveStockCallout(testOrderItemIds);
        BLN_StockReservationController.rebookStocksCalloutAsync(null, null, null);
        // BLN_StockReservationController.stockMovementCallout(testOrderItemIds);
        // BLN_StockReservationController.cancelOrderItem(testOrderItemList);
        Test.stopTest();
        List<Order> finalOrder = [Select id from order];
        System.assertEquals(1,finalOrder.size(), 'There should only be 1 orders');
    }
    
    @isTest
    static void reserveStockCalloutSpecialTest() {
        String name = 'Test'+(Math.random() * 1000);
        Account acc = new Account(name = name);
        insert acc;
        Contract contractObj = BLN_TestDataFactory.createTestContract(acc);
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_SpecialVehicle__c = true;
        insert veh;
        Case caseObj = BLN_TestDataFactory.createCase(true);
        caseObj.BLN_Vehicle__c = veh.id;
        update caseObj;
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_ProductStockable__c = true;
        prod.BLN_MDMID__c = String.valueof(Math.random() * 100000);
        insert prod;
        
        Id sAppointment = BLN_TestDataFactory.createServiceAppointment(name, true);
        
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(acc, contractObj, caseObj);
        insert orderObj;
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.ListPrice = 5;
        orderItem.BLN_StockOrderNumber__c = '876432';
        orderItem.BLN_ServiceAppointment__c = sAppointment;
        orderItem.BLN_StockLineNumber__c = '1234';
        orderItem.Quantity = 3;
        
        insert orderItem;

        OrderItem orderItem1 = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem1.ListPrice = 5;
        orderItem1.BLN_StockOrderNumber__c = '876432';
        orderItem1.BLN_StockLineNumber__c = '1234';
        orderItem1.BLN_ServiceAppointment__c = sAppointment;
        orderItem1.Quantity = 3;
        insert orderItem1;

        List<Id> testOrderItemIds = new List<Id>();
        testOrderItemIds.add(orderItem1.Id);
        testOrderItemIds.add(orderItem.Id);
        
        List<List<Id>> testOrderItemList = new List<List<Id>>();
        testOrderItemList.add(testOrderItemIds);
        
        Test.setMock(HttpCalloutMock.class, new BLN_ReserveCptStockMock());
        Test.startTest();
        //BLN_StockReservationController.reserveStockCallout(testOrderItemIds);
        BLN_StockReservationController.stockMovementCallout(testOrderItemIds);
        BLN_StockReservationController.cancelOrderItem(testOrderItemList);
        Test.stopTest();
        List<Order> finalOrder = [Select id from order];
        System.assertEquals(1,finalOrder.size(), 'There should only be 1 orders');
    }

    @isTest
    static void rebookStockCalloutTest() {
        String name = 'Test'+(Math.random() * 1000);
        // String name2 = 'Test'+(Math.random() * 1000);
        Account acc = new Account(name = name);
        insert acc;
        Contract contractObj = BLN_TestDataFactory.createTestContract(acc);
        Case caseObj = BLN_TestDataFactory.createCase(true);
        caseObj.BLN_SubType__c = 'ISP';
        update caseObj;
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_ProductStockable__c = true;
        prod.BLN_MDMID__c = String.valueof(Math.random() * 100000);
        insert prod;
        
        List<ServiceAppointment> sAppointment = BLN_TestDataFactory.creatSARecords(name, true);
        //Id sAppointment2 = BLN_TestDataFactory.createServiceAppointment(name2, true);
        
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(acc, contractObj, caseObj);
        orderObj.Status = 'Accepted';
        insert orderObj;

        Order orderObj2 = BLN_TestDataFactory.createTestOrder(acc, contractObj, caseObj);
        orderObj2.Status = 'Inactive';
        insert orderObj2;
        List<OrderItem> orderItemList = new List<OrderItem>();

        OrderItem orderItemCreate = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItemCreate.ListPrice = 5;
        orderItemCreate.BLN_StockOrderNumber__c = '87643231';
        orderItemCreate.BLN_ServiceAppointment__c = sAppointment[0].Id;
        orderItemCreate.BLN_StockLineNumber__c = '12341';
        orderItemCreate.BLN_StockStatus__c = 'Issue';
        orderItemCreate.Quantity = 3;
        orderItemCreate.BLN_DocumentNumber__c = 1;
        orderItemCreate.BLN_IsProductSelected__c = true;
        // orderItemCreate.BLN_PriceNotFound__c = true;
        orderItemList.add(orderItemCreate);

        OrderItem orderItem0 = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem0.ListPrice = 5;
        orderItem0.BLN_StockOrderNumber__c = '876437';
        orderItem0.BLN_ServiceAppointment__c = sAppointment[0].Id;
        orderItem0.BLN_StockLineNumber__c = '12347';
        orderItem0.BLN_StockStatus__c = 'Issue';
        orderItem0.Quantity = 3;
        orderItem0.BLN_DocumentNumber__c = 7;
        orderItem0.BLN_IsProductSelected__c = true;
        // orderItem0.BLN_PriceNotFound__c = true;
        orderItemList.add(orderItem0);

        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.ListPrice = 5;
        orderItem.BLN_StockOrderNumber__c = '8764323';
        orderItem.BLN_ServiceAppointment__c = sAppointment[0].Id;
        orderItem.BLN_StockLineNumber__c = '1234';
        orderItem.BLN_StockStatus__c = 'Issue';
        orderItem.Quantity = 3;
        orderItem.BLN_DocumentNumber__c = 3;
        orderItem.BLN_IsProductSelected__c = true;
        // orderItem.BLN_PriceNotFound__c = true;
        orderItemList.add(orderItem);
        // insert orderItem;

        OrderItem orderItem1 = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem1.ListPrice = 5;
        orderItem1.BLN_StockOrderNumber__c = '8764324';
        orderItem1.BLN_StockLineNumber__c = '12344';
        orderItem1.BLN_DocumentNumber__c = 4;
        orderItem1.BLN_ServiceAppointment__c = sAppointment[0].Id;
        orderItem1.Quantity = 3;
        orderItem1.BLN_StockStatus__c = 'Reserved';
        orderItem1.BLN_StockOrderAppointmentDate__c = System.now()+5;
        orderItem1.BLN_BranchThreshold__c = 1;
        orderItem1.BLN_IsProductSelected__c = true;
        // orderItem1.BLN_PriceNotFound__c = true;
        orderItemList.add(orderItem1);
        // insert orderItem1;

        OrderItem orderItem2 = BLN_TestDataFactory.createTestOrderItem(orderObj2, prod);
        orderItem2.ListPrice = 5;
        orderItem2.BLN_StockOrderNumber__c = '8764323';
        orderItem2.BLN_ServiceAppointment__c = sAppointment[1].Id;
        orderItem2.BLN_StockLineNumber__c = '1234';
        orderItem2.BLN_DocumentNumber__c = 3;
        orderItem2.BLN_StockStatus__c = 'Cancellation';
        orderItem2.Quantity = 3;
        orderItem2.BLN_IsProductSelected__c = true;
        // orderItem2.BLN_PriceNotFound__c = true;
        orderItemList.add(orderItem2);
        // insert orderItem2;

        OrderItem orderItem3 = BLN_TestDataFactory.createTestOrderItem(orderObj2, prod);
        orderItem3.ListPrice = 5;
        orderItem3.BLN_StockOrderNumber__c = '8764324';
        orderItem3.BLN_StockLineNumber__c = '12344';
        orderItem3.BLN_DocumentNumber__c = 4;
        orderItem3.BLN_StockStatus__c = 'Reserved';
        orderItem3.BLN_StockOrderAppointmentDate__c = System.now();
        orderItem3.BLN_BranchThreshold__c = 1;
        orderItem3.BLN_ServiceAppointment__c = sAppointment[1].Id;
        orderItem3.Quantity = 3;
        orderItem3.BLN_IsProductSelected__c = true;
        // orderItem3.BLN_PriceNotFound__c = true;
        orderItemList.add(orderItem3);
        // insert orderItem3;

        OrderItem orderItemDelete = BLN_TestDataFactory.createTestOrderItem(orderObj2, prod);
        orderItemDelete.ListPrice = 5;
        orderItemDelete.BLN_StockOrderNumber__c = '87643249';
        orderItemDelete.BLN_StockLineNumber__c = '12342';
        orderItemDelete.BLN_DocumentNumber__c = 2;
        orderItemDelete.BLN_ServiceAppointment__c = sAppointment[1].Id;
        orderItemDelete.Quantity = 3;
        orderItemDelete.BLN_IsProductSelected__c = true;
        // orderItemDelete.BLN_PriceNotFound__c = true;
        orderItemList.add(orderItemDelete);

        OrderItem orderItem7 = BLN_TestDataFactory.createTestOrderItem(orderObj2, prod);
        orderItem7.ListPrice = 5;
        orderItem7.BLN_StockOrderNumber__c = '876437';
        orderItem7.BLN_StockLineNumber__c = '12347';
        orderItem7.BLN_DocumentNumber__c = 7;
        orderItem7.BLN_ServiceAppointment__c = sAppointment[0].Id;
        orderItem7.Quantity = 3;
        orderItem7.BLN_IsProductSelected__c = true;
        // orderItem7.BLN_PriceNotFound__c = true;
        orderItemList.add(orderItem7);



        insert orderItemList;
        
        Test.setMock(HttpCalloutMock.class, new BLN_ReserveCptStockMock());
        Test.startTest();
        BLN_StockReservationController.rebookStocksCallout(caseObj.Id);
        BLN_StockReservationController.rebookStocksCallout(null);
        System.enqueueJob(new BLN_StockRebookQueuable(caseObj.Id));
        Test.stopTest();
        List<Order> finalOrder = [Select id from order];
        System.assertEquals(2,finalOrder.size(), 'There should only be 2 orders');
    }
}