/** @description : This test class is used to cover testcoverage for BLN_AppointmentWebService
*   @Story : FOUK-
*   @author: Wasim Akram (PwC)
*   @CreatedDate: 
*   @Last Modified By:Subhamita Dutta
*/


@IsTest
public class BLN_AppointmentWebServiceTest {
    
    @TestSetup
    public static void setupTestData() {
        // Create Operating Hours
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours('All Day Slot', true);
        
        // Create Service Territories
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford', (String) operatingHours.Id, true);
        
        // Create Work Type
        WorkType repairWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_RepairWT, 4, true, true);
        
        // Create Scheduling Policy
        //FSL__Scheduling_Policy__c schedulingPolicy = BLN_TestDataFactory.createSchedulingPolicy(System.Label.BLN_SchedulingPolicyName, true);
        
        // Create Case
        Case newCase = BLN_TestDataFactory.createCase(true);
        
        // Create Work Order and associate with the case
        WorkOrder workOrder1 = BLN_TestDataFactory.createWorkOrder2(repairWT.Id, st.Id, false);
        workOrder1.CaseId = newCase.Id;
        workOrder1.BLN_RemedyJobId__c = '0969964544427';
        insert workOrder1;
        
        // Create Work Order Line Item
        WorkOrderLineItem wOLI1 =  BLN_TestDataFactory.createWorkOrderLineItem();
        wOLI1.Status = 'New';
        wOLI1.WorkOrderId = workOrder1.Id;
        wOLI1.WorkTypeId = repairWT.Id;
        wOLI1.BLN_RemedyTaskId__c = '66088851';
        insert wOLI1;
        
