/*****************************************
ClassName : BLN_PushRefundtoGateway
Description :  FOUK-6359, do the callout after creating Refund Record
CreatedDate: 28-03-2024
Author: Ayush Kumar Singh (PwC India)
****************************************/
public class BLN_PushRefundtoGateway implements Queueable{
    public String paymentRecordId ; 
    public BLN_PushRefundtoGateway(String  paymentRecordId){
        this.paymentRecordId = paymentRecordId ;
    }
    public void execute(QueueableContext context) {
        pushRefundToGateway(paymentRecordId);
    }
    
    /*****************************************
MethodName : pushRefundToGateway
Description : This method will be callout will the LWC bln_RefundScreen
Output Parameter : String
CreatedDate: 28-03-2024
CreatedBy : Ayush Kumar Singh (PwC India)
Change log :
****************************************/
    @AuraEnabled
    @Future(callout=true)
    public static void pushRefundToGateway(String  paymentRecordId){
        String returnString = '';
        HttpResponse response = new HttpResponse();
        Map<String,String> headerMap = new Map<String,String>();
        String endPoint='';
        String payload = '';
        BLN_APICalloutMapper__mdt apiCalloutmapperRec = BLN_APICalloutMapper__mdt.getInstance(System.Label.BLN_RefundAPICallName);
        try{
            endPoint =  apiCalloutmapperRec.BLN_NamedCredential__c + apiCalloutmapperRec.BLN_CalloutURL__c;
            List<BLN_Payment__c> paymentRecCreated  = [SELECT Id, Name, BLN_PaymentAmountTaken__c, BLN_RefundType__c, BLN_Currency__c, BLN_OriginalPayment__c,BLN_OriginalPayment__r.BLN_PmtGatewayProvider__c, BLN_CR__c, BLN_PmtGatewayProvider__c,BLN_OriginalPayment__r.BLN_PmtReferenceId__c,BLN_OriginalPayment__r.BLN_LinkData__c FROM BLN_Payment__c WHERE Id=:paymentRecordId];
            if(!paymentRecCreated.isEmpty()){
                payload = makePayload(paymentRecCreated[0], apiCalloutmapperRec);
            }
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken().accessToken);
            for(String str : apiCalloutmapperRec.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
            }
            response = BLN_HttpCalloutUtility.makeCallout(System.label.BLN_TargetSystemMulesoft, endPoint, System.label.BLN_HttpMethodPost, headerMap, '', payload);
            if(response.getStatusCode() == 200){
                BLN_IntegrationLoggerFuture.processIntegrationLogger(JSON.serializePretty(response));
            }
        }
        catch(exception e){
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);
        }
    }
    
    /*****************************************
MethodName : makePayload
Description : This method is used to make the payload
Output Parameter : BLN_Payment__c, BLN_APICalloutMapper__mdt
CreatedDate: 28-03-2024
CreatedBy : Ayush Kumar Singh (PwC India)
Change log :
****************************************/
    private static String makePayload(BLN_Payment__c paymentRecord, BLN_APICalloutMapper__mdt apiCalloutmapperRec){
        
        Datetime dt = System.now();
        String isoString = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        String timezoneOffset = UserInfo.getTimezone().getDisplayName();
        String offsetHours = timezoneOffset.substring(timezoneOffset.indexOf('GMT') + 3, timezoneOffset.indexOf('GMT') + 6);
        String offsetMinutes = timezoneOffset.substring(timezoneOffset.indexOf('GMT') + 7, timezoneOffset.indexOf('GMT') + 9);
        String formattedString = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + offsetHours + ':' + offsetMinutes;

        PayloadWrapper payload = new PayloadWrapper();
        payload.entityName = apiCalloutmapperRec.BLN_EntityName__c;
        payload.entityID = paymentRecord.Id;
        payload.eventType = apiCalloutmapperRec.BLN_EventType__c;
        payload.sourceSystem = apiCalloutmapperRec.BLN_SourceSystem__c;
        payload.timestamp = formattedString;//'2024-07-10T13:08:12.000353+00:00';
        payload.initialisedSystem = apiCalloutmapperRec.BLN_SourceSystem__c;
        
        Cls_data data = new Cls_data();
        Cls_current current = new Cls_current();
        Cls_refunds refunds = new Cls_refunds();
        if(paymentRecord.BLN_OriginalPayment__c!=null){
          //  refunds.paymentId = paymentRecord.BLN_OriginalPayment__r.BLN_CR__c!=null ? paymentRecord.BLN_OriginalPayment__r.BLN_CR__c : '';
            refunds.provider = paymentRecord.BLN_OriginalPayment__r.BLN_PmtGatewayProvider__c!=null ?paymentRecord.BLN_OriginalPayment__r.BLN_PmtGatewayProvider__c : '';
            if(paymentRecord.BLN_OriginalPayment__r.BLN_PmtGatewayProvider__c ==System.Label.BLN_Worldpay){
                refunds.paymentId=paymentRecord.BLN_OriginalPayment__r.BLN_LinkData__c;
            }
            
            
            else if(paymentRecord.BLN_OriginalPayment__r.BLN_PmtGatewayProvider__c == System.Label.BLN_BarclaysGatewayProvider){
                refunds.paymentId=paymentRecord.BLN_OriginalPayment__r.BLN_PmtReferenceId__c;
            }
        }
        else{
            refunds.paymentId = '';
            refunds.provider = '';
        }
        refunds.amount = paymentRecord.BLN_PaymentAmountTaken__c!=null ? String.valueOf(paymentRecord.BLN_PaymentAmountTaken__c.intValue()): '';
        refunds.refundType = paymentRecord.BLN_RefundType__c!=null ? paymentRecord.BLN_RefundType__c : '';
        refunds.currency2 = paymentRecord.BLN_Currency__c!=null ?paymentRecord.BLN_Currency__c : '';
        refunds.internalId = paymentRecord.Id;
        current.refunds = refunds;
        
        
        
        data.current = current;
        
        payload.data = data;
        return JSON.serializePretty(payload).replaceAll('currency2', 'currency');
    }
    public class PayloadWrapper{
        @AuraEnabled
        public String entityName{get;set;}
        @AuraEnabled
        public String entityID{get;set;}
        @AuraEnabled
        public String eventType{get;set;}
        @AuraEnabled
        public String sourceSystem{get;set;}
        @AuraEnabled
        public String timestamp{get;set;}
        @AuraEnabled
        public String initialisedSystem{get;set;}
        @AuraEnabled
        public Cls_data data{get;set;}
    }
    
    public class Cls_data {
        @AuraEnabled
        public Cls_current current{get;set;}
    }
    public class Cls_current {
        @AuraEnabled
        public Cls_refunds refunds{get;set;}
    }
    public class Cls_refunds {
        @AuraEnabled
        public String paymentId{get;set;}
        //@AuraEnabled
        //public String environment{get;set;}
        //@AuraEnabled
        //public String saleIdentification{get;set;}
        //@AuraEnabled
        //public String merchantId{get;set;}
        @AuraEnabled
        public String amount{get;set;}
        @AuraEnabled
        public String refundType{get;set;}
        @AuraEnabled
        public String currency2{get;set;}	// it needs to be replaced by "currency" when passed as payload
        @AuraEnabled
        public String internalId{get;set;}
        @AuraEnabled
        public String provider{get;set;}
    }
}