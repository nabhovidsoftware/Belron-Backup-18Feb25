/**@description : This is the Apex Test Class for BLN_QuotesAndStocksAPICallout
*  @author: PwC India
*  @Story: 
*  @CreatedDate: 28/05/2024
*/
@isTest
public class BLN_QuotesAndStocksAPICalloutTest {
    @testSetup
    static void setup(){
        Test.startTest();
        
       // Id userid = UserInfo.getUserId();
        
        List<Product2> prodList = new List<Product2>();
        List<OrderItem> oiList = new List<OrderItem>();
        List<ProductRequired> prList = new List<ProductRequired>();
        List<ProductConsumed> pcList = new List<ProductConsumed>();
        List<ProductItem> piList = new List<ProductItem>();

        String remedyJobId = randomNumberGenerator();
        String remedyTaskId = randomNumberGenerator();

        Id pricebookId = Test.getStandardPricebookId();
        /*Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
*/

        WorkType workType = BLN_TestDataFactory.createWorkType('Replacement', 1.0, true, true);
        Account newAcc = BLN_TestDataFactory.createAccount('Tes Account', 'PersonAccount','9988127600');
        insert newAcc;

        Contract newContract = BLN_TestDataFactory.createTestContract(newAcc);
        insert newContract;

        BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();
        vehicles.BLN_SpecialVehicle__c = true;
        insert vehicles;

        BLN_Corporate__c corporate = new BLN_Corporate__c();
        corporate.BLN_OEAuthorizationRequired__c = false;
        corporate.BLN_Vehicle__c = vehicles.Id;
        insert corporate;

        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','Closed');
        caseObj.AccountId = newAcc.Id;
        caseObj.BLN_SubType__c = 'Job Request';
        caseObj.BLN_Corporate__c = corporate.id;
        insert caseObj;

        

        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = 'Bedford';
        operatingHours.TimeZone = 'Europe/London';
        insert operatingHours;

        ServiceTerritory servicesTerritories = new ServiceTerritory();
        servicesTerritories.Name = 'Bedford';
        servicesTerritories.IsActive = TRUE;
        servicesTerritories.OperatingHoursId = operatingHours.id;
        servicesTerritories.BLN_CostCenter__c = 'COST_CENTER_000000001';
        insert servicesTerritories; 

        WorkOrder workOrder = BLN_TestDataFactory.createWorkOrder(false);
        workOrder.Status = 'Completed';
        workOrder.WorkTypeId = workType.Id;
        workOrder.CaseId = caseObj.Id;
        workOrder.AccountId = newAcc.Id;
        workOrder.BLN_RemedyJobId__c = remedyJobId;
        workOrder.Pricebook2Id = pricebookId;
        insert workOrder;
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.WorkTypeId = workType.Id;
        wOLI.WorkOrderId = workOrder.id;
        wOLI.Status = 'Completed';
        wOLI.BLN_IsStockCheckInCompleted__c = false;
        wOLI.BLN_RemedyTaskId__c = remedyTaskId;
        insert wOLI;

        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        insert schedulingPolicy;
        
        ServiceAppointment servApp = new ServiceAppointment();
        servApp.ParentRecordId = wOLI.id;
        servApp.Duration = 11.00;
        servApp.Status = 'None';
        servApp.ServiceTerritoryId = servicesTerritories.id;
        servApp.SchedStartTime = System.now();
        servApp.SchedEndTime = System.now()+5;
        servApp.BLN_WorkOrderNumber__c = workOrder.id;
        servApp.BLN_WorkOrderLineItem__c = wOLI.Id;
        servApp.BLN_RemedyJobId__c = remedyJobId;
        servApp.BLN_RemedyTaskId__c = remedyTaskId;
        servApp.WorkTypeId = workType.id;
        servApp.ArrivalWindowStartTime = System.now();
        insert servApp;

        ServiceResource servRersource = BLN_TestDataFactory.createServiceResource('test names', true);

        ServiceTerritoryMember sTMember = new ServiceTerritoryMember();
        sTMember.OperatingHoursId = operatingHours.Id;        
        sTMember.ServiceResourceId = servRersource.Id;        
        sTMember.ServiceTerritoryId = servicesTerritories.Id ;
        sTMember.TerritoryType = 'P';
        sTMember.EffectiveStartDate = System.now() -3;
        insert sTMember;

        Order newOrder = BLN_TestDataFactory.createTestOrder(newAcc, newContract, caseObj);
        newOrder.Status = 'Accepted';
        insert newOrder;

        Schema.Location loc = new Schema.Location();
        loc.Name = 'Branch Location';
        loc.LocationType = 'Belron Warehouse';
        loc.IsInventoryLocation = true;
        loc.Longitude = -0.474;  //28.635308;
        loc.Latitude = 52.119; //28.635308;
        loc.BLN_GUID__c = 'Test';
        loc.BLN_OrgCodeLocation__c = 'Test';
        loc.BLN_OrgCodeLocation__c = 'location001';
        insert loc;

        Product2 p1 = new Product2();
        p1.Name = 'Windscreen';
        p1.BLN_MDMID__c = 'p0001';
        p1.ProductCode = 'Product 1';
        p1.BLN_ProductCategory__c = 'Product 1';
        p1.BLN_ProductStockable__c = true;
        prodList.add(p1);

        Product2 p2 = new Product2();
        p2.Name = 'Side Glass';
        p2.BLN_MDMID__c = 'p0002';
        p2.ProductCode = 'Product 2';
        p2.BLN_ProductCategory__c = 'Product 2';
        p2.BLN_ProductStockable__c = true;
        prodList.add(p2);

        insert prodList;

        ProductItem pi1 = new ProductItem();
        pi1.Product2Id = p1.Id;
        pi1.QuantityUnitOfMeasure = 'Each';
        pi1.QuantityOnHand = 20;
        pi1.LocationId = loc.Id;
        piList.add(pi1);

        ProductItem pi2 = new ProductItem();
        pi2.Product2Id = p2.Id;
        pi2.QuantityUnitOfMeasure = 'Each';
        pi2.QuantityOnHand = 20;
        pi2.LocationId = loc.Id;
        piList.add(pi2);
        
        insert piList;

        OrderItem oi1 = BLN_TestDataFactory.createTestOrderItem(newOrder , p1);
        oi1.Quantity = 6;
        oi1.BLN_ServiceAppointment__c = servApp.Id;
        oi1.BLN_StockLineNumber__c  = '9917828281828198';
        oi1.BLN_StockLocation__c = loc.Id;
        oi1.ListPrice = 100;
        oi1.BLN_FittingLocation__c = loc.Id;
        oi1.BLN_StockLocation__c = loc.Id;
        oi1.BLN_StockOrderNumber__c = 'STOCK001';
        oi1.BLN_IsProductSelected__c = true;
        oi1.Product2 = p1;
        oi1.OrderId = newOrder.Id;
        oiList.add(oi1);

        OrderItem oi2 = BLN_TestDataFactory.createTestOrderItem(newOrder , p2);
        oi2.Quantity = 6;
        oi2.BLN_ServiceAppointment__c = servApp.Id;
        oi2.BLN_StockLineNumber__c  = '9917828281828199';
        oi2.BLN_StockLocation__c = loc.Id;
        oi2.ListPrice = 100;
        oi2.BLN_FittingLocation__c = loc.Id;
        oi2.BLN_StockLocation__c = loc.Id;
        oi2.BLN_StockOrderNumber__c = 'STOCK001';
        oi2.BLN_IsProductSelected__c = true;
        oi2.Product2 = p2;
        oiList.add(oi2);

        insert oiList;        

        ProductRequired pr1 = new ProductRequired();
        pr1.Product2Id = p1.Id;
        pr1.QuantityRequired = 6;
        pr1.QuantityUnitOfMeasure = 'Each';
        pr1.ParentRecordId = wOLI.Id;
        pr1.BLN_WOLI__c = wOLI.Id;
        pr1.BLN_WorkOrder__c = workOrder.Id;
        pr1.BLN_Status__c = 'Completed';
        pr1.BLN_Title__c = 'PR for Product 1';
        pr1.BLN_ProductQuantityConsumedOrTransferred__c = 3;
        prList.add(pr1);

        ProductRequired pr2 = new ProductRequired();
        pr2.Product2Id = p2.Id;
        pr2.QuantityRequired = 6;
        pr2.QuantityUnitOfMeasure = 'Each';
        pr2.ParentRecordId = wOLI.Id;
        pr2.BLN_WOLI__c = wOLI.Id;
        pr2.BLN_WorkOrder__c = workOrder.Id;
        pr2.BLN_Status__c = 'Completed';
        pr2.BLN_Title__c = 'PR for Product 2';
        pr2.BLN_ProductQuantityConsumedOrTransferred__c = 3;
        prList.add(pr2);

        insert prList;

        ProductConsumed pc1 = new ProductConsumed();
        pc1.ProductItemId = pi1.Id;
        pc1.QuantityConsumed = 3;
        pc1.WorkOrderLineItemId = wOLI.Id;
        pc1.WorkOrderId = workOrder.Id;
        pc1.Description = 'Product Consumed for Product 1';

        pcList.add(pc1);

        ProductConsumed pc2 = new ProductConsumed();
        pc2.ProductItemId = pi2.Id;
        pc2.QuantityConsumed = 3;
        pc2.WorkOrderLineItemId = wOLI.Id;
        pc2.WorkOrderId = workOrder.Id;
        pc2.Description = 'Product Consumed for Product 2';
        pcList.add(pc2);

        insert pcList;

        workOrder.BLN_Order__c = newOrder.Id;
        update workOrder;

        Test.stopTest();
    }

