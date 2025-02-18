/**@description : This Apex class used to send callout and mapping.
*  @author: PwC India
*  @Story: FOUK-5167
*  @CreatedDate: 24/06/2024
*/
public class BLN_QueueMDMCallout extends BLN_MDMCalloutSetup implements Queueable, Database.AllowsCallouts  {
	
    public BLN_MDMConfiguration.MDMParameters mdmParameter{get;set;}
    public String fieldsJson{get;set;}

    
/**
*@description:This is a constructor.
*@return 
*/
    public BLN_QueueMDMCallout(String fieldsJson,BLN_MDMConfiguration.MDMParameters parameters ){
       
          	this.fieldsJson=fieldsJson; 
              this.mdmParameter=parameters; 
         }

        /**
*@description:This is method used to do callout and field mapping.
*@return  void
*/
    public void execute(QueueableContext context) {
        String responseBody = '';
        try{
            Integer timeout = 30000;
            Map<String, Object> jsonMap = new Map<String, Object>();
           // String accountName = (String) fieldsMap.get('First_Name') + ' '+ (String) fieldsMap.get('Last_Name');

            jsonMap.put('timestamp', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
            jsonMap.put('sourceSystem', 'SFDC');
            jsonMap.put('initialisedSystem', 'SFDC');
            jsonMap.put('eventType', mdmParameter.eventType);
              
            jsonMap.put('entityID', mdmParameter.accountId);

            Map<String, Object> dataMap = new Map<String, Object>();
            Map<String, Object> currentMap = new Map<String, Object>();
            if(mdmParameter.streamName == System.label.BLN_SalesStream){
                jsonMap.put('entityName', mdmParameter.accountName);
                if(mdmParameter.eventType == 'Update' && mdmParameter.mdmAccountId!=null){
                    currentMap.put('mdmAccountId',mdmParameter.mdmAccountId);

                }
                else{
                    mdmParameter.eventType = 'Create';
                    jsonMap.put('eventType', mdmParameter.eventType);
                }
                dataMap.put('current', currentMap);
                jsonMap.put('data', dataMap);
            }
            else if(mdmParameter.streamName == System.label.BLN_ServiceStream){
                Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fieldsJson);
               
                String accountName = (String) fieldsMap.get('First_Name') + ' '+ (String) fieldsMap.get('Last_Name');
                jsonMap.put('entityName', accountName);
                currentMap.putAll((Map<String, Object>) JSON.deserializeUntyped(fieldsJson));
                dataMap.put('current', currentMap);
                jsonMap.put('data', dataMap);
                String personId = '';
                personId = (String)fieldsMap.get('Person_ID');
                if(personId != null && !String.isBlank(personId)){
                    jsonMap.put('eventType', 'Update');
                }
                else{
                    jsonMap.put('eventType', 'Create');
                }
            }
           

            String requestBody = JSON.serializePretty(jsonMap); //serialize(jsonMap);

            BLN_APICalloutMapper__mdt calloutData = BLN_APICalloutMapper__mdt.getInstance('BLN_MDMApiCallout');

             Map<String,String> headerMap = new Map<String,String>();
             headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
             for(String header : calloutData.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                 headerMap.put(header.split(System.label.BLN_Comma)[0],header.split(System.label.BLN_Comma)[1]);
             }
             if(mdmParameter.streamName == System.label.BLN_SalesStream){
                headerMap.put('destination',System.Label.BLN_MdmDestinationHeader);
             }
             String hCode = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
             String correlID = hCode.substring(0,4)+'-'+hCode.substring(0,4)+'-'+hCode.substring(5,8)+'-'+hCode.substring(9,12)+'-'+hCode.substring(12,16)+'-'+hCode.substring(16,20);
           headerMap.put(System.label.BLN_XCORRELATIONID,correlID);

          
           HttpResponse response = BLN_HttpCalloutUtility.makeCallout(calloutData.BLN_DestinationSystem__c,calloutData.BLN_NamedCredential__c+calloutData.BLN_CalloutURL__c,calloutData.BLN_Method__c,headerMap,mdmParameter.accountId,requestBody,timeout);

            if(response.getStatusCode() == 201){
                responseBody = response.getBody();
            }
            
        }catch(Exception e){
            BLN_ExceptionLogger.captureException(e);

        }
    } 
}