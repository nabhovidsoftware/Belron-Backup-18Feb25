/** @description : This class is used for 3DS callout
*   @author: Sourabh Bhattacharjee
*   @Story: FOUK-10605
*   @Created Date: 06/06/2024
*/
public without sharing class BLN_AuthenticationRequest {
    public static Map<String,String> performCallout(String paymentId,Decimal amount,String token,String said,String pref) {
        // Define the endpoint URL
       // System.debug(paymentId+'PARAM 6--'+amount+token+said+pref);
       // String endpoint = 'https://try.access.worldpay.com/verifications/customers/3ds/authentication';
        Map<String,String> returnmap = new Map<String,String>();
        returnmap.put('method', 'authentication');
        // Define the request body
         Map<String, Object> requestBody = new Map<String, Object>{
            'transactionReference' => 'Portal_'+paymentid,
            'merchant' => new Map<String, Object>{ 
                'entity' => 'default'
            },
            'instruction' => new Map<String, Object>{
                'paymentInstrument' => new Map<String, Object>{
                    'type' => 'card/tokenized',
                    'href' => token
                },
                'value' => new Map<String, Object>{
                    'currency' => 'GBP',
                    'amount' => amount
                }
            },
            'deviceData' => new Map<String, Object>{
                'acceptHeader' => 'text/html',
                'userAgentHeader' => 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0)'
            },
            'challenge' => new Map<String, Object>{
                'windowSize' => '600x400',
                'preference' => pref,
                //'preference' => 'noPreference',
                'returnUrl' => Site.getBaseUrl()+'/apex/BLN_Worldpay_final?challenge=complete&paymentid='+paymentId +'&said='+said
            } 
        };
       
        // Convert request body to JSON string
        String requestBodyJson = JSON.serialize(requestBody);
        // Make HTTP callout
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:WorldPayCredential/verifications/customers/3ds/authentication');
        request.setMethod('POST');
        //request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBodyJson);
        
        Map<String,string> headers = new Map<String,String>();
        headers.put('Authorization','Basic ZjljZ2V4MTJqMmhvaDJ4MDowODBlOWo0bzBxbjZ5emVkaWVvcW8wamYwa2ZicHk5YTdyZ3BlNWJqdTZqdWkwY3huZHFnYmtxd3JsbjljdDdi');
        headers.put('Content-Type','application/vnd.worldpay.verifications.customers-v3.hal+json');
        headers.put('Accept','application/vnd.worldpay.verifications.customers-v3.hal+json');
        
        for (String key : headers.keySet()) {
            request.setHeader(key, headers.get(key));
        }
        // Send the request
        Http http = new Http();
        HttpResponse response = http.send(request);
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        String outcome = (String)jsonMap.get('outcome');
        Map<String, Object> challengemap = (Map<String, Object>)jsonMap.get('challenge');
        String challengereference = (String)challengemap.get('reference');
        String url = (String)challengemap.get('url');
        String jwt = (String)challengemap.get('jwt');
        String payload = (String)challengemap.get('payload');
        BLN_IntegrationLogger__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<BLN_IntegrationLogger__c> intLogList = new List<BLN_IntegrationLogger__c>();
                BLN_IntegrationLogger__c integrat = new BLN_IntegrationLogger__c();
                integrat.BLN_RequestBody__c = request.getBody();
                integrat.BLN_RequestEndPoint__c = request.getEndpoint();
                integrat.BLN_RequestIssuedBy__c = UserInfo.getUserId();
                integrat.BLN_RequestMethod__c = request.getMethod();
                integrat.BLN_RequestSent__c = System.today();
                integrat.BLN_ResponseBody__c = response.getBody();
                integrat.BLN_ResponseReceived__c = System.today();
                integrat.BLN_ResponseStatus__c = response.getStatus();
                integrat.BLN_ResponseStatusCode__c = ''+response.getStatusCode();
                integrat.BLN_TargetSystem__c = System.label.BLN_TargetSystemMulesoft;
        		integrat.BLN_RecordId__c=paymentId;
                intLogList.add(integrat);
                BLN_IntegrationLogger.logRequest(intLogList);
        // Check the response
        if (response.getStatusCode() == 200) {
            // Successful callout
           // String responseBody = response.getBody();
            returnmap.put('outcome', outcome);
            returnmap.put('challengereference', challengereference);
            returnmap.put('url', url);
            returnmap.put('jwt', jwt);
            returnmap.put('payload', payload);
            if(outcome =='Authenticated'){
                returnmap = BLN_PaymentWorldPayController.authorizeAPayment(paymentid,token,amount,'');
                return returnmap;
            }
            if(outcome == 'Challenged'){
                returnmap.put('challengereference', challengereference);
                returnmap.put('url', url);
                returnmap.put('jwt', jwt);
                returnmap.put('payload', payload);
                BLN_Payment__c pay = new BLN_Payment__c(Id = paymentId);
                pay.BLN_challengereference__c = challengereference;
                BLN_Payment__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable();
                update pay;
            }
        } else {
            // Error handling
          //  String responseBody = response.getBody();
            returnmap.put('outcome', outcome);
            /*returnmap.put('challengereference', challengereference);
            returnmap.put('url', url);
            returnmap.put('jwt', jwt);
            returnmap.put('payload', payload);*/
        }
        return returnmap;
    }
}