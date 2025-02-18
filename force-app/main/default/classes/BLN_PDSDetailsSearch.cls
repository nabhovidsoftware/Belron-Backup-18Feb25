public with sharing class BLN_PDSDetailsSearch {

    @AuraEnabled
  public static List<Case> blnPDSsearchAPI(string recordId){
    return [SELECT Id,BLN_Vehicle__c,BLN_VRN__c,CreatedDate from Case where id = :recordId WITH SECURITY_ENFORCED];
}
}