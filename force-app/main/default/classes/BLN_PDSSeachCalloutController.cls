/*****************************************
ClassName : BLN_PDSSeachCalloutController
Description : This class is used as a controller class of bln_PDSSearch.
CreatedDate: 26-03-2024
CreatedBy : Pwc-India
****************************************/

public with sharing class BLN_PDSSeachCalloutController {
       
                
    /*****************************************
MethodName : blnPDSsearchAPI
Description : This method is used to get the case record from record id.
Input Parameter : string
Output Parameter : Case
CreatedDate: 26-03-2024
CreatedBy : Pwc-India
Change log :
****************************************/
    @AuraEnabled
    public static Case blnPDSsearchAPI(string recordId){
       
        Case cs = new Case();
        try{
            if (String.isNotBlank(recordId)){
            cs = [SELECT Id,BLN_Vehicle__c,BLN_VRN__c,CreatedDate, BLN_BillingMethod__c ,BLN_Corporate__c, BLN_Corporate__r.BLN_KnownAs__c,BLN_Corporate__r.BLN_PolicyConfirmation__c from Case where id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
            }
    } catch(Exception ex){
        BLN_ExceptionLogger.captureException(ex);
    }
        return cs;
    }           
        
/*****************************************
MethodName : getCustomerB2BAccount
Description : This method is used to get the case record from record id.
Input Parameter : (string, String, String)
Output Parameter : List<Account>
CreatedDate: 26-03-2024
CreatedBy : Pwc-India
Change log :
****************************************/
    @AuraEnabled
    public static List<Account> getCustomerB2BAccount(String accountName, String accountNumber, String selectedOption) {
        List<Account> accounts = new List<Account>();
        String likeAccountName = '';
    String accountQuery = '';  
    String altNameQuery = ''; 
    String altAccountQuery = '';
    try {  
        if (String.isNotBlank(accountName)) {  
            likeAccountName = '%' + String.escapeSingleQuotes(accountName) + '%';  
            
            }  
            accountQuery = String.escapeSingleQuotes(accountQuery);
            
            
         accountQuery = 'SELECT Id, Name, BLN_NonDirectBilling__c, BLN_Status__c, BLN_MDMAccountID__c ' +  
                       'FROM Account ' +  
                       'WHERE RecordType.DeveloperName = \'BLN_CustomerB2BAccount\' ' +  
                       'AND BLN_Level__c = \'Legal Entity Account\' ';  
  
        if (selectedOption == 'Corporate') {  
            accountQuery += ' AND BLN_ClientType__c != \'Insurance\'';  
            if (String.isNotBlank(accountNumber)) {  
                accountQuery += ' AND BLN_MDMAccountID__c = \'' + String.escapeSingleQuotes(accountNumber) + '\'';    
            }  else if (String.isNotBlank(accountName)) {  
                accountQuery += ' AND Name LIKE \'' +   likeAccountName  + '\''; 
                
            }  
            else if  (String.isNotBlank(accountNumber) && String.isNotBlank(accountName)){
                accountQuery  += ' AND BLN_MDMAccountID__c = \'' + String.escapeSingleQuotes(accountNumber) + '\' AND Name LIKE \'' + likeAccountName  + '\''; 
      }
        } else if (selectedOption == 'Insurance') {  
            accountQuery += ' AND BLN_ClientType__c = \'Insurance\'';  
            if (String.isNotBlank(accountName)) {  
                accountQuery += ' AND Name LIKE \'' + likeAccountName  + '\''; 
            }  
        }  
  
        if (!String.isBlank(accountQuery)) {  
            accounts = Database.query(accountQuery);  
        }  
  
        if (String.isNotBlank(accountName)) {  
              altNameQuery = 'SELECT BLN_Account__c ' +  
                           'FROM BLN_AccountAlternativeName__c ' +  
                           'WHERE BLN_AlternativeAccountName__c LIKE :likeAccountName';  
                           List<BLN_AccountAlternativeName__c> altNames = new List<BLN_AccountAlternativeName__c>();
                            altNames = Database.query(altNameQuery);  
  
            
                Set<Id> altAccountIds = new Set<Id>();  
                for (BLN_AccountAlternativeName__c altName : altNames) {  
                    altAccountIds.add(altName.BLN_Account__c);  
                }

        if(!altAccountIds.isEmpty()){
  
                 altAccountQuery = 'SELECT Id, Name, BLN_NonDirectBilling__c, BLN_Status__c, BLN_MDMAccountID__c ' +  
                                         'FROM Account ' +  
                                         'WHERE Id IN :altAccountIds ' +  
                                         'AND RecordType.DeveloperName = \'BLN_CustomerB2BAccount\' ' +  
                                         'AND BLN_Level__c = \'Legal Entity Account\' ';  

          altAccountQuery += (selectedOption == 'Corporate')   ? ' AND BLN_ClientType__c != \'Insurance\''  : (selectedOption == 'Insurance')  ? ' AND BLN_ClientType__c = \'Insurance\''  : ''; 
          altAccountQuery += (selectedOption == 'Corporate' && String.isNotBlank(accountNumber))  ? ' AND BLN_MDMAccountID__c = :accountNumber'  : '';   
  
                List<Account> altAccounts = Database.query(altAccountQuery);  
                accounts.addAll(altAccounts);  
            }  
        }  
  
        
        Set<Id> accountIds = new Set<Id>();  
        List<Account> uniqueAccounts = new List<Account>();  
        for (Account acc : accounts) {  
            if (!accountIds.contains(acc.Id)) {  
                accountIds.add(acc.Id);  
                uniqueAccounts.add(acc);  
            }  
        }  
        accounts = uniqueAccounts;  
  
    } catch(Exception ex){
        BLN_ExceptionLogger.captureException(ex);
    }
        return accounts;
    }
/*****************************************
MethodName : searchManual
Description : This method is used to get the known as value from corporate.
Input Parameter : Case
Output Parameter : String
CreatedDate: 26-03-2024
CreatedBy : Pwc-India
Change log :
****************************************/

    @AuraEnabled
    public static String searchManual(Case cs){
        String name = ''; 
        try{  
       
        if(cs.BLN_Corporate__c != null && !String.isBlank(cs.BLN_Corporate__r.BLN_KnownAs__c) && cs.BLN_Corporate__r.BLN_PolicyConfirmation__c == System.label.BLN_Rejected){
            name = cs.BLN_Corporate__r.BLN_KnownAs__c;
        }
    } catch(Exception ex){
        BLN_ExceptionLogger.captureException(ex);
    }      
        return name;      
               
    }    

   /*****************************************
MethodName : makeCallout
Description : This method is used to callout happy path pds api.
Input Parameter : (String, Date)
Output Parameter : String
CreatedDate: 26-03-2024
CreatedBy : Pwc-India
Change log :
****************************************/
    @AuraEnabled
    public static String makeCallout(String vrn, Date lossDate){
        
        String corpWrap = '';
        String endPoint = '';
        String accountMDMID = '';
        Map<String,String> headerMap = new Map<String,String>();
        HttpResponse response = new HttpResponse();
        String lossDateString = string.valueOf(lossDate);  
        CalloutCorporateWrapper calloutCorporateWrap = new CalloutCorporateWrapper();
        
        try{
            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_PDSVRNCalloutName);    
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
            if(calloutDetails.BLN_Headers__c != null)   {
            for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
            }  
        }
        if(calloutDetails != null)   {    
            endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c + System.label.BLN_QuestionMark + System.label.BLN_VehicleCountryCode + System.label.BLN_EqualTo + System.label.BLN_CountryValue + System.label.BLN_ANDOperator + 
                System.label.BLN_VrnLabel + System.label.BLN_EqualTo + vrn + System.label.BLN_ANDOperator + System.label.BLN_LossDate + System.label.BLN_EqualTo + lossDateString +  System.label.BLN_ANDOperator + System.label.BLN_InsurerAPI + System.label.BLN_EqualTo + System.label.BLN_PDSOrigin;

            response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c, endPoint, calloutDetails.BLN_Method__c, headerMap, Integer.valueOf(calloutDetails.BLN_APITimeout__c));   
        }

        if (response != null && lossDate != null ) { 
            calloutCorporateWrap = getCorporateWrapper(response, lossDate, accountMDMID, false, true);
        }  
        }
        catch(Exception ex){
            BLN_ExceptionLogger.captureException(ex);
        }
        corpWrap = JSON.serialize(calloutCorporateWrap);
        return corpWrap;
    }
    /*****************************************
MethodName     : pdsDirectCallout
Description    : This method is used to call pds direct api.
Input Parameter: (String, Date, String, String)
Output Parameter: String
CreatedDate    : 09-06-2024
CreatedBy      : PwC-India
Change log     :
****************************************/
@AuraEnabled
    public static String pdsDirectCallout(String vrn, Date lossDate, String vehicleId, String accountMDMID) {
        String corpWrap = '';
        Map<String, String> headerMap = new Map<String, String>();
        HttpResponse response = new HttpResponse();
        String lossDateString = String.valueOf(lossDate).substring(0,10);
        String endPoint = '';
        
        CalloutCorporateWrapper calloutCorporateWrap = new CalloutCorporateWrapper();
        
        try {
            
            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_PDSVRNCalloutName);
            
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0], 
                          System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1] + ' ' + BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
            if(calloutDetails.BLN_Headers__c != null)   {
            for (String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)) {
                headerMap.put(str.split(System.label.BLN_Comma)[0], str.split(System.label.BLN_Comma)[1]);
            }
        }
        if(calloutDetails != null){      
            endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c + System.label.BLN_QuestionMark + 
                System.label.BLN_VehicleCountryCode + System.label.BLN_EqualTo + System.label.BLN_CountryValue + 
                System.label.BLN_ANDOperator + System.label.BLN_VrnLabel + System.label.BLN_EqualTo + vrn + 
                System.label.BLN_ANDOperator + System.label.BLN_LossDate + System.label.BLN_EqualTo + lossDateString + 
                System.label.BLN_ANDOperator + System.label.BLN_InsurerAPI + System.label.BLN_EqualTo + System.label.BLN_PDSOrigin+
                System.label.BLN_ANDOperator + System.label.BLN_LegalAccId + System.label.BLN_EqualTo + accountMDMID;
            
            response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c, endPoint, calloutDetails.BLN_Method__c, headerMap, Integer.valueOf(calloutDetails.BLN_APITimeout__c));
        } 
        if (response != null && lossDate != null && accountMDMID != null) { 
            calloutCorporateWrap = getCorporateWrapper(response, lossDate, accountMDMID,true, true);
        }
            
        } catch (Exception ex) {
            BLN_ExceptionLogger.captureException(ex);
        }
        corpWrap = JSON.serialize(calloutCorporateWrap);
        return corpWrap;
    }
    
    /*****************************************
MethodName     : getPolicyFormatApi
Description    : This method is used for call policy format api for corporate.
Input Parameter: String, String, String, Date
Output Parameter: String
CreatedDate    : 09-06-2024
CreatedBy      : PwC-India
Change log     :
****************************************/
    @AuraEnabled
    public static String getPolicyFormatApi(String accountMDMID, String policyno, String replacementexcess, Date lossDate) {
        
       
        String corpWrap = '';
        String endPoint = '';
        Map<String, String> headerMap = new Map<String, String>();
        HttpResponse response = new HttpResponse();
        String lossDateString = String.valueOf(lossDate).substring(0,10);
        String excessGlassValueString = String.valueOf(replacementexcess);
        CalloutCorporateWrapper calloutCorporateWrap = new CalloutCorporateWrapper();
        if (policyno.contains(' ')) {  
            policyno = policyno.replace(' ', '%20');  
        }
        
          String originalString = policyno;  
        if (originalString.contains('/')) {  
            policyno = originalString.replace('/', '%23');  
        }
        
        try {
            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_PolicyFormatCalloutName);
          
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0], 
                          System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1] + ' ' + BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
            
     if(calloutDetails.BLN_Headers__c != null)   {
            for (String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)) {
                headerMap.put(str.split(System.label.BLN_Comma)[0], str.split(System.label.BLN_Comma)[1]);
            }  
        }   
        if(calloutDetails != null){      
            endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c + '/' + accountMDMID + '/policies/'+ policyno
                + '/' + 'templates?' +'glassExcessValue' + System.label.BLN_EqualTo + excessGlassValueString + 
                System.label.BLN_ANDOperator + System.label.BLN_LossDate + System.label.BLN_EqualTo + lossDateString ;

            response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c, endPoint, calloutDetails.BLN_Method__c, headerMap, Integer.valueOf(calloutDetails.BLN_APITimeout__c));
        }

        if (response != null && lossDate != null && accountMDMID != null) { 
            calloutCorporateWrap = getCorporateWrapper(response,lossDate, accountMDMID, false, false);
        }
            
        } catch (Exception ex) {            
            BLN_ExceptionLogger.captureException(ex);
        }        
        corpWrap = JSON.serialize(calloutCorporateWrap);
        return corpWrap;
    }
    
    /*****************************************
MethodName     : splitBillCorpCallout
Description    : This method is for split bill api for corporate.
Input Parameter: (String, Date)
Output Parameter: String
CreatedDate    : 09-06-2024
CreatedBy      : PwC-India
Change log     :
****************************************/   
    @AuraEnabled
    public static String splitBillCorpCallout(String accountMDMID, Date lossDate) {
        
        String corpWrap = '';
        String endPoint = '';
        Map<String, String> headerMap = new Map<String, String>();
        HttpResponse response = new HttpResponse();        
        String lossDateString = String.valueOf(lossDate).substring(0,10);
        CalloutCorporateWrapper calloutCorporateWrap = new CalloutCorporateWrapper();
        
        try {
            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_SplitBillCorpCalloutName);
            
                
                    String[] parts = System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma);  
                    if ( parts[0] != null && parts[1] != null) {  
                        String accessToken = BLN_HTTPCallOutAccessToken.getAccessToken() != null ? BLN_HTTPCallOutAccessToken.getAccessToken().accessToken : null;  
                        if (accessToken != null) {  
                            headerMap.put(parts[0], parts[1] + ' ' + accessToken);  
                        }  
                    }  
                
                if (calloutDetails.BLN_Headers__c != null && System.label.BLN_Semicolon != null) {  
                    String[] headerEntries = calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon);  
                          for (String str : headerEntries) {  
                        
                            
                            String[] headerParts = str.split(System.label.BLN_Comma);  
                            if ( headerParts[0] != null && headerParts[1] != null) {  
                                headerMap.put(headerParts[0], headerParts[1]);  
                            } 
                          
                    } 
                }
            
            if(calloutDetails != null){
            endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c +'/' + accountMDMID + '/split-billings?'+
                System.label.BLN_LossDate + System.label.BLN_EqualTo + lossDateString;   
             response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c, endPoint, calloutDetails.BLN_Method__c, headerMap, Integer.valueOf(calloutDetails.BLN_APITimeout__c));
            }
            if (response != null && lossDate != null && accountMDMID != null) { 
            calloutCorporateWrap = getCorporateWrapper(response, lossDate, accountMDMID, false, false);     
            }
         
            set<String> corpSiteIdSet = new set<String>();

            if(calloutCorporateWrap.corporateWrapList.Size() > 0){
            for(CorporateWrapper objCorpWap : calloutCorporateWrap.corporateWrapList){
                corpSiteIdSet.add(objCorpWap.corporateSiteID);
            }
        }
            list<Account> siteAccountList = new list<Account>();
            
            if(accountMDMID != null) {
                siteAccountList = [select id,Name, BLN_NonDirectBilling__c, BLN_ClientType__c from Account where BLN_Level__c = : System.label.BLN_SiteAccount AND RecordType.DeveloperName  =:  System.label.BLN_CustomerB2BAccount AND parent.BLN_MDMAccountID__c = : accountMDMID AND BLN_MDMAccountID__c NOT IN : corpSiteIdSet WITH SECURITY_ENFORCED ];
                if(!siteAccountList.isEmpty()){
                    for(Account acc : siteAccountList) {
                        CorporateWrapper corp = new CorporateWrapper();
                        corp.corporateSiteName = acc.Name;
                        corp.corporateSiteSFId = acc.Id;
                        corp.corporateSiteSFNonDirectBilling = acc.BLN_NonDirectBilling__c;
                        calloutCorporateWrap.corporateWrapList.add(corp);
                    }
                
                }
                }
            
        } catch (Exception ex) {
            BLN_ExceptionLogger.captureException(ex);
        }        
        corpWrap = JSON.serialize(calloutCorporateWrap);
        return corpWrap;
  }
    
 /*****************************************
MethodName     : getCorporateWrapper
Description    : This method is for getting the wrapper.
Input Parameter: (HttpResponse, Date)
Output Parameter: CalloutCorporateWrapper
CreatedDate    : 09-06-2024
CreatedBy      : PwC-India
Change log     :
****************************************/
    public static CalloutCorporateWrapper getCorporateWrapper(HttpResponse response, Datetime incidentDate, String accountMDMID, Boolean isPDSDirectCall, Boolean isSchemeCode){
        

        CalloutCorporateWrapper calloutCorpWrapper = new CalloutCorporateWrapper();
        List<CorporateWrapper> corporateWrapList = new List<CorporateWrapper>();        
        
        String policyStartDate = '';
        String policyEndDate = '';
        List<String> mdmIdList = new List<String>();
        Map<String,Account> mdmIdAccMap = new Map<String,Account>();
        Boolean flagDate = false;
        Boolean flagActive = false;
       
        List<CorporateWrapper> responsecorporateWrapList = new List<CorporateWrapper>();
        try{

        if (response != null && (response.getStatusCode() == 201 || response.getStatusCode() == 200)) {
            
            PayloadWrapper parserReq = new PayloadWrapper();parserReq = (PayloadWrapper) JSON.deserialize(response.getBody(), PayloadWrapper.class);  

            if(parserReq.statuscode == 200  && parserReq.body.status == System.label.BLN_Success){
                
                responsecorporateWrapList = parserReq.body.data;
                    
            }
        }

        else {
            ErrorWrapper errorRec = new ErrorWrapper();
            errorRec.title = System.label.BLN_PdsApiError;errorRec.detail = System.label.BLN_PdsApiError;List<ErrorWrapper> errors = new List<ErrorWrapper>();errors.add(errorRec);
            calloutCorpWrapper.errors = errors;
            }
            
            if(!responsecorporateWrapList.isEmpty()){
               
               /* if(isPDSDirectCall == true && isSchemeCode == true && !isInsuranceSiteIDSet(responsecorporateWrapList)){
                  
                    responsecorporateWrapList = getSchemeCodes(responsecorporateWrapList, accountMDMID, true);
                    
                } else if( isSchemeCode == true && isPDSDirectCall == false && !isInsuranceSiteIDSet(responsecorporateWrapList)) {
                    responsecorporateWrapList = getSchemeCodes(responsecorporateWrapList, accountMDMID, false);
                  } */
                
                for (CorporateWrapper corpWrapper : responsecorporateWrapList) {
                    
                if(corpWrapper.corporateLegalEntityID != null && !String.isBlank(corpWrapper.corporateLegalEntityID)){
                    mdmIdList.add(corpWrapper.corporateLegalEntityID);
                }
                if(corpWrapper.corporateSiteID != null && !String.isBlank(corpWrapper.corporateSiteID)){
                mdmIdList.add(corpWrapper.corporateSiteID);
                }
                if(corpWrapper.corporateCountryGroupingID != null  && !String.isBlank(corpWrapper.corporateCountryGroupingID)){
                mdmIdList.add(corpWrapper.corporateCountryGroupingID);
                
                }
                if(corpWrapper.insuranceSiteID != null && !String.isBlank(corpWrapper.insuranceSiteID)){
                mdmIdList.add(corpWrapper.insuranceSiteID);
            
                }
                if(corpWrapper.insuranceLegalEntityID != null && !String.isBlank(corpWrapper.insuranceLegalEntityID)){
                mdmIdList.add(corpWrapper.insuranceLegalEntityID);
               
                }
                if(corpWrapper.insuranceCountryGroupingID != null && !String.isBlank(corpWrapper.insuranceCountryGroupingID)){
                mdmIdList.add(corpWrapper.insuranceCountryGroupingID);
               
                }
                
                    
            }

            if(!mdmIdList.isEmpty()){
                
                mdmIdAccMap = getAccountMap(mdmIdList);
                  
                }
                
                   
                    responsecorporateWrapList = getSchemeCodes(responsecorporateWrapList);  
                    
                   
                
                for (CorporateWrapper corpWrapper : responsecorporateWrapList) {                   
                    
                    if(mdmIdAccMap.containsKey(corpWrapper.insuranceLegalEntityID) && mdmIdAccMap.get(corpWrapper.insuranceLegalEntityID) != null && mdmIdAccMap.get(corpWrapper.insuranceLegalEntityID).BLN_ClientType__c == System.label.BLN_PdsInsurance  && mdmIdAccMap.get(corpWrapper.insuranceLegalEntityID).BLN_Level__c == System.label.BLN_LegalEntityAccount && mdmIdAccMap.get(corpWrapper.insuranceLegalEntityID).Id != null && mdmIdAccMap.get(corpWrapper.insuranceLegalEntityID).Name != null){                
                corpWrapper.insuranceLegalEntityName = mdmIdAccMap.get(corpWrapper.insuranceLegalEntityID).Name;
                corpWrapper.insuranceLegalEntitySFId = mdmIdAccMap.get(corpWrapper.insuranceLegalEntityID).Id;
                
               }
                    if(mdmIdAccMap.containsKey(corpWrapper.insuranceSiteID) && mdmIdAccMap.get(corpWrapper.insuranceSiteID) != null && mdmIdAccMap.get(corpWrapper.insuranceSiteID).BLN_ClientType__c == System.label.BLN_PdsInsurance  && mdmIdAccMap.get(corpWrapper.insuranceSiteID).BLN_Level__c == System.label.BLN_SiteAccount && mdmIdAccMap.get(corpWrapper.insuranceSiteID).Id != null && mdmIdAccMap.get(corpWrapper.insuranceSiteID).Name != null ){                 
                corpWrapper.insuranceSiteAccountName=mdmIdAccMap.get(corpWrapper.insuranceSiteID).Name;
                corpWrapper.insuranceSiteAccountSFId=mdmIdAccMap.get(corpWrapper.insuranceSiteID).Id;                
                corpWrapper.insuraceSiteSFNonDirectBilling=mdmIdAccMap.get(corpWrapper.insuranceSiteID).BLN_NonDirectBilling__c;
            }
                    if(mdmIdAccMap.containsKey(corpWrapper.insuranceCountryGroupingID) && mdmIdAccMap.get(corpWrapper.insuranceCountryGroupingID) != null && mdmIdAccMap.get(corpWrapper.insuranceCountryGroupingID).BLN_ClientType__c == System.label.BLN_PdsInsurance  && mdmIdAccMap.get(corpWrapper.insuranceCountryGroupingID).BLN_Level__c ==  System.label.BLN_CountryGroupingAccount  && mdmIdAccMap.get(corpWrapper.insuranceCountryGroupingID).Id != null && mdmIdAccMap.get(corpWrapper.insuranceCountryGroupingID).Name != null){                   
                        corpWrapper.insuranceCountryGroupingName=mdmIdAccMap.get(corpWrapper.insuranceCountryGroupingID).Name;
                        corpWrapper.insuranceCountryGroupingSFId=mdmIdAccMap.get(corpWrapper.insuranceCountryGroupingID).Id;
                    }
                    if(mdmIdAccMap.containsKey(corpWrapper.corporateLegalEntityID) && mdmIdAccMap.get(corpWrapper.corporateLegalEntityID) != null && mdmIdAccMap.get(corpWrapper.corporateLegalEntityID).BLN_ClientType__c != System.label.BLN_PdsInsurance  && mdmIdAccMap.get(corpWrapper.corporateLegalEntityID).BLN_Level__c == System.label.BLN_LegalEntityAccount && mdmIdAccMap.get(corpWrapper.corporateLegalEntityID).Id != null && mdmIdAccMap.get(corpWrapper.corporateLegalEntityID).Name != null){                  
                        corpWrapper.corporateLegalEntityName=mdmIdAccMap.get(corpWrapper.corporateLegalEntityID).Name;
                        corpWrapper.corporateLegalEntitySFId=mdmIdAccMap.get(corpWrapper.corporateLegalEntityID).Id;
                    }
                    if(mdmIdAccMap.containsKey(corpWrapper.corporateSiteID)  && mdmIdAccMap.get(corpWrapper.corporateSiteID) != null && mdmIdAccMap.get(corpWrapper.corporateSiteID).BLN_ClientType__c != System.label.BLN_PdsInsurance  && mdmIdAccMap.get(corpWrapper.corporateSiteID).BLN_Level__c == System.label.BLN_SiteAccount && mdmIdAccMap.get(corpWrapper.corporateSiteID).Id != null && mdmIdAccMap.get(corpWrapper.corporateSiteID).Name != null){       
                corpWrapper.corporateSiteName=mdmIdAccMap.get(corpWrapper.corporateSiteID).Name;
                corpWrapper.corporateSiteSFId=mdmIdAccMap.get(corpWrapper.corporateSiteID).Id;
                corpWrapper.corporateSiteSFNonDirectBilling=mdmIdAccMap.get(corpWrapper.corporateSiteID).BLN_NonDirectBilling__c;
            }
                    if(mdmIdAccMap.containsKey(corpWrapper.corporateCountryGroupingID) && mdmIdAccMap.get(corpWrapper.corporateCountryGroupingID) != null && mdmIdAccMap.get(corpWrapper.corporateCountryGroupingID).BLN_ClientType__c != System.label.BLN_PdsInsurance && mdmIdAccMap.get(corpWrapper.corporateCountryGroupingID).BLN_Level__c == System.label.BLN_CountryGroupingAccount && mdmIdAccMap.get(corpWrapper.corporateCountryGroupingID).Id != null && mdmIdAccMap.get(corpWrapper.corporateCountryGroupingID).Name != null){ 
                corpWrapper.corporateCountryGroupingName=mdmIdAccMap.get(corpWrapper.corporateCountryGroupingID).Name;
                corpWrapper.corporateCountryGroupingSFId=mdmIdAccMap.get(corpWrapper.corporateCountryGroupingID).Id;
                }
                    corpWrapper.attachToCase = false;

                if(!String.isBlank(corpWrapper.policyExpirationDatetime)){
                policyEndDate = (corpWrapper.policyExpirationDatetime).replace('T', ' ').replace('Z', '');
                
              }
              if(!String.isBlank(corpWrapper.policyValidFromDatetime)){
                  policyStartDate = (corpWrapper.policyValidFromDatetime).replace('T', ' ').replace('Z', ''); 
                }

                if(incidentDate != null && corpWrapper.policyValidFromDatetime != null && corpWrapper.policyExpirationDatetime != null && (!(Datetime.valueOf(policyStartDate) <= incidentDate && Datetime.valueOf(policyEndDate) >= incidentDate)) ){
                        
                    flagDate = true;
                    }
                    
                    if( (corpWrapper.insuranceLegalEntityID != null && corpWrapper.corporateLegalEntityID == null && !mdmIdAccMap.containsKey(corpWrapper.insuranceLegalEntityID)) || (corpWrapper.corporateLegalEntityID != null && corpWrapper.insuranceLegalEntityID == null && !mdmIdAccMap.containsKey(corpWrapper.corporateLegalEntityID)) || (corpWrapper.corporateLegalEntityID != null && corpWrapper.insuranceLegalEntityID != null && ( !mdmIdAccMap.containsKey(corpWrapper.insuranceLegalEntityID) || !mdmIdAccMap.containsKey(corpWrapper.corporateLegalEntityID))) || (corpWrapper.insuranceLegalEntityID == null && corpWrapper.corporateLegalEntityID == null) || (corpWrapper.insuranceSiteAccountSFId == null && corpWrapper.corporateSiteSFId == null) ){
                        
                        flagActive = true;

                    }                   
                    if(flagDate == false && flagActive == false ){

                    corporateWrapList.add(corpWrapper); 
                }           
            }  

        } 
            if(corporateWrapList != null && !corporateWrapList.isEmpty()){
                
                calloutCorpWrapper.corporateWrapList = getReference(corporateWrapList,mdmIdAccMap);  
                      
            }            
        }
        catch(Exception ex){            
            BLN_ExceptionLogger.captureException(ex);
        }        
        
        return calloutCorpWrapper;        
    }

    /*****************************************
MethodName     : getAccountMap
Description    : This method is used to get the account map.
Input Parameter: List<String>
Output Parameter: map<String, Account>
CreatedDate    : 09-06-2024
CreatedBy      : PwC-India
Change log     :
****************************************/
    
    public static map<String, Account> getAccountMap(List<String> mdmIdList){
        Map<String,Account> mdmIdAccMap = new Map<String,Account>();
        List<Account> accList = new List<Account>();
      try{
            accList = [SELECT Id,Name, BLN_Status__c, BLN_MDMAccountID__c,BLN_ClientType__c,BLN_NonDirectBilling__c,BLN_Level__c FROM Account WHERE BLN_MDMAccountID__c IN : mdmIdList  WITH SECURITY_ENFORCED];

        if(!accList.isEmpty()) {
        for (Account acc : accList){
            mdmIdAccMap.put(acc.BLN_MDMAccountID__c, acc);
        }
    }
} catch(Exception ex){
    BLN_ExceptionLogger.captureException(ex);
}
      return mdmIdAccMap;
   }

