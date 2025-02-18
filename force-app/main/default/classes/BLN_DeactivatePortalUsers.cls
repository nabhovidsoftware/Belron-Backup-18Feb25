/********************************************************************************************
 * Class Name   : BLN_DeactivatePortalUsers                                                 *
 * Description  : This controller is used in the BLN_DeactivatePortalUsers scheduled job    *
 * @Story       : FOUK-5170/FOUK-12817                                                      *
 * Created Date : 10-02-2025                                                                *
 * Created By   : Sourabh Bhattacharjee                                                     *
 ********************************************************************************************/
public class BLN_DeactivatePortalUsers implements Database.Batchable<Sobject>, Database.Stateful, Database.RaisesPlatformEvents {
	public List<User> deactivatedUsers = new List<User>();
	public List<Account> start(Database.BatchableContext bc) {
		Set<Id> accountIds = new Set<Id>();
		User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
		List<User> users = [
			SELECT ID, AccountId, Profile.Name, isActive
			FROM USER
			WHERE
				AccountId != NULL
				AND Profile.Name = :BLN_AppConstants.B2C_PROFILE
				AND isActive = TRUE
		];
		for (User u : users) {
			accountIds.add(u.AccountId);
		}
		//System.debug(accountIds.size()+'accountIds ' + accountIds);
		//  Fetch accounts where there is at least one Service Appointment
		List<Account> accountsWithAppointments = new List<Account>();
		Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
		if (!accountIds.isEmpty()) {
			accountsWithAppointments = [
				SELECT ID
				FROM Account
				WHERE
					ID IN (
						SELECT AccountId
						FROM ServiceAppointment
						WHERE AccountId IN :accountIds
					)
					AND IsCustomerPortal = TRUE
					AND IsPersonAccount = TRUE
			];
		}
		//System.debug(accountsWithAppointments.size()+'<--accountsWithAppointments==>'+ accountsWithAppointments);
		return accountsWithAppointments;
	}

	public void execute(
		Database.BatchableContext bc,
		List<Account> accountsWithAppointments
	) {
		ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
		List<ServiceAppointment> allAppointments = [
			SELECT
				ID,
				AccountId,
				Status,
				Account.IsPersonAccount,
				Account.IsCustomerPortal
			FROM ServiceAppointment
			WHERE
				AccountId IN :accountsWithAppointments
				AND Account.IsCustomerPortal = TRUE
				AND AccountId != NULL
				AND Account.IsPersonAccount = TRUE
		];
		//System.debug('SIZE--->'+allAppointments.size());
		String labelValue = System.Label.AADeactivation_Status;
        List<String> statusList = labelValue.split(','); 
        Set<String> allowedStatuses = new Set<String>(statusList);
		Set<Id> qualifyingAccountIds = new Set<Id>();
		Map<Id, Set<String>> accountStatusMap = new Map<Id, Set<String>>();
		Set<Id> accountsWithHighBalance = new Set<Id>();
		Set<Id> accountsWithLowBalance = new Set<Id>();
		Set<Id> finalQualifiedAccounts = new Set<Id>();
		for (ServiceAppointment app : allAppointments) {
			if (!accountStatusMap.containsKey(app.AccountId)) {
				accountStatusMap.put(app.AccountId, new Set<String>());
			}
			accountStatusMap.get(app.AccountId).add(app.Status);
		}
		//System.debug('Account Status Map: ' + accountStatusMap);
		for (Id accountId : accountStatusMap.keySet()) {
			Set<String> appointmentStatuses = accountStatusMap.get(accountId);
			//System.debug('AccountId: ' + accountId + ', Appointment Statuses: ' + appointmentStatuses);
			// Check if all statuses for this account are within the allowed set
			Boolean allStatusesAllowed = true;
			for (String status : appointmentStatuses) {
				if (!allowedStatuses.contains(status)) {
					allStatusesAllowed = false;
					break;
				}
			}
			if (allStatusesAllowed) {
				qualifyingAccountIds.add(accountId);
			}
		}
		//System.debug('Qualifying Account IDs: ' + qualifyingAccountIds);
		List<AggregateResult> groupedResults = [
			SELECT AccountId, SUM(BLN_OutstandingBalance__c)
			FROM Case
			WHERE
				Account.IsCustomerPortal = TRUE
				AND Account.IsPersonAccount = TRUE
				AND AccountId IN :qualifyingAccountIds
			GROUP BY AccountId
		];
	    //System.debug('groupedResults-->'+groupedResults);
		for (AggregateResult result : groupedResults) {
			Id accountId = (Id) result.get('AccountId');
			Decimal totalBalance = (Decimal) result.get('expr0');
			if (totalBalance > 2.99) {
				accountsWithHighBalance.add(accountId);
			} else {
				accountsWithLowBalance.add(accountId);
			}
		}
		//System.debug(accountsWithHighBalance.size()+'Accounts with high balance: ' + accountsWithHighBalance);
		//System.debug(accountsWithLowBalance.size()+'Accounts with low balance: ' + accountsWithLowBalance);
		ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
		if (!accountsWithHighBalance.isEmpty()) {   
    List<AggregateResult> latestAppointments = [SELECT AccountId, MAX(EarliestStartTime) latestStart FROM ServiceAppointment  
                                                WHERE AccountId IN :accountsWithHighBalance GROUP BY AccountId];  
  
    for (AggregateResult ar : latestAppointments) {  
        Id accountId = (Id) ar.get('AccountId');  
        DateTime latestStartTime = (DateTime) ar.get('latestStart'); 
        // Check if the latest appointment date is more than 7 days old  
        if (latestStartTime != null && latestStartTime < System.today().addDays(-7)) {  
            finalQualifiedAccounts.add(accountId);  
           // System.debug('Account added to finalQualifiedAccounts: ' + accountId);  
        }  
    }  
  //  System.debug(finalQualifiedAccounts.size() + ' finalQualifiedAccounts-->' + finalQualifiedAccounts);  
}   
		//System.debug(finalQualifiedAccounts.size()+'Final qualified accounts: ' + finalQualifiedAccounts);
		Set<Id> allAccounts = new Set<Id>();
		allAccounts.addAll(finalQualifiedAccounts);
		allAccounts.addAll(accountsWithLowBalance);
		User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
		List<User> usersToDeactivate = [
			SELECT ID,Name, AccountId, isActive, Email
			FROM USER
			WHERE AccountId IN :allAccounts AND isActive = TRUE
		];
		if (!usersToDeactivate.isEmpty()) {
			for (User u : usersToDeactivate) {
				u.IsActive = false;
			}
			try {
				update usersToDeactivate;
				deactivatedUsers.addAll(usersToDeactivate);
			 //System.debug('Successfully deactivated users: ' + usersToDeactivate);
			} catch (Exception e) {
				BLN_ExceptionLogger.captureException(e);
			}
		}
	}

