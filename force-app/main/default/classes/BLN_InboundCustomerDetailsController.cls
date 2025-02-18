/*****************************************
    ClassName : BLN_InboundCustomerDetailsController
    Description : FOUK-3964 This controller class is used in Bln_InboundCustomerDetails lwc.
    CreatedDate: 18-12-2023
    CreatedBy : Hemangi Temgire (PWC-India)
    ****************************************/

    public with sharing class BLN_InboundCustomerDetailsController {

         /*@description : getPersonAccounts method used to check account with given mobile number.
      @Return : method returns List of account */
        @AuraEnabled(cacheable=true)
        public static List<Account> getPersonAccounts(String mobilenumber) {
            List<Account> personAccounts = new List<Account>();
             if (Schema.sObjectType.Account.isAccessible()) {
                try {
                    if(!String.isBlank(mobilenumber)){
                        personAccounts = [SELECT Id, FirstName, LastName, PersonMobilePhone, PersonHomePhone FROM Account WHERE PersonMobilePhone = :mobilenumber OR PersonHomePhone = :mobilenumber WITH SECURITY_ENFORCED];}}catch (Exception e) {BLN_ExceptionLogger.captureException(e);}
                    } 
            if(!personAccounts.isEmpty()){
                return personAccounts;
            }else{
               return null; 
            }
            
        }
    }