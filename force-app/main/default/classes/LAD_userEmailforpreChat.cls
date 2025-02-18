/* description :  This apex class is used to fetch user email address.
   author:       (punam.patil@pwc.com (IN))
   Story:         FOUK-8504
*/

public with sharing class LAD_userEmailforpreChat {
    @AuraEnabled(cacheable=true)
       public static string getUserEmail(String userId) {

   
    system.debug('id'+userId);
        return([select Id, email from User where id=:userId].email);

    }
}