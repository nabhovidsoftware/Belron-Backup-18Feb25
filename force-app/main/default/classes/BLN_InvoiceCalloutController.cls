public with sharing class BLN_InvoiceCalloutController {

    @InvocableMethod(label='syncCloseCompletedCase' description='Completed/Close data sync' category='Case')
    public static void syncCloseCompletedCase(List<String> caseId) {

        if(caseId.size() > 0 && caseId[0] != null && caseId[0] != 'undefined') {
            String caseIdP = caseId[0].split('~')[0];
            String eventTypeP = caseId[0].split('~')[1];
            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_InvoiceCalloutName);
            Map<String,String> headerMap = new Map<String,String>();
            Integer timeout = 60000;
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
            String hCode = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
            String correlID = hCode.substring(0,4)+'-'+hCode.substring(0,4)+'-'+hCode.substring(5,8)+'-'+hCode.substring(9,12)+'-'+hCode.substring(12,16)+'-'+hCode.substring(16,20);
            headerMap.put(System.label.BLN_XCORRELATIONID, correlID);

            for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
            }
            
            String requestBody = BLN_InvoiceCalloutController.makeRequestBody('BULK_JOB', caseIdP, eventTypeP, calloutDetails.BLN_SourceSystem__c, System.Now());
            HttpResponse response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,
                                    calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c, 
                                    calloutDetails.BLN_Method__c, headerMap, caseIdP, requestBody, timeout);
            
            String returnPayloadAsString = response.getStatusCode() == 201 ? response.getBody() : System.label.BLN_CalloutFailed;
        }
    }

    private static String makeRequestBody(String entityName, String caseId, String eventType, String sourceSystem, DateTime timestamp) {

        RequestBODYWrapper requestBody = new RequestBODYWrapper();
        requestBody.entityName = entityName;
        requestBody.entityID = caseId;
        requestBody.eventType = eventType;
        requestBody.sourceSystem = sourceSystem;
        requestBody.timestamp = timestamp;
        requestBody.initialisedSystem = SourceSystem;

        CurrentWrapper currentWrp = new CurrentWrapper();
        currentWrp.caseId = caseId;
        DataWrapper dataWrapper = new DataWrapper();
        dataWrapper.current = currentWrp;
        requestBody.data = dataWrapper;
        return JSON.serialize(requestBody, true);
    }

    public class RequestBODYWrapper {
        public String entityName;
        public String entityID;
        public String eventType;
        public String sourceSystem;
        public dateTime timestamp;
        public String initialisedSystem;
        public DataWrapper data;
    }

    public class DataWrapper {
        public CurrentWrapper current;
    }

    public class CurrentWrapper {
        public String caseId;
    }
}