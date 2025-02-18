public with sharing class BLN_FetchKnowledgeArticles {
    
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getKnowledgeArticles(List<String> articleTitle) {
        return [SELECT Id, Title, BLN_Description__c FROM Knowledge__kav WHERE Title IN :articleTitle WITH SECURITY_ENFORCED];
    }    
    
    @AuraEnabled
    public static String createTaskRecord(String subject, String description, String caseId) {
        String idVal = '';            
        Task newTask = new Task();
        newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('BLN_Audit').getRecordTypeId();
        newTask.Subject = subject;
        newTask.Description = description;
        newTask.Status = 'Completed';
        newTask.ActivityDate = Date.today();
        newTask.OwnerId = UserInfo.getUserId();
        newTask.WhatId = Id.valueOf(caseId);
        newTask.BLN_Case__c = Id.valueOf(caseId);
        if(Schema.sObjectType.Task.isCreateable()){
            insert newTask;
            idVal = String.valueOf(newTask.Id);
        }  
        return idVal;
    }    
    
	@AuraEnabled(cacheable = true)
    public static String checkMotabilityAccountName(String caseId) {
        String entityName='';
        Case caseRecord = [SELECT Id,AccountId,BLN_Corporate__c From Case Where Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
        /*Account acc = new Account();
        if(caseRecord.AccountId != null){
            acc=[Select Id,Name From Account Where Id=:caseRecord.AccountId WITH SECURITY_ENFORCED LIMIT 1];           
        }
        return acc.Name;*/
   
        BLN_Corporate__c corpRecord=[SELECT Id,BLN_InsuranceLegalEntity__c,BLN_CorporateLegalEntity__c,BLN_CorporateLegalEntity__r.Name,RecordTypeId,BLN_InsuranceLegalEntity__r.Name From BLN_Corporate__c where Id=:caseRecord.BLN_Corporate__c WITH SECURITY_ENFORCED LIMIT 1];
        if(corpRecord.recordTypeId == Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get(System.label.BLN_CorporateFleet).getRecordTypeId()){           
            if(corpRecord.BLN_CorporateLegalEntity__c!=Null){
                entityName=corpRecord.BLN_CorporateLegalEntity__r.Name;                
            }           
        }
        else if(corpRecord.recordTypeId == Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get(System.label.BLN_Insurance).getRecordTypeId()){
            if(corpRecord.BLN_InsuranceLegalEntity__c!=Null){
                entityName=corpRecord.BLN_InsuranceLegalEntity__r.Name;
            }
                         
        }
        /*else if(corpRecord.recordTypeId == Schema.SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get(System.label.BLN_SplitBill).getRecordTypeId()){
         * if(corpRecord.BLN_InsuranceLegalEntity__c!=Null){
                entityName=corpRecord.BLN_InsuranceLegalEntity__r.Name;
            }
        }*/
        return entityName;
    }    
    
    @AuraEnabled
    public static List<BLN_ProductIdentifier__mdt> checkADASScriptProduct() {
        List<BLN_ProductIdentifier__mdt> productIdentifierListForHideOnUI = new List<BLN_ProductIdentifier__mdt>();
        List<String> typeList = new List<String>();
	    String allTypevalues = System.Label.BLN_ArticleTypes;
        typeList = allTypevalues.split(',');
	    productIdentifierListForHideOnUI = [SELECT Id,BLN_ProductCode__c,BLN_Type__c,BLN_CategoryCode__c FROM BLN_ProductIdentifier__mdt WHERE BLN_Type__c IN : typeList WITH SECURITY_ENFORCED];  
        List<BLN_ProductIdentifier__mdt> prodADASList = new List<BLN_ProductIdentifier__mdt>();
            for(BLN_ProductIdentifier__mdt prodIdentifier : productIdentifierListForHideOnUI){
                prodADASList.add(prodIdentifier);
            }
    
        return prodADASList;
    }
    
}