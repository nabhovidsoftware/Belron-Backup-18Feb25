/* @description - Creates IntegrationLogger records. Used after making API callouts.
 * @Story - FOUK-5189
 * @author - Animesh Biswas
 * @Created Date - 21/02/2024
*/ 
public without sharing class BLN_IntegrationLoggerHandler {

     /*@description : logCalloutDetails method used to create integrationLogger records.
      @Return : method returns database.SaveResult*/
    public static Database.SaveResult logCalloutDetails (Id recordId, String targetSystem, DateTime reqTime,DateTime resTime, HttpRequest request,HttpResponse response) {
        BLN_IntegrationLogger__c loggerRecord = new BLN_IntegrationLogger__c();
                
        //assignment of request details
        loggerRecord.BLN_RequestBody__c = request.getBody();
        loggerRecord.BLN_RequestEndPoint__c = request.getEndpoint();
        loggerRecord.BLN_RequestIssuedBy__c = UserInfo.getUserId();
        loggerRecord.BLN_RequestMethod__c = request.getMethod();
        loggerRecord.BLN_RequestSent__c = reqTime;
        
        //assigment of response details
        loggerRecord.BLN_ResponseBody__c = response.getBody();
        for(String keyVal : response.getHeaderkeys()){loggerRecord.BLN_ResponseHeaders__c += response.getHeader(keyVal)+'\n';}
        loggerRecord.BLN_ResponseReceived__c = resTime;
        loggerRecord.BLN_ResponseStatusCode__c = String.valueOf(response.getStatusCode());
        loggerRecord.BLN_ResponseStatus__c = response.getStatus();
        
        //assignment of other details
        loggerRecord.BLN_APICallInSeconds__c = String.valueOf(resTime.getTime() - reqTime.getTime()) ;
        loggerRecord.BLN_RecordId__c = recordId;
        loggerRecord.BLN_TargetSystem__c = targetSystem;
        
        return Database.insert(loggerRecord,false);
    }

    public static Database.SaveResult logCalloutDetailsRest(String recordId, String targetSystem, Datetime reqTime, Datetime resTime, RestRequest request, RestResponse response, String method) {
        BLN_IntegrationLogger__c loggerRecord = new BLN_IntegrationLogger__c();
        loggerRecord.BLN_RequestBody__c = request.requestBody?.toString();
        loggerRecord.BLN_RequestEndPoint__c = request.requestURI;
        loggerRecord.BLN_RequestIssuedBy__c = UserInfo.getUserId();
        loggerRecord.BLN_RequestMethod__c = method;
        loggerRecord.BLN_RequestSent__c = reqTime;
        loggerRecord.BLN_RequestHeaders__c = request.headers?.toString();
        
        loggerRecord.BLN_ResponseBody__c = response.responseBody?.toString();
        loggerRecord.BLN_ResponseHeaders__c = response.headers?.toString();
        loggerRecord.BLN_ResponseReceived__c = resTime;
        loggerRecord.BLN_ResponseStatus__c = response.statusCode?.toString();
        loggerRecord.BLN_ResponseStatusCode__c = response.statusCode?.toString();
        
        loggerRecord.BLN_APICallInSeconds__c = String.valueOf(resTime.getTime() - reqTime.getTime());
        loggerRecord.BLN_RecordId__c = recordId;
        loggerRecord.BLN_TargetSystem__c = targetSystem;
        return Database.insert(loggerRecord, false);
    }
}