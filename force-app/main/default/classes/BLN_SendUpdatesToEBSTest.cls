/**@description : This is the Apex Test Class for BLN_SendUpdatesToEBS
*  @author: PwC India
*  @Story: FOUK-5076 (Salesforce Trigger of EBS Stock Update for Unused Parts)
*  @CreatedDate: 17/05/2024
*/
@isTest
public class BLN_SendUpdatesToEBSTest {
    private class MockResponseGenerator implements HttpCalloutMock {
        public Boolean err = false;
        public HTTPResponse respond(HTTPRequest req) {
            String jsonRes = '';
            if(err)
            {
                jsonRes =		'[{'+
                '    "status": "success",'+
                '    "itemsRevoke": ['+
                '        {'+
                '            "lineId": "1234",'+
                '            "returnedQuantity": "2",'+
                '            "errorCode": "000000"'+
                '        }'+
                '    ]'+
                '}]';
            }
            else {
                jsonRes =		'[{'+
                '    "status": "success",'+
                '    "itemsRevoke": ['+
                '        {'+
                '            "lineId": "1234",'+
                '            "returnedQuantity": "2",'+
                '            "errorCode": "100019"'+
                '        }'+
                '    ]'+
                '}]';
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
    @testSetup
    static void setup(){
        List<Product2> prodList = new List<Product2>();
        List<OrderItem> oiList = new List<OrderItem>();
        List<ProductRequired> prList = new List<ProductRequired>();
        List<ProductConsumed> pcList = new List<ProductConsumed>();
        List<ProductItem> piList = new List<ProductItem>();
        List<id> oIids = new List<id>();

        String remedyJobId = randomNumberGenerator();
        String remedyTaskId = randomNumberGenerator();

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;

        WorkType workType = BLN_TestDataFactory.createWorkType('Replacement', 1.0, true, true);
        
        Account newAcc = BLN_TestDataFactory.createAccount('Tes Account', 'PersonAccount','9988127600');
        insert newAcc;

        Contract newContract = BLN_TestDataFactory.createTestContract(newAcc);
        insert newContract;

        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = newAcc.Id;
        caseObj.BLN_SubType__c = 'Job Request';
        insert caseObj;

        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = 'Bedford';
        operatingHours.TimeZone = 'Europe/London';
        insert operatingHours;

        ServiceTerritory services = BLN_TestDataFactory.createServiceTerritories('Test Certainty', false);
        services.BLN_Type__c=  'Branch';
        services.BLN_GUID__c= '140007';
        services.OperatingHoursId = operatingHours.id;  
        services.BLN_CostCenter__c = 'COST_CENTER_000000001';       
        insert services;

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
        servApp.ServiceTerritoryId = services.id;
        servApp.SchedStartTime = System.now();
        servApp.SchedEndTime = System.now()+5;
        servApp.BLN_WorkOrderNumber__c = workOrder.id;
        servApp.BLN_WorkOrderLineItem__c = wOLI.Id;
        servApp.BLN_RemedyJobId__c = remedyJobId;
        servApp.BLN_RemedyTaskId__c = remedyTaskId;
        servApp.WorkTypeId = workType.id;
        insert servApp;

        ServiceResource sr = BLN_TestDataFactory.createServiceResource('Test - tech 1' , true);
        
        ServiceTerritoryMember sTMember = new ServiceTerritoryMember();
        sTMember.OperatingHoursId = operatingHours.Id;        
        sTMember.ServiceResourceId = sr.Id;        
        sTMember.ServiceTerritoryId = services.Id ;
        sTMember.TerritoryType = 'P';
        sTMember.EffectiveStartDate = System.now() -3;
        insert sTMember;

        Order newOrder = new Order();
        newOrder.Status = 'Accepted';
        newOrder.AccountId= newAcc.Id;
        newOrder.BLN_Case__c = caseObj.id;
        newOrder.EffectiveDate=Date.today();
        newOrder.ContractId=newContract.Id;
        newOrder.BLN_ServiceTerritory__c = services.Id;
        newOrder.BLN_CPQExternalQuoteId__c = '39239816';
        insert newOrder;

        Schema.Location loc = new Schema.Location();
        loc.Name = 'Branch Location';
        loc.LocationType = 'Belron Warehouse';
        loc.IsInventoryLocation = true;
        loc.Longitude = -0.474;  //28.635308;
        loc.Latitude = 52.119; //28.635308;
        loc.BLN_GUID__c = 'Test';
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
        oi1.OrderId = newOrder.Id;
        oi1.ListPrice = 100;
        oi1.BLN_FittingLocation__c = loc.Id;
        oi1.BLN_StockLocation__c = loc.Id;
        oi1.BLN_StockOrderNumber__c = 'STOCK001';
        oi1.BLN_ProductChangeType__c = System.label.BLN_ProductRemoved;
        oi1.BLN_IsProductSelected__c = false;
        oiList.add(oi1);

        OrderItem oi2 = BLN_TestDataFactory.createTestOrderItem(newOrder , p2);
        oi2.Quantity = 6;
        oi2.BLN_ServiceAppointment__c = servApp.Id;
        oi2.BLN_StockLineNumber__c  = '9917828281828199';
      
        oi2.ListPrice = 100;
        oi2.BLN_FittingLocation__c = loc.Id;
        oi2.BLN_StockLocation__c = loc.Id;
        oi2.BLN_StockOrderNumber__c = 'STOCK001';
        oi2.BLN_ProductChangeType__c = System.label.BLN_ProductUpsold;
        oi2.BLN_IsProductSelected__c = true;
        oiList.add(oi2);

        insert oiList;
        
        OrderItem oi3 = BLN_TestDataFactory.createTestOrderItem(newOrder , p2);
        oi3.Quantity = 3;
        oi3.BLN_ServiceAppointment__c = servApp.Id;
        oi3.BLN_StockLineNumber__c  = '9917828281828199';
      
        oi3.ListPrice = 10;
        oi3.BLN_FittingLocation__c = loc.Id;
        oi3.BLN_StockLocation__c = loc.Id;
        oi3.BLN_StockOrderNumber__c = 'STOCK001';
        oi3.BLN_ProductChangeType__c = System.label.BLN_QuantityChanged;
        oi3.BLN_IsProductSelected__c = true;
        insert oi3;
        oIids.add(oi3.id);

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
        pr2.BLN_IsConsumed__c = true;
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
        
    }
    /*Description:This method is used to test EBS call out */
    @isTest
    static void testMethod1() {
        List<ServiceAppointment> sAList = [SELECT Id, ServiceTerritoryId, Status, WorkTypeId, ParentRecordId, BLN_Case__c FROM ServiceAppointment LIMIT 1];
        List<BLN_SendUpdatesToEBS.InputVariables> inputVariables = new List<BLN_SendUpdatesToEBS.InputVariables>();
        BLN_SendUpdatesToEBS.InputVariables inputVariable = new BLN_SendUpdatesToEBS.InputVariables();
        inputVariable.sA = sAList[0];
        inputVariables.add(inputVariable);
        List<Id> oid = new List<Id>();
        Map<Id, Integer> mapOi = new Map<Id, Integer>();
        for(OrderItem oii: [Select Id, Quantity from OrderItem])
        {
            oid.add(oii.Id);
            mapOi.put(oii.Id, Integer.valueOf(oii.Quantity));
        }
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        Test.startTest();
        System.runAs(new User(Id =UserInfo.getUserId())){        
            BLN_SendUpdatesToEBS.sendUpdatesToEBS(inputVariables);
            BLN_SendUpdatesToEBSCallout.calloutForQuantityChange(oid, mapOi);
        }
        Test.stopTest();
        System.assertEquals(1, sAList.size(), 'Appointment Should be only 1');
    }

    private static String randomNumberGenerator(){
        Integer randomNumber = Integer.valueOf(Math.rint(Math.random() * 900000 + 100000));
        String randomString = String.valueOf(randomNumber);
        return randomString;
    }
    @isTest
    public static void updateOrderRecordTest(){
        Order testOrd = [Select Id, BLN_CPQExternalQuoteId__c from Order LIMIT 1];
        testOrd.BLN_CPQExternalQuoteId__c = '39239816';
        update testOrd;
        String currentPayloadJson ='{'+
            '    "status": "success",'+
            '    "quotes": ['+
            '        {'+
            '            "quoteId": "39239816",'+
            '            "locationId": "9y8hfh9",'+
            '            "quoteTotals": {'+
            '                "totalPrice": 0,'+
            '                "totalTax": 176.8,'+
            '                "totalRepair": 0,'+
            '                "totalReplacement": 629.51,'+
            '                "totalCalibration": 0,'+
            '                "totalSundries": 0,'+
            '                "totalIncludingTax": 1060.78'+
            '            },'+
            '            "insuranceTotals": {'+
            '                "payableByInsuranceRepair": 0,'+
            '                "payableByInsuranceReplacement": 0,'+
            '                "payableByInsuranceCalibration": 0,'+
            '                "payableByInsuranceSundry": 0,'+
            '                "totalPayableByInsurance": 0,'+
            '                "totalTaxPayableByInsurance": 0,'+
            '                "totalIncludingTaxPayableByInsurance": 0'+
            '            },'+
            '            "motoristTotals": {'+
            '                "payableByMotoristRepair": 0,'+
            '                "payableByMotoristReplacement": 629.51,'+
            '                "payableByMotoristCalibration": 0,'+
            '                "payableByMotoristSundry": 0,'+
            '                "totalTaxPayableByMotorist": 1060.78,'+
            '                "totalPayableByMotorist": 883.98,'+
            '                "totalInludingTaxPayableByMotorist": 1060.78'+
            '            },'+
            '            "taxTotals": {'+
            '                "totalTaxRepair": 0,'+
            '                "totalTaxReplacement": 0,'+
            '                "totalTaxCalibration": 0,'+
            '                "totalTaxSundries": 0'+
            '            },'+
            '            "tradeCompanyTotals": {'+
            '                "payableByTradeRepair": 0,'+
            '                "totalPayableByTrade": 0,'+
            '                "totalPayableByTradeIncludingTax": 0,'+
            '                "payableByTradeSundry": 0,'+
            '                "payableByTradeReplacement": 0,'+
            '                "payableByTradeCalibration": 0,'+
            '                "payableByTradeTotalTax": 0'+
            '            },'+
            '            "discountThresholdA": 848.62,'+
            '            "discountThresholdB": 689.51,'+
            '            "discountThresholdC": 618.79,'+
            '            "priceExpirationDate": "2024-05-27T00:00:00Z",'+
            '            "lineItems": ['+
            '                {'+
            '                    "lineItemId": 2,'+
            '                    "parentLineItemId": 2,'+
            '                    "bundleName": null,'+
            '                    "partNumber": "2474AGNMVZ6C",'+
            '                    "belronPartNumber": "2474AGNMVZ6C",'+
            '                    "partDescription": "MINI MINI 2CA 2016 ^WINDSCREEN  DROP DOWN BAND / ENCAPSULATION BOTTOM / FITTING SENSOR / GLASS COLOR - GREEN / SILKPRINT 4/4 / VERTICAL VIN",'+
            '                    "quantity": 1,'+
            '                    "baseListPrice": 629.51,'+
            '                    "netPrice": 629.51,'+
            '                    "taxRate": 20,'+
            '                    "totalTax": 125.9,'+
            '                    "netPriceIncludingTax": 755.41,'+
            '                    "optional": "mandatory",'+
            '                    "partOfBundle": false,'+
            '                    "bundleHierarchy": null,'+
            '                    "nonBundlePrice": null,'+
            '                    "availabilityDetails": ['+
            '                        {'+
            '                            "stockLocationId": "9y8hfh9",'+
            '                            "availableFromDate": "2024-03-27T00:00:00Z"'+
            '                        }'+
            '                    ]'+
            '                }'+
            '            ]'+
            '        }'+
            '    ]'+
            '}';
        Test.startTest();
        BLN_SendUpdatesToEBSCallout.updateOrderRecordWithNewQuoteValues(currentPayloadJson, testOrd.Id);
        Test.stopTest();
        System.assertEquals(true, testOrd!=null, 'Order Should not be null');
    }
}