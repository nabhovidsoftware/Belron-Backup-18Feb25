/*****************************************
*ClassName : BLN_CheckCreditSafeController
*@description : FOUK-602 This controller class is used in Screen Flow .
*CreatedDate: 27-11-2023
*CreatedBy : PwC-India
****************************************/
public with sharing class BLN_CheckCreditSafeController {
    /*MethodName : checkCreditSafe
*@description : This method is used to return the response from CreditSafe API.
*@return List
*@param List
*Input Parameter : List<String> 
*Output Parameter : List<String>
*CreatedDate: 27-11-2023
*CreatedBy : Pwc-India
*Change log :
****************************************/
    
    @InvocableMethod(label='checkCreditSafe')
    public static List<String> checkCreditSafe(List<String> getAccountRecord ) {
        try { 
            HttpResponse creditSafeResponse = new HttpResponse();
            Map<String,String> headerResponseMap = new Map<String,String>();
            Integer timeout = 30000;
            Account accountRecord  = new Account();
            if(!getAccountRecord.isEmpty()) {
                accountRecord  = [Select Id,BLN_CompanyRegistrationNumber__c,BLN_RegistrationAddress__CountryCode__s From Account Where Id = :getAccountRecord[0]  WITH SECURITY_ENFORCED];  
               
                
                headerResponseMap.put(BLN_AppConstants.creditSafeInstance.headerCountryCode, accountRecord.BLN_RegistrationAddress__CountryCode__s != null ? accountRecord.BLN_RegistrationAddress__CountryCode__s : ''); 
                headerResponseMap.put(BLN_AppConstants.creditSafeInstance.headerGenericSystemKey, BLN_AppConstants.creditSafeInstance.headerGenericSystemValue); 
                headerResponseMap.put(BLN_AppConstants.creditSafeInstance.headerAccountId, accountRecord.Id != null ? accountRecord.Id : ''); 
                headerResponseMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
                creditSafeResponse = BLN_HttpCalloutUtility.makeCallout(System.label.BLN_TargetSystemMulesoft,BLN_AppConstants.creditSafeInstance.creditSafeRequestEndpoint+ BLN_AppConstants.creditSafeInstance.creditSafeRequestPath+  BLN_AppConstants.creditSafeInstance.creditSafeRequestQueryString  +accountRecord.BLN_CompanyRegistrationNumber__c,BLN_AppConstants.HTTPMETHODTYPEGET,headerResponseMap,'','',timeout);
            }     
            
            String creditSafeStatus = '';
            if (creditSafeResponse != null && creditSafeResponse.getStatusCode() == 200) {  
                BLN_WrapperStore.CreditSafeResponse creditSafeResponseWrapper = BLN_WrapperStore.parseCreditSafeResponse(creditSafeResponse.getBody());
                creditSafeStatus = creditSafeResponseWrapper.statusCompanyReportProcessing;
            } 

                    
            if(creditSafeStatus != '' && creditSafeStatus != null){
                return new List<String>{creditSafeStatus} ;
                    }
            
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            
        }
        return null;
    }
    
}