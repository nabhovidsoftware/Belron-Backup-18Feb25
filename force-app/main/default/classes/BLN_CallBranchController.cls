/*****************************************
ClassName : BLN_CallBranchController
Description : FOUK-7149 This controller class is used in BLN_CallBranch lwc.
CreatedDate: 16-03-2024
CreatedBy : Siddhant Pandya
****************************************/
public with sharing class BLN_CallBranchController {
    @AuraEnabled(cacheable=true)
    public static String getBranchPhone(String userId) {
        String phone;
        Datetime now = System.now();
        ServiceTerritoryMember STMRec = [select ServiceTerritory.BLN_PhoneNumber__c from ServiceTerritoryMember where ServiceResource.RelatedRecordId = :userId  and EffectiveStartDate < :now and (EffectiveEndDate >= :now or EffectiveEndDate = null) and TerritoryType = 'P'];
        if(STMRec!=null)
        {
            phone = (String)STMRec.ServiceTerritory.BLN_PhoneNumber__c;
        }
        return phone;
    }
}