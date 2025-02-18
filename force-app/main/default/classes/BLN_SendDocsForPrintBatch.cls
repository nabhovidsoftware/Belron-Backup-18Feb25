/**@description : This batch class will send Documents for Printing
*  @author: PwC India
*  @Story: FOUK-5770 (Create Bulk Customer Service ReportFOUK-5770 File for Printing and Posting)
*  @CreatedDate: 26/04/2024
*/
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.ApexSuggestUsingNamedCred')
global class BLN_SendDocsForPrintBatch implements  Database.Batchable<sObject>,  Database.AllowsCallouts, Schedulable {
    public static Integer expiresIn;

    global Database.QueryLocator start(Database.BatchableContext bc){
        String status = System.Label.BLN_ReadyForPrintStatus;
        Datetime last24Hours = System.now().addHours(-24);
        String query = 'SELECT Id, LastModifiedDate, Status, BLN_PrintStatus__c, WorkOrderId, WorkOrder.CaseId, WorkOrder.Case.CaseNumber  FROM WorkOrderLineItem WHERE BLN_PrintStatus__c=:status AND LastModifiedDate>=:last24Hours';
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext bc, List<WorkOrderLineItem> scope){
        String oktaToken = BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken;
        if(!String.isBlank(oktaToken)){
            sendDocsToMuleSoftForPrinting(oktaToken, scope);
        }
    }
    
    global void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, JobType, ApexClassId, Status, NumberOfErrors, MethodName, CompletedDate FROM AsyncApexJob WHERE Id =: bc.getJobId()];
    }
    
    global void execute(SchedulableContext ctx) {
        Integer batchSize = 200;
        BLN_SendDocsForPrintBatch batch = new BLN_SendDocsForPrintBatch();
        Database.executeBatch(batch, batchSize);
    }

    public static void sendDocsToMuleSoftForPrinting(String accessToken, List<WorkOrderLineItem> scope){
        try{
            Map<String, String> mapOfParentIdAndAWSDocId = getMapOfParentIdAndAWSDocId(scope);
                
            // Start Preparing JSON for Request Body
            Current current = new Current();
            current.bucketName = System.Label.BLN_PrintCalloutBucketName;
            List<Document> documents = new List<Document>();

            for(WorkOrderLineItem woli:scope){
                Document doc = new Document();
                doc.woliID = woli.Id;
                if(woli.WorkOrder!=null){
                    if(woli.WorkOrder.CaseId!=null){
                        doc.caseId = woli.WorkOrder.Case.CaseNumber!=null ? woli.WorkOrder.Case.CaseNumber : '';
                    }
                }
                if(!mapOfParentIdAndAWSDocId.isEmpty() && mapOfParentIdAndAWSDocId.containsKey(woli.Id)){
                    doc.serviceReportDocumentId = mapOfParentIdAndAWSDocId.get(woli.Id);// get the serviceReportDocumentId from AWS
                }
                else{
                    doc.serviceReportDocumentId = '';
                }
                documents.add(doc);
            }

            current.documents = documents;

            Data data = new Data();
            data.current = current;

            PayloadWrapper payLoad = new PayloadWrapper();
            payLoad.entityName = '';
            payLoad.entityID = '';
            payLoad.eventType = System.Label.BLN_PrintEventType;
            payLoad.sourceSystem = '';
            payLoad.timestamp = makeTimeStamp();
            payLoad.initialisedSystem = '';
            payLoad.data = data;

            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_DocsForPrintApi);
            Map<String,String> headerMap = new Map<String,String>();
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+accessToken);
            
            if(String.isNotBlank(calloutDetails.BLN_Headers__c)){
                for(String header : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                    if(header.contains(System.label.BLN_Comma)){
                        headerMap.put(header.split(System.label.BLN_Comma)[0],header.split(System.label.BLN_Comma)[1]);
                    }
                }
            }
            Integer timeout = Integer.valueOf(calloutDetails.BLN_APITimeout__c);
            HttpResponse res = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c, calloutDetails.BLN_Method__c,headerMap,'Send Docs For Printing',JSON.serialize(payLoad),timeout);
           
        } catch (Exception ex) {
            // Store Exception Logger Record
            BLN_ExceptionLogger.captureException(ex);
        }
    }
    
    public static string resHeaders(HttpResponse res){
        string[] headerkeys = res.getHeaderKeys();
        String headers;
        for(String header : headerkeys){
            headers = res.getHeader(header) + ',';
        }
        return headers;
    }
    
    public static String randomCodeGenerator() {
        Blob blobKey = Crypto.GenerateAESKey(128);
        String hexKey = EncodingUtil.ConvertTohex(blobKey);
        String uid = hexKey.SubString(0,8)+ '-' + hexKey.SubString(8,12) + '-' + hexKey.SubString(12,16) + '-' + hexKey.SubString(16,20) + '-' + hexKey.substring(20);
        return uid;
    }
    
    public static String makeTimeStamp(){
        String currentDateTime = '';
        currentDateTime = System.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSSSSZ');
        String last2Chars = currentDateTime.right(2);
        currentDateTime = currentDateTime.removeEnd(last2Chars);
        currentDateTime = currentDateTime + ':' + last2Chars;
        return currentDateTime;
    }

    public static Map<String, String> getMapOfParentIdAndAWSDocId(List<WorkOrderLineItem> scope){
        Map<String, String> mapOfParentIdAndAWSDocId = new Map<String, String>();
        Set<Id> setOfWoliIds = new Set<Id>();
        for(WorkOrderLineItem woli:scope){
            setOfWoliIds.add(woli.Id);
        }

        if(!setOfWoliIds.isEmpty()){
            List<BLN_ExternalFileLinks__c> externalLinks = [SELECT Id, BLN_ParentId__c, BLN_DocumentId__c 
                                                            FROM BLN_ExternalFileLinks__c 
                                                            WHERE BLN_ParentId__c IN:setOfWoliIds
                                                           		AND BLN_FileType__c = 'PDF'
                                                           	AND BLN_Category__c = 'Post-Inspection'];
            for(BLN_ExternalFileLinks__c link:externalLinks){
                if(link.BLN_ParentId__c!=null && link.BLN_DocumentId__c!=null){
                    mapOfParentIdAndAWSDocId.put(link.BLN_ParentId__c, link.BLN_DocumentId__c);
                }
            }
        }
        return mapOfParentIdAndAWSDocId;
    }

    public class PayloadWrapper {
        public String entityName{get;set;}
        public String entityID{get;set;}
        public String eventType{get;set;}
        public String sourceSystem{get;set;}
        public String timestamp{get;set;}
        public String initialisedSystem{get;set;}
        public Data data{get;set;}
    }  

    public class Data {
        public Current current{get;set;}
    }

    public class Current {
        public String bucketName{get;set;}
        public List<Document> documents{get;set;}
    }
    
	public class Document {
		public String caseId{get;set;}
		public String woliID{get;set;}
		public String serviceReportDocumentId{get;set;}
	}    
}