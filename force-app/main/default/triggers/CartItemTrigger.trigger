/** @description :  This Trigger is for CartItem Object.
*   @Story :        FOUK-9051; FOUK-8454; FOUK-8231; FOUK-8232; FOUK-8230; FOUK-7684; FOUK-8367
*   @author:        (prajjawal.tiwari@pwc.com (IN)) (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
trigger CartItemTrigger on CartItem (before insert, after insert,after update,after delete) {
    
   // if(LAD_CartItemTriggerHandler.isFirstTime){
    
    
    if (Trigger.isBefore && Trigger.isInsert) {
        LAD_CartItemTriggerHandler.assignAssociatedLocations(Trigger.New);
    }
    
    
    
    if (Trigger.isAfter && Trigger.isInsert /* && !System.isfuture() */) {
        
        LAD_CartItemTriggerHandler.updateMDCwithCartItem(Trigger.New);
        LAD_FetchTaxDetails.isTaxCreatedFromAmendment(Trigger.NewMap.keyset());
    }
   
    
        if(Trigger.isafter && Trigger.isDelete && !System.isfuture()){
            LAD_CartItemTriggerHandler.deleteCart(Trigger.old);
        }
    
          if(Trigger.isDelete){
             List<CartItem> stopDeletion = LAD_CartItemTriggerHandler.restrictDeliveryCostDeletion(Trigger.old);
             for(CartItem c: stopDeletion){
                 c.addError('Cannot delete delivery cost');
             }
         }

        //recursive check
        LAD_CartItemTriggerHandler.isFirstTime=false;
        
   // }
     if (Trigger.isAfter && Trigger.isUpdate && !System.isfuture()) {
        LAD_FetchTaxDetails.isTaxCreatedFromAmendment(Trigger.NewMap.keyset());
    }
}