/** @description :  This apex class is used to handle Payment related functionalities.
*   @Story :        FOUK-10266
*   @author:        binayak.debnath@pwc.com
*   @CreatedDate:   07-10-2024
*/

global with sharing class LAD_PaymentHandler {

    public static String challengeUrl { get; set; }
    public static String jwtToken { get; set; }
    
    //VF PAGE METHODS
    /**@MethodName :    fetchSiteUrl
    * @description :    This method when invoked by a scheduled flow runs to delete Financial Document records based on the time limit set by the user.
    * @param:           Id[] finDocIdList
    * @return:          String
    * story:            FOUK-10266
    */
    @RemoteAction
    global static string fetchSiteUrl(){
        return 'https://' + DomainCreator.getExperienceCloudSitesHostname();
    }

    /**@MethodName :    fetchAmountPayable
    * @description :    This method returns account currency.
    * @param:           String accountId
    * @return:          String
    * story:            FOUK-10266
    */
    @RemoteAction
    global static String getCurrency(String accountId){
        return LAD_checkoutPageController.returnSymbol([SELECT CurrencyIsoCode FROM Account WHERE Id = :accountId].CurrencyIsoCode);
    }

    /**@MethodName :    fetchAmountPayable
    * @description :    This method called by a VF Page returns the cummulative amount of all Financial Document records based on Ids received.
    * @param:           Id[] finDocIdList
    * @return:          String
    * story:            FOUK-10266
    */
    @RemoteAction
    global static String fetchAmountPayable(Id[] finDocIdList) {
        try {
            List<LAD_Financial_Document__c> finDocList = [  SELECT Id, LAD_Remaining_Amount__c, LAD_Type__c, CurrencyIsoCode 
                                                            FROM LAD_Financial_Document__c 
                                                            WHERE Id IN :finDocIdList];
            Double amount = 0;
            for(LAD_Financial_Document__c fin : finDocList){
                amount += Double.valueOf(fin.LAD_Remaining_Amount__c);
            }
            String returnAmount = String.valueOf(Decimal.valueOf(amount).setScale(2));
            return returnAmount;
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            return null;
        }
        
    }

    global class InputWrapper{
        public String paymentMode {get; set;}
        public String sessionId {get; set;}
        public String accountId {get; set;}
        public String[] finDocIdList {get; set;}
        public String totalAmount {get; set;}
    }
    /**@MethodName :    createPaymentRecord
    * @description :    This method creates a payment record.
    * @param:           Id[] finDocIdList
    * @return:          String
    * story:            FOUK-10266
    */
    @RemoteAction
    global static Id createPaymentRecord(InputWrapper parameters) {

        String paymentMode = parameters.paymentMode;
        String accountId = parameters.accountId;
        String sessionId;
        String totalAmount = parameters.totalAmount;
        Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        Case caseRecord = [SELECT Id, BLN_OutstandingBalance__c FROM Case WHERE Id = '500Fg00000DpoPtIAJ' LIMIT 1];  
        
        if (parameters.sessionId != null && parameters.sessionId.length() > 200) {
            sessionId = parameters.sessionId.substring(0, 200);
        }

        if(paymentMode == 'invoice'){
            totalAmount = fetchAmountPayable(parameters.finDocIdList);
        }

        if (caseRecord != null) {

            Id paymentrecordtypeid = Schema.SObjectType.BLN_Payment__c.getRecordTypeInfosByName().get('Payments').getRecordTypeId();
            BLN_Payment__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable();
            BLN_Payment__c newPayment = new BLN_Payment__c();
            newPayment.BLN_PaymentAmountTaken__c = Decimal.valueOf(totalAmount);
            newPayment.BLN_Case__c = caseRecord.Id;
            newPayment.BLN_InitiatedBy__c = 'Portal';
            newPayment.BLN_InitiatedDateTime__c = Datetime.now();
            newPayment.BLN_PaymentStatus__c = 'Initiated';
            newPayment.BLN_Status__c = 'Initiated';
            newPayment.BLN_PaymentType__c = 'Online Payment';
            newPayment.BLN_PmtGatewayProvider__c = 'WorldPay';
            //BLN_Reason__c = 'Scratched Glass',
            newPayment.BLN_SessionId__c = sessionId;
            newPayment.RecordTypeId = paymentrecordtypeid;
            newPayment.CurrencyIsoCode = [SELECT CurrencyIsoCode FROM Account WHERE Id = :accountId LIMIT 1].CurrencyIsoCode;
            insert newPayment;            
            //outstandingbalance = caseRecord.BLN_OutstandingBalance__c; 
            return newPayment.Id;
            //return 'newPayment';
        }
        return null;
    }     


    @RemoteAction
    public static Map<String,String> generateToken(String sessionid,Id paymentid,String fullname){
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
        BLN_Payment__c newPayment = [SELECT id, BLN_PaymentAmountTaken__c FROM BLN_Payment__c WHERE id =: paymentid LIMIT 1];
        headers.put('Authorization','Basic ZjljZ2V4MTJqMmhvaDJ4MDowODBlOWo0bzBxbjZ5emVkaWVvcW8wamYwa2ZicHk5YTdyZ3BlNWJqdTZqdWkwY3huZHFnYmtxd3JsbjljdDdi');
        headers.put('Content-Type','application/vnd.worldpay.verified-tokens-v3.hal+json');
        headers.put('Accept','application/vnd.worldpay.verified-tokens-v3.hal+json');
        String body = '{ "description": "Token-Description", "paymentInstrument": { "type": "card/checkout", "cardHolderName": "' + fullname + '", "sessionHref": "' + sessionid + '"}, "merchant": { "entity": "default" }, "verificationCurrency": "GBP" }}';
        //System.debug('Body==>'+body);
        HttpResponse response = makeCallout(  'Worldpay', 'callout:WorldPayCredential/verifiedTokens/oneTime',
                                                                            'POST', headers, paymentid, body, sessiontimeout);
        String responsecode = String.valueOf(response.getStatusCode());

        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        // Accessing values
        Map<String, Object> embeddedMap = (Map<String, Object>) jsonMap.get('_embedded');
        Map<String, Object> verificationMap = (Map<String, Object>) embeddedMap.get('verification');
        outcome = (String) verificationMap.get('outcome');
        returnmap.put('outcome', outcome);
        code = (String) verificationMap.get('code');
        // system.debug('Code in controller---->'+code);
        returnmap.put('code', code);
        description = (String) verificationMap.get('description');
        returnmap.put('description', description);

        Map<String, Object> tokenMap = (Map<String, Object>) embeddedMap.get('token');
        Map<String, Object> tokenPaymentInstrumentMap = (Map<String, Object>) tokenMap.get('tokenPaymentInstrument');
        Map<String, Object> paymentInstrumentMap = (Map<String, Object>) tokenMap.get('paymentInstrument');
        token = (String) tokenPaymentInstrumentMap.get('href');
        bin = (String) paymentInstrumentMap.get('bin');
        String cardnumber = (String) paymentInstrumentMap.get('cardNumber');

        if(cardnumber != null && lastfourdigits != '' && bin != ''){
            lastfourdigits = cardnumber.right(4);
            paymentidtoken = bin + '******' + lastfourdigits;
        }

        if(responsecode == '201' || responsecode == '200' || responsecode == '409'){
           if(outcome == 'verified'){
            //saveToken(paymentid,token);
                //call authorize a payment API.
                returnmap = authorizeAPayment(paymentid,token,100,paymentidtoken);
                saveToken(paymentid, token, paymentidtoken);
                return returnmap;
            }
            else{
                saveToken(paymentid, token, paymentidtoken);
                return returnmap;
            }
        }
        else{
            if(outcome=='not verified' && code =='65'){
            //3DS flow
                returnmap = performCallout(paymentid,Integer.valueOf(newPayment.BLN_PaymentAmountTaken__c),token);
                if(returnmap.get('outcome')=='challenged'){
                    challengeurl = returnmap.get('url');
                    jwttoken = returnmap.get('jwt');    
                    
                }
                else if(returnmap.get('outcome')=='authenticationFailed' || returnmap.get('outcome')=='unavailable'){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Payment could not be completed at this moment, please try later'));
                }
                System.debug(token+'Enter Token after 3DS'+paymentidtoken);
                saveToken(paymentid, token, paymentidtoken);
                return returnmap;
            } 
                return returnmap;
        }
    }

    public static void saveToken(Id paymentid,String token,String paymentidtoken){
        //System.debug('paymentidtoken=>'+paymentidtoken);
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
          System.debug('Body=>'+requestBody);
        // Convert request body to JSON string
        String requestBodyJson = JSON.serialize(requestBody);
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
        
        // Parse response
        Integer statusCode = response.getStatusCode();
        if (statusCode == 201) {
            // If status code is 201, return it
            returnmap.put('code', String.valueOf(statusCode));
            //get the payment reference for refund.
            Map<String, Object> jsonmap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object> linksmap = (Map<String, Object>)jsonMap.get('_links');
            Map<String, Object> refundlinkmap = (Map<String, Object>)linksMap.get('cardPayments:refund');
            refundlink = (String)refundlinkmap.get('href');
            String[] linkarray = refundlink.split('full/');
            updateLinkData(paymentid,linkarray[1]);
            //System.debug(linkarray[1]);
             System.debug('response=>'+response.getBody());
            updateStatus(paymentid,'Success');
            //System.debug('Reach Here auth');
            //saveToken(paymentid, token,paymentidtoken);
            return returnmap;
        } 
        else {
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

        }
        else{            
            response.setStatus(System.label.BLN_IncorrectCalloutParams);
        }
        return response;
    }

    public static Map<String,String> performCallout(String paymentId,Decimal amount,String token) {
        // Define the endpoint URL
        //String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
        //System.debug('userAgent==>'+userAgent);
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
                'preference' => 'noPreference',
                'returnUrl' => Site.getBaseUrl()+'/invoice'
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
       
        // Check the response
        if (response.getStatusCode() == 200) {
            // Successful callout
            String responseBody = response.getBody();
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
            String responseBody = response.getBody();
            returnmap.put('outcome', outcome);
            returnmap.put('code', String.valueOf(response.getStatusCode()));
            /*returnmap.put('challengereference', challengereference);
            returnmap.put('url', url);
            returnmap.put('jwt', jwt);
            returnmap.put('payload', payload);*/
        }
       
        return returnmap;
    }
}