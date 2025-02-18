/*****************************************
*ClassName : Bln_PortalEnquiryFormController
*@description : FOUK- This controller class is used in LWC.
*CreatedDate: 29-04-2024
*CreatedBy : PwC-India
****************************************/
public without sharing class Bln_PortalEnquiryFormController {
    
    /*MethodName : createCaseRecord
*@description : This method is used for to create case record
*@return string
*@param caseData,base64Data,fileName
*Output Parameter : 
*CreatedDate: 29-04-2024
*CreatedBy : Pwc-India
*Change log :
****************************************/
    @AuraEnabled
    public static Map<String,String> createCaseRecord(Case caseData , string base64Data , string fileName){
        Map<String,String> caseRecordMap = new Map<String,string>();
        string caseId = null;
        try {
            
            
            caseData.Type = 'Enquiry';
            
            caseData.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BLN_Enquiry').getRecordTypeId();
            
            
            AssignmentRule AR = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true AND Name = 'B2B Case Assignment Rules' LIMIT 1];
            if (AR.Id != null) {
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.Id;
                dmlOpts.EmailHeader.triggerAutoResponseEmail = true;
                dmlOpts.EmailHeader.triggerUserEmail = true;
                caseData.setOptions(dmlOpts);
            } 
            insert caseData;
            
            // Create a ContentVersion record
            if(base64Data!=null & fileName!=null){
                ContentVersion contentVersion = new ContentVersion(
                    Title = fileName,
                    PathOnClient = fileName,
                    VersionData = EncodingUtil.base64Decode(base64Data),
                    IsMajorVersion = true
                );
                insert contentVersion;
                
                // Create a ContentDocumentLink to associate the ContentVersion with the Task
                ContentDocumentLink contentLink = new ContentDocumentLink(
                    ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId,
                    LinkedEntityId = caseData.Id,
                    ShareType = 'V' 
                );
                insert contentLink;  
            }
            
            if(caseData.Id !=null){
                List<Case> caseRecordList = [select Id, CaseNumber from case where id =: caseData.Id limit 1];
                if(caseRecordList!=null){
                caseRecordMap.put('Id',caseRecordList[0].Id);
                caseRecordMap.put('CaseNumber',caseRecordList[0].CaseNumber); 
                }
            }
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return caseRecordMap;
    }
    /*MethodName : isVRNRegistered
*@description : This method is used to check vrn registration
*@return string
*@param vrn
*Output Parameter : 
*CreatedDate: 29-04-2024
*CreatedBy : Pwc-India
*Change log :
****************************************/   
    @AuraEnabled
    public static String isVRNRegistered(String vrn) {
        
        String vehicleId = null;
        try{
            List<BLN_Vehicle__c> existingVehicles = [SELECT Id FROM BLN_Vehicle__c WHERE BLN_VehicleRegNumber__c = :vrn LIMIT 1];
            if (!existingVehicles.isEmpty()) {
                vehicleId = existingVehicles[0].Id;
            }
        }
        catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
            
        }
        return vehicleId;
    }
    
    
}