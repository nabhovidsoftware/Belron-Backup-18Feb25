public with sharing class LAD_webCartTriggerHandler {
    public static Boolean isFirstTime = true;

    public static void clearMDCPreferenceRecords(List<WebCart> webCarts) {
        system.debug('isfirstime>>'+isFirstTime);
        List<Id> cartIds = new List<Id>();
        for(WebCart c: webCarts){
             cartIds.add(c.Id);
        }
        system.debug('cart Ids updated>>>'+cartIds);
        
        List<WebCart> c = [SELECT Id, Status, (SELECT Id, Product2Id FROM CartItems) FROM WebCart WHERE Id IN :cartIds];
        system.debug('cart>>'+c);
        List<CartItem> ci = new List<CartItem>();
        List<Id> ciIds = new List<Id>();
        List<LAD_MDC_Preference__c> clearMDCList = new List<LAD_MDC_Preference__c>();

        try{
            for(WebCart i:c){
                if(i.Status=='Closed' || i.Status=='PendingClosed' || i.Status == 'PendingDelete'){
                    ci.addAll(i.CartItems);
                }
            }
            system.debug('cart items>>'+ci);

            if(ci.size()>0){
                for(CartItem i:ci){
                    ciIds.add(i.Id);
                }
            
                clearMDCList = [SELECT Id FROM LAD_MDC_Preference__c WHERE LAD_Cartitem__c in :ciIds];
                system.debug('clearMDCList>>'+clearMDCList);
                Database.DeleteResult[] result = Database.delete(clearMDCList);
                system.debug('deletion status>>>'+result);

            }

        }catch (Exception e) {
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);
        }
    }
}