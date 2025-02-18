@isTest
public class LAD_WishlistHandlerTest {

    @isTest
    static void testRemoveWishlistItems() {
          Account testAccount = new Account(Name = 'ABC Corp'); // add more fields based on your org validation 
        insert testAccount;
        Contact testContact = New Contact(LastName = 'Test', AccountID = testAccount.id);
        insert testContact;
                Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];

         user testUser = New User(   UserName = 'test_' + math.random() + '@test.com',
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
          Product2 testProduct = new Product2(Name = 'Test Product');
        insert testProduct;
        
        Test.startTest();
        String result = LAD_WishlistHandler.removeWishlistItems(testProduct.Id,testUser.id);
        Test.stopTest();

     
    }

    @isTest
    static void testGetWebStoreId() {
        // Create a test WebStore
        WebStore testStore = new WebStore(Name = 'Laddaw');
        insert testStore;

        // Call the method to get the WebStore ID
        Test.startTest();
        String webStoreId = LAD_WishlistHandler.getWebStoreId();
        Test.stopTest();

        // Verify that the returned ID matches the test store's ID
        System.assertNotEquals(null, webStoreId, 'WebStore ID should not be null.');
        System.assertEquals(testStore.Id, webStoreId, 'The returned WebStore ID should match the test store.');
    }
}