/** @description :  This is the test class for LAD_AmendOrderHandler and LAD_ReOrderHandler.
*   @Story :        FOUK-9073; FOUK-9872
*   @author:        (binayak.debnath@pwc.com (IN)) (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   18-07-2024
*/
@isTest
private class LAD_AmendOrderHandlerTest {


    // Test data setup
    @isTest(seealldata=true)
    static void setup() {
        Account testaccount =LAD_TestDataFactory.createAccount();
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = testaccount.Id;
        buyerAccount.Name = 'Test Buyer Account (BA-AJ)';
        buyerAccount.IsActive = true;
        insert buyerAccount;
        
        BuyerGroup bg=new BuyerGroup();
        bg.name='Test';
        bg.Role='AccountBased';
        insert bg;
        BuyerGroupMember bgm=new BuyerGroupMember();
        bgm.BuyerId =testaccount.id;
        bgm.BuyerGroupId=bg.id;
        insert bgm;
        
        Contact testContact = New Contact(LastName = 'Test', AccountID = testAccount.id);
        insert testContact;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
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
        
        Schema.location loc= new Schema.location();
        loc.Name = 'test';
        loc.LocationType = 'WAREHOUSE';
        loc.BLN_GUID__c = 'L19_UK';
        insert loc;
        
        
        AssociatedLocation testAssociatedLocation = new AssociatedLocation(LocationId = loc.id,
                                                                           LAD_Location_Type__c = 'Primary',
                                                                           ParentRecordId = testAccount.Id);
        insert testAssociatedLocation;
        
        Product2 testProduct = new Product2(Name = 'Test Product');
        insert testProduct;
        
        WebStore testStore = new WebStore(Name = 'test Store',
                                          OptionsAutoFacetingEnabled = true,
                                          OptionsCartToOrderAutoCustomFieldMapping = true,	
                                          OptionsCommerceEinsteinActivitiesTracked = true,	                                             
                                          OptionsCommerceEinsteinDeployed = true,	
                                          OptionsGuestBrowsingEnabled = true,	                                             
                                          OptionsSkipAdditionalEntitlementCheckForSearch = true);
        insert testStore;
        
        WebStoreBuyerGroup wsbg=new WebStoreBuyerGroup();
        wsbg.WebStoreId=testStore.id;
        wsbg.BuyerGroupid=bg.id;
        insert wsbg;

        //CART RELATED DATA
        WebCart testCart = new WebCart (Name = 'TestCart', WebStoreId = testStore.id, AccountId = testAccount.id);
        insert testCart;
        testCart.OwnerId = testUser.Id;
        update testCart;
        
        OrderDeliveryMethod testDelMethod = new OrderDeliveryMethod(name = 'TestMethod', isActive = true);
        insert testDelMethod;
        
        CartDeliveryGroup testGroup = new CartDeliveryGroup(Name = 'TestGroup', CartId = testCart.id, DeliveryMethodId = testDelMethod.Id);
        insert testGroup;
        
        String deliveryDate = Date.today().addDays(7).format();
        LAD_MDC_Preference__c mdcPreference = new LAD_MDC_Preference__c();
        mdcPreference.LAD_Account__c = testAccount.Id;
        mdcPreference.LAD_Delivery_Date__c = deliveryDate;
        mdcPreference.LAD_Associated_Location__c = testAssociatedLocation.Id;
        
        
        mdcPreference.LAD_Product__c = testProduct.id;
        
        
        mdcPreference.LAD_User__c = testUser.id;
        
        insert mdcPreference;

        List<cartitem> cartitemlist=new List<cartitem>();
        CartItem testItem = new CartItem(Name = 'TestItem', 
                                         Product2id = testProduct.id,
                                         Quantity = 10,
                                         CartDeliveryGroupId = testGroup.id, 
                                         CartId = testCart.id,
                                         LAD_Non_Returnable__c = true);
        insert testItem;
        cartitemlist.add(testItem);
        CartTax tax = new CartTax(  Amount = 50.0,
                                  CartItemId = testItem.id,
                                  Name = 'Sample',
                                  TaxCalculationDate = Date.today(),
                                  TaxRate = 0.5,
                                  TaxType = 'Actual');
        insert tax;


        //ORDER RELATED DATA

        Id pricebookId = Test.getStandardPricebookId();
      
        Order testOrder = new Order();
        testOrder.SalesStoreId = testStore.Id;
        testOrder.AccountId = testAccount.id;
        testOrder.Status = 'Draft';
        //testOrder.PoNumber = activeCart.PoNumber;
        //testOrder.LAD_Created_by_Upload__c = activeCart.LAD_Created_by_Upload__c;
        testOrder.Pricebook2Id = pricebookId;
        testOrder.EffectiveDate = Date.today();
        testOrder.Description = 'Test';
        insert testOrder;
      
		testCart.LAD_Order__c=testOrder.id;
        update testCart;
        OrderDeliveryGroup testOrdGroup = new OrderDeliveryGroup(   
            LAD_Name__c = 'Laddaw-Delivery-0001', 
                                                                    OrderId = testOrder.id, 
                                                                    OrderDeliveryMethodId = testDelMethod.Id, 
                                                                    DeliverToName = testUser.FirstName);
        insert testOrdGroup;
        pricebookentry fetchPBentry=[select id from pricebookentry where product2id=:testProduct.id];
        OrderItem testOrdItem = new OrderItem(  product2id = testProduct.id,
                                                Quantity = 10,
                                                OrderDeliveryGroupId = testOrdGroup.id, 
                                                orderId = testOrder.id,
                                                PriceBookEntryId = fetchPBentry.Id,
                                             	unitprice=0);
        insert testOrdItem;


        OrderItemAdjustmentLineItem oial=new OrderItemAdjustmentLineItem();
        oial.Name='test';
        oial.OrderItemId=testOrdItem.id;
        oial.AdjustmentValue =100;
        oial.Amount=100;
        insert oial;

        OrderItemTaxLineItem ordtax = new OrderItemTaxLineItem( Amount = 50.0,
                                                                OrderItemId = testOrdItem.id,
                                                                Name = 'Sample',
                                                                TaxeffectiveDate = Date.today(),
                                                                Type = 'Actual');
        insert ordtax;

        testOrder.Status = 'Activated';
        testOrder.OrderedDate = Datetime.now();
        update testOrder;
        LAD_AmendOrderHandler.isTest=true;
        //LAD_AmendOrderHandler.cartIdMock=testCart.id;
        LAD_AmendOrderHandler.orderIdfromtest=testOrder.id;
       Order orderDetail=[select 	id,
                                        name,
                                        accountId,
                                        SalesStoreId,
                                        POnumber,
                             			Description,
                                        (SELECT Id, 
                                                OrderDeliveryGroupId,
                                                OrderDeliveryGroup.LAD_Name__c,
                                                OrderDeliveryGroup.DeliverToStreet,
                                                OrderDeliveryGroup.DeliverToCity,
                                                OrderDeliveryGroup.DeliverToState,
                                                OrderDeliveryGroup.DeliverToPostalCode,
                                                OrderDeliveryGroup.DeliverToCountry,
                                                OrderDeliveryGroup.OrderDeliveryMethodId,
                                                OrderDeliveryGroup.DesiredDeliveryDate,
                                                OrderDeliveryGroup.LAD_Date_Selected_By_Customer__c, //FOUK-9758 & FOUK-9759
                                                Product2Id,
                                                Product2.Name, 
                                                TotalLineTaxAmount, 
                                                Quantity, 
                                                LAD_PO_Number__c
                                            FROM orderItems),
                                     (select id,
                                          LAD_Name__c,
                                          DeliverToStreet,
                                          DeliverToCity,
                                          DeliverToState,
                                          DeliverToPostalCode,
                                          DeliverToCountry,
                                          DeliverToName,
                                          OrderDeliveryMethodId,
                                          DesiredDeliveryDate,
                                          LAD_Date_Selected_By_Customer__c
                                          from OrderDeliveryGroups),
                                    (SELECT AdjustmentValue,
                                      AdjustmentType,
                                      AdjustmentAmountScope,
                                      AdjustmentSource,
                                      AdjustmentBasisReferenceId,
                                      AdjustmentCauseId,
                                      TotalAmtWithTax,
                                      OrderAdjustmentGroupId,
                                      TotalTaxAmount,
                                      Description,
                                      RelatedAdjustmentLineItemId,
                                      OrderId,
                                      Amount,
                                      OrderItemId,
                                    OrderItem.product2id,
                                      Id,
                                      Name,
                                      CurrencyIsoCode 
                                      FROM OrderItemAdjustmentLineItems)
                                         from order 
                                         where id=:testOrder.id];

        Test.startTest();
        LAD_ReOrderHandler.ReorderParamters reorderParameters = new LAD_ReOrderHandler.ReorderParamters();
        reorderParameters.orderSummaryId = testOrder.Id;
        reorderParameters.userId = testUser.Id;
        LAD_ReOrderHandler.testOrderId = testOrder.Id;
        String retString = LAD_ReOrderHandler.executeReorder(reorderParameters);
        Test.stopTest();

        List<OrderItem> orderList = LAD_AmendOrderHandler.fetchExistingOrderDetails(testCart.id);
		LAD_AmendOrderHandler.orderAmendmentViability(testOrder.id);
		LAD_AmendOrderHandler.orderAmendmentViabilityDetailsPage('001');
        LAD_AmendOrderHandler.fetchExistingOrderDetails(testCart.id);
        LAD_AmendOrderHandler.processAmendOrder(testCart.id,'test');
        LAD_AmendOrderHandler.handlePriceAdjustment(orderDetail,cartitemlist,testCart.id);
        LAD_amendOrderhandler.doesCartExist(testUser.id,testaccount.id);     
    }
    