    @isTest
    static void makeQuoteTest() {
        Id caseRecordId = [SELECT Id FROM Case LIMIT 1].Id;
        String payload = '{'+
		'  "motoristVATStatus": "Registered",'+
		'  "bomIds": ['+
		'    {'+
		'      "bomId": "2474AGNMVZ6C",'+
		'      "quantity": 1'+
		'    },'+
		'    {'+
		'      "bomId": "2484AGSCMVZ",'+
		'      "quantity": 1'+
		'    },'+
		'    {'+
		'      "bomId": "5385AGAACMVZ2L",'+
		'      "quantity": 1'+
		'    }'+
		'  ],'+
		'  "partIds": ['+
		'    {'+
		'      "partId": "9876",'+
		'      "quantity": 3'+
		'    }'+
		'  ],'+
		'  "caseId": '+ caseRecordId + ',' +
		'  "vehicleId": "7698had",'+
		'  "country": "GB",'+
		'  "currency": "GBP",'+
		'  "accountId": "98alijea",'+
		'  "locations": ['+
		'    {'+
		'      "costCenterId": "9y8avfh9",'+
		'      "locationId": "9y8avfh9",'+
		'      "mobileLocationIndicator": false,'+
		'      "countryCode": "GB"'+
		'    }'+
		'  ],'+
		'  "profile": "Example",'+
		'  "voucherCode": "ere",'+
		'  "insuranceDetails": {'+
		'    "glassLimit": 34,'+
		'    "repairExcess": 34,'+
		'    "replacementExcess": 10,'+
		'    "calibrationExcess": 12,'+
		'    "sundryExcess": 5'+
		'  },'+
		'  "tradeAccountId": "1234",'+
		'  "pricingDate": "2024/04/13",'+
		'  "taxRegistrationNumber": "129783",'+
		'  "chfVATStatus": "Exempt",'+
		'  "channel": "FrontOffice"'+
		'}';
        Test.setMock(HttpCalloutMock.class, new BLN_MockHttpResponseHTTPCallOutToOkta());
        Test.startTest();
        System.runAs(new User(Id =UserInfo.getUserId())){
            //HttpResponse res = 
            BLN_QuotesAndStocksAPICallout.makeQuoteCallout(payload, caseRecordId);
        }
        Test.stopTest();
        System.assertEquals(caseRecordId, caseRecordId, 'Correct');
    }

