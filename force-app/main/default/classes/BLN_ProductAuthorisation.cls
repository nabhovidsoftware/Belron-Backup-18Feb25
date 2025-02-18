/*****************************************
ClassName : BLN_ProductAuthorisation
    Description : FOUK-3167 This controller class is used in lwc.
    CreatedDate:  13-05-2024
    CreatedBy : PwC-India
     ****************************************/


/*  *@description:This class is used to return the response */
public without sharing class BLN_ProductAuthorisation {
    
    /* MethodName : createBvtTask
    Description : This method is used to create OE Autharization task:
        Input Parameter : caseId
        Output Parameter :
        CreatedDate: 13-05-2024
        CreatedBy : Pwc-India
        Change log :
         ****************************************/
    /*  *@description:FOUK-3167 This method is used to create/update BVT Autharization task */
    
    @AuraEnabled
    public static String createBvtTask(String caseId, String subjectType, Date slotDate, String taskAccId){
        String taskId = Null;
        BLN_Corporate__c corporateRecord;
        Case cases;
        Id recordTypeId;
        Id corporateId;
        Id accountId;
        RecordType recordType;

    //system.debug('caseId in BVTTAsk'+ caseId);
    // system.debug('subjectType in BVTTAsk'+ subjectType);
    try {
        String insuranceFLTR = null;
        string corporateFLTR = null;
        
            if (Schema.sObjectType.Case.isAccessible()) {
                cases=[select Id, BLN_Corporate__c from Case where Id =:caseId];
            }
            corporateId = cases.BLN_Corporate__c;
            
            if (Schema.sObjectType.BLN_Corporate__c.isAccessible() || Schema.sObjectType.RecordType.isAccessible()) {
            corporateRecord=[select Id,BLN_InsuranceSite__c,BLN_CorporateSite__c,BLN_CorporateLegalEntity__c,RecordTypeId,BLN_InsuranceLegalEntity__c,BLN_InsuranceLegalEntity__r.BLN_FLTRIndicator__c,BLN_CorporateLegalEntity__r.BLN_FLTRIndicator__c from BLN_Corporate__c where Id =:corporateId];
                recordTypeId = corporateRecord.RecordTypeId;
                recordType = [SELECT Id, DeveloperName FROM RecordType WHERE Id = :recordTypeId];
            }
            
            if(recordType.DeveloperName==System.label.BLN_InsuranceLabel){
                accountId = corporateRecord.BLN_InsuranceSite__c;
            insuranceFLTR = corporateRecord.BLN_InsuranceLegalEntity__r.BLN_FLTRIndicator__c;

        }
        else if( recordType.DeveloperName==System.label.BLN_CorporateFleetLabel){
            accountId = corporateRecord.BLN_CorporateSite__c;
            corporateFLTR =   corporateRecord.BLN_CorporateLegalEntity__r.BLN_FLTRIndicator__c;
        }
        else if(recordType.DeveloperName==System.label.BLN_SpiltBill){
            accountId = taskAccId;
            insuranceFLTR = corporateRecord.BLN_InsuranceLegalEntity__r.BLN_FLTRIndicator__c;
            corporateFLTR =   corporateRecord.BLN_CorporateLegalEntity__r.BLN_FLTRIndicator__c;


            }
            
            Integer bufferTime = Integer.valueOf(label.BLN_BVTBufferTime);
            List<Task> taskList = new List<Task>();
            if(Task.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                taskList = [select Id,BLN_TaskSubjectType__c, Type, Status, WhatId, ActivityDate,BLN_AppointmentDate__c, OwnerId, BLN_Subtype__c from task where Status != 'Completed' and Subject =: label.BLN_BVTAuthorisationSubject and WhatId=:caseId WITH SECURITY_ENFORCED LIMIT 1];
            }
            
            Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(label.BLN_BVTRecordType).getRecordTypeId();
            
            Group bvtQueue = new Group();
            if(Task.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                bvtQueue = [SELECT Id, Name FROM Group WHERE Type =:label.BLN_Queue AND developerName =:label.BLN_BVTQueue WITH SECURITY_ENFORCED LIMIT 1];
            }
        Group fltrQueue = new Group();
        if(Task.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
            fltrQueue = [SELECT Id, 
                                Name 
                            FROM Group 
                            WHERE Type =:label.BLN_Queue 
                            AND developerName =:label.BLN_FLTRQueue 
                            WITH SECURITY_ENFORCED 
                            LIMIT 1];
        } 
            
            if(!taskList.isEmpty() && Task.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable() ){
                List<String> subjectTypeValues = new List<String>();
                
                //Check that TaskSubject Type is not null
                if(taskList[0].BLN_TaskSubjectType__c!=null)
                {
                    subjectTypeValues = taskList[0].BLN_TaskSubjectType__c.split(';');
                }
                
                //Check that subjectType value is not already in TaskSubjectType, then add values in subtypvals
                if ((!subjectTypeValues.contains(subjectType)) && taskList[0].BLN_TaskSubjectType__c!=null) {
                    //taskList[0].BLN_TaskSubjectType__c = taskList[0].BLN_TaskSubjectType__c + ';' +subjectType;
                    subjectTypeValues.add(subjectType);
                    taskList[0].BLN_TaskSubjectType__c = String.join(subjectTypeValues,';');
                }
                
                //If tasklist is empty, add subjectType from parameters.
                if(taskList[0].BLN_TaskSubjectType__c==null){
                    subjectTypeValues.add(subjectType);
                    taskList[0].BLN_TaskSubjectType__c = String.join(subjectTypeValues,';');
                }
                
                taskList[0].Status = label.BLN_TaskStatusOpen;
                taskList[0].Type = label.BLN_BVTTaskType;
                taskList[0].ActivityDate = Date.today()+bufferTime;
            if((insuranceFLTR == System.label.BLN_FLTR) || (corporateFLTR == System.label.BLN_FLTR)){
                taskList[0].OwnerId = fltrQueue.Id;
            }
            else{
                taskList[0].OwnerId = bvtQueue.Id;
            }
                taskList[0].BLN_Subtype__c = label.BLN_BVTTaskType;
                taskList[0].BLN_AppointmentDate__c = slotDate;
                
                update taskList;
                taskId = taskList[0].Id;
            }
            else{
                Task taskRecord = new Task();
                taskRecord.Subject = label.BLN_BVTAuthorisationSubject;
                taskRecord.Status = label.BLN_TaskStatusOpen;
                taskRecord.BLN_IsAutomated__c = true;
                taskRecord.BLN_Subtype__c = label.BLN_BVTTaskType;
                taskRecord.Type = label.BLN_BVTTaskType;
                taskRecord.BLN_TaskSubjectType__c = subjectType;
                taskRecord.ActivityDate = Date.today()+bufferTime;
                taskRecord.recordtypeId = taskRecordTypeId;
            if((insuranceFLTR == System.label.BLN_FLTR) || (corporateFLTR == System.label.BLN_FLTR)){
                taskRecord.OwnerId = fltrQueue.Id;
            }
            else{
                taskRecord.OwnerId = bvtQueue.Id;
            }
                taskRecord.whatId = caseId;
                taskRecord.BLN_Account__c = accountId;
                taskRecord.BLN_Case__c = caseId;
                taskRecord.BLN_AppointmentDate__c = slotDate;
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
    
    @AuraEnabled
    public static void updateTask(String taskId, Date slotDate) {
        Task taskToUpdate = new Task();
        if(Task.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
            taskToUpdate = [SELECT Id, 
                                   BLN_AppointmentDate__c
                            FROM Task 
                            WHERE Id = :taskId 
                            WITH SECURITY_ENFORCED 
                            LIMIT 1];
        }
        taskToUpdate.BLN_AppointmentDate__c = slotDate;
        if( Task.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
            update taskToUpdate;
        }
    }
    
    @AuraEnabled
    public static void splitBillBVT(String caseId, BLN_Corporate__c corporateObj, Date slotDate){
        List<BLN_AccountRuleParameter__c> arpList1 = new List<BLN_AccountRuleParameter__c>();
        List<BLN_AccountRuleParameter__c> arpList2 = new List<BLN_AccountRuleParameter__c>();
        List<BLN_AccountRuleParameter__c> arpList = new List<BLN_AccountRuleParameter__c>();
        String taskId;
        String insuranceAccountId;
        String corpAccountId;
        String subjectType = System.label.BLN_AssignDirectToBVT;
    // Account objInsuranceAccount;
    // Account objCorporateAccount;
        try{
            if(corporateObj.BLN_InsuranceSite__c != Null){
                insuranceAccountId = corporateObj.BLN_InsuranceSite__c;
            }
        if(corporateObj.BLN_CorporateSite__c != Null){
                corpAccountId = corporateObj.BLN_CorporateSite__c;
            }

            if(BLN_AccountRuleParameter__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                if(String.isNotBlank(insuranceAccountId) && String.isNotBlank(corpAccountId)){
                    arpList1 = BLN_AccountRuleParameterUtil.getAccountRuleParameters(label.BLN_AutoDivertoAuthTeamRecordType,insuranceAccountId,date.today());
                    arpList2 = BLN_AccountRuleParameterUtil.getAccountRuleParameters(label.BLN_AutoDivertoAuthTeamRecordType,corpAccountId,date.today());
                }
                else if(String.isNotBlank(insuranceAccountId) && String.isBlank(corpAccountId)){
                    arpList1 = BLN_AccountRuleParameterUtil.getAccountRuleParameters(label.BLN_AutoDivertoAuthTeamRecordType,insuranceAccountId,date.today());
                }
                else if(String.isBlank(insuranceAccountId) && String.isNotBlank(corpAccountId)){
                arpList2 = BLN_AccountRuleParameterUtil.getAccountRuleParameters(label.BLN_AutoDivertoAuthTeamRecordType,corpAccountId,date.today());
                }
            }
            
            if(arpList1 != Null && !arpList1.isEmpty()){
            // objInsuranceAccount = [SELECT Id, 
            //                               BLN_FLTRIndicator__c
            //                         FROM Account
            //                         WHERE Id =: corporateObj.BLN_InsuranceSite__c
            //                         WITH SECURITY_ENFORCED
            //                         LIMIT 1];
            arpList.addAll(arpList1);
        }
        if(arpList2 != Null && !arpList2.isEmpty()){
            // objCorporateAccount = [SELECT Id, 
            //                                 BLN_FLTRIndicator__c
            //                         FROM Account
            //                         WHERE Id =: corporateObj.BLN_CorporateSite__c
            //                         WITH SECURITY_ENFORCED
            //                         LIMIT 1];   
                arpList.addAll(arpList2);
            }
        
            if(arpList != Null && !arpList.isEmpty()){
                for(BLN_AccountRuleParameter__c objectArp: arpList){
                    if(objectArp.BLN_AutomaticDiverttoAuthorisationTeam__c == System.label.BLN_AllCasesForValidation){
                        if(corporateObj.BLN_Origin__c == System.label.BLN_ManualOrigin || corporateObj.BLN_Origin__c == System.label.BLN_PDSOrigin || corporateObj.BLN_Origin__c == System.label.BLN_DirectAPIOrigin){
                            String taskAccId = objectArp.BLN_Account__c;
                            taskId = BLN_ProductAuthorisation.createBvtTask(caseId, subjectType, slotDate, taskAccId);
                        }
                    }
                    if(objectArp.BLN_AutomaticDiverttoAuthorisationTeam__c == System.label.BLN_NonPDSCasesForValidation){
                        if(corporateObj.BLN_Origin__c == System.label.BLN_ManualOrigin){
                            String taskAccId = objectArp.BLN_Account__c;
                            taskId = BLN_ProductAuthorisation.createBvtTask(caseId, subjectType, slotDate, taskAccId);
                        }
                    }
                }
            }
            
        // Group fltrQueue = new Group();
        // if(Task.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
        //     fltrQueue = [SELECT Id, 
        //                         Name 
        //                     FROM Group 
        //                     WHERE Type =:label.BLN_Queue 
        //                     AND developerName =:label.BLN_FLTRQueue 
        //                     WITH SECURITY_ENFORCED 
        //                     LIMIT 1];
        // }    
        // if(taskId != Null){
        //     Task taskRecord = new Task(id = taskId);
        //     if((objInsuranceAccount != Null && objInsuranceAccount.BLN_FLTRIndicator__c == System.label.BLN_FLTR) || (objCorporateAccount != Null && objCorporateAccount.BLN_FLTRIndicator__c == System.label.BLN_FLTR)){
        //         taskRecord.OwnerId = fltrQueue.Id;
        //     }
        //     update taskRecord;
        // }
        }
        catch(Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
    }
    
    /* MethodName : updateCorporateAmountAuth
    Description : This method is used to update BLN_AuthorizationStatus__c and BLN_AmountAuthorizationRequired__c field:
        Input Parameter : caseId
        Output Parameter :
        CreatedDate: 13-05-2024
        CreatedBy : Pwc-India
        Change log :
         ****************************************/
    /*  *@description:FOUK-3167 This method is used to update Case corporte fields */
    @AuraEnabled
    public static boolean updateCorporateAmountAuth(string caseId){
        List<BLN_Corporate__c> corporateList = new List<BLN_Corporate__c>();
        try {
            Case caseRecord = new Case();
            if(Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                caseRecord = [Select Id,BLN_Corporate__c from case where Id =:caseId WITH SECURITY_ENFORCED LIMIT 1 ];
            }
            if(caseRecord.BLN_Corporate__c!=null){
                if(BLN_Corporate__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                corporateList = [SELECT Id, 
                                        BLN_AuthorizationStatus__c,
                                        BLN_OEAuthorizationRequired__c,
                                        BLN_AmountAuthorizationRequired__c 
                                FROM BLN_Corporate__c 
                                WHERE Id =:caseRecord.BLN_Corporate__c 
                                WITH SECURITY_ENFORCED 
                                LIMIT 1];
                    
                }
                if(!corporateList.isEmpty() && BLN_Corporate__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
                    corporateList[0].BLN_AuthorizationStatus__c = label.BLN_CorporateAuthorizationReqLabel;
                    corporateList[0].BLN_AmountAuthorizationRequired__c = true;
                    update corporateList;
                }
                
            }
            
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return !corporateList.isEmpty() ? true : false;
        
        
    }
    
    /* MethodName : updateCorporateReAmt
    Description : This method is used to update BLN_AuthorizationStatus__c and BLN_AmountAuthorizationRequired__c field:
        Input Parameter : caseId
        Output Parameter :
        CreatedDate: 13-05-2024
        CreatedBy : Pwc-India
        Change log :
         ****************************************/
    /*  *@description:FOUK-7331 This method is used to update Case corporte fields */
    @AuraEnabled
    public static boolean updateCorporateReAmt(string caseId, decimal authorizeAmount){
        List<BLN_Corporate__c> corporateList = new List<BLN_Corporate__c>();
        try {
            Case caseRecord = new Case();
            if(Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
            caseRecord = [SELECT Id,
                                    BLN_Corporate__c 
                            FROM Case 
                            WHERE Id =: caseId 
                            WITH SECURITY_ENFORCED 
                            LIMIT 1 ];
        }
        if(caseRecord.BLN_Corporate__c != null){
            if(BLN_Corporate__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                corporateList = [SELECT Id, 
                                        BLN_AuthorizationStatus__c,
                                        BLN_OEAuthorizationRequired__c,
                                        BLN_AmountAuthorizationRequired__c,
                                        BLN_AmountAuthorized__c 
                                    FROM BLN_Corporate__c 
                                    WHERE Id =: caseRecord.BLN_Corporate__c 
                                    WITH SECURITY_ENFORCED LIMIT 1];
                    
                }
                if(!corporateList.isEmpty() && BLN_Corporate__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
                    corporateList[0].BLN_AuthorizationStatus__c = label.BLN_CorporateAuthorizationReqLabel;
                    corporateList[0].BLN_AmountAuthorizationRequired__c = true;
                    corporateList[0].BLN_AmountAuthorized__c = authorizeAmount;
                    update corporateList;
                }
                
            }
            
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return !corporateList.isEmpty() ? true : false;
        
        
    }
    /* MethodName : getCorporateRecord
    Description : This method is used to get corporate  record against caseId:
        Input Parameter : caseId
        Output Parameter :
        CreatedDate: 13-05-2024
        CreatedBy : Pwc-India
        Change log :
         ****************************************/
    /*  *@description:FOUK-3167 This method is used to  get corporate  record against caseId: */
    @AuraEnabled(cacheable = true)
    public static BLN_Corporate__c getCorporateRecord(string caseId){
        
        BLN_Corporate__c  corporateRecord;
        try {
            if(!string.isBlank(caseId)){
                
                Case caseRecord = new Case();
                if(Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                caseRecord = [SELECT Id,
                                        BLN_Corporate__c 
                                FROM Case 
                                WHERE Id =:caseId 
                                WITH SECURITY_ENFORCED LIMIT 1 ];
            }
            
            if(caseRecord != null && caseRecord.BLN_Corporate__c != null && BLN_Corporate__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                corporateRecord = [SELECT Id,
                                            BLN_OEAuthorizationRequired__c,
                                            BLN_OEAuthorized__c,
                                            BLN_OEAuthorizationRequiredTrade__c,
                                            BLN_OEAuthorizedTrade__c,
                                            BLN_AmountAuthorized__c,
                                            BLN_AmountAuthorizedTrade__c,
                                            BLN_ApprovedLimit__c,
                                            BLN_AuthorizationStatus__c,
                                            BLN_AuthorizationStatusTrade__c,
                                            BLN_AmountAuthorizationRequired__c,
                                            BLN_AmountAuthorizationRequiredTrade__c,
                                            BLN_Origin__c,
                                            BLN_CHFVATStatus__c,
                                            BLN_ProductAuthorised__c,
                                            BLN_ProductAuthorisedTrade__c, 
                                            BLN_CorporateSite__c,
                                            BLN_InsuranceSite__c, 
                                            RecordType.DeveloperName, 
                                            BLN_InsuranceLegalEntity__c,
                                            BLN_CorporateLegalEntity__c 
                                    FROM BLN_Corporate__c 
                                    WHERE id =:caseRecord.BLN_Corporate__c 
                                    WITH SECURITY_ENFORCED 
                                    LIMIT 1];
                    
                }
            }
            
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return corporateRecord;
    }
    
    /* MethodName : getProductExcessArp
    Description : This method is used to get product excess arp using split bill  against account:
        Input Parameter :
        Output Parameter :
        CreatedDate: 23-05-2024
        CreatedBy : Pwc-India
        Change log :
         ****************************************/
    /*  *@description:FOUK- 7082 This method is used to get product excess arp using split bill  against account: */
    @AuraEnabled
    public static List<BLN_AccountRuleParameter__c> getProductExcessArp(string arpRecordType, string accountId, date jobDate){
        
        List<BLN_AccountRuleParameter__c>  productExcessArps = new List<BLN_AccountRuleParameter__c>();
        try{
            List<BLN_AccountRuleParameter__c> splitBillArps = BLN_AccountRuleParameterUtil.getAccountRuleParameters(label.BLN_SplitBillRecType,accountId,jobDate);
            
            if(BLN_AccountRuleParameter__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() && !splitBillArps.isEmpty()) {
            productExcessArps = [SELECT Id, 
                                        BLN_Product__c,
                                        BLN_ProductCategory__c 
                                FROM  BLN_AccountRuleParameter__c 
                                WHERE BLN_SplitBill__c IN: splitBillArps  
                                AND recordType.Name =: arpRecordType 
                                WITH SECURITY_ENFORCED  
                                LIMIT 49999];
        } 
    }
    catch(Exception e){
        BLN_ExceptionLogger.captureException(e);
    }
    return productExcessArps;
    }
    
    /* MethodName : createNoStockTask
    Description : This method is used to This method will create "No Stock" tasks
        Input Parameter :
        Output Parameter :
        CreatedDate: 27-05-2024
        CreatedBy : Pwc-India
        Change log :
         ****************************************/
    /*  *@description:FOUK- 7757 This method is used to This method will create "No Stock" tasks when order products went out of stock */
    @AuraEnabled
    public static void createNoStockTask(string serAppId, string caseId){
        
    ServiceAppointment sApp = [SELECT Id, 
                                    SchedStartTime, 
                                    EarliestStartTime, 
                                    status 
                                FROM ServiceAppointment 
                                WHERE Id =: serAppId 
                                WITH SECURITY_ENFORCED 
                                LIMIT 1];
    list<orderItem> oIRec = new list<orderItem>();
    if(sApp != null){
        oIRec = [SELECT Id, 
                        BLN_ServiceAppointment__c, 
                        BLN_OutOfStock__c
                    FROM OrderItem
                    WHERE BLN_ServiceAppointment__c =: sApp.Id 
                    AND BLN_OutOfStock__c = true 
                    WITH SECURITY_ENFORCED];
        }
        
        if(oIRec != null && !oIRec.isEmpty()){
            Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(label.BLN_ServiceTask).getRecordTypeId();
            Group noStockQueue = new Group();
        noStockQueue = [SELECT Id, 
                                Name 
                        FROM Group 
                        WHERE Type =: label.BLN_Queue 
                        AND developerName =: label.BLN_NoStock 
                        WITH SECURITY_ENFORCED 
                        LIMIT 1];
            
            if(taskRecordTypeId!=null && noStockQueue!=null){
                Task createTask = New Task();
                createTask.Subject = System.label.BLN_NoStockValue;
                createTask.RecordtypeId = taskRecordTypeId;
                createTask.WhatId = caseId;
                createTask.OwnerId = noStockQueue.id;
                createTask.Status = System.label.BLN_TaskStatusOpen; //Label for Open Status
                createTask.Priority = System.label.BLN_NormalStatus; //Label for Normal Priority
                createTask.BLN_IsAutomated__c = true;
                createTask.BLN_Subtype__c = System.label.BLN_NoStockValue;
                createTask.Type = System.label.BLN_NoStockValue;
                createTask.BLN_TaskSubjectType__c = System.label.BLN_NoStockValue;
                createTask.BLN_AppointmentDate__c = date.newInstance(sApp.EarliestStartTime.year(), sApp.EarliestStartTime.month(), sApp.EarliestStartTime.day()); // 7734{
                    INSERT createTask;
                }
            }
    }

        /* MethodName : checkCurrentLoggedinUser
        Description : to check custom permission of current logged in user
            Input Parameter :
            Output Parameter :
            CreatedDate: 27-05-2024
            CreatedBy : Pwc-India
            Change log :
             ****************************************/
        /*  *@description:FOUK- 7148 to check custom permission of current logged in user*/
        
        @AuraEnabled
        public static boolean checkCurrentLoggedinUser(){
            Boolean permissionAssigned;
        CustomPermission cSid = [SELECT Id 
                                    FROM CustomPermission 
                                    WHERE DeveloperName =: System.label.BLN_AppointmentOverrideLabel 
                                    WITH SECURITY_ENFORCED];
        List<PermissionSetAssignment> pSAssign = [SELECT Id, 
                                                            PermissionSetId, 
                                                            AssigneeId 
                                                    FROM PermissionSetAssignment
                                                    WHERE PermissionSetId IN 
                                                        (SELECT ParentId
                                                        FROM SetupEntityAccess 
                                                        WHERE SetupEntityId =: CSid.id)  
                                                    AND AssigneeId =: UserInfo.getUserId()
                                                    WITH SECURITY_ENFORCED 
                                                    LIMIT 1];
        
        if(pSAssign != null && !pSAssign.isEmpty()){ 
            permissionAssigned = true;
            }
            return permissionAssigned;
        }
        
        @AuraEnabled
        public static boolean checkCurrentLoggedinUserPermission(){
            Boolean permissionAssigned = false;
        CustomPermission cSid = [SELECT Id 
                                    FROM CustomPermission 
                                    WHERE DeveloperName =: System.label.BLN_AppointmentOverrideLabel 
                                    WITH SECURITY_ENFORCED];
        List<PermissionSetAssignment> pSAssign = [SELECT Id, 
                                                            PermissionSetId, 
                                                            AssigneeId 
                                                    FROM PermissionSetAssignment
                                                    WHERE PermissionSetId IN 
                                                        (SELECT ParentId
                                                            FROM SetupEntityAccess 
                                                            WHERE SetupEntityId =: CSid.id)
                                                    AND AssigneeId =: UserInfo.getUserId()
                                                    WITH SECURITY_ENFORCED 
                                                    LIMIT 1];
        
            if(pSAssign!=null && !pSAssign.isEmpty()){ permissionAssigned = true;
            }
            return permissionAssigned;
        }

        /* MethodName : corporateAccountUpdate
        Description : to update corporate record and update bvt tasks
            Input Parameter :
            Output Parameter :
            CreatedDate: 27-05-2024
            CreatedBy : Pwc-India
            Change log :
             ****************************************/
        /*  *@description:FOUK- 3278 to update corporate record and update bvt tasks*/
        @AuraEnabled
        public static void corporateAccountUpdate(string caseId, double cpqAmount){
            if(caseId != null && cpqAmount!= null){
            Case caseObj = [SELECT Id,
                                    BLN_Corporate__c 
                            FROM Case 
                            WHERE Id =: caseId 
                            WITH SECURITY_ENFORCED 
                            LIMIT 1];
            list<Task> authLimitBreachTask = [SELECT Id, 
                                                        Subject, 
                                                        BLN_TaskSubjectType__c, 
                                                        WhatId, 
                                                        Status
                                                FROM Task 
                                                WHERE WhatId =: caseObj.Id 
                                                AND Subject =: System.label.BLN_AuthorisationBreachedLabel 
                                                AND Status =: System.label.BLN_OpenLabel 
                                                WITH SECURITY_ENFORCED];
                if(authLimitBreachTask!=null && authLimitBreachTask.size()>0){
                    authLimitBreachTask[0].BLN_TaskSubjectType__c    =  System.label.BLN_AuthReqAmountLabel;
                    //authLimitBreachTask.ActivityDate = system.today();
                    update authLimitBreachTask;
                }
                
            BLN_Corporate__c corporateObj = [SELECT Id, 
                                                    BLN_AuthorizationStatus__c, 
                                                    BLN_ApprovedLimit__c, 
                                                    BLN_AmountAuthorized__c, 
                                                    BLN_AmountAuthorizationRequired__c  
                                                FROM BLN_Corporate__c 
                                                WHERE Id =: CaseObj.BLN_Corporate__c 
                                                WITH SECURITY_ENFORCED];
                
                if(CorporateObj!=null && CorporateObj.BLN_AuthorizationStatus__c == System.label.BLN_ApprovedLabel && CorporateObj.BLN_AmountAuthorized__c < cpqAmount){
                    CorporateObj.BLN_AmountAuthorizationRequired__c= true;
                    CorporateObj.BLN_AuthorizationStatus__c=System.label.BLN_AuthorizationRequired;
                    CorporateObj.BLN_AmountAuthorized__c = cpqAmount;
                    update CorporateObj;
            }
        }
    }

        /* MethodName : getProductAllowance
        Description : This method is used to get product allowance arp :
            Input Parameter :
            Output Parameter :
            CreatedDate: 23-05-2024
            CreatedBy : Pwc-India
            Change log :
             ****************************************/
        /*  *@description:FOUK- 7082 This method is used to get product allowance arp: */
        @AuraEnabled
        public static List<BLN_AccountRuleParameter__c> getProductAllowance(string arpRecordType, string accountId, date jobDate){
            
            List<BLN_AccountRuleParameter__c>  productAllowancesList = new List<BLN_AccountRuleParameter__c>();
            try{
                List<BLN_AccountRuleParameter__c> productAllowanceArps = BLN_AccountRuleParameterUtil.getAccountRuleParameters(label.BLN_ProductAllowanceRecTypeName,accountId,jobDate);
                if(productAllowanceArps!=null){
                    if(BLN_AccountRuleParameter__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()) {
                    productAllowancesList = [SELECT Id, 
                                                    BLN_Product__c,
                                                    BLN_ProductCategory__c,
                                                    BLN_ProductAllowance__c,
                                                    BLN_Account__c,
                                                    BLN_AuthorisationRequired__c 
                                            FROM BLN_AccountRuleParameter__c 
                                            WHERE Id IN: productAllowanceArps 
                                            WITH SECURITY_ENFORCED 
                                            LIMIT 49999];
                }
                }
            }
            catch(Exception e){
                BLN_ExceptionLogger.captureException(e);
                
            }
            return productAllowancesList;
        }
        
        /* MethodName : getAutomaticDiverArps
        Description : This method is used to :
            Input Parameter : accountId
            Output Parameter :
            CreatedDate: 31-05-2024
            CreatedBy : Pwc-India
            Change log :
             ****************************************/
        /*  *@description:FOUK- This method is used to  */
        @InvocableMethod(label='getAutomaticDiverArps')
        public static List<string> getAutomaticDiverArps(List<String> accountIds){
            List<string>automaticDivert =  new List<String>();
            try{
                List<BLN_AccountRuleParameter__c> arpList = new List<BLN_AccountRuleParameter__c>();
                
                if(BLN_AccountRuleParameter__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                    arpList = BLN_AccountRuleParameterUtil.getAccountRuleParameters(label.BLN_AutoDivertoAuthTeamRecordType,accountIds[0],date.today());
                }
                if(arpList != null && !arpList.isEmpty() && arpList !=null){
                    automaticDivert.add(arpList[0].BLN_AutomaticDiverttoAuthorisationTeam__c);
                }
            }
            catch(Exception e){
                BLN_ExceptionLogger.captureException(e);
            }
            return automaticDivert;
        }
    }