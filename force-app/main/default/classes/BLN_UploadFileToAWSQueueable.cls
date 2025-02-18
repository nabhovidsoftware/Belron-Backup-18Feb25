/*****************************************
ClassName : BLN_UploadFileToAWSQueueable
Description : FOUK-7053
CreatedDate: 25-06-2024
CreatedBy : PwC-India
****************************************/


/*  *@description:This class is used to upload file to AWS*/
public with sharing class BLN_UploadFileToAWSQueueable implements Queueable, Database.AllowsCallouts  {
    public Map<String,String> keywordVsCategoryMap = new Map<String,String>();
    public List<ContentDocumentLink> cdlList{get;set;}
/**
*@description:This is a constructor.
*@return 
*/
    public BLN_UploadFileToAWSQueueable(List<ContentDocumentLink> cdlList){
           this.cdlList = cdlList;
         }

        /**
*@description:This is method used to do callout 
*@return  void
*/
    public void execute(QueueableContext context) {

        try{
            //collect all keywords vs category            
            List<BLN_FileCategoryConfig__mdt> categoryConfigMetaData = BLN_FileCategoryConfig__mdt.getall().values();
            if (categoryConfigMetaData != null && categoryConfigMetaData.size() > 0) {
                for (BLN_FileCategoryConfig__mdt configRec : categoryConfigMetaData) {
                    
                    if (configRec.BLN_Keywords__c != null) {                        
                        generateKeywordVscategoryMap(configRec);                        
                    }
                    
                }
            }


            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink cdl : cdlList) {

                if(cdl.ContentDocumentId!=null){
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }
            }
        
            List<ContentVersion> newCvList = new List<ContentVersion>();
            if(Schema.sObjectType.ContentVersion.isAccessible()){
                newCvList = [SELECT Id, ContentDocumentId, VersionData, Title, FileType, FileExtension, CreatedBy.Name, CreatedDate, 
                                ContentSize,BLN_IsUploadedToAWS__c 
                            FROM ContentVersion 
                            WHERE ContentDocumentId IN :contentDocumentIds WITH SECURITY_ENFORCED];
        }
        
        List<String> fileTypeList = new List<String>();
        List<BLN_FileTypesUploadToAWS__mdt> fileTypeMetaData = BLN_FileTypesUploadToAWS__mdt.getall().values();
        for(BLN_FileTypesUploadToAWS__mdt fileTypeMeta :fileTypeMetaData){
            if(fileTypeMeta.DeveloperName!=null){
            fileTypeList.add(fileTypeMeta.DeveloperName);
            }
        }
        // Create a map to store ContentVersion records with ContentDocumentId as the key
        Map<Id, ContentVersion> documentVersionMap = new Map<Id, ContentVersion>();
        for (ContentVersion cv : newCvList) {
                if(fileTypeList.contains(cv.FileExtension) && cv.ContentDocumentId!=null){
            documentVersionMap.put(cv.ContentDocumentId, cv);
            }
        }
            // // Query ContentDocumentLink records associated with the ContentDocumentId
            // List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            // if(Schema.sObjectType.ContentDocumentLink.isAccessible()){
            //  cdlList = [SELECT Id, ContentDocumentId, LinkedEntityId, LinkedEntity.Type FROM ContentDocumentLink WHERE ContentDocumentId IN :documentVersionMap.keySet() ];
            // }
            // List to store FileDataWrapper objects
            List<FileDataWrapper> fileDataWrapList = new List<FileDataWrapper>();
        
            for (ContentDocumentLink cdl : cdlList) {
                if (documentVersionMap.containsKey(cdl.ContentDocumentId)) {
                ContentVersion cv = documentVersionMap.get(cdl.ContentDocumentId);
                // Create a new FileDataWrapper object and populate it with data from ContentVersion
                FileDataWrapper fileDataWrap = new FileDataWrapper();
                fileDataWrap.additionalInfo = 'Additional';
                fileDataWrap.documentType = cv.FileType;
                fileDataWrap.fileExtension = cv.FileExtension;
                fileDataWrap.fileName = cv.Title +'.'+cv.FileExtension;
                fileDataWrap.documentSource = System.label.BLN_DocumentSource;
                fileDataWrap.createdBy = cv.CreatedBy.Name; // Uncomment and use CreatedById if needed
                fileDataWrap.fileBytes = EncodingUtil.base64Encode(cv.VersionData);
                fileDataWrap.associations = new List<AssociationWrapper>{
                    new AssociationWrapper(cdl.LinkedEntityId,System.label.BLN_SalesForceWorkOrder)
                };
                fileDataWrapList.add(fileDataWrap);
            }
        }


        String endPoint;
        HttpResponse response = new HttpResponse();
        Map<String,String> headerMap = new Map<String,String>();
        DocStoreWrapper docStoreRes = new DocStoreWrapper(); 
        List<ContentVersion> uplodedCvList =  new List<ContentVersion>();
        // DocStoreErrorWrapper docStoreError = new DocStoreErrorWrapper();
        List<BLN_ExternalFileLinks__c> extFileLinkList = new List<BLN_ExternalFileLinks__c>();
            
        Map<String,DocInfoWrapper> docStoreInfoMap = new Map<String,DocInfoWrapper>();

            if(!fileDataWrapList.isEmpty()){
                BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_UploadDocumentLabel);    
                headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
            
        for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
            headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
        }
        endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c;
                Integer timeout = Integer.valueOf(calloutDetails.BLN_APITimeout__c);
                response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c, endPoint, calloutDetails.BLN_Method__c, headerMap,'',JSON.serialize(fileDataWrapList),timeout);
        }

        if ( response.getStatusCode() == 201 || response.getStatusCode() == 200) {
            docStoreRes = (DocStoreWrapper) JSON.deserialize(response.getBody(), DocStoreWrapper.class);  
            for(DocInfoWrapper docStore: docStoreRes.docStore){
                docStoreInfoMap.put(docStore.associationId,docStore);
            }
                
            }
            
           for(ContentDocumentLink cdl: cdlList){
                if(docStoreInfoMap.containsKey(cdl.LinkedEntityId) && documentVersionMap.containsKey(cdl.ContentDocumentId)){
                    DocInfoWrapper docStoreInfo = docStoreInfoMap.get(cdl.LinkedEntityId);
                    ContentVersion cv = documentVersionMap.get(cdl.ContentDocumentId);
                    BLN_ExternalFileLinks__c extFileLink = new BLN_ExternalFileLinks__c();
                    extFileLink.BLN_FileName__c = cv.Title;
                    extFileLink.BLN_FileType__c = cv.FileType;
                    extFileLink.BLN_ParentId__c = docStoreInfo.associationId;
                    extFileLink.BLN_ParentObjectName__c = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
                    extFileLink.BLN_DocumentId__c = docStoreInfo.documentId;
                    extFileLink.BLN_FileCreationDate__c = cv.CreatedDate;
                    extFileLink.BLN_S3BucketLink__c = docStoreInfo.publicLink;
                    extFileLink.BLN_FileSize__c =  String.valueOf(cv.ContentSize);

                    //for categorization
                    Set<String> keywords =keywordVsCategoryMap.keySet();

                    for(String keyword : keywords){
                        if(cv.Title.contains(keyword)){
                            extFileLink.BLN_Category__c =  keywordVsCategoryMap.get(keyword);
                            break;
                        }
                    }
                    extFileLinkList.add(extFileLink);
                    uplodedCvList.add(new ContentVersion(Id = cv.Id , BLN_IsUploadedToAWS__c = true));
                }
            }
            

            if(!extFileLinkList.isEmpty() && Schema.sObjectType.BLN_ExternalFileLinks__c.isCreateable()){
                insert extFileLinkList;
            }

            if(!uplodedCvList.isEmpty() && Schema.sObjectType.BLN_ExternalFileLinks__c.isCreateable()){
          update uplodedCvList;
      }
    }
        catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
        }
    }


    
    public void generateKeywordVscategoryMap(BLN_FileCategoryConfig__mdt configRec){
        List<String> keywordList = new List<String>();
        keywordList.addAll(configRec.BLN_Keywords__c.split(','));
        if (keywordList != null && keywordList.size() > 0) {
            for (String keyword : keywordList) {
                keywordVsCategoryMap.put(keyword, configRec.BLN_CategoryType__c);
            }                
        }
    }
    
     // Inner class to wrap file data
     public class FileDataWrapper {
        public String additionalInfo;
        public String documentType;
        public String fileExtension;
        public String fileName;
        public String documentSource;
        public String createdBy;
        public String fileBytes;
        public List<AssociationWrapper> associations;
    }
    // Inner class to wrap associations
    public class AssociationWrapper {
        public String associationId;
        public String typeOfAssociation;
        
        // Constructor for AssociationWrapper
        public AssociationWrapper(String associationId,string typeOfAssociation) {
            this.associationId = associationId;
            this.typeOfAssociation = typeOfAssociation; // Initialize with default or actual type if needed
        }
    }
    public class DocStoreWrapper {
        public List<DocInfoWrapper> docStore { get; set; }
    
    }
    public class DocInfoWrapper {
        public String associationId { get; set; }
        public String documentId { get; set; }
        public String publicLink { get; set; }
    }
}