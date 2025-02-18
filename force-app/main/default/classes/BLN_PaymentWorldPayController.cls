/**
 * @description       :
 * @author            : Sourabh Bhattacharjee
 * @group             :
 * @last modified on  : 10-18-2024
 * @last modified by  : Sourabh Bhattacharjee
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   10-18-2024   Sourabh Bhattacharjee   Initial Version
**/
public without sharing class BLN_PaymentWorldPayController {

    public static Decimal outstandingbalance;
    public String challenge{get;set;}
    public static String jwt {get;set;}
    public static String url {get;set;}
    public static String bin {get;set;}
    public static Boolean showcheckout {get;set;}
    public static Boolean showDDC {get;set;}
    public static Boolean token {get;set;}
    public static Boolean paymentid {get;set;}
    public static String challengeUrl { get; set; }
    public static String jwtToken { get; set; }
    public static Boolean showCode { get ; set; }
    
    public BLN_PaymentWorldPayController(){
        showcheckout = true;        
    } 
    
    @RemoteAction
     public static String showoutstandingBalance(Id caseid) {
        Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        Case caseRecord = [SELECT Id, BLN_OutstandingBalance__c FROM Case WHERE Id =: caseid LIMIT 1];
         String outstandingbalance = String.valueOf(caseRecord.BLN_OutstandingBalance__c);
        return outstandingbalance;
    }
    
    @RemoteAction
    public static Map<String,String> generateToken(String sessionid,Id paymentid,String fullname,String said){
        //generate a token
        Integer sessiontimeout = 5000;
        String outcome;
        String code;
        String description;
        String token;
        String bin;
        String lastfourdigits;
        String paymentidtoken;
        Map<String,String> returnmap = new Map<String,String>();
        returnmap.put('method', 'token');
        Map<String,string> headers = new Map<String,String>();
        BLN_Payment__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        BLN_Payment__c newPayment = [Select id,BLN_PaymentAmountTaken__c FROM BLN_Payment__c WHERE id =: paymentid LIMIT 1];
        headers.put('Authorization','Basic ZjljZ2V4MTJqMmhvaDJ4MDowODBlOWo0bzBxbjZ5emVkaWVvcW8wamYwa2ZicHk5YTdyZ3BlNWJqdTZqdWkwY3huZHFnYmtxd3JsbjljdDdi');
        headers.put('Content-Type','application/vnd.worldpay.verified-tokens-v3.hal+json');
        headers.put('Accept','application/vnd.worldpay.verified-tokens-v3.hal+json');
        String body = '{ "description": "Token-Description", "paymentInstrument": { "type": "card/checkout", "cardHolderName": "'+fullname+'", "sessionHref": "'+sessionid+'"}, "merchant": { "entity": "default" }, "verificationCurrency": "GBP" }}';
        //System.debug('Body58==>'+JSON.serializePretty(body));
        HttpResponse response = BLN_PaymentWorldPayController.makeCallout(
        'Worldpay','callout:WorldPayCredential/verifiedTokens/cardOnFile',
        'POST',headers,paymentid,body,sessiontimeout);
        //System.debug('response62---->'+response);
        String responsecode = String.valueOf(response.getStatusCode());

            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            // Accessing values
            Map<String, Object> embeddedMap = (Map<String, Object>)jsonMap.get('_embedded');
            Map<String, Object> verificationMap = (Map<String, Object>)embeddedMap.get('verification');
            outcome = (String)verificationMap.get('outcome');
            returnmap.put('outcome', outcome);
            code = (String)verificationMap.get('code');
           // System.debug('VerMap---->'+verificationMap);
           // System.debug('Code in controller---->'+code);
            returnmap.put('code', code);
            description = (String)verificationMap.get('description');
            returnmap.put('description', description);

            Map<String, Object> tokenMap = (Map<String, Object>)embeddedMap.get('token');
            //System.debug('tokenMap in controller---->'+tokenMap);
            Map<String, Object> tokenPaymentInstrumentMap = (Map<String, Object>)tokenMap.get('tokenPaymentInstrument');
           // system.debug('tokenPaymentInstrumentMap in controller---->'+tokenPaymentInstrumentMap);
            Map<String, Object> paymentInstrumentMap = (Map<String, Object>)tokenMap.get('paymentInstrument');
            //system.debug('paymentInstrumentMap in controller---->'+paymentInstrumentMap);
        token = (String)tokenPaymentInstrumentMap.get('href');
        bin = (String)paymentInstrumentMap.get('bin');
        String cardnumber = (String)paymentInstrumentMap.get('cardNumber');
            String randomString = BLN_SCUtility.generateRandomAlphabetString();
            if(cardnumber != null && lastfourdigits != '' && bin != ''){
                lastfourdigits = cardnumber.right(4);
                paymentidtoken = bin + randomString + lastfourdigits;
        }

        if(responsecode == '201' || responsecode == '200'){
           if(outcome == 'verified'){
          //  System.debug(outcome+'<--LINE 93-->'+responsecode);
            //saveToken(paymentid,token);
                //call authorize a payment API.
               // System.debug('Bal--->'+newPayment.BLN_PaymentAmountTaken__c*100);
               returnmap = authorizeAPayment(paymentid,token,newPayment.BLN_PaymentAmountTaken__c * 100,paymentidtoken);
                saveToken(paymentid, token,paymentidtoken);
               // System.debug('Line 96--->'+returnmap);
                return returnmap;
            }
            else{
                saveToken(paymentid, token,paymentidtoken);
               // System.debug('Line 100--->'+returnmap);
                return returnmap;
            }
    }
    else{
         //	System.debug(code+ '3DS process--->'+outcome + '=='+responsecode);
            if((outcome=='not verified' && code =='65') ||(outcome=='verified' && responsecode =='409')||(outcome=='not verified' && responsecode =='206') ){
            //3DS flow
           //    System.debug('In 3DS flow--->');
               String pref;
                if((outcome=='not verified' && code =='65') ){
                    pref ='challengeMandated';
                }else{
                    pref ='noPreference';
                }
               returnmap = BLN_AuthenticationRequest.performCallout(paymentid,Integer.valueOf(newPayment.BLN_PaymentAmountTaken__c * 100),token,said,pref);
              // System.debug('3DS map--->'+returnmap);
                if(returnmap.get('outcome')=='challenged'){
                challengeurl = returnmap.get('url');
                jwttoken = returnmap.get('jwt');
            }
            else if(returnmap.get('outcome')=='authenticationFailed' || returnmap.get('outcome')=='unavailable'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Payment could not be completed at this moment, please try later'));
            }
               // System.debug(token+'Enter Token after 3DS'+paymentidtoken);
                saveToken(paymentid, token,paymentidtoken);
               // System.debug('Line 96--->'+returnmap);
            return returnmap;
        } 
                return returnmap;
            }
    }
    
    @RemoteAction
    public static Id createPaymentRecord(string sessionId, Id caseid ) {
        Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        Case caseRecord = [SELECT Id, BLN_OutstandingBalance__c FROM Case WHERE Id =: caseid LIMIT 1];  
        
        if (sessionId != null && sessionId.length() > 200) {
            sessionId = sessionId.substring(0, 200);
        }if (caseRecord != null) {

            Id paymentrecordtypeid = Schema.SObjectType.BLN_Payment__c.getRecordTypeInfosByName().get('Payments').getRecordTypeId();
            BLN_Payment__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable();
            BLN_Payment__c newPayment = new BLN_Payment__c(
                BLN_PaymentAmountTaken__c = caseRecord.BLN_OutstandingBalance__c,
                BLN_Case__c = caseRecord.Id,
                BLN_InitiatedBy__c = System.label.BLN_PortalValue,
                BLN_InitiatedDateTime__c = Datetime.now(),
                BLN_PaymentStatus__c = 'Initiated',
                BLN_Status__c = 'Initiated',
                BLN_PaymentType__c = System.label.BLN_Ecommerce,//Changed from Online Payment
                BLN_PmtGatewayProvider__c = System.label.BLN_Worldpay,
                //BLN_Reason__c = 'Scratched Glass',
                BLN_SessionId__c = sessionId,
                BLN_CardType__c='Ecomms Card',
                RecordTypeId = paymentrecordtypeid
            ); 
            insert newPayment;            
            outstandingbalance = caseRecord.BLN_OutstandingBalance__c; 
            return newPayment.Id;
            //return 'newPayment';
        }
        return null;
    }     
    
    @RemoteAction
    public static String getCurrentUserAccountName() {
        Id userId = UserInfo.getUserId();
        User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        User currentUser = [SELECT contactId, Account.Name FROM User WHERE Id = :userId];          
        if(currentUser != null) {            
            return currentUser.Account != null ? currentUser.Account.Name : null;
        } else {
            return null;
        }      
    }    
    
    @RemoteAction
    public static String getErrorMessage(String code){
       if (String.isBlank(code)) {
        return null;
    }
        BLN_WorldPay_Error_Code__mdt  ec = BLN_WorldPay_Error_Code__mdt.getInstance('X'+code);
        return ec.BLN_Customer_Message__c;
    }
    
    public static void saveToken(Id paymentid,String token,String paymentidtoken){
       // System.debug(paymentid+'-'+token+'paymentidtoken=>'+paymentidtoken);
        BLN_Payment__c payment = new BLN_Payment__c(Id = paymentid);
        payment.BLN_WorldPay_Token__c = token;
        if(paymentidtoken != null){
            payment.BLN_PaymentId__c = paymentidtoken;
            payment.BLN_CR__c = 'Portal_'+ paymentid;
        }
        
        if(Schema.sObjectType.BLN_Payment__c.fields.BLN_WorldPay_Token__c.isUpdateable() && Schema.sObjectType.BLN_Payment__c.fields.BLN_PaymentId__c.isUpdateable()){
            update payment;
        }        
    }
    public static Map<String,String> authorizeAPayment(String paymentid,String token,Decimal amount,String paymentidtoken){
       // System.debug(token+'Amt---'+amount+'=='+paymentidtoken);
        Map<String,String> returnmap = new Map<String,String>();
        returnmap.put('method', 'authorize');
        String refusalCode;
        String refusalDescription;
        String outcome;
        Integer sessiontimeout = 5000;
        String refundlink;
        //String paymentref;
        // Create request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'transactionReference' => 'Portal_'+paymentid,
            'merchant' => new Map<String, Object>{
                'entity' => 'default'
            },
            'instruction' => new Map<String, Object>{
                'requestAutoSettlement' => new Map<String, Object>{
                    'enabled' => true
                },
                'narrative' => new Map<String, Object>{
                    'line1' => 'default'
                },
                'value' => new Map<String, Object>{
                    'currency' => 'GBP',
                    'amount' => amount
                },
                'paymentInstrument' => new Map<String, Object>{
                    'type' => 'card/token',
                    'href' => token
                }
            },
            'channel' => 'ecom'
        };
        //  System.debug('Body 232=>'+requestBody);
        // Convert request body to JSON string
        String requestBodyJson = JSON.serialize(requestBody);
       //  System.debug('requestBodyJson 235=>'+requestBodyJson);
        // Make HTTP callout
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://try.access.worldpay.com/cardPayments/customerInitiatedTransactions');
        request.setMethod('POST');
        Map<String,string> headers = new Map<String,String>();
        headers.put('Authorization','Basic ZjljZ2V4MTJqMmhvaDJ4MDowODBlOWo0bzBxbjZ5emVkaWVvcW8wamYwa2ZicHk5YTdyZ3BlNWJqdTZqdWkwY3huZHFnYmtxd3JsbjljdDdi');
        headers.put('Content-Type','application/vnd.worldpay.payments-v7+json');
        headers.put('Accept','application/vnd.worldpay.payments-v7+json');
        HttpResponse response = BLN_PaymentWorldPayController.makeCallout(
            'Worldpay','callout:WorldPayCredential/cardPayments/customerInitiatedTransactions',
            'POST',headers,paymentid,requestBodyJson,sessiontimeout);
       //  System.debug('RESPONSE 249--->'+response);
        /* List<BLN_IntegrationLogger__c> intLogList = new List<BLN_IntegrationLogger__c>();
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
                intLogList.add(integrat);

                BLN_IntegrationLogger.logRequest(intLogList);*/
        // Parse response
        Integer statusCode = response.getStatusCode();
 if (statusCode == 201) {
            // If status code is 201, return it
            returnmap.put('code', String.valueOf(statusCode));
            //get the payment reference for refund.
            Map<String, Object> jsonmap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
           //   System.debug('jsonmap 269'+jsonmap);
            Map<String, Object> linksmap = (Map<String, Object>)jsonMap.get('_links');
           //  System.debug('linksmap 271'+linksmap);
            Map<String, Object> refundlinkmap = (Map<String, Object>)linksMap.get('cardPayments:refund');
            refundlink = (String)refundlinkmap.get('href');
            String[] linkarray = refundlink.split('full/');
            updateLinkData(paymentid,linkarray[1]);
            //System.debug(linkarray[1]);
           //  System.debug('response 277=>'+response.getBody());
            updateStatus(paymentid,'Success');
            //System.debug('Reach Here auth');
            //saveToken(paymentid, token,paymentidtoken);
            return returnmap;
        } else {
            // If status code is not 201, parse response body
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            refusalCode = (String) responseBody.get('refusalCode');
            refusalDescription = (String) responseBody.get('refusalDescription');
            outcome = (String) responseBody.get('outcome');
            returnmap.put('code', refusalCode);
            returnmap.put('description', refusalDescription);
            returnmap.put('outcome', outcome);
            updateStatus(paymentid,'Declined');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Payment Cannot be completed at the moment'));
            return returnmap;
        }
    }
    
    public static void updateStatus(Id paymentid,String status){
        BLN_Payment__c payment = new BLN_Payment__c(Id = paymentid);
        payment.BLN_PaymentStatus__c = status;
        payment.BLN_Status__c = status;
        payment.BLN_PaymentTime__c = System.now();
        if(Schema.sObjectType.BLN_Payment__c.fields.BLN_PaymentStatus__c.isUpdateable()){
            update payment;
        }
    }
    
    public static void updateLinkData(Id paymentid,String linkdata){
        BLN_Payment__c payment = new BLN_Payment__c(Id = paymentid);
        payment.BLN_LinkData__c  = linkdata;
        if(Schema.sObjectType.BLN_Payment__c.fields.BLN_LinkData__c.isUpdateable()){
            update payment;
        } 
    }
    
    // @params : makeCallout(String targetSystem, String apiEndPoint, String methodType, Map<String,String> headerMap, String recordId, String payloadBody, Integer timeout)
    // @description : this callout method wil be used incase the request has a timeout value
    public static HttpResponse makeCallout(String targetSystem, String apiEndPoint, String methodType, Map<String,String> headerMap, String recordId, String payloadBody,Integer timeout){                
     //  System.debug('Param 318--'+targetSystem+apiEndPoint+methodType+headerMap+recordId+payloadBody+timeout);
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
            if(payloadBody != null && payloadBody != '' && !System.label.BLN_GET.equalsIgnoreCase(methodType)){
                request.setBody(payloadBody);            
            }
            //DateTime responseTimerStart = System.now();        
            response = new Http().send(request);
            //DateTime reponseTimerStop = System.now();
               /* List<BLN_IntegrationLogger__c> intLogList = new List<BLN_IntegrationLogger__c>();
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
                intLogList.add(integrat);
                BLN_IntegrationLogger.logRequest(intLogList);*/

        }
        else{            
            response.setStatus(System.label.BLN_IncorrectCalloutParams);
        }
        return response;
    }
     @RemoteAction
    public static boolean getShowCode(string code){
        if(code == null){
            showCode = false;
        }
        else if(code == '400'){
            showCode = true;
        }
        return showCode;
    }
}