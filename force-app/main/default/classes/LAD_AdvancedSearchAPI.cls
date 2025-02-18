/** @description :  This class is used to make API callouts for the lwc lad_AdvancedSearch.
*   @Story :        FOUK-7858; FOUK-7857; FOUK-7851; FOUK-8516; FOUK-8515; FOUK-7845; FOUK-7859; FOUK-7862
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
public without sharing class LAD_AdvancedSearchAPI {

    /**@MethodName :    insertSearchRecord
    * @description :    This method is used to create Search records for all Advanced Searches.
    * @param:           String userId
    * @return:          String
    */
    @AuraEnabled
    public static string insertSearchRecord(List<Map<String, Object>> paramsList){
        try {
            Set<Id> userIdList = new Set<Id>();
            String accountId;
            for(Map<String, Object> temp : paramsList){
                if(temp.containsKey('userId')){
                    userIdList.add((Id) temp.get('userId'));
                }
                if(temp.containsKey('accountId')){
                    accountId = (String) temp.get('accountId');
                }
            }

            List<User> userList = [SELECT Id, ContactId FROM User WHERE Id = :userIdList];
            Map<Id, User> userMap = new Map<Id, User>();
            for(User u : userList){
                userMap.put(u.Id, u);
            }

            List<RecordType> recordTypeList = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'LAD_Search__c'];
            Map<String, Id> recordTypeMap = new Map<String, Id>();
            for(RecordType r : recordTypeList){
                recordTypeMap.put(r.DeveloperName, r.Id);
            }

            List<LAD_Search__c> searchInsertList = new List<LAD_Search__c>();
            for(Map<String, Object> temp : paramsList){
                LAD_Search__c newSearch = new LAD_Search__c();
                if(temp.containsKey('userId') && temp.containsKey('isInternal') && !(Boolean) temp.get('isInternal')){
                    User triggerUser = userMap.get((Id) temp.get('userId'));
                    newSearch.LAD_Account__c = accountId;
                    newSearch.LAD_Contact__c = triggerUser.ContactId;
                }
                newSearch.LAD_Date__c = Date.today();
                newSearch.RecordTypeId = recordTypeMap.get((String) temp.get('recordType'));
                searchInsertList.add(newSearch);
            }

            insert searchInsertList;
            return 'Success';

        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            return 'Error '+ e.getMessage();
        }
    }

    /**@MethodName :    VRNSearchEligibility
    * @description :    This method is used to return Account details related to VRN search eligibility.
    * @param:           string accountId
    * @return:          AccountWrapper
    */
    @AuraEnabled
    public static AccountWrapper VRNSearchEligibility(string accountId){ 
        system.debug(accountId);
        try {
            Account acc = [SELECT    id, 
                                    LAD_Not_Eligible_For_VRN_Search__c,
                                    LAD_VRN_search_monthly_usage_limit__c, 
                                    LAD_Number_of_VRN_searches_this_month__c  
                                FROM Account WHERE id =:accountId  LIMIT 1];

            system.debug(acc);
            AccountWrapper returnWrapper = new AccountWrapper();
            returnWrapper.disableVRN = acc.LAD_Not_Eligible_For_VRN_Search__c;
            returnWrapper.vrnLimit = acc.LAD_VRN_search_monthly_usage_limit__c == null ? null : (Integer) acc.LAD_VRN_search_monthly_usage_limit__c;
            returnWrapper.vrnUsage = (Integer) acc.LAD_Number_of_VRN_searches_this_month__c;
            
            return returnWrapper;
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            return null;
        }
        
    }

    public class AccountWrapper{
       
        @AuraEnabled public Boolean disableVRN {get;set;}
        @AuraEnabled public Integer vrnLimit {get;set;}
        @AuraEnabled public Integer vrnUsage {get;set;}
    }


    /**@MethodName :    VRNSearchEligibility
    * @description :    This method is used to return Account details related to VRN search eligibility.
    * @param:           String userId
    * @return:          AccountWrapper
    */
    @AuraEnabled
    public static Integer updateVrnUsage(String accountId){
        try {
            //User currentUser = [SELECT AccountId FROM User WHERE Id = :userId LIMIT 1];
            Account currentAccount = [SELECT LAD_Number_of_VRN_searches_this_month__c FROM Account WHERE Id = :accountId LIMIT 1];
            if(currentAccount.LAD_Number_of_VRN_searches_this_month__c != null ){
                currentAccount.LAD_Number_of_VRN_searches_this_month__c += 1;
            }
            else{
                currentAccount.LAD_Number_of_VRN_searches_this_month__c = 1;
            }
            update currentAccount;
            return (Integer) currentAccount.LAD_Number_of_VRN_searches_this_month__c;
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            return null;
        }
    }

    /**@MethodName :    callDVLA
    * @description :    This method is used to return the response from DVLA API.
    * @param:          String
    * @return:         List<Map<String,String>>
    */
    @AuraEnabled
    public static List<Map<String,String>> callDVLA(String inputText) 
    {
        String mvris='';
        String make='';
        String model='';
        String year='';
        String bodyType='';
        String vin='';
        List<Map<String,String>> mapList = new List<Map<String,String>>();
        map<String,String> fieldsMap = new map<String,String>();
        Map<String,String> headerMap = new Map<String,String>();
        try{
            
            // Set the Content-Type for the HTTP requests
            if(!String.isBlank(inputText)){
                
                BLN_HTTPCallOutAccessToken.WrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();
                
                // Create an another HTTP object and send a request to get the vehicle details
                String endpoint = System.label.BLN_CreditSafeReuestEndpoint+System.label.BLN_GblPath+System.label.BLN_VehicleInstancesPath+inputText;
                headerMap.put(System.label.BLN_VehicleCountryCode,System.label.BLN_VehicleCountry);
                if(wrapperToken!=null){
                    headerMap.put(System.label.BLN_HttpAuth,System.label.BLN_Bearer + ' ' + wrapperToken.accessToken);
                }
                
                HttpResponse vehicleResponse = BLN_HttpCalloutUtility.makeCallout(System.label.BLN_TargetSystemMulesoft, endpoint, System.label.BLN_GET, headerMap);
                
                if (vehicleResponse.getStatusCode() == 200) {
                    // Calling the Parser Class and passing the response body.
                    BLN_VehicleSearchParser parsed1 = BLN_VehicleSearchParser.parse(vehicleResponse.getBody()); 
                    system.debug('PARSED BODY' + parsed1);
                    fieldsMap.put(System.label.BLN_VehicleVin, parsed1.vehicleVIN);
                    fieldsMap.put(System.label.BLN_VehicleRegistrationAuthority, parsed1.vehicleRegistrationLicensingAuthority);
                    fieldsMap.put(System.label.BLN_MvrisLabel, parsed1.vehicleIdentifierTypeValue);//parsed1.vehicleIdentifierTypeCode
                    fieldsMap.put(System.label.BLN_VehicleVrnLabel, parsed1.vehicleRegistration);
                    make = parsed1.providedVehicleMake;
                    model = parsed1.providedVehicleModel;
                    bodyType = parsed1.providedVehicleBodyTypeName;
                    year = parsed1.providedVehicleModelYear;
                    mvris = parsed1.vehicleIdentifierTypeValue;//parsed1.vehicleIdentifierTypeCode
                    vin = parsed1.vehicleVIN;
                    //mapList.add(fieldsMap); 
                    
                }                 
            }
            if(!String.isBlank(mvris)){
                List<BLN_VehicleType__c> vtList = [SELECT Id, BLN_Make__c, BLN_Colour__c ,BLN_Model__c , BLN_Year__c, BLN_BodyType__c,BLN_MVRIS__c FROM BLN_VehicleType__c where BLN_MVRIS__c =: mvris WITH SECURITY_ENFORCED];
                for(BLN_VehicleType__c objvt : vtList){
                    fieldsMap.put(System.label.BLN_MakeLabel, objvt.BLN_Make__c);
                    fieldsMap.put(System.label.BLN_ModelLabel, objvt.BLN_Model__c); 
                    fieldsMap.put(System.label.BLN_VehicleBodyType, objvt.BLN_BodyType__c);
                    fieldsMap.put(System.label.BLN_YearLabel,string.valueof(objvt.BLN_Year__c));
                    fieldsMap.put(System.label.BLN_VehicleColor, objvt.BLN_Colour__c);
                    fieldsMap.put(System.label.BLN_VehicleVin, vin);
                    
                    mapList.add(fieldsMap);
                }
                
            }
            if(mapList.size() == 0){
                fieldsMap.put('Error', System.label.LAD_VehicleDetailsError);
                mapList.add(fieldsMap);
            }
            return mapList;
        } 
        catch (Exception e) {
            // Handling the exceptions and log an error message            
            BLN_ExceptionLogger.captureException(e);            
            fieldsMap.put('Error', e.getMessage());
            mapList.add(fieldsMap);
            return mapList;
        } 
    }


    /*@methodName:  callGPSSchematics
    @description :  method used to get bomId.
    @return :       method returns the Map.
    @param :        String make, String model, String bodyType, String year */
    @AuraEnabled
    public static String callGPSSchematics(String make, String model, String bodyType, String year, String vin){
        integer count = 0;
        integer row = 0;
        string bodyTypeEncoded = '';
        string modelEncoded = '';
        string makeEncoded = '';
        integer resSize;
        string responseBody = '';
        string endPoint='';
        String displayVal = '';
        String vehicleImage = '';
        String wrap = '';
        BLN_ProductParser parser = new BLN_ProductParser();
        HttpResponse response = new HttpResponse();
        Map<Integer,HoverContent[]> hcMap = new Map<Integer,HoverContent[]>();
        list<BLN_ProductParser.Schematics> shemL = new list<BLN_ProductParser.Schematics>();
        map<integer,list<BLN_ProductParser.Schematics>> scheMap = new map<integer,list<BLN_ProductParser.Schematics>>();
        list<HoverContent> hcList = new list<HoverContent>();
        Map<String,String> headerMap = new Map<String,String>();
        
        try{
           
            bodyTypeEncoded = EncodingUtil.urlEncode(bodyType, System.label.BLN_UTF);
            makeEncoded = EncodingUtil.urlEncode(make, System.label.BLN_UTF);
            modelEncoded = EncodingUtil.urlEncode(model, System.label.BLN_UTF);
            BLN_HTTPCallOutAccessToken.WrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();
            
            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_GetSchematicLable); 
            if(vin == null){
             endPoint=calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c+system.label.BLN_MakePath+ makeEncoded + system.label.BLN_ModelPath + modelEncoded+system.label.BLN_YearPath+string.valueOf(year) + system.label.BLN_ExternalRef + 'LADDAW_REFERENCE' + + system.label.BLN_BodyTypePath + bodyTypeEncoded; 
            }else{
            endPoint=calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c+system.label.BLN_MakePath+ makeEncoded + system.label.BLN_ModelPath + modelEncoded+system.label.BLN_YearPath+string.valueOf(year) + system.label.BLN_ExternalRef + 'LADDAW_REFERENCE' + system.label.BLN_Vin + vin + system.label.BLN_BodyTypePath+bodyTypeEncoded;    
            }

           // endPoint=System.label.BLN_CreditSafeRequest+System.label.BLN_GblPath+System.label.BLN_SchematicPath+System.label.BLN_MakePath+ makeEncoded +System.label.BLN_ModelPath+ modelEncoded+System.label.BLN_YearPath+string.valueOf(year)+System.label.BLN_BodyTypePath+bodyTypeEncoded;
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
            for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
            }
            
            response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,endPoint,calloutDetails.BLN_Method__c, headerMap,'','',Integer.valueof(system.label.BLN_TimeOutGPS));
            if(response != null){
                responseBody = response.getBody();
                resSize = responseBody.length();
            }

            system.debug('RESPONSE-----> '+responseBody);

            
            if(response.getStatuscode() == 200){
                parser = BLN_ProductParser.parseGPS(response.getBody());
                list<list<BLN_ProductParser.Schematics>> sLi = parser.schematics;
                vehicleImage = parser.digitalReferenceName;
                hcMap = new Map<Integer,HoverContent[]>();

                if(sLi !=null && sLi.size() > 0){
                    for(list<BLN_ProductParser.Schematics> sdl : sLi){
                        scheMap.put(row++,sdl);
                    }
                }
                for(integer i=0; i<sLi.size();i++){
                    shemL = scheMap.get(i);
                    hcList = new HoverContent[0];
                    for(BLN_ProductParser.Schematics dis : shemL){
                        HoverContent hc = new HoverContent();
                        hc.vhid = dis.vehicleHoleId!=null ? dis.vehicleHoleId : 0000;
                        hc.vType=dis.vehicleHoleTypeCode!=null ? dis.vehicleHoleTypeCode : 	System.label.BLN_TestLabel;
                        hc.displayType=dis.display!=null ? dis.display : System.label.BLN_TestLabel;
                        hc.transactionId=parser.vehicleDamage.transactionId;
                        displayVal=dis.display!=null ? dis.display : System.label.BLN_NullLabel;
                        hcList.add(hc);
                    }
                    hcMap.put(count++,hcList);
                }
            }
            else{
                return null;
            }
            WrapperList wrapListObj = New WrapperList();
            wrapListObj.hoverMap = hcMap;
            wrapListObj.vehicleImage = vehicleImage;

            wrap = JSON.serializePretty(wrapListObj);
            return wrap;

        }catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            return null;
        }

    }

    public class HoverContent{
        //vhid
        @AuraEnabled
        public Integer vhid{get;set;}
        //vtype
        @AuraEnabled
        public String vtype{get;set;}
        //displayType
        @AuraEnabled
        public String displayType{get;set;}
        //transactionId
        @AuraEnabled
        public String transactionId{get;set;}
        
    }

 /*@methodName:     callGPSbomId
    @description :  receiveBomIdFromGPS method used to get bomId.
    @return : method returns the String list.
    @param : parameter send transactionId, vehicleHoleId And recordId */
    @AuraEnabled
    public static list<List<String>> callGPSbomId(list<list<string>> listOfBom) {
        string endPoint = '';
        string bomId = '';
        list<string> tranAndHole = new list<string>();

        if(listOfBom !=null &&  listOfBom.size() > 0 && listOfBom[0]!=null){
            tranAndHole = listOfBom[0];
        }
        BLN_ProductParser parser = new BLN_ProductParser();
        Map<String, Object> requestBody= new Map<String, Object>();
        List<String> returnList = new List<String>();
        Map<String,String> headerMap = new Map<String,String>();
        list<list<string>> newReturn = new list<list<string>>();
        HttpResponse response = new HttpResponse();
        try{
            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_GetPidQuestionsLabel); 

            endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c+system.label.BLN_TransactionPath+tranAndHole[0] + system.label.BLN_HoleIdPath + tranAndHole[1];
            system.debug('receiveBomIdFromGPS EndPoint'+ endPoint);            

            BLN_HTTPCallOutAccessToken.wrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
            for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
            }
            response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,endPoint,calloutDetails.BLN_Method__c, headerMap,'','',Integer.valueof(system.label.BLN_TimeOutGPS));
            system.debug(response.getBody());
            if(response.getStatuscode() == 200){
                parser = BLN_ProductParser.parseGPS(response.getBody());

            }
            if(parser !=null && parser.vehicleDamage !=null && parser.vehicleDamage.status !=null && parser.vehicleDamage.status == System.label.BLN_ResultLabel){
               /*  if(parser.Results[0].bomId != null ){
                    bomId = string.valueof(parser.Results[0].bomId);
                }
                returnList.add(parser.vehicleDamage.status);
                returnList.add(bomId);  */
                returnList.add(parser.vehicleDamage.status);
                for(integer i = 0; i < parser.Results.size(); i++){
                    String partNumber = String.valueOf(parser.Results[i].partNumber);
                    if(!returnList.contains(partNumber)){
                        returnList.add(partNumber);
                    }
                }
                newReturn.add(returnList);                
            }else if(parser !=null && parser.vehicleDamage !=null && parser.vehicleDamage.status !=null && parser.vehicleDamage.status == System.label.BLN_QuestionLabel){
                
                returnList.add(parser.vehicleDamage.transactionId);
                returnList.add(parser.vehicleDamage.status);
                returnList.add(parser.Question.question);
                newReturn.add(returnList); 

            }
            return newReturn;

        }catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            return null;
        }
    }


    /*@methodName:  callGPSanswer
    @description :  method used to get Question or bomId.
    @return : method returns the String list.
    @param : parameter send ans, transId  */
    @AuraEnabled 
    public static List<String> callGPSanswer(string ans, string transId){
        BLN_ProductParser parser = new BLN_ProductParser(); 
        HttpResponse response = new HttpResponse();
        List<String> returnList = new List<String>();
        Map<String,String> headerMap = new Map<String,String>();
        string endPoint='';
        string bomId = '';
        BLN_HTTPCallOutAccessToken.wrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();
        try{        
            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_GetPidQuestionsLabel); 
              
            endPoint=calloutDetails.BLN_NamedCredential__c+calloutDetails.BLN_CalloutURL__c+system.label.BLN_TransactionPath+transId+system.label.BLN_AnswerPath+ans;
            system.debug('getAnswerFromGPS EndPoint'+ endPoint);
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
            for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
            }
            response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,endPoint,calloutDetails.BLN_Method__c, headerMap,'','',Integer.valueof(system.label.BLN_TimeOutGPS));
            if(response.getStatusCode()== 200){
                parser = BLN_ProductParser.parseGPS(response.getBody());
                if(parser !=null && parser.vehicleDamage !=null && parser.vehicleDamage.status !=null) {       
                returnList.add(parser.VehicleDamage.status);
                }
            }

            if(parser !=null && parser.vehicleDamage !=null && parser.VehicleDamage.transactionId !=null && parser.vehicleDamage.status !=null && parser.vehicleDamage.status == System.label.BLN_QuestionLabel){
                returnList.add(parser.VehicleDamage.transactionId);
                returnList.add(parser.Question.question);
            }
            else if(parser.vehicleDamage.status == System.label.BLN_ResultLabel){
                for(integer i = 0; i < parser.Results.size(); i++){
                    String partNumber = String.valueOf(parser.Results[i].partNumber);
                    if(!returnList.contains(partNumber)){
                        returnList.add(partNumber);
                    }
                }
            }
            return returnList;

        }catch(exception e){
                BLN_ExceptionLogger.captureException(e);
                return null;

        }
    }
    

    
    public class WrapperList{
       
        @AuraEnabled
        public  map<Integer,HoverContent[]> hoverMap{get;set;}

        @AuraEnabled
        public String vehicleImage{get;set;}
    }
}