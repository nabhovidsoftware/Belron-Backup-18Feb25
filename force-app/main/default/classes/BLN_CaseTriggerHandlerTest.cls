/** @description : The Apex test class for BLN_CaseTriggerHandler
*   @Story : FOUK-5034
*   @author: Rahul Jain(PwC IN)
*   @CreatedDate: 19/06/2024
*/ 
@isTest
public class BLN_CaseTriggerHandlerTest {
    @isTest
    static void setup() {
        //string vehicleType;
        // Create test Accounts
        Account acc1 = new Account(Name = 'Test Acc 1');
        Account acc2 = new Account(Name = 'Test Acc 2');
        insert new List<Account>{ acc1, acc2 };
        // Create test Products
        Product2 prod1 = new Product2(Name = 'Product1', isActive = true, ProductCode = 'PSER01227A',
                                      BLN_ProductCategory__c = 'Windscreen', LAD_Vehicle_Hole__c = 'Front Glass',
                                      BLN_ProductType__c = 'TMD_CAT_1- Windscreen', LAD_Vehicle_Type__c = '00');
        Product2 prod2 = new Product2(Name = 'Product2', isActive = true, ProductCode = 'PSER01237A',
                                      BLN_ProductCategory__c = 'Windscreen', LAD_Vehicle_Hole__c = 'Front Glass',
                                      BLN_ProductType__c = 'TMD_CAT_1- Windscreen', LAD_Vehicle_Type__c = '00'); 
        Product2 prod3 = new Product2(Name = 'Product3', isActive = true, ProductCode = 'PSER01228A',
                                      BLN_ProductCategory__c = 'Windscreen', LAD_Vehicle_Hole__c = 'Front Glass',
                                      BLN_ProductType__c = 'TMD_CAT_1- Windscreen', LAD_Vehicle_Type__c = '02');
        Product2 prod4 = new Product2(Name = 'Product4', isActive = true, ProductCode = 'PSER01229A',
                                      BLN_ProductCategory__c = 'Windscreen', LAD_Vehicle_Hole__c = 'Rear Glass',
                                      BLN_ProductType__c = 'TMD_CAT_1- Windscreen', LAD_Vehicle_Type__c = '02');
        insert new List<Product2>{ prod1, prod2, prod3, prod4 };
        
        // Create test Cases
        Case case1 = new Case(Status = 'Open', AccountId = acc1.id, Type = 'Job Request');
        Case case2 = new Case(Status = 'Open', AccountId = acc2.id, Type = 'Job Request');
        insert new List<Case>{ case1, case2 };
            
        Id pricebookId = Test.getStandardPricebookId();
        // Insert PricebookEntries
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod3.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod4.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert new List<PricebookEntry>{ standardPrice1, standardPrice2, standardPrice3, standardPrice4 };
            
        // Create test Orders and OrderItems
        Order order1 = new Order(Status = 'Draft', AccountId = acc1.id, Pricebook2Id = pricebookId, BLN_Case__c = case1.Id, EffectiveDate = System.Today() - 5);
        Order order2 = new Order(Status = 'Draft', AccountId = acc2.id, Pricebook2Id = pricebookId, BLN_Case__c = case2.Id, EffectiveDate = System.Today() - 5);
        insert new List<Order>{ order1, order2 };
        OrderItem orderItem1 = new OrderItem(OrderId = order1.Id, BLN_IsProductSelected__c = true, PricebookEntryId = standardPrice1.id, Product2Id = prod1.Id, Quantity = 1, UnitPrice = 0, ListPrice = 0);
        OrderItem orderItem2 = new OrderItem(OrderId = order1.Id, BLN_IsProductSelected__c = true, PricebookEntryId = standardPrice2.id, Product2Id = prod2.Id, Quantity = 1, UnitPrice = 0, ListPrice = 0);
        OrderItem orderItem3 = new OrderItem(OrderId = order2.Id, BLN_IsProductSelected__c = true, PricebookEntryId = standardPrice3.id, Product2Id = prod3.Id, Quantity = 1, UnitPrice = 0, ListPrice = 0);
        OrderItem orderItem4 = new OrderItem(OrderId = order2.Id, BLN_IsProductSelected__c = true, PricebookEntryId = standardPrice4.id, Product2Id = prod4.Id, Quantity = 1, UnitPrice = 0, ListPrice = 0);
        insert new List<OrderItem>{ orderItem1, orderItem2, orderItem3, orderItem4 };
        order1.Status = 'Accepted';
        order2.Status = 'Accepted';
        update new List<Order>{ order1, order2 };
            
        //Case case1 = [SELECT Id, Status FROM Case WHERE AccountId IN (SELECT Id FROM Account WHERE Name = 'Test Acc 1') LIMIT 1];
        //Case case2 = [SELECT Id, Status FROM Case WHERE AccountId IN (SELECT Id FROM Account WHERE Name = 'Test Acc 2') LIMIT 1];
        case1.Status = 'Closed';
        case2.Status = 'Closed';
        
        // Create a list of new cases with updated status
        List<Case> newCaseList = new List<Case>{ case1, case2 };
        // Create a map of old cases
            Map<Id, Case> oldCaseMap = new Map<Id, Case>{
                case1.Id => case1.clone(false, false, false, false),
                case2.Id => case2.clone(false, false, false, false)
            };
       	oldCaseMap.get(case1.Id).Status = 'Open';
        oldCaseMap.get(case2.Id).Status = 'Open';
        
        // Create the vehicletypeMap
        Map<String, List<Id>> vehicletypeMap = new Map<String, List<Id>>();
        vehicletypeMap.put('01', new List<Id>{ prod1.Id, prod2.Id });
        // Instantiate the controller and call the method
        //string mapKey = 'Same Product';
        //BLN_CaseTriggerHandler classinstance = new BLN_CaseTriggerHandler();

        Test.startTest();
        //classinstance.applyProductRestriction(mapKey, vehicletypeMap, newCaseList, oldCaseMap);
        test.setmock(httpcalloutmock.class, new MockResponseGenerator());
        BLN_CaseTriggerHandler.beforeUpdate(newCaseList, oldCaseMap);
        BLN_CaseTriggerHandler.afterInsert(newCaseList, oldCaseMap);
        BLN_CaseTriggerHandler.afterUpdate(newCaseList, oldCaseMap);
        
        Test.stopTest();
        Case updatedCase1 = [SELECT Id, Status FROM Case WHERE Id = :case1.Id];
        Case updatedCase2 = [SELECT Id, Status FROM Case WHERE Id = :case2.Id];
        update new List<Case>{ updatedCase1, updatedCase2 };
            for (Case c : newCaseList) {
                System.assertEquals('Closed', c.Status, 'Case ID ' + c.Id + ' should be closed.');
            }
    }
    public class MockResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String jsonRes =		'{}';
            //String contentType = 'application/x-www-form-urlencoded';
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
}