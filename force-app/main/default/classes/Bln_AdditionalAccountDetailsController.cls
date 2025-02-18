public without sharing class Bln_AdditionalAccountDetailsController {
	@AuraEnabled(cacheable=true)
    public static Id getLoggedInUserAccount() { 
        User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
         return [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()].AccountId;
    }
}