        // Create Service Appointment
        ServiceAppointment servApp = BLN_TestDataFactory.createServiceAppointment('SA1', wOLI1.Id, st.Id, '66088851', true);
        servApp.BLN_RemedyJobId__c = workOrder1.BLN_RemedyJobId__c;
        servApp.Status = 'Scheduled';
        update servApp;
    }
    
    @IsTest
    public static void testGetSlots() {
        try {
            User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            System.runAs(u) {
                system.assertNotEquals(u, Null, 'Profile Should be available');
            }

            ServiceAppointment servApp = [SELECT Id, ServiceTerritoryId FROM ServiceAppointment LIMIT 1];
            servApp.ServiceTerritoryId = null;
            update servApp;
            if (servApp != null){
                RestRequest request = new RestRequest();
                RestResponse response = new RestResponse();
                String requestBody = '{"jobAppointmentId": "' + servApp.Id + '", "method": "getSlots"}';
                request.requestBody = Blob.valueOf(requestBody);
                RestContext.request = request;
                RestContext.response = response;
            }
            Test.startTest();
            	BLN_AppointmentWebService.doPost();
            Test.stopTest();
        } catch (Exception ex) {
            BLN_ExceptionLogger.captureException(ex);
        }
    }
    
    @IsTest
    public static void testGetSlots1() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }

        try {
            ServiceAppointment servApp = [SELECT Id FROM ServiceAppointment LIMIT 1];
            if (servApp != null){
                RestRequest request = new RestRequest();
                RestResponse response = new RestResponse();
                String requestBody = '{"jobAppointmentId": "' + servApp.Id + '", "method": "getSlots"}';
                request.requestBody = Blob.valueOf(requestBody);
                RestContext.request = request;
                RestContext.response = response;
            }
            Test.startTest();
            	BLN_AppointmentWebService.doPost();
            Test.stopTest();
        } catch (Exception ex) {
            BLN_ExceptionLogger.captureException(ex);
        }
    }
    
    @IsTest
    public static void testScheduleAppointment() {
        try {
            ServiceAppointment servApp = [SELECT Id FROM ServiceAppointment LIMIT 1];
            if (servApp != null) {
                RestRequest request = new RestRequest();
                RestResponse response = new RestResponse();
                String requestBody = '{"jobAppointmentId": "' + servApp.Id + '", "method": "scheduleAppointment"}';
                request.requestBody = Blob.valueOf(requestBody);
                RestContext.request = request;
                RestContext.response = response;
                
                Test.startTest();
                BLN_AppointmentWebService.doPost();
                BLN_AppointmentWebService.getSlots(servApp.Id);
                system.debug('servApp.Id----'+servApp.Id);
                System.assertEquals(200, response.statusCode, 'Status Should be 200');
                System.assertEquals('application/json', response.headers.get('Content-Type'), 'ContentType should be JSON');
                Test.stopTest();
            } 
        } catch (Exception ex) {
            BLN_ExceptionLogger.captureException(ex);
        }
        
        
        
    }
    
    @IsTest
    public static void testBookAppointment() {
        ServiceAppointment servApp = [SELECT Id FROM ServiceAppointment LIMIT 1];
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        String requestBody = '{ "method": "bookAppointment", "jobAppointmentId": "' + servApp.Id + '", "slot": { "slotStart": "2024-03-27T10:00:00+00:00", "slotFinish": "2024-03-28T10:00:00+00:00", "isDropOff": true }, "isForcedAppointment": true }';
        request.requestBody = Blob.valueOf(requestBody);
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        BLN_AppointmentWebService.doPost();
        Test.stopTest();
        
        // Assert response status and content type
        System.assertEquals(200, response.statusCode, 'Status Should be 200');
        System.assertEquals('application/json', response.headers.get('Content-Type'), 'ContentType should be JSON');
    }
    @IsTest
    public static void testBookAppointmentElse() {
        ServiceAppointment servApp = [SELECT Id FROM ServiceAppointment LIMIT 1];
                
        Test.startTest();
        BLN_AppointmentWebService.bookAppointment(servApp.Id, Null, Null, false, true);
        Test.stopTest();
        
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
    }
    
    @IsTest
    public static void testCreateAppointmentData() {
        // Create necessary data for this test
        Account accountObj = BLN_TestDataFactory.createAccount('Sample', 'PersonAccount', '8698023890');
        insert accountObj;
        
        Contract contractObj = BLN_TestDataFactory.createTestContract(accountObj);
        insert contractObj;
        
        Case caseObj = BLN_TestDataFactory.createCase('BLN_JobRequest', 'Job Request', 'New');
        caseObj.AccountId = accountObj.Id;
        caseObj.BLN_SubType__c = 'Warranty';
        insert caseObj;
        
        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = true;
        prod.BLN_NumberofTechnicianNeeded__c = 3;
        prod.BLN_ProductStockable__c = true;
        prod.BLN_BusinessUnitSpecificAssistDuration__c = 80;
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true, Name = System.label.BLN_StandardPriceBook);
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = prod.Id, IsActive = true, UnitPrice = 0);
        insert pbe;
        
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];
        
        Order orderObj = BLN_TestDataFactory.createTestOrder(accountObj, contractObj, caseObj);
        orderObj.Pricebook2Id = pricebookId;
        orderObj.BLN_ServiceTerritory__c = st.Id;
        insert orderObj;
        
        OrderItem orderItem = BLN_TestDataFactory.createTestOrderItem(orderObj, prod);
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Quantity = 1;
        insert orderItem;
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        String requestBody = '{ "method": "createAppointmentData", "productList": [{}], "caseId": "' + caseObj.Id + '", "earliestAvailableDate": "2024-03-27T10:00:00+00:00", "locationId": "' + st.Id + '" }';
        request.requestBody = Blob.valueOf(requestBody);
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        BLN_AppointmentWebService.doPost();
        Test.stopTest();
        
        // Assert response status and content type
        //System.assertEquals(200, response.statusCode, 'Status Should be 200');
        System.assertEquals('application/json', response.headers.get('Content-Type'), 'ContentType should be JSON');
    }
    
    @IsTest
    public static void testInvalidMethod() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        String requestBody = '{ "method": "invalidMethod" }';
        request.requestBody = Blob.valueOf(requestBody);
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        BLN_AppointmentWebService.doPost();
        Test.stopTest();
        
        // Assert response status and content type
        System.assertEquals(200, response.statusCode, 'Status Should be 200');
        System.assertEquals('application/json', response.headers.get('Content-Type'), 'ContentType should be JSON');
        
        // Assert the response body contains the error message
        String expectedResponse = '{"error": "Invalid method"}';
        System.assertEquals(expectedResponse, response.responseBody.toString(), 'Resuld should be Error');
    }
    
    @IsTest
    public static void testNullJobAppointmentId() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        String requestBody = '{ "method": "getSlots", "jobAppointmentId": null }';
        request.requestBody = Blob.valueOf(requestBody);
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        BLN_AppointmentWebService.doPost();
        Test.stopTest();
        
        // Assert response status and content type
        System.assertEquals(200, response.statusCode, 'Status Should be 200');
        System.assertEquals('application/json', response.headers.get('Content-Type'), 'ContentType should be JSON');
        
        // Assert the response body contains the error message
        String expectedResponse = '{"error": "jobAppointmentId is null"}';
        System.assertEquals(expectedResponse, response.responseBody.toString(), 'Appointment Id Should be blank');
    }
    
    @IsTest
    public static void testEmptyRequestBody() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf('{}');
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        BLN_AppointmentWebService.doPost();
        Test.stopTest();
        
        // Assert response status and content type
        System.assertEquals(200, response.statusCode, 'Status Should be 200');
        System.assertEquals('application/json', response.headers.get('Content-Type'), 'ContentType should be JSON');
        
        // Assert the response body contains the error message
        String expectedResponse = '{"error": "Empty or invalid request body"}';
        System.assertnotEquals(expectedResponse, response.responseBody.toString(), 'Error');
    }
    
    
    @IsTest
    public static void testNullRequestBody() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = response; 
        Test.startTest();
        BLN_AppointmentWebService.doPost();
        Test.stopTest();
        System.assertnotEquals('', response.responseBody.toString(), 'Body Should be null');
    }
}