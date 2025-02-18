/** @description : This controller class is used in lwc.
*   @Story : FOUK-3149 and FOUK-1009
*   @author: PwC-India
*   @CreatedDate: 03-11-2023
*/
Public with sharing class BLN_VehicleSearchAPI {
    

    @auraEnabled
    public static List<BLN_VehicleType__c> returnMDMId(string make, string model, string bodyType ){        
        List<BLN_VehicleType__c> vtListYear = new List<BLN_VehicleType__c>();
        try{                    
            
            if(!String.isBlank(make) && !String.isBlank(model) && !String.isBlank(bodyType) ){
                vtListYear = [select id, BLN_Year__c, BLN_MVRIS__c,BLN_MDMExternalID__c, BLN_Make__c,BLN_Model__c,BLN_BodyType__c from BLN_VehicleType__c where  BLN_Make__c =: make AND BLN_Model__c =: model AND BLN_BodyType__c =: bodyType WITH SECURITY_ENFORCED LIMIT 50000]; //BLN_Year__c =: integer.valueof(year) AND  
            } 
        }
        catch(exception e){            
            BLN_ExceptionLogger.captureException(e);
            vtListYear = null; 
        }
        return vtListYear;
    }
    
/**@MethodName : searchVRN
* @description : This method is used to return the response from DVLA API.
* @param : String
* @return : List<Map<String,String>>
* @createdDate: 03-11-2023
* @createdBy: Pwc-India
*/
    @AuraEnabled
    public static List<Map<String,String>> searchVRN(String inputText, String recordId) 
    {
        String mvris='';
        String make='';
        String model='';
        String year='';
        String bodyType='';
        String vin='';
        String vrnDvla = '';
        List<Map<String,String>> mapList = new List<Map<String,String>>();
        map<String,String> fieldsMap = new map<String,String>();
        Map<String,String> headerMap = new Map<String,String>();
        try{
            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_GetVehicleSearchLabel); 
            // Set the Content-Type for the HTTP requests
            if(!String.isBlank(inputText)){
                
                BLN_HTTPCallOutAccessToken.WrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();
                
                // Create an another HTTP object and send a request to get the vehicle details
                String endpoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c+inputText;
              //  system.debug('VehicleApiendiPoint'+ endpoint);
               // headerMap.put(System.label.BLN_VehicleCountryCode,System.label.BLN_VehicleCountry);
                for(String str :  calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                    headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
                }

                if(wrapperToken!=null){
                    headerMap.put(System.label.BLN_HttpAuth,System.label.BLN_Bearer + ' ' + wrapperToken.accessToken);
                }
               // system.debug('VehicleApi headerMap'+ headerMap);
             
                HttpResponse vehicleResponse = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c, endpoint, calloutDetails.BLN_Method__c, headerMap, recordId,Integer.valueOf(calloutDetails.BLN_APITimeout__c));
               // system.debug('VehicleApi Response'+ vehicleResponse.getBody());
                if (vehicleResponse.getStatusCode() == 200) {
                    // Calling the Parser Class and passing the response body.
                    BLN_VehicleSearchParser parsed1 = BLN_VehicleSearchParser.parse(vehicleResponse.getBody()); 
                    vrnDvla = parsed1.vehicleRegistration != null ? parsed1.vehicleRegistration : '';
                    fieldsMap.put(System.label.BLN_VehicleVin, parsed1.vehicleVIN);
                    fieldsMap.put(System.label.BLN_VehicleRegistrationAuthority, parsed1.vehicleRegistrationLicensingAuthority);
                    fieldsMap.put(System.label.BLN_MvrisLabel, parsed1.vehicleIdentifierTypeValue);//parsed1.vehicleIdentifierTypeCode
                    fieldsMap.put(System.label.BLN_VehicleVrnLabel, vrnDvla);
                    fieldsMap.put(System.label.BLN_VehicleColor, parsed1.providedVehicleColour);
                    fieldsMap.put(System.label.BLN_YearLabel,parsed1.providedVehicleModelYear); //Change Under FOUK- 12474
                    make = parsed1.providedVehicleMake;
                    model = parsed1.providedVehicleModel;
                    bodyType = parsed1.providedVehicleBodyTypeName;
                    year = parsed1.providedVehicleModelYear;
                    mvris = parsed1.vehicleIdentifierTypeValue;//parsed1.vehicleIdentifierTypeCode;
                    vin = parsed1.vehicleVIN;
                    mapList.add(fieldsMap); 
                    
                }                 
            }
            if(!String.isBlank(mvris)){
                List<BLN_VehicleType__c> vtList = [SELECT Id, BLN_Make__c, BLN_Colour__c ,BLN_Model__c, BLN_SpecialVehicle__c ,BLN_VehicleNote__c,BLN_AvailableStartDate__c,BLN_AvailableEndDate__c, BLN_Year__c, BLN_BodyType__c,BLN_MDMExternalID__c,BLN_IsVehicleCalibrationRequired__c,BLN_MVRIS__c FROM BLN_VehicleType__c where BLN_MVRIS__c =: mvris WITH SECURITY_ENFORCED];
                for(BLN_VehicleType__c objvt : vtList){
                    Map<String,String> vehicleTypeMap = new Map<String,String>();
                    vehicleTypeMap.put(System.label.BLN_VehicleExternalIdLabel, objvt.BLN_MDMExternalID__c);
                    vehicleTypeMap.put(System.label.BLN_MakeLabel, objvt.BLN_Make__c);
                    vehicleTypeMap.put(System.label.BLN_ModelLabel, objvt.BLN_Model__c); 
                    vehicleTypeMap.put(System.label.BLN_VehicleBodyType, objvt.BLN_BodyType__c);
                  //  vehicleTypeMap.put(System.label.BLN_YearLabel,string.valueof(objvt.BLN_Year__c));
                   // vehicleTypeMap.put(System.label.BLN_VehicleColor, objvt.BLN_Colour__c);
                    vehicleTypeMap.put(System.label.BLN_VehicleSpecial, String.valueof(objvt.BLN_SpecialVehicle__c));  
                    vehicleTypeMap.put(System.label.BLN_IsVehicleCalibrationLabel, String.valueof(objvt.BLN_IsVehicleCalibrationRequired__c)); 
                    vehicleTypeMap.put(System.label.BLN_AvailableStartDate, String.valueof(objvt.BLN_AvailableStartDate__c));
                    vehicleTypeMap.put(System.label.BLN_AvailableEndDate, String.valueof(objvt.BLN_AvailableEndDate__c));
                    vehicleTypeMap.put(System.label.BLN_VehicleNote, String.valueof(objvt.BLN_VehicleNote__c));
                  
                    mapList.add(vehicleTypeMap);
                }
            }
            else{
                If(!String.isBlank(make) && !String.isBlank(model) && !String.isBlank(year)){
                    List<BLN_VehicleType__c> vtListelse= new List<BLN_VehicleType__c> ();
                    vtListelse = [SELECT Id, BLN_Make__c, BLN_Model__c, BLN_Year__c, BLN_Colour__c ,BLN_BodyType__c, 
                                  BLN_MVRIS__c,BLN_SpecialVehicle__c,BLN_AvailableEndDate__c,BLN_AvailableStartDate__c, BLN_VehicleNote__c,BLN_MDMExternalID__c FROM BLN_VehicleType__c where BLN_Make__c =: make AND BLN_Model__c =: model AND BLN_Year__c =: integer.valueOf(year) WITH SECURITY_ENFORCED];
                    
                    for(BLN_VehicleType__c objvt : vtListelse){
                        Map<String,String> vehicleTypeMap = new Map<String,String>();
                        vehicleTypeMap.put(System.label.BLN_VehicleExternalIdLabel, objvt.BLN_MDMExternalID__c);
                        vehicleTypeMap.put(System.label.BLN_MakeLabel,objvt.BLN_Make__c);
                        vehicleTypeMap.put(System.label.BLN_ModelLabel,objvt.BLN_Model__c); 
                        vehicleTypeMap.put(System.label.BLN_VehicleBodyType,objvt.BLN_BodyType__c);
                       // vehicleTypeMap.put(System.label.BLN_YearLabel,string.valueof(objvt.BLN_Year__c));
                       // vehicleTypeMap.put(System.label.BLN_VehicleColor,objvt.BLN_Colour__c);
                        vehicleTypeMap.put(System.label.BLN_VehicleSpecial,String.valueof(objvt.BLN_SpecialVehicle__c)); 
                        vehicleTypeMap.put(System.label.BLN_AvailableStartDate, String.valueof(objvt.BLN_AvailableStartDate__c));
                        vehicleTypeMap.put(System.label.BLN_AvailableEndDate, String.valueof(objvt.BLN_AvailableEndDate__c));
                        vehicleTypeMap.put(System.label.BLN_VehicleNote, String.valueof(objvt.BLN_VehicleNote__c));
                      
                        mapList.add(vehicleTypeMap);
                    }
                }
            } 
        } 
        catch (Exception e) {
            // Handling the exceptions and log an error message            
            BLN_ExceptionLogger.captureException(e);
            mapList = null;
        }
        return mapList;
    }
    /**@MethodName : returnMake
* @description : This method is used to return Vehicle Types.
* @param : String
* @return : List<BLN_VehicleType__c>
* @createdDate: 03-11-2023
* @createdBy: Pwc-India
*/
    @auraEnabled(Cacheable=true)
    public static List<BLN_VehicleType__c> returnMake(string make, Boolean isMakeSearch){
        list<BLN_VehicleType__c> vtListMake= new list<BLN_VehicleType__c> ();
        try{
            If(isMakeSearch == false){
                vtListMake = [select id, BLN_Make__c,BLN_Model__c,BLN_Colour__c,BLN_SpecialVehicle__c, BLN_MVRIS__c from BLN_VehicleType__c  WITH SECURITY_ENFORCED ORDER BY BLN_Make__c ASC LIMIT 50000]; //where BLN_Make__c like: make + System.label.BLN_PercentageLabel
            } 

            If(!String.isBlank(make) && isMakeSearch == true){
                vtListMake = [select id, BLN_Make__c,BLN_Model__c,BLN_Colour__c,BLN_SpecialVehicle__c, BLN_MVRIS__c from BLN_VehicleType__c where BLN_Make__c like: make + System.label.BLN_PercentageLabel WITH SECURITY_ENFORCED ORDER BY BLN_Make__c ASC LIMIT 50000]; //where BLN_Make__c like: make + System.label.BLN_PercentageLabel
            }      
        }
        catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            vtListMake = null; 
        }
        return vtListMake;
    }
    /**@MethodName : returnMake
* @description : This method is used to return Vehicle Types.
* @param : String
* @return : List<BLN_VehicleType__c>
* @createdDate: 03-11-2023
* @createdBy: Pwc-India
*/
    @auraEnabled
    public static List<BLN_VehicleType__c> returnModel(string make, string model, Boolean isModelSearch){
        list<BLN_VehicleType__c> vtListModel= new list<BLN_VehicleType__c>(); 
        try{            
            If(!String.isBlank(make) && isModelSearch == false){ //&& !String.isBlank(model)
                vtListModel = [select id, BLN_Model__c, BLN_MVRIS__c from BLN_VehicleType__c where BLN_Make__c =: make  WITH SECURITY_ENFORCED ORDER BY BLN_Model__c ASC LIMIT 50000]; //AND BLN_Model__c like: model+ System.label.BLN_PercentageLabel
            }    
            
            If(!String.isBlank(make) && !String.isBlank(model) && isModelSearch == true){ //&& !String.isBlank(model)
                vtListModel = [select id, BLN_Model__c, BLN_MVRIS__c from BLN_VehicleType__c where BLN_Make__c =: make AND BLN_Model__c like: model+ System.label.BLN_PercentageLabel  WITH SECURITY_ENFORCED ORDER BY BLN_Model__c ASC LIMIT 50000]; //
            }  
        }
        catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            vtListModel = null; 
        }
        return vtListModel;
    }
    /**@MethodName : returnBodyType
* @description : This method is used to return Vehicle Types.
* @param : Strings
* @return : List<BLN_VehicleType__c>
* @createdDate: 03-11-2023
* @createdBy: Pwc-India
*/
    @auraEnabled
    public static List<BLN_VehicleType__c> returnBodyType(string make, string model , string body, Boolean isBodySearch){ 
        list<BLN_VehicleType__c> vtListBody = new list<BLN_VehicleType__c> ();
        try{
            if(!String.isBlank(make) && !String.isBlank(body) && !String.isBlank(model) &&isBodySearch == true){
                vtListBody = [select id, BLN_BodyType__c,BLN_Model__c, BLN_MVRIS__c from BLN_VehicleType__c where BLN_Make__c =: make AND BLN_Model__c =: model AND BLN_BodyType__c like: body+ System.label.BLN_PercentageLabel  WITH SECURITY_ENFORCED ORDER BY BLN_BodyType__c ASC LIMIT 50000];//AND BLN_BodyType__c like: body+ System.label.BLN_PercentageLabel
            }
            
            if( !String.isBlank(make) && !String.isBlank(model)  && isBodySearch == false){
                vtListBody = [select id, BLN_BodyType__c,BLN_Model__c, BLN_MVRIS__c from BLN_VehicleType__c where BLN_Make__c =: make AND BLN_Model__c =: model  WITH SECURITY_ENFORCED ORDER BY BLN_BodyType__c ASC LIMIT 50000];//AND BLN_BodyType__c like: body+ System.label.BLN_PercentageLabel
            }     
        }
        catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            vtListBody = null; 
        }
        return vtListBody;
    }
    
    /*****************************************
MethodName : returnVehicle
@description : This method is used to return Vehicle Records.
@param : Strings
@return : List<BLN_Vehicle__c>
CreatedDate: 14-12-2023
CreatedBy : Pwc-India
Change log :
****************************************/
    @auraEnabled
    public static List<BLN_Vehicle__c> returnVehicle(string vehicleId){ 
        list<BLN_Vehicle__c> vehicleList= new list<BLN_Vehicle__c>();
        try{
            if(!String.isBlank(vehicleId)){
                vehicleList = [SELECT Id, BLN_SpecialVehicle__c, BLN_MVRIS__c, BLN_VIN__c, BLN_Year__c, BLN_Mileage__c, 
                               BLN_SpecialTypes__c, BLN_BodyType__c, BLN_Colour__c, BLN_RegistrationAuthority__c, 
                               BLN_VehicleType__c, BLN_MakeOfVehicle__c, BLN_VehicleDetails__c, BLN_ModelOfVehicle__c, 
                               BLN_VehicleRegNumber__c, BLN_MDMID__c,BLN_VehicleNote__c, BLN_IsVehicleCalibrationRequired__c FROM BLN_Vehicle__c WHERE Id =: vehicleId WITH SECURITY_ENFORCED];
            }
        }
        catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            vehicleList = null; 
        }
        return vehicleList;
    }
    
    /*****************************************
MethodName : returnYear
@description : This method is used to return Vehicle Types.
@param : String
@return : List<BLN_VehicleType__c>
CreatedDate: 03-11-2023
CreatedBy : Pwc-India
Change log :
****************************************/
    @auraEnabled
    public static List<BLN_VehicleType__c> returnYear(string make, string model, string bodyType, string year , Boolean isYearSearch){        
        List<BLN_VehicleType__c> vtListYear = new List<BLN_VehicleType__c>();
        try{                    
            if(!String.isBlank(make) && !String.isBlank(model) && !String.isBlank(bodyType) && isYearSearch == false){
                vtListYear = [select id, BLN_Year__c, BLN_MVRIS__c, BLN_SpecialVehicle__c,BLN_Colour__c,BLN_AvailableEndDate__c,BLN_AvailableStartDate__c,BLN_VehicleNote__c from BLN_VehicleType__c where  BLN_Make__c =: make AND BLN_Model__c =: model AND BLN_BodyType__c =: bodyType WITH SECURITY_ENFORCED ORDER BY BLN_AvailableStartDate__c ASC LIMIT 50000]; //BLN_Year__c =: integer.valueof(year) AND ORDER BY BLN_AvailableStartDate__c ASC  
            } //&& !String.isBlank(year)    
            if(!String.isBlank(make) && !String.isBlank(model) && !String.isBlank(bodyType) && !String.isBlank(year) && isYearSearch == true){
                vtListYear = [select id, BLN_Year__c, BLN_MVRIS__c, BLN_SpecialVehicle__c,BLN_Colour__c,BLN_AvailableEndDate__c,BLN_AvailableStartDate__c,BLN_VehicleNote__c from BLN_VehicleType__c where  BLN_Make__c =: make AND BLN_Model__c =: model AND BLN_BodyType__c =: bodyType AND  CALENDAR_YEAR(BLN_AvailableStartDate__c) =: Integer.valueOf(year)  WITH SECURITY_ENFORCED ORDER BY BLN_AvailableStartDate__c ASC LIMIT 50000]; //BLN_Year__c =: integer.valueof(year) AND ORDER BY BLN_AvailableStartDate__c ASC 
            } 
        }
        catch(exception e){            
            BLN_ExceptionLogger.captureException(e);
            vtListYear = null; 
        }
        return vtListYear;
    }
    /*****************************************
MethodName : returnColor
@description : This method is used to return Vehicle Types.
@param : String
@return : List<BLN_VehicleType__c>
CreatedDate: 03-11-2023
CreatedBy : Pwc-India
Change log :
****************************************/
    @auraEnabled
    public static List<BLN_VehicleType__c> returnColor(string make, string model, string bodyType){
      
        list<BLN_VehicleType__c> vtListColor = new list<BLN_VehicleType__c>(); 
        try{            
       
            
            if(!String.isBlank(make) && !String.isBlank(model) && !String.isBlank(bodyType)){ 
                vtListColor = [select id, BLN_Year__c, BLN_MVRIS__c, BLN_SpecialVehicle__c,BLN_Colour__c from BLN_VehicleType__c where  BLN_Make__c =:make AND BLN_Model__c =: model AND BLN_BodyType__c =:bodyType WITH SECURITY_ENFORCED];//BLN_Colour__c LIKE: colour+'%'  AND
                
            }// && !String.isBlank(colour)
        }
        catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            vtListColor = null; 
        }
        return vtListColor;
    }
    /*****************************************
MethodName : returnSpecialVehicle
@description : This method is used to return Vehicle Types.
@param : String
@return : List<BLN_VehicleType__c>
CreatedDate: 03-11-2023
CreatedBy : Pwc-India
Change log :
****************************************/
    @auraEnabled
    public static List<BLN_VehicleType__c> returnSpecialVehicle(string specialVData){
        
        String make='';
        String model='';
        String bodyType='';
        String year='';
        list<BLN_VehicleType__c> vtListSpecial = new list<BLN_VehicleType__c>();
        try{
            
            Map<String,String> specialMap = new Map<String,String>();
            List<Object> specialRes =  (List<Object>)JSON.deserializeUntyped(specialVData);
            
            for(Object obj : specialRes){
                Map<String,Object> specialParam = (Map<String,Object>)obj;
                specialMap.put((String)specialParam.get(System.label.BLN_MelissaKey),(String)specialParam.get(System.label.BLN_MelissaValue));
            }
            
            if(String.isNotBlank(specialMap.get(System.label.BLN_MakeLabel)) || specialMap.get(System.label.BLN_MakeLabel) == ''){
                make = specialMap.get(System.label.BLN_MakeLabel);
            }
            
            if(String.isNotBlank(specialMap.get(System.label.BLN_ModelLabel)) || specialMap.get(System.label.BLN_ModelLabel) == ''){
                model = specialMap.get(System.label.BLN_ModelLabel);
            }
            
            if(String.isNotBlank(specialMap.get(System.label.BLN_VehicleBodyType)) || specialMap.get(System.label.BLN_VehicleBodyType) == ''){
                bodyType = specialMap.get(System.label.BLN_VehicleBodyType);
            }
            
            if(String.isNotBlank(specialMap.get(System.label.BLN_YearLabel)) || specialMap.get(System.label.BLN_YearLabel) == ''){
                year = specialMap.get(System.label.BLN_YearLabel);
            }    
            if(!String.isBlank(make) && !String.isBlank(model) && !String.isBlank(bodyType)  && !String.isBlank(year)){
                vtListSpecial = [select id,BLN_SpecialVehicle__c,BLN_Colour__c,BLN_Year__c from BLN_VehicleType__c where BLN_BodyType__c =: bodyType AND BLN_Model__c =: model AND BLN_Make__c =: make AND BLN_Year__c =: integer.valueOf(year) WITH SECURITY_ENFORCED];    
            }
            return vtListSpecial;
        }
        catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            vtListSpecial = null; 
        }
        return vtListSpecial;
    }
    /*****************************************
MethodName : insertVehicle
@description : This method is used to return Vehicle Types.
@param : Strings
@return : String
CreatedDate: 03-11-2023
CreatedBy : Pwc-India
Change log :
****************************************/
    @auraEnabled
    Public Static String insertVehicle(String vehicleData, String recordId){
        String retValue = ''; 
        try{
            map<string,string> vehicleMap = new map<string,string>();
            case cases =new Case();
            list<object> vehicleList = (list<object>)json.deserializeuntyped(vehicleData);
            for(object obj : vehicleList){
                map<string,object> vehicleParam = (map<string,object>)obj;
                vehicleMap.put((string)vehicleParam.get(System.label.BLN_MelissaKey),(string)vehicleParam.get(System.label.BLN_MelissaValue));
            }
            if(!string.isBlank(recordId)){    
                cases = [SELECT Id, BLN_Vehicle__c FROM Case where Id =: recordId WITH SECURITY_ENFORCED];
            }
            if(string.isBlank(cases.BLN_Vehicle__c)){
                BLN_Vehicle__c vehicles = new BLN_Vehicle__c();
                vehicles.BLN_MakeOfVehicle__c = (!string.isBlank(vehicleMap.get(System.label.BLN_MakeLabel)))?vehicleMap.get(System.label.BLN_MakeLabel) : '';
                vehicles.BLN_ModelOfVehicle__c = (!string.isBlank(vehicleMap.get(System.label.BLN_ModelLabel)))?vehicleMap.get(System.label.BLN_ModelLabel) : '';
                vehicles.BLN_BodyType__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleBodyType)))?vehicleMap.get(System.label.BLN_VehicleBodyType) : '';
                vehicles.BLN_Colour__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleColor)))?vehicleMap.get(System.label.BLN_VehicleColor) : '';
                vehicles.BLN_VehicleRegNumber__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleVrnLabel)))?vehicleMap.get(System.label.BLN_VehicleVrnLabel) : '';
                vehicles.BLN_VIN__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleVinLabel)))?vehicleMap.get(System.label.BLN_VehicleVinLabel) : '';
                vehicles.BLN_MVRIS__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleMvrisLabel)))?vehicleMap.get(System.label.BLN_VehicleMvrisLabel) : '';
                vehicles.BLN_SpecialTypes__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleSTLabel)))?vehicleMap.get(System.label.BLN_VehicleSTLabel) : '';
                vehicles.BLN_SpecialVehicle__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleSPLabel)) || vehicleMap.get(System.label.BLN_VehicleSPLabel) != null)?boolean.valueOf(vehicleMap.get(System.label.BLN_VehicleSPLabel)) : false;
                vehicles.BLN_Year__c = (!string.isBlank(vehicleMap.get(System.label.BLN_YearLabel))&& vehicleMap.get(System.label.BLN_YearLabel) != System.label.BLN_Other)?double.valueOf(vehicleMap.get(System.label.BLN_YearLabel)) : null;
                vehicles.BLN_RegistrationAuthority__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleRegAuthLabel)))?vehicleMap.get(System.label.BLN_VehicleRegAuthLabel) : '';
                vehicles.BLN_IsVehicleCalibrationRequired__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleIsCaliberationLabel)) || vehicleMap.get(System.label.BLN_VehicleIsCaliberationLabel) != null)?boolean.valueOf(vehicleMap.get(System.label.BLN_VehicleIsCaliberationLabel)) : false;
                vehicles.BLN_VehicleType__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleExternalIdLabel)))?vehicleMap.get(System.label.BLN_VehicleExternalIdLabel) : '';
                 vehicles.BLN_MDMID__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleExternalIdLabel)))?vehicleMap.get(System.label.BLN_VehicleExternalIdLabel) : '';
                 vehicles.BLN_VehicleNote__c = (!string.isBlank(vehicleMap.get(System.label.BLN_YearRange)))?vehicleMap.get(System.label.BLN_YearRange) : '';
                if(BLN_Vehicle__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()){
                    insert vehicles;
                }
                cases.BLN_Vehicle__c = vehicles.Id; 
                if(case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
                    update cases;
                }
                return System.label.BLN_VehicleInsertedSuccessfullyLabel; 
            }
            else{
                BLN_Vehicle__c upVehicle = [select Name, BLN_MakeOfVehicle__c, BLN_ModelOfVehicle__c, BLN_BodyType__c, BLN_Colour__c, BLN_VehicleRegNumber__c, BLN_VIN__c, BLN_MVRIS__c, BLN_SpecialTypes__c, BLN_SpecialVehicle__c, BLN_Year__c, BLN_RegistrationAuthority__c from BLN_Vehicle__c Where Id=:cases.BLN_Vehicle__c WITH SECURITY_ENFORCED];
                
                if(upVehicle != null){
                    upVehicle.BLN_MakeOfVehicle__c = (!string.isBlank(vehicleMap.get(System.label.BLN_MakeLabel)))?vehicleMap.get(System.label.BLN_MakeLabel) : '';
                    upVehicle.BLN_ModelOfVehicle__c = (!string.isBlank(vehicleMap.get(System.label.BLN_ModelLabel)))?vehicleMap.get(System.label.BLN_ModelLabel) : '';
                    upVehicle.BLN_BodyType__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleBodyType)))?vehicleMap.get(System.label.BLN_VehicleBodyType) : '';
                    upVehicle.BLN_Colour__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleColor)))?vehicleMap.get(System.label.BLN_VehicleColor) : '';
                    upVehicle.BLN_MVRIS__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleMvrisLabel)))?vehicleMap.get(System.label.BLN_VehicleMvrisLabel) : '';
                    upVehicle.BLN_RegistrationAuthority__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleRegAuthLabel)))?vehicleMap.get(System.label.BLN_VehicleRegAuthLabel) : '';
                    upVehicle.BLN_SpecialTypes__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleSTLabel)))?vehicleMap.get(System.label.BLN_VehicleSTLabel) : '';
                    upVehicle.BLN_SpecialVehicle__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleSPLabel)) || vehicleMap.get(System.label.BLN_VehicleSPLabel) != null)?boolean.valueOf(vehicleMap.get(System.label.BLN_VehicleSPLabel)) : false;
                    upVehicle.BLN_Year__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleYearLabel)) && vehicleMap.get(System.label.BLN_VehicleYearLabel) != System.label.BLN_Other)?double.valueOf(vehicleMap.get(System.label.BLN_VehicleYearLabel)) : null;
                    upVehicle.BLN_VIN__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleVinLabel)))?vehicleMap.get(System.label.BLN_VehicleVinLabel) : '';
                    upVehicle.BLN_VehicleRegNumber__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleVrnLabel)))?vehicleMap.get(System.label.BLN_VehicleVrnLabel) : '';
                    upVehicle.BLN_IsVehicleCalibrationRequired__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleIsCaliberationLabel)) || vehicleMap.get(System.label.BLN_VehicleIsCaliberationLabel) != null)?boolean.valueOf(vehicleMap.get(System.label.BLN_VehicleIsCaliberationLabel)) : false;
                    upVehicle.BLN_VehicleType__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleExternalIdLabel)))?vehicleMap.get(System.label.BLN_VehicleExternalIdLabel) : '';
                    upVehicle.BLN_MDMID__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleExternalIdLabel)))?vehicleMap.get(System.label.BLN_VehicleExternalIdLabel) : '';
                    upVehicle.BLN_VehicleNote__c = (!string.isBlank(vehicleMap.get(System.label.BLN_YearRange)))?vehicleMap.get(System.label.BLN_YearRange) : '';
                    if(BLN_Vehicle__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
                        update upVehicle;
                    }
                }
                retValue = System.label.BLN_VehicleUpdatedSuccessfullyLabel;
            }
        }
        catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            retValue = System.label.BLN_FailedVehicleLabel + e.getMessage();
        }
        return retValue;
    }
    /*****************************************
MethodName : insertEditVehicle
@description : This method is used to return Vehicle .
@param : Strings
@return : String
CreatedDate: 18-12-2023
CreatedBy : Pwc-India
Change log :
****************************************/
    
    @auraEnabled
    public Static String insertEditVehicle(String vehicleData, String recordId){
        String retValue = '';
        try{
            map<string,string> vehicleMap = new map<string,string>();
            list<object> vehicleList = (list<object>)json.deserializeuntyped(vehicleData);
            for(object obj : vehicleList){
                map<string,object> vehicleParam = (map<string,object>)obj;
                vehicleMap.put((string)vehicleParam.get('key'),(string)vehicleParam.get('value'));
            }
            if(!string.isBlank(recordId)){
                List<BLN_Vehicle__c> vehiclesList = new List<BLN_Vehicle__c>();
                vehiclesList= [select Name, BLN_MakeOfVehicle__c, BLN_ModelOfVehicle__c, BLN_BodyType__c, BLN_Colour__c, BLN_VehicleRegNumber__c, BLN_VIN__c, BLN_MVRIS__c, BLN_SpecialTypes__c, BLN_SpecialVehicle__c, BLN_Year__c, BLN_RegistrationAuthority__c from BLN_Vehicle__c Where Id=:recordId WITH SECURITY_ENFORCED];
                
                if(!vehiclesList.isEmpty() && vehiclesList.size()==1 && BLN_Vehicle__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
                    BLN_Vehicle__c vehicle = new BLN_Vehicle__c();
                    vehicle = vehiclesList.get(0);
                    vehicle.BLN_MakeOfVehicle__c = (!string.isBlank(vehicleMap.get(System.label.BLN_MakeLabel)))?vehicleMap.get(System.label.BLN_MakeLabel) : '';
                    vehicle.BLN_ModelOfVehicle__c = (!string.isBlank(vehicleMap.get(System.label.BLN_ModelLabel)))?vehicleMap.get(System.label.BLN_ModelLabel) : '';
                    vehicle.BLN_BodyType__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleBodyType)))?vehicleMap.get(System.label.BLN_VehicleBodyType) : '';
                    vehicle.BLN_Colour__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleColor)))?vehicleMap.get(System.label.BLN_VehicleColor) : '';
                    vehicle.BLN_VehicleRegNumber__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleVrnLabel)))?vehicleMap.get(System.label.BLN_VehicleVrnLabel) : '';
                    vehicle.BLN_VIN__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleVinLabel)))?vehicleMap.get(System.label.BLN_VehicleVinLabel) : '';
                    vehicle.BLN_MVRIS__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleMvrisLabel)))?vehicleMap.get(System.label.BLN_VehicleMvrisLabel) : '';
                    vehicle.BLN_SpecialTypes__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleSTLabel)))?vehicleMap.get(System.label.BLN_VehicleSTLabel) : '';
                    vehicle.BLN_SpecialVehicle__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleSPLabel)) || vehicleMap.get(System.label.BLN_VehicleSPLabel) != null)?boolean.valueOf(vehicleMap.get(System.label.BLN_VehicleSPLabel)) : false;
                    vehicle.BLN_Year__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleYearLabel))&& vehicleMap.get(System.label.BLN_VehicleYearLabel) != System.label.BLN_Other)?double.valueOf(vehicleMap.get(System.label.BLN_VehicleYearLabel)) : null;
                    vehicle.BLN_RegistrationAuthority__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleRegAuthLabel)))?vehicleMap.get(System.label.BLN_VehicleRegAuthLabel) : '';
                    vehicle.BLN_IsVehicleCalibrationRequired__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleIsCaliberationLabel)) || vehicleMap.get(System.label.BLN_VehicleIsCaliberationLabel) != null)?boolean.valueOf(vehicleMap.get(System.label.BLN_VehicleIsCaliberationLabel)) : false;
                    vehicle.BLN_MDMID__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleExternalIdLabel)))?vehicleMap.get(System.label.BLN_VehicleExternalIdLabel) : '';
                    vehicle.BLN_VehicleType__c = (!string.isBlank(vehicleMap.get(System.label.BLN_VehicleExternalIdLabel)))?vehicleMap.get(System.label.BLN_VehicleExternalIdLabel) : '';
                    vehicle.BLN_VehicleNote__c = (!string.isBlank(vehicleMap.get(System.label.BLN_YearRange)))?vehicleMap.get(System.label.BLN_YearRange) : '';
                    update vehicle;
                    
                }
            }
            retValue = System.label.BLN_VehicleUpdatedSuccessfullyLabel;  // with Id : +vehicles.id;
        }
        catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            retValue = System.label.BLN_FailedVehicleLabel+e.getMessage();
        }
        return retValue;
        
    }

   @AuraEnabled(cacheable=true)
   
    public static List<Case> duplicateVrnCases(String vrn) {
        
        List<Case> duplicateCases = new List<Case>();
        if (Schema.sObjectType.Case.isAccessible()) {
            try {   
               if(vrn != null){   
                    duplicateCases = [
                        SELECT Id, CaseNumber, BLN_VRN__c
                        FROM Case
                        WHERE BLN_Vehicle__r.BLN_VehicleRegNumber__c = : vrn
                        AND IsClosed = false  
                        WITH SECURITY_ENFORCED
                    ];
               } 
                 }  
                catch (Exception e) {BLN_ExceptionLogger.captureException(e); }
            }
              return duplicateCases.isEmpty() ? new List<Case>() : duplicateCases;
    }
    
    
 
    
}