/*****************************************
MethodName      : createUpdateRecords
Description     : This method is used to create corporate.
Input Parameter : (String, Case)
Output Parameter: boolean
CreatedDate     : 09-06-2024
CreatedBy       : PwC-India
Change log      :
****************************************/
   @AuraEnabled
   public static boolean createUpdateRecords(String corporateWrapperList, Case cs){

    List<CorporateWrapper> corWarpList =  new List<CorporateWrapper>();
    corWarpList =(List<CorporateWrapper>)JSON.deserializeStrict(corporateWrapperList, List<CorporateWrapper>.class);
    Boolean success = false;
   String policyEndDate = '';
   String policyStartDate = '';
        String realtedSiteId;

    List<BLN_Corporate__c> corporateList = new List<BLN_Corporate__c>();
    List<BLN_Corporate__c> corporateAccteptedList = new List<BLN_Corporate__c>();

        try{
            if(corWarpList != null && !corWarpList.isEmpty()) {
               
                Case queriedCase  = [SELECT BLN_Make__c, BLN_Model__c, BLN_BillingName__c FROM Case WHERE Id = :cs.Id WITH SECURITY_ENFORCED];  
                
                for (CorporateWrapper corpWrapper : corWarpList) {
                    BLN_Corporate__c corpRecord = new BLN_Corporate__c();
            if(!String.isBlank(corpWrapper.policyValidFromDatetime)){
                policyStartDate = corpWrapper.policyValidFromDatetime;
                policyStartDate = policyStartDate.replace('T', ' ').replace('Z', '');
            }
            if(!String.isBlank(corpWrapper.policyExpirationDatetime)){
                policyEndDate =  corpWrapper.policyExpirationDatetime;
                policyEndDate = policyEndDate.replace('T', ' ').replace('Z', '');
            }
          
            corpRecord.BLN_Vehicle__c = cs.BLN_Vehicle__c;
                    //system.debug('cs.BLN_Make__c' + cs.BLN_Vehicle__r.BLN_MakeOfVehicle__c + cs.BLN_Vehicle__c);
                    //corpRecord.BLN_VehicleRegistration__c = corpWrapper.vehicleRegistration != null ? corpWrapper.vehicleRegistration : '';
            corpRecord.BLN_CorporateOperatingCompanyName__c = corpWrapper.operatingCompanyName != null ? corpWrapper.operatingCompanyName : '';
            corpRecord.BLN_CorporateOperatingCompanyPostcode__c = corpWrapper.operatingCompanyPostcode != null ? corpWrapper.operatingCompanyPostcode : '';
            corpRecord.BLN_PolicyNumber__c = corpWrapper.policyNumber != null ? corpWrapper.policyNumber : '';       
            corpRecord.BLN_VATPayingPartyType__c =  corpWrapper.vatPayingParty != null ? corpWrapper.vatPayingParty  : '';
            corpRecord.BLN_ExcessPayingPartyType__c = corpWrapper.excessPayingParty != null ? corpWrapper.excessPayingParty : '';
            corpRecord.BLN_policyFormat__c = corpWrapper.policyFormat != null ? corpWrapper.policyFormat : '';
                    //corpRecord.BLN_VehicleMake__c = corpWrapper.providedVehicleMake != null ? corpWrapper.providedVehicleMake : '';
                    //corpRecord.BLN_VehicleModel__c = corpWrapper.providedVehicleModel != null ? corpWrapper.providedVehicleModel : '';
                 
                    if (String.isBlank(corpWrapper.providedVehicleMake) && String.isBlank(corpWrapper.providedVehicleModel)) {  
                        //system.debug('inside if');
                        corpRecord.BLN_VehicleMake__c =  queriedCase.BLN_Make__c  != null ?  queriedCase.BLN_Make__c  : '';  
                        
                        corpRecord.BLN_VehicleModel__c = queriedCase.BLN_Model__c != null ? queriedCase.BLN_Model__c : ''; 
  
                        corpRecord.BLN_VehicleRegistration__c = cs.BLN_VRN__c != null ? cs.BLN_VRN__c : ''; 

                    } else {  
                        corpRecord.BLN_VehicleMake__c = corpWrapper.providedVehicleMake; 
                        corpRecord.BLN_VehicleRegistration__c = corpWrapper.vehicleRegistration; 
                        corpRecord.BLN_VehicleModel__c = corpWrapper.providedVehicleModel;
                    } 
            corpRecord.BLN_Salutation__c =corpWrapper.salutation != null ? corpWrapper.salutation : '';
            corpRecord.BLN_FirstName__c = corpWrapper.firstName != null ? corpWrapper.firstName : '';
            corpRecord.BLN_MiddleName__c = corpWrapper.middleName != null ? corpWrapper.middleName : '';
            corpRecord.BLN_LastName__c = corpWrapper.lastName != null ? corpWrapper.lastName : '';
                  
            corpRecord.BLN_PostalCode__c = corpWrapper.addressPostalCode != null ? corpWrapper.addressPostalCode : '';
            corpRecord.BLN_PolicyValidationToken__c = corpWrapper.policyValidationToken != null ? corpWrapper.policyValidationToken : '';
            corpRecord.BLN_AdditionalDrivers__c = corpWrapper.additionalDrivers != null ? corpWrapper.additionalDrivers : '';
            corpRecord.BLN_PolicyTypeCode__c = corpWrapper.policyTypeCode != null ? corpWrapper.policyTypeCode : '';
            if(!String.isBlank(corpWrapper.policyValidFromDatetime)){
                corpRecord.BLN_PolicyStartDate__c =  DateTime.valueOf(policyStartDate) != null ? DateTime.valueOf(policyStartDate) : null;
            }
            if(!String.isBlank(corpWrapper.policyExpirationDatetime)){
                        corpRecord.BLN_PolicyEndDate__c =  DateTime.valueOf(policyEndDate) != null ?  DateTime.valueOf(policyEndDate) : null;
            }               
            corpRecord.BLN_GlassCoverFlag__c = corpWrapper.glassCoverFlag != null ? corpWrapper.glassCoverFlag : '';
            corpRecord.BLN_RepairCoverFlag__c = corpWrapper.repairCoverFlag != null ? corpWrapper.repairCoverFlag : '';
            
            corpRecord.BLN_ReplacementExcess__c = corpWrapper.glassExcessAmount != null ? corpWrapper.glassExcessAmount : null;
                    
                    corpRecord.BLN_RepairExcess__c = corpWrapper.repairExcessAmount != null ? corpWrapper.repairExcessAmount : null;
            corpRecord.BLN_WindscreenExcess__c =  corpWrapper.windscreenExcessAmount != null ? corpWrapper.windscreenExcessAmount : null;
            corpRecord.BLN_BodyGlassExcess__c = corpWrapper.bodyglassExcessAmount != null ? corpWrapper.bodyglassExcessAmount : null;
            corpRecord.BLN_HeatedRearExcess__c   = corpWrapper.heatedRearExcessAmount != null ? corpWrapper.heatedRearExcessAmount : null;
            corpRecord.BLN_ADASExcess__c = corpWrapper.adasExcessAmount != null ? corpWrapper.adasExcessAmount : null;
            corpRecord.BLN_LimitIncludedInExcess__c =  corpWrapper.limitIncExcess != null ? corpWrapper.limitIncExcess : '';
            corpRecord.BLN_RemainderPayingPartyType__c = corpWrapper.remainderPayingParty != null ? corpWrapper.remainderPayingParty : '';
            corpRecord.BLN_CommercialFlag__c = corpWrapper.commercialFlag != null ? corpWrapper.commercialFlag : '';
            corpRecord.BLN_VATRegisteredFlag__c = corpWrapper.vatRegFlag != null ? corpWrapper.vatRegFlag : '';
            corpRecord.BLN_Reference__c = corpWrapper.reference != null ? corpWrapper.reference : '';
                    corpRecord.BLN_PolicyLimit__c = corpWrapper.policyLimit != null ? corpWrapper.policyLimit : null;  
                    corpRecord.BLN_CorporateLegalEntity__c = realtedSiteId = corpWrapper.corporateLegalEntitySFId != null ? corpWrapper.corporateLegalEntitySFId : null;  
                    corpRecord.BLN_CorporateSite__c = realtedSiteId = corpWrapper.corporateSiteSFId != null ?  corpWrapper.corporateSiteSFId : null;
                    realtedSiteId = realtedSiteId == null ? corpRecord.BLN_CorporateSite__c : corpRecord.BLN_CorporateSite__c == null ? realtedSiteId : corpRecord.BLN_CorporateSite__c;
                    corpRecord.BLN_InsuranceLegalEntity__c = realtedSiteId = corpWrapper.insuranceLegalEntitySFId != null ? corpWrapper.insuranceLegalEntitySFId : null;
                    realtedSiteId = realtedSiteId == null ? corpRecord.BLN_InsuranceLegalEntity__c : corpRecord.BLN_InsuranceLegalEntity__c == null ? realtedSiteId : corpRecord.BLN_InsuranceLegalEntity__c;          
                    corpRecord.BLN_InsuranceSite__c = realtedSiteId = corpWrapper.insuranceSiteAccountSFId != null ? corpWrapper.insuranceSiteAccountSFId : null;
                    realtedSiteId = realtedSiteId == null ? corpRecord.BLN_InsuranceSite__c : corpRecord.BLN_InsuranceSite__c == null ? realtedSiteId : corpRecord.BLN_InsuranceSite__c;          
                    corpRecord.BLN_InsuranceCountryGrouping__c= corpWrapper.insuranceCountryGroupingSFId != null ? corpWrapper.insuranceCountryGroupingSFId : null;            
            corpRecord.BLN_CorporateCountryGrouping__c= corpWrapper.corporateCountryGroupingSFId != null ? corpWrapper.corporateCountryGroupingSFId : null; 
            corpRecord.BLN_KnownAs__c= corpWrapper.knownAs != null ? corpWrapper.knownAs : null; 
            corpRecord.BLN_PolicyConfirmation__c = corpWrapper.policyConfirmation != null ? corpWrapper.policyConfirmation : null;
            corpRecord.BLN_IspolicyValid__c = corpWrapper.isPolicyValid != null ? corpWrapper.isPolicyValid : null;
            corpRecord.BLN_Origin__c = corpWrapper.origin != null ? corpWrapper.origin : null;   
            if((corpRecord.BLN_CorporateSite__c != null && corpRecord.BLN_InsuranceSite__c == null) || 
            (corpRecord.BLN_CorporateSite__c == null && corpRecord.BLN_InsuranceSite__c == null && corpWrapper.isCorporateSelected != null && corpWrapper.isCorporateSelected  && corpWrapper.knownAs != null)){
                corpRecord.recordTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get(System.label.BLN_CorporateFleet).getRecordTypeId();
            }

            else if((corpRecord.BLN_CorporateSite__c == null && corpRecord.BLN_InsuranceSite__c != null) ||
            (corpRecord.BLN_CorporateSite__c == null && corpRecord.BLN_InsuranceSite__c == null && corpWrapper.isCorporateSelected != null && !corpWrapper.isCorporateSelected && corpWrapper.knownAs != null)){
                corpRecord.recordTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get(System.label.BLN_Insurance).getRecordTypeId();
            }

            else if(corpRecord.BLN_CorporateSite__c != null && corpRecord.BLN_InsuranceSite__c != null){
                corpRecord.recordTypeId = Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get(System.label.BLN_SplitBill).getRecordTypeId();
            } 
             if( corpWrapper.attachToCase == false){

                    corporateList.add(corpRecord); 
                }
                else if ( corpWrapper.attachToCase == true){                
                            
                    corporateAccteptedList.add(corpRecord);  
                }
                }  
                
            }
    if(!corporateList.isEmpty()){
       
        Database.SaveResult[] sr = Database.insert(corporateList);
                success = (sr != null && sr.size() > 0) ? true : false;
    }
    if(!corporateAccteptedList.isEmpty() && corporateAccteptedList.size()== 1){
        BLN_Corporate__c corpRecordToInsert = new BLN_Corporate__c();
        corpRecordToInsert = corporateAccteptedList.get(0);
        Database.SaveResult sr =  Database.insert(corpRecordToInsert);
            if (sr.isSuccess()) {                
                    cs.BLN_MotoristTaxStatus__c = taxStatusCheck(realtedSiteId,corpRecordToInsert);
               cs.BLN_Corporate__c = sr.getId();
               Database.SaveResult sr1 = Database.update(cs);
                   success = (sr1.isSuccess() == true ) ? true : false;
            }            
    }
            Case caseRecord = [SELECT Id, CaseNumber, BLN_Corporate__c,BLN_Corporate__r.BLN_PolicyValidationToken__c FROM Case where Id = :cs.Id WITH SECURITY_ENFORCED];
            List<BLN_DataCollectAnswer__c> answerRecords = [SELECT Id, BLN_Case__c, BLN_Question__c, BLN_Question__r.BLN_EDITypeCode__c FROM BLN_DataCollectAnswer__c WHERE BLN_Question__r.BLN_EDITypeCode__c =: System.label.BLN_ONUM AND BLN_Case__c = :cs.Id WITH SECURITY_ENFORCED];
            if(answerRecords != null && answerRecords.size() > 0){
                For(BLN_DataCollectAnswer__c answerRecord: answerRecords){
                    answerRecord.BLN_Answer__c = caseRecord.BLN_Corporate__r.BLN_PolicyValidationToken__c;
                }
                Database.SaveResult[] saveAnswerResult = Database.update(answerRecords);
                success = (saveAnswerResult != null ) ? true : false;
            } else{
                Date jobDate = Date.today();
                List<BLN_AccountRuleParameter__c> allArpRecords = new List<BLN_AccountRuleParameter__c>();
                List<BLN_AccountRuleParameter__c> corporateSiteRecords = new List<BLN_AccountRuleParameter__c>();
                List<BLN_AccountRuleParameter__c> insuranceSiteRecords = new List<BLN_AccountRuleParameter__c>();

                List<BLN_DataCollectAnswer__c> newAnswerRecords = new List<BLN_DataCollectAnswer__c>();
                //Get corporate record
                BLN_Corporate__c corporateRecord = [SELECT Id, Name, BLN_CorporateSite__c, BLN_InsuranceSite__c FROM BLN_Corporate__c WHERE Id =: caseRecord.BLN_Corporate__c WITH SECURITY_ENFORCED LIMIT 1];
                String corporateSiteId = corporateRecord.BLN_CorporateSite__c;
                String insuranceSiteId = corporateRecord.BLN_InsuranceSite__c;
                if(corporateSiteId != null && insuranceSiteId != null){
                    //Get ARP for split bill
                    corporateSiteRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.label.BLN_ARPDataCollect, corporateSiteId, jobDate);
                    insuranceSiteRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.label.BLN_ARPDataCollect,insuranceSiteId, jobDate);

                    if(corporateSiteRecords != null){
                        allArpRecords.addAll(corporateSiteRecords);
                    }
                    if(insuranceSiteRecords != null){
                        allArpRecords.addAll(insuranceSiteRecords);
                    }
                    
                } else if(corporateSiteId != null){
                    //Get ARP records for corporate
                    corporateSiteRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.label.BLN_ARPDataCollect, corporateSiteId, jobDate);
                    if(corporateSiteRecords != null){
                        allArpRecords.addAll(corporateSiteRecords);
                    }
                } else if(insuranceSiteId != null){
                    //Ger ARP records for insurance
                    insuranceSiteRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.label.BLN_ARPDataCollect, insuranceSiteId, jobDate);
                    if(insuranceSiteRecords != null){
                        allArpRecords.addAll(insuranceSiteRecords);
                    }
                }
                for(BLN_AccountRuleParameter__c arp: allArpRecords){
                    if(arp.BLN_EDITypeCode__c == System.label.BLN_ONUM){
                        BLN_DataCollectAnswer__c newRecord = new BLN_DataCollectAnswer__c();
                        newRecord.BLN_Question__c = arp.Id;
                        newRecord.BLN_Case__c = caseRecord.Id;
                        newRecord.BLN_Answer__c = caseRecord.BLN_Corporate__r.BLN_PolicyValidationToken__c;
                        newAnswerRecords.add(newRecord);
                    }
                }
                if(newAnswerRecords.size() > 0 && newAnswerRecords != null){
                    Database.SaveResult[] saveNewAnswers = Database.insert(newAnswerRecords);
                    success = (saveNewAnswers != null ) ? true : false;
                }
            }
        }
        catch(Exception ex){
            BLN_ExceptionLogger.captureException(ex);
        }
        return success;
    }    

    /*private static Boolean isInsuranceSiteIDSet(List<CorporateWrapper> corWarpList) {
        for (CorporateWrapper corpWrapper : corWarpList) {
            if (corpWrapper.insuranceSiteID != null) {
                return true; 
            }
        }
        return false; 
    }*/
    
    // Method to check taxStatus
    private static String taxStatusCheck(String realtedSiteId, BLN_Corporate__c corpRecordToInsert){
        List<BLN_AccountRuleParameter__c> acpList = [SELECT Id,BLN_VATToMotorist__c,BLN_Account__c FROM BLN_AccountRuleParameter__c WHERE BLN_Account__c = :realtedSiteId AND BLN_Account__c != null WITH SECURITY_ENFORCED];
        String retValue = 'N';
        Boolean siteVatStatus = false;
        for(BLN_AccountRuleParameter__c acp : acpList){
            if(acp.BLN_VATToMotorist__c){
                siteVatStatus = true;
                break;
            }
        }
        retValue = siteVatStatus || corpRecordToInsert.BLN_VATRegisteredFlag__c == 'Y' ? 'Yes' : 'No';
        return retValue;
    }


   /* MethodName      : getReference
    Description     : This method is used to fetch Reference value from BLN_AccountRuleParameter or from account.
    Input Parameter : (List, Map)
    Output Parameter: corWarpList
    CreatedDate     : 07-08-2024
    CreatedBy       : PwC-India
    Change log      :
    ****************************************/
    
    public static List<CorporateWrapper> getReference(List<CorporateWrapper> corWarpList, Map<String,Account> mdmIdAccMap){
        try{
    List<String> siteIds = new List<String>();

    for(CorporateWrapper corpWrapper : corWarpList) {
        if(corpWrapper.corporateSiteSFId != null && corpWrapper.insuranceSiteID != null) {

            siteIds.add(corpWrapper.corporateSiteSFId);
            siteIds.add(corpWrapper.insuranceSiteAccountSFId);
        }
    }
    List<BLN_AccountRuleParameter__c> accRuleParams = new List<BLN_AccountRuleParameter__c>();
    accRuleParams = [SELECT Id,BLN_Reference__c,BLN_ReplacementExcess__c,BLN_ActiveTo__c,BLN_ActiveFrom__c,BLN_Account__c,BLN_InsurerAccount__c FROM BLN_AccountRuleParameter__c WHERE RecordType.DeveloperName = 'BLN_SplitBill' AND BLN_ActiveFrom__c <= TODAY AND BLN_ActiveTo__c >= TODAY AND BLN_Account__c IN :siteIds AND BLN_InsurerAccount__c IN :siteIds  WITH SECURITY_ENFORCED];
    
    Map<String,BLN_AccountRuleParameter__c> accRuleParamsMap = new Map<String,BLN_AccountRuleParameter__c>();
    if(!accRuleParams.isEmpty()){
        for(BLN_AccountRuleParameter__c arp : accRuleParams){
            if(arp.BLN_Account__c != null){
                accRuleParamsMap.put(arp.BLN_Account__c,arp);
            }
            if(arp.BLN_InsurerAccount__c != null){
                accRuleParamsMap.put(arp.BLN_InsurerAccount__c,arp);
            }            
        }
    }

 
        for (CorporateWrapper corpWrapper : corWarpList) {    
            try{ 
            if (accRuleParamsMap != null && !accRuleParamsMap.isEmpty() && corpWrapper.corporateSiteSFId != null &&  corpWrapper.insuranceSiteAccountSFId != null && (accRuleParamsMap.containsKey(corpWrapper.corporateSiteSFId) && accRuleParamsMap.get(corpWrapper.corporateSiteSFId).BLN_ReplacementExcess__c == corpWrapper.glassExcessAmount) ||
                (accRuleParamsMap.containsKey(corpWrapper.insuranceSiteAccountSFId) && accRuleParamsMap.get(corpWrapper.insuranceSiteAccountSFId).BLN_ReplacementExcess__c == corpWrapper.glassExcessAmount)) {
                    
                    if(accRuleParamsMap.containsKey(corpWrapper.corporateSiteSFId)){
                        corpWrapper.reference = accRuleParamsMap.get(corpWrapper.corporateSiteSFId).BLN_Reference__c;
                    }
                    else if (accRuleParamsMap.containsKey(corpWrapper.insuranceSiteAccountSFId)){
                        corpWrapper.reference = accRuleParamsMap.get(corpWrapper.insuranceSiteAccountSFId).BLN_Reference__c;
                    }
                }          
            else if (mdmIdAccMap != null && !mdmIdAccMap.isEmpty() &&
                     corpWrapper.corporateSiteID != null && mdmIdAccMap.get(corpWrapper.corporateSiteID) != null) { 
                         corpWrapper.reference = mdmIdAccMap.get(corpWrapper.corporateSiteID).BLN_ClientType__c;
                     } 
            else  if (mdmIdAccMap != null && !mdmIdAccMap.isEmpty() &&
                      corpWrapper.insuranceSiteID != null && mdmIdAccMap.get(corpWrapper.insuranceSiteID) != null) {
                          corpWrapper.reference = mdmIdAccMap.get(corpWrapper.insuranceSiteID).BLN_ClientType__c;
                      }
                    }  catch(Exception ex){
                        BLN_ExceptionLogger.captureException(ex);
                    }
        }
    } catch(Exception ex){
        BLN_ExceptionLogger.captureException(ex);
    }
        return corWarpList;
    }

    
   /* MethodName      : getSchemeCodes
    Description     : This method is used to fetch SchemeCodes value from pds code object or from account.
    Input Parameter : (List, String)
    Output Parameter: corWarpList
    CreatedDate     : 07-08-2024
    CreatedBy       : PwC-India
    Change log      :
    ****************************************/
    
    public static List<CorporateWrapper> getSchemeCodes(List<CorporateWrapper> corWarpList) {  
    try {
        Set<String> schemeCodes = new Set<String>();
        Set<String> insuranceLegalEntityIDs = new Set<String>();
        Map<String, Account> accountMap = new Map<String, Account>();
        Map<String, String> schemeToMDMIdMap = new Map<String, String>(); 
        String mdmAccountId = ''; 
        Account relatedAccount = new Account();
      
        if (corWarpList != null && !corWarpList.isEmpty()) {
            for (CorporateWrapper corpWrapper : corWarpList) {
                if (corpWrapper.schemeCodeMapping != null && corpWrapper.insuranceSiteID == null) {
                    schemeCodes.add(corpWrapper.schemeCodeMapping);
                }
                if (corpWrapper.insuranceLegalEntityID != null && corpWrapper.insuranceSiteID == null) {
                    insuranceLegalEntityIDs.add(corpWrapper.insuranceLegalEntityID);
                }
            }

           if(!(schemeCodes.isEmpty() && insuranceLegalEntityIDs.isEmpty())){
            List<Account> relatedAccounts = [SELECT Id, Name, BLN_MDMAccountID__c, Parent.BLN_MDMAccountID__c, BLN_NonDirectBilling__c  
                                             FROM Account
                                             WHERE Parent.BLN_MDMAccountID__c IN :insuranceLegalEntityIDs
                                             AND BLN_Level__c = :System.label.BLN_SiteAccount
                                             WITH SECURITY_ENFORCED];

            for (Account acc : relatedAccounts) {
                accountMap.put(acc.BLN_MDMAccountID__c, acc);  
            }

           
            List<BLN_PDSCode__c> relatedPDSCodes = [SELECT Id, BLN_SchemeCode__c, BLN_Account__r.BLN_MDMAccountID__c,  BLN_Account__r.BLN_NonDirectBilling__c 
                                                     FROM BLN_PDSCode__c
                                                     WHERE BLN_SchemeCode__c IN :schemeCodes  AND BLN_Account__r.Parent.BLN_MDMAccountID__c IN :insuranceLegalEntityIDs AND BLN_Account__r.BLN_MDMAccountID__c != null
                                                     WITH SECURITY_ENFORCED];

            for (BLN_PDSCode__c pdsCode : relatedPDSCodes) {

                    schemeToMDMIdMap.put(pdsCode.BLN_SchemeCode__c, pdsCode.BLN_Account__r.BLN_MDMAccountID__c);  
           
            }  
        }

            
            for (CorporateWrapper corpWrapper : corWarpList) {
                if(schemeToMDMIdMap != null && !schemeToMDMIdMap.isEmpty()){
                 mdmAccountId = schemeToMDMIdMap.get(corpWrapper.schemeCodeMapping); 
                } 
                if(accountMap != null && !accountMap.isEmpty() && !string.isBlank(mdmAccountId)){
                 relatedAccount = accountMap.get(mdmAccountId);
                }
                
                  
                
                if (!string.isBlank(relatedAccount.id) && !string.isBlank(relatedAccount.Name) && corpWrapper.insuranceSiteID == null) {  
                    corpWrapper.insuranceSiteID = mdmAccountId;  
                                    corpWrapper.insuranceSiteAccountName = relatedAccount.Name;
                    corpWrapper.insuranceSiteAccountSFId = relatedAccount.Id;  
                    corpWrapper.insuraceSiteSFNonDirectBilling = relatedAccount.BLN_NonDirectBilling__c;  
                                }
                            }
                        
                    }
                
    } catch (Exception e) {  
        BLN_ExceptionLogger.captureException(e);  
    }  
  
    
    return corWarpList;  
}  
  
 

  /* MethodName      : updateBillingMethodToCash
    Description     : This method is used to fetch SchemeCodes value from pds code object or from account.
    Input Parameter : (List, String)
    Output Parameter: corWarpList
    CreatedDate     : 18-11-2024
    CreatedBy       : PwC-India
    Change log      :
    ****************************************/

