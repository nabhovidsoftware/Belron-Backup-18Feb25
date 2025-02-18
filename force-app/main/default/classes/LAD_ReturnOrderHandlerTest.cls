/** @description :  Test Class for LAD_ReturnOrderHandler
*   @Story :        
*   @author:        (ashwin.r.raja@pwc.com (IN))
*   @CreatedDate:   30-09-2024
*/

@isTest
public class LAD_ReturnOrderHandlerTest {
    
    @isTest(seeAllData=True)
    static void testReturnCreation(){
        Account testaccount = new Account(Name = 'ABC Corp');
        insert testaccount;
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
        
        Contact testContact = New Contact(LastName = 'Test', AccountID = testAccount.id, LAD_Role__c='Wholesale Manager');
        insert testContact;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Laddaw B2B Commerce External User' LIMIT 1];
        user testUser = New User(UserName = 'test_' + math.random() + '@test.com',
                                 FirstName = 'Test-First',
                                 LastName = 'Test-Last',
                                 Alias = 'test',
                                 email = 'test' + math.random() + '@test.com',
                                 CommunityNickName = string.valueOf(math.random()).substring(0,6),
                                 ProfileID = p.id,
                                 Phone = '9999888822',
                                 ContactId = testContact.Id,
                                 TimeZoneSidKey = 'America/New_York', 
                                 LocaleSidKey = 'en_US', 
                                 EmailEncodingKey = 'UTF-8', 
                                 LanguageLocaleKey = 'en_US');
        insert testUser; 
        
        Schema.location loc1= new Schema.location();
        loc1.Name = 'test1';
        loc1.LocationType = 'WAREHOUSE';
        loc1.BLN_GUID__c = 'L19_UK';
        insert loc1;
        
        Schema.location loc2= new Schema.location();
        loc2.Name = 'test2';
        loc2.LocationType = 'WAREHOUSE';
        loc2.BLN_GUID__c = 'L20_UK';
        insert loc2;
        
        ContactPointAddress testContactPointAddress1 = new ContactPointAddress(Name='Test CPA', City='Toronto', Country='US', street='Random street 1');
        insert testContactPointAddress1;
        ContactPointAddress testContactPointAddress2 = new ContactPointAddress(Name='Test CPA', City='Toronto', Country='US', street='Random street 2');
        insert testContactPointAddress2;
        
        AssociatedLocation testAssociatedLocation1 = new AssociatedLocation(LocationId = loc1.id,
                                                                           LAD_Location_Type__c = 'Primary',
                                                                           ParentRecordId = testAccount.Id);
        insert testAssociatedLocation1;
        
        LAD_Assigned_Address__c testAssignedAddress1= new LAD_Assigned_Address__c(LAD_Address__c = testContactPointAddress1.Id, LAD_Account__c = testAccount.Id, LAD_Assigned_MDC__c = testAssociatedLocation1.Id );
        insert testAssignedAddress1;
        
        AssociatedLocation testAssociatedLocation2 = new AssociatedLocation(LocationId = loc2.id,
                                                                            ParentRecordId = testAccount.Id,
                                                                            Type='Ship To');
        insert testAssociatedLocation2;
        
        LAD_Assigned_Address__c testAssignedAddress2= new LAD_Assigned_Address__c(LAD_Address__c = testContactPointAddress2.Id, LAD_Account__c = testAccount.Id, LAD_Assigned_MDC__c = testAssociatedLocation2.Id);
        insert testAssignedAddress2;
        
        Product2 testProduct = new Product2(Name = 'Test Product');
        Product2 testProduct1 = new Product2(Name = 'Test Product 1', ProductCode = 'Prod1');
        Product2 testProduct2 = new Product2(Name = 'Test Product 2', ProductCode = 'Prod2');

        insert testProduct;
        insert testProduct1;
        insert testProduct2;
        
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
        
        OrderDeliveryMethod testDelMethod = new OrderDeliveryMethod(name = 'TestMethod', isActive = true);
        insert testDelMethod;
        
        Id pricebookId = Test.getStandardPricebookId();
      
        Order testOrder = new Order();
        testOrder.SalesStoreId = testStore.Id;
        testOrder.AccountId = testAccount.id;
        testOrder.Status = 'Draft';
        testOrder.Pricebook2Id = pricebookId;
        testOrder.EffectiveDate = Date.today();
        testOrder.Name = 'Test Order';
        testOrder.Status='Draft';
        insert testOrder;
        
        
        OrderDeliveryGroup testOrdGroup = new OrderDeliveryGroup(   
         															LAD_Name__c = 'Laddaw-Delivery-0001', 
                                                                    OrderId = testOrder.id, 
                                                                    OrderDeliveryMethodId = testDelMethod.Id, 
                                                                    DeliverToName = testUser.FirstName,
            														LAD_Deliver_to_Location__c = loc1.Id
        														);
        insert testOrdGroup;
        
        pricebookentry fetchPBentry=[select id from pricebookentry where product2id=:testProduct.id];
        pricebookentry fetchPBentry2=[select id from pricebookentry where product2id=:testProduct2.id];
        
        OrderItem testOrdItem = new OrderItem(  product2id = testProduct.id,
                                                Quantity = 10,
                                                OrderDeliveryGroupId = testOrdGroup.id, 
                                                orderId = testOrder.id,
                                                PriceBookEntryId = fetchPBentry.Id,
                                             	unitprice=0);
        OrderItem testOrdItem2 = new OrderItem(  product2id = testProduct2.id,
                                                Quantity = 10,
                                                OrderDeliveryGroupId = testOrdGroup.id, 
                                                orderId = testOrder.id,
                                                PriceBookEntryId = fetchPBentry2.Id,
                                             	unitprice=0);
        insert testOrdItem;
        insert testOrdItem2;
        
        Order currOrder = [SELECT Id, Status FROM Order WHERE Id=:testOrder.Id];
        currOrder.Status='Activated';
        update currOrder;
        
        ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
		osir.orderId = currOrder.Id;
   		osir.orderLifeCycleType = 'UNMANAGED';
    	ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        //OrderSummary os = [SELECT Id, Status,LAD_Invoiced_Date__c FROM OrderSummary WHERE Id =:osor.orderSummaryId];
        //update os;
        LAD_Financial_Document__c finDoc = new LAD_Financial_Document__c(LAD_Order_Summary__c = osor.orderSummaryId, LAD_Oracle_Id__c='Test_Oracle_Id', LAD_Type__c='Invoice',
                                                                         LAD_Account__c =testaccount.Id, LAD_Total_Amount__c=100, LAD_Remaining_Amount__c=50, 
                                                                         LAD_Due_Date__c = System.today()+10, LAD_Status__c='Open');
        insert finDoc;
        List<OrderItemSummary> ois = [SELECT Id, LAD_Invoice__c,OrderSummaryId FROM OrderItemSummary WHERE OrderSummaryId=:osor.orderSummaryId];
        for(OrderItemSummary oi: ois){
            oi.LAD_Invoice__c=finDoc.Id;
        }
        update ois;
        
        LAD_ReturnOrderHandler.ReturnOrderWrapper returnOrd = new LAD_ReturnOrderHandler.ReturnOrderWrapper();
        LAD_ReturnOrderHandler.ReturnOrderItemWrapper ri1 = new LAD_ReturnOrderHandler.ReturnOrderItemWrapper();
        LAD_ReturnOrderHandler.ReturnOrderItemWrapper ri2 = new LAD_ReturnOrderHandler.ReturnOrderItemWrapper();
        List<LAD_ReturnOrderHandler.ReturnOrderItemWrapper> returnItems = new List<LAD_ReturnOrderHandler.ReturnOrderItemWrapper>();
        
        ri1.returnAddress = testContactPointAddress1.Id;
        ri1.Id = ois[0].Id;
        ri1.productId = testProduct.Id;
        ri1.productName = testProduct.Name;
        ri1.returnReason = 'UK12';
        ri1.quantity = 2;
        ri1.quantityReturnable = 2;
        ri1.quantityReturned = 2;
        ri1.returnDate = System.Today();
        ri1.returnMethod = 	'Laddaw Collect';
        
        ri2.returnAddress = testContactPointAddress2.Id;
        ri2.Id = ois[1].Id;
        ri2.productId = testProduct2.Id;
        ri2.productName = testProduct2.Name;
        ri2.returnReason = 'UK11';
        ri2.quantity = 2;
        ri2.quantityReturnable = 2;
        ri2.quantityReturned = 2;
        ri2.returnDate = System.Today();
        ri2.returnMethod = 	'Drop Off at MDC';
        
        returnItems.add(ri1);
        returnItems.add(ri2);
        
        returnOrd.returnOrderItems = returnItems;
        returnOrd.orderId = osor.orderSummaryId;
        returnOrd.accountId = testaccount.Id;
        returnOrd.userId = testUser.Id;
        
        LAD_Return__c returnOrder1 = new LAD_Return__c(
            LAD_Account__c = testaccount.Id,
            LAD_Original_Order_Summary__c = osor.orderSummaryId
        );
        
        insert new List<LAD_Return__c>{ returnOrder1};

        LAD_Return_Item__c returnItem1 = new LAD_Return_Item__c(
            LAD_Sales_Code__c = 'SC001',
            LAD_Quantity_ordered__c = 5,
            LAD_Quantity_returned__c = 2,
            LAD_Original_Order_Summary_Product__c =ois[0].Id,
            LAD_Product_Name__c = testProduct1.Id,
            LAD_Return_Order__c = returnOrder1.Id
        );
        
        LAD_Return_Item__c returnItem2 = new LAD_Return_Item__c(
            LAD_Sales_Code__c = 'SC002',
            LAD_Quantity_ordered__c = 10,
            LAD_Quantity_returned__c = 5,
            LAD_Original_Order_Summary_Product__c = ois[1].Id,
            LAD_Product_Name__c = testProduct2.Id,
            LAD_Return_Order__c = returnOrder1.Id
        );
        
        insert new List<LAD_Return_Item__c>{ returnItem1, returnItem2 };

        LAD_ReturnOrderHandler.dateValidateWrapper dateValidate1 = new LAD_ReturnOrderHandler.dateValidateWrapper();
        dateValidate1.key = 'test key1';
        dateValidate1.returnReason = 'UK01';
        dateValidate1.returnDate = Date.today();
        dateValidate1.invoiceDate = Date.today()-5;
        
        LAD_ReturnOrderHandler.dateValidateWrapper dateValidate2 = new LAD_ReturnOrderHandler.dateValidateWrapper();
        dateValidate2.key = 'test key3';
        dateValidate2.returnReason = 'UK01';
        dateValidate2.returnDate = Date.today()+25;
        dateValidate2.invoiceDate = Date.today();
        
        List<LAD_ReturnOrderHandler.dateValidateWrapper> dateList = new List<LAD_ReturnOrderHandler.dateValidateWrapper>();
        dateList.add(dateValidate1);
        dateList.add(dateValidate2);
        
        LAD_ReturnOrderHandler.ReturnOrderWrapper orderItems = LAD_ReturnOrderHandler.getOrderItems(osor.orderSummaryId);
        LAD_ReturnOrderHandler.createReturnOrder(returnOrd);
        LAD_ReturnOrderHandler.createReturnCase(testaccount.Id, returnItems);
        List<LAD_ReturnOrderHandler.dateValidateWrapper> validatedList = LAD_ReturnOrderHandler.checkReturnPeriod(dateList,osor.orderSummaryId);
        List<LAD_ReturnOrderHandler.ReturnOrdersWrapper> returnOrders = LAD_ReturnOrderHandler.getReturnOrders(testaccount.Id);
        List<LAD_ReturnOrderHandler.ReturnItemWrapper> returnItemslist = LAD_ReturnOrderHandler.getItemsByReturnOrder(returnOrder1.Id);
        Map<String,String> returnRecord = LAD_ReturnOrderHandler.returnDetail(returnOrder1.Id);
        
    }

    @IsTest
    static void testGetUserInfo() {
        Account testaccount = new Account(Name = 'ABC Corp');
        insert testaccount;
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
                                 Phone = '9999888822',
                                 ContactId = testContact.Id,
                                 TimeZoneSidKey = 'America/New_York', 
                                 LocaleSidKey = 'en_US', 
                                 EmailEncodingKey = 'UTF-8', 
                                 LanguageLocaleKey = 'en_US');
        insert testUser; 
        
        Test.startTest();
        // Call the method and verify the response
        Map<String, String> userInfo = LAD_ReturnOrderHandler.getUserInfo(testUser.Id, testaccount.Id);
        Test.stopTest();
    }
}