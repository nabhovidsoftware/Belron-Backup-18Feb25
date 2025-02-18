/** @description : This apex class used to store Integration information from Apex class
*   @author:Rahul Jain (PwC IN)
*   @CreatedDate: 24.07.2023
*   @Story: FOUK-252
*/
public with sharing class BLN_IntegrationLogger {
    
/*@description : logRequest method used to get IntegrationLogger.
@return : void.
@param : BLN_IntegrationLogger__c list */
    public static void logRequest(List<BLN_IntegrationLogger__c> intLogList){
        
        List<BLN_IntegrationLogger__c> loggerList = new  List<BLN_IntegrationLogger__c>();
        List<Attachment> attachList = new List<Attachment>();
       
        for(BLN_IntegrationLogger__c intLoggerObj : intLogList){
            String jsonString = JSON.serialize(intLoggerObj.BLN_RequestBody__c);
            Integer jsonBodyLength = jsonString.length(); 

            String jsonResponseString = JSON.serialize(intLoggerObj.BLN_ResponseBody__c);
            Integer jsonResponseBodyLength = jsonResponseString.length(); 
            
            Blob jsonAttchement = Blob.valueOf(intLoggerObj.BLN_RequestBody__c);
            
            BLN_IntegrationLogger__c objIntLogger = New BLN_IntegrationLogger__c();
            objIntLogger.BLN_APICallInSeconds__c = intLoggerObj.BLN_APICallInSeconds__c;
            objIntLogger.BLN_CorrelationId__c = intLoggerObj.BLN_CorrelationId__c;
            objIntLogger.BLN_RecordId__c = intLoggerObj.BLN_RecordId__c;
             Integer maxSize = 131072;
            if(jsonBodyLength < maxSize ){
                objIntLogger.BLN_RequestBody__c = intLoggerObj.BLN_RequestBody__c;
            } else{
                objIntLogger.BLN_RequestBody__c = intLoggerObj.BLN_RequestBody__c.substring(0, maxSize);
            }

            if(jsonResponseBodyLength < maxSize ){
                objIntLogger.BLN_ResponseBody__c = intLoggerObj.BLN_ResponseBody__c;
            } else{
                objIntLogger.BLN_ResponseBody__c = intLoggerObj.BLN_ResponseBody__c.substring(0, maxSize);
            }
            
            objIntLogger.BLN_RequestEndPoint__c = intLoggerObj.BLN_RequestEndPoint__c;
            objIntLogger.BLN_RequestHeaders__c = intLoggerObj.BLN_RequestHeaders__c; 
            objIntLogger.BLN_RequestIssuedBy__c = intLoggerObj.BLN_RequestIssuedBy__c;
            objIntLogger.BLN_RequestMethod__c = intLoggerObj.BLN_RequestMethod__c;
            objIntLogger.BLN_RequestSent__c = intLoggerObj.BLN_RequestSent__c;
            objIntLogger.BLN_ResponseHeaders__c = intLoggerObj.BLN_ResponseHeaders__c;
            objIntLogger.BLN_ResponseReceived__c = intLoggerObj.BLN_ResponseReceived__c;
            objIntLogger.BLN_ResponseStatus__c = intLoggerObj.BLN_ResponseStatus__c;
            objIntLogger.BLN_ResponseStatusCode__c = intLoggerObj.BLN_ResponseStatusCode__c;
            objIntLogger.BLN_TargetSystem__c = intLoggerObj.BLN_TargetSystem__c;
            loggerList.add(objIntLogger); 
        }
        if(BLN_IntegrationLogger__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()){
            insert loggerList;
        }
        if(Attachment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()){
            insert attachList;
        }
       // insert loggerList;
       // insert attachList;
    }

/*@description : captureIntegrationLogger method used to capture IntegrationLogger.
@return : Database.SaveResult.
@param : String recordId, String targetSystem,String correlId, DateTime reqTime,DateTime resTime,Map<String,String> reqHeaderMap, HttpRequest request,HttpResponse response */
    public static Database.SaveResult captureIntegrationLogger (String recordId, String targetSystem,String correlId, DateTime reqTime,DateTime resTime,Map<String,String> reqHeaderMap, HttpRequest request,HttpResponse response) {
        BLN_IntegrationLogger__c loggerRecord = new BLN_IntegrationLogger__c();
        String header = '';        
        //assignment of request details
        loggerRecord.BLN_RequestBody__c = request.getBody().length() <= BLN_IntegrationLogger__c.BLN_RequestBody__c.getDescribe().length ? request.getBody() : request.getBody().subString(0,BLN_IntegrationLogger__c.BLN_RequestBody__c.getDescribe().length - 1);
        loggerRecord.BLN_RequestEndPoint__c = request.getEndpoint();
        loggerRecord.BLN_RequestIssuedBy__c = UserInfo.getUserId();
        loggerRecord.BLN_RequestMethod__c = request.getMethod();
        loggerRecord.BLN_RequestSent__c = reqTime;
        loggerRecord.BLN_CorrelationId__c = correlId;
        for(String keyVal : reqHeaderMap.keySet()){header += keyVal+' '+reqHeaderMap.get(keyVal)+'  ';}
        loggerRecord.BLN_RequestHeaders__c = header;
        //assigment of response details
        loggerRecord.BLN_ResponseBody__c = response.getBody().length() <= BLN_IntegrationLogger__c.BLN_ResponseBody__c.getDescribe().length ? response.getBody() : response.getBody().subString(0,BLN_IntegrationLogger__c.BLN_ResponseBody__c.getDescribe().length - 1);
        header = '';
        for(String keyVal : response.getHeaderkeys()){header += keyVal+' '+response.getHeader(keyVal)+'  ';}
        loggerRecord.BLN_ResponseHeaders__c = header;
        loggerRecord.BLN_ResponseReceived__c = resTime;
        loggerRecord.BLN_ResponseStatusCode__c = String.valueOf(response.getStatusCode());
        loggerRecord.BLN_ResponseStatus__c = response.getStatus();
        
        //assignment of other details
        loggerRecord.BLN_APICallInSeconds__c = String.valueOf(resTime.getTime() - reqTime.getTime()) ;
        loggerRecord.BLN_RecordId__c = recordId;
        loggerRecord.BLN_TargetSystem__c = targetSystem;
        return Database.insert(loggerRecord,false);
    }

    /*@description : captureIntegrationLoggerFuture method used to make callout.
@return : void.
@param : String recordId, String targetSystem, DateTime reqTime,String correlId,DateTime resTime,Map<String,String> reqHeaderMap, String request,String response */
    @future
    public static void captureIntegrationLoggerFuture(String recordId, String targetSystem,String correlId,DateTime reqTime,DateTime resTime,Map<String,String> reqHeaderMap, String request,String response){
        HttpRequest req = String.isNotBlank(request) ? (HttpRequest) System.JSON.deserialize(request,HttpRequest.class) : new HttpRequest();
        
        HttpResponse res = String.isNotBlank(response) ? (HttpResponse) System.JSON.deserialize(response,HttpResponse.class) : new HttpResponse();
        
        captureIntegrationLogger(recordId,targetSystem,correlId,reqTime,resTime,reqHeaderMap,req,res);
    }
    
    /*R1-R2 Code Merge*/
    public static BLN_IntegrationLogger__c  createIntegrationLoggers(
            String secondsGap, HttpResponse res, HttpRequest req, Id appointmentId,
            String auth, String instanceUrl, String countryCode, String targetSystem
    ) {
        return createIntegrationLoggers(secondsGap, res, req, appointmentId, auth, instanceUrl, targetSystem, countryCode, true);
    }
    public static BLN_IntegrationLogger__c  createIntegrationLoggers(
            String secondsGap, HttpResponse res, HttpRequest req, Id appointmentId,
            String auth, String instanceUrl, String targetSystem, String countryCode, Boolean insertLog
    ) {
        String correlationId = randomCodeGenerator();
        List<BLN_IntegrationLogger__c> intLogList = new List<BLN_IntegrationLogger__c>();
        BLN_IntegrationLogger__c integrat = new BLN_IntegrationLogger__c();
        integrat.BLN_APICallInSeconds__c = secondsGap;
        integrat.BLN_CorrelationId__c = correlationId;
        integrat.BLN_RecordId__c = appointmentId;
        integrat.BLN_RequestBody__c = req.getBody();
        integrat.BLN_RequestEndPoint__c = req.getEndpoint();
        integrat.BLN_RequestHeaders__c = reqHeader(auth, correlationId, countryCode, instanceUrl);
        integrat.BLN_RequestIssuedBy__c = UserInfo.getUserId();
        integrat.BLN_RequestMethod__c = req.getMethod();
        integrat.BLN_RequestSent__c = System.today();
        integrat.BLN_ResponseBody__c = res.getBody();
        integrat.BLN_ResponseHeaders__c = resHeaders(res);
        integrat.BLN_ResponseReceived__c = System.today();
        integrat.BLN_ResponseStatus__c = res.getStatus();
        integrat.BLN_ResponseStatusCode__c = ''+res.getStatusCode();
        integrat.BLN_TargetSystem__c = targetSystem;
        intLogList.add(integrat);

        if (insertLog) {
            BLN_IntegrationLogger.logRequest(intLogList);
        }
        return integrat;
    }

    public static BLN_IntegrationLogger__c  createIntegrationLoggers(
            String secondsGap, HttpResponse res, HttpRequest req, Id appointmentId,
            String auth, String instanceUrl, String targetSystem, Boolean insertLog
    ) {
        String correlationId = randomCodeGenerator();
        List<BLN_IntegrationLogger__c> intLogList = new List<BLN_IntegrationLogger__c>();
        BLN_IntegrationLogger__c integrat = new BLN_IntegrationLogger__c();
        integrat.BLN_APICallInSeconds__c = secondsGap;
        integrat.BLN_CorrelationId__c = correlationId;
        integrat.BLN_RecordId__c = appointmentId;
        integrat.BLN_RequestBody__c = req.getBody();
        integrat.BLN_RequestEndPoint__c = req.getEndpoint();
        integrat.BLN_RequestHeaders__c = reqHeader(auth, correlationId, instanceUrl);
        integrat.BLN_RequestIssuedBy__c = UserInfo.getUserId();
        integrat.BLN_RequestMethod__c = req.getMethod();
        integrat.BLN_RequestSent__c = System.today();
        integrat.BLN_ResponseBody__c = res.getBody();
        integrat.BLN_ResponseHeaders__c = resHeaders(res);
        integrat.BLN_ResponseReceived__c = System.today();
        integrat.BLN_ResponseStatus__c = res.getStatus();
        integrat.BLN_ResponseStatusCode__c = ''+res.getStatusCode();
        integrat.BLN_TargetSystem__c = targetSystem;
        intLogList.add(integrat);

        if (insertLog) {
            BLN_IntegrationLogger.logRequest(intLogList);
        }
        return integrat;
    }



    public static String randomCodeGenerator() {
        Blob blobKey = Crypto.GenerateAESKey(128);
        String hexKey = EncodingUtil.ConvertTohex(blobKey);
        String uid = hexKey.SubString(0,8)+ '-' + hexKey.SubString(8,12) + '-' + hexKey.SubString(12,16) + '-' + hexKey.SubString(16,20) + '-' + hexKey.substring(20);
        return uid;
    }

    public static String resHeaders(HttpResponse res) {
        //get the list of header names (keys)
        String[] headerKeys = res.getHeaderKeys();
        String headers;

        //iterate through they keys, and populate your map
        for (String headerKey : headerKeys) {
            headers = res.getHeader(headerKey) + ',';
        }
        return headers;
    }

    public static String reqHeader(String auth, String correlationId, String instanceUrl) {
        String reqHeader = 'Authorization: ' + auth + ' Content-Type: application/json ' + 'X-CORRELATION-ID: ' + correlationId + ' destination: '
                + instanceUrl;
        return reqHeader;
    }

    public static String reqHeader(String auth, String correlationId, String countryCode, String instanceUrl){
        String reqHeader = 'Authorization: ' + auth + ' Content-Type: application/json ' + 'X-CORRELATION-ID: ' + correlationId + ' country-code: ' + countryCode + ' destination: '
                + instanceUrl + ' destinationType: TOPIC';
        return reqHeader;
    }
    /*R1-R2 Code Merge End*/
    
}