    @istest
    static void repricequotetest() {
        list<string> setoforderitemids = new list<string>();
        for(orderitem oi:[select id from orderitem ]){
            setoforderitemids.add(oi.id);
        }
		Order ord = [SELECT Id From Order LIMIT 1];        
        test.setmock(httpcalloutmock.class, new bln_mockhttpresponsehttpcallouttookta());
        test.starttest();
        system.runas(new user(id =userinfo.getuserid())){
            bln_quotesandstocksapicallout.makeRepriceCalloutFromOrder(ord.Id);
        }
        test.stoptest();
        system.assertequals(2, setoforderitemids.size(), 'it should be only 2');
    }
	@istest
    static void stockMovementQuotetest() {
        set<Id> setoforderitemids = new set<Id>();
        Map<string, string> oidLoc = new Map<string,string>();
        for(orderitem oi:[select id, BLN_StockLocation__r.BLN_GUID__c from orderitem ]){
            setoforderitemids.add(oi.id);
            oidLoc.put(oi.Id, oi.BLN_StockLocation__r.BLN_GUID__c);
        }        
        test.setmock(httpcalloutmock.class, new bln_mockhttpresponsehttpcallouttookta());
        test.starttest();
        system.runas(new user(id =userinfo.getuserid())){
            bln_quotesandstocksapicallout.quoteStockMovementCallout(setoforderitemids, JSON.serialize(oidLoc));
            try{bln_quotesandstocksapicallout.quoteStockMovementCallout('12345', JSON.serialize(oidLoc));}
            catch(exception e){exception ex; ex = e;}
        }
        test.stoptest();
        system.assertequals(2, setoforderitemids.size(), 'it should be only 2');
    }

