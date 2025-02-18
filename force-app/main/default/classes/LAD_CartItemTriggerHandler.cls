/** @description :  This apex class is used to handle certain tasks on the trigger context of CartItem Object.
*   @Story :        FOUK-9051; FOUK-8454; FOUK-8231; FOUK-8232; FOUK-8230; FOUK-7684; FOUK-8367
*   @author:        (prajjawal.tiwari@pwc.com (IN)) (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
public with sharing class LAD_CartItemTriggerHandler {

    /**@MethodName :    assignAssociatedLocations
    * @description :    This method is used to assign Associated Locations to the CartItem record before they are inserted.
    * @param:           List<CartItem> newCartItems
    * @return:          void
    */
            //recursive check

   	public static Boolean isFirstTime = true;
   
    public static void assignAssociatedLocations(List<CartItem> newCartItems) {
         try{
        Set<Id> productIds = new Set<Id>();
        Map<Id, Id> cartIdToAccountId = new Map<Id, Id>();
        Set<Id> userIds = new Set<Id>();
        
        for (CartItem cartItem : newCartItems) {
            if (cartItem.Product2Id != null) {
                productIds.add(cartItem.Product2Id);
            }
            /* if (cartItem.CreatedById != null) {
                userIds.add(cartItem.CreatedById);
            } */
            if (cartItem.CartId != null) {
                cartIdToAccountId.put(cartItem.CartId, null);
            }
        }
        
        system.debug('Product IDs: ' + productIds);
        system.debug('User IDs: ' + userIds);
        system.debug('Cart ID to Account ID map: ' + cartIdToAccountId);
        Map<string,cartdeliveryGroup> dummyCartDeliveryGrpList=new Map<string,cartdeliveryGroup>();
        for (WebCart cart : [SELECT Id, OwnerId, AccountId FROM WebCart WHERE Id IN :cartIdToAccountId.keySet()]) {
            cartIdToAccountId.put(cart.Id, cart.AccountId);
            dummyCartDeliveryGrpList.put(cart.Id,new CartDeliveryGroup(Name = 'TestGroup', CartId = cart.Id));
            userIds.add(cart.OwnerId);
        }
        insert dummyCartDeliveryGrpList.values();
        system.debug('Associated Account IDs for Cart Items: ' + cartIdToAccountId);
        
        Map<Id, Id> productIdToAssociatedLocationId = new Map<Id, Id>();
        for (LAD_MDC_Preference__c preference : [
            SELECT LAD_Product__c, LAD_Associated_Location__c, LAD_Account__c
            FROM LAD_MDC_Preference__c 
            WHERE LAD_Product__c IN :productIds AND LAD_Account__c IN :cartIdToAccountId.values() AND LAD_User__c IN :userIds
        ]) {
            productIdToAssociatedLocationId.put(preference.LAD_Product__c, preference.LAD_Associated_Location__c);
        }
        system.debug('Associated Location IDs for Products: ' + productIdToAssociatedLocationId);
        
        // Create a set to track product IDs that have preferences
        Set<Id> productIdsWithPreferences = new Set<Id>(productIdToAssociatedLocationId.keySet());
        system.debug('productIdsWithPreferences>>'+productIdsWithPreferences);
        
        
        
        
             
        for (CartItem cartItem : newCartItems) {
            system.debug('hereee');
            if(cartItem.name!='Delivery Cost'){
            if (!productIdsWithPreferences.contains(cartItem.Product2Id)) {
                system.debug('in if');
                cartItem.addError('Please select a Location before adding to cart');
            } else {
                system.debug('in else');
                cartItem.LAD_Associated_Location__c = productIdToAssociatedLocationId.get(cartItem.Product2Id);
                cartItem.CartDeliveryGroupId=dummyCartDeliveryGrpList.get(cartItem.cartId).id;
            }
        }
        
        }
        
        System.debug('Completed processing Cart Items.');
         }catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            
        } 
    }

    /**@MethodName :    updateMDCwithCartItem
    * @description :    This method is used to Update MDC Preference records with the associated cart item for the product after
                        the record is inserted.
    * @param:           LList<CartItem> afterInsertCartItems
    * @return:          void
    */
    public static void updateMDCwithCartItem(List<CartItem> afterInsertCartItems) {
        try{
        system.debug('in CartItem after insert Trigger');
        
        Set<Id> productIds = new Set<Id>();
        Map<Id, Id> cartIdToAccountId = new Map<Id, Id>();
        Set<Id> userIds = new Set<Id>();

        
        for (CartItem cartItem : afterInsertCartItems) {
            if (cartItem.Product2Id != null) {
                productIds.add(cartItem.Product2Id);
            }
            if (cartItem.CartId != null) {
                cartIdToAccountId.put(cartItem.CartId, null);
            }
            if (cartItem.CreatedById != null) {
                userIds.add(cartItem.CreatedById);
            }
        }
        
        system.debug('productIds>>' + productIds);
        system.debug('cartIdToAccountId>>' + cartIdToAccountId);
        
        for (WebCart cart : [
            SELECT Id, AccountId 
            FROM WebCart 
            WHERE Id IN :cartIdToAccountId.keySet()
        ]) {
            cartIdToAccountId.put(cart.Id, cart.AccountId);
        }
        
        System.debug('Associated Account IDs for Cart Items: ' + cartIdToAccountId);
        
        Map<Id, LAD_MDC_Preference__c> productToPreferenceMap = new Map<Id, LAD_MDC_Preference__c>();
        for (LAD_MDC_Preference__c preference : [
            SELECT Id, LAD_Product__c, LAD_Associated_Location__c, LAD_Account__c, LAD_Cartitem__c 
            FROM LAD_MDC_Preference__c 
            WHERE LAD_Product__c IN :productIds 
            AND LAD_Account__c IN :cartIdToAccountId.values()
            AND LAD_User__c IN :userIds
        ])
        { productToPreferenceMap.put(preference.LAD_Product__c, preference);}
        
        System.debug('Preferences Map: ' + productToPreferenceMap);
        
        List<LAD_MDC_Preference__c> preferencesToUpdate = new List<LAD_MDC_Preference__c>();
        
        for (CartItem cartItem : afterInsertCartItems) {
            if (productToPreferenceMap.containsKey(cartItem.Product2Id)) {
                LAD_MDC_Preference__c preference = productToPreferenceMap.get(cartItem.Product2Id);
                preference.LAD_Cartitem__c = cartItem.Id;
                preferencesToUpdate.add(preference);
            }
        }
        
        if (!preferencesToUpdate.isEmpty()) {update preferencesToUpdate;        }
        
        system.debug('Updated Preferences: ' + preferencesToUpdate);
             }catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            
        } 
    }
    
    /**@MethodName :    deleteCart
    * @description :    This method is used to Delete Cart if there are not any cart Items associated with a cart when cart Item is removed.
                        
    * @param:           List<CartItem> beforedeleteCartItems
    * @return:          void
    */
    
    public static void deleteCart(List<CartItem> beforeDeleteCartItems){
        try{         
              system.debug(beforeDeleteCartItems);
		List<string> cartList=new List<string>();
        for(cartItem i:beforeDeleteCartItems){
            cartList.add(i.cartid);
        }
              system.debug('cartList>>>'+cartList);
       
           doCalloutInFuture(string.join(cartList,','));
        
         }catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            
        } 
      }
    
    
    @future
    public static void doCalloutInFuture(String cartDetails){
        system.debug(cartDetails);
          		delete [  
                        SELECT Id, Status, UniqueProductCount   
                        FROM WebCart   
                        WHERE Id in : cartDetails.split(',') and UniqueProductCount=0
                    ];
    }
    
    
      /**@MethodName :    restrictDeliveryCostDeletion
    * @description :    This method is used to Delete Cart if there are not any cart Items associated with a cart when cart Item is removed.
                        
    * @param:           List<CartItem> beforedeleteCartItems
    * @return:          void
    */
    
     public static List<CartItem> restrictDeliveryCostDeletion(List<CartItem> beforeDeleteCartItems){
      
             Boolean isInternalUser = FeatureManagement.checkPermission('LAD_Laddaw_Internal_Portal');
             List<CartItem> stopDeletion = new List<CartItem>();
                    for(CartItem i:beforeDeleteCartItems){
                      
                         if(i.LAD_Product_Code__c == 'PSER00405A' && (!isInternalUser)){
                             	stopDeletion.add(i);
                              	LAD_Cart_Page_Errors__e platformEvent=new LAD_Cart_Page_Errors__e();
                            	platformEvent.LAD_Cart_ID__c=i.cartId;
                            	platformEvent.LAD_Cart_Item_ID__c=i.Id;
        
                            	EventBus.publish(platformEvent);    
                         }
                 }
            
          
             return stopDeletion;
      
   }
    

    }