/*****************************************
ClassName : BLN_DisplayDocStoreRecordsController
Description : FOUK-7055
CreatedDate: 25-06-2024
CreatedBy : PwC-India
****************************************/
/*  *@description:This class is used to open and download files uploaded on the AWS storage */

public without sharing class BLN_DisplayDocStoreRecordsController {
    @AuraEnabled (cacheable=true)
    public static WrapperList getFileDetails(Id parentId, boolean isCommunity){
        WrapperList wrap = new WrapperList();
        try {

            Id recordId  = parentId;
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            wrap.objName = sObjName;
            List<BLN_ExternalFileLinks__c> extFileLinkList = [SELECT Id, BLN_FileName__c, BLN_FileType__c, BLN_FileSize__c,BLN_FileCreationDate__c,BLN_ParentId__c,BLN_ParentObjectName__c,BLN_S3BucketLink__c,BLN_DocumentId__c,BLN_Category__c FROM BLN_ExternalFileLinks__c WHERE BLN_ParentId__c =: parentId AND BLN_ParentObjectName__c =: sObjName WITH SECURITY_ENFORCED ];
             
            SObjectAccessDecision decisionExtFileLinkList = Security.stripInaccessible(
            AccessType.READABLE, 
            extFileLinkList
            );

            Map<String,boolean> showToCustomerMap = new Map<String,boolean> ();
            List<BLN_FileCategoryConfig__mdt> categoryConfigMetaData = BLN_FileCategoryConfig__mdt.getall().values();
            for(BLN_FileCategoryConfig__mdt fileCategory: categoryConfigMetaData){
                if(fileCategory.BLN_CategoryType__c!=null){
                showToCustomerMap.put(fileCategory.BLN_CategoryType__c,fileCategory.BLN_ShowToCustomer__c);
               }
            }
            
            List<BLN_ExternalFileLinks__c> extFileLinkForPortal = new List<BLN_ExternalFileLinks__c>();
            for(BLN_ExternalFileLinks__c extFile: extFileLinkList){
              
               if(showToCustomerMap.containsKey(extFile.BLN_Category__c) && showToCustomerMap.get(extFile.BLN_Category__c)){
                extFileLinkForPortal.add(extFile);
               }
            }
            if(isCommunity){
                wrap.fileList = extFileLinkForPortal ;
            }
            else{
                wrap.fileList = extFileLinkList;
            }
            wrap.fileList = [SELECT Id, BLN_FileName__c, BLN_FileType__c, BLN_FileSize__c,BLN_FileCreationDate__c,BLN_ParentId__c,BLN_ParentObjectName__c,BLN_S3BucketLink__c,BLN_DocumentId__c,BLN_Category__c FROM BLN_ExternalFileLinks__c WHERE BLN_ParentId__c =: parentId AND BLN_ParentObjectName__c =: sObjName ];
            SObjectAccessDecision decision = Security.stripInaccessible(
                                            AccessType.READABLE,
                                            wrap.fileList);
            return wrap;

            
        } catch (Exception e) {
          //  throw new AuraHandledException(e.getMessage());
            BLN_ExceptionLogger.captureException(e);
            String errorMsg = string.valueof(e);
            wrap.errorMessage = errorMsg;
            return  wrap;
        }
    }

    @AuraEnabled
    public static String fetchDocumentDetails(string docId){
        Integer timeout = 30000;
        String endPoint;
        HttpResponse response = new HttpResponse();
        String getResponseStr ;
        Map<String,String> headerMap = new Map<String,String>();
       try{
        BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_FetchDocumentLabel);    
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
 
        endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c + '/'+ docId;
        
        response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c, endPoint, calloutDetails.BLN_Method__c, headerMap,'','',timeout);
        
        getResponseStr = response.getBody();
        return getResponseStr;
       }catch (Exception e) {
        BLN_ExceptionLogger.captureException(e);
       
        return string.valueof(e);
       }     

    }

    public class WrapperList{
        @AuraEnabled public List<BLN_ExternalFileLinks__c> fileList = new List<BLN_ExternalFileLinks__c>();
        @AuraEnabled public String objName;
        @AuraEnabled public String errorMessage; 
    }
}