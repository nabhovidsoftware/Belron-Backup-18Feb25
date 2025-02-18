/** @description : This Apex is called from Service Appointment and call OKTA to get Access Token of MuleSoft
*   @Story : FOUK-1175
*   @author: Shailendra Tiwari (PwC)
*   @CreatedDate: 01/12/2023
*/
public with sharing class BLN_HTTPCallOutAccessToken {
    /*  *@description: This method is used to get access token.
        *@return : Wrapper class data
    */
    public static WrapperAccessToken getAccessToken() {
        Integer sec;
        DateTime now;        
        Map<String,String> headerMap = new Map<String,String>();
        BLN_CalloutSettings__c calloutOptions = BLN_CalloutSettings__c.getInstance();

        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.OKTAIdP');
        DateTime expiresIn = (DateTime) orgPart.get('OKTATokenExpirationDateTime');
        String oktaToken = (String) orgPart.get('OKTAAccessToken');

        WrapperAccessToken token;
        if (expiresIn != null && oktaToken != null && expiresIn > Datetime.now().addSeconds(60)) {
            token = new WrapperAccessToken();
            token.accessToken = oktaToken;
        } else {
        
        BLN_APICalloutMapper__mdt calloutData = BLN_APICalloutMapper__mdt.getInstance('BLN_OktaTokenApi');
        
        if(String.isNotBlank(calloutData.BLN_Headers__c)){
            for(String header : calloutData.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                if(header.contains(System.label.BLN_Comma)){
                    headerMap.put(header.split(System.label.BLN_Comma)[0],header.split(System.label.BLN_Comma)[1]);
                }
            }
        }
        String endPoint = calloutData.BLN_NamedCredential__c + (String.isNotBlank(calloutData.BLN_CalloutURL__c) ? calloutData.BLN_CalloutURL__c : ''); 
        Boolean createIntgrLogger = false;
        
        // Send the request and get the response
        HttpResponse tokenResponse = BLN_HttpCalloutUtility.makeCallout(createIntgrLogger,calloutData.BLN_DestinationSystem__c,endPoint,calloutData.BLN_Method__c,headerMap,'','',Integer.valueOf(calloutData.BLN_APITimeout__c));
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(tokenResponse.getBody());
        
        if((tokenResponse.getstatusCode() == 200 || tokenResponse.getstatusCode() == 201) && results.containsKey('body') != null){
                token = new WrapperAccessToken();
            token.accessToken = results.containsKey('access_token') ? (String)results.get('access_token') : '';
            token.expiresIn = results.containsKey('expires_in') ? (Integer)results.get('expires_in') : 0;
            sec = token.expiresIn == 0 ? 0 : token.expiresIn - 60;            
            now = DateTime.now();
            token.expireTime = now.addSeconds(sec);
        
                if(String.isNotBlank(token.accessToken)){
                    orgPart.put('OKTAAccessToken', token.accessToken);
                    orgPart.put('OKTATokenExpirationDateTime', token.expireTime);
                }
            }
        }
        
        return token;
    }
    
    public class WrapperAccessToken{
        public String accessToken;
        public Integer expiresIn;
        public Datetime expireTime;
    }
}