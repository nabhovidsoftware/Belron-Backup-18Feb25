/** @description : This controller class is used in Assisted Payment.
*   @Story : FOUK-4767
*   @author: PwC-India
*   @CreatedDate: 18-04-2024
*/
public with sharing class BLN_AssistedPaymentsController {
    
    
    @auraenabled
    public static string generatedHexDigestkey(string paymentId){
        String hexStr = '';
        String digestkey = '';
        Blob sha256v ;
        String uRL = '';
        AsstPaymentWrapper aPW = new AsstPaymentWrapper();
        BLN_AssistedPmtAttr__mdt asstPayList = new BLN_AssistedPmtAttr__mdt();
        list<AsstPaymentWrapper> asstWrpList = new list<AsstPaymentWrapper>();
        
        BLN_Payment__c payments = [Select BLN_PaymentAmountTaken__c, BLN_CR__c, BLN_Case__r.CaseNumber from BLN_Payment__c where Id =: paymentId with security_enforced];
        hexStr = system.label.BLN_ClientReferenceAstPmt + payments.BLN_CR__c + system.label.BLN_DigestAstPmt;
        
        sha256v = Crypto.generateDigest(system.label.BLN_hexCode, Blob.valueOf(hexStr)); 
        
        digestkey = EncodingUtil.convertToHex(sha256v);
        asstPayList = BLN_AssistedPmtAttr__mdt.getAll().values();
        
        uRL = asstPayList.BLN_BaseURL__c+asstPayList.BLN_ClientRef__c+asstPayList.BLN_SemafoneCode__c+asstPayList.BLN_GatewayId__c+asstPayList.BLN_TenantId__c+asstPayList.BLN_ClientId__c+asstPayList.BLN_AccountId__c+asstPayList.BLN_Principle__c+asstPayList.BLN_LicenseCode__c+asstPayList.BLN_ResponseType__c+asstPayList.BLN_txnType__c+asstPayList.BLN_ResponseURL__c+asstPayList.BLN_Amount__c+string.valueOf(payments.BLN_PaymentAmountTaken__c)+asstPayList.BLN_Currency__c+asstPayList.BLN_ReturnBin__c+asstPayList.BLN_JobNo__c+string.valueOf(payments.BLN_Case__r.CaseNumber)+asstPayList.BLN_SalesDetails__c+payments.BLN_CR__c+asstPayList.BLN_PostFwdURL__c+asstPayList.BLN_Digest__c+digestkey;
        
        aPW.responseType = asstPayList.BLN_ResponseType__c;
        aPW.merchantRef = asstPayList.BLN_MchntRef__c;
        aPW.principle = asstPayList.BLN_Principle__c;
        aPW.curency = asstPayList.BLN_Currency__c;
        aPW.licenseCode = asstPayList.BLN_LicenseCode__c;
        aPW.txnType = asstPayList.BLN_txnType__c;
        aPW.accountId = asstPayList.BLN_AccountId__c;
        aPW.tokenize = asstPayList.BLN_Tokenize__c;
        aPW.amount = asstPayList.BLN_Amount__c  + string.valueOf(payments.BLN_PaymentAmountTaken__c);
        aPW.gatewayId = asstPayList.BLN_GatewayId__c;
        aPW.digest = asstPayList.BLN_Digest__c + digestkey;
        aPW.postFwdURL = asstPayList.BLN_PostFwdURL__c;
    //    aPW.txnRef = asstPayList.BLN_TxnRef__c;
        aPW.clientId = asstPayList.BLN_ClientId__c;
        aPW.tenantId = asstPayList.BLN_TenantId__c;
        aPW.semafoneCode = asstPayList.BLN_SemafoneCode__c;
        aPW.jobNo = asstPayList.BLN_JobNo__c;
        aPW.clientRef = asstPayList.BLN_ClientRef__c;
        aPW.baseURL = asstPayList.BLN_BaseURL__c;
        aPW.responseURL = asstPayList.BLN_ResponseURL__c;
        asstWrpList.add(aPW);
        
        return uRL;
        
    }
    
    public class AsstPaymentWrapper{
        private string responseType; 
        private string merchantRef;
        private string principle;
        private string curency;
        private string licenseCode;
        private string txnType;
        private string accountId;
        private string tokenize;
        private string amount;
        private string gatewayId;
        private string digest;
        private string postFwdURL;
        private string clientId;
        private string tenantId;
        private string semafoneCode;
        private string jobNo;
        private string clientRef;
        private string baseURL;
        private string responseURL;
        
    }
    
}