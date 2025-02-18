/** @description : This apex class is used for FOUK-4719.
*  @author: (pruthvising.vanrajsinh.pujara@pwc.com (IN))
*  @Story: FOUK-4719
*/
public with sharing class BLN_SaveSignature {
    @AuraEnabled(cacheable=true)
    public static String getSARecord(String woliId){
        Id serviceAppoinmentId = [select id from ServiceAppointment where ParentRecordId =: woliId Limit 1].Id;
        return serviceAppoinmentId;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getContentDocumentId(String contVerId){
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contVerId].ContentDocumentId;
        return contentDocumentId;
    }

    @AuraEnabled
    public static String saveSignature(String fileContent, String fileName,String woliId){
        Id workorderId = [select id,WorkOrderId from WorkOrderLineItem where id =:woliId Limit 1].WorkOrderId;
        Id serviceAppoinmentId = [select id from ServiceAppointment where BLN_WorkOrderNumber__c =: workorderId Limit 1].Id;
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = fileName;
        conVer.Title = fileName;
        conVer.VersionData = EncodingUtil.base64Decode(fileContent);
        if(Schema.sObjectType.ContentVersion.isCreateable()){
            insert conVer;
        }
        

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = serviceAppoinmentId;
        conDocLink.ContentDocumentId = conDoc; 
        conDocLink.shareType = 'V';
        try{
            if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
                insert conDocLink;
            }
            return 'Success';
        }catch(Exception e){
            return 'Error while Inserting the File';
        }
    }
    @AuraEnabled
    public static DateTime getCurrentDateTime(){
        User usr = new User();
        Id userId = UserInfo.getUserId();
        usr = [Select Id,TimeZoneSidKey From User Where Id =: userId WITH SECURITY_ENFORCED LIMIT 1];
        Datetime gmtDateTime = System.now();
        return gmtDateTime;
    }

    @AuraEnabled
    public static Boolean checkSTRelease(String woliID){
        try {
            WorkOrderLineItem woli = [SELECT Id, ServiceTerritory.BLN_ConsiderforR1__c FROM WorkOrderLineItem WHERE Id = :woliID WITH SECURITY_ENFORCED];
            return woli.ServiceTerritory.BLN_ConsiderforR1__c;
            
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return false;
    }
}