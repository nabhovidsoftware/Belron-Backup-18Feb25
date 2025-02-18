/** @description :  Test Class for LAD_OrderHistoryHandler
*   @Story :        FOUK-9870; FOUK-9872
*   @author:        binayak.debnath@pwc.com (IN)
*   @CreatedDate:   10-09-2024
*/
@isTest
public class LAD_OrderHistoryHandlerTest {

    /**@MethodName :    testFetchOrderDetails
    * @description :    This method is used to test fetchOrderDetails method from LAD_OrderHistoryHandler class.
    * @param:           
    * @return:          
    */

    //(SeeAllData = true) is essential for using ConnectApi methods. We need ConnectApi methods to create Order Summary records.
    @isTest(SeeAllData = true) 
    static void testFetchOrderDetails(){
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
            /* PriceBookEntry testEntry = new PriceBookEntry(product2id = productList[i].id, pricebook2id = standardPricebook.Id, UnitPrice = 10);
            insert testEntry; */
            PriceBookEntry testEntry = [SELECT Id FROM PriceBookEntry WHERE pricebook2Id = :standardPriceBook.Id AND product2id = :productList[i].id LIMIT 1];
            OrderItem testOrdItem = new OrderItem(  product2id = productList[i].id,
                                                    Quantity = (i + 1) * 10,
                                                    OrderDeliveryGroupId = testOrdGroup.id, 
                                                    orderId = testOrder.id,
                                                    PriceBookEntryId = testEntry.Id,
                                                    unitprice = 0);
            insert testOrdItem; 
        }

        testOrder.OrderedDate = Date.today();
        testOrder.Status = 'Activated';

        update testOrder;

        ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();

        osir.orderId = testOrder.Id;
        osir.orderLifeCycleType='UNMANAGED';

        ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);

        System.debug([SELECT OrderedDate FROM OrderSummary WHERE Id = :osor.orderSummaryId]);

 

        LAD_OrderHistoryHandler.SearchParameters parameters = new LAD_OrderHistoryHandler.SearchParameters();
        parameters.effectiveAccountId = testAccount.Id;
        parameters.communityId = testStore.Id;
        LAD_OrderHistoryHandler.OrderDetailsWrapper mockWrapper = LAD_OrderHistoryHandler.fetchOrderDetails(parameters);

        Test.startTest();
        LAD_OrderHistoryHandler.allowException = false;
        parameters.startDate = String.valueOf(Date.today());
        parameters.endDate = String.valueOf(Date.today().addDays(1));
        LAD_OrderHistoryHandler.OrderDetailsWrapper returnWrapper = LAD_OrderHistoryHandler.fetchOrderDetails(parameters);
        Test.stopTest();
        System.assertEquals(true, returnWrapper.orderDetails.size() > 0);


    }

}