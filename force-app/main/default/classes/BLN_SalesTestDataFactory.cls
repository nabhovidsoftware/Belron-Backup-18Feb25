/*****************************************
*ClassName : BLN_SalesTestDataFactory
*@description : The Test Data Factory class is responsible for creation of test data
*@Story : FOUK - 602
*CreatedDate: 07-12-2023
*CreatedBy : PwC-India
****************************************/

@isTest
public class BLN_SalesTestDataFactory {
    /*****************************************
*MethodName : createAccount
*@description : This method is used for creating account
*@param :  name,  industry,  clientSubType, Integer totalNoOfVehiclesMotorPolicy,  clientType,  vatRegistrationNumber,  companyRegistrationNumber, registrationAddressCity,  registrationAddressStreet, registrationAddressPostalCode,  registrationAddressCountryCode,   billingStreet,  billingCity ,   billingPostalCode,  billingCountry,  recType
*@return account
*CreatedDate: 07-12-2023
*CreatedBy : Pwc-India
*Change log :
****************************************/
    public static Account createAccount(String name, String industry, String clientSubType, Integer totalNoOfVehiclesMotorPolicy, String clientType, String vatRegistrationNumber, String companyRegistrationNumber, 
                                        String registrationAddressCity, String registrationAddressStreet, 
                                        String registrationAddressPostalCode, String registrationAddressCountryCode, String  billingStreet, String billingCity , String  billingPostalCode, String billingCountry, String recType) {
                                            Account acc= new Account();
                                            acc.Name                                    = name;
                                            acc.Industry                                = industry;
                                            acc.BLN_ClientSubType__c                    = clientSubType ;
                                            acc.BLN_TotalNoOfVehiclesMotorPolicy__c     = totalNoOfVehiclesMotorPolicy ;
                                            acc.BLN_ClientType__c                       = clientType;
                                            acc.BLN_VatRegistrationNumber__c            = vatRegistrationNumber;
                                            acc.BLN_CompanyRegistrationNumber__c        = companyRegistrationNumber;
                                            acc.BLN_RegistrationAddress__City__s        = registrationAddressCity;
                                            acc.BLN_RegistrationAddress__Street__s      = registrationAddressStreet;
                                            acc.BLN_RegistrationAddress__PostalCode__s  = registrationAddressPostalCode;
                                            acc.BLN_RegistrationAddress__CountryCode__s = registrationAddressCountryCode;
                                            acc.BillingStreet                           = billingStreet;
                                            acc.BillingCity                             = billingCity;
                                            acc.BillingPostalCode                       = billingPostalCode;                
                                            acc.BillingCountry                          = billingCountry;                                         
                                            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recType).getRecordTypeId();
                                            return acc;
                                       }
    
    /*****************************************
*MethodName : createTestUser
*@description : This method is used for creating test user
*@param uniqueUserName , userProfile,  userAlias, userEmail, userLastName, userLanguageLocaleKey, userLocaleSidKey,userTimeZoneSidKey, userEmailEncodingKey
*@return  user
*CreatedDate: 07-12-2023
*CreatedBy : Pwc-India
*Change log :
****************************************/
    public static User createTestUser(String uniqueUserName ,String userProfile, String userAlias,String userEmail,String userLastName,String userLanguageLocaleKey,String userLocaleSidKey,
                                      String userTimeZoneSidKey,String userEmailEncodingKey ){                
                                          // This code runs as the system user
                                          Profile testSalesUserProfile = [SELECT Id FROM Profile WHERE Name =:userProfile];                                      
                                          User testSalesUser = new User(Alias = userAlias, Email = userEmail,
                                                                        EmailEncodingKey=userEmailEncodingKey, LastName= userLastName, LanguageLocaleKey=userLanguageLocaleKey,
                                                                        LocaleSidKey=userLocaleSidKey, ProfileId = testSalesUserProfile.Id,
                                                                        TimeZoneSidKey=userTimeZoneSidKey,
                                                                        UserName=uniqueUserName);
                                          
                                          return testSalesUser;
                                      }
   
    /*****************************************
*MethodName : createAccountRuleParameterDefinition
*@description : This method is used for creating Account Rule Parameter 
*@param : accountId, arpdId, activeFromDate, activeToDate
*@return  user
*CreatedDate: 19-01-2024
****************************************/
    public static BLN_AccountRuleParameter__c createAccountRuleParameter(Id accountId, String recordtypeId, Date activeFromDate,Date activeToDate){                
        BLN_AccountRuleParameter__c testARP = new BLN_AccountRuleParameter__c(BLN_Account__c = accountId, BLN_ActiveFrom__c = activeFromDate, BLN_ActiveTo__c = activeToDate,RecordTypeId=recordTypeId);
        return testARP;
    }
 
        /*****************************************
*MethodName : CreateContact
*@description : This method is used for creating a contact
*@param : accountId, lastName, firstName, postion, decisionPower, attitude
*@return  Contact
*CreatedDate: 16-02-2024
****************************************/
    public static Contact createContact (String lastName, String firstName, Id accountId, String postion, string decisionPower, string attitude	 ){
        Contact con = new Contact();
        con.FirstName = firstName;
        con.LastName = lastName;
        con.AccountId = accountId;
        con.BLN_Position__c = postion;
        con.BLN_DecisionPower__c = decisionPower;
        con.BLN_AttitudetowardsAutoglass__c = attitude;
        return con;
        
    }
            /*****************************************
*MethodName : createRelationShip 
*@description : This method is used for creating a Realtionship
*@param : accountId, contactId, health,userId
*@return  Contact
*CreatedDate: 16-02-2024
****************************************/
    public static BLN_Relationship__c createRelationship (String health,  Id userId, Id accountId,Id contactId ){
        BLN_Relationship__c relationship = new BLN_Relationship__c ();
        relationship.BLN_RelationshipHealth__c	 = health;
        relationship.BLN_UserName__c = userId;
        relationship.BLN_Account__c = accountId;
        relationship.BLN_ContactName__c =contactId;
        return relationship;
        
        
    }
}