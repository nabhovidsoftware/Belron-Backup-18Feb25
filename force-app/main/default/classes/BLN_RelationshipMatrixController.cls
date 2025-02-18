/*****************************************
*ClassName : BLN_RelationshipMatrixController
*@description : FOUK-2031 This controller class is used in Lightning web component .
*CreatedDate: 10-02-2024
*CreatedBy : PwC-India
****************************************/
public with sharing class BLN_RelationshipMatrixController {
    
    /*MethodName : getRelationships
*@description : This method is used to return the relationships.
*@return Map
*@param string
*Input Parameter : String
*CreatedDate: 10-02-2024
*CreatedBy : Pwc-India
*Change log :
****************************************/
    
    @AuraEnabled(Cacheable = true)
    public static Map<Id,List<BLN_Relationship__c>> getRelationships(String recordId) {
        Map<Id,List<BLN_Relationship__c>> relationshipMap = new Map<Id,List<BLN_Relationship__c>>();
        
        try {
            if(String.isNotBlank(recordId)){
                List<BLN_Relationship__c> relationshipList = [SELECT Id, BLN_UserName__r.Name, BLN_ContactName__c, BLN_ContactName__r.Name, 
                                                              BLN_RelationshipHealth__c, BLN_RelationshipHealthIndicator__c, 
                                                              BLN_ContactPosition__c, BLN_ContactDecisionPower__c, 
                                                              BLN_ContactAttitudeTowardsBelron__c 
                                                              FROM BLN_Relationship__c 
                                                              WHERE BLN_Account__c = :recordId WITH SECURITY_ENFORCED LIMIT 500000];
                
               
                    for (BLN_Relationship__c relationship : relationshipList) {
                        if (!relationshipMap.containsKey(relationship.BLN_ContactName__c)) {
                            relationshipMap.put(relationship.BLN_ContactName__c, new List<BLN_Relationship__c>());
                        }
                        relationshipMap.get(relationship.BLN_ContactName__c).add(relationship);
                    }
                
            }
        }
        catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return relationshipMap;
    }
    
    /*MethodName : getRelationshipId
*@description : This method is used to return the relationship Id.
*@return string
*@param string
*Input Parameter : String
*CreatedDate: 10-02-2024
*CreatedBy : Pwc-India
*Change log :
****************************************/
    @AuraEnabled
    public static string getRelationshipId(string contactId, string userName){
        try {
            
            BLN_Relationship__c  relationship = [select Id,BLN_RelationshipHealth__c from BLN_Relationship__c where BLN_ContactName__c =:contactId and BLN_UserName__r.Name =: userName   WITH SECURITY_ENFORCED limit 1];
           
            return relationship.Id;
        }
        catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            return null;
            
        }
    }
}