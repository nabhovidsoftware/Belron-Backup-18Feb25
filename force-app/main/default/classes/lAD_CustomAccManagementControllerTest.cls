/** @description :  Test Class for lAD_CustomAccManagementController
*   @Story :        
*   @author:        (manoj.varma.ummadisingu@pwc.com (IN))
*   @CreatedDate:   07-10-2024
*/
@isTest
public class lAD_CustomAccManagementControllerTest {
    
    /* Utility method to create test data
    public static void setupTestData() {
        
    }*/
    
    @isTest
    static void testGetAll() {
        Account testaccount = new Account(Name = 'ABC Corp');
        insert testaccount;
        Contact testContact = New Contact(LastName = 'Test', AccountID = testAccount.id);
        insert testContact;
         Contact testContact2 = New Contact(LastName = 'Test', AccountID = testAccount.id);
        insert testContact2;
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
        user testUser2 = New User(UserName = 'test_' + math.random() + '@test.com',
                                 FirstName = 'Test-First',
                                 LastName = 'Test-Last',
                                 Alias = 'test',
                                 email = 'test' + math.random() + '@test.com',
                                 CommunityNickName = string.valueOf(math.random()).substring(0,6),
                                 ProfileID = p.id,
                                 Phone = '9999888822',
                                 ContactId = testContact2.Id,
                                 TimeZoneSidKey = 'America/New_York', 
                                 LocaleSidKey = 'en_US', 
                                 EmailEncodingKey = 'UTF-8', 
                                 LanguageLocaleKey = 'en_US');
        insert testUser2;  
         WebStore testStore = new WebStore(Name = 'test Store',
                                          OptionsAutoFacetingEnabled = true,
                                          OptionsCartToOrderAutoCustomFieldMapping = true,  
                                          OptionsCommerceEinsteinActivitiesTracked = true,                                               
                                          OptionsCommerceEinsteinDeployed = true,   
                                          OptionsGuestBrowsingEnabled = true,                                                
                                          OptionsSkipAdditionalEntitlementCheckForSearch = true);
        insert testStore;
        WebCart testCart = new WebCart (Name = 'TestCart', WebStoreId = testStore.id, AccountId = testaccount.id);
        insert testCart;
        testCart.OwnerId = testUser.Id;
        update testCart;
        Test.startTest();
        Id accId = lAD_CustomAccManagementController.getAccId(testUser.Id);
        List<User> users = lAD_CustomAccManagementController.getMembers(testaccount.Id);
        List<Map<String, Object>> carts = lAD_CustomAccManagementController.getCarts(testaccount.Id,testUser2.Id);
        List<WebCart> activeCarts = lAD_CustomAccManagementController.getActiveCartForUser();
        WebCart resultCart = lAD_CustomAccManagementController.getcartCreatedBy(testCart.Id);
        lAD_CustomAccManagementController.updateCartOwner(testCart.Id, testUser.Id);
         lAD_CustomAccManagementController.updateCartStatusReturn(testCart.Id);
        Test.stopTest();
        
        System.assert(!users.isEmpty(), 'There should be users associated with the account');
        System.assertNotEquals(null, accId, 'Account Id should not be null');
    }

    @isTest
    static void testUpdateCartStatus() {
         Account acc = new Account(Name = 'ABC Corp');
        insert acc;
         WebStore testStore = new WebStore(Name = 'test Store',
                                          OptionsAutoFacetingEnabled = true,
                                          OptionsCartToOrderAutoCustomFieldMapping = true,  
                                          OptionsCommerceEinsteinActivitiesTracked = true,                                               
                                          OptionsCommerceEinsteinDeployed = true,   
                                          OptionsGuestBrowsingEnabled = true,                                                
                                          OptionsSkipAdditionalEntitlementCheckForSearch = true);
        insert testStore;
        WebCart testCart = new WebCart (Name = 'TestCart', WebStoreId = testStore.id, AccountId = acc.id);
        insert testCart;
        testCart.Status = 'Closed';
        update testCart;
        
        Test.startTest();
        lAD_CustomAccManagementController.updateCartStatus(testCart.Id, 'Closed');
        Test.stopTest();
    }
}