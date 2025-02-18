/*****************************************
ClassName : BLN_InitiateAutomPayment
Description :  FOUK-7125, do the Automated Payments callout after creating Refund Record
CreatedDate: 01-04-2024
Author: Ayush Kumar Singh (PwC India)
****************************************/
public class BLN_InitiateAutomPayment implements Queueable{
    public String paymentRecordId ; 
    public BLN_InitiateAutomPayment(String  paymentRecordId){
        this.paymentRecordId = paymentRecordId ;
    }
    public void execute(QueueableContext context) {
        paymentAutomatedInit(paymentRecordId);
    }
    
    /*****************************************
    MethodName : paymentAutomatedInit
    Description : This method will be callout will the LWC bln_PaymentScreenCmp
    Output Parameter : String
    CreatedDate: 01-04-2024
    CreatedBy : Ayush Kumar Singh (PwC India)
    Change log :
    ****************************************/
    @Future(callout=true)
    @AuraEnabled
    public static void paymentAutomatedInit(String  paymentRecordId){
        String returnString = '';
        HttpResponse response = new HttpResponse();
        Map<String,String> headerMap = new Map<String,String>();
        String endPoint='';
        String payload = '';
        BLN_APICalloutMapper__mdt apiCalloutmapperRec = BLN_APICalloutMapper__mdt.getInstance(System.Label.BLN_AutomPmtAPICallName);
        try{
            endPoint = apiCalloutmapperRec.BLN_NamedCredential__c + apiCalloutmapperRec.BLN_CalloutURL__c;
            List<BLN_Payment__c> paymentRecCreated  = [SELECT Id, Name, BLN_CR__c FROM BLN_Payment__c WHERE Id=:paymentRecordId];
            if(!paymentRecCreated.isEmpty()){
                payload = makePayload(paymentRecCreated[0], apiCalloutmapperRec);
            }
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken().accessToken);
            for(String str : apiCalloutmapperRec.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
            }
            response = BLN_HttpCalloutUtility.makeCallout(System.label.BLN_TargetSystemMulesoft, endPoint, apiCalloutmapperRec.BLN_Method__c, headerMap,  '', payload);
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
    CreatedDate: 01-04-2024
    CreatedBy : Ayush Kumar Singh (PwC India)
    Change log :
    ****************************************/
    private static String makePayload(BLN_Payment__c paymentRecord, BLN_APICalloutMapper__mdt apiCalloutmapperRec){
        User currentUser = [SELECT Id,Name, Username, Extension FROM User WHERE Id=:UserInfo.getUserId()];
        PayloadWrapper payload = new PayloadWrapper();
        payload.from2 = currentUser.Extension!=null ? currentUser.Extension : '';
        payload.to = System.Label.BLN_IVRTransferNumber;
        payload.videoCall = 0;
        payload.uui = paymentRecord.BLN_CR__c!=null ? paymentRecord.BLN_CR__c : '';
        return JSON.serializePretty(payload).replaceAll('from2', 'from');
    }
    public class PayloadWrapper{      
        @AuraEnabled
        public String from2{get;set;}	// it needs to be replaced by "from" when passed as payload
        @AuraEnabled
        public String to{get;set;}
        @AuraEnabled
        public Integer videoCall{get;set;}
        @AuraEnabled
        public String uui{get;set;}        
    }
}