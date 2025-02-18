/********************************************************************************************
 * Class Name   : BLN_ForgetPasswordHandler                                                 *
 * Description  : This controller is used in the Reset Password  page.                      *
 *                It is responsible for handling the reset password of Portal Users.        *
 *                                                                                          *
 * @Story       : FOUK-10951 / FOUK-11442 /FOUK-12018                                                  *
 * Created Date : 09-11-2024                                                                *
 * Created By   : Sourabh Bhattacharjee                                                     *
 ********************************************************************************************/
public without sharing class BLN_ForgetPasswordHandler {
	public static Integer count { get; set; }
	@AuraEnabled
	public static Boolean checkMultiplePersonAccount(String emailId) {
		//System.debug('checkMultiplePersonAccount called with emailId: ' + emailId);
		User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
		List<User> personAccList = [SELECT Id,Email,isActive,Profile.Name FROM User WHERE Email = :emailId AND isActive=true AND Profile.Name =: BLN_AppConstants.B2C_PROFILE];
		//  System.debug('Person Accounts found: ' + personAccList.size());
		if (personAccList != null && personAccList.size() > 1) {
			return true;
		} else {
			return false;
		}
	}

	@AuraEnabled
	public static String searchPersonAccAndLogin(
		String emailId,
		String caseNumber
	) {
		// System.debug('searchPersonAccAndLogin called with emailId: ' + emailId + ' and caseNumber: ' + caseNumber);
			Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
				.isAccessible();
			List<Case> caseRecList = [
				SELECT Id, AccountId, ContactEmail
				FROM Case
				WHERE CaseNumber = :caseNumber AND ContactEmail = :emailId
			];
			//  System.debug('Cases found: ' + caseRecList.size());
			if (caseRecList.size() > 0) {
				sendLeadOverlapCompleteNotification1(emailId, caseNumber, null);
				return 'Case found and email sent';
			} else {
				return 'No matching case found';
			}
		
	}

	@AuraEnabled
	public static String sendLeadOverlapCompleteNotification(
		String emailId,
		String accountId
	) {
		// Check if the Account object is accessible
		Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
		// If accountId is provided, search by both emailId and accountId
		if (accountId != null) {
			List<Account> accList = [
				SELECT Id
				FROM Account
				WHERE PersonEmail = :emailId AND Id = :accountId
				LIMIT 1
			];
			if (accList.size() > 0) {
				sendLeadOverlapCompleteNotification1(emailId, null, accountId);
				return 'Email sent';
			} else {
				return 'No matching account found';
			}
		} else {
			// If accountId is not provided, search by emailId only
			User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
			List<User> userList = [
				SELECT Id, ContactId, AccountId
				FROM User
				WHERE Email = :emailId
			];
			if (userList.size() == 1) {
				sendLeadOverlapCompleteNotification1(emailId, null, userList[0].accountId);
				return 'Email sent';
			} else if (userList.size() > 1) {
				return 'Multiple users found with the same email';
			} else {
				return 'No matching user found';
			}
		}
	}

	public static void sendLeadOverlapCompleteNotification1(
		String emailId,
		String caseNumber,
		String accountId
	) {
		// System.debug('sendLeadOverlapCompleteNotification called with emailId: ' + emailId + ', caseNumber: ' + caseNumber + ', accountId: ' + accountId);
		try {
			List<Contact> contacts = new List<Contact>();
			if (emailId != null && caseNumber != null && accountId == null) {
				Contact.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
				contacts = [
					SELECT Id, Email
					FROM Contact
					WHERE
						Email = :emailId
						AND Id IN (
							SELECT ContactId
							FROM Case
							WHERE CaseNumber = :caseNumber
						)
					LIMIT 1
				];
			} else if (emailId != null && accountId != null && caseNumber == null) {
				// Query the Contact based on email and accountId
				//  System.debug('EmailTemplate found: 59' + emailId + ',' + accountId + ',' + caseNumber);
				Contact.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
				contacts = [
					SELECT Id FROM Contact
					WHERE Email = :emailId AND AccountId = :accountId LIMIT 1
				];
			} else {
				//   System.debug('Insufficient parameters provided. At least emailId and either caseId or accountId are required.');
				return;
			}

			if (!contacts.isEmpty()) {
				Contact contact = contacts[0];
				EmailTemplate.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
				EmailTemplate emailTemplate = [
					SELECT Id, Subject, HtmlValue
					FROM EmailTemplate
					WHERE DeveloperName = 'Bln_Customer_community_reset_mail'
					LIMIT 1
				];
				//   System.debug('EmailTemplate found: ' + emailTemplate.Id);
				// OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'servicecloudtest@belronuk.com' LIMIT 1];
				String orgWideEmailAddress = Label.BLN_Portalowa;
				OrgWideEmailAddress[] owea = [
					SELECT Id
					FROM OrgWideEmailAddress
					WHERE Address = :orgWideEmailAddress
					LIMIT 1
				];

				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
				message.setReplyTo('noreply@service.autoglass.co.uk');
				message.setUseSignature(false);
				message.setBccSender(false);
				message.setSaveAsActivity(false);
				message.setTemplateId(emailTemplate.Id);
				message.setToAddresses(new List<String>{ emailId });
				message.setOrgWideEmailAddressId(owea[0].Id);
				message.setTargetObjectId(contact.Id);
				Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ message });
			} else {
				return;
			}
		} catch (Exception e) {
			throw new AuraHandledException(
				'An error occurred in sendLeadOverlapCompleteNotification:  ' +
				e.getMessage()
			);
			// System.debug('An error occurred in sendLeadOverlapCompleteNotification: ' + e.getMessage());
		}
	}
    //FOUK-12018 reset functionality fix
	@AuraEnabled
	public static String resetPassword(String contactId,String newPassword) {
		try {
			String loginMessagePageCompleted = System.Label.Bln_NoActiveAppnt;
			String loginCustomLabel = System.Label.SiteLoginUrl;
			String link;
			User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();	
			User usr = [SELECT Id, ContactId, Username, AccountId, Email FROM User WHERE ContactId = :contactId LIMIT 1];
            //System.debug('USER DATA--->'+usr);
            Integer serviceAppointmentCount=0;
            AggregateResult.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();	
			List<AggregateResult> groupedResults = [
            SELECT AccountId, COUNT(Id) serviceAppointmentCount
            FROM ServiceAppointment
            WHERE AccountId = :usr.AccountId AND BLN_Case__c != null AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect')
            AND Status NOT IN ('Canceled','None','Completed', 'Failed Before Arrive', 'Failed After Arrive')
            GROUP BY AccountId];
		if (!groupedResults.isEmpty()) {
            Integer count = (Integer)groupedResults[0].get('serviceAppointmentCount');
            serviceAppointmentCount = count > 0 ? count : 0;
        } else {
            serviceAppointmentCount = 0;
        }
			//System.debug('COUNT____' + serviceAppointmentCount);
			System.setPassword(usr.Id, newPassword);
			if (serviceAppointmentCount == 0) {
				link = loginMessagePageCompleted;
				//System.debug('Link--0' + link);
			} else if (serviceAppointmentCount == 1) {
                ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
				List<ServiceAppointment> serviceAppointments = [
					SELECT Id, BLN_Case__r.Id
					FROM ServiceAppointment
					WHERE AccountId = :usr.AccountId AND BLN_Case__c != NULL
						AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect')
						AND Status NOT IN (
							'Canceled','None','Completed','Failed Before Arrive','Failed After Arrive'
						)
				];
				Id caseId = serviceAppointments[0].BLN_Case__r != null
					? serviceAppointments[0].BLN_Case__r.Id
					: null;
				Id sID = serviceAppointments[0].Id;
				String communityCaseURL = System.Label.AACommunityCaseURL;
				String caseDetailPageUrl =
					communityCaseURL +
					caseId +
					'/detail?sid=' +
					sID;
				PageReference pr1 = Site.login(
					usr.Username,
					newPassword,
					caseDetailPageUrl
				);
				if (pr1 != null) {
					//System.debug('HERE PR147---->' + pr1);
					link = pr1.getUrl();
					//System.debug('Link--1' + link);
				} else {
					link = 'The email failed to send';
				}
			} else if (serviceAppointmentCount > 1) {
				PageReference pr2 = Site.login(
					usr.Username,
					newPassword,
					loginCustomLabel
				);
				if (pr2 != null) {
					//System.debug('HERE PR147---->' + pr2);
					link = pr2.getUrl();
					//System.debug('Link--1+' + link);
				} else {
					link = 'The email failed to send';
				}
			}
			//System.debug('Link--161' + link);
			return link;
		} catch (Exception e) {
			/*System.debug(
				'HERE 165 exception---->' +
					e.getMessage() +
					'--' +
					e.getLineNumber() +
					'==' +
					e.getCause() +
					'...' +
					e.getStackTraceString()
			);*/
			return 'The email failed to send';
		}
	}

	@AuraEnabled
	public static String getEmailByAccountId(String accountId) {
        User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
		User objUser = [
			SELECT ID, Email, Username
			FROM User
			WHERE AccountId = :accountId
			LIMIT 1
		];
		return objUser.Email;
	}

	@AuraEnabled(cacheable=true)
	public static DateTime getPasswordChangeDateForContact(Id contactId) {  
      
        User associatedUser = [  
            SELECT Id  
            FROM User  
            WHERE ContactId = :contactId  
            LIMIT 1  
        ];  
          
        // If no user is found, return null  
        if (associatedUser == null) {  
            return null;  
        }  
		List<User> auditTrailRecords = [  
            SELECT Id, LastPasswordChangeDate 
            FROM User WHERE Id = :associatedUser.Id];    
        if (!auditTrailRecords.isEmpty()) {  
            return auditTrailRecords[0].LastPasswordChangeDate;  
        }  
        return null;  
    }  


	
}