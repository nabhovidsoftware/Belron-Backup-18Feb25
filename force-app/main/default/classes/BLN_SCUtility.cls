/** @description : This class used to generate random code.
*   @Story : FOUK-867
*   @author: Shubhangi Patil (PwC)
*   @CreatedDate: 24/11/2023
*/
public with sharing class BLN_SCUtility {
    /**
*@description:This method is used to get random CorrelationID.
*@return String
*/
    public static String generateCorrelationID() {
        Blob blogKey;
        String hexCode ='';
        String uid ='';
        blogKey = Crypto.GenerateAESKey(128);
        hexCode = EncodingUtil.ConvertTohex(blogKey);
        uid = hexCode.SubString(0,8)+ System.label.BLN_Hyphen + hexCode.SubString(8,12) + System.label.BLN_Hyphen + hexCode.SubString(12,16) + System.label.BLN_Hyphen + hexCode.SubString(16,20) + System.label.BLN_Hyphen + hexCode.substring(20);
        return uid;
    }
    
    /**
*@description:This method Query fieldset from account and getting called from BLN_APICalloutPublisherTriggerHandler class
*@return  Account
*/
    public static Account getMotoristDataforMDMSync(Id accountId){
        String queryString = '';
        String queryFields = ''; 
        try{
            if(accountId !=null){
                List<Schema.FieldSetMember> fields = Schema.SObjectType.Account.fieldSets.BLN_MotoristMDMSyncAPI.getFields();
                
                for (Schema.FieldSetMember fieldset : fields) {
                    queryFields += fieldset.getFieldPath() + System.label.BLN_Comma+' ';
                }
                queryFields = queryFields.removeEnd(System.label.BLN_Comma+' ');
                
                queryString = System.label.BLN_QuoteSelect+' '+ queryFields +' '+System.label.BLN_AccountQuery;
                return Database.query(String.escapeSingleQuotes(queryString));
            }return null;}catch(Exception e){BLN_ExceptionLogger.captureException(e);return null;
                                            }
    }
    
    /**
*@description:This method used to generate random code
*@return  String
*/
    public static String paymentUniqueCRGenerator(Id paymentRecordId) {
        
        String s1 = String.valueOf(paymentRecordId)+System.Now();
        Blob sha256v = Crypto.generateDigest('SHA-256', Blob.valueOf(s1));
        String sha256hex = EncodingUtil.convertToHex(sha256v);
        sha256hex = sha256hex.substring(0,32);
        return sha256hex;
    }
    
    /**
*@description:This method called from payments Payments Field Population flow, used to populate payment status.
*@return  void
*/
    @InvocableMethod
    public static void paymentFieldsPopulation(List<BLN_Payment__c> paymentList) {
        try{
        List<BLN_PaymentStatMapping__mdt>getMetadata = BLN_PaymentStatMapping__mdt.getall().values(); 
        Set<Id> caseIds = populateCaseIds(paymentList);
        Set<Id> paymentIds = populatePaymentIds(paymentList);
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, CaseNumber FROM Case WHERE Id IN :caseIds]);
        Map<Id, BLN_Payment__c> paymentMap = new Map<Id, BLN_Payment__c>( [SELECT Id,RecordType.developername, BLN_Case__c,BLN_PmtGatewayProvider__c, BLN_PaymentMethod__c,BLN_OriginalPayment__r.Id, BLN_OriginalPayment__r.BLN_PmtGatewayProvider__c, BLN_Status__c FROM BLN_Payment__c WHERE Id IN :paymentIds]);
        Boolean hasPermission = FeatureManagement.checkPermission(label.BLN_IntegrationUser);
        for (BLN_Payment__c paymentRecord : paymentList) {
            BLN_Payment__c payments1 = paymentMap.get(paymentRecord.Id);
            String recordTypeName =payments1.RecordType.DeveloperName;
            String uniqueId = paymentUniqueCRGenerator(payments1.Id);
            if (paymentRecord.createddate == paymentRecord.LastModifiedDate && paymentRecord.BLN_Case__c != null) {
                paymentRecord.BLN_CR__c = uniqueId;
                Case relatedCase = caseMap.get(paymentRecord.BLN_Case__c);
                    paymentRecord.BLN_TxnId__c = relatedCase.CaseNumber + '/04';
                paymentRecord.BLN_InitiatedBy__c = hasPermission ? UserInfo.getName() : UserInfo.getName();
                if(hasPermission == true){
                    paymentRecord.BLN_PaymentMethod__c = label.BLN_Automated;
                }
               // paymentRecord.BLN_PaymentMethod__c = hasPermission ? label.BLN_Automated : label.BLN_Automated;
            }
            
                 if(recordTypeName==System.label.BLN_Payments ){
                for(BLN_PaymentStatMapping__mdt statusmappingmdt: getMetadata){
                    if(statusmappingmdt.BLN_PaymentGateway__c == paymentRecord.BLN_PmtGatewayProvider__c &&
                        statusmappingmdt.BLN_PaymentMethod__c == paymentRecord.BLN_PaymentMethod__c &&
                        (statusmappingmdt.BLN_ResponseStatus__c?.toLowerCase() == paymentRecord.BLN_Status__c?.toLowerCase())) {
                            paymentRecord.BLN_PaymentStatus__c = statusmappingmdt.BLN_SalesforceStatus__c;
                            break;
                        }
                }
            } else if(recordTypeName==System.label.BLN_Refunds){
                
                for(BLN_PaymentStatMapping__mdt statusmappingmdt: getMetadata){
                    
                    if(statusmappingmdt.BLN_PaymentGateway__c == payments1.BLN_OriginalPayment__r.BLN_PmtGatewayProvider__c &&
                       statusmappingmdt.BLN_PaymentMethod__c == payments1.BLN_PaymentMethod__c &&
                       (statusmappingmdt.BLN_ResponseStatus__c?.toLowerCase() == payments1.BLN_Status__c?.toLowerCase())) {
                           paymentRecord.BLN_PaymentStatus__c = statusmappingmdt.BLN_SalesforceStatus__c;
                           
                       } 
                }
            }
            
            
                if (paymentRecord.BLN_PaymentMethod__c != System.label.BLN_Assisted) {
                paymentRecord.BLN_InitiatedDateTime__c = System.now();
                paymentRecord.BLN_PaymentTime__c = System.now();
                
                
            } else {
                paymentRecord.BLN_InitiatedDateTime__c = System.now();
                //aymentRecord.BLN_PaymentTime__c = Sycurio.getPaymentTime(); //after integration with Sycurio
            }
            
        }
        if(BLN_Payment__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
            update paymentList;
        }
            
            
            paymentReceiptMethodPopulation(paymentList); 
        }catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
        }
    } 
    
    /**
*@description:This method used to populate payment card type and BLN_RctMethod__c fields.
*@return  void
*/
    public static void paymentReceiptMethodPopulation(List<BLN_Payment__c> paymentList) {
        try{
        List<BLN_CardTypeMaster__mdt> cardTypeMetadata = BLN_CardTypeMaster__mdt.getall().values();
        Set<Id> paymentIds = populatePaymentIds(paymentList);
        Map<Id, BLN_Payment__c> paymentMap = new Map<Id, BLN_Payment__c>( [SELECT Id,RecordType.developername FROM BLN_Payment__c WHERE Id IN :paymentIds]);
            //Map<Id, BLN_Payment__c> oldPaymentMap = new Map<Id, BLN_Payment__c>();
        
        // Create a map to store card types with their start ranges
        Map<String, BLN_CardTypeMaster__mdt> cardTypeMap = new Map<String, BLN_CardTypeMaster__mdt>();
        for (BLN_CardTypeMaster__mdt cardType : cardTypeMetadata) {
            String startRangeString = String.valueOf(cardType.BLN_StartofRange__c);
            cardTypeMap.put(startRangeString, cardType);
        }
        
            List<BLN_Payment__c> paymentToUpdate = new List<BLN_Payment__c>();
            List<BLN_Payment__c> paymentWaivedToUpdate = new List<BLN_Payment__c>();
            List<BLN_Payment__c> paymentTokenWithZero = new List<BLN_Payment__c>();
        
        for (BLN_Payment__c paymentRecord : paymentList) {
            BLN_Payment__c payments1 = paymentMap.get(paymentRecord.Id);
            String recordTypeName =payments1.RecordType.DeveloperName;
                if ((recordTypeName==System.label.BLN_Payments && paymentRecord.BLN_PaymentId__c != null && paymentRecord.BLN_PaymentType__c != System.label.BLN_Ecommerce) ||
                (recordTypeName==System.label.BLN_Refunds && paymentRecord.BLN_PaymentId__c != null)) {
                Decimal cardNumberPrefixDecimal = paymentRecord.BLN_First6DigitsofCard__c;

                    for (BLN_CardTypeMaster__mdt cardType : cardTypeMetadata) {
                        if(cardType.BLN_Status__c == System.label.BLN_StatusValid && cardType.BLN_StartofRange__c <= cardNumberPrefixDecimal && cardType.BLN_EndofRange__c >=cardNumberPrefixDecimal)
                        {
                            paymentRecord.BLN_CardType__c = cardType.BLN_CardType__c;
                            // paymentRecord.BLN_RctMethod__c = cardType.BLN_CardType__c;
                            paymentToUpdate.add(paymentRecord);
                            paymentWaivedToUpdate.add(paymentRecord);
                            paymentTokenWithZero.add(paymentRecord);
                            break;
                        }
                    }
                } else if (recordTypeName==System.label.BLN_Payments && paymentRecord.BLN_PaymentId__c != null && paymentRecord.BLN_PaymentType__c == System.label.BLN_Ecommerce){
                    paymentRecord.BLN_CardType__c = System.label.BLN_EcommsCard;
                    paymentToUpdate.add(paymentRecord); 
                    paymentWaivedToUpdate.add(paymentRecord);
                    break;
                }
                if(!paymentWaivedToUpdate.contains(paymentRecord) && recordTypeName==System.label.BLN_WaivedReceiptsRT)
                {
                    paymentWaivedToUpdate.add(paymentRecord);
            }
        }
        
        if (BLN_Payment__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()) {
                update paymentToUpdate;
            }
            
            paymentReceiptIdMethodPopulation(paymentToUpdate);
            paymentBatchDetermination(paymentWaivedToUpdate);

            paymentTokenIdConcatinate(paymentTokenWithZero);
            
        }catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
        }
    }
    
    
    /**
*@description:This method used to populate paymenttokenId concatinate with 0000 .
*@return  String
*/  
public static void paymentTokenIdConcatinate(List<BLN_Payment__c> paymentList) {

 
    try{
        for(BLN_Payment__c paymentRecords:paymentList){
            if(paymentRecords.BLN_PaymentType__c == System.label.BLN_ONLINEPAYMENTSValue && paymentRecords.BLN_PaymentId__c != null){
             paymentRecords.BLN_TokenNumberEBS__c = '0000'+''+paymentRecords.BLN_PaymentId__c;
              //String ebsPayment =  paymentRecords.BLN_PaymentId__c;
            }  
       
        }
        
        if(BLN_Payment__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
            update paymentList;
        }
        
    }catch(Exception e){
        BLN_ExceptionLogger.captureException(e);
    }

}

    
    /**
*@description:This method used to populate payment BLN_RctMethodId__c .
*@return  String
*/
    public static void paymentReceiptIdMethodPopulation(List<BLN_Payment__c> paymentList) {
        try{
        List<BLN_PmtReqIdMapping__mdt>getReqIdMetadata = BLN_PmtReqIdMapping__mdt.getall().values(); 
        Set<Id> paymentIds = populatePaymentIds(paymentList);
        
        Map<Id, BLN_Payment__c> paymentMap = new Map<Id, BLN_Payment__c>( [SELECT Id,RecordType.developername FROM BLN_Payment__c WHERE Id IN :paymentIds]);
        
        for(BLN_Payment__c paymentRecords:paymentList){
            BLN_Payment__c payments1 = paymentMap.get(paymentRecords.Id);
            String recordTypeName =payments1.RecordType.DeveloperName;
                if(recordTypeName==System.label.BLN_Payments){
                for(BLN_PmtReqIdMapping__mdt reqIdmdt: getReqIdMetadata){
                    if(
                        reqIdmdt.BLN_LookupValue__c == paymentRecords.BLN_CardType__c && 
                        reqIdmdt.BLN_PaymentGrouping__c == paymentRecords.BLN_PaymentType__c){
                            paymentRecords.BLN_RctMethodId__c=reqIdmdt.BLN_RequestId__c;
                                paymentRecords.BLN_RctMethod__c=reqIdmdt.BLN_PaymentType__c;
                        }
                    
                }
                
            }
        }
        if(BLN_Payment__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
            update paymentList;
        }
        
        }catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
        }
    }
    
    /**
*@description:This method used to populate paymentID .
*@return  String
*/    
    public static Set<Id> populatePaymentIds(List<BLN_Payment__c> paymentList) {
        Set<Id> paymentIds = new Set<Id>();
        for (BLN_Payment__c paymentRecord : paymentList) {
            paymentIds.add(paymentRecord.Id);
        }
        return paymentIds;
    }
    
    /**
*@description:This method used to populate payment's case Id .
*@return  String
*/    
    public static Set<Id> populateCaseIds(List<BLN_Payment__c> paymentList) {
        Set<Id> paymentIds = new Set<Id>();
        for (BLN_Payment__c paymentRecord : paymentList) {
            paymentIds.add(paymentRecord.BLN_Case__c);
        }
        return paymentIds;
    }

    /**
*@description:This method used to return the random 6 digit alphabet string .
*@return  String
*/  
    public static String generateRandomAlphabetString() {  
        String alphabet = 'abcdefghijklmnopqrstuvwxyz';  
        String randomString = '';  
        Integer alphabetLength = alphabet.length();  
          
        for (Integer i = 0; i < 6; i++) {  
            Integer randomIndex = Integer.valueOf(Math.floor(Math.random() * alphabetLength));  
            randomString += alphabet.substring(randomIndex, randomIndex + 1);  
        }  

          
        return randomString;  
    }

    
    /**
*@description:This method used to populate payment's case Id .
*@return  String
*/  
    
    public static void paymentBatchDetermination(List<BLN_Payment__c> paymentList) {
        RecordType rt1;
        RecordType rt2;
        RecordType rt3;
        try {
            if (Schema.sObjectType.RecordType.isAccessible()){
                rt1=[ select id,DeveloperName from RecordType where DeveloperName =: System.label.BLN_Payments ];
                rt2=[ select id,DeveloperName from RecordType where DeveloperName =: System.label.BLN_Refunds ];
                rt3=[ select id,DeveloperName from RecordType where DeveloperName =: System.label.BLN_WaivedReceiptsRT ];
            }
            Set<Id> caseIds = new Set<Id>();
          List<BLN_Payment__c> paymentListToUpdate = new List<BLN_Payment__c>();
            for (BLN_Payment__c paymentRec : paymentList) {
                caseIds.add(paymentRec.BLN_Case__c);
                
            }
            Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, BLN_LocationBranchName__r.BLN_CostCenterCode__c
                                                       FROM Case
                                                       WHERE Id IN :caseIds]);
            List<BLN_PmtBatchMapper__mdt> batchMapperList = [SELECT Id, BLN_Prefix__c, BLN_CenterDigits__c, BLN_PaymentType__c, BLN_MethodId__c FROM BLN_PmtBatchMapper__mdt WITH SECURITY_ENFORCED];
            
            for (BLN_Payment__c paymentRecord : paymentList) {
                Case relatedCase = caseMap.get(paymentRecord.BLN_Case__c);
                
                String centerCode = relatedCase.BLN_LocationBranchName__r.BLN_CostCenterCode__c;
                for (BLN_PmtBatchMapper__mdt mapper : batchMapperList) {
                    if (mapper.BLN_PaymentType__c == paymentRecord.BLN_RctMethod__c && mapper.BLN_MethodId__c == paymentRecord.BLN_RctMethodId__c
                        && (paymentRecord.recordTypeId == rt1.Id || paymentRecord.recordTypeId == rt2.Id)) {
                            paymentRecord.BLN_PmtBatch__c = mapper.BLN_Prefix__c + mapper.BLN_CenterDigits__c + DateTime.now().format('ddMMyy');
                        }else if(mapper.BLN_PaymentType__c == paymentRecord.BLN_RctMethod__c && mapper.BLN_MethodId__c == paymentRecord.BLN_RctMethodId__c && paymentRecord.recordTypeId == rt3.Id ){
                            
                            paymentRecord.BLN_PmtBatch__c = mapper.BLN_Prefix__c + centerCode + DateTime.now().format('ddMMyy');
                            
                            
                        }
                }
                paymentListToUpdate.add(paymentRecord);
            }
            update paymentListToUpdate;
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
    }   
}