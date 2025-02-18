/*****************************************
ClassName : BLN_MelissaApiAddressService
Description : FOUK-684 This controller class is used in lwc.
CreatedDate: 26-10-2023
CreatedBy : PwC-India
****************************************/
/*@description : This method is used to return the response from Melissa API.*/
public with sharing class BLN_MelissaApiAddressService{
    /*****************************************
MethodName : searchAddress
Description : This method is used to return the response from Melissa API.
Input Parameter : String
Output Parameter : List<object>
CreatedDate: 26-10-2023
CreatedBy : Pwc-India
Change log :
****************************************/
    
    @AuraEnabled
    public static List<object> searchAddress(String inputText){
        try {
            
            // Set the Content-Type for the HTTP requests
            //HttpRequest addressRequest = new HttpRequest();
            HttpResponse addressResponse = new HttpResponse();
            String endpoint = '';
            String country ='';
            string encoded = '';
            // Create another HTTP object for the address request
            Map<String,String> headerMap = new Map<String,String>();
            Map<String, Object> addressResponseMap = new Map<String, Object>();
            List<Object> addresses = new List<Object>();
            User currentUser = new user();
            encoded = EncodingUtil.urlEncode(inputText, System.label.BLN_UTF);
            if(UserInfo.getUserId() != null){
            // Query the current user
            currentUser = [SELECT Id, Country, Username FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED ];
            }
            if(currentUser.Country != null){
            country = currentUser.Country;
            }
            
            if(string.isBlank(country) || country == null){
                country = System.label.BLN_CountryValue;
            }
            // Create an HTTP object and send a request to get an access token
            BLN_HTTPCallOutAccessToken.WrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();

            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_GetMellisaApiLabel);
            // Construct the address request URL
            endpoint  =calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c + encoded+System.label.BLN_RecAndCountry+country;
            
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+wrapperToken.accessToken);
            
            addressResponse = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,endpoint,calloutDetails.BLN_Method__c,headerMap,Integer.valueOf(calloutDetails.BLN_APITimeout__c));
               if(addressResponse != null){
                    // Deserialize the JSON response to get the list of addresses
                    addressResponseMap = (Map<String, Object>) JSON.deserializeUntyped(addressResponse.getBody());
                }
                addresses = (List<Object>) addressResponseMap.get(System.label.BLN_AddressMelissa);
                
                // Return the list of addresses
                return addresses;
        } catch (Exception e) {
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);
            return new List<Object>(); 
        }
    }
    /*****************************************
MethodName : updateAddress
Description : This method is used to update Address in person account.
Input Parameter : String, Id
Output Parameter : void
CreatedDate: 26-10-2023
CreatedBy : Pwc-India
Change log :
****************************************/
 /*@description : updateAddress method used to update Address in person account
   @return : method returns the String
   @param : parameter send String And Id */
   
    public static string updateAddress(String addressMap, string recordId){
        return updateAddress(addressMap, recordId, null, false ,null);
    }
    
    @AuraEnabled
    public static string updateAddress(String addressMap, string recordId, String caseId, Boolean updateBilling, String caseBillingMethod){
        double newLat = null;
        Map<String,String> accMap = new Map<String,String>();
        List<Object> addressRes =  new List<Object>();
        Map<String,Object> addressParam = new Map<String,Object>();
        Account acc = new Account();
        Case cse = new Case();
        addressRes = (List<Object>)JSON.deserializeUntyped(addressMap);
        
        try{
            if(recordId != null){
            acc =[SELECT Id, PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry,
                          PersonOtherStreet, PersonOtherCity, PersonOtherState, PersonOtherPostalCode, PersonOtherCountry, PersonMailingLatitude, PersonMailingLongitude, PersonOtherLatitude, PersonOtherLongitude , BLN_HomeCountryCode__c , BLN_OtherCountryCode__c,Salutation,FirstName,LastName FROM Account where id =: recordId WITH SECURITY_ENFORCED ];
            }
            for(Object obj : addressRes){
                addressParam = (Map<String,Object>)obj;
                accMap.put((String)addressParam.get(System.label.BLN_MelissaKey),(String)addressParam.get(System.label.BLN_MelissaValue));
            }
            
            if(String.isNotBlank(accMap.get(System.label.BLN_homeStreetValue)) || accMap.get(System.label.BLN_homeStreetValue) == ''){
                acc.PersonMailingStreet = accMap.get(System.label.BLN_homeStreetValue);
            }
            
            if(String.isNotBlank(accMap.get(System.label.BLN_homeTownValue)) || accMap.get(System.label.BLN_homeTownValue) == ''){
                acc.PersonMailingCity = accMap.get(System.label.BLN_homeTownValue);
            } 
            if(String.isNotBlank(accMap.get(System.label.BLN_homeCountyValue)) || accMap.get(System.label.BLN_homeCountyValue) == ''){
                acc.PersonMailingState = accMap.get(System.label.BLN_homeCountyValue); 
            } 
            if(String.isNotBlank(accMap.get(System.label.BLN_homeCountryValue)) || accMap.get(System.label.BLN_homeCountryValue) == ''){
                acc.PersonMailingCountry = accMap.get(System.label.BLN_homeCountryValue);
            } 
            if(String.isNotBlank(accMap.get(System.label.BLN_homePostCodeValue)) || accMap.get(System.label.BLN_homePostCodeValue) == ''){
                acc.PersonMailingPostalCode = accMap.get(System.label.BLN_homePostCodeValue);
            } 
            if(String.isNotBlank(accMap.get(System.label.BLN_HomeCountryCode)) || accMap.get(System.label.BLN_HomeCountryCode) == ''){
                acc.BLN_HomeCountryCode__c = accMap.get(System.label.BLN_HomeCountryCode);
            } 
            
            if(caseId != null){
                cse = [SELECT Id, BLN_BillingStreet__c, BLN_BillingTown__c, BLN_BillingCountry__c, BLN_BillingCounty__c, BLN_BillingPostCode__c,BLN_BillingMethod__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
            }

            if(updateBilling == true && caseBillingMethod == System.label.BLN_CashValue)
             {
                
                if(String.isNotBlank(accMap.get(System.label.BLN_homeStreetValue)) || accMap.get(System.label.BLN_homeStreetValue) == ''){
                    cse.BLN_BillingStreet__c = accMap.get(System.label.BLN_homeStreetValue);
                }
                
                if(String.isNotBlank(accMap.get(System.label.BLN_homeTownValue)) || accMap.get(System.label.BLN_homeTownValue) == ''){
                    cse.BLN_BillingTown__c = accMap.get(System.label.BLN_homeTownValue);
                } 
                if(String.isNotBlank(accMap.get(System.label.BLN_homeCountyValue)) || accMap.get(System.label.BLN_homeCountyValue) == ''){
                    cse.BLN_BillingCounty__c = accMap.get(System.label.BLN_homeCountyValue); 
                } 
                if(String.isNotBlank(accMap.get(System.label.BLN_homeCountryValue)) || accMap.get(System.label.BLN_homeCountryValue) == ''){
                    cse.BLN_BillingCountry__c = accMap.get(System.label.BLN_homeCountryValue);
                } 
                if(String.isNotBlank(accMap.get(System.label.BLN_homePostCodeValue)) || accMap.get(System.label.BLN_homePostCodeValue) == ''){
                    cse.BLN_BillingPostCode__c = accMap.get(System.label.BLN_homePostCodeValue);
                } 
                if(String.isNotBlank(acc.FirstName) || String.isNotBlank(acc.LastName)){
                    cse.BLN_BillingName__c = acc.Salutation+''+acc.FirstName+''+acc.LastName;
                }

                if(Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable() && caseId!=null){
                update cse;
                }
            }

            if(updateBilling == true && caseBillingMethod != System.label.BLN_CashValue){
                if(String.isNotBlank(acc.FirstName) || String.isNotBlank(acc.LastName)){
                    cse.BLN_BillingName__c = acc.Salutation+''+acc.FirstName+''+acc.LastName;
                }

                if(Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable() && caseId!=null){
                update cse;
                }
            }

            //Other address fields
            if(String.isNotBlank(accMap.get(System.label.BLN_otherStreetValue)) || accMap.get(System.label.BLN_otherStreetValue) == '' ){
                acc.PersonOtherStreet = accMap.get(System.label.BLN_otherStreetValue);
            }
            
            if(String.isNotBlank(accMap.get(System.label.BLN_otherTownValue)) || accMap.get(System.label.BLN_otherTownValue) == '' ){
                acc.PersonOtherCity = accMap.get(System.label.BLN_otherTownValue);
            } 
            if(String.isNotBlank(accMap.get(System.label.BLN_otherCountyValue)) || accMap.get(System.label.BLN_otherCountyValue) == ''){
                acc.PersonOtherState = accMap.get(System.label.BLN_otherCountyValue);
            } 
            if(String.isNotBlank(accMap.get(System.label.BLN_otherCountryValue)) || accMap.get(System.label.BLN_otherCountryValue) == ''){
                acc.PersonOtherCountry = accMap.get(System.label.BLN_otherCountryValue);
            } 
            if(String.isNotBlank(accMap.get(System.label.BLN_otherPostCodeValue)) || accMap.get(System.label.BLN_otherPostCodeValue) == ''){
                acc.PersonOtherPostalCode = accMap.get(System.label.BLN_otherPostCodeValue);
            } 
            if(String.isNotBlank(accMap.get(System.label.BLN_OtherCountryCode)) || accMap.get(System.label.BLN_OtherCountryCode) == ''){
                acc.BLN_OtherCountryCode__c = accMap.get(System.label.BLN_OtherCountryCode);
            } 
            
            
            
            if(accMap.get(System.label.BLN_changedHomePostCodeValue) == System.label.BLN_TrueInQuotes){
                acc.PersonMailingLatitude = null;acc.PersonMailingLongitude = null;
            }
            else{
                if(accMap.containsKey(System.label.BLN_homeLatitudeValue)){
                    if(accMap.get(System.label.BLN_homeLatitudeValue) == '' || accMap.get(System.label.BLN_homeLatitudeValue) == null){
                        acc.PersonMailingLatitude = newLat;
                    }else{
                        acc.PersonMailingLatitude = double.valueof(accMap.get(System.label.BLN_homeLatitudeValue));
                    }
                }
                if(accMap.containsKey(System.label.BLN_homeLongitudeValue)){
                    if(accMap.get(System.label.BLN_homeLongitudeValue) == '' || accMap.get(System.label.BLN_homeLongitudeValue) == null){
                        
                        acc.PersonMailingLongitude = newLat;
                    }else{
                        acc.PersonMailingLongitude = double.valueof(accMap.get(System.label.BLN_homeLongitudeValue));
                    }
                }
                
            }
            if(accMap.get(System.label.BLN_changedOtherPostCodeValue) == System.label.BLN_TrueInQuotes){
                acc.PersonOtherLatitude = null; acc.PersonOtherLongitude = null;
                
            }else{
                if(accMap.containskey(System.label.BLN_otherLatitudeValue)){
                    if(accMap.get(System.label.BLN_otherLatitudeValue) == '' || accMap.get(System.label.BLN_otherLatitudeValue) == null){
                        acc.PersonOtherLatitude = newLat;
                    }else{
                        acc.PersonOtherLatitude =  double.valueof(accMap.get(System.label.BLN_otherLatitudeValue));
                    }
                }
                if(accMap.containskey(System.label.BLN_otherLongitudeValue)){
                    if(accMap.get(System.label.BLN_otherLongitudeValue) == '' || accMap.get(System.label.BLN_otherLongitudeValue) == null){
                        
                        acc.PersonOtherLongitude = newLat;
                    }else{
                        acc.PersonOtherLongitude =  double.valueof(accMap.get(System.label.BLN_otherLongitudeValue));
                    }
                }
            }
            
            if(Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
                update acc;
                }
           
            return string.valueof(acc.id);
        }
        catch (Exception e) {
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);
            return string.valueof(e);
        } 
    }
}