/**@description : This Apex class used to get Data collect answer records based on created date.
*  @author: PwC India
*  @Story: FOUK-5013
*  @CreatedDate: 29/05/2024  **/
public with sharing class BLN_DataCollectAnswers {
    
    //This method is used to query data collect answers.
    // @AuraEnabled(cacheable=true)
    @AuraEnabled
    public static List<BLN_DataCollectAnswer__c> getPreviousAnswers(Id caseId, String resultLength) {
        Integer limitCount = Integer.valueOf(resultLength);
        List<BLN_DataCollectAnswer__c> previousAnswers = new List<BLN_DataCollectAnswer__c>();
        String query = 'SELECT Id, BLN_Case__c, BLN_Question__c, BLN_Answer__c FROM BLN_DataCollectAnswer__c WHERE BLN_Case__c = :caseId ORDER BY CreatedDate DESC LIMIT :limitCount';
        previousAnswers = Database.query(query);
        
        return previousAnswers;
        
    }
    /* MethodName : checkDataCollectAnswer
Description : This method is used to check data collect answer :
Input Parameter : accountId
Output Parameter : 
CreatedDate: 31-05-2024
CreatedBy : Pwc-India
Change log :
****************************************/
    /*  *@description:FOUK-5015 This method is used to check data collect answer */
    @AuraEnabled
    public static boolean   getDataCollectAnswer(List<string> accountIds, string caseId){
        // boolean isBlankAnswer = false;
        Boolean arCheck = false;
        List<BLN_DataCollectAnswer__c> dataCollAns = new List<BLN_DataCollectAnswer__c>();
        Set<Id> arpSet = new Set<Id>();
        try{
            String mandatoryValue = System.label.BLN_MandatoryForQualityBooking ;
        List<BLN_AccountRuleParameter__c> arpList1 = new List<BLN_AccountRuleParameter__c>();
        List<BLN_AccountRuleParameter__c> arpList = new List<BLN_AccountRuleParameter__c>();

        List<BLN_AccountRuleParameter__c> arpList2 = new List<BLN_AccountRuleParameter__c>();
        if(accountIds.size()> 0 && BLN_AccountRuleParameter__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() ){
            arpList1 = BLN_AccountRuleParameterUtil.getAccountRuleParameters(label.BLN_ARPDataCollect,accountIds[0],date.today());
        }
        if(accountIds.size()>1 && BLN_AccountRuleParameter__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
            arpList2 = BLN_AccountRuleParameterUtil.getAccountRuleParameters(label.BLN_ARPDataCollect,accountIds[1],date.today());
        }
        if(arpList1 !=null && arpList1.size() > 0){
            arpList.addAll(arpList1);
        }
        if(arpList2!=null && arpList2.size()>0){
            arpList.addAll(arpList2);
        }
            for(BLN_AccountRuleParameter__c arp: arpList){
            if(arp.BLN_Mandatory__c == mandatoryValue){
                    arpSet.add(arp.Id);
                }
       
        }

        Set<Id> questionIds = new Set<Id>();
        if(!arpSet.isEmpty() && BLN_DataCollectAnswer__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
            dataCollAns = [select Id, BLN_Question__c, BLN_Answer__c, BLN_Case__c from  BLN_DataCollectAnswer__c where BLN_Question__c in : arpSet and BLN_Case__c=:caseId WITH SECURITY_ENFORCED LIMIT 49999];
       }
            
               for(BLN_DataCollectAnswer__c dcaList : dataCollAns) {
                   if(dcaList.BLN_Answer__c != null && dcaList.BLN_Answer__c !=''){
                questionIds.add(dcaList.BLN_Question__c);
            }
        }
        //Case updateCase = [SELECT Id, BLN_StockDetailsTheme__c, Type, BLN_SubType__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
        if(arpSet.isEmpty() || (arpSet.size() == questionIds.size())){
            arCheck = true;
            // updateCase.BLN_StockDetailsTheme__c = true;
            // if (Schema.sObjectType.Case.isUpdateable()){
            //         update updateCase;  
            // }
        }
        else{
            createdDataCollectTask(caseId);
            // updateCase.BLN_StockDetailsTheme__c = false;
            // if (Schema.sObjectType.Case.isUpdateable()){
            //         update updateCase;  
            // }

        }
        }
        catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
        }
        return arCheck;
                
    }

    /* MethodName : checkDataCollectAnswer
    Description : This method is used to get the related account rule parameters :
    Input Parameter : caseId, accountId
    Output Parameter : related account rule parameters
    CreatedDate: 03-06-2024
    CreatedBy : PwC-India
    ****************************************/
    /* description:FOUK-5390 This method is used to get the related account rule parameters */
    @AuraEnabled
    public static boolean submitButtonOnClick(Id caseId, List<String> accountIds) {
        // Id recordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get(System.label.BLN_DataCollect).getRecordTypeId();
        Boolean arCheck2 = false;
        List<BLN_DataCollectAnswer__c> dataCollAns = new List<BLN_DataCollectAnswer__c>();
        Set<Id> arpSet = new Set<Id>();
      
            String mandatoryValue = System.label.BLN_MandatoryForQualityBooking ;
        List<BLN_AccountRuleParameter__c> arpList1 = new List<BLN_AccountRuleParameter__c>();
        List<BLN_AccountRuleParameter__c> arpList = new List<BLN_AccountRuleParameter__c>();

        List<BLN_AccountRuleParameter__c> arpList2 = new List<BLN_AccountRuleParameter__c>();
        if(accountIds.size()> 0 && BLN_AccountRuleParameter__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() ){
            arpList1 = BLN_AccountRuleParameterUtil.getAccountRuleParameters(label.BLN_ARPDataCollect,accountIds[0],date.today());
        }
        if(accountIds.size()>1 && BLN_AccountRuleParameter__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
            arpList2 = BLN_AccountRuleParameterUtil.getAccountRuleParameters(label.BLN_ARPDataCollect,accountIds[1],date.today());
        }
        if(arpList1 !=null && arpList1.size() > 0){
            arpList.addAll(arpList1);
        }
        if(arpList2!=null && arpList2.size()>0){
            arpList.addAll(arpList2);
        }
        for(BLN_AccountRuleParameter__c arp: arpList){
            if(arp.BLN_Mandatory__c == mandatoryValue){
                arpSet.add(arp.Id);
            }
       
    }

        Set<Id> questionIds = new Set<Id>();
        if(!arpSet.isEmpty() && BLN_DataCollectAnswer__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
            dataCollAns = [select Id, BLN_Question__c, BLN_Answer__c, BLN_Case__c from  BLN_DataCollectAnswer__c where BLN_Question__c in : arpSet and BLN_Case__c=:caseId WITH SECURITY_ENFORCED LIMIT 49999];
       }
            
               for(BLN_DataCollectAnswer__c dcaList : dataCollAns) {
            if(dcaList.BLN_Answer__c != null && dcaList.BLN_Answer__c != '' ){
                questionIds.add(dcaList.BLN_Question__c);
            }
        }

        if(arpSet.size() == 0 || arpSet.isEmpty()){
            arCheck2 = true;
        }
        else if (arpSet.size() == questionIds.size()){
            arCheck2 = true;
        }

        Case updateCase = [SELECT Id, BLN_ARCheck2__c, Type, BLN_SubType__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
        updateCase.BLN_ARCheck2__c = arCheck2;
        if (Schema.sObjectType.Case.isUpdateable()){
            if(updateCase.Type == 'Job Request' && updateCase.BLN_SubType__c == 'Job Request'){
                update updateCase;
            }
        }
        return arCheck2;
    }


    /* MethodName : getCaseClosureDataCollectAns
Description : This method is used to check data collect answer :
Input Parameter : accountId
Output Parameter : 
CreatedDate: 31-05-2024
CreatedBy : Pwc-India
Change log :
****************************************/
    /*  *@description:FOUK-5016 This method is used to check data collect answer */
    @InvocableMethod(label='getCaseClosureDataCollectAns')
    public static List<string> getCaseClosureDataCollectAns(List<String> caseIdList){
        List<String>isBlankAnswer  = new List<String>();

        List<BLN_DataCollectAnswer__c> dataCollAns = new List<BLN_DataCollectAnswer__c>();
        try{
            String caseId = caseIdList[0]; // Assuming only one CaseId is passed from the Flow
            String accountId;
            BLN_Corporate__c corporateRecord;
            Id recordTypeId;
            RecordType recordType;
        // Query the Case record to get the associated Account Id
        Case relatedCase = [SELECT AccountId,BLN_Corporate__c FROM Case WHERE Id = :caseId LIMIT 1];

           // String accountId = relatedCase.AccountId;
            Id corporateId = relatedCase.BLN_Corporate__c;
            if (Schema.sObjectType.BLN_Corporate__c.isAccessible() || Schema.sObjectType.RecordType.isAccessible()) {
                corporateRecord=[select Id,BLN_InsuranceSite__c,BLN_CorporateSite__c,BLN_CorporateLegalEntity__c,RecordTypeId,BLN_InsuranceLegalEntity__c from BLN_Corporate__c where Id =:corporateId];
                recordTypeId = corporateRecord.RecordTypeId;
             recordType = [SELECT Id, DeveloperName FROM RecordType WHERE Id = :recordTypeId];
           }
           if((recordType.DeveloperName=='BLN_Insurance' || recordType.DeveloperName =='BLN_SpiltBill') && corporateRecord.BLN_InsuranceSite__c !=null){
            accountId = corporateRecord.BLN_InsuranceSite__c;
            
            }else if((recordType.DeveloperName=='BLN_Insurance' || recordType.DeveloperName =='BLN_SpiltBill') && corporateRecord.BLN_InsuranceSite__c ==null){
                accountId = corporateRecord.BLN_InsuranceLegalEntity__c;
            }
            else if(recordType.DeveloperName=='BLN_CorporateFleet' && corporateRecord.BLN_CorporateSite__c !=null){
                accountId = corporateRecord.BLN_CorporateSite__c;
            }else if(recordType.DeveloperName=='BLN_CorporateFleet' && corporateRecord.BLN_CorporateSite__c ==null){
                accountId = corporateRecord.BLN_CorporateLegalEntity__c;
            }
            List<BLN_AccountRuleParameter__c> arpList = new List<BLN_AccountRuleParameter__c>();
            Set<Id> arpSet = new Set<Id>();
            if(BLN_AccountRuleParameter__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                arpList = BLN_AccountRuleParameterUtil.getAccountRuleParameters(label.BLN_ARPDataCollect,accountId,date.today());
            }
            if(arpList !=null && arpList.size() > 0){  
            for(BLN_AccountRuleParameter__c arp: arpList){
                if(arp.BLN_Mandatory__c == label.BLN_CaseClosurevalue){
                    arpSet.add(arp.Id);
                }
            }
        }
            if(!arpSet.isEmpty() && BLN_DataCollectAnswer__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){

                 dataCollAns = [select BLN_Answer__c,Id,BLN_Case__c from  BLN_DataCollectAnswer__c where  BLN_Case__c = :caseId AND BLN_Question__c in : arpSet  WITH SECURITY_ENFORCED LIMIT 49999];
            }
                 if(dataCollAns !=null && dataCollAns.size() > 0){  
                 for(BLN_DataCollectAnswer__c dataCol : dataCollAns){
                    if(string.isBlank(dataCol.BLN_Answer__c)){
                        isBlankAnswer.add('true');
                         break;
                    }
                }
            }
        }
        catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
        }
        return isBlankAnswer;
    }

         /* MethodName : createdDataCollectTask
Description : This method is used to create BVT task:
Input Parameter : caseId
Output Parameter :
CreatedDate: 13-05-2024
CreatedBy : Pwc-India
Change log :
****************************************/
    /*  *@description:FOUK-5015 This method is used to create/update BVT  task */
    
    @AuraEnabled
    public static string createdDataCollectTask(string caseId){
        string taskId = null;
        try {
            Integer bufferTime = Integer.valueOf(label.BLN_BVTBufferTime);
            List<Task> taskList = new List<Task>();
            if(Task.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                taskList = [select Id,BLN_TaskSubjectType__c, Type, Status, WhatId, ActivityDate,BLN_AppointmentDate__c, OwnerId, BLN_Subtype__c from task where Subject =:label.BLN_BVTTaskType and  WhatId=:caseId and BLN_TaskSubjectType__c includes('Data Collect')  WITH SECURITY_ENFORCED LIMIT 1];
            }
            Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(label.BLN_BVTRecordType).getRecordTypeId();
            Group bvtQueue = new Group();
            if(Task.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                bvtQueue = [SELECT Id, Name FROM Group WHERE Type =:label.BLN_Queue AND developerName =:label.BLN_BVTQueue WITH SECURITY_ENFORCED LIMIT 1];
            }
            
            if(!taskList.isEmpty() && Task.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable() ){
          
                taskList[0].Status = label.BLN_TaskStatusOpen;
                taskList[0].Type = label.BLN_BVTTaskType;
                taskList[0].ActivityDate = Date.today()+bufferTime;
                taskList[0].OwnerId = bvtQueue.Id;
                taskList[0].BLN_Subtype__c = label.BLN_BVTTaskType;
                update taskList;
                taskId = taskList[0].Id;
                
                
            }
            else{
                Task taskRecord = new Task();
                taskRecord.Subject = label.BLN_BVTTaskType;
                taskRecord.Status = label.BLN_TaskStatusOpen;
                taskRecord.BLN_IsAutomated__c = true;
                taskRecord.BLN_Subtype__c = label.BLN_BVTTaskType;
                taskRecord.Type = label.BLN_BVTTaskType;
                taskRecord.BLN_TaskSubjectType__c = label.BLN_DataCollectSubType;
                taskRecord.ActivityDate = Date.today()+bufferTime;
                taskRecord.recordtypeId = taskRecordTypeId;
                taskRecord.OwnerId = bvtQueue.Id;
                taskRecord.whatId = caseId;
                if( Task.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()){
                    insert taskRecord;
                }
                if(taskRecord.Id!=null){
                    taskId = taskRecord.Id;
                }
                
            }
        }
        
        
        catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return taskId;
    }

    /* MethodName : getSiteAccountNames
    Description : This method is used to fetch the names of site accounts based on the account type.
    Input Parameter : String accountId, String accountId2, String accountType
    Output Parameter :
    CreatedDate: 03-10-2024
    CreatedBy : Pwc-India
    Change log :
    ****************************************/
    /*  *@description:FOUK-10506 This method is used to fetch the names of site accounts based on the account type. */
    @AuraEnabled
    public static SiteAccountNameWrapper getSiteAccountNames(String accountId, String accountId2, String accountType){
        SiteAccountNameWrapper resultWrapper = new SiteAccountNameWrapper();
        try {
            
            Account corporateSite = new Account();
            Account insuranceSite = new Account();
            if(accountType == 'corporate'){
                corporateSite = [SELECT Id, Name FROM Account WHERE Id =: accountId WITH SECURITY_ENFORCED LIMIT 1];
                resultWrapper.corporateSiteName = corporateSite.Name;
            } else if(accountType == 'insurance'){
                insuranceSite = [SELECT Id, Name FROM Account WHERE Id =: accountId WITH SECURITY_ENFORCED LIMIT 1];
                resultWrapper.insuranceSiteName = insuranceSite.Name;
            } else{
                corporateSite = [SELECT Id, Name FROM Account WHERE Id =: accountId WITH SECURITY_ENFORCED LIMIT 1];
                insuranceSite = [SELECT Id, Name FROM Account WHERE Id =: accountId2 WITH SECURITY_ENFORCED LIMIT 1];
                resultWrapper.corporateSiteName = corporateSite.Name;
                resultWrapper.insuranceSiteName = insuranceSite.Name;
            }
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return resultWrapper;
    }

    /* MethodName : checkAnswerRecords
    Description : This method is used to fetch the answer records for the case and check if answer records are there or not, if no records found create answer records from arp.
    Input Parameter : String caseId, String accountId, String accountId2
    Output Parameter : void
    CreatedDate: 10-10-2024
    CreatedBy : Pwc-India
    Change log :
    ****************************************/
    /*  *@description:FOUK-10731 This method is used to fetch the answer records for the case and check if answer records are there or not, if no records found create answer records from arp. */
    @AuraEnabled
    public static Boolean checkAnswerRecords(String caseId, String accountId, String accountId2){
        Boolean result = true;
        Boolean success;
        try {
            Date jobDate = Date.today();

            List<BLN_AccountRuleParameter__c> arpRecords = new List<BLN_AccountRuleParameter__c>();
            Set<String> arpIdSet = new Set<String>();
            List<BLN_DataCollectAnswer__c> previousRecords = new List<BLN_DataCollectAnswer__c>();
            Set<String> arpIdsWithAnswers = new Set<String>();
            List<BLN_AccountRuleParameter__c> arpWithoutAnswers = new List<BLN_AccountRuleParameter__c>();
            List<BLN_DataCollectAnswer__c> newAnswerRecords = new List<BLN_DataCollectAnswer__c>();
            if(accountId != null){
                List<BLN_AccountRuleParameter__c> arp1 = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.label.BLN_ARPDataCollect, accountId, jobDate);
                if(arp1 != null){
                    arpRecords.addAll(arp1);
                }
            }
            if(accountId2 != null){
                List<BLN_AccountRuleParameter__c> arp2 = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.label.BLN_ARPDataCollect, accountId2, jobDate);
                if(arp2 != null){
                    arpRecords.addAll(arp2);
                }
            }
            if(arpRecords != null || arpRecords.size() > 0){
                for(BLN_AccountRuleParameter__c arp: arpRecords){
                    arpIdSet.add(arp.Id);
                }
            }
            if(arpIdSet != null){
                previousRecords = [SELECT Id, BLN_Case__c, BLN_Question__c FROM BLN_DataCollectAnswer__c WHERE BLN_Case__c =: caseId AND BLN_Question__c IN :arpIdSet WITH SECURITY_ENFORCED];
                if(previousRecords.size() == 0 || previousRecords == null){
                    //no records found so sending false
                    result = false;
                    return result;
                } else{
                    for(BLN_DataCollectAnswer__c answer: previousRecords){
                        arpIdsWithAnswers.add(answer.BLN_Question__c);
                    }
                    for(BLN_AccountRuleParameter__c arp: arpRecords){
                        if(!arpIdsWithAnswers.contains(arp.Id)){
                            arpWithoutAnswers.add(arp);
                        }
                    }
                }
                if(arpWithoutAnswers == null || arpWithoutAnswers.size() == 0){
                    //All answer records are present for the respective ARP records so return true.
                    result = true;
                    return result;
                } else{
                    //Some ARP records do not have answer records, so creating answers records.
                    for(BLN_AccountRuleParameter__c arp: arpWithoutAnswers){
                        BLN_DataCollectAnswer__c answerRecord = new BLN_DataCollectAnswer__c();
                        answerRecord.BLN_Case__c = caseId;
                        answerRecord.BLN_Question__c = arp.Id;
                        newAnswerRecords.add(answerRecord);
                    }
                }
                if(newAnswerRecords.size() > 0 || newAnswerRecords != null){
                    Database.SaveResult[] saveNewAnswers = Database.insert(newAnswerRecords);
                    success = (saveNewAnswers != null ) ? true : false;
                }
            }
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return result;
    }

    public class SiteAccountNameWrapper{
        @AuraEnabled public String corporateSiteName {get; set;}
        @AuraEnabled public String insuranceSiteName {get; set;}
    }

}