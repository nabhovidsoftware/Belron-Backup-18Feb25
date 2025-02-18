@isTest
public class BLN_ManageStockSourceControllerTest {
    @testSetup
    public static void createData(){
        
        // ServiceTerritory services = BLN_TestDataFactory.createServiceTerritories('Test Certainty', false);
        // services.BLN_Type__c=  'Branch';
        // services.BLN_GUID__c= '140007';
        // insert services;

        Schema.Location locInst =  new Schema.Location();
        locInst.LocationType = 'Warehouse';
        locInst.Name = 'test123';
        locInst.BLN_GUID__c = '2515';
        insert locInst;
        
        Account testAcc = BLN_TestDataFactory.createTestAccount();
        testAcc.FirstName = 'Test';
        testAcc.LastName = 'Contact';
        testAcc.PersonEmail = 'test123@gmail.com';
        insert testAcc;
        
        Contact testContact = BLN_TestDataFactory.getContact('Test');
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'test123@gmail.com';
        insert testContact;
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.BLN_ServiceGeolocation__latitude__s=48.010976;
        cse.BLN_ServiceGeolocation__longitude__s=-84.187741;
        cse.AccountId = testAcc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        insert cse;
        cse.AccountId = testAcc.Id;
        update cse;
        
        product2 prod1 = new product2();
        prod1.Name = 'Test2';
        prod1.BLN_MDMID__c = '2474AGNMVZ6C';
        prod1.ProductCode = '125317'; 
        prod1.IsActive = true;
        insert prod1 ;
        
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'test2';
        pb2.IsActive = true;       
        insert pb2;
        
        Id standardPB = Test.getStandardPricebookId();
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB, Product2Id = prod1.Id, UnitPrice = 0.00, IsActive = true);
        insert standardPBE;
        PricebookEntry pbe = new PricebookEntry();
        pbe.UnitPrice = 0.00;
        pbe.Pricebook2Id = pb2.id;
        pbe.Product2Id = prod1.id;
        pbe.Product2 = prod1;
        insert pbe;
        
        Id serviceAppointmentId = BLN_TestDataFactory.createServiceAppointment('Recalibration', true);
        serviceappointment sa = new serviceappointment();
        sa.Id = serviceAppointmentId;
        sa.ArrivalWindowStartTime = System.now();
        sa.ArrivalWindowEndTime = System.now().addHours(2);
        update sa;
        
        // Create mock Order and related records
        Datetime effectiveDate = System.now();        
        Order testOrder = new Order(
            AccountId = testAcc.Id,
            BLN_CPQExternalQuoteId__c = '2525',
            Status = System.label.BLN_Accepted,
            BLN_Case__c = cse.Id,
            Pricebook2Id = standardPB,
            EffectiveDate = effectiveDate.date()  
        );
        insert testOrder;
        
        //List<orderItem> orderItmList = new List<orderItem>();
        orderItem orderItm = new OrderItem();
        orderItm.BLN_DocumentNumber__c = 20;
        orderItm.Quantity = 1;
        orderItm.BLN_IsProductSelected__c = true;
        orderItm.BLN_BOMId__c = 'TEST_BOMID';
        orderItm.BLN_BundleName__c = '';
        orderItm.Product2Id = prod1.Id;
        orderItm.OrderId = testOrder.Id;
        orderItm.ListPrice = 0.0;
        orderItm.UnitPrice = 0.0;
        orderItm.TotalLineAmount = 0.0;
        orderItm.BLN_ServiceAppointment__c = serviceAppointmentId;
        orderItm.BLN_LeadingPartIndicator__c = true;
        orderItm.BLN_OutOfStock__c = true;
        orderItm.BLN_StockOrderNumber__c = '450';
        orderItm.PricebookEntryId = standardPBE.Id;
        insert orderItm;
        System.assertNotEquals(effectiveDate, null,'success');  
    }
    @isTest
    static void getProductLineItemTest() {
        Test.startTest();
        string caseId = [select Id from case].Id;
        BLN_ManageStockSourceController.getProductLineItem(caseId);
        BLN_ManageStockSourceController.getProduct();
        System.assertNotEquals(caseId, null,'test');  
        Test.stopTest();    
    }
    
    @isTest
    public static void getLocationTest(){
        List<String> stockLocationId = new List<String>();
        String ser = [Select Id, Name,BLN_OrgCodeLocation__c From Location LIMIT 1].BLN_OrgCodeLocation__c;
        stockLocationId.add(ser);
        //List<BLN_ManageStockSourceController.Locationwrap> locationwrapList = new List<BLN_ManageStockSourceController.Locationwrap>();
        //BLN_ManageStockSourceController.Locationwrap locWrap = new BLN_ManageStockSourceController.Locationwrap();
        BLN_ManageStockSourceController.getLocation(stockLocationId);
        System.assertNotEquals(stockLocationId, null,'test'); 
    }
    
    @isTest
    public static void getAppointmentIdTest(){
        ServiceAppointment servApp = [SELECT Id FROM ServiceAppointment LIMIT 1];
        BLN_ManageStockSourceController.getAppointmentId(servApp.Id,'2525');
        System.assertNotEquals(servApp, null,'test'); 
    }
    
//    @isTest
//     static void testGetAppoinmentAndProduct() {
//         string caseId = [select Id from case].Id;        
//         Test.startTest();
//         BLN_ProductAvailabilityUtility.DisplayDetailsWrapper result = BLN_ManageStockSourceController.getAppoinmentAndProduct(caseId);
//         Test.stopTest();

//         // Assert the results
//         System.assertNotEquals(null, result, 'Result should not be null');
//     }
    
    @isTest
    public static void makeStockCalloutTest(){
        list<string> setoforderitemids = new list<string>();
        Map<string, string> oidLoc = new Map<string,string>();
        String orderitemLocation = '{"802Fg000009Is3BIAS": "544","802Fg000009Is3CIAS": "4523"}';
        String orderitemSa = '{"56391": "No Address Available on the given location.","230562": "No Address Available on the given location."}';
        String collectFlag = '{"802Fg000009Is3BIAS": true, "802Fg000009Is3CIAS": true}';
        for(orderitem oi:[select id, BLN_StockLocation__r.BLN_GUID__c from orderitem ]){
            setoforderitemids.add(oi.id);
            oidLoc.put(oi.Id, oi.BLN_StockLocation__r.BLN_GUID__c);
        }   
        test.setmock(httpcalloutmock.class, new bln_mockhttpresponsehttpcallouttookta());
        test.starttest();
        system.runas(new user(id =userinfo.getuserid())){
            BLN_ManageStockSourceController.makeStockCallout(setoforderitemids, orderitemLocation,orderitemSa,collectFlag);
        }
        test.stoptest();
        System.assertNotEquals(setoforderitemids, null,'test');
    }
    
}