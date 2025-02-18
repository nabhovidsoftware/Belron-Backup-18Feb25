/** @description : This test class is used to cover testcoverage for BLN_PortalProductAvailabilityRebook Class
  @Story : FOUK - 6281,6282
  @author: PwC India
  @CreatedDate: 06/06/2024
*/
@isTest
Public class BLN_PProductAvailabilityRebookTest {
    
    Public class MockResponseGenerator implements HttpCalloutMock {
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
    
    @isTest
	static void getOrderItemsToIdentifyTest() {
        Test.startTest();
        Order testOrder = [select id, BLN_CPQExternalQuoteId__c from order limit 1];
        BLN_PortalProductAvailabilityRebook.getOrderItemsToIdentify(testOrder);
        System.assertNotEquals(testOrder, null,'test');
        Test.stopTest(); 
    }

    @isTest
	static void getAcceptedOrderItemsToIdentifyByCPQExternalIdTest() {
        Test.startTest();
        Order testOrder = [select id, BLN_CPQExternalQuoteId__c from order limit 1];
        BLN_PortalProductAvailabilityRebook.getOrderItemsToIdentifyByCPQExternalId(testOrder.BLN_CPQExternalQuoteId__c);
        System.assertNotEquals(testOrder, null,'test');
        Test.stopTest(); 
    }

    @isTest
	static void getOrderItemsToIdentifyByStatusTest() {
        Test.startTest();
        String caseId = [select id from case].Id;
        Order testOrder = [select id, BLN_CPQExternalQuoteId__c,Status from order limit 1];
        testOrder.Status = 'Invoiced';
        update testOrder;
        BLN_PortalProductAvailabilityRebook.getOrderItemsToIdentifyByStatus(caseId,testOrder.Status);
        System.assertNotEquals(testOrder, null,'test');
        Test.stopTest(); 
    }
	 @isTest
	static void dataSetup(){
        Test.startTest();
            String insuranceRTId = Schema.getGlobalDescribe().get('BLN_Corporate__c').getDescribe().getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
            BLN_Vehicle__c testVehicle = new BLN_Vehicle__c(BLN_VehicleRegNumber__c = 'TestVRN');
            insert testVehicle;
            BLN_Corporate__c corporate = new BLN_Corporate__c(RecordTypeId = insuranceRTId, BLN_Vehicle__c=testVehicle.id);
            insert corporate;
            case cs = [select Id,BLN_Corporate__c from case limit 1]; 
            cs.BLN_Corporate__c = corporate.Id;
            update cs;
        System.assertEquals('TestVRN', testVehicle.BLN_VehicleRegNumber__c, 'Worng value provided');
        Test.stopTest();
        
    }

    
    @isTest
    static void makeNewQuoteCalloutTest() {
               
        Test.startTest();
        case cs = [select Id,BLN_Corporate__c from case];
        ServiceTerritory sr = [select Id,BLN_GUID__c from ServiceTerritory where BLN_GUID__c = '2515' limit 1]; 
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        string response = BLN_PortalProductAvailabilityRebook.makeNewQuoteCallout(cs.Id,Double.valueOf(54.63150177683656), Double.valueOf(-5.924506383950011),sr.BLN_GUID__c);
        System.assertNotEquals(response, null,'success');
        Test.stopTest(); 
    }
        
	@isTest
    static void updateServiceAppointmentsTest() {
        Test.setMock(HttpCalloutMock.class, new BLN_ReserveCptStockMock());
  		Test.startTest();
        
		//String data = appJson();
		List<BLN_ProductAvailabilityWrapper.products> prodList = new List<BLN_ProductAvailabilityWrapper.products>();
		BLN_ProductAvailabilityWrapper.products prod = new BLN_ProductAvailabilityWrapper.products();
        prod.productCode = 'PSER00400A';
        prod.productEnable = false;
        prod.quantity = 1;
        prod.isChecked = true;
        prod.orderItemId = [select id from orderItem limit 1].Id;
        prod.lineItemId = 55;
        prodList.add(prod);
        
        List<BLN_ProductAvailabilityWrapper.ProductAvailibilities> prdAvailablelist = new List<BLN_ProductAvailabilityWrapper.ProductAvailibilities>();
        BLN_ProductAvailabilityWrapper.ProductAvailibilities prdAvailable = new BLN_ProductAvailabilityWrapper.ProductAvailibilities();
        prdAvailable.products = prodList;
        prdAvailablelist.add(prdAvailable);
             
        List<BLN_ProductAvailabilityWrapper.Appointments> appList = new List<BLN_ProductAvailabilityWrapper.Appointments>();
		BLN_ProductAvailabilityWrapper.Appointments app = new BLN_ProductAvailabilityWrapper.Appointments();
        app.productAvailibilities = prdAvailablelist;
        app.keyIndex = '0';
        app.locationId = '389';
        app.locationName = 'CE Bedford';
        //app.isFirstAppointment = true;
        //app.isMobileLocation = true;
        app.serviceAppointmentId = [Select Id from serviceAppointment Limit 1].Id;
        app.earlierAvailabilityDateHeader = 'May 20, 2024';
        appList.add(app);

        List<BLN_ProductAvailabilityWrapper.AppointmentWrapper> appWrapperList = New List<BLN_ProductAvailabilityWrapper.AppointmentWrapper>();        
        BLN_ProductAvailabilityWrapper.AppointmentWrapper appWrapper = New BLN_ProductAvailabilityWrapper.AppointmentWrapper();
        appwrapper.serviceLocationName = 'SERVICE LOCATION Cardington';
        appWrapper.serviceLocationId = '2515';
        appWrapper.isPrimaryLocation = true;
        appWrapper.externalQuoteId = '2525';
        appWrapper.appointments = appList;  
        
        appWrapperList.add(appWrapper);
        
        BLN_PortalProductAvailabilityRebook.SlotDateTimeToOrderItem slotsObj = new BLN_PortalProductAvailabilityRebook.SlotDateTimeToOrderItem();
        slotsObj.lineItemId = prod.lineItemId;
        slotsObj.slotDate = '2024-09-09T00:00:00Z';
        
        List<BLN_PortalProductAvailabilityRebook.SlotDateTimeToOrderItem> slotList = new List<BLN_PortalProductAvailabilityRebook.SlotDateTimeToOrderItem>();
        slotList.add(slotsObj);
        
        string caseId = [select Id from case].Id;
        BLN_PortalProductAvailabilityRebook.updateServiceAppointments(JSON.serialize(appWrapperList),caseId);
       // BLN_PortalProductAvailabilityRebook.rebookingStockCallout(JSON.serialize(prodList), JSON.serialize(prodList), JSON.serialize(prodList),JSON.serialize(slotList), caseId);
        System.assertNotEquals(caseId, null,'success');
        Test.stopTest();
    }

    @isTest
    static void testLocation1() {
        
        test.startTest();       
        // Coordinates from the provided KML data
        String jsonRes=		'{'+
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
            '                "totalIncludingTaxPayableByMotorist": 1060.78'+
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
            '          "lineItemId": 2,'+
            '          "parentLineItemId": 2,'+
            '          "bundleName": "bundle01",'+
            '          "partNumber": "2474AGNMVZ6C",'+
            '          "belronPartNumber": "2474AGNMVZ6C",'+
            '          "partDescription": "BOSCH  WIPER BLADE AP18U",'+
            '          "quantity": 1,'+
            '          "baseListPrice": 25.42,'+
            '          "netPrice": 25.42,'+
            '          "taxRate": 20.0,'+
            '          "totalTax": 5.08,'+
            '          "netPriceIncludingTax": 30.5,'+
            '          "selectProduct": false,'+
            '          "bomMandatory": false,'+
            '          "partOfBundle": false,'+
            '          "bundleHierarchy": null,'+
            '          "nonBundlePrice": null,'+
            '          "parentBOMId": null,'+
            '          "leadingProductIndicator": false,'+
            '          "totalPayableByInsurance": 0,'+
            '          "totalTaxPayableByInsurance": 0,'+
            '          "totalIncludingTaxPayableByInsurance": 0,'+
            '          "totalPayableByMotorist": 5.08,'+
            '          "totalTaxPayableByMotorist": 25.42,'+
            '          "totalIncludingTaxPayableByMotorist": 30.5,'+
            '          "payableByTradeTotalTax": 0,'+
            '          "totalPayableByTrade": 0,'+
            '          "totalPayableByTradeIncludingTax": 0,'+
            '          "payableByTrade": "Motorist",'+
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
        Case cse = [Select Id, BLN_Vehicle__r.BLN_SpecialVehicle__c from case Limit 1];

        ServiceTerritory services2 = BLN_TestDataFactory.createServiceTerritories('Test Certainty 2', false);
        FSL__Polygon__c myPolygon = new FSL__Polygon__c();
        services2.BLN_GUID__c='9y8hfh2';
        services2.PostalCode = 'MK44 3US';
        services2.IsActive = true;
        services2.BLN_Type__c = 'Mobile';
        services2.BLN_Specials__c = true;
        services2.Country = 'Bedford';        
        services2.Latitude = 52.125290000000000;
        services2.Longitude = -0.422290000000000;
        services2.BLN_CostCenter__c = '9y8hfh2';
        
        insert services2;

        myPolygon.FSL__Ma_La__c = 48.010976; 
        myPolygon.FSL__Mi_La__c = 45.911905 ; 
        myPolygon.FSL__Ma_Lo__c = -84.187741;
        myPolygon.FSL__Mi_Lo__c = -89.307370;     
        myPolygon.FSL__Color__c ='#5679C0';
        myPolygon.Name = 'Central SSS1' ;
        myPolygon.FSL__Service_Territory__c = services2.id;
        myPolygon.FSL__KML__c =  '<?xml version="1.0" encoding="UTF-8"?> '+
                '<kml xmlns="http://www.opengis.net/kml/2.2">'+
                '<Style id="CentralSSSStyle">'+
                '<LineStyle>'+
                '<width>1</width>'+
                '</LineStyle>'+
                '<PolyStyle>'+
                '<color>80C07956</color>'+
                '</PolyStyle>'+
                '</Style>'+
                '<Placemark>'+
                '<name>CentralSSS</name>'+
                '<styleUrl>#CentralSSSStyle</styleUrl>'+
                '<Polygon>'+
                '<outerBoundaryIs>'+
                '<LinearRing>\n'+
                '<coordinates>-89.02172505348693,47.81952924639332,0\n'+
                '-84.18774067848693,48.01097620848099,0\n'+
                '-84.89086567848693,46.22441984873406,0\n'+
                '-88.34057270973693,45.91190522847453,0\n'+
                '-88.90087544411193,47.53103006689299,0\n'+
                '-89.30736958473693,47.77524856801052,0\n'+
                '-89.02172505348693,47.81952924639332,0\n'+
                '</coordinates>\n'+
                '</LinearRing>'+
                '</outerBoundaryIs>'+
                '</Polygon>'+
                '</Placemark>'+
                '</kml>';
        insert myPolygon;
        
        List<BLN_ProductAvailabilityWrapper.LocationWrapper> results = BLN_PortalProductAvailabilityRebook.getNearestServiceLocationsByLatLong(cse, 893893, 8973);
        System.assertNotEquals(results, null,'success');
        BLN_PortalProductAvailabilityRebook.parse(jsonRes);
        //BLN_PortalProductAvailabilityRebook.ServiceLabel test = new BLN_PortalProductAvailabilityRebook.ServiceLabel();
        //test.serviceLocation = '239';
        BLN_PortalProductAvailabilityRebook.Product test1 = new BLN_PortalProductAvailabilityRebook.Product();
        test1.products = 'test';
        Test.stopTest();
    }
    
    @isTest
    static void testGetEarliestDateList() {
        String payload = newJsonV3();
        Test.setMock(HttpCalloutMock.class, new YourMockHttpResponse());
        Test.startTest();
        string caseId = [select Id from case].Id;
        List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> result =  BLN_PortalProductAvailabilityRebook.getEarliestDateList(payload,caseId);
        //List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> result1 =  BLN_ProductAvailabilityUtility.getEarliestDateList(payload);
        Test.stopTest();
        system.assertNotEquals(result, null,'test');
    }
    
    @isTest
    static void testgetLiabilityList() {
        String payload = newJsonV3();
        Test.startTest();
        string orderId = [select BLN_CPQExternalQuoteId__c from Order limit 1].BLN_CPQExternalQuoteId__c;
       // List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper> liabilityList = 
        BLN_PortalProductAvailabilityRebook.getLiabilityList(payload,'43723139');
        Test.stopTest();
        System.assertNotEquals(orderId, null,'Test');
    }
    
    // Create a mock HTTP response to simulate the callout response
    public class YourMockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Construct and return a mock HTTP response with the desired response payload
            HTTPResponse res = new HTTPResponse();
            res.setBody('payload');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void rebookServiceAppointmentsTest() {
        
        string caseId = [select Id from case].Id;
         
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        //BLN_PortalProductAvailabilityRebook.DisplayDetailsWrapper data = 
        BLN_PortalProductAvailabilityRebook.rebookServiceAppointments(caseId, null);
        System.assertNotEquals(caseId, null,'test');  
        Test.stopTest();    
    }
    
        @isTest
    static void rebookServiceAppointmentsTest1() {
        
        string caseId = [select Id from case].Id;
         
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        //BLN_ProductAvailabilityUtility.DisplayDetailsWrapper data = 
        BLN_ProductAvailabilityUtility.rebookServiceAppointments(caseId);
        System.assertNotEquals(caseId, null,'test');  
        Test.stopTest();    
    }
         
    
        @isTest
    	static void testGetAllSelectedProductLists() {
        Test.startTest();
        string orderId = [select BLN_CPQExternalQuoteId__c from Order].BLN_CPQExternalQuoteId__c;
       // List<List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>> data = 
        BLN_PortalProductAvailabilityRebook.getAllSelectedProductLists(orderId);
       // List<List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>> data1 = 
        BLN_ProductAvailabilityUtility.getAllSelectedProductLists(orderId);
        Test.stopTest();    
        System.assertNotEquals(orderId, null,'Test'); 
    }


    @isTest
    static void testRebookingStockCallout() {
        List<BLN_ProductAvailabilityWrapper.Products> prodList = new List<BLN_ProductAvailabilityWrapper.Products>();
		BLN_ProductAvailabilityWrapper.Products prod = new BLN_ProductAvailabilityWrapper.Products();
        prod.productCode = 'PSER00400A';
        prod.productEnable = false;
        prod.quantity = 1;
        prod.isChecked = true;
        //prod.orderItemId = [select id from orderItem limit 1].Id;
        prodList.add(prod);
        
       // BLN_PortalProductAvailabilityRebook.ProductSelectionWrapper prod2 = new BLN_PortalProductAvailabilityRebook.ProductSelectionWrapper();
        BLN_ProductAvailabilityWrapper.Products prod2 = new BLN_ProductAvailabilityWrapper.Products();
        prod2.productCode = 'PSER00400A';
        prod2.productEnable = false;
        prod2.quantity = 1;
        prod2.isChecked = true;
        prod2.totalTax = 10;
        prod2.selectProduct = 'ProductSlect';
        prod2.productName = 'ProductName';
        prod2.partOfBundle = true;
        prod2.netPriceIncludingTax = 10;
        prod2.netPrice = 10;
        prod2.leadingProductIndicator = true;
        prod2.hierarchy = 'Prod Hierarchy';
        prod2.bundleName = 'Prod Bundle';
        prod2.bundleHierarchy = 'Prod Bundle Hierarchy';
        
        List<BLN_ProductAvailabilityWrapper.ProductAvailibilities> prdAvailablelist = new List<BLN_ProductAvailabilityWrapper.ProductAvailibilities>();
        BLN_ProductAvailabilityWrapper.ProductAvailibilities prdAvailable = new BLN_ProductAvailabilityWrapper.ProductAvailibilities();
        prdAvailable.products = prodList;
        prdAvailablelist.add(prdAvailable);
             
        List<BLN_ProductAvailabilityWrapper.Appointments> appList = new List<BLN_ProductAvailabilityWrapper.Appointments>();
		BLN_ProductAvailabilityWrapper.Appointments app = new BLN_ProductAvailabilityWrapper.Appointments();
        app.productAvailibilities = prdAvailablelist;
        app.keyIndex = '0';
        app.locationId = '389';
        app.locationName = 'CE Bedford';
        //app.isFirstAppointment = true;
        //app.isMobileLocation = true;
        app.earlierAvailabilityDateHeader = 'May 20, 2024';
        appList.add(app);

        List<BLN_ProductAvailabilityWrapper.AppointmentWrapper> appWrapperList = New List<BLN_ProductAvailabilityWrapper.AppointmentWrapper>();        
        BLN_ProductAvailabilityWrapper.AppointmentWrapper appWrapper = New BLN_ProductAvailabilityWrapper.AppointmentWrapper();
        appwrapper.serviceLocationName = 'SERVICE LOCATION Cardington';
        appWrapper.serviceLocationId = '2515';
        appWrapper.isPrimaryLocation = true;
        appWrapper.externalQuoteId = '2525';
        appWrapper.appointments = appList;
        appWrapperList.add(appWrapper);
        
        Case testCase = [Select Id from case Limit 1];
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        Test.startTest();
        //BLN_PortalProductAvailabilityRebook.parse(appJson());
        BLN_PortalProductAvailabilityRebook.EarliestAvailibilityDetailsWrapper testWrapper = new BLN_PortalProductAvailabilityRebook.EarliestAvailibilityDetailsWrapper();
        testWrapper.bundleName = 'test';
        //BLN_PortalProductAvailabilityRebook.ProductSelectionWrapper testProdWrapper = new BLN_PortalProductAvailabilityRebook.ProductSelectionWrapper();
        BLN_PortalProductAvailabilityRebook.getCaseData(testCase.Id);
        BLN_PortalProductAvailabilityRebook.callCPQCloneAPI('44517653',testCase.Id );
        //BLN_PortalProductAvailabilityRebook.rebookingStockCallout(JSON.serialize(appWrapperList), testCase.Id);
        System.assertNotEquals(appWrapperList, null,'test');  
        Test.stopTest();
    }
    
    @testSetup
    public static void createData(){
       
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
        
       // BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle(); 
        
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
        
        BLN_VehicleDamage__c vD = new BLN_VehicleDamage__c();
        vD.BLN_BOMID__c = '12541';
        vD.BLN_Case__c = cse.id;
        vD.BLN_ProductId__c = String.valueOf(prod1.Id);
        insert vD;
        
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
        
        worktype worktype = new worktype();
        worktype.Name = 'Recalibration';
        worktype.EstimatedDuration = 3;
            insert worktype;
        
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = worktype.Id;
            insert workOrders;  
        
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = '5454545';
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
            insert wOLI;  
             
        ServiceAppointment sa = new ServiceAppointment();
        sa.ParentRecordId = wOLI.id;        
        sa.Status = 'Scheduled';
        sa.ServiceTerritoryId = services.id;
        sa.EarliestStartTime = System.now();        
        sa.DueDate = System.now()+1;
        sa.BLN_WorkOrderNumber__c = workOrders.id;
        sa.BLN_IsForcedAppointment__c = false;
        sa.BLN_RemedyJobId__c = '3333333';
        sa.BLN_RemedyTaskId__c = '5454545';
        sa.WorkTypeId = worktype.id;
        sa.Latitude = 51.51333;
        sa.Longitude = -0.08895;
        sa.SchedStartTime = system.now();
        sa.ArrivalWindowStartTime = System.now();
        sa.ArrivalWindowEndTime = System.now().addHours(2);
        sa.SchedEndTime = System.now().addHours(2);
        insert sa;
        
        // Create mock Order and related records
        Datetime effectiveDate = System.now();        
        Order testOrder = new Order(
            AccountId = testAcc.Id,
            BLN_CPQExternalQuoteId__c = '2525',
            Status = System.label.BLN_Accepted,
            BLN_Case__c = cse.Id,
            EffectiveDate = effectiveDate.date()  
        );
        insert testOrder;
        System.assertNotEquals(testOrder, null,'test');
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
        orderItm.BLN_ServiceAppointment__c = sa.Id;
        orderItm.BLN_LeadingPartIndicator__c = true;
        orderItm.BLN_OutOfStock__c = true;
        orderItm.BLN_StockOrderNumber__c = '450';
        insert orderItm;
        System.assertNotEquals(effectiveDate, null,'success');  
    }
    
    public static string appJson(){
        String appjson=	'['+
        '    {'+
        '        "ServiceLocationName": "SERVICE LOCATION Cardington",'+
        '        "ServiceLocationId": "2515",'+
        '        "isPrimaryLocation": true,'+
        '		 "ExternalQuoteId" : "47098762",'+
        '        "ServiceLocationLabel": ['+
        '            {'+
        '                "ServiceLabel": "SERVICE LOCATION",'+
        '                "Product": "Products",'+
        '                "ProductNames": ['+
        '                    {'+
        '                        "productName": "ENVIRONMENTAL LEVY CHARGE WINDSCREEN",'+
        '                        "productCode": "PSER00400A",'+
        '                        "prodCategory": "WINDSCREEN"'+
        '                    },'+
        '                    {'+
        '                        "productName": "AUDI A3 3H/5B 2004-ON WINDSCREEN-GREEN SOLAR+ACOUSTIC+GREY TOP TINT+LOWER MOULDING+UPPER MOULDING+VIN",'+
        '                        "productCode": "8580AGAGYVW",'+
        '                        "prodCategory": "WINDSCREEN"'+
        '                    }'+
        '                ]'+
        '            }'+
        '        ],'+
        '        "earliestAvailablity": ['+
        '            {'+
        '                "serviceName": "Cardington",'+
        '                "earliestAvailablity": "Earliest Availability",'+
        '                "productDate": ['+
        '                    {'+
        '                        "earliestDate": "June 11, 2024",'+
        '                        "productCode": "PSER00400A"'+
        '                    },'+
        '                    {'+
        '                        "earliestDate": "May 20, 2024",'+
        '                        "productCode": "8580AGAGYVW"'+
        '                    }'+
        '                ]'+
        '            }'+
        '        ],'+
        '        "appointments": ['+
        '            {'+
        '                "appointmentName": "Appointment 1",'+
        '                "keyIndex": "0",'+
        '                "locationId": "2515",'+
        '                "locationName": "Cardington",'+
        '                "isFirstAppointment": true,'+
        '                "isMobileLocation": false,'+
        '                "earlierAvailabilityDateHeader": "June 11, 2024",'+
        '                "slotSelectedDate": "",'+
        '                "serviceAppointmentId": "",'+
        '                "slotDate": "",'+
        '                "slotTime": "",'+
        '                "isDropOff": false,'+
        '                "slotDateTimeStart": "",'+
        '                "slotDateTimeFinish": "",'+
        '                "productAvailibilities": ['+
        '                    {'+
        '                        "Products": ['+
        '                            {'+
        '                                "productCode": "PSER00400A",'+
        '                                "productEnable": true,'+
        '                                "quantity": 1,'+
        '                                "isChecked": false'+
        '                            },'+
        '                            {'+
        '                                "productCode": "8580AGAGYVW",'+
        '                                "productEnable": false,'+
        '                                "quantity": 1,'+
        '                                "isChecked": false'+
        '                            }'+
        '                        ]'+
        '                    }'+
        '                ]'+
        '            }'+
        '        ]'+
        '    },'+
        '    {'+
        '        "ServiceLocationName": "SERVICE LOCATION CE Bedford",'+
        '        "ServiceLocationId": "389",'+
        '        "isPrimaryLocation": false,'+
        '        "ServiceLocationLabel": ['+
        '            {'+
        '                "ServiceLabel": "SERVICE LOCATION",'+
        '                "Product": "Products",'+
        '                "ProductNames": ['+
        '                    {'+
        '                        "productName": "ENVIRONMENTAL LEVY CHARGE WINDSCREEN",'+
        '                        "productCode": "PSER00400A",'+
        '                        "prodCategory": "WINDSCREEN"'+
        '                    },'+
        '                    {'+
        '                        "productName": "AUDI A3 3H/5B 2004-ON WINDSCREEN-GREEN SOLAR+ACOUSTIC+GREY TOP TINT+LOWER MOULDING+UPPER MOULDING+VIN",'+
        '                        "productCode": "8580AGAGYVW",'+
        '                        "prodCategory": "WINDSCREEN"'+
        '                    }'+
        '                ]'+
        '            }'+
        '        ],'+
        '        "EarliestAvailablity": ['+
        '            {'+
        '                "ServiceName": "CE Bedford",'+
        '                "EarliestAvailablity": "Earliest Availability",'+
        '                "productDate": ['+
        '                    {'+
        '                        "EarliestDate": "June 11, 2024",'+
        '                        "productCode": "PSER00400A"'+
        '                    },'+
        '                    {'+
        '                        "EarliestDate": "May 20, 2024",'+
        '                        "productCode": "8580AGAGYVW"'+
        '                    }'+
        '                ]'+
        '            }'+
        '        ],'+
        '        "Appointments": ['+
        '            {'+
        '                "appointmentName": "Appointment 1",'+
        '                "keyIndex": "0",'+
        '                "locationId": "389",'+
        '                "locationName": "CE Bedford",'+
        '                "isFirstAppointment": true,'+
        '                "isMobileLocation": true,'+
        '                "earlierAvailabilityDateHeader": "May 20, 2024",'+
        '                "slotSelectedDate": "",'+
        '                "serviceAppointmentId": "",'+
        '                "slotDate": "",'+
        '                "slotTime": "",'+
        '                "slotDateTimeStart": "",'+
        '                "slotDateTimeFinish": "",'+
        '                "ProductAvailibilities": ['+
        '                    {'+
        '                        "Products": ['+
        '                            {'+
        '                                "productCode": "PSER00400A",'+
        '                                "productEnable": false,'+
        '                                "quantity": 1,'+
        '                                "isChecked": true'+
        '                            },'+
        '                            {'+
        '                                "productCode": "8580AGAGYVW",'+
        '                                "productEnable": true,'+
        '                                "quantity": 1,'+
        '                                "isChecked": false'+
        '                            }'+
        '                        ]'+
        '                    }'+
        '                ]'+
        '            }'+
        '        ]'+
        '    }'+
        ']';
        System.assertNotEquals(appjson, null,'test');
        return appjson;
    }
     public static String newJsonV3(){
        String mainJson='{'+
        '  "status": "success",'+
        '  "quotes": ['+
        '    {'+
        '      "quoteId": "43723139",'+
        '      "locationId": "2515",'+
        '      "quoteTotals": {'+
        '        "totalPrice": 729.75,'+
        '        "totalTax": 145.95,'+
        '        "totalRepair": 0.0,'+
        '        "totalReplacement": 654.21,'+
        '        "totalCalibration": 0.0,'+
        '        "totalSundries": 0.0,'+
        '        "totalIncludingTax": 875.7'+
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
        '        "payableByMotoristReplacement": 654.21,'+
        '        "payableByMotoristCalibration": 0.0,'+
        '        "payableByMotoristSundry": 0.0,'+
        '        "totalTaxPayableByMotorist": 145.95,'+
        '        "totalPayableByMotorist": 729.75,'+
        '        "totalIncludingTaxPayableByMotorist": 875.7'+
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
        '      "discountThresholdA": 700.56,'+
        '      "discountThresholdB": 569.21,'+
        '      "discountThresholdC": 510.83,'+
        '      "priceExpirationDate": "2024-08-15T00:00:00Z",'+
        '      "lineItems": ['+
        '        {'+
        '          "lineItemId": 2,'+
        '          "parentLineItemId": 2,'+
        '          "bundleName": null,'+
        '          "partNumber": "8580AGAGYVW",'+
        '          "belronPartNumber": null,'+
        '          "partDescription": "AUDI A3 3H/5B 2004-ON WINDSCREEN-GREEN SOLAR+ACOUSTIC+GREY TOP TINT+LOWER MOULDING+UPPER MOULDING+VIN",'+
        '          "quantity": 1,'+
        '          "baseListPrice": 87.86,'+
        '          "netPrice": 87.86,'+
        '          "taxRate": 20.0,'+
        '          "totalTax": 17.57,'+
        '          "netPriceIncludingTax": 105.43,'+
        '          "selectProduct": false,'+
        '          "bomMandatory": false,'+
        '          "partOfBundle": false,'+
        '          "bundleHierarchy": null,'+
        '          "nonBundlePrice": null,'+
        '          "availabilityDetails": ['+
                   
        '          ],'+
        '          "parentBOMId": "APPOINTMENT_CODE",'+
        '          "leadingProductIndicator": false,'+
        '          "totalPayableByInsurance": 0,'+
        '          "totalTaxPayableByInsurance": 0,'+
        '          "totalIncludingTaxPayableByInsurance": 0,'+
        '          "totalPayableByMotorist": 17.57,'+
        '          "totalTaxPayableByMotorist": 87.86,'+
        '          "totalIncludingTaxPayableByMotorist": 105.43,'+
        '          "payableByTradeTotalTax": 0,'+
        '          "totalPayableByTrade": 0,'+
        '          "totalPayableByTradeIncludingTax": 0,'+
        '          "payableByTrade": "Motorist"'+
        '        }'+
        '      ]'+
        '    }'+
        '  ]'+
        '}';
        System.assertNotEquals(mainJson, null,'test');
        return mainJson;  
    }

    @isTest
    static void getARPTest() {
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :System.label.BLN_CustomerB2BAccount AND SObjectType = 'Account' LIMIT 1];
        
        // Create a test Account record for the query to find
        Account accountObj = new Account(
            Name = 'Test Account11',
            BLN_ClientType__c = 'Intercompany',
            BLN_ClientSubType__c = 'ISP',
            RecordTypeId = recordType.Id, // Assign the RecordType Id to the RecordTypeId field
            BLN_MDMAccountID__c = '145623', // Set this to a non-null value
            BillingStreet = 'UK',
            BLN_RegistrationAddress__Street__s = 'UK',
            ShippingStreet = 'GB'
        );
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        INSERT contractObj;
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        caseObj.AccountId = accountObj.Id;
        caseObj.Priority = System.label.BLN_Critical;
        INSERT caseObj;

        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.Name = 'Test';
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        INSERT prod;

       // Id pricebookId = Test.getStandardPricebookId();
        // Pricebook2 standardPricebook = new Pricebook2(
        //     Id = pricebookId,
        //     IsActive = true,
        //     Name = System.label.BLN_StandardPriceBook
        // );
        
        Id clientRT = SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get(System.label.BLN_ProductAllowanceRT).getRecordTypeId();
        BLN_AccountRuleParameter__c arp = new BLN_AccountRuleParameter__c();
        arp.BLN_Account__c = caseObj.AccountId;
        arp.BLN_ProductAllowance__c = 'Do Not Show';
        arp.BLN_ActiveFrom__c = Date.today();
        arp.BLN_ActiveTo__c= Date.today().addDays(3);
        arp.BLN_Product__c = prod.Id;
        arp.RecordTypeId = clientRT;
        insert arp;

        BLN_PortalProductAvailabilityRebook.ServiceLabel abc = new BLN_PortalProductAvailabilityRebook.ServiceLabel();
        abc.serviceLocation = 'abc';

        BLN_ProductAvailabilityUtility.getAccountRuleParameters(System.label.BLN_ProductAllowanceRT, caseObj.accountId != null ? caseObj.accountId : null, Date.today()); 
        // Verify the quoteType is set correctly
        System.assertEquals('Do Not Show', arp.BLN_ProductAllowance__c, 'test'); 
    }

    
}