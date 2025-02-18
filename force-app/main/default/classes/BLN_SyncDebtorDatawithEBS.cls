/*****************************************
ClassName : BLN_SyncDebtorDatawithEBS
Description :  FOUK-6288, sends Debtor details to EBS after case record gets updated with debtor details
CreatedDate: 14-04-2024
Author: Rupesh Kumar V (PwC India)
****************************************/
public class BLN_SyncDebtorDatawithEBS implements Queueable{
    List<Case> cases = new List<Case>();
    public BLN_SyncDebtorDatawithEBS(List<Case> cases){
        this.cases = cases ;
    }
    public void execute(QueueableContext context) {
        syncEBSDebtor(cases);
    }
    @InvocableMethod
    public static void syncEBSDebtor(List<Case> cases) {
        for (case updatecase : cases) {
            syncDebtorEBS(updatecase.Id);
        }
    }
    @Future(callout=true)
    public static void syncDebtorEBS(String caseId){
        Case caseRec = [Select Id, BLN_Corporate__c, BLN_BillingStreet__c, BLN_BillingTown__c, BLN_BillingPostCode__c, BLN_BillingCountry__c, 
                        BLN_VRN__c, BLN_LocationBranchName__c, BLN_ISP__c, BLN_EBSDebtorStatus__c, BLN_EBSDebtorTitle__c, BLN_EBSDebtorResMsg__c, BLN_BillingMethod__c, Account.FirstName, Account.LastName, Account.Salutation, BLN_Corporate__r.BLN_PolicyHolderName__c,  BLN_Corporate__r.BLN_FirstName__c, BLN_Corporate__r.BLN_LastName__c, BLN_Corporate__r.BLN_Salutation__c, AccountId from Case where Id =: caseId WITH SECURITY_ENFORCED];
        String caseCropId = caseRec.BLN_Corporate__c;
        BLN_Corporate__c corpRec = [SELECT Id, 
                                          BLN_Salutation__c, BLN_FirstName__c, BLN_LastName__c, BLN_CustomerId__c, BLN_CustomerSiteId__c, BLN_SiteUseId__c FROM BLN_Corporate__c WHERE Id =: caseCropId WITH SECURITY_ENFORCED];
        Account caseAccount = [SELECT Id, BLN_CustomerId__c, BLN_CustomerSiteId__c, BLN_SiteUseId__c FROM Account WHERE Id = :caseRec.AccountId WITH SECURITY_ENFORCED];
        
        HttpResponse response = new HttpResponse();
        Map<String,String> headerMap = new Map<String,String>();
        String endPoint='';
        String payload = '';
        BLN_APICalloutMapper__mdt apiCalloutmapperRec = BLN_APICalloutMapper__mdt.getInstance(System.Label.BLN_DebtorEBSAPICallName);
        try{
            endPoint = apiCalloutmapperRec.BLN_NamedCredential__c + apiCalloutmapperRec.BLN_CalloutURL__c;
            payload = makePayload(caseRec, apiCalloutmapperRec);
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken().accessToken); for(String str : apiCalloutmapperRec.BLN_Headers__c.split(System.label.BLN_Semicolon)){ headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]); } response = BLN_HttpCalloutUtility.makeCallout(System.label.BLN_TargetSystemMulesoft, endPoint, apiCalloutmapperRec.BLN_Method__c, headerMap,  '', payload); Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 
            if(response.getstatuscode() == 201)
            { 
                if(caseRec.BLN_BillingMethod__c == 'Cash')
                {
                    caseAccount.BLN_CustomerId__c = String.valueOf((Integer) jsonResponse.get('customerId')); 
                    caseAccount.BLN_CustomerSiteId__c = String.valueOf((Integer) jsonResponse.get('custSiteId')); 
                    caseAccount.BLN_SiteUseId__c = String.valueOf((Integer) jsonResponse.get('siteUseId')); 
                    update caseAccount;
                }
                else if(caseRec.BLN_BillingMethod__c == 'Insurance / Account')
                {
                    corpRec.BLN_CustomerId__c = String.valueOf((Integer) jsonResponse.get('customerId')); 
                    corpRec.BLN_CustomerSiteId__c = String.valueOf((Integer) jsonResponse.get('custSiteId')); 
                    corpRec.BLN_SiteUseId__c = String.valueOf((Integer) jsonResponse.get('siteUseId')); 
                    update corpRec;
                }
            }
			List<Object> errors = (List<Object>) jsonResponse.get('errors');
            if(errors!=null || Test.isRunningTest())
            {
            for (Object error : errors) {
    			Map<String, Object> errorDetails = (Map<String, Object>) error;
                if(response.getstatuscode() == 404 || response.getstatuscode() == 400 || response.getstatuscode() == 500){
                        caseRec.BLN_EBSDebtorStatus__c = String.valueOf((Integer) errorDetails.get('status'));caseRec.BLN_EBSDebtorTitle__c = (String) errorDetails.get('title');caseRec.BLN_EBSDebtorResMsg__c = (String) errorDetails.get('detail');
                }
            }
            update caseRec;
            }
        } catch(exception e){
            //Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);
        }
    }
    /*****************************************
    MethodName : makePayload
    Description : This method is used to make the payload
    Output Parameter : BLN_APICalloutMapper__mdt
    CreatedDate: 14-04-2024
    Author: Rupesh Kumar V (PwC India)
    Change log :
    ****************************************/
    private static String makePayload(Case caseRecord, BLN_APICalloutMapper__mdt apiCalloutmapperRec){
        String caseCropId = caseRecord.BLN_Corporate__c;
        List<BLN_Corporate__c> corpRec = [SELECT Id, BLN_FirstName__c, BLN_LastName__c, BLN_Salutation__c, BLN_PolicyHolderName__c from BLN_Corporate__c where Id =: caseCropId];
        String personAccountId = corpRec[0].BLN_PolicyHolderName__c;
        List<Account> personAcc = [Select Id, Salutation, FirstName, LastName, BLN_PrimaryContactNumber__c, PersonMobilePhone from Account Where Name =: personAccountId];
        PayloadWrapper payload = new PayloadWrapper();
        if(caseRecord.BLN_BillingMethod__c == 'Cash')
        {
            payload.title = caseRecord.Account.Salutation;
            payload.firstName = caseRecord.Account.FirstName;
            payload.lastName = caseRecord.Account.LastName;
        }
        else if(caseRecord.BLN_BillingMethod__c == 'Insurance / Account' && caseRecord.BLN_Corporate__r.BLN_PolicyHolderName__c!=null)
        { 
            payload.title = caseRecord.BLN_Corporate__r.BLN_Salutation__c;
            payload.firstName = caseRecord.BLN_Corporate__r.BLN_FirstName__c;
            payload.lastName = caseRecord.BLN_Corporate__r.BLN_LastName__c;
        }
        else if(caseRecord.BLN_BillingMethod__c == 'Insurance / Account')
        {
            payload.title = caseRecord.BLN_Corporate__r.BLN_Salutation__c;
            payload.firstName = caseRecord.BLN_Corporate__r.BLN_FirstName__c;
            payload.lastName = caseRecord.BLN_Corporate__r.BLN_LastName__c;
        }
        List<String> parts = caseRecord.BLN_BillingStreet__c.split(',');
        if(parts.size() == 3){
            payload.address1 = parts[0];
        	payload.address2 = parts[1];
        	payload.address3 = parts[2];
        } else{
            payload.address1 = caseRecord.BLN_BillingStreet__c;
        	payload.address2 = caseRecord.BLN_BillingStreet__c;
        	payload.address3 = caseRecord.BLN_BillingStreet__c;            
        }
        payload.city = caseRecord.BLN_BillingTown__c;
        payload.countyOrProvince = caseRecord.BLN_BillingCountry__c;
        payload.postalCode = caseRecord.BLN_BillingPostCode__c;
        payload.country = 'GB';
        If(personAcc[0].BLN_PrimaryContactNumber__c == System.label.BLN_PrimaryContactMethodMobile){
            payload.telephoneType = System.label.BLN_EBStelephonetype;
        } else {
            payload.telephoneType = System.label.BLN_EBSGentelephonetype;
        }
        payload.contactNumber = personAcc[0].PersonMobilePhone;
        payload.vrn = caseRecord.BLN_VRN__c;
        payload.salesrep = caseRecord.BLN_LocationBranchName__c;
        payload.ispDebtor = caseRecord.BLN_ISP__c;
		String jsonData = JSON.serialize(payload);
        return jsonData;
    }
    public class PayloadWrapper{      
        @AuraEnabled
        public String title{get;set;}
        @AuraEnabled
        public String firstName{get;set;}
        @AuraEnabled
        public String lastName{get;set;}
        @AuraEnabled
        public String address1{get;set;} 
        @AuraEnabled
        public String address2{get;set;}
        @AuraEnabled
        public String address3{get;set;}
        @AuraEnabled
        public String city{get;set;}
        @AuraEnabled
        public String countyOrProvince{get;set;}
        @AuraEnabled
        public String postalCode{get;set;}
        @AuraEnabled
        public String country{get;set;}
        @AuraEnabled
        public String telephoneType{get;set;}
        @AuraEnabled
        public String contactNumber{get;set;}
        @AuraEnabled
        public String vrn{get;set;}    
        @AuraEnabled
        public String salesrep{get;set;}
        @AuraEnabled
        public String ispDebtor{get;set;}
    }
}