@AuraEnabled  
public static void updateBillingMethodToCash(Id recordId) {  
    try {  
    case billingMethod = [SELECT Id, BLN_BillingMethod__c FROM case WHERE Id = :recordId   WITH SECURITY_ENFORCED LIMIT 1] ;  
    billingMethod.BLN_BillingMethod__c = 'Cash';  
     Database.update(new List<case> { billingMethod }, false);  
   
    } catch(Exception ex){
        BLN_ExceptionLogger.captureException(ex);
    }
} 
    
    
    
    
    //wrapper classes
    
    /* *@description: This wrapper is used for storing retrieved data from API */
    
    public class PayloadWrapper {
        public Decimal statusCode { get; set; }
        public BodyWrapper body { get; set; }
        
        public PayloadWrapper(){
            this.statusCode = null;
            this.body = new BodyWrapper();
        }
        
    }
    
   /* *@description: This wrapper is used for storing retrieved data from API */ 
    public class BodyWrapper {
        public String status { get; set; }
        public List<CorporateWrapper> data { get; set; }
        
        public BodyWrapper(){
            this.status='';
            this.data= new List<CorporateWrapper>();
        }
    }
    
    /* *@description: This wrapper is used for storing retrieved data from API */
    public class CorporateWrapper {
        @AuraEnabled
        public String vehicleRegistration { get; set; }
        @AuraEnabled
        public String operatingCompanyName { get; set; }
        @AuraEnabled
        public String operatingCompanyPostcode { get; set; }
        @AuraEnabled
        public String policyExpirationDatetime { get; set; }
        @AuraEnabled
        public String policyValidFromDatetime { get; set; }
        @AuraEnabled
        public String corporateSiteID { get; set; }
        @AuraEnabled
        public String corporateCountryGroupingID { get; set; }
        @AuraEnabled
        public String corporateLegalEntityID { get; set; }
        @AuraEnabled
        public String policyNumber { get; set; }
        @AuraEnabled
        public Decimal glassExcessAmount { get; set; }
        @AuraEnabled
        public Decimal glassLimitAmount { get; set; }
        @AuraEnabled
        public Decimal repairExcessAmount { get; set; }
        @AuraEnabled
        public Decimal repairLimitAmount { get; set; }
        @AuraEnabled
        public Decimal windscreenExcessAmount { get; set; }
        @AuraEnabled
        public Decimal bodyglassExcessAmount { get; set; }
        @AuraEnabled
        public Decimal heatedRearExcessAmount { get; set; }
        @AuraEnabled
        public Decimal adasExcessAmount { get; set; }
        @AuraEnabled
        public String insuranceSiteAccountID { get; set; }
        @AuraEnabled
        public String insuranceLegalEntityID { get; set; }
        @AuraEnabled
        public String insuranceCountryGroupingID { get; set; }
        @AuraEnabled
        public String vatPayingParty { get; set; }
        @AuraEnabled
        public String excessPayingParty { get; set; }
        @AuraEnabled
        public String policyFormat{get;set;}
        @AuraEnabled
        public String providedVehicleMake { get; set; }
        @AuraEnabled
        public String providedVehicleModel { get; set; }
        @AuraEnabled
        public String salutation { get; set; }
        @AuraEnabled
        public String firstName { get; set; }
        @AuraEnabled
        public String middleName { get; set; }
        @AuraEnabled
        public String lastName { get; set; }
        @AuraEnabled
        public String addressPostalCode { get; set; }
        @AuraEnabled
        public String policyValidationToken { get; set; }
        @AuraEnabled
        public String additionalDrivers { get; set; }
        @AuraEnabled
        public String policyTypeCode { get; set; }
        @AuraEnabled
        public String glassCoverFlag { get; set; }
        @AuraEnabled
        public String repairCoverFlag { get; set; }
        @AuraEnabled
        public String insuranceSiteID { get; set; }
        @AuraEnabled
        public String commercialFlag { get; set; }
        @AuraEnabled
        public String vatRegFlag { get; set; }
        @AuraEnabled
        public String limitIncExcess { get; set; }
        @AuraEnabled
        public string remainderPayingParty {get; set;}
        @AuraEnabled
        public string corporateSiteName { get; set; }
        @AuraEnabled
        public string corporateCountryGroupingName { get; set; }
        @AuraEnabled
        public string corporateLegalEntityName { get; set; }
        @AuraEnabled
        public string insuranceSiteAccountName { get; set; }
        @AuraEnabled
        public string insuranceLegalEntityName { get; set; }
        @AuraEnabled
        public string insuranceCountryGroupingName { get; set; }
        @AuraEnabled
        public string corporateSiteSFId { get; set; }
        @AuraEnabled
        public string corporateCountryGroupingSFId { get; set; }
        @AuraEnabled
        public string corporateLegalEntitySFId { get; set; }
        @AuraEnabled
        public string insuranceSiteAccountSFId { get; set; }
        @AuraEnabled
        public string insuranceLegalEntitySFId { get; set; }
        @AuraEnabled
        public string insuranceCountryGroupingSFId { get; set; }       
        @AuraEnabled
        public boolean attachToCase { get; set; }
        @AuraEnabled
        public Integer row { get; set; }
        @AuraEnabled
        public boolean isCorporateSelected { get; set; }
        @AuraEnabled
        public String knownAs { get; set; }
        @AuraEnabled
        public String policyConfirmation { get; set; }
        @AuraEnabled
        public String isPolicyValid { get; set; }
        @AuraEnabled
        public String origin { get; set; }
        @AuraEnabled
        public boolean corporateSiteSFNonDirectBilling { get; set; }
        @AuraEnabled
        public boolean insuraceSiteSFNonDirectBilling { get; set; }
        @AuraEnabled
        public String reference { get; set; }
        @AuraEnabled
        public Decimal policyLimit { get; set; }
        @AuraEnabled
        public String schemeCodeMapping { get; set; }
        @AuraEnabled
        public Boolean isPDSDirectCall { get; set; }
        @AuraEnabled
        public Boolean isSchemeCode { get; set; }

        

        
    }
    
    /*  *@description:This wrapper is used for sending retrieved data from api */
    public class CalloutCorporateWrapper {
        @auraEnabled
        public List<CorporateWrapper> corporateWrapList { get; set; }
        @auraEnabled
        public List<ErrorWrapper> errors { get; set; }
        
        public CalloutCorporateWrapper(){
            this.corporateWrapList= new List<CorporateWrapper>();
            this.errors = new List<ErrorWrapper>();
        }
        
    }
    
    /* *@description: This wrapper is used for storing errors received in callout */
    public class ErrorWrapper {
        @auraEnabled
        public String title { get; set; }
        @auraEnabled
        public String detail { get; set; }
        @auraEnabled
        public String insurerAPI { get; set; }
        
        public ErrorWrapper(){
            this.title='';
            this.detail='';
            this.insurerAPI='';
        }
    }
    
}