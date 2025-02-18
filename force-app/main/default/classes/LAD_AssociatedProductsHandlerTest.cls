/** @description :  Test Class for LAD_AssociatedProductsHandler.
*   @Story :        FOUK-7848; FOUK-7866; FOUK-7867; FOUK-7868; FOUK-8518
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   03-07-2024
*/

@isTest
public with sharing class LAD_AssociatedProductsHandlerTest {
   public static Id childProduct1;
   public static Id childProduct2;

    @TestSetup
    static void testData(){
        Account testAccount = new Account(Name = 'ABC Corp'); // add more fields based on your org validation 
        insert testAccount;
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
        loc.BLN_GUID__c = 'L31_UK';
        insert loc;
        
        
        AssociatedLocation testAssociatedLocation = new AssociatedLocation(LocationId = loc.id,
                                                                           LAD_Location_Type__c = 'Primary',
                                                                           ParentRecordId = testAccount.Id);
        insert testAssociatedLocation;
        
        Product2 testProduct = new Product2(Name = 'Test Product', LAD_Latest_OEM_Code__c = 'OEMCODE-PARENT');
        Product2 testProductchild1 = new Product2(Name = 'Test Product child 1', LAD_Latest_OEM_Code__c = 'OEMCODE-CHILD0');
        Product2 testProductchild2 = new Product2(Name = 'Test Product child 2', LAD_Latest_OEM_Code__c = 'OEMCODE-CHILD1');

        insert testProduct;
        insert testProductchild1;
        insert testProductchild2;

        PurchaseQuantityRule child1QuantityRule = new PurchaseQuantityRule(Name='Test', Minimum=5,Maximum=100, Increment = 5);
        insert child1QuantityRule;

        ProductQuantityRule childProduct1QuantityRule = new ProductQuantityRule(PurchaseQuantityRuleId = child1QuantityRule.id, ProductId = testProductchild1.id);
        insert childProduct1QuantityRule;
        
        WebStore testStore = new WebStore(Name = 'test Store',
                                          OptionsAutoFacetingEnabled = true,
                                          OptionsCartToOrderAutoCustomFieldMapping = true,	
                                          OptionsCommerceEinsteinActivitiesTracked = true,	                                             
                                          OptionsCommerceEinsteinDeployed = true,	
                                          OptionsGuestBrowsingEnabled = true,	                                             
                                          OptionsSkipAdditionalEntitlementCheckForSearch = true);
        insert testStore;

        LAD_Product_Bill_Of_Material__c leadProductBOM = new LAD_Product_Bill_Of_Material__c();
        leadProductBOM.LAD_Bill_of_Material_Id__c = 'BOM1';
        leadProductBOM.LAD_Product_Belron_Id__c = 'OEMCODE-PARENT';
        leadProductBOM.LAD_Product_Bill_of_Material_Quantity__c = 10;
        leadProductBOM.LAD_Product_BOM_Leading_Product_Ind__c = 'TRUE';
        leadProductBOM.LAD_Product_BOM_Mandatory_Ind__c = 'TRUE';
        leadProductBOM.LAD_Product_Start_Date__c = '2024-07-01';
        leadProductBOM.LAD_Product_End_Date__c = '2024-07-30';
        insert leadProductBOM;

        LAD_Product_Bill_Of_Material__c childProductBOM1 = new LAD_Product_Bill_Of_Material__c();
        childProductBOM1.LAD_Bill_of_Material_Id__c = 'BOM1';
        childProductBOM1.LAD_Product_Belron_Id__c = 'OEMCODE-CHILD0';
        childProductBOM1.LAD_Product_Bill_of_Material_Quantity__c = 10;
        childProductBOM1.LAD_Product_BOM_Leading_Product_Ind__c = 'FALSE';
        childProductBOM1.LAD_Product_BOM_Mandatory_Ind__c = 'TRUE';
        childProductBOM1.LAD_Product_Start_Date__c = '2024-07-01';
        childProductBOM1.LAD_Product_End_Date__c = '2024-07-30';
        insert childProductBOM1;

        LAD_Product_Bill_Of_Material__c childProductBOM2 = new LAD_Product_Bill_Of_Material__c();
        childProductBOM2.LAD_Bill_of_Material_Id__c = 'BOM1';
        childProductBOM2.LAD_Product_Belron_Id__c = 'OEMCODE-CHILD1';
        childProductBOM2.LAD_Product_Bill_of_Material_Quantity__c = 5;
        childProductBOM2.LAD_Product_BOM_Leading_Product_Ind__c = 'FALSE';
        childProductBOM2.LAD_Product_BOM_Mandatory_Ind__c = 'FALSE';
        childProductBOM2.LAD_Product_Start_Date__c = '2024-07-01';
        childProductBOM2.LAD_Product_End_Date__c = '2024-07-30';
        insert childProductBOM2;
    }

    @isTest
    public static void findAssociatedProductsHandlerTest() {
        Id userId = [SELECT Id FROM User WHERE LastName ='Test-Last' LIMIT 1].Id;
        Id leadProductId = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1].Id;
        Id storeId = [SELECT Id FROM WebStore WHERE Name = 'test Store' LIMIT 1].Id;

        Id childProductId1 = [SELECT Id FROM Product2 WHERE Name = 'Test Product child 1' LIMIT 1].Id;
        Id childProductId2 = [SELECT Id FROM Product2 WHERE Name = 'Test Product child 2' LIMIT 1].Id;

        childProduct1 = childProductId1;
        childProduct2 = childProductId2;
        system.debug('CHILD 1' + childProduct1);
        Test.setMock(HttpCalloutMock.class, new LAD_AssociatedProductsHandlerMock());

        Test.startTest();
        LAD_AssociatedProductsHandler.findAssociatedProductsHandler(leadProductId, userId, storeId);
        Test.stopTest();
    }

    @isTest
    public static void findAssociatedProductsHandlerExceptionTest() {
        Id userId = [SELECT Id FROM User WHERE LastName ='Test-Last' LIMIT 1].Id;
        //Id leadProductId = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1].Id;
        Id storeId = [SELECT Id FROM WebStore WHERE Name = 'test Store' LIMIT 1].Id;

        system.debug('CHILD 1' + childProduct1);
        Test.setMock(HttpCalloutMock.class, new LAD_AssociatedProductsHandlerMock());

        List<String> bomList = new List<String>{'ueibebq'};

        Test.startTest();
        LAD_AssociatedProductsHandler.findAssociatedProductsHandler('', userId, storeId);
        LAD_AssociatedProductsHandler.findAssociatedProductsbyBom(bomList, userId, storeId);
        Test.stopTest();
    }
}