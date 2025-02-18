public with sharing class LAD_WishlistHandler {
 
   @AuraEnabled
   public static string removeWishlistItems(String prodId, String userId){
       try{
        WishlistItem removeItems = [SELECT Id FROM WishlistItem 
                                    WHERE wishlist.ownerId=:userId 
                                    AND Product2Id=:prodId];
        delete removeItems;return 'success';
         } catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
         return 'error';
         }
   }
   	
   @auraEnabled
    public static string getWebStoreId(){
        return [select id from webstore where name='Laddaw' limit 1].id;
    }
    

}