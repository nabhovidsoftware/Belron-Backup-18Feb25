public with sharing class ChangePasswordController {
    public String oldPassword { get; set; }
    public String newPassword { get; set; }
    public String verifyNewPassword { get; set; }
    public String errorMessage { get; set; }
    
    public PageReference changePassword() {
        try {
            String userId = UserInfo.getUserId();
            System.setPassword(userId, newPassword);
            return navigatePortal();} catch (Exception e) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while changing password: ' + e.getMessage()));
           errorMessage = 'We are unable to log you in. Please check your password.';
            return null;
        }
    }     
    
    public PageReference navigatePortal() {
        //try {
            String address = UserInfo.getUserName();
            String loginCustomLabel = System.Label.SiteLoginUrl;
        	ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            List<ServiceAppointment> serviceAppointments = [SELECT Id, BLN_Case__r.Id FROM ServiceAppointment WHERE Account.PersonEmail = :address AND Status NOT IN :System.Label.BLN_CompleteSAStatus.split(',') AND Worktype.Name NOT IN ('Stock Collect', 'Assist')];
            Integer countOfServiceAppointment = serviceAppointments.size();
            String communityCaseURL = System.Label.AACommunityCaseURL;
            Id caseId = serviceAppointments[0].BLN_Case__r != null ? serviceAppointments[0].BLN_Case__r.Id : null;
            Id sID = serviceAppointments[0].Id; // Assigning sID to a variable
            // if (countOfServiceAppointment == 0 ) {
            //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'We'+'re sorry. You no longer have access to the customer portal as you have no upcoming appointments. If you'+'d like to speak to us about a past appointment, please call 0333 999 0101.'));
            //     return null;}
            if (newPassword != null && verifyNewPassword != null && newPassword.equals(verifyNewPassword)) {
                if (countOfServiceAppointment > 1) {
                    String encodedUrl = EncodingUtil.urlEncode(loginCustomLabel, 'UTF-8');
                    return new PageReference(encodedUrl);
                    //PageReference homepage = new PageReference(EncodingUtil.urlEncode(loginCustomLabel,'utf-8'));
                } else if (countOfServiceAppointment == 1 && caseId != null) {
                    //Id caseId = serviceAppointments[0].BLN_Case__r != null ? serviceAppointments[0].BLN_Case__r.Id : null;
                    //if (caseId != null) {
                        String caseDetailPageUrl = communityCaseURL + caseId + '/detail?sid='+sID;
                        caseDetailPageUrl = EncodingUtil.urlDecode(caseDetailPageUrl, 'UTF-8');
                        return new PageReference(caseDetailPageUrl);
                         //PageReference homepage = new PageReference(EncodingUtil.urlEncode(caseDetailPageUrl,'utf-8'));
                    // return new PageReference(EncodingUtil.urlEncode(caseDetailPageUrl,'utf-8'));
                   // }
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The passwords do not match.'));
                errorMessage = 'We are unable to log you in. Please check your password.';
            }
        //} catch (Exception e) {
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected error occurred. Please contact your administrator.'));
        //}
        return null;
    }
}