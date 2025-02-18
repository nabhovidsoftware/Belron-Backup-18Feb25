/** @description :  This apex class is used to pass details to LAD_AmendOrderHandler for  Reorder Functionality.  
 *                  Test coverage is done by LAD_AmendOrderHandler Test
*   @Story :        FOUK-9872; FOUK-10281
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   16-09-2024
*/
public with sharing class LAD_ReOrderHandler {
    @TestVisible private static string testOrderId = '';


    /**@className :     ReorderParamters
    * @description :    Used to wrap order input parameters from LWC.
    */
    public class ReorderParamters{
        @AuraEnabled public String orderSummaryId {get;set;}
        @AuraEnabled public String userId {get;set;}
    }

    /**@MethodName :    executeReorder
    * @description :    This method handles the details to be passed to LAD_AmendOrderHandler for  Reorder Functionality.
    * @param:           ReorderParamters reorderDetails
    * @return:          string
    */
    @AuraEnabled
    public static string executeReorder(ReorderParamters reorderDetails){
        try {
            LAD_AmendOrderHandler.OrderWrapper parameters = new LAD_AmendOrderHandler.OrderWrapper();
            parameters.orderSummaryId = reorderDetails.orderSummaryId;
            parameters.userId = reorderDetails.userId;
            parameters.isAmend = false;
            parameters.isReorder = true;


            LAD_AmendOrderHandler.amendOrderController(parameters);

            String accountId;
            if(!Test.isRunningTest()){
                accountId = [SELECT AccountId FROM OrderSummary WHERE Id = :reorderDetails.orderSummaryId].AccountId;
            }
            else{
                accountId = [SELECT AccountId FROM Order WHERE Id = :testOrderId].AccountId;
            }
            List<WebCart> cartList = [SELECT Id FROM WebCart WHERE OwnerId = :parameters.userId AND Status = 'Active' AND AccountId = :accountId];
            if(cartList.size() > 0){
                return 'Successfully Added to Cart';
            }
            
        } catch (Exception ex) {
            BLN_ExceptionLogger.captureException(ex);
        }
        return 'Could not add to Cart';
    }
}