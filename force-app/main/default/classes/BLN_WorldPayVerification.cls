/** @description : This class is used for payment verification
*   @author: Sourabh Bhattacharjee
*   @Story: FOUK-10605
*   @Created Date: 06/06/2024
*/
public with sharing class BLN_WorldPayVerification {
    public static Map<String,String> performCallout(String paymentid){
        BLN_Payment__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        BLN_Payment__c newpayment = [SELECT Id, BLN_challengereference__c,BLN_WorldPay_Token__c,BLN_Case__c,BLN_PaymentAmountTaken__c,BLN_PaymentId__c FROM BLN_Payment__c WHERE id =:paymentid LIMIT 1];
        Map<String,String> returnmap = new Map<String,String>();
        returnmap.put('method', 'verification');
        // Define the request body
         Map<String, Object> requestBody = new Map<String, Object>{
            'transactionReference' => 'Portal_'+paymentid,
            'merchant' => new Map<String, Object>{
                'entity' => 'default'
            },
            'challenge' => new Map<String, Object>{
                'reference' => newpayment.BLN_challengereference__c
            }   
        };
       
        // Convert request body to JSON string
        String requestBodyJson = JSON.serialize(requestBody);
       //System.debug('BODY 22-->'+requestBodyJson);
        // Make HTTP callout
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:WorldPayCredential/verifications/customers/3ds/verification');
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
        System.debug('JSONMAP 44-->'+JSON.serializePretty(jsonMap));
        String outcome = (String)jsonMap.get('outcome');
        /*List<BLN_IntegrationLogger__c> intLogList = new List<BLN_IntegrationLogger__c>();
                BLN_IntegrationLogger__c integrat = new BLN_IntegrationLogger__c();
                integrat.BLN_RecordId__c=paymentid;
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
                intLogList.add(integrat);
                BLN_IntegrationLogger.logRequest(intLogList);*/
        if(outcome == 'authenticated'){
            // System.debug(newpayment.BLN_PaymentAmountTaken__c+'Param passd fr authpay verification-->'+newpayment.BLN_WorldPay_Token__c+'-'+newpayment.BLN_PaymentId__c);
            returnmap = BLN_PaymentWorldPayController.authorizeAPayment(paymentid,newpayment.BLN_WorldPay_Token__c,newPayment.BLN_PaymentAmountTaken__c*100,newPayment.BLN_PaymentId__c);
           // System.debug('returnmap in verification-->'+returnmap);
              if(returnmap.get('code')!= null && returnmap.get('code')=='201'){
                returnmap.put('code', '201');
                returnmap.put('caseid', newpayment.BLN_Case__c);
                returnmap.put('outcome',outcome);
                 //System.debug('LINE 66-->'+returnmap);
                return returnmap;
            }
        }
        else{
            returnmap.put('code', String.valueOf(response.getStatusCode()));
            returnmap.put('caseid', newpayment.BLN_Case__c);
            returnmap.put('outcome',outcome);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Payment could not be completed at this moment, please try later'));
           // System.debug('LINE 75-->'+returnmap);
            return returnmap;    
        }
        return null;
    }
}