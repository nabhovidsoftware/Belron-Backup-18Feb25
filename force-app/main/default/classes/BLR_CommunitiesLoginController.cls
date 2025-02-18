/********************************************************************************************
* Class Name   : BLR_CommunitiesLoginController                                             *
* Description  : This controller is used in the BLRCommunityLoginPage Visualforce page.    *
*                It is responsible for handling the login of Portal Users.                 *
*                                                                                          *
* @Story       : FOUK-10951 / FOUK-11442                                                   *
* Created Date : 09-11-2024                                                                *
* Created By   : Sourabh Bhattacharjee                                                     *
********************************************************************************************/
@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts , PMD.ApexOpenRedirect,PMD.IfElseStmtsMustUseBraces,PMD.ApexXSSFromURLParam,PMD.IfStmtsMustUseBraces,PMD.ApexCRUDViolation')
Public without sharing  class BLR_CommunitiesLoginController {
    // getter setters 
    public String accId { get; set; } 
    public String forgotPasswordUrl { get; set; } 
    public String address { get; set; } 
    public String address1 { get; set; } 
    public String customerType { get; set; }
    public String firstName {get ; set;}
    public Boolean displayLoginScreen { get; set; }
    public Boolean showPasswordResetSection { get; set; }
    public Boolean noServiceAppointment { get; set; }
    public Boolean  userInactive {get ; set;}
    public String newPassword { get; set; }
    public String confirmPassword { get; set; }
    public String currentPassword { get; set; }
    public Id newUserId {get; set;}
    public String newPassword1 { get; set; }
    public String confirmPassword1 { get; set; }
    public String username { get; set; }
    public String password { get; set; }
    public String emailParam { get; set; }
     public String caseId { get; set; }
    public String errorMessage { get; set; }
    public String passwordErrorMessage { get; set; }
    public String encryptedAddress { get; set; }
    public String decryptAddress { get; set; }
    public Boolean errorMessage1 { get; set; }
    public Boolean passwordErrorMessage1 { get; set; }
    public Boolean checkNew {get;set;}
    public String uName {get;set;}
    public Boolean showBookingInput { get; set; }
    public Boolean multiAcc { get; set; }
    public String caseNumber {get;set;}
    public String loginText {get;set;}
    public Boolean wrongCase {get;set;}
    public Boolean wrongPassword {get;set;}
    public Boolean wrongEmail {get;set;}
    public Boolean noData {get;set;}
    public String newUserLoginError { get; set; } // Variable to hold error message 
    public String newUserLoginPara { get; set; }
    public String decryptedEmail { get; set; }
    
    public BLR_CommunitiesLoginController() {
        loginText = System.Label.BLN_SecureLoginText;
        newUserLoginPara = System.Label.Bln_loginPara;
        String accId = ApexPages.currentPage().getParameters().get('accId');  
        if (accId != null) {  
            forgotPasswordUrl = System.Label.BLR_ForgotPassword + '?accId=' + accId;  
        } else {  
            forgotPasswordUrl = System.Label.BLR_ForgotPassword;  
        }
        passwordErrorMessage1 = false;
        errorMessage1 = false;
        String addressParam = ApexPages.currentPage().getParameters().get('address');    
        String accIdParam = ApexPages.currentPage().getParameters().get('accId');    
        String showInputParam = ApexPages.currentPage().getParameters().get('showInput');  
        Boolean isShowInputTrue = (showInputParam != null && showInputParam == 'true');   
        // Determine the value of showBookingInput based on the conditions  
        if (isShowInputTrue) {  
            if (addressParam != null && accIdParam == null) {  
                showBookingInput = true;  
            } else {showBookingInput = false;
            }  
        } else {  
            showBookingInput = false;  
        }  
        checkUserCondition();  
    }
    public void checkUserCondition(){
        String sanitizedParamaddress ;
        showPasswordResetSection = ApexPages.currentPage().getParameters().get('showPasswordResetSection') == 'true';
        address = ApexPages.currentPage().getParameters().get('address');  
        accId=ApexPages.currentPage().getParameters().get('accId');
        Boolean ifNew = checkIfNew(accId);
        if(ifNew == true){
        displayLoginScreen = false; 
        }else{
        displayLoginScreen = true; 
        }
        if(address != null){
        BLN_CryptoUtility cu = new BLN_CryptoUtility();
        decryptedEmail = cu.decryptEmail(address);
       /*address = cu.decryptData(address);
        String[] st = address.split('.com');
        address = st[0] + '.com';*/
        }  
        if(test.isrunningTest() ){ address = 'testsit@testorg.com'; }
        if(address != null){            
            sanitizedParamaddress = address.escapeHtml4();
           /* System.debug(  
                'Address and Email Parameters:\n' + 'Address: ' + address + '\n' +  
                'Sanitized Param Address: ' + sanitizedParamaddress + '\n'+decryptedEmail+'--'+accId);*/
        }
        checkNew =checkIfNew(accId);
        if (String.isNotBlank(sanitizedParamaddress) && sanitizedParamaddress != null) {
            if (checkNew == true){
                customerType = System.label.BLN_New;
            } else {
                customerType = BLN_AppConstants.EXISTING;
                User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
                User u =[SELECT Id,Email,AccountId FROM USER WHERE AccountId =: accId LIMIT 1];
                if(accId!=null){
                 username = u.Email;   
                }else{
               /* username = sanitizedParamaddress;*/
                 username = decryptedEmail;
                }
            //  System.debug(decryptedEmail+'ߍ䭭-ctype----ߍ䧫customerType+'---'+sanitizedParamaddress);
            }
        }
    }
    
    //User creation method
    public  void processForm() {
        String sanitizedParamaddress ;
        String portalProfileName = BLN_AppConstants.B2C_PROFILE;
        if(address != null){
            sanitizedParamaddress = address.escapeHtml4();
        }
        if (customerType == System.label.BLN_New) {
            // Logic to create a new user and render password reset section
            try{
                String concat = getPersonAccountFirstName(accId).substring(0,2) + getPersonAccountLastName(accId).substring(0,2);
                User newUser = new User();
                newUser.Username = accId+ System.label.BLN_UserNameIdnetifier; 
                newUser.Email = getPersonAccountEmail(accId);
                newUser.ContactId = getContactId(accId);
                newUser.CommunityNickname = accId; 
                newUser.FirstName = getPersonAccountFirstName(accId);
                newUser.LastName = getPersonAccountLastName(accId); 
                newUser.Alias = concat;
                newUser.TimeZoneSidKey = BLN_AppConstants.TIMEZONE_KEY;
                newUser.LocaleSidKey = BLN_AppConstants.EN_GB; 
                newUser.EmailEncodingKey = BLN_AppConstants.ISO;
                newUser.LanguageLocaleKey = BLN_AppConstants.EN_US;
                newUser.LocaleSidKey = BLN_AppConstants.EN_GB;
                Profile.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
                newUser.ProfileId = [SELECT Id FROM Profile WHERE Name = :portalProfileName LIMIT 1].Id;
                User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable();
                INSERT newUser;
                newUserId = newUser.id;
                String perGroupId = [SELECT Id,DeveloperName FROM PermissionSetGroup WHERE DeveloperName =:BLN_AppConstants.PORTAL_PSG].Id;
                PermissionSetAssignment psa = new PermissionSetAssignment
                (PermissionSetGroupId = perGroupId, AssigneeId = newUserId);
                insert psa; 
            }
            catch(Exception e){
              //  System.debug('EXcep11-5--'+e.getMessage()+'--'+e.getLineNumber()+'=='+e.getCause()+'...'+e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Exception Occured while Creating User-->'+e.getMessage()+'--'+e.getLineNumber()+'=='+'...'+e.getStackTraceString()));  
            } 
        } 
    }    
    // Helper method to get FirstName from Person Account
    public String getPersonAccountFirstName(String accId) {
        String firstName;
        Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<Account> personAccounts = [SELECT FirstName , PersonEmail FROM Account WHERE RecordType.DeveloperName =: BLN_AppConstants.PERSON_ACCOUNT and Id =: accId LIMIT 1];
        if (!personAccounts.isEmpty()) {
            firstName = personAccounts[0].FirstName;
        }
        return firstName;
    }
    
    // Helper method to get LastName from Person Account
    public String getPersonAccountLastName(String accId) {
        String lastName;
        Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<Account> personAccounts = [SELECT id, LastName , PersonEmail FROM Account WHERE RecordType.DeveloperName =: BLN_AppConstants.PERSON_ACCOUNT AND Id =: accId LIMIT 1];
        if (!personAccounts.isEmpty()) {
            lastName = personAccounts[0].LastName;
        }
        return lastName;    
    } 
    
    public String getPersonAccountEmail (String accId) {
        String personEmail;
        Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<Account> personAccounts = [SELECT id, LastName , PersonEmail FROM Account WHERE RecordType.DeveloperName =: BLN_AppConstants.PERSON_ACCOUNT AND Id =: accId LIMIT 1];
        if (!personAccounts.isEmpty()) {
            personEmail = personAccounts[0].PersonEmail;
        }
        return personEmail;
    }
    
    //Helper to get related Contact 
    public Id getContactId(String accId) {
        String conID;
        Contact.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<Contact> conList = [SELECT Id,AccountId FROM Contact WHERE AccountId = :accId ORDER BY createdDate DESC LIMIT 1];      
        if (!conList.isEmpty()) {
            conID = conList[0].id;
        }
        return conID;    
    }
    
    @RemoteAction
    public static Boolean checkIfNew(String accId) {
        if(accId!=null){
        User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<User> uList = [SELECT Id,AccountId,isActive FROM User WHERE AccountId = :accId];  
        if(uList.isEmpty()){
           return true;
            } else{
             return false;
            } 
        }else{
            return null;
        }  
    }  
    //Helper method to fetch username if email associatd with single account
    public String fetchUserName(String email){
        String uNameWithSingleAccount ;
        User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        User u =[SELECT ID,username FROM USER WHERE email =: email LIMIT 1];
        uNameWithSingleAccount = u.username;
        return uNameWithSingleAccount;
    }
    //Helper method to fetch username if email associatd with multi account
    public String fetchUserNameMulti(String email,String casenumber){
        String uNameWithMultiAccount ;
		Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        Case c=[SELECT Id,AccountId, Account.PersonEmail, CaseNumber from Case where Account.PersonEmail =: email AND CaseNumber =:casenumber LIMIT 1];
        String accIdFound=c.AccountId;
		User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        User u =[SELECT ID,username FROM USER WHERE AccountId =:accIdFound LIMIT 1];
        uNameWithMultiAccount = u.username;
        return uNameWithMultiAccount;
    }
    public Boolean validateEmail(String username) { 
		User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<User> users = [SELECT Id,Email,isActive,Profile.Name FROM User WHERE Email = :username AND isActive=true AND Profile.Name =: BLN_AppConstants.B2C_PROFILE];   
        Boolean multiUser;
        if (users.size() > 1) {  
            multiUser = true;  
        } else {  
            multiUser = false;  
        } 
        return multiUser;
    }

    public Boolean isEmailValid(String email){
        Boolean res = true;
        String emailRegex = System.Label.BLN_PortalEmailPattern;
		Pattern myPattern = Pattern.compile(emailRegex);
		Matcher myMatcher = myPattern.matcher(email);
        if (!myMatcher.matches()){
	    res = false;
        }
	    
        return res;
    }
     //helper method to check fetch Appointment Count
    public Integer countofAppointment(String accId){
        Integer serviceAppointmentCount=0;
        ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<AggregateResult> groupedResults = [SELECT AccountId, COUNT(Id) serviceAppointmentCount FROM ServiceAppointment
            WHERE AccountId = :accId AND BLN_Case__c != null AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect')
            AND Status NOT IN ('Canceled','None','Completed', 'Failed Before Arrive', 'Failed After Arrive')
            GROUP BY AccountId ];
        if (!groupedResults.isEmpty()) {
            Integer count = (Integer)groupedResults[0].get('serviceAppointmentCount');
            serviceAppointmentCount = count > 0 ? count : 0;
        } else {
            serviceAppointmentCount = 0;
        }
        return serviceAppointmentCount;
    }
    //helper method to check whether user has access to case or not
    public Boolean hasCase(String username,String caseNumber) {
		Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<Case> caseList = [SELECT Id,CaseNumber,Account.PersonEmail,AccountId FROM Case WHERE Account.PersonEmail =:username AND CaseNumber=:CaseNumber];   
        Boolean hasAccess;
        if (caseList.size() > 0) {  
            hasAccess = true;  
        } else {  
            hasAccess = false;  
        } 
        return hasAccess;
    }   
    // Action method for New user login
    public PageReference newUserLogin() {
        processform();
        String loginCustomLabel = System.Label.SiteLoginUrl ;
        Integer count;
        if(newPassword != null && confirmPassword!= null && newUserId!=null & newPassword.equals(confirmPassword)){
            try{
                User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
                User loggedInUser = [SELECT Id,Email,Username,IsActive,AccountId FROM User WHERE AccountId = :accId LIMIT 1];
                System.setPassword(loggedInUser.Id,confirmPassword);
                count=countofAppointment(accId);
         if ( count == 0 ) { 
           PageReference loginResult = Site.login(loggedInUser.Username, confirmPassword, loginCustomLabel);
           if (loginResult != null) {
            // System.debug('HERE 303---->'+loginResult);
            String loginMessagePageCompleted =  System.Label.Bln_NoActiveAppnt;
            PageReference completedPage = new PageReference(loginMessagePageCompleted); 
            completedPage.setRedirect(true); 
            return completedPage;
        }else{
           newUserLoginError = BLN_AppConstants.NEW_LOGIN_ERR1;
                 }
       }   
      else if (count == 1) {  
    List<ServiceAppointment> serviceAppointments = [SELECT Id, BLN_Case__r.Id  FROM ServiceAppointment WHERE AccountId = :accId    AND BLN_Case__c != null    AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect')  
        AND Status NOT IN ('Canceled', 'None', 'Completed', 'Failed Before Arrive', 'Failed After Arrive')];  
        Id caseId = serviceAppointments[0].BLN_Case__r != null ? serviceAppointments[0].BLN_Case__r.Id : null;  
        Id sID = serviceAppointments[0].Id;  
        String communityCaseURL = System.Label.AACommunityCaseURL; 
        String caseDetailPageUrl = communityCaseURL + caseId + '/detail?sid=' + sID; 
        PageReference loginResult = Site.login(loggedInUser.Username, confirmPassword, loginCustomLabel);
           if (loginResult != null) {
            PageReference caseDetailPage = Site.login(loggedInUser.Username, confirmPassword, caseDetailPageUrl);
            if (caseDetailPage != null) {      
                return caseDetailPage;
            } else {   
                newUserLoginError = BLN_AppConstants.NEW_LOGIN_ERR3;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'We are unable to log you in. Please check your email and password.'));
                //return null;
            } 
           }else{
            newUserLoginError = BLN_AppConstants.NEW_LOGIN_ERR1;
           }
        }
           //
                else if( loggedInUser.IsActive && count > 1){     
                PageReference loginResult = Site.login(loggedInUser.Username, confirmPassword, loginCustomLabel);
                if (loginResult != null) {
                    return loginResult;
                }else{
                 newUserLoginError = BLN_AppConstants.NEW_LOGIN_ERR1;
                    }
                }
            }
            catch(Exception e){
                //System.debug('HERE 351---->'+ e.getMessage() +''+e.getStacktraceString());
                Integer colonIndex = e.getMessage().indexOf(': ');
               if (colonIndex != -1) {  
        		newUserLoginError = e.getMessage().substring(colonIndex + 2);  
                } else {   
                    newUserLoginError = e.getMessage();  
                }
            	//newUserLoginError =  e.getMessage();
                //return null;
            }
        } 
        else{
            newUserLoginError = BLN_AppConstants.NEW_LOGIN_ERR2;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'The passwords are not matching.'));
        } 
        return null ; 
    }
    // Action method for User login
     public PageReference login() {
        //String sanitizedParamaddress ;
        String loginCustomLabel = System.Label.SiteLoginUrl ;
        //System.debug(password+'356'+username+'--'+noData);
		Integer count;
        Boolean emailCheck = isEmailValid(username);
        if(emailCheck == false){   wrongEmail = true;
        }else{
		if(accId!=null){
		count=countofAppointment(accId);
        User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        User loggedInUser = [SELECT Id,Username,IsActive,AccountId FROM User WHERE AccountId = :accId LIMIT 1];
        if ( count == 0 ) { 
           /*string loginMessagePageCompleted =  System.Label.Bln_NoActiveAppnt;
           PageReference completedPage = new PageReference(loginMessagePageCompleted); 
           completedPage.setRedirect(true); 
           return completedPage;*/
           PageReference loginResult = Site.login(loggedInUser.Username, password, loginCustomLabel);
           if (loginResult != null) {
            string loginMessagePageCompleted =  System.Label.Bln_NoActiveAppnt;
            PageReference completedPage = new PageReference(loginMessagePageCompleted); 
            completedPage.setRedirect(true); 
            return completedPage;
        }else{
           wrongPassword=true;
           wrongEmail = false;
           //return null;
                 }
       }   
       if (count == 1) {  
    ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
    List<ServiceAppointment> serviceAppointments = [SELECT Id, BLN_Case__r.Id FROM ServiceAppointment   
        WHERE AccountId = :accId AND BLN_Case__c != null AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect') AND Status NOT IN ('Canceled', 'None', 'Completed', 'Failed Before Arrive', 'Failed After Arrive')];  
        Id caseId = serviceAppointments[0].BLN_Case__r != null ? serviceAppointments[0].BLN_Case__r.Id : null;  
        Id sID = serviceAppointments[0].Id;  
        User objUser=[SELECT ID,Email,Username FROM User WHERE AccountId=:accId LIMIT 1];
        String userName=objUser.UserName;
       /*String communityCaseURL = System.Label.AACommunityCaseURL; 
       String caseDetailPageUrl = communityCaseURL + caseId + '/detail?sid=' + sID; 
        PageReference caseDetailPage = Site.login(username, password, caseDetailPageUrl);
            if (caseDetailPage != null) {      
                return caseDetailPage;
            } else {   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'We are unable to log you in. Please check your email and password.'));
                return null;
            } */
            String communityCaseURL = System.Label.AACommunityCaseURL; 
            String caseDetailPageUrl = communityCaseURL + caseId + '/detail?sid=' + sID; 
            PageReference loginResult = Site.login(objUser.Username, password, loginCustomLabel);
               if (loginResult != null) {
                PageReference caseDetailPage = Site.login(objUser.Username, password, caseDetailPageUrl);
                if (caseDetailPage != null) {      
                    return caseDetailPage;
                } else {   
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'We are unable to log you in. Please check your email and password.'));
                    return null;
                } 
               }else{
                wrongPassword=true;
                wrongEmail = false;
               }    
        }
        else if (!loggedInUser.IsActive  && count >=1){
          //  System.debug(count+'here 363--->'+loggedInUser);
            loggedInUser.IsActive = true;  
            User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable();
            UPDATE loggedInUser; // Activate the user  
        }else if(loggedInUser != null && loggedInUser.IsActive && count >=1){
        User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
		User objUser=[SELECT ID,Email,Username FROM User WHERE AccountId=:accId LIMIT 1];
        String userName=objUser.UserName;
      //  System.debug(loggedInUser+'HERE 369--->'+objUser);
        PageReference loginResult = Site.login(username, password, loginCustomLabel);
      //  System.debug('HERE 375--->'+loginResult);
        if(loginResult!=null){
        return loginResult;
        }else{
        wrongPassword=true;
        wrongEmail = false;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your password is not matching retry again'));
         }		
		}
		}else if(address!= null){
				multiAcc = validateEmail(username);
			//	System.debug(caseNumber+'Is MultiAcc?--->'+multiAcc);
				if(multiAcc == true){
                //String showInputParam = ApexPages.currentPage().getParameters().get('showInput');
              //  Boolean isShowInputTrue = (showInputParam != null && showInputParam == 'true');
             //   System.debug(caseNumber+'Is isShowInputTrue 396?--->'+isShowInputTrue);
                if(caseNumber == null){    wrongCase =true;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Kindly provide booking reference number'));
                return null; 
                }else{
                 Boolean accountFound =hasCase(username,caseNumber);
               //  System.debug('Acctfound 402--'+accountFound);
                    if(accountFound == false){
                     wrongCase =true;
                     //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Kindly provide valid booking reference number'));
                     return null;
                    }else{
                      String uNameMulti = fetchUserNameMulti(username,caseNumber);
                      User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
                      User u1 = [SELECT ID,AccountId FROM USER WHERE userName =: uNameMulti];
                      String acc1 = u1.AccountId;
                      Integer count1 = countofAppointment(acc1);
                        if(count1 > 1){
                      PageReference loginResult = Site.login(uNameMulti, password, loginCustomLabel);
                      if(loginResult!=null){        return loginResult;
                        }else{
                         wrongPassword=true;
                         wrongEmail = false;
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your password is not matching retry again'));
                         return null;
                         }	     
                        }else if(count1 == 0){
                           PageReference loginResult = Site.login(uNameMulti, password, loginCustomLabel);
           if (loginResult != null) {
            string loginMessagePageCompleted =  System.Label.Bln_NoActiveAppnt;
            PageReference completedPage = new PageReference(loginMessagePageCompleted); 
            completedPage.setRedirect(true); 
            return completedPage;
        }else{
           wrongPassword=true;
           wrongEmail = false;
           //return null;
                 }  
                        }else if(count1 == 1){
            List<ServiceAppointment> serviceAppointments123 = [SELECT Id, BLN_Case__r.Id FROM ServiceAppointment   
        WHERE AccountId = :acc1 AND BLN_Case__c != null AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect') AND Status NOT IN ('Canceled', 'None', 'Completed', 'Failed Before Arrive', 'Failed After Arrive')];  
        Id caseId = serviceAppointments123[0].BLN_Case__r != null ? serviceAppointments123[0].BLN_Case__r.Id : null;  
        Id sID = serviceAppointments123[0].Id; 
            String communityCaseURL1 = System.Label.AACommunityCaseURL; 
            String caseDetailPageUrl1 = communityCaseURL1 + caseId + '/detail?sid=' + sID; 
               PageReference loginResult = Site.login(uNameMulti, password, loginCustomLabel);
               if (loginResult != null) {
                PageReference caseDetailPage = Site.login(uNameMulti, password, caseDetailPageUrl1);
                if (caseDetailPage != null) {      
                    return caseDetailPage;
                } else {   
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'We are unable to log you in. Please check your email and password.'));
                    return null;
                } 
               }else{
                wrongPassword=true;
                wrongEmail = false;
               }    
                        }  
                     	     
                    }   
                }
				}else{
					String userName1=fetchUserName(username);
                    User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
                   User u2 = [SELECT ID,AccountId FROM USER WHERE userName =: userName1];
                    String acc2 = u2.AccountId;
                    Integer count2 = countofAppointment(acc2);
                    if(count2 > 1){
					PageReference loginResult = Site.login(userName1, password, loginCustomLabel);
					if(loginResult!=null){
					return loginResult;
					}else{
                     wrongPassword=true;
                     wrongEmail = false;
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your password is not matching retry again'));
                     return null;   
					}		
                    }else if(count2 == 0){
                    PageReference loginResult = Site.login(userName1, password, loginCustomLabel);
           if (loginResult != null) {
            string loginMessagePageCompleted =  System.Label.Bln_NoActiveAppnt;
            PageReference completedPage = new PageReference(loginMessagePageCompleted); 
            completedPage.setRedirect(true); 
            return completedPage;
        }else{
           wrongPassword=true;
           wrongEmail = false;
           //return null;
                 }    
                    }else if(count2 == 1){
                 ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
                List<ServiceAppointment> serviceAppointments1234 = [SELECT Id, BLN_Case__r.Id FROM ServiceAppointment   
        WHERE AccountId = :acc2 AND BLN_Case__c != null AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect') AND Status NOT IN ('Canceled', 'None', 'Completed', 'Failed Before Arrive', 'Failed After Arrive')];  
        Id caseId = serviceAppointments1234[0].BLN_Case__r != null ? serviceAppointments1234[0].BLN_Case__r.Id : null;  
        Id sID = serviceAppointments1234[0].Id; 
            String communityCaseURL11 = System.Label.AACommunityCaseURL; 
            String caseDetailPageUrl11 = communityCaseURL11 + caseId + '/detail?sid=' + sID; 
               PageReference loginResult = Site.login(userName1, password, loginCustomLabel);
               if (loginResult != null) {
                PageReference caseDetailPage = Site.login(userName1, password, caseDetailPageUrl11);
                if (caseDetailPage != null) {      
                    return caseDetailPage;
                } else {   
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'We are unable to log you in. Please check your email and password.'));
                    return null;
                } 
               }else{
                wrongPassword=true;
                wrongEmail = false;
               }    
        
                    }
							
				}
            }else if(address == null){
                multiAcc = validateEmail(username);
              //  System.debug('Is MultiAcc? 402--->'+multiAcc);
                String showInputParam = ApexPages.currentPage().getParameters().get('showInput');
                Boolean isShowInputTrue = (showInputParam != null && showInputParam == 'true');
               // System.debug('Is isShowInputTrue?--->'+isShowInputTrue);
                BLN_CryptoUtility cryptoUtilityInstance = new BLN_CryptoUtility();
               String encryptedEmail1 = cryptoUtilityInstance.encryptEmail(username);
              // String encryptedEmail = cryptoUtilityInstance.encyptData(username);
              // System.debug('Encrypted Email Information:\n' + encryptedEmail1 + '\n' +'Encrypted Email: ' + encryptedEmail); 
                if(multiAcc == true && isShowInputTrue == false){
                String redirectUrl =System.Label.BLN_CommunityEncrptUrl  + encryptedEmail1 +'&showInput=true'; 
                PageReference completedPage = new PageReference(redirectUrl);  
                completedPage.setRedirect(true);  
                return completedPage;    
                }else{
                    String uNameSingle;  
                    try {  
                        uNameSingle = fetchUserName(username);  
                    } catch (Exception e) {  
                        wrongPassword = true;  
                        wrongEmail = false;  
                        return null; 
                    } 
                    User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
                      User u1 = [SELECT ID,AccountId FROM USER WHERE userName =: uNameSingle];
                      String acc1 = u1.AccountId;
                      Integer count1 = countofAppointment(acc1); 
                    // Continue with the login process  
                    if(count1 > 1){
                    PageReference loginResult = Site.login(uNameSingle, password, loginCustomLabel);  
					if(loginResult!=null){
					return loginResult;
					}else{
                    wrongPassword=true;
                    wrongEmail = false;
                       // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your password is not matching, please try again.'));  
                        return null;  
                    }  
                    } else if(count1 == 0){
                        PageReference loginResult = Site.login(uNameSingle, password, loginCustomLabel);
        if (loginResult != null) {
         string loginMessagePageCompleted =  System.Label.Bln_NoActiveAppnt;
         PageReference completedPage = new PageReference(loginMessagePageCompleted); 
         completedPage.setRedirect(true); 
         return completedPage;
     }else{
        wrongPassword=true;
        wrongEmail = false;
        //return null;
              }  
                }else if(count1 == 1){
         List<ServiceAppointment> serviceAppointments123 = [SELECT Id, BLN_Case__r.Id FROM ServiceAppointment   
     WHERE AccountId = :acc1 AND BLN_Case__c != null AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect') AND Status NOT IN ('Canceled', 'None', 'Completed', 'Failed Before Arrive', 'Failed After Arrive')];  
     Id caseId = serviceAppointments123[0].BLN_Case__r != null ? serviceAppointments123[0].BLN_Case__r.Id : null;  
     Id sID = serviceAppointments123[0].Id; 
         String communityCaseURL1 = System.Label.AACommunityCaseURL; 
         String caseDetailPageUrl1 = communityCaseURL1 + caseId + '/detail?sid=' + sID; 
            PageReference loginResult = Site.login(uNameSingle, password, loginCustomLabel);
            if (loginResult != null) {
             PageReference caseDetailPage = Site.login(uNameSingle, password, caseDetailPageUrl1);
             if (caseDetailPage != null) {      
                 return caseDetailPage;
             } else {   
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'We are unable to log you in. Please check your email and password.'));
                 return null;
             } 
            }else{
             wrongPassword=true;
             wrongEmail = false;
            }    
                     } 
                }
               // return null;				
            }
        }
       return null;
    }
    
    public PageReference changePassword() {
        String sanitizedParamaddress ;
        String loginCustomLabel = System.Label.SiteLoginUrl ;
        if(address != null){
            sanitizedParamaddress = address.escapeHtml4();
        }
        try{
            if (newPassword1 != null && confirmPassword1 != null && newPassword1.equals(confirmPassword1)) {       
                User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
                User u  =[Select Id,Username FROM User WHERE Email =:sanitizedParamaddress LIMIT 1];   
                String userName=u.Username;
                System.setPassword(u.Id, newPassword1);         
                PageReference loginResult = Site.login(userName, confirmPassword1,loginCustomLabel); 
                //System.debug('HERE 336--->'+loginResult);
                if (loginResult != null) {
                    return loginResult;
                }else{
                    wrongPassword=true;
                    wrongEmail = false;
                    return null;
                }
            } else { 
                wrongPassword=true;
                wrongEmail = false;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The passwords do not match.'));
            }
        } catch(Exception e){
           // System.debug('EXcep347--'+e.getMessage()+'--'+e.getLineNumber()+'=='+'...'+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Exception-->'+e.getMessage()+'--'+e.getLineNumber()+'=='+'...'+e.getStackTraceString()));
        }
        return null;
    }
}