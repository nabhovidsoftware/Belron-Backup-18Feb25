/*
 * Copyright (c) 2021, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@IsTest
public with sharing class B2BProductEntitlementCheckTest {
    
    private static Id userId = null;
    private static Id accountId = null;
    private static Id pricebookId;
    private static List<Product2> productList = null;
    private static Id storeId;

    private static Id buyerGroupId;

    private static Id buyerAccountId;

    private static List<String> skus = new List<String>();

    private static void createObjs() {

        accountId = B2BCartUploadTestUtils.createAccount();

        Id contactId = B2BCartUploadTestUtils.createContact(accountId);
        
        userId = B2BCartUploadTestUtils.createUser(null);

    }

    private static void setupTestData(Integer numProducts) {

        System.debug('begin setupTestData()');

        B2BCartUploadTestUtils.createCustomSettings('https://www.salesforce.com');

        Id pricebookId = B2BCartUploadTestUtils.createPricebook();
        storeId = B2BCartUploadTestUtils.createWebStore(pricebookId);

        storeId = null;

        productList = new List<Product2>();

        for(Integer i = 1; i <= numProducts; i++) {

            String sku = B2BCartUploadTestUtils.getGuid();

            Product2 product =  B2BCartUploadTestUtils.createProductBatch('Sample Product', sku, '');

            productList.add(product);

            skus.add(sku);

        }

        insert productList;

        List<PricebookEntry> pbeList1 = new List<PricebookEntry>();
        List<PricebookEntry> pbeList2 = new List<PricebookEntry>();

        for(Product2 product : productList) {
            
            PricebookEntry stdpbe = B2BCartUploadTestUtils.createStandardPricebookEntryBatch(product.Id);
            pbeList1.add(stdpbe);

            PricebookEntry pbe = B2BCartUploadTestUtils.createPricebookEntryBatch(pricebookId, product.Id);
            pbeList2.add(pbe);
        }

        insert pbeList1;
        insert pbeList2;

    }

    @IsTest
    /*
        Tests for one product.
    */
    public static void testCode1() {

        User adminUser = B2BCartUploadTestUtils.createAdminUser();

        System.runAs(adminUser) {
            createObjs();
            setupTestData(1);
        }

        B2B_Cart_Upload_Settings__c cs = B2B_Cart_Upload_Settings__c.getOrgDefaults();

        System.debug('cs: ' + cs);

        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        String endpoint = cs.REST_API_Domain__c + '/services/data/v49.0/connect/batch';

        System.debug('--- endpoint: ' + endpoint);
        String staticResourceUrl = 'B2B_Product_Search_Results_One_Product';

       // mock.setStaticResource(endpoint, 'B2B_Product_Search_Results_One_Product');
        mock.setStaticResource(endpoint, staticResourceUrl);
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        Map<String, String> skuMap = B2BProductEntitlementCheck.productSearch(skus, storeId, null, 25);

        Test.stopTest();

        System.debug('skuMap: ' + JSON.serialize(skuMap));

        Product2 product = productList.get(0);
        System.debug('product: ' + product);

        Boolean validSkuFound = skuMap.containsKey('999AAA000111');

        System.assertEquals(validSkuFound, true, 'SKU not found in response');

    }

    @IsTest
    /*
        Tests for 50 products.
    */
    public static void testCode2() {

        User adminUser = B2BCartUploadTestUtils.createAdminUser();

        System.runAs(adminUser) {
            createObjs();
            setupTestData(50);
        }

        B2B_Cart_Upload_Settings__c cs = B2B_Cart_Upload_Settings__c.getOrgDefaults();

        System.debug('cs: ' + cs);

        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        String endpoint = cs.REST_API_Domain__c + '/services/data/v49.0/connect/batch';
        String staticResourceUrl = 'B2B_Product_Search_Results_One_Product';

        System.debug('--- endpoint: ' + endpoint);

       // mock.setStaticResource(endpoint, 'B2B_Product_Search_Results_One_Product');
        mock.setStaticResource(endpoint, staticResourceUrl);
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        Map<String, String> skuMap = B2BProductEntitlementCheck.productSearch(skus, storeId, null, 25);

        Test.stopTest();

        System.debug('skuMap: ' + JSON.serialize(skuMap));

        Boolean validSkuFound = skuMap.containsKey('999AAA000111');

        System.assertEquals(validSkuFound, true, 'SKU not found in response');

    }

    @IsTest
    /*
        Tests for 201 products.
    */
    public static void testCode3() {

        User adminUser = B2BCartUploadTestUtils.createAdminUser();

        System.runAs(adminUser) {
            createObjs();
            setupTestData(201);
        }

        B2B_Cart_Upload_Settings__c cs = B2B_Cart_Upload_Settings__c.getOrgDefaults();

        System.debug('cs: ' + cs);

        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        String endpoint = cs.REST_API_Domain__c + '/services/data/v49.0/connect/batch';
		String staticResourceUrl = 'B2B_Product_Search_Results_One_Product';
        System.debug('--- endpoint: ' + endpoint);
         System.debug('--- staticResourceUrl in test3: ' + staticResourceUrl);

        //mock.setStaticResource(endpoint, 'B2B_Product_Search_Results_One_Product');
         mock.setStaticResource(endpoint, staticResourceUrl);
          //mock.setStaticResource(endpoint, '/resource/B2B_Product_Search_Results_One_Product'); 
        //mock.setStaticResource(endpoint, '{"hasErrors": false,"results": [{	"statusCode": 201,"result": {"categories": {"category": {"description": "All Categories", "id": null, "name": "All Categories"}, "children": [{"category": {"description": null, "id": "0ZGB0000000Gp3aOAC", "name": "All Products" }, 	"children": [], "productCount": 1}], "productCount": 1 },"facets": [], "locale": "en_US", "productsPage": { "currencyIsoCode": null, "pageSize": 50, "products": [ { "defaultImage": { "alternateText": "image", "contentVersionId": null, "id": null, "mediaType": "Image", "sortOrder": 0, "thumbnailUrl": null, "title": "image" }, "fields": { "StockKeepingUnit": {   "value": "999AAA000111" } }, "id": "01tB0000000VYU2IAO", "name": "Sample Product", "prices": null } ], "total": 1} } 	} ] }');
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        Map<String, String> skuMap = B2BProductEntitlementCheck.productSearch(skus, storeId, null, 25);

        Test.stopTest();

        System.debug('skuMap: ' + JSON.serialize(skuMap));

        Boolean validSkuFound = skuMap.containsKey('999AAA000111');

        System.assertEquals(validSkuFound, true, 'SKU not found in response');

    }

    @IsTest
    /*
        Tests for 1 product.
    */
    public static void testError() {

        User adminUser = B2BCartUploadTestUtils.createAdminUser();

        System.runAs(adminUser) {
            createObjs();
            setupTestData(1);
        }

        B2B_Cart_Upload_Settings__c cs = B2B_Cart_Upload_Settings__c.getOrgDefaults();

        System.debug('cs: ' + cs);

        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        String endpoint = cs.REST_API_Domain__c + '/services/data/v49.0/connect/batch';
        //String staticResourceUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/resource/B2B_Product_Search_Results_Error';
		String  staticResourceUrl = 'B2BCartError';
        System.debug('--- endpoint: ' + endpoint);

        //mock.setStaticResource(endpoint, 'B2B_Product_Search_Results_Error');
      //  mock.setStaticResource(endpoint, '{"hasErrors": true,"results": [{"result": [{"errorCode": "INVALID_API_INPUT","message": "Only a buyer user can access this account."}],"statusCode": 400}]}');
          mock.setStaticResource(endpoint,staticResourceUrl);                      
                               
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        system.debug('skus in testError'+skus);

         Map<String, String> skuMap = B2BProductEntitlementCheck.productSearch(skus, storeId, null, 25);
        //Map<String, String> skuMap = B2BProductEntitlementCheck.productSearch(skus, storeId, accountId, 25);

        Test.stopTest();

        System.debug('skuMap: ' + JSON.serialize(skuMap));

        System.assertEquals(0, skuMap.size(), 'No valid SKUs should have been returned');

    }

}