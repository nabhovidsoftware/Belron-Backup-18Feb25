/*****************************************
ClassName : BLN_ConnectWithGPS
Description : FOUK-2164 This controller class is used to call 'vehicle-schematics' & 'vehicle-bill-of-materials' request GPS API &
Passed the data back to 'BLN_DamageAssessmentFlow'.
CreatedDate: 15-12-2023
CreatedBy : PWC-India
****************************************/
public with sharing class BLN_ConnectWithGPS {
    

    /*@description : getBomId method used to get bomId.
@return : method returns the String .
@param : parameter send Parser */
  public static String getBomId(BLN_ProductParser parser){
    String bomId = '';
    List<String> listBomId = new List<String>(); 
    if(parser.Results.size() > 1){
        for (Integer i = 0; i < parser.Results.size(); i++) {  
            listBomId.add(string.valueof(parser.Results[i].bomId));  
        }
         bomId =  String.join(listBomId, ',');
} else{
    bomId =  string.valueof(parser.Results[0].bomId);
}
   // system.debug('bomId12345678 '+bomId);
   return bomId;
   }
    
    /*@description : receiveBomIdFromGPS method used to get bomId.
@return : method returns the String list.
@param : parameter send transactionId, vehicleHoleId And recordId */
    @invocablemethod
    public static list<List<String>> receiveBomIdFromGPS(list<list<string>> listOfBom) {
        string endPoint = '';
        string bomId = '';
        list<string> tranAndHole = new list<string>();
        if(listOfBom !=null &&  listOfBom.size() > 0 && listOfBom[0]!=null){
            tranAndHole = listOfBom[0];
        }
        
        BLN_ProductParser parser = new BLN_ProductParser();
       // Map<String, Object> requestBody= new Map<String, Object>();
        List<String> returnList = new List<String>();
        Map<String,String> headerMap = new Map<String,String>();
        list<list<string>> newReturn = new list<list<string>>();
        HttpResponse response = new HttpResponse();
        try{
            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_GetPidQuestionsLabel); 

            endPoint=calloutDetails.BLN_NamedCredential__c+calloutDetails.BLN_CalloutURL__c+system.label.BLN_TransactionPath+tranAndHole[0]+system.label.BLN_HoleIdPath+tranAndHole[1];
           // system.debug('receiveBomIdFromGPS EndPoint'+ endPoint);
          // BLN_HTTPCallOutAccessToken.wrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
            for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
            }
            response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,endPoint,calloutDetails.BLN_Method__c, headerMap,Integer.valueOf(calloutDetails.BLN_APITimeout__c));

            //if(response.getStatuscode() == 200){
                parser = BLN_ProductParser.parseGPS(response.getBody());
           // }
            if(parser !=null && parser.vehicleDamage !=null && parser.vehicleDamage.status !=null && parser.vehicleDamage.status == System.label.BLN_ResultLabel){
               /* if(parser.Results[0].bomId != null ){
                    bomId = string.valueof(parser.Results[0].bomId);
                }*/

                //Added Under 11509
                bomId =  getBomId(parser);

            /* List<String> listBomId = new List<String>(); 
                if(parser.Results.size() > 1){
                    for (Integer i = 0; i < parser.Results.size(); i++) {  
                        listBomId.add(string.valueof(parser.Results[i].bomId));  
                    }
                     bomId =  String.join(listBomId, ',');
            } else{
                bomId =  string.valueof(parser.Results[0].bomId);
            }*/

                returnList.add(parser.vehicleDamage.status);
                returnList.add(bomId); 
                newReturn.add(returnList);  

            }else if(parser !=null && parser.vehicleDamage !=null && parser.vehicleDamage.status !=null && parser.vehicleDamage.status == System.label.BLN_QuestionLabel){
                
                returnList.add(parser.vehicleDamage.transactionId);
                returnList.add(parser.vehicleDamage.status);
                returnList.add(parser.Question.question);
                newReturn.add(returnList); 

            } else if(response.getStatuscode() != 200){if (response.getStatuscode() == 0){returnList.add(system.label.BLN_APITimeOutErrorMsg);}else{returnList.add(parser.errors[0].detail);}newReturn.add(returnList); }
           
        }catch(exception e){
            BLN_ExceptionLogger.captureException(e);

        }
        return newReturn;
    }
    /*@description : getAnswerFromGPS method used to get Question or bomId.
@return : method returns the String list.
@param : parameter send ans, transId And recordId */
    @AuraEnabled 
    public static List<String> getAnswerFromGPS(string ans, string transId, string recordId, string glassHoleType){
        BLN_ProductParser parser = new BLN_ProductParser(); 
        HttpResponse response = new HttpResponse();
        List<String> returnList = new List<String>();
        Map<String,String> headerMap = new Map<String,String>();
        string endPoint='';
        string bomId = '';
       // BLN_HTTPCallOutAccessToken.wrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();
        try{      
            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_GetPidQuestionsLabel); 
              
            endPoint=calloutDetails.BLN_NamedCredential__c+calloutDetails.BLN_CalloutURL__c+system.label.BLN_TransactionPath+transId+system.label.BLN_AnswerPath+ans;
           // system.debug('getAnswerFromGPS EndPoint'+ endPoint);
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
            for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
            }
            response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,endPoint,calloutDetails.BLN_Method__c, headerMap,Integer.valueOf(calloutDetails.BLN_APITimeout__c));
            parser = BLN_ProductParser.parseGPS(response.getBody());
            if(response.getStatusCode()== 200){
               
                if(parser !=null && parser.vehicleDamage !=null && parser.vehicleDamage.status !=null) {       
                returnList.add(parser.VehicleDamage.status);
            }
            }else if(response.getStatuscode() != 200){if (response.getStatuscode() == 0){ returnList.add(system.label.BLN_APITimeOutErrorMsg);}else{returnList.add(parser.errors[0].detail);}}
            if(parser !=null && parser.vehicleDamage !=null && parser.Results !=null && parser.Results.size() > 0 && parser.Results[0].bomId != null &&parser.vehicleDamage.status !=null && parser.vehicleDamage.status == System.label.BLN_ResultLabel){
                
                bomId = getBomId(parser);

             /*List<String> listBomId = new List<String>(); 
                if(parser.Results.size() > 1){
                    for (Integer i = 0; i < parser.Results.size(); i++) {  
                        listBomId.add(string.valueof(parser.Results[i].bomId));  
                    }
                     bomId =  String.join(listBomId, ',');
            } else{
                bomId =  string.valueof(parser.Results[0].bomId);
            }*/

               // bomId = string.valueof(parser.Results[0].bomId);


                insertVehicleDamage(recordId, bomId, glassHoleType);

            }else if(parser !=null && parser.vehicleDamage !=null && parser.VehicleDamage.transactionId !=null && parser.vehicleDamage.status !=null && parser.vehicleDamage.status == System.label.BLN_QuestionLabel){
                returnList.add(parser.VehicleDamage.transactionId);
                returnList.add(parser.Question.question);

            }

        }catch(exception e){
            BLN_ExceptionLogger.captureException(e);

        }
        return returnList;
    }
    /*@description : getSchematicApi method used to get bomId.
@return : method returns the Map.
@param : recordId */
    @AuraEnabled
    public static String getSchematicApi(String recordId){
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
        String errorDetail = '';
        String wrap = '';
        String vin = '';
        String mvris = '';
        String vehicleId = '';

        BLN_ProductParser parser = new BLN_ProductParser();
        HttpResponse response = new HttpResponse();
        Map<Integer,HoverContent[]> hcMap = new Map<Integer,HoverContent[]>();
        list<BLN_ProductParser.Schematics> shemL = new list<BLN_ProductParser.Schematics>();
        map<integer,list<BLN_ProductParser.Schematics>> scheMap = new map<integer,list<BLN_ProductParser.Schematics>>();
        list<HoverContent> hcList = new list<HoverContent>();
        Map<String,String> headerMap = new Map<String,String>();
        Case objCase=new Case();
        BLN_Vehicle__c objVeh= new  BLN_Vehicle__c();
        try{
            if(!string.isBlank(recordId)){ 
                objCase = [SELECT Id, BLN_Vehicle__c FROM Case WHERE Id =: recordId WITH SECURITY_ENFORCED];
            }
            if(objCase.BLN_Vehicle__c != null){
                objVeh = [SELECT Id, BLN_BodyType__c, BLN_MakeOfVehicle__c, BLN_ModelOfVehicle__c, BLN_Year__c, BLN_VIN__c,BLN_MDMID__c,BLN_MVRIS__c FROM BLN_Vehicle__c WHERE Id =: objCase.BLN_Vehicle__c WITH SECURITY_ENFORCED];
            }
            bodyTypeEncoded = EncodingUtil.urlEncode(objVeh.BLN_BodyType__c, System.label.BLN_UTF);
            makeEncoded = EncodingUtil.urlEncode(objVeh.BLN_MakeOfVehicle__c, System.label.BLN_UTF);
            modelEncoded = EncodingUtil.urlEncode(objVeh.BLN_ModelOfVehicle__c, System.label.BLN_UTF);
           
            if(!String.isBlank(objVeh.BLN_VIN__c)){
            vin = system.label.BLN_Vin+objVeh.BLN_VIN__c;
            }else{
            vin = '';   
            }

            if(!String.isBlank(objVeh.BLN_MVRIS__c)){
            mvris = system.label.BLN_MvrisEnd+objVeh.BLN_MVRIS__c;
            }else{
            mvris = '';
            }

            if(!String.isBlank(objVeh.BLN_MDMID__c)){
            vehicleId = system.label.BLN_VehicleIdEnd+objVeh.BLN_MDMID__c;
            }else{
            vehicleId = '';
            }
        

          //  BLN_HTTPCallOutAccessToken.WrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();

            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_GetSchematicLable); 


            endPoint=calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c+system.label.BLN_MakePath+ makeEncoded +system.label.BLN_ModelPath+ modelEncoded+system.label.BLN_YearPath+string.valueOf(objVeh.BLN_Year__c)+system.label.BLN_ExternalRef+objCase.Id+vin+mvris+vehicleId+system.label.BLN_BodyTypePath+bodyTypeEncoded; //+system.label.BLN_Vin+objVeh.BLN_VIN__c
           /* if(String.isBlank(objVeh.BLN_VIN__c)){
             endPoint=calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c+system.label.BLN_MakePath+ makeEncoded +system.label.BLN_ModelPath+ modelEncoded+system.label.BLN_YearPath+string.valueOf(objVeh.BLN_Year__c)+system.label.BLN_ExternalRef+objCase.Id+system.label.BLN_BodyTypePath+bodyTypeEncoded; //+system.label.BLN_Vin+objVeh.BLN_VIN__c
             }else{
             endPoint=calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c+system.label.BLN_MakePath+ makeEncoded +system.label.BLN_ModelPath+ modelEncoded+system.label.BLN_YearPath+string.valueOf(objVeh.BLN_Year__c)+system.label.BLN_ExternalRef+objCase.Id+system.label.BLN_Vin+objVeh.BLN_VIN__c+system.label.BLN_BodyTypePath+bodyTypeEncoded;    
             }*/
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
            for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
            }
            
            response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,endPoint,calloutDetails.BLN_Method__c, headerMap,Integer.valueOf(calloutDetails.BLN_APITimeout__c));
            If(response !=null) {
                responseBody = response.getBody();
                resSize = responseBody.length();
            }

          

            if(response.getStatuscode() == 200){
                parser = BLN_ProductParser.parseGPS(response.getBody());

                list<list<BLN_ProductParser.Schematics>> sLi = parser.schematics;
                vehicleImage = parser.digitalReferenceName;
             
                hcMap = new Map<Integer,HoverContent[]>();
                If(sLi !=null && sLi.size() > 0){
                for(list<BLN_ProductParser.Schematics> sdl : sLi){
                    scheMap.put(row++,sdl);
                }
               
                for(integer i=0; i<sLi.size();i++){
                    shemL = scheMap.get(i);
                    hcList = new HoverContent[0];
                    for(BLN_ProductParser.Schematics dis : shemL){
                        HoverContent hc = new HoverContent();
                        hc.vhid = dis.vehicleHoleId!=null ? dis.vehicleHoleId : 0000;
                        hc.vType=dis.vehicleHoleTypeCode!=null ? dis.vehicleHoleTypeCode : 	system.label.BLN_TestLabel;
                        hc.displayType=dis.display!=null ? dis.display : system.label.BLN_TestLabel;
                        hc.transactionId=parser.vehicleDamage.transactionId;
                       
                        displayVal=dis.display!=null ? dis.display : system.label.BLN_NullLabel;
                        hcList.add(hc);
                    }
                    hcMap.put(count++,hcList);
                }
            }
                WrapperList wrapListObj = New WrapperList();
                wrapListObj.hoverMap = hcMap;
                wrapListObj.vehicleImage = vehicleImage;

                wrap = JSON.serializePretty(wrapListObj);
            } else

            if(response.getStatuscode() != 200){
                WrapperList wrapListObj = New WrapperList();if(response.getStatuscode() != 0){parser = BLN_ProductParser.parseGPS(response.getBody());}errorDetail = response.getStatuscode() != 0 ? parser.errors[0].detail : '';wrapListObj.errorDetail = response.getStatuscode() == 0 ? system.label.BLN_APITimeOutErrorMsg : errorDetail;wrap = JSON.serializePretty(wrapListObj);
            }
        }catch(exception e){
            BLN_ExceptionLogger.captureException(e);
           
        }

        return wrap;
    }
    /*@description : getPidQuestionGPS method used to get Question or bomId.
@return : method returns the Map.
@param : transactionId, productId, recordId */
    @AuraEnabled
    public static List<String> getPidQuestionGPS(string transactionId, string productId, string recordId, string glassHoleType){        
        string bomId = '';
        HttpResponse response = new HttpResponse();
        BLN_ProductParser parser = new BLN_ProductParser();
        List<String> returnList = new List<String>();
        Map<String,String> headerMap = new Map<String,String>();
        string endPoint='';
      //  BLN_HTTPCallOutAccessToken.wrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();
        try{
            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_GetPidQuestionsLabel);

            endPoint=calloutDetails.BLN_NamedCredential__c+calloutDetails.BLN_CalloutURL__c+system.label.BLN_TransactionPath+transactionId+system.label.BLN_AtrNameValuePath+productId;
           // system.debug('getPidQuestionGPS EndPoint'+ endPoint);
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
            for(String str :  calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
            }
            response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,endPoint,calloutDetails.BLN_Method__c, headerMap,Integer.valueOf(calloutDetails.BLN_APITimeout__c));
            parser = BLN_ProductParser.parseGPS(response.getBody());
             

              // bomId = string.valueof(parser.Results[0].bomId);
                if(response.getStatusCode() == 200 && parser !=null && parser.vehicleDamage !=null && parser.vehicleDamage.status !=null){
                   returnList.add(parser.vehicleDamage.status);
                 }  

                if(response.getStatusCode() == 200 && parser !=null && parser.vehicleDamage !=null && parser.vehicleDamage.status !=null && parser.vehicleDamage.status == System.label.BLN_ResultLabel){
                   // List<String> listBomId = new List<String>();  
                  
                    bomId = getBomId(parser);
                    /* if(parser.Results.size() > 1){
                     for (Integer i = 0; i < parser.Results.size(); i++) {  
                         listBomId.add(string.valueof(parser.Results[i].bomId));  
                     } 
                     bomId =  String.join(listBomId, ',');
                 } else{
                     bomId =  string.valueof(parser.Results[0].bomId);
                 }*/
                   
                    insertVehicleDamage(recordId, bomId, glassHoleType);
                    
                }

                else if(response.getStatusCode() == 200 && parser !=null && parser.Question !=null && parser.Question.question !=null && parser.vehicleDamage !=null && parser.VehicleDamage.transactionId !=null && parser.vehicleDamage.status !=null && parser.vehicleDamage.status == System.label.BLN_QuestionLabel){
                    returnList.add(parser.VehicleDamage.transactionId);
                    returnList.add(parser.Question.question);
                    
                }                
            

            else if(response.getStatuscode() != 200){if (response.getStatuscode() == 0){ returnList.add(system.label.BLN_APITimeOutErrorMsg);}else{returnList.add(parser.errors[0].detail);}
            }
        }
        catch(exception e){
                       
            BLN_ExceptionLogger.captureException(e);
        }
        return returnList;
        } 
    

    
    /*@description : insertVehicleDamage method used to log.
@return : method returns nothing.
@param : recordId, bomId */ 
    public static void insertVehicleDamage(string recordId, string bomId, string glassHoleType){
        
        try{
            Case caseRecord = new Case();
            BLN_VehicleDamage__c vedhicleDamageRecord = new BLN_VehicleDamage__c();
            if(!string.isBlank(recordId) && Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() && Schema.SObjectType.Case.fields.BLN_Vehicle__c.isAccessible()) {
                caseRecord = [select id,BLN_Vehicle__r.id from Case where id=:recordId WITH SECURITY_ENFORCED limit 1];
            }
                if(caseRecord != null && caseRecord.id!=null && BLN_VehicleDamage__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()){
                    vedhicleDamageRecord.BLN_Case__c = caseRecord.id;
                    vedhicleDamageRecord.BLN_Vehicle__c=caseRecord.BLN_Vehicle__r.id;
                    vedhicleDamageRecord.BLN_BOMID__c=bomId;
                    vedhicleDamageRecord.BLN_AssessmentStatus__c = System.label.BLN_CompletedLabel;
                    vedhicleDamageRecord.BLN_GlassHoleType__c = glassHoleType;
                    if(glassHoleType!= null && glassHoleType!= system.label.BLN_WindScreenInitials){
                    vedhicleDamageRecord.BLN_WorkType__c = system.label.BLN_SideAndRear;  
                    }else{
                    vedhicleDamageRecord.BLN_WorkType__c = system.label.BLN_replacement;
                    }
                    vedhicleDamageRecord.BLN_OutcomeType__c = system.label.BLN_replacement;
                    insert vedhicleDamageRecord;
                }
            }
        
        catch(Exception e){          
            BLN_ExceptionLogger.captureException(e);
        }
    }
    
    
    public class HoverContent{
        @AuraEnabled
        public Integer vhid{get;set;}
        @AuraEnabled
        public String vtype{get;set;}
        @AuraEnabled
        public String displayType{get;set;}
        @AuraEnabled
        public String transactionId{get;set;}
       
    }

    public class WrapperList{
       
        @AuraEnabled
        public  map<Integer,HoverContent[]> hoverMap{get;set;}

        @AuraEnabled
        public String vehicleImage{get;set;}

        @AuraEnabled
        public String errorDetail{get;set;}
    }
    
}