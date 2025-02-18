/* @description : Utility Class for making API Callouts
 * @createdBy : Animesh Biswas (PwC)
 * @createdDate : 29/02/2024
 * @userStory : FOUK-5189
 */ 
public with sharing class BLN_HttpCalloutUtility {
    // @params : makeCallout(Boolean allowIntegrLogging, String targetSystem, String apiEndPoint, String methodType, Map<String,String> headerMap, String recordId, String payloadBody, Integer timeout)
    // @description : this callout method wil be used incase the request has a timeout value
    // retrun type : HttpResponse
    public static HttpResponse makeCallout(Boolean allowIntegrLogging, String targetSystem, String apiEndPoint, String methodType, Map<String,String> headerMap, String recordId, String payloadBody,Integer timeout){                
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        if(String.isNotBlank(apiEndPoint) && String.isNotBlank(methodType)){
        	request.setEndpoint(apiEndPoint);
        	request.setMethod(methodType);
            
        	if(timeout != 0 && timeout != null){
            	request.setTimeout(timeout);
        	}
        	if(headerMap!= null && headerMap.size() > 0){
            	for(String headerKey : headerMap.keyset()){
                	request.setHeader(headerKey, headerMap.get(headerKey)); 
            	}
        	}
            //Adding correlationId in request header
            String hCode = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
            String correlID = hCode.substring(0,4)+'-'+hCode.substring(5,8)+'-'+hCode.substring(9,12)+'-'+hCode.substring(12,16)+'-'+hCode.substring(16,20);
            request.setHeader(System.label.BLN_XCORRELATIONID,correlID);
            
        	if(String.isNotBlank(payloadBody) && !System.label.BLN_GET.equalsIgnoreCase(methodType)){
	        	request.setBody(payloadBody);            
        	}
            
			DateTime responseTimerStart = System.now();
            try{
               response = new Http().send(request); 
            } 
            catch(CalloutException e){
               response.setStatus(e.getMessage());
            }
			DateTime reponseTimerStop = System.now();
            
       		if(allowIntegrLogging){
                BLN_IntegrationLogger.captureIntegrationLogger(recordId,targetSystem,correlID,responseTimerStart,reponseTimerStop,headerMap,request,response);
            }      
        }
        else{            
            response.setStatus(System.label.BLN_IncorrectCalloutParams);
        }
        return response;
    }
    
    // @params : makeCallout(String targetSystem, String apiEndPoint, String methodType, Map<String,String> headerMap, String recordId, String payloadBody, Integer timeout)
    // @description : this callout method wil be used in case the request has a timeout value    
    public static HttpResponse makeCallout(String targetSystem, String apiEndPoint, String methodType, Map<String,String> headerMap, String recordId, String payloadBody,Integer timeout){
        return makeCallout(true,targetSystem,apiEndPoint,methodType,headerMap,recordId,payloadBody,timeout);
    }
    
     // @params : makeCallout(String targetSystem, String apiEndPoint, String methodType, Map<String,String> headerMap, String recordId, String payloadBody)
    // @description : this callout method wil be used incase the request has a body
    public static HttpResponse makeCallout(String targetSystem, String apiEndPoint, String methodType, Map<String,String> headerMap, String recordId, String payloadBody){
        return makeCallout(targetSystem,apiEndPoint,methodType,headerMap,recordId,payloadBody,0);
    }    
    
    // @params : makeCallout(String targetSystem,String apiEndPoint, String methodType, Map<String,String> headerMap, String recordId)
    // @description : this callout method wil be used in case the payload does not have a body
    public static HttpResponse makeCallout(String targetSystem, String apiEndPoint, String methodType, Map<String,String> headerMap, String recordId){
		return makeCallout(targetSystem,apiEndPoint,methodType,headerMap,recordId,'');         
    }
    
    // @params : makeCallout(String targetSystem, String apiEndPoint, String methodType, Map<String,String> headerMap)
    // @description : this callout method wil be used in ase the payload does not have a body
    public static HttpResponse makeCallout(String targetSystem, String apiEndPoint, String methodType, Map<String,String> headerMap) {
        return makeCallout(targetSystem,apiEndPoint,methodType,headerMap,'');
    }

     // @params : makeCallout(String targetSystem,String apiEndPoint,String methodType, Map<String,String> headerMap, Integer timeout)
    // @description : this callout method wil be used in ase the payload does not have a body (with timeout)
    public static HttpResponse makeCallout(String targetSystem, String apiEndPoint, String methodType, Map<String,String> headerMap, String recordId, Integer timeout){
		return makeCallout(targetSystem,apiEndPoint,methodType,headerMap,recordId,'',timeout);         
    }
    
	 // @params : makeCallout(String targetSystem,String apiEndPoint, String methodType, Map<String,String> headerMap, Integer timeout)
    // @description : this callout method wil be used in ase the payload does not have a body (with timeout)
    public static HttpResponse makeCallout(String targetSystem, String apiEndPoint, String methodType, Map<String,String> headerMap, Integer timeout){
		return makeCallout(targetSystem,apiEndPoint,methodType,headerMap,'',timeout);         
    } 
}