/*****************************************
ClassName : BLN_SearchAndGetMotoristController
Description : FOUK-1175 This controller class is used in bln_SearchAndGetMotorist lwc.
              Search account base on user input if result not available in SF then api request on mulesoft and store data in sf
CreatedDate: 25-11-2023
CreatedBy : Shailendra Tiwari (PWC-India)
    Last Modified By: Subhamita Dutta (Person Type field to the BLN_PersonType__c field on Account.)
    FOUK-5378
    ****************************************/
    /**
     * @discription : FOUK-1175 This controller class is used in bln_SearchAndGetMotorist lwc.
                  Search account base on user input if result not available in SF then api request on mulesoft and store data in sf*/
public with sharing class BLN_SearchAndGetMotoristController {
  

         /* This method is used for search user input records from account*/    
    @AuraEnabled
    public static List<MotoristWrapper> searchAndGetMotorists(MotoristWrapper motoristWrap) {
        String query = '';
        //String condition = '';
       // RecordType recordType;
        list<Account> accList = new list<Account>(); 
        MotoristWrapper wrapperM = new MotoristWrapper();  
        List<MotoristWrapper> motorists = new List<MotoristWrapper>();  
       
        query = 'SELECT Id, Salutation, PersonMailingStreet, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry, PersonMailingCity,BLN_PrimaryContactNumber__c, BLN_PersonAccountType__c, FirstName, LastName, PersonMobilePhone,PersonOtherPhone, PersonHomePhone, PersonEmail, BLN_MDMAccountPartyId__c, BLN_MDMMotoristId__c, BLN_PreferredContactMethod__c,RecordTypeId,BLN_HomeCountryCode__c,BLN_OtherCountryCode__c  FROM Account WHERE RecordType.DeveloperName = \'PersonAccount\'' ;
        if( !String.isBlank(motoristWrap.firstName )){
            query += ' AND FirstName =\''+String.escapeSingleQuotes(motoristWrap.firstName.deleteWhitespace())+'\'';
        }

        if(!String.isBlank(motoristWrap.lastName )){ 
            query += 'AND LastName = \''+String.escapeSingleQuotes(motoristWrap.lastName.deleteWhitespace())+'\'';
        }

       if(!String.isBlank(motoristWrap.primaryEmail )){
        query += ' AND PersonEmail =\''+String.escapeSingleQuotes(motoristWrap.primaryEmail.deleteWhitespace())+'\'';
        }
        
        if(!String.isBlank(motoristWrap.mobilePhone )){
            query += ' AND PersonMobilePhone =\''+String.escapeSingleQuotes(motoristWrap.mobilePhone.deleteWhitespace())+'\'';
        }

        if(!string.isblank(query)){
            accList = database.query(query);

            }
            if(!accList.isEmpty()){
            for (Account acc : accList) {
                wrapperM = new MotoristWrapper();
            wrapperM.firstName = acc.firstName;
            wrapperM.lastName = acc.LastName;
                wrapperM.title = acc.Salutation;
                wrapperM.primaryEmail = acc.PersonEmail;
                wrapperM.mobilePhone = acc.PersonMobilePhone;
                wrapperM.homePhone = acc.PersonHomePhone;
                wrapperM.otherPhone = acc.PersonOtherPhone;
                wrapperM.source = system.label.BLN_SF;
                wrapperM.sfId = acc.Id;
            wrapperM.homeStreet = acc.PersonMailingStreet;
            wrapperM.homePostalCode = acc.PersonMailingPostalCode;
            wrapperM.homeState = acc.PersonMailingState;
            wrapperM.homeCountry = acc.PersonMailingCountry;
            wrapperM.homeTown = acc.PersonMailingCity;
                wrapperM.primaryContactNumber = acc.BLN_PrimaryContactNumber__c;
                wrapperM.preferredContactMethod = acc.BLN_PreferredContactMethod__c;
                wrapperM.mdmMotoristId = acc.BLN_MDMMotoristId__c;                
                wrapperM.homeCountryCode = acc.BLN_HomeCountryCode__c;     
                wrapperM.selectMotorist = false; 
                motorists.add(wrapperM);
            }
            }
        if (motorists.isEmpty()) {
            // If no records found, call external API
            motorists = callExternalAPI(motoristWrap);
        }

        return motorists;
    }
    
    /* Method is used for call external API to display on datatable*/
    public static List<MotoristWrapper> callExternalAPI(MotoristWrapper motoristWrap) {
        List<MotoristWrapper> motorists = new List<MotoristWrapper>();
      //  Map<String, Object> requestBody= new Map<String, Object>();
        //Http serachHttp = new Http(); 
        //HttpRequest searchRequest = new HttpRequest();
       // HttpResponse searchResponse = new HttpResponse();
      //  String jsonData = '';
        String endPoint = '';
        if(!String.isBlank(motoristWrap.firstName ) && !String.isBlank(motoristWrap.lastName )) {
            try {
                 
                BLN_APICalloutMapper__mdt calloutData = BLN_APICalloutMapper__mdt.getInstance('BLN_GetSearchMDM');
                Map<String,String> headerMap = new Map<String,String>();
                headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
                for (String str : calloutData.BLN_Headers__c.split(System.label.BLN_Semicolon)) {
                    headerMap.put(str.split(System.label.BLN_Comma)[0], str.split(System.label.BLN_Comma)[1]);
                }
                endpoint=calloutData.BLN_NamedCredential__c + calloutData.BLN_CalloutURL__c + System.label.BLN_QuestionMark;

                if(!String.isBlank(motoristWrap.firstName )){
                    endpoint += system.label.BLN_FName +System.label.BLN_EqualTo + motoristWrap.firstName.deleteWhitespace();
                }

                if(!String.isBlank(motoristWrap.lastName )){ 
                    endpoint += System.label.BLN_ANDOperator + system.label.BLN_LName + System.label.BLN_EqualTo+ motoristWrap.lastName.deleteWhitespace();
                }
        
               if(!String.isBlank(motoristWrap.primaryEmail )){
                endpoint += System.label.BLN_ANDOperator+'email'+System.label.BLN_EqualTo+motoristWrap.primaryEmail.deleteWhitespace();
                }
            
                if(!String.isBlank(motoristWrap.mobilePhone )){
                    endpoint += System.label.BLN_ANDOperator+'mobilePhone'+System.label.BLN_EqualTo+motoristWrap.mobilePhone.deleteWhitespace();
                }

           
                HttpResponse response= BLN_HttpCalloutUtility.makeCallout(calloutData.BLN_DestinationSystem__c, endPoint, calloutData.BLN_Method__c, headerMap);
                if (response != null && response.getStatusCode() == 200) {
            
                    MotoristResponseWrapper parserReq = new MotoristResponseWrapper(); 
                    parserReq = (MotoristResponseWrapper) JSON.deserialize(response.getBody(), MotoristResponseWrapper.class);                          
                    motorists = parserReq.data;
                
                }
                if(motorists != null && !motorists.isEmpty()){
                    for(MotoristWrapper motoristWp : motorists) {
                        motoristWp.source = system.label.BLN_MDM;
                        motoristWp.sfId = '';
                        motoristWp.selectMotorist= false;
                    }

                }
                
            } catch (Exception e) {
                BLN_ExceptionLogger.captureException(e);
            }
        }
        return motorists;           
    }

    
    /* This method is used to create new account and update case record based on mulesoft response */
    @AuraEnabled
    public static String createAccount(MotoristWrapper motoristWrap, String caseId, Boolean callMotoristFlow1) {
        String mesg = '';

        try {
            String recTypeId = '';
            Database.SaveResult srUpsert;
            recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

            Account acc = new Account();
            acc.Salutation = motoristWrap.title != null ? motoristWrap.title : '';
            acc.FirstName = motoristWrap.firstName != null ? motoristWrap.firstName : '';
            acc.LastName = motoristWrap.lastName != null ? motoristWrap.lastName : '';
            acc.PersonEmail = motoristWrap.primaryEmail != null ? motoristWrap.primaryEmail : '';
            acc.PersonMobilePhone = motoristWrap.mobilePhone != null ? motoristWrap.mobilePhone : '';
            acc.BLN_MDMMotoristId__c = motoristWrap.mdmMotoristId != null ? motoristWrap.mdmMotoristId : '';
            acc.PersonMailingStreet = motoristWrap.homeStreet != null ? motoristWrap.homeStreet : ''; 
            acc.PersonMailingCity = motoristWrap.homeTown != null ? motoristWrap.homeTown : ''; 
            acc.PersonMailingState = motoristWrap.homeState != null ? motoristWrap.homeState : '';
            acc.PersonMailingPostalCode = motoristWrap.homePostalCode != null ? motoristWrap.homePostalCode : '';
            acc.PersonMailingCountry = motoristWrap.homeCountry != null ? motoristWrap.homeCountry : '';
            acc.BLN_PrimaryContactNumber__c = motoristWrap.primaryContactNumber != null ? motoristWrap.primaryContactNumber : '';
            acc.RecordTypeId = recTypeId;
            acc.PersonHomePhone = motoristWrap.homePhone != null ? motoristWrap.homePhone : '';
            acc.PersonOtherPhone = motoristWrap.otherPhone != null ? motoristWrap.otherPhone : '';
            acc.BLN_HomeCountryCode__c = motoristWrap.homeCountryCode != null ? motoristWrap.homeCountryCode : '';
            if(!String.isBlank(motoristWrap.sfId)){
            acc.Id = motoristWrap.sfId ;
            }
            acc.BLN_MDMAccountPartyId__c = motoristWrap.mdmAccountPartyId != null ? motoristWrap.mdmAccountPartyId : '';
            acc.BLN_PreferredContactMethod__c = motoristWrap.preferredContactMethod != null ? motoristWrap.preferredContactMethod : '';
            

            if(!String.isBlank(motoristWrap.sfId)){
                srUpsert =  Database.update(acc,false);

            }else{
                srUpsert =  Database.insert(acc,false);
            }

            if(srUpsert.isSuccess()  && !String.isBlank(caseId)) {
                Case cs = new Case();
                cs.Id = caseId;
                Account upertAcc = new Account();
                upertAcc =[SELECT Id, PersonContactId FROM Account WHERE id =: srUpsert.getId() WITH SECURITY_ENFORCED LIMIT 1];
            
            if(upertAcc.PersonContactId != null && callMotoristFlow1 != true && (motoristWrap.personType == null || motoristWrap.personType  =='Motorist')){
                cs.ContactId = upertAcc.PersonContactId;
                
            }
            
            else if (upertAcc.PersonContactId != null && callMotoristFlow1 != true && motoristWrap.personType =='Nominated Person')
            {
                cs.BLN_NominatedPerson__c = upertAcc.Id;
                
            }          
                Database.SaveResult  sr;
                sr = Database.update(cs);
           }
            mesg = String.valueOf(acc.Id);
        } 
        catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            String errorMsg = e.getMessage();
                String pureErrorMsg = errorMsg.substringAfter(system.label.BLN_Error);
                if(pureErrorMsg.contains(system.label.BLN_Colon)) {
                    
                    pureErrorMsg = e.getMessage().split(system.label.BLN_Error)[1].split(system.label.BLN_Colon)[0];
                }
            mesg = pureErrorMsg;
        }

        return mesg;
    }
    
    /* This wrapper class is used for mulesoft response deserialize*/  
    public class MotoristResponseWrapper {
        public List<MotoristWrapper> data;
        public List<Errors> errors;
        public Links links;
    }

    /* This wrapper class is used for mulesoft response deserialize*/	
    public class Errors {
        public String status;
        public String title;
        public String detail;
    }

    public class Links {
        public Self self;
        public Self first;
        public Self last;
        public Self prev;
        public Self next;
    }
    
    public class Self {
        public String href;
    }
    
    /* This wrapper class is used for mulesoft response deserialize*/
    public class MotoristWrapper {
        @AuraEnabled public String mdmAccountPartyId{ get; set; }
        @AuraEnabled public String firstName{ get; set; }
        @AuraEnabled public String lastName{ get; set; }
        @AuraEnabled public String title{ get; set; }
        @AuraEnabled public String suffix{ get; set; }
        @AuraEnabled public String preferredName{ get; set; }
        @AuraEnabled public String middleName{ get; set; }
        @AuraEnabled public String mdmMotoristId{ get; set; }
        @AuraEnabled public String preferredContactMethod{ get; set; }
        @AuraEnabled public String primaryContactNumber{ get; set; }
        @AuraEnabled public String homePhone{ get; set; }
        @AuraEnabled public String otherPhone{ get; set; }
        @AuraEnabled public String mobilePhone{ get; set; }
        @AuraEnabled public String primaryEmail{ get; set; }
        @AuraEnabled public String homeStreet{ get; set; }
        @AuraEnabled public String homePostalCode{ get; set; }
        @AuraEnabled public String homeState{ get; set; }
        @AuraEnabled public String homeCountry{ get; set; }
        @AuraEnabled public String homeCountryCode{ get; set; }
        @AuraEnabled public String homeTown{ get; set; }
        @AuraEnabled public List<String> accountType{ get; set; }
        @AuraEnabled public String source{ get; set; }
        @AuraEnabled public String sfId{ get; set; }
        @AuraEnabled public boolean selectMotorist { get; set; }
        @AuraEnabled public String personType { get; set; }
    }
   
}