/** @description : This class is used to construct payload based on mappings.
*   @Story : FOUK-867
*   @author: Shubhangi Patil (PwC)
*   @CreatedDate: 24/11/2023
*/
public class BLN_APICalloutPublisherTriggerHandler {
    public static String countryCode ='';
    public static String instanceUrl = System.label.BLN_DestinationType;
    public static String secondsGap ='';


/*  *@description: This method is used to pass the payload to callout.
    *@return : void
*/
    @InvocableMethod
    public static void syncMotoristDatawithMDM(List<BLN_APICalloutPublisher__e> newAccountRecords) {
        Id accountId;
        String eventType ='';
        Account acc;
        Map<String, Object> currentData = new Map<String, Object>();
        Map<String, Object> data = new Map<String, Object>();
        Map<String, Object> payload = new Map<String, Object>();
        try{
            for(BLN_APICalloutPublisher__e events: newAccountRecords){
                accountId= events.BLN_RecordId__c;
                eventType= getEventType(events);
                acc= BLN_SCUtility.getMotoristDataforMDMSync(accountId);
                if(acc!=null){
                    currentData.put(System.label.BLN_homeState, acc.PersonMailingStreet);
                    currentData.put(System.label.BLN_homePostalCode, acc.PersonMailingPostalCode);
                    currentData.put(System.label.BLN_homeState, acc.PersonMailingState);
                    currentData.put(System.label.BLN_homeCountryValue, acc.PersonMailingCountry);
                    currentData.put(System.label.BLN_homeTownValue, acc.PersonMailingCity);
                    currentData.put(System.label.BLN_homePhone, acc.PersonHomePhone);
                    currentData.put(System.label.BLN_otherPhone, acc.PersonOtherPhone);
                    currentData.put(System.label.BLN_MobilePhoneLabel, acc.PersonMobilePhone);
                    currentData.put(System.label.BLN_preferredContactMethodLabel, acc.BLN_PreferredContactMethod__c);
                    currentData.put(System.label.BLN_primaryContactNumber, acc.BLN_PrimaryContactNumber__c);
                    currentData.put(System.label.BLN_title, acc.PersonTitle);
                    currentData.put(System.label.BLN_FName, acc.FirstName);
                    currentData.put(System.label.BLN_LName, acc.LastName);
                    currentData.put(System.label.BLN_primaryEmail, acc.PersonEmail);
                    data.put(System.label.BLN_current, currentData);
                    payload.put(System.label.BLN_entityName, acc.Name);
                    payload.put(System.label.BLN_entityID, accountId);
                    payload.put(System.label.BLN_eventType, eventType);
                    payload.put(System.label.BLN_sourceSystem,System.label.BLN_SFDCLabel);
                    payload.put(System.label.BLN_timestamp, DateTime.now().formatGMT(System.label.BLN_timestampvalue));
                    payload.put(System.label.BLN_initialisedSystem,System.label.BLN_SFDCLabel);
                    payload.put(System.label.BLN_data, data);
                    String jsonData = JSON.serialize(payload);
                    
                    makeCallOut(jsonData,accountId);
                }		            
            }
        }catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
        }
    }

/*  *@description: This method is used to get event type.
    *@return : string
*/
    public static string getEventType(BLN_APICalloutPublisher__e event){
        if(event.BLN_DMLEventType__c==System.label.BLN_Create){
            return System.label.BLN_Create;
        }else if(event.BLN_DMLEventType__c==System.label.BLN_Update){
            return System.label.BLN_Update;
            
        }else{
            return null;
        }
    }
    
/*  *@description: This method is used to make callout and return type is string.
    *@return : string
*/
    public static String makeCallOut(String jsonBody, ID accountId) {
       BLN_HTTPCallOutAccessToken.WrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();
        String correlationId = BLN_SCUtility.generateCorrelationID();
        Decimal rounded;
        String secondsGap ='';
        String auth ='';
        String responseBody = '';
        try{
            String endpoint  = System.label.BLN_CreditsafeRequestEndpoint+System.label.BLN_MdmPath;
            Map<String,String> headerMap = new Map<String,String>();
            
            for(String str : System.label.BLN_CalloutPublisherHeader.split(System.label.BLN_Semicolon)){
				headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
			}
            headerMap.put(System.label.BLN_HttpAuth,System.label.BLN_Bearer+' '+wrapperToken.accessToken);
            headerMap.put(System.label.BLN_APICorrectionLabel, correlationId);
            headerMap.put(System.label.BLN_DestinationLabel, instanceUrl);
            headerMap.put(System.label.BLN_JMSXGroupID, accountId);
            

            HttpResponse response = BLN_HttpCalloutUtility.makeCallout(System.label.BLN_TargetSystemMulesoft,endpoint,System.label.BLN_HttpMethodPost,headerMap,accountId,jsonBody);

                if(response.getStatusCode() == 201 || response.getStatusCode() == 200){
                    responseBody = response.getBody();
               }
            return responseBody;
            
        }catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            return responseBody;
        }
    }

}