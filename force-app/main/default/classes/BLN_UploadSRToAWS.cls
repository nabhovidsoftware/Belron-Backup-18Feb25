public with sharing class BLN_UploadSRToAWS {
    
    public static Map<String,String> keywordVsCategoryMap = new Map<String,String>();

    //invokable method to send data to Docstore
    @InvocableMethod(label='Service Report Ids' category='Service Report')
    public static void sendDatatoDocstore(List<ID> ids){
        processData(ids);
    }
    
    @future(callout=true)
    public static void processData(List<ID> ids){

        try {
        
            Boolean processPDFsForDocstore = false;

            List<BLN_ExternalFileLinks__c> extFileLinkList = new List<BLN_ExternalFileLinks__c>();
            List<ContentVersion> uplodedCvList =  new List<ContentVersion>();
            
            //filter by allowable file type
            List<BLN_FileTypesUploadToAWS__mdt> fileTypeMetaData = BLN_FileTypesUploadToAWS__mdt.getall().values();
            for(BLN_FileTypesUploadToAWS__mdt fileTypeMeta :fileTypeMetaData){
                if(fileTypeMeta.DeveloperName == 'PDF'){
                    processPDFsForDocstore = true;
                }
            }

            //collect all keywords vs category            
            List<BLN_FileCategoryConfig__mdt> categoryConfigMetaData = BLN_FileCategoryConfig__mdt.getall().values();
            if (categoryConfigMetaData != null && categoryConfigMetaData.size() > 0) {
                for (BLN_FileCategoryConfig__mdt configRec : categoryConfigMetaData) {
                    
                    if (configRec.BLN_Keywords__c != null) {                        
                        generateKeywordVscategoryMap(configRec);                        
                    }
                    
                }
            }
            
            if(processPDFsForDocstore){
                
                List<BLN_UploadFileToAWSQueueable.FileDataWrapper> fileDataWrapList = 
                    new List<BLN_UploadFileToAWSQueueable.FileDataWrapper>();
                
                List<ServiceReport> serviceReportList = [SELECT Id, ContentVersionDocumentId, CreatedDate,
                                                            ContentVersionDocument.FileType, 
                                                            ContentVersionDocument.FileExtension,
                                                            ContentVersionDocument.Title,
                                                            createdby.name, ParentId, ServiceReportNumber,
                                                            ContentVersionDocument.VersionData,
                                                            ContentVersionDocument.ContentSize
                                                        FROM ServiceReport 
                                                        WHERE Id IN: ids WITH SECURITY_ENFORCED];
                
                if(serviceReportList != null && serviceReportList.size() > 0){
                    //create payload
                    Map<String,String> headerMap = new Map<String,String>();
                        
                    BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_UploadDocumentLabel);    
                    headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
                    
                    for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                        headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
                    }
                    
                    for(ServiceReport srRec: serviceReportList){
                        
                        BLN_UploadFileToAWSQueueable.FileDataWrapper fileDataWrap 
                            = new BLN_UploadFileToAWSQueueable.FileDataWrapper();
                        fileDataWrap.additionalInfo = 'Additional';
                        fileDataWrap.documentType = srRec.ContentVersionDocument.FileType;
                        fileDataWrap.fileExtension = srRec.ContentVersionDocument.FileExtension;
                        String processedTitle = srRec.ServiceReportNumber.replace(':', '-');
                        fileDataWrap.fileName = processedTitle
                                                +'.'
                                                +srRec.ContentVersionDocument.FileExtension;
                        fileDataWrap.documentSource = System.label.BLN_DocumentSource;
                        fileDataWrap.createdBy = srRec.CreatedBy.Name;
                        fileDataWrap.fileBytes = EncodingUtil.base64Encode(srRec.ContentVersionDocument.VersionData);
                        fileDataWrap.associations = new List<BLN_UploadFileToAWSQueueable.AssociationWrapper>{
                            new BLN_UploadFileToAWSQueueable.AssociationWrapper(srRec.ParentId,
                                                                                System.label.BLN_SalesForceWorkOrder)
                        };
                        
                        //proceed for callout                    
                        String endPoint;
                        HttpResponse response = new HttpResponse();
                        
                        endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c;
                        
                        response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c, 
                                                                    endPoint, 
                                                                    calloutDetails.BLN_Method__c, 
                                                                    headerMap,
                                                                    '',
                                                                    JSON.serialize(new List<BLN_UploadFileToAWSQueueable.FileDataWrapper>{fileDataWrap}));
                            
                        extFileLinkList.add(createExternalFileRec(response, srRec)); 
                        
                        uplodedCvList.add(updateContentVersion(srRec.ContentVersionDocumentId));
                        
                    }
                    
                }    
                
                if(extFileLinkList != null && extFileLinkList.size() > 0 && Schema.sObjectType.BLN_ExternalFileLinks__c.isCreateable()){
                    insert extFileLinkList;
                }
                
                if(uplodedCvList != null && uplodedCvList.size() > 0 && Schema.sObjectType.ContentVersion.isUpdateable()){
                    update uplodedCvList;  
                }
                
            }

        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);    
        }
    }


    public static BLN_ExternalFileLinks__c createExternalFileRec(HttpResponse response, ServiceReport srRec){

        if ( response.getStatusCode() == 201 || response.getStatusCode() == 200) {
            BLN_UploadFileToAWSQueueable.DocStoreWrapper docStoreRes 
                            = new BLN_UploadFileToAWSQueueable.DocStoreWrapper();
            docStoreRes = (BLN_UploadFileToAWSQueueable.DocStoreWrapper) JSON.deserialize(response.getBody(), BLN_UploadFileToAWSQueueable.DocStoreWrapper.class);  
            
            BLN_ExternalFileLinks__c extFileLink = new BLN_ExternalFileLinks__c();
            extFileLink.BLN_FileName__c = srRec.ServiceReportNumber;
            extFileLink.BLN_FileType__c = srRec.ContentVersionDocument.FileType;
            extFileLink.BLN_ParentId__c = srRec.ParentId;
            extFileLink.BLN_ParentObjectName__c = srRec.ParentId.getSObjectType().getDescribe().getName();
            extFileLink.BLN_DocumentId__c = docStoreRes.docStore[0].documentId;
            extFileLink.BLN_FileCreationDate__c = srRec.CreatedDate;
            extFileLink.BLN_S3BucketLink__c = docStoreRes.docStore[0].publicLink;
            extFileLink.BLN_FileSize__c =  String.valueOf(srRec.ContentVersionDocument.ContentSize);
            
            //for categorization
            Set<String> keywords = keywordVsCategoryMap.keySet();
            
            for(String keyword : keywords){
                if(srRec.ServiceReportNumber.contains(keyword)){
                    extFileLink.BLN_Category__c = keywordVsCategoryMap.get(keyword);
                    break;
                }
            }
            
            return extFileLink;           
            
        }

        return null;

    }

    public static ContentVersion updateContentVersion(Id cvId){
        ContentVersion cv = new ContentVersion(Id = cvId,
                                                BLN_IsUploadedToAWS__c = true);

        return cv;
    }
    
    public static void generateKeywordVscategoryMap(BLN_FileCategoryConfig__mdt configRec){
        List<String> keywordList = new List<String>();
        keywordList.addAll(configRec.BLN_Keywords__c.split(','));
        if (keywordList != null && keywordList.size() > 0) {
            for (String keyword : keywordList) {
                keywordVsCategoryMap.put(keyword, configRec.BLN_CategoryType__c);
            }                
        }
    }

}