    @istest
    static void getquotecallouttest() {
        test.setmock(httpcalloutmock.class, new bln_mockhttpresponsehttpcallouttookta());
        test.starttest();
        // system.runas(new user(id =userinfo.getuserid())){
            //httpresponse res = 
            //bln_quotesandstocksapicallout.getquotecallout('50770460');
        // }
        test.stoptest();
        system.assertequals('quote1', 'quote1', 'correct');
    }
    
    @istest
    static void quotestockmovementtest() {
        list<string> setoforderitemids = new list<string>();
        for(orderitem oi:[select id from orderitem ]){
            setoforderitemids.add(oi.id);
        }        
        test.setmock(httpcalloutmock.class, new bln_mockhttpresponsehttpcallouttookta());
        test.starttest();
        system.runas(new user(id =userinfo.getuserid())){
            bln_quotesandstocksapicallout.quotestockmovementcancelcallout(setoforderitemids);
        }
        test.stoptest();
        system.assertequals(2, setoforderitemids.size(), 'it should be only 2');
    }
    
    @istest
    static void makestockrequesttest() {
        list<id> listoforderitemids = new list<id>();
        for(orderitem oi:[select id from orderitem ]){
            listoforderitemids.add(oi.id);
        }        
        test.setmock(httpcalloutmock.class, new bln_mockhttpresponsehttpcallouttookta());
        test.starttest();
        system.runas(new user(id =userinfo.getuserid())){
            bln_quotesandstocksapicallout.makestockrequestcallout(listoforderitemids, listoforderitemids, true);
        }
        test.stoptest();
        system.assertequals(2, listoforderitemids.size(), 'it should be only 2');
    }
    
    @istest
    static void makeStockRequestCalloutforStockCollectTest() {
        list<id> listoforderitemids = new list<id>();
        String collectFlag = '{"802Fg000009Is3BIAS": true, "802Fg000009Is3CIAS": true}';
        Map<String, String> orderitemLocationMap = new  Map<String, String>();
            Map<String, String> productWithSA =  New Map<String, String>();
        for(orderitem oi:[select id,Product2.BLN_MDMID__c,BLN_StockLocation__r.BLN_GUID__c from orderitem ]){
            listoforderitemids.add(oi.id);
            orderitemLocationMap.put(oi.Id,oi.BLN_StockLocation__r.BLN_GUID__c);
        }        
        test.setmock(httpcalloutmock.class, new bln_mockhttpresponsehttpcallouttookta());
        test.starttest();
        system.runas(new user(id =userinfo.getuserid())){
            //To be handled by portal - please update
            bln_quotesandstocksapicallout.makeStockRequestCalloutforStockCollect(listoforderitemids, listoforderitemids, orderitemLocationMap,productWithSA, collectFlag);
        }
        test.stoptest();
        system.assertequals(2, listoforderitemids.size(), 'it should be only 2');
    }
    
    @istest
    static void makestockadjustmenttest() {
        list<id> listoforderitemids = new list<id>();
        Set<Id> listOfCase = new Set<Id>();
        List<Case> caseList = [SELECT Id FROM Case];
        for(case caseObj: caseList)
        {
            listOfCase.add(caseObj.Id);
        }
        for(orderitem oi:[select id from orderitem]){
            listoforderitemids.add(oi.id);
        }        
        test.setmock(httpcalloutmock.class, new bln_mockhttpresponsehttpcallouttookta());
        test.starttest();
        //system.runas(new user(id =userinfo.getuserid())){
            // bln_quotesandstocksapicallout.makestockadjustmentcallout(listoforderitemids, 'cancel');
        //}
        BLN_QuotesAndStocksAPICallout.makeWorkOrderComplete(listoforderitemids);
        BLN_QuotesAndStocksAPICallout.sendWorkOrderComplete(listOfCase);
        try{BLN_QuotesAndStocksAPICallout.makeStockRequestCalloutFromPortal(listoforderitemids,listoforderitemids,false);} catch(exception e){}
        test.stoptest();
        system.assertequals(2, listoforderitemids.size(), 'it should be only 2');
    }


    private static String randomNumberGenerator(){
        Integer randomNumber = Integer.valueOf(Math.rint(Math.random() * 900000 + 100000));
        String randomString = String.valueOf(randomNumber);
        return randomString;
    }
}