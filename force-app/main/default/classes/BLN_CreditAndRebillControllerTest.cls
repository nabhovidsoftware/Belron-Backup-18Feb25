@isTest
public class BLN_CreditAndRebillControllerTest {
    private class MockResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {   
            String jsonRes =		'{'+
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
    public static void testData(){
        
        ServiceTerritory services = BLN_TestDataFactory.createServiceTerritories('Test Certainty', false);
        services.BLN_Type__c=  'Branch';
        services.BLN_GUID__c= '2515';
        services.BLN_CostCenter__c = 'Test';
        services.BLN_ExcludedProduct__c = 'test';
        insert services;
        
        Schema.Location locInst =  new Schema.Location();
        locInst.LocationType = 'Warehouse';
        locInst.Name = 'test123';
        locInst.BLN_GUID__c = '2515';
        locInst.BLN_CostCenterCode__c = services.BLN_CostCenter__c;
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
        
        // Create mock Order and related records
        Datetime effectiveDate = System.now();        
        Order testOrder = new Order(
            AccountId = testAcc.Id,
            BLN_CPQExternalQuoteId__c = '2525',
            Status = System.label.BLN_Accepted,
            BLN_Case__c = cse.Id,
            BLN_ServiceTerritory__c = services.Id,
            EffectiveDate = effectiveDate.date()  
        );
        insert testOrder;
    }
        //JSON.serialize(existingOrderList);
        public static string payloadmethod(){
        String currentPayloadJson ='{'+
            '  "status": "success",'+
            '  "quotes": ['+
            '    {'+
            '      "quoteId": "38318988",'+
            '      "locationId": "2515",'+
            '      "quoteTotals": {'+
            '        "totalPrice": 1531.97,'+
            '        "totalTax": 306.4,'+
            '        "totalRepair": 0.0,'+
            '        "totalReplacement": 1439.99,'+
            '        "totalCalibration": 0.0,'+
            '        "totalSundries": 0.0,'+
            '        "totalIncludingTax": 1838.37'+
            '      },'+
            '      "insuranceTotals": {'+
            '        "payableByInsuranceRepair": 0.0,'+
            '        "payableByInsuranceReplacement": 0.0,'+
            '        "payableByInsuranceCalibration": 0.0,'+
            '        "payableByInsuranceSundry": 0.0,'+
            '        "totalPayableByInsurance": 0.0,'+
            '        "totalTaxPayableByInsurance": 0.0,'+
            '        "totalIncludingTaxPayableByInsurance": 0.0'+
            '      },'+
            '      "motoristTotals": {'+
            '        "payableByMotoristRepair": 0.0,'+
            '        "payableByMotoristReplacement": 1439.99,'+
            '        "payableByMotoristCalibration": 0.0,'+
            '        "payableByMotoristSundry": 0.0,'+
            '        "totalTaxPayableByMotorist": 306.4,'+
            '        "totalPayableByMotorist": 1531.97,'+
            '        "totalInludingTaxPayableByMotorist": 1838.37'+
            '      },'+
            '      "taxTotals": {'+
            '        "totalTaxRepair": 0.0,'+
            '        "totalTaxReplacement": 0.0,'+
            '        "totalTaxCalibration": 0.0,'+
            '        "totalTaxSundries": 0.0'+
            '      },'+
            '      "tradeCompanyTotals": {'+
            '        "payableByTradeRepair": 0.0,'+
            '        "totalPayableByTrade": 0.0,'+
            '        "totalPayableByTradeIncludingTax": 0.0,'+
            '        "payableByTradeSundry": 0.0,'+
            '        "payableByTradeReplacement": 0.0,'+
            '        "payableByTradeCalibration": 0.0,'+
            '        "payableByTradeTotalTax": 0.0'+
            '      },'+
            '      "discountThresholdA": 1470.7,'+
            '      "discountThresholdB": 1194.94,'+
            '      "discountThresholdC": 1076.38,'+
            '      "priceExpirationDate": "2024-07-22T00:00:00Z",'+
            '      "lineItems": ['+
            '        {'+
            '          "lineItemId": 2,'+
            '          "parentLineItemId": 2,'+
            '          "bundleName": null,'+
            '          "partNumber": "2437AXRC",'+
            '          "belronPartNumber": null,'+
            '          "partDescription": "BMW 3-SERIES 2C/2CA 1998-ON WINDSCREEN-SUNDRY",'+
            '          "quantity": 1,'+
            '          "baseListPrice": 80.0,'+
            '          "netPrice": 80.0,'+
            '          "taxRate": 20.0,'+
            '          "totalTax": 16.0,'+
            '          "netPriceIncludingTax": 96.0,'+
            '          "optional": "mandatory",'+
            '          "partOfBundle": false,'+
            '          "bundleHierarchy": null,'+
            '          "nonBundlePrice": null,'+
            '          "availabilityDetails": [],'+
            '          "parentBOMId": null,'+
            '          "leadingProductIndicator": false,'+
            '          "totalPayableByInsurance": 0,'+
            '          "totalTaxPayableByInsurance": 0,'+
            '          "totalIncludingTaxPayableByInsurance": 0,'+
            '          "totalPayableByMotorist": 16.0,'+
            '          "totalTaxPayableByMotorist": 80.0,'+
            '          "totalIncludingTaxPayableByMotorist": 96.0,'+
            '          "payableByTradeTotalTax": 0,'+
            '          "totalPayableByTrade": 0,'+
            '          "totalPayableByTradeIncludingTax": 0,'+
            '          "payableByTrade": "Motorist"'+
            '        }'+
            '     '+
            '      '+
            '    '+
            '      '+
            '      ]'+
            '    }'+
            '  ]'+
            '}';
            return currentPayloadJson;
    }
    @isTest
    static void getOrderItemsAndOrderItems() {
        String service = [Select Id, BLN_GUID__c from ServiceTerritory LIMIT 1].BLN_GUID__c;
        List<BLN_ProductAvailabilityWrapper.LineItemIdentifier> existingOrderList = new List<BLN_ProductAvailabilityWrapper.LineItemIdentifier>();
        BLN_ProductAvailabilityWrapper.LineItemIdentifier existingOrder = new BLN_ProductAvailabilityWrapper.LineItemIdentifier();
        existingOrderList.add(existingOrder);
        Test.startTest();
        String testOrder = [select id, BLN_CPQExternalQuoteId__c from order limit 1].BLN_CPQExternalQuoteId__c;
        String payload = payloadmethod();
        BLN_CreditAndRebillController.createOrderAndOrderItemsAfterRebill(payload,JSON.serialize(existingOrderList),testOrder,service);  
        System.assertNotEquals(testOrder, null,'test');
        Test.stopTest(); 
    }
    
    @isTest
    static void makeQuoteCalloutWithSpecificOrderLocationTest() {
        string orderId = [select BLN_CPQExternalQuoteId__c from Order limit 1].BLN_CPQExternalQuoteId__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        BLN_CreditAndRebillController.makeQuoteCalloutWithSpecificOrderLocation('2525');
        System.assertNotEquals(orderId, null,'test');
        Test.stopTest(); 
    }
}