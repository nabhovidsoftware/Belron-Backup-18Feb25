/** @description :  Test Class for LAD_InvoiceHandler, LAD_ScheduleFinancialDocumentCreation, LAD_InvoiceCreationBatch and LAD_CreditNoteCreationBatch
*   @Story :        FOUK-8908; FOUK-10157; FOUK-8956; FOUK-10522; FOUK-10582
*   @author:        (binayak.debnath@pwc.com(IN)) (hrithas.sardar@pwc.com (IN))
*   @CreatedDate:   04-10-2024
*/
@isTest
public with sharing class LAD_InvoiceHandlerTest {
    /**@MethodName :    testFinDocCreation
    * @description :    This method is used to test LAD_ScheduleFinancialDocumentCreation, LAD_InvoiceCreationBatch and LAD_CreditNoteCreationBatch class.
    * @param:           
    * @return:          
    */
    //(SeeAllData = true) is essential for using ConnectApi methods. We need ConnectApi methods to create Order Summary records.
    @isTest(SeeAllData = true) 
    static void testFinDocCreation(){
        Account testAccount = new Account(Name = 'ABC Corp');
        testAccount.BLN_PaymentTerms__c = '5 END OF MONTH';
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

        List<OrderItemSummary> itemList = [SELECT LAD_Status__c FROM OrderItemSummary WHERE OrderSummaryId = :osor.orderSummaryId];
        for(OrderItemSummary item : itemList){
            item.LAD_Status__c = 'Shipped';
        }

        update itemList;

        LAD_Return__c returnOrder1 = new LAD_Return__c(
            LAD_Account__c = testAccount.Id,
            LAD_Original_Order_Summary__c = osor.orderSummaryId
        );
        
        insert new List<LAD_Return__c>{ returnOrder1};

        LAD_Return_Item__c returnItem1 = new LAD_Return_Item__c(
            LAD_Sales_Code__c = 'SC001',
            LAD_Quantity_ordered__c = 5,
            LAD_Quantity_returned__c = 2,
            LAD_Product_Name__c = testProduct1.Id,
            LAD_Return_Order__c = returnOrder1.Id,
            LAD_Status__c = 'Return Accepted',
            LAD_Original_Order_Summary_Product__c = [SELECT Id FROM OrderItemSummary WHERE Product2Id = :testProduct1.Id LIMIT 1].Id
        );
        
        LAD_Return_Item__c returnItem2 = new LAD_Return_Item__c(
            LAD_Sales_Code__c = 'SC002',
            LAD_Quantity_ordered__c = 10,
            LAD_Quantity_returned__c = 5,
            LAD_Product_Name__c = testProduct2.Id,
            LAD_Return_Order__c = returnOrder1.Id,
            LAD_Status__c = 'Return Accepted',
            LAD_Original_Order_Summary_Product__c = [SELECT Id FROM OrderItemSummary WHERE Product2Id = :testProduct2.Id LIMIT 1].Id
        );
        
        insert new List<LAD_Return_Item__c>{ returnItem1, returnItem2 };

        String jobIdInvoice = System.schedule('test job', '0 0 * * * ?', new LAD_ScheduleFinancialDocumentCreation());


        Test.startTest();
        Test.stopTest();
    }

    /**@MethodName :    testFetchFinDoc
    * @description :    This method is used to test LAD_InvoiceHandler class.
    * @param:           
    * @return:          
    */

    //(SeeAllData = true) is essential for using ConnectApi methods. We need ConnectApi methods to create Order Summary records.
    @isTest(SeeAllData = true) 
    static void testFetchFinDoc(){
        Account testAccount = new Account(Name = 'ABC Corp');
        testAccount.BLN_PaymentTerms__c = '5 END OF MONTH';
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
        testOrder.PoNumber = '00ii20j020';
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
                                                    unitprice = 0,
                                                    LAD_PO_Number__c = '00000000' + String.valueOf(i + 1));
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

        //Create Invoices and Payment records
        LAD_Financial_Document__c finDoc = new LAD_Financial_Document__c(LAD_Account__c = testAccount.Id, 
                                                                        LAD_Order_Summary__c = osor.orderSummaryId, 
                                                                        LAD_Type__c = 'Invoice',
                                                                        LAD_Total_Amount__c = 100,
                                                                        LAD_Remaining_Amount__c = 100,
                                                                        LAD_Status__c = 'Open',
                                                                        LAD_Due_Date__c = Date.today());
                                        
        insert finDoc;
        
        List<OrderItemSummary> itemList = [SELECT LAD_Status__c FROM OrderItemSummary WHERE OrderSummaryId = :osor.orderSummaryId];
        for(OrderItemSummary item : itemList){
            item.LAD_Status__c = 'Shipped';
            item.LAD_Invoice__c = finDoc.Id;
        }

        update itemList;

        Id jobReqId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LAD_Laddaw_Case').getRecordTypeId();
        Case testCase = new Case(RecordTypeId = jobReqId, Status = 'New', AccountId = testAccount.Id, ContactId = testContact.Id);
        insert testCase;

        List<BLN_Payment__c> paymentList = new List<BLN_Payment__c>();
        for(Integer i = 0; i < 3; i++){
            BLN_Payment__c testPayment = new BLN_Payment__c(BLN_Case__c = testCase.Id, BLN_PmtReferenceId__c = 'Testioweuvqw' + String.valueOf(i));
            paymentList.add(testPayment);
        }
        
        insert paymentList;

        List<LAD_Financial_Document_Payment__c> finDocPayList = new List<LAD_Financial_Document_Payment__c>();
        for(Integer i = 0; i < paymentList.size(); i++){
            LAD_Financial_Document_Payment__c test = new LAD_Financial_Document_Payment__c( Name = 'Test' + i, 
                                                                                            LAD_Financial_Document__c = finDoc.Id, 
                                                                                            LAD_Payment__c = paymentList[i].Id,
                                                                                            LAD_Paid_Amount__c = 100);
            finDocPayList.add(test);
        }

        insert finDocPayList;

        //Create Credit Notes
        LAD_Return__c returnOrder1 = new LAD_Return__c(
            LAD_Account__c = testAccount.Id,
            LAD_Original_Order_Summary__c = osor.orderSummaryId
        );
        
        insert new List<LAD_Return__c>{ returnOrder1};

        LAD_Return_Item__c returnItem1 = new LAD_Return_Item__c(
            LAD_Sales_Code__c = 'SC001',
            LAD_Quantity_ordered__c = 5,
            LAD_Quantity_returned__c = 2,
            LAD_Product_Name__c = testProduct1.Id,
            LAD_Return_Order__c = returnOrder1.Id,
            LAD_Status__c = 'Return Accepted'
        );
        
        LAD_Return_Item__c returnItem2 = new LAD_Return_Item__c(
            LAD_Sales_Code__c = 'SC002',
            LAD_Quantity_ordered__c = 10,
            LAD_Quantity_returned__c = 5,
            LAD_Product_Name__c = testProduct2.Id,
            LAD_Return_Order__c = returnOrder1.Id,
            LAD_Status__c = 'Return Accepted'
        );
        
        insert new List<LAD_Return_Item__c>{ returnItem1, returnItem2 };

        LAD_Financial_Document__c creditDoc = new LAD_Financial_Document__c(   LAD_Account__c = testAccount.Id, 
                                                                            LAD_Return_Order__c = returnOrder1.Id, 
                                                                            LAD_Type__c = 'Credit Note',
                                                                            LAD_Total_Amount__c = -100,
                                                                            LAD_Remaining_Amount__c = -100,
                                                                            LAD_Status__c = 'Open',
                                                                            LAD_Due_Date__c = Date.today());

        insert creditDoc;

        returnItem1.LAD_CreditNote__c = creditDoc.Id;
        returnItem2.LAD_CreditNote__c = creditDoc.Id;
        update new List<LAD_Return_Item__c>{ returnItem1, returnItem2 };

        LAD_InvoiceHandler.FinancialDocInputWrapper wrap = new LAD_InvoiceHandler.FinancialDocInputWrapper();
        wrap.accountId = testAccount.Id;

        Test.startTest();
        List<LAD_InvoiceHandler.FinancialDocOutputWrapper> returnWrap = LAD_InvoiceHandler.fetchFinancialDocuments(wrap);
        Test.stopTest();

        System.Assert.areEqual(returnWrap.size(), 2);

        String orange = LAD_InvoiceHandler.invoiceBannerCheck(testAccount.Id);
        System.Assert.areEqual(orange, 'Orange');


        finDoc.LAD_Due_Date__c = Date.today().addDays(4);
        update finDoc;

        String blue = LAD_InvoiceHandler.invoiceBannerCheck(testAccount.Id);
        System.Assert.areEqual(blue, 'Blue');


        finDoc.LAD_Due_Date__c = Date.today().addDays(-3);
        update finDoc;

        String red = LAD_InvoiceHandler.invoiceBannerCheck(testAccount.Id);
        System.Assert.areEqual(red, 'Red');

/*         Date cutoffDate = Date.today().addYears(-3); 
        Test.setCreatedDate(finDoc.Id, cutoffDate); */
        LAD_InvoiceHandler.invokeDeleteFinancialDocumentBatch();

        LAD_InvoiceHandler.fetchVFBaseURL();
    }

    
}