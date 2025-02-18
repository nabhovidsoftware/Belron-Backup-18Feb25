/*****************************************
*ClassName : BLN_InsuranceDetailFormController
*@description : FOUK-6986 This controller class is used in LWC.
*CreatedDate: 12-04-2024
*CreatedBy : PwC-India
****************************************/
public  without sharing class BLN_InsuranceDetailFormController {
    
    /*MethodName : createCaseRecord
*@description : This method is used for to create task record
*@return boolean
*@param caseId,description,base64Data,fileName
*Output Parameter : 
*CreatedDate: 12-04-2024
*CreatedBy : Pwc-India
*Change log :
****************************************/
    @AuraEnabled
    public static boolean  createTask(String caseId, String description, string base64Data , string fileName ) {
       boolean insuranceFlag = false ;
        
        try {
            system.debug(description+caseId);
            Group bvtQueue = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND developerName = 'BLN_BVT' LIMIT 1];
            
            // Create a Task record
            Task newTask = new Task(
                
                Subject = 'BVT Insurance Details',
                Type = 'Onboarding',
                BLN_SubType__c = 'Billing',
                Description = description,
                WhatId = caseId,
                IsVisibleInSelfService = true,
                //recordtypeId = null,
                OwnerId = bvtQueue.Id
            );
            
            insert newTask;
            system.debug('newTask'+newTask.Id);
            
            // Create a ContentVersion record
            if(base64Data!=null && fileName!=null ){
            ContentVersion contentVersion = new ContentVersion(
                Title = fileName,
                PathOnClient = fileName,
                VersionData = EncodingUtil.base64Decode(base64Data),
                IsMajorVersion = true
            );
            insert contentVersion;
            
            // Create a ContentDocumentLink to associate the ContentVersion with the Task
            ContentDocumentLink contentLink = new ContentDocumentLink(
                ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId,
                LinkedEntityId = newTask.Id,
                ShareType = 'V' 
            );
            insert contentLink;
            system.debug('contentLink'+contentLink);
            
            }
            
            if(newTask.Id != null){
                insuranceFlag = true;
        }
            
            
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return insuranceFlag;
    }
}