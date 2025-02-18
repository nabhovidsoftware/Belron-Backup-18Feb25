/** @description :  This is the test class for LAD_FrequentlyOrderedHandler
*   @Story :        FOUK-9940
*   @author:        binayak.debnath@pwc.com (IN)
*   @CreatedDate:   04-09-2024
*/

@isTest
public class LAD_FrequentlyOrderedHandlerTest {
    @TestSetup
    static void testdata(){
        Account testAccount = new Account(Name = 'ABC Corp');
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAD_B2B_Commerce_Account').getRecordTypeId();
        testAccount.RecordTypeId = recordTypeId;
        insert testAccount;
        Contact testContact = New Contact(LastName = 'Test', AccountID = testAccount.id);
        insert testContact;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Laddaw B2B Commerce External User' LIMIT 1];
        user testUser = New User(UserName = 'test_' + math.random() + '@test.com',
                                 FirstName = 'Test-First',
                                 LastName = 'Test-Last',
                                 Alias = 'test',
                                 email = 'test' + math.random() + '@test.com',
                                 CommunityNickName = string.valueOf(math.random()).substring(0,6),
                                 ProfileID = p.id,
                                 ContactId = testContact.Id,
                                 TimeZoneSidKey = 'America/New_York', 
                                 LocaleSidKey = 'en_US', 
                                 EmailEncodingKey = 'UTF-8', 
                                 LanguageLocaleKey = 'en_US');
        insert testUser; 
        
        Product2 testProduct1 = new Product2(Name = 'Test Product 1', ProductCode = 'Prod1');
        Product2 testProduct2 = new Product2(Name = 'Test Product 2', ProductCode = 'Prod2');
        Product2 testProduct3 = new Product2(Name = 'Test Product 3', ProductCode = 'Prod3');

        insert testProduct1;
        insert testProduct2;
        insert testProduct3;

        Product2 testProduct4 = new Product2(Name = 'Test Product 4');
        insert testProduct4;

        WebStore testStore = new WebStore(Name = 'test Store',
                                          OptionsAutoFacetingEnabled = true,
                                          OptionsCartToOrderAutoCustomFieldMapping = true,	
                                          OptionsCommerceEinsteinActivitiesTracked = true,	                                             
                                          OptionsCommerceEinsteinDeployed = true,	
                                          OptionsGuestBrowsingEnabled = true,	                                             
                                          OptionsSkipAdditionalEntitlementCheckForSearch = true);
        insert testStore;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;

        Order testOrder = new Order();
        testOrder.SalesStoreId = testStore.Id;
        testOrder.AccountId = testAccount.id;
        testOrder.Status = 'Draft';
        //testOrder.PoNumber = activeCart.PoNumber;
        //testOrder.LAD_Created_by_Upload__c = activeCart.LAD_Created_by_Upload__c;
        testOrder.Pricebook2Id = standardPricebook.Id;
        testOrder.EffectiveDate = Date.today();
        testOrder.Description = 'Test';
        insert testOrder;
      
		OrderDeliveryMethod testDelMethod = new OrderDeliveryMethod(name = 'TestMethod', isActive = true);
        insert testDelMethod;

        OrderDeliveryGroup testOrdGroup = new OrderDeliveryGroup(   
                                                                    LAD_Name__c = 'Laddaw-Delivery-0001', 
                                                                    OrderId = testOrder.id, 
                                                                    OrderDeliveryMethodId = testDelMethod.Id, 
                                                                    DeliverToName = testUser.FirstName);
        insert testOrdGroup;

        List<Product2> productList = new List<Product2>{testProduct1, testProduct2, testProduct3};

        
        for(Integer i = 0; i < productList.size() ; i ++ ){
            PriceBookEntry testEntry = new PriceBookEntry(product2id = productList[i].id, pricebook2id = standardPricebook.Id, UnitPrice = 0);
            insert testEntry;
            OrderItem testOrdItem = new OrderItem(  product2id = productList[i].id,
                                                    Quantity = (i + 1) * 10,
                                                    OrderDeliveryGroupId = testOrdGroup.id, 
                                                    orderId = testOrder.id,
                                                    PriceBookEntryId = testEntry.Id,
                                                    unitprice = 0);
            insert testOrdItem; 
        }
    
        PriceBookEntry testEntry4 = new PriceBookEntry(product2id = testProduct4.id, pricebook2id = standardPricebook.Id, UnitPrice = 0);
        insert testEntry4;
    }

    @isTest
    public static void testFetchFreqOrderedProduct(){
        String accountId = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        string webstoreId = [SELECT Id FROM Webstore WHERE Name = 'test Store' LIMIT 1].Id;
        Test.startTest();
        LAD_FrequentlyOrderedHandler.allowException = false;
        List<LAD_FrequentlyOrderedHandler.ProductWrapper> returnList = LAD_FrequentlyOrderedHandler.fetchFreqOrderedProducts(accountId, webstoreId);
        Test.stopTest();
        System.assertEquals(true, returnList.size() > 0);
    }

    @isTest
    public static void testException(){
        String accountId = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        string webstoreId = [SELECT Id FROM Webstore WHERE Name = 'test Store' LIMIT 1].Id;
        String product4Id = [SELECT Id FROM Product2 WHERE Name = 'Test Product 4' LIMIT 1].Id;
        String testEntry4Id = [SELECT Id FROM PriceBookEntry WHERE product2id = :product4Id LIMIT 1].Id;
        String ordDelGrpId = [SELECT Id FROM OrderDeliveryGroup WHERE LAD_Name__c = 'Laddaw-Delivery-0001' LIMIT 1].Id;
        String testOrderId = [SELECT Id FROM Order WHERE AccountId = :accountId LIMIT 1].Id;

        
        OrderItem testOrdItem = new OrderItem(  product2id = product4Id,
                                                Quantity = 5 * 10,
                                                OrderDeliveryGroupId = ordDelGrpId, 
                                                orderId = testOrderId,
                                                PriceBookEntryId = testEntry4Id,
                                                unitprice = 0);
        insert testOrdItem;
        Test.startTest();
        LAD_FrequentlyOrderedHandler.allowException = true;
        List<LAD_FrequentlyOrderedHandler.ProductWrapper> exceptionList = LAD_FrequentlyOrderedHandler.fetchFreqOrderedProducts(accountId, webstoreId);
        Test.stopTest();
    }
}