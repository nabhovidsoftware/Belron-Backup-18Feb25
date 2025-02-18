/** @description :  This is component is used for displaying the contacts of the account associated to the external user.
*   @Story :        FOUK-9572, FOUK-9573, FOUK-9576
*   @author:        (ashwin.r.raja@pwc.com (IN))
*   @CreatedDate:   26-08-2024
*/

public with sharing class LAD_fetchContacts {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getRelatedContacts(Id accountId) {
        List<String>Role = new List<String>{'Buyer','Buyer Manager'};
        return [SELECT Id, Name, Email, Phone,LAD_Status__c,LAD_Role__c 
                FROM Contact 
                WHERE AccountId = :accountId AND LAD_Role__c in :Role];
    }
}