	public void finish(Database.BatchableContext bc) {
		AsyncApexJob.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
		OrgWideEmailAddress.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
		User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
		/*USER dUser = [
			SELECT ID, isActive, Profile.Name, NAME,Email
			FROM USER
			WHERE
				NAME =: BLN_AppConstants.DP_USER
				AND isActive = TRUE
				AND Profile.Name =: BLN_AppConstants.SYS_ADMIN
		];*/
        DateTime dt = DateTime.now();
        String dateTimeStr = dt.format('yyyy/MM/dd hh:mm:ss');
        
		AsyncApexJob a = [
			SELECT
				ID,
				Status,
				ExtendedStatus,
				NumberOfErrors,
				JobItemsProcessed,
				TotalJobItems,
				CreatedBy.Email
			FROM AsyncApexJob
			WHERE ID = :BC.getJobId()
		];
		OrgWideEmailAddress orgWideAddr = [
			SELECT Id
			FROM OrgWideEmailAddress
			WHERE Address = :System.label.BLN_Portalowa
			LIMIT 1
		];
		//System.debug('deactivatedUsers'+deactivatedUsers);
		String body;
		if (deactivatedUsers.size() > 0) {
			body = '<html><body>';
			body += '<h2>Deactivated Users Report</h2>';
			body += '<p>The following users have been deactivated:</p>';
			body += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">';
			body += '<tr><th>Name</th><th>Email</th></tr>';

			for (User u : deactivatedUsers) {
				body += '<tr>';
				body += '<td>' + u.Name.escapeHtml4() + '</td>';
				body += '<td>' + u.Email.escapeHtml4() + '</td>';
				body += '</tr>';
			}

			body += '</table>';
			body += '<p>Thank you,<br/>Belron</p>';
			body += '</body></html>';
		} else {
			// Prepare a summary email if no users were deactivated
			body =
				'The Deactivate Portal Users job has processed ' +
				a.totalJobItems +
				' batches with ' +
				a.numberOfErrors +
				' failures.';
		}
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new List<String>{System.label.BLN_DeactivationReportRecepient};
		mail.setToAddresses(toAddresses);
		mail.setOrgWideEmailAddressId(orgWideAddr.Id);
		mail.setSubject('Deactivate Portal Users Batch Status ' + '-' + dateTimeStr);
		if (deactivatedUsers.size() > 0) {
			mail.setHtmlBody(body);
		} else {
			mail.setPlainTextBody(body);
		}
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
}