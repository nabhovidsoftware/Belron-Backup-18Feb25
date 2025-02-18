/** @description : This controller class is used in Service certainty API.
*   @Story : FOUK-4365
*   @author: PwC-India
*   @CreatedDate: 11-01-2024
*/
public with sharing class BLN_ServCertAPIPublisherTriggerHandler {
    /**@MethodName : syncCasewithServCertainty
* @description : This method is used to insert the response from Service Certainty API.
* @param : list<BLN_APICalloutPublisher__e>
* @return : void
* @createdDate: 11-01-2024
* @createdBy: Pwc-India
*/
    
    @invocableMethod
    public static void syncCasewithServCertainty(list<string> recordId){
        try{
            String jsonData = '';
            ServiceAppointment sAs = new ServiceAppointment();
            Account accounts = new Account();
            case cases = new case();
            requestParser certainties = new requestParser();
            Address add = new Address();
            if(!recordId.isEmpty() && (ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() || Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() || case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible())){
                sAs = [Select BLN_Case__r.BLN_VRN__c, BLN_Case__c,BLN_WorkOrderNumber__r.caseId, EarliestStartTime, BLN_OriginalScheduledStartTime__c, AccountId, ParentRecordId, BLN_AssignmentID__c, BLN_JobLink__c from ServiceAppointment Where Id =: recordId[0] with security_enforced];
            }
            if(sAs.BLN_WorkOrderNumber__r.caseId != null && case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
             cases = [Select BLN_VRN__c, BLN_ServicePostCode__c, BLN_ServiceCountry__c from Case where id =: sAs.BLN_WorkOrderNumber__r.caseId with Security_Enforced];
            }
            if(sAs.AccountId !=null && (Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible())){
                accounts = [SELECT Id, FirstName, LastName, PersonEmail, PersonMobilePhone, PersonMailingPostalCode, PersonMailingCountry FROM Account where id =:  sAs.AccountId with security_enforced];
            }
            if(sAs != null && cases !=null){
                certainties = new requestParser();
                certainties.glassDamageDocumentTypeCode = System.label.BLN_glassDamageDocumentTypeCode;
                certainties.insurancePolicyNumber = System.label.BLN_InsurancePolicyNumber;
                certainties.vrn = cases.BLN_VRN__c != null? cases.BLN_VRN__c:system.label.BLN_VrnText;
                certainties.appointmentDateTime = (string.valueOf(sAs.BLN_OriginalScheduledStartTime__c) != null)?string.valueOf(sAs.BLN_OriginalScheduledStartTime__c):string.valueof(sAs.EarliestStartTime);
                add.country = cases.BLN_ServiceCountry__c!= null? cases.BLN_ServiceCountry__c: '';
                add.addressPostalCode = cases.BLN_ServicePostCode__c!= null? cases.BLN_ServicePostCode__c: '';
            }
            if(accounts != null ){
        certainties.firstName = accounts.FirstName;
        certainties.lastName = accounts.LastName;
        certainties.email = accounts.PersonEmail;
        certainties.phone = accounts.PersonMobilePhone ;
                certainties.glassDamageServiceTypeCode = system.label.BLN_GlassDamageServiceTypeCode;
            }
            certainties.address = add ;
            JSONGenerator generator = JSON.createGenerator(true);
            generator.writeObject(certainties);
            jsonData = generator.getAsString();
            if(!string.isBlank(jsonData) && !recordId.isEmpty() && !system.isBatch() && !system.isFuture()){
                updateCaseAndSA(jsonData, recordId); 
            }
        }catch(exception e){
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e); 
        }
    }
    @future(callout=true)
    public static void updateCaseAndSA(string jsonBody, list<string> recordId){
        try{
            
            string encoded = '';
            encoded = EncodingUtil.urlEncode(jsonBody, system.label.BLN_UTF);
            list<ServiceAppointment> sAList = new list<ServiceAppointment>();
            httpResponse res = new httpResponse();
            ServiceAppointment sAs = new ServiceAppointment();
            case cases = new case();
            if(!recordId.isEmpty() && (ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() )){
                sAs = [Select BLN_Case__c, BLN_AssignmentID__c, BLN_WorkOrderNumber__r.caseId, BLN_JobLink__c from ServiceAppointment Where Id =: recordId[0] with security_enforced];
            }
            if(sAs.BLN_WorkOrderNumber__r.caseId != null && (case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible())){
                cases = [SELECT Id, BLN_AssignmentID__c, BLN_JobLink__c FROM Case where id =: sAs.BLN_WorkOrderNumber__r.caseId with security_enforced];
            }
            // Create an HTTP object and send a request to get an access token
            BLN_HTTPCallOutAccessToken.WrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken();
            if(wrapperToken.accessToken != null){
                String endpoint = System.label.BLN_CreditsafeRequestEndpoint+system.label.BLN_GblPath+system.label.BLN_ServCertPath;
                Map<String,String> headerMap = new Map<String,String>();
                headerMap.put(System.label.BLN_HttpContentTypeKey,System.label.BLN_AppJson);
                headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+wrapperToken.accessToken);
                res = BLN_HttpCalloutUtility.makeCallout(System.label.BLN_MelissaApiAddressService,endpoint,System.label.BLN_HttpMethodPost,headerMap,recordId[0],jsonBody);
                
            }
            
            BLN_ProductParser certParse = BLN_ProductParser.parse(res.getBody());
            if(certParse !=null){
            sAs.BLN_AssignmentID__c = certParse.glassDamageDocument.glassDamageDocumentID;
            sAs.BLN_JobLink__c = certParse.glassDamageDocument.uploadURL;
            sAList.add(sAs);
            cases.BLN_AssignmentID__c = certParse.glassDamageDocument.glassDamageDocumentID;
            cases.BLN_JobLink__c = certParse.glassDamageDocument.uploadURL; 
                
            }
            if(certParse != null && case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable() || ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
                database.update(sAList) ;
                database.update(cases);
            }
            
        }catch(exception e){
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);
        }
    }
    /** @description : This Wrapper class is used in Service certainty API.
*   @Story : FOUK-4365
*   @author: PwC-India
*   @CreatedDate: 11-01-2024
*/
    public class RequestParser{
        public String glassDamageDocumentTypeCode;	//image
        public String insurancePolicyNumber;	//1
        public String vrn;	//WL2433435
        public String appointmentDateTime;	//2023-08-23
        public String firstName;	//test
        public String lastName;	//name
        public object address;
        public String email;	//x123@gmail.com
        public String phone;	//+44 7927 116434
        public String glassDamageServiceTypeCode;
    }
    /** @description : This Wrapper class is used in Service certainty API.
*   @Story : FOUK-4365
*   @author: PwC-India
*   @CreatedDate: 11-01-2024
*/
    public class Address {
        public String addressPostalCode;	
        public String country;	
    }
}