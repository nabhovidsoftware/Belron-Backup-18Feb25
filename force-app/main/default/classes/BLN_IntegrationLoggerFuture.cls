public class BLN_IntegrationLoggerFuture {
    @future
    public static void processIntegrationLogger(String serializedIntLogListJSON) {
        // Deserialize the serialized JSON array of integration logger records
        List<BLN_IntegrationLogger__c> deserializedIntLogList = (List<BLN_IntegrationLogger__c>) JSON.deserialize(serializedIntLogListJSON, List<BLN_IntegrationLogger__c>.class);
        system.debug('deserializedIntLogListRequest : '+ deserializedIntLogList);
        insert deserializedIntLogList;
    }
    
    /*- commenting this as not require
    @future
    public static void processIntegrationLoggerResponse(String serializedIntLogListJSON) {
        DateTime requestSentDT = null;
        BLN_IntegrationLogger__c intLoggerInst;
        // Deserialize the serialized JSON array of integration logger records
        List<BLN_IntegrationLogerWrapper.ResponseWrapper> deserializedIntLogList = (List<BLN_IntegrationLogerWrapper.ResponseWrapper>) JSON.deserialize(serializedIntLogListJSON, List<BLN_IntegrationLogerWrapper.ResponseWrapper>.class);
        system.debug('deserializedIntLogList : '+ deserializedIntLogList);
        
        if(!String.isEmpty(deserializedIntLogList[0].requestTimeStamp)){
        	requestSentDT = Datetime.valueOf(deserializedIntLogList[0].requestTimeStamp);
        }
        //fetch the integration log record
        if(deserializedIntLogList.size()>0){
            List<BLN_IntegrationLogger__c> intLogger = [Select id, 
                                                  BLN_ResponseBody__c, 
                                                  BLN_ResponseReceived__c, 
                                                  BLN_ResponseStatus__c, 
                                                  BLN_ResponseStatusCode__c 
                                                  From BLN_IntegrationLogger__c 
                                                  Where BLN_RecordId__c =: deserializedIntLogList[0].remedyJobId AND
                                                  BLN_RequestSent__c =: requestSentDT LIMIT 1 ];
            if(intLogger.size() >0){
                intLogger[0].BLN_ResponseBody__c =deserializedIntLogList[0].responseBody;
                intLogger[0].BLN_ResponseReceived__c=!String.isEmpty(deserializedIntLogList[0].responseReceived)?Datetime.valueOf(deserializedIntLogList[0].responseReceived):null;
                intLogger[0].BLN_ResponseStatus__c=deserializedIntLogList[0].responseStatus;
                intLogger[0].BLN_ResponseStatusCode__c=deserializedIntLogList[0].responseStatusCode;
                update intLogger[0];
            }
            else{
                intLoggerInst = new BLN_IntegrationLogger__c();
                intLoggerInst = deserializedIntLogList[0].intLogger;
                intLoggerInst.BLN_ResponseBody__c =deserializedIntLogList[0].responseBody;
                intLoggerInst.BLN_ResponseReceived__c=!String.isEmpty(deserializedIntLogList[0].responseReceived)?Datetime.valueOf(deserializedIntLogList[0].responseReceived):null;
                intLoggerInst.BLN_ResponseStatus__c=deserializedIntLogList[0].responseStatus;
                intLoggerInst.BLN_ResponseStatusCode__c=deserializedIntLogList[0].responseStatusCode;
                insert intLoggerInst;
            }
        }
        //insert deserializedIntLogList;
    }
    */
}