     // Test data setup
    @isTest(seealldata=true)
    static void test2() {
        Account testaccount =LAD_TestDataFactory.createAccount();
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = testaccount.Id;
        buyerAccount.Name = 'Test Buyer Account (BA-AJ)';
        buyerAccount.IsActive = true;
        insert buyerAccount;
        
        BuyerGroup bg=new BuyerGroup();
        bg.name='Test';
        bg.Role='AccountBased';
        insert bg;
        BuyerGroupMember bgm=new BuyerGroupMember();
        bgm.BuyerId =testaccount.id;
        bgm.BuyerGroupId=bg.id;
        insert bgm;
        
        Contact testContact = New Contact(LastName = 'Test', AccountID = testAccount.id);
        insert testContact;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
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
        
        Schema.location loc= new Schema.location();
        loc.Name = 'test';
        loc.LocationType = 'WAREHOUSE';
        loc.BLN_GUID__c = 'L19_UK';
        insert loc;
        
        
        AssociatedLocation testAssociatedLocation = new AssociatedLocation(LocationId = loc.id,
                                                                           LAD_Location_Type__c = 'Primary',
                                                                           ParentRecordId = testAccount.Id);
        insert testAssociatedLocation;
        
        Product2 testProduct = new Product2(Name = 'Test Product');
        insert testProduct;
        
        WebStore testStore = new WebStore(Name = 'test Store',
                                          OptionsAutoFacetingEnabled = true,
                                          OptionsCartToOrderAutoCustomFieldMapping = true,	
                                          OptionsCommerceEinsteinActivitiesTracked = true,	                                             
                                          OptionsCommerceEinsteinDeployed = true,	
                                          OptionsGuestBrowsingEnabled = true,	                                             
                                          OptionsSkipAdditionalEntitlementCheckForSearch = true);
        insert testStore;
        
        WebStoreBuyerGroup wsbg=new WebStoreBuyerGroup();
        wsbg.WebStoreId=testStore.id;
        wsbg.BuyerGroupid=bg.id;
        insert wsbg;

        //CART RELATED DATA
        WebCart testCart = new WebCart (Name = 'TestCart', WebStoreId = testStore.id, AccountId = testAccount.id);
        insert testCart;
        testCart.OwnerId = testUser.Id;
        update testCart;
        
        OrderDeliveryMethod testDelMethod = new OrderDeliveryMethod(name = 'TestMethod', isActive = true);
        insert testDelMethod;
        
        CartDeliveryGroup testGroup = new CartDeliveryGroup(Name = 'TestGroup', CartId = testCart.id, DeliveryMethodId = testDelMethod.Id);
        insert testGroup;
        
        String deliveryDate = Date.today().addDays(7).format();
        LAD_MDC_Preference__c mdcPreference = new LAD_MDC_Preference__c();
        mdcPreference.LAD_Account__c = testAccount.Id;
        mdcPreference.LAD_Delivery_Date__c = deliveryDate;
        mdcPreference.LAD_Associated_Location__c = testAssociatedLocation.Id;
        
        
        mdcPreference.LAD_Product__c = testProduct.id;
        
        
        mdcPreference.LAD_User__c = testUser.id;
        
        insert mdcPreference;
        CartItem testItem = new CartItem(Name = 'TestItem', 
                                         Product2id = testProduct.id,
                                         Quantity = 10,
                                         CartDeliveryGroupId = testGroup.id, 
                                         CartId = testCart.id,
                                         LAD_Non_Returnable__c = true);
        insert testItem;
        
        CartTax tax = new CartTax(  Amount = 50.0,
                                  CartItemId = testItem.id,
                                  Name = 'Sample',
                                  TaxCalculationDate = Date.today(),
                                  TaxRate = 0.5,
                                  TaxType = 'Actual');
        insert tax;


        //ORDER RELATED DATA

        Id pricebookId = Test.getStandardPricebookId();

        Order testOrder = new Order();
        testOrder.SalesStoreId = testStore.Id;
        testOrder.AccountId = testAccount.id;
        testOrder.Status = 'Draft';
        //testOrder.PoNumber = activeCart.PoNumber;
        //testOrder.LAD_Created_by_Upload__c = activeCart.LAD_Created_by_Upload__c;
        testOrder.Pricebook2Id = pricebookId;
        testOrder.EffectiveDate = Date.today();
        testOrder.Description = 'Test';
        insert testOrder;
		testCart.LAD_Order__c=testOrder.id;
        update testCart;
        OrderDeliveryGroup testOrdGroup = new OrderDeliveryGroup(   
            LAD_Name__c = 'Laddaw-Delivery-0001', 
                                                                    OrderId = testOrder.id, 
                                                                    OrderDeliveryMethodId = testDelMethod.Id, 
                                                                    DeliverToName = testUser.FirstName);
        insert testOrdGroup;
        pricebookentry fetchPBentry=[select id from pricebookentry where product2id=:testProduct.id];

        OrderItem testOrdItem = new OrderItem(  product2id = testProduct.id,
                                                Quantity = 10,
                                                OrderDeliveryGroupId = testOrdGroup.id, 
                                                orderId = testOrder.id,
                                                PriceBookEntryId = fetchPBentry.Id,
                                             	unitprice=0);
        insert testOrdItem;

        OrderItemTaxLineItem ordtax = new OrderItemTaxLineItem( Amount = 50.0,
                                                                OrderItemId = testOrdItem.id,
                                                                Name = 'Sample',
                                                                TaxeffectiveDate = Date.today(),
                                                                Type = 'Actual');
        insert ordtax;
OrderItemAdjustmentLineItem oial=new OrderItemAdjustmentLineItem();
        oial.Name='test';
        oial.OrderItemId=testOrdItem.id;
        oial.AdjustmentValue =100;
        oial.Amount=100;
        insert oial;
        testOrder.Status = 'Activated';
        testOrder.OrderedDate = Datetime.now();
        update testOrder;
        LAD_AmendOrderHandler.isTest=true;
        //LAD_AmendOrderHandler.cartIdMock=testCart.id;
        LAD_AmendOrderHandler.orderIdfromtest=testOrder.id;
    	
        
        ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
		osir.orderId = testOrder.Id;
   		osir.orderLifeCycleType = 'UNMANAGED';
    	ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        
        List<OrderItemSummary> ois = [SELECT Id, LAD_Non_Returnable_Flag__c FROM OrderItemSummary WHERE OrderSummaryId=:osor.orderSummaryId];
        for(OrderItemSummary oi: ois){
            oi.LAD_Non_Returnable_Flag__c=true;
        }
        update ois;
    	
         delete [select id from webcart where accountid=:testaccount.id];
        LAD_AmendOrderHandler.OrderWrapper parameters = new LAD_AmendOrderHandler.OrderWrapper();
        parameters.orderSummaryId = testOrder.Id;
        parameters.userId = testUser.Id;
        parameters.isAmend = true;
        parameters.isReorder = false;
        LAD_AmendOrderHandler.amendOrderController(parameters);


        Test.startTest();
        LAD_ReOrderHandler.ReorderParamters reorderParameters = new LAD_ReOrderHandler.ReorderParamters();
        reorderParameters.orderSummaryId = testOrder.Id;
        reorderParameters.userId = testUser.Id;
        System.runAs(testUser){
            String retString = LAD_ReOrderHandler.executeReorder(reorderParameters);
        }   
        Test.stopTest();
    }

     
   
     
}