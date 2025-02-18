/*************************************************************************   
* @description : LAD_TestDataFactory
*/
public without sharing class LAD_TestDataFactory {
   //createAdminUser method
   public static User createAdminUser() {
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        String randomNumber = invokeRandomizer();
        String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        User adminUser = new User(
            isActive=true,
            UserroleId =role,
            ProfileId = adminProfileId,
            FirstName = 'System',
            LastName = 'User',
            UserName = System.now().getTime() + '@test.demo' + randomNumber,
            Alias = 'sadmin',
            Email = 'test@sample.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true);
       insert adminUser;
        
        return adminUser;
    }
    //invokeRandomizer method
     public static String invokeRandomizer(){
        Integer randomNumber = Integer.valueOf(Math.rint(Math.random() * 900000 + 100000));
        String randomString = String.valueOf(randomNumber);
        return randomString;
    }
    //createWebStore method
    public static WebStore createWebStore(){
        WebStore sampleWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert sampleWebStore;
        return sampleWebStore;
    }
    //createAccount method
    public static Account createAccount(){
        Account sampleAccount = new Account(Name='TestAccount');
        insert sampleAccount;
        return sampleAccount;
    }
    //createWebCart method
    public static WebCart createWebCart(string webStoreId,string accountId,string ownerId){
         WebCart cart = new WebCart(Name='Cart', WebStoreId=webStoreId, AccountId=accountId,OwnerId=ownerId,Status = 'Active');
        insert cart;
        return cart;
    }
    //createCartDeliveryGroup method
    public static CartDeliveryGroup createCartDeliveryGroup(string cartId){
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cartId, Name='Default Delivery');
        insert cartDeliveryGroup;
        return CartDeliveryGroup;
    }
    //createCartitem method
    public static CartItem createCartitem(string cartid,string cartDeliveryGrpId,string productid){
        CartItem cartItem = new CartItem(
            CartId=cartid, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct',
            product2id=productid,
            CartDeliveryGroupId=cartDeliveryGrpId,
            LAD_UnitPriceAdjustment__c=0,
            TotalAdjustmentAmount=0,
            TotalPriceAfterAllAdjustments=0,
            TotalPromoAdjustmentAmount=0,
            UnitAdjustmentAmount=0
        );
        insert cartItem;
        return CartItem;
    }

	    
}