/*****************************************
*ClassName : BLN_AppConstants
@description : FOUK-602 This class is for the constants of apex controller .
*CreatedDate: 27-11-2023
*CreatedBy : PwC-India
****************************************/

public class BLN_AppConstants {
    //Account Constants
    public static final String STATUS_CLOSED = 'Closed';
	public static final String RECORD_TYPE_B2B = 'Customer(B2B Account)';
    public static final String RECORD_TYPE_REFERRAL = 'Referral Partner';
    public static final String ACCOUNT_ID_MISSING = 'Account Id is missing.';
    public static final String ACCOUNT_BRANCH_UNAVAILABLE = 'Account Branch Details are un-available.';
    public static final String ACCOUNT_BRANCH_EMPTY = 'No accounts found for the specified input arguments.';
    public static final String ACCOUNT_RULE_PARAM_EMPTY = 'No ARP found for the specified input arguments.';
    public static final String INHERITANCE_BEHAVIOUR_SUM = 'Sum';
    public static final String INHERITANCE_BEHAVIOUR_LOWEST_LEVEL = 'Lowest Level';
    public static final String INHERITANCE_BEHAVIOUR_SUM_LOWEST_LEVEL = 'Sum with Lowest Level Precedence';
    public static final String SITE_ACCOUNT = 'Site Account';
    public static final String RECORD_TYPE_CORPORATE_LEVEL = 'Corporate Level';
    public static final String RECORD_TYPE_SLA = 'SLA';
    public static final String B2C_PROFILE = 'Belron Customer Community User';
    public static final String TIMEZONE_KEY = 'Europe/London';
    public static final String EN_GB = 'en_GB';
    public static final String PORTAL_PSG = 'BLN_Portal_User';
    public static final String ISO = 'ISO-8859-1';
    public static final String EN_US = 'en_US';
    public static final String PERSON_ACCOUNT = 'PersonAccount';
    public static final String EXISTING = 'Existing';
    public static final String NONE = 'None';
    public static final String EMAIL_SENT = 'Email sent';
    public static final String EMAIL_FAILED = 'The email failed to send';
    public static final String NO_ACC_FOUND = 'No matching account found';
    public static final String MULTI_ACC_FOUND = 'Multiple users found with the same email';
    public static final String NO_USER_FOUND = 'No matching user found';
    public static final String B2C_TEMPLATE = 'BLN_CustomForgetPasswordTemplateCommunity';
    public static final String RESET_SUCCESS = 'Password reset successfully';
    public static final String NO_CASE = 'No matching case found';
    public static final String CASE_FOUND ='Case found and email sent';
    public static final String NEW_LOGIN_ERR1 ='We are unable to set your password.Kindly adhere to above mentioned password policy.';
    public static final String NEW_LOGIN_ERR2 ='The passwords are not matching.';
    public static final String NEW_LOGIN_ERR3 ='We are unable to log you in. Please check your email and password.';
    public static final String PORTAL_1 ='Portal_';
    public static final String INITIATED ='Initiated';
    public static final String E_CARD = 'Ecomms Card';
    public static final String DFLT = 'default';
    public static final String BLN = 'Belron';
    public static final String CHALLANGED = 'challenged';
    public static final String VERIFIED = 'verified';
    public static final String NON_VERIFIED = 'not verified';
    public static final String FRICTIONLESS = 'Frictionless';
    public static final String DP_USER = 'Deployment User';
    public static final String SYS_ADMIN = 'System Administrator';
    public static final String AUTHENTICATED = 'Authenticated';
    public static final String AUTHFAIL = 'authenticationFailed';
    public static final String UNAVAILABLE = 'unavailable';
    public static final String NO_PREF = 'noPreference';
    public static final String CHAL_MANDATED = 'challengeMandated';
    public static final String ACCEPT = 'Accept';
    public static final String PER_ACC = 'Person Account';
    public static final String RESERVED = 'Reserved';
    public static final String PENDING = 'Pending';
    public static final String CLOSED = 'Closed';
    public static final String IN_REVIEW = 'In Review';
    public static final String TRAVEL = 'Travel';
    public static final String ARRIVED = 'Arrived';
    public static final String REPLACE = 'replace';
    public static final String REPAIR = 'repair';
    //End
    // Common Http Constants
    public static final String HTTPMETHODTYPEGET = 'GET';
    public static final String HTTPMETHODTYPEPOST  = 'POST';
     public static final String GLASS = 'Glass is on the way';
    
    // Initialize CreditSafe Class 
    public static CreditSafe creditSafeInstance = new CreditSafe();
    
    // Initialize Territory Class    
    public static TerritoryRules territoryRulesInstance = new TerritoryRules();
    
    /*****************************************
    *ClassName : CreditSafe
    *@description This is the Credit safe app constant class
    ****************************************/ 
    public class CreditSafe{
        
        // EndPoint Constants
        public final String creditSafeRequestEndpoint = 'callout:BLN_MulesoftRequest/';
        public final String creditSafeRequestPath = 'gbl/sfdc/v1/company-reports';
        public final String creditSafeRequestQueryString = '?companyRegistrationNumber=';  
        
        // Header Constants
        public final String headerCountryCode = 'country-code';
        public final String headerGenericSystemKey = 'genericSystem';
        public final String headerGenericSystemValue = 'sfdc';
        public final String headerAccountId = 'accountId';
        public final String headerAuthorization = 'Authorization';
        public final String headerBearer = 'Bearer ';
        public final String authorizationType = 'Basic';
        
        // Content-Type Constants
        public final String accessTokenContentTypeKey = 'Content-Type';
        public final String accessTokenContentTypeValue = 'application/x-www-form-urlencoded';
    }
    
    
     /*****************************************
*ClassName : TerritoryRules
*@description This is the TerritoryRules app constant class
****************************************/
    public class TerritoryRules{
        
        // Endpoint Constants
        public final String endpoint = System.URL.getOrgDomainURL().toExternalForm()+'/services/Soap/u/41.0/'+UserInfo.getOrganizationId();
        
        // Content-Type Constants
        public final String contentTypeKey = 'Content-Type';
        public final String contentTypeValue = 'text/xml;charset=UTF-8';
        public final String soapActionKey = 'SOAPAction';
        public final String soapActionValue =  '""';
        // AssignmentRuleHeader parameter Constant
        public final String accountTag = '<urn:sObjects> '+
            '<urn1:type>Account</urn1:type>  '+
            '<urn1:Id>{ACCID}</urn1:Id>   '+
            '</urn:sObjects> ' ;
        
        public final String requestTemplate = '<soapenv:Envelope '+
            'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'+
            ' xmlns:urn="urn:partner.soap.sforce.com"'+
            ' xmlns:urn1="urn:sobject.partner.soap.sforce.com">'+
            '<soapenv:Header> '+
            '<urn:AssignmentRuleHeader> '+ 
            '<urn:useDefaultRule>true</urn:useDefaultRule> '+
            '<urn:assignmentRuleId></urn:assignmentRuleId> '+
            '</urn:AssignmentRuleHeader>  '+
            '<urn:SessionHeader> '+
            '<urn:sessionId>{SESSID}</urn:sessionId> '+
            '</urn:SessionHeader> '+
            '</soapenv:Header> '+
            '<soapenv:Body> '+
            '<urn:update> '+
            ' {ACCLISTS}'+ 
            '</urn:update> '+
            '</soapenv:Body> '+
            '</soapenv:Envelope>';       
        // Integration Logger Constants
        public final String requestHeader = 'Content-Type:' + 'text/xml;charset=UTF-8' + 'SOAPAction:'+ '""';
        public final String targetSystem = 'Salesforce';
    }  
}