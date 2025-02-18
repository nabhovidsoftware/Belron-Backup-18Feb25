/**
 * @description       : 
 * @author            : Prajjawal Tiwari
 * @group             : 
 * @last modified on  : 07-10-2024
 * @last modified by  : Prajjawal Tiwari
**/
public without sharing class LAD_ReusableLookup {
    
    @AuraEnabled
    public static List<returnWrapper> fetchAccount(string userId,string recordId){
        system.debug(userId+'-'+recordId);
        List<returnWrapper> retWrapper=new List<returnWrapper>();
        List<DelegatedAccount> fetchDeleGatedAccount=[select id,TargetId,Target.Name,Target.AccountNumber from DelegatedAccount where parentid=:recordId and ManagedById=:userId];
        system.debug(fetchDeleGatedAccount);
        Account loggedInAccount=[select id,Name,AccountNumber from account where id=:recordId];
        for(DelegatedAccount i:fetchDeleGatedAccount){
            returnWrapper temp=new returnWrapper();
            temp.AccountNumber=i.Target.AccountNumber!=null?i.Target.AccountNumber:'';temp.AccountName=i.Target.Name;temp.IdStr=i.TargetId;retWrapper.add(temp);
        }
        
        returnWrapper self=new returnWrapper();
            self.AccountNumber=loggedInAccount.AccountNumber!=null?loggedInAccount.AccountNumber:'';
            self.AccountName=loggedInAccount.name;
            self.IdStr=loggedInAccount.id;
            retWrapper.add(self);

        
        system.debug(retWrapper);
        return retWrapper;
    }
    public class returnWrapper{
        @AuraEnabled public String AccountNumber{get;set;}
        @AuraEnabled public String AccountName{get;set;}
        @AuraEnabled public String IdStr{get;set;}


    }
    @AuraEnabled
    public static string returnAccountName(string userId){
        return [select account.name from user where Id=:userId].account.name;
    }
}