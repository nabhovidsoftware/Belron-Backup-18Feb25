public class BLN_AccountRuleParameterWrapper {
    @AuraEnabled @InvocableVariable
    public String accountName;
    
    @AuraEnabled @InvocableVariable
    public BLN_AccountRuleParameter__c objARP;

    public BLN_AccountRuleParameterWrapper(){
       this.accountName = '';
       this.objARP = new BLN_AccountRuleParameter__c();
    }
}