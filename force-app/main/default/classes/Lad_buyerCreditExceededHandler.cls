/** @description :  This apex class is used to handle Submit Order Functionality.
*   @Story :        
*   @author:        (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   13-06-2024
*/
public class Lad_buyerCreditExceededHandler {
  /**@MethodName :   	checkAccountViability
    * @description :    This method checks if the account is on hold or has exceeded buyer limits.
    * @param:           string userId,string effectiveAccountId
    * @return:          AccountWrapper
    */
    @auraenabled
    public static boolean returnBuyerCreditExceededCheck(string userId,string effectiveAccountId){
        string acccountId='';
        if(effectiveAccountId==null || effectiveAccountId==''){
            string contactId=[select contactId from user where id=:userId].contactId;
            acccountId=[select accountId from contact where id=:contactId].accountId;
        }else{
            acccountId=effectiveAccountId;
        }
        return [select id,LAD_Buyer_Credit_Exceeded__c from account where id=:acccountId].LAD_Buyer_Credit_Exceeded__c;
    }
}