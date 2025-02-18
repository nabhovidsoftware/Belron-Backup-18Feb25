/**@description : This Apex class used to send callout and mapping.
*  @author: PwC India
*  @Story:
*  @CreatedDate: 10/07/2024
*/

public without sharing class BLN_QueueMSGSessionCallout implements Queueable, Database.AllowsCallouts {
    private String payloadJson = '';

/**
*@description:This is a constructor.
*@return 
*/
    public BLN_QueueMSGSessionCallout(String json) {
        payloadJson = json;
    }

     /**
*@description:This is method used to do callout and field mapping.
*@return  void
*/
public void execute(QueueableContext context) {
    String responseBody = '';
    try{
        String requestBody = payloadJson;
        BLN_APICalloutMapper__mdt calloutData = BLN_APICalloutMapper__mdt.getInstance('BLN_MSGSessionApiCallout');

         Map<String,String> headerMap = new Map<String,String>();
         headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
         for(String header : calloutData.BLN_Headers__c.split(System.label.BLN_Semicolon)){
             headerMap.put(header.split(System.label.BLN_Comma)[0],header.split(System.label.BLN_Comma)[1]);
         }
         String hCode = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
         String correlID = hCode.substring(0,4)+'-'+hCode.substring(0,4)+'-'+hCode.substring(5,8)+'-'+hCode.substring(9,12)+'-'+hCode.substring(12,16)+'-'+hCode.substring(16,20);
        headerMap.put(System.label.BLN_XCORRELATIONID,correlID);
        HttpResponse response = BLN_HttpCalloutUtility.makeCallout(calloutData.BLN_DestinationSystem__c,calloutData.BLN_NamedCredential__c+calloutData.BLN_CalloutURL__c,calloutData.BLN_Method__c,headerMap,'',requestBody,Integer.valueOf(calloutData.BLN_APITimeout__c));

        if(response.getStatusCode() == 201){
            responseBody = response.getBody();
        }
        
    }catch(Exception e){
        BLN_ExceptionLogger.captureException(e);

    }
} 
}