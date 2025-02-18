public with sharing class BLN_UploadPhotoToServiceCertaintyCallout{
    
    @InvocableMethod(label='Send Image To Service Certainty' callout=true)
    public static void uploadPhotosToServiceCertainty(List<BLN_ExternalFileLinks__c> extFileList){
        List<BLN_ExternalFileLinks__c> eligibleRecords = new List<BLN_ExternalFileLinks__c>();
        Set<String> imageNameToSendSet = new Set<String>();
        
        //Collect all tags from config to send particular images to Service Certainty
        List<BLN_ServiceCertaintyImageTags__mdt> imageNameToSend = [Select DeveloperName 
                                                                    From BLN_ServiceCertaintyImageTags__mdt WITH SECURITY_ENFORCED];
        
        for(BLN_ServiceCertaintyImageTags__mdt imageName : imageNameToSend){
            if(!imageNameToSendSet.contains(imageName.DeveloperName)){
                imageNameToSendSet.add(imageName.DeveloperName);
            }
        }
        //Filter out eligible file records
        for (BLN_ExternalFileLinks__c extFile : extFileList) {
            for(String imageNameoInclude : imageNameToSendSet){
               
                if (extFile.BLN_ParentObjectName__c != null 
                    	&& extFile.BLN_FileName__c !=null  
                    	&& extFile.BLN_FileName__c.contains(imageNameoInclude) 
                    	&& (extFile.BLN_ParentObjectName__c.equalsIgnoreCase('WorkOrderLineItem'))
                   		&& extFile.BLN_ParentId__c != null
                   ) {
                    eligibleRecords.add(extFile);
                }
            }
        }
        
        if (!eligibleRecords.isEmpty()) {
            Set<Id> woliIds = new Set<Id>();
            for (BLN_ExternalFileLinks__c extFileRec : eligibleRecords) {
                if(!woliIds.contains(extFileRec.BLN_ParentId__c)){
                	woliIds.add(extFileRec.BLN_ParentId__c);    
                }                
            }
            
            List<WorkOrderLineItem> wolis = [SELECT Id, WorkOrder.Case.BLN_AssignmentID__c, WorkOrder.Case.CaseNumber 
                                             FROM WorkOrderLineItem 
                                             WHERE Id IN :woliIds WITH SECURITY_ENFORCED];
            
            Map<Id, String> woliIdVsAssignmentId = new Map<Id, String>();
            Map<Id, String> woliIdVsCaseNumber = new Map<Id, String>();
            for (WorkOrderLineItem woLi : wolis) {
                woliIdVsAssignmentId.put(woLi.Id, woLi.WorkOrder.Case.BLN_AssignmentID__c);
                woliIdVsCaseNumber.put(woli.Id, woli.WorkOrder.Case.CaseNumber);
            } 
            
            List<ServiceCertanityWrapper> wrappersToSend = new List<ServiceCertanityWrapper>();
            for (BLN_ExternalFileLinks__c extFileRec : eligibleRecords) {
                if(woliIdVsAssignmentId.containsKey(extFileRec.BLN_ParentId__c) 
                   	&& woliIdVsAssignmentId.get(extFileRec.BLN_ParentId__c) != null
                  	&& woliIdVsCaseNumber.containskey(extFileRec.BLN_ParentId__c)
                   	&& woliIdVsCaseNumber.get(extFileRec.BLN_ParentId__c) != null
                  ){
					ServiceCertanityWrapper wrapper = new ServiceCertanityWrapper();
                    wrapper.entityName = '';
                    wrapper.entityID = woliIdVsAssignmentId.get(extFileRec.BLN_ParentId__c);
                    wrapper.eventType = 'Create';
                    wrapper.sourceSystem = 'Salesforce';
                    wrapper.timestamp = Datetime.now();
                    wrapper.initialisedSystem = 'Salesforce';
                    wrapper.data = new DataWrapper();
                    wrapper.data.current = new CurrentWrapper();
                    wrapper.data.current.caseId = woliIdVsCaseNumber.get(extFileRec.BLN_ParentId__c);
                    wrapper.data.current.assignmentId = woliIdVsAssignmentId.get(extFileRec.BLN_ParentId__c);
                    wrapper.data.current.documentId = extFileRec.BLN_DocumentId__c;
                    wrappersToSend.add(wrapper);
                }         

            }
            if(wrappersToSend.size() > 0){
                sendDataToMuleServiceCertainty(wrappersToSend);
            }

        }
    }
    
    public static void sendDataToMuleServiceCertainty(List<ServiceCertanityWrapper> wrappersToSend){
        String oktaToken = BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken;
        for(ServiceCertanityWrapper payload: wrappersToSend){
        	makeCallout(oktaToken, payload);    
        }
    }

    public static void makeCallout(String accessToken, ServiceCertanityWrapper payload){
        try{
            HttpResponse res;
            String auth = System.label.BLN_Bearer + ' ' + accessToken;
            String destination = System.label.BLN_ServiceCertaintyMulesoftDestination;
            String reqHeader;
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            
            String correlationId = randomCodeGenerator();  
            req.setMethod('POST');
            req.setHeader('Authorization', auth);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('X-CORRELATION-ID', correlationId);
            req.setHeader('country-code', 'UK');
            req.setHeader('destination', destination);
            req.setHeader('destinationType', 'Topic');
            req.setHeader('legacyBroker', 'false');
            req.setHeader('businessGroup', 'Customer');
            
            reqHeader =	'Authorization: ' + auth +
                        ' Content-Type: application/json' +
                        ' X-CORRELATION-ID: ' + correlationId +
                        ' country-code: ' + 'UK' +
                        ' destination: '  + destination +
                        ' destinationType: Topic'+
                        'legacyBroker: false' +
                        'businessGroup: Customer';        
            String endPoint = System.label.BLN_MulesoftServiceCertaintyEndpoint;
            req.setEndpoint(endPoint);
            req.setTimeout(Integer.valueof(120000));
            req.setBody(JSON.serialize(payload));
            
            DateTime t1 = System.Now();
            res = http.send(req);
            DateTime t2 = System.Now();
            
            Decimal decSec2 = t2.getTime();
            Decimal decSec1 = t1.getTime();
            Decimal miliDiff = decsec2 - decsec1;
            Decimal secDiff = miliDiff/1000;
            Decimal rounded = secDiff.setScale(3);
            String secondsGap = String.valueOf(rounded);
            
            if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getbody() != null) {
                // Store Integration Logger Record
                List<BLN_IntegrationLogger__c> intLogList = new List<BLN_IntegrationLogger__c>();
                BLN_IntegrationLogger__c integrat = new BLN_IntegrationLogger__c();
                integrat.BLN_APICallInSeconds__c = secondsGap;
                integrat.BLN_RequestBody__c = req.getBody();
                integrat.BLN_RequestEndPoint__c = req.getEndpoint();
                integrat.BLN_RequestHeaders__c = reqHeader;
                integrat.BLN_RequestIssuedBy__c = UserInfo.getUserId();
                integrat.BLN_RequestMethod__c = req.getMethod();
                integrat.BLN_RequestSent__c = System.today();
                integrat.BLN_ResponseBody__c = res.getBody();
                integrat.BLN_ResponseHeaders__c = resHeaders(res);
                integrat.BLN_ResponseReceived__c = System.today();
                integrat.BLN_ResponseStatus__c = res.getStatus();
                integrat.BLN_ResponseStatusCode__c = ''+res.getStatusCode();
                integrat.BLN_TargetSystem__c = System.label.BLN_TargetSystemMulesoft;
                intLogList.add(integrat);

                BLN_IntegrationLogger.logRequest(intLogList);
            }
        }
        catch(Exception ex){
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
        String uid = hexKey.SubString(0,8)
            			+ '-' 
            			+ hexKey.SubString(8,12) 
            			+ '-' 
            			+ hexKey.SubString(12,16) 
            			+ '-' 
            			+ hexKey.SubString(16,20) 
            			+ '-' 
            			+ hexKey.substring(20);
        return uid;
    }
    
    
    public class ServiceCertanityWrapper{
        public string entityName{get;set;}
        public string entityID{get;set;}
        public string eventType{get;set;}
        public string sourceSystem{get;set;}
        public Datetime timestamp{get;set;}
        public string initialisedSystem{get;set;}
        public DataWrapper data {get;set;}
    }

    public class DataWrapper{
        public CurrentWrapper current{get;set;}
    }
    public class CurrentWrapper{
        public string caseId{get;set;}
        public string assignmentId{get;set;}
        public string documentId{get;set;}
    }

}