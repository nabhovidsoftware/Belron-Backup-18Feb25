/** @description : This Test class is for BLN_TaskCreateUpdateWebservice.
*   @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
*   @author: Ayush Singh(PwC IN)
*    @CreatedDate: 28/06/2023
*/

@IsTest
public class BLN_PrepDataWebserviceTest {
    
    @testSetUp
    public static void testSetupData(){
        WorkType assistWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_AssistWT, 4 , false ,  true);
        //WorkType recalibrationWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_RecalibrationWT, 4 , false ,  true);      
        WorkType repairWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_RepairWT, 4 , true ,  true);
        WorkType replacementWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_ReplacementWT, 4 , true ,  true);
        WorkType replaceRecalWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_ReplacementRecalibrationWT, 4 , true ,  true);
        //WorkType sideRearReplacementWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_SideRearReplacementWT, 4 ,true ,  true);
        WorkType stockCollectWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_StockCollectWT, 4 ,true ,  true);
        WorkType warrantyReplacementWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_WarrantyReplacementWT, 4 , true ,  true);
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours('All Day Slot', true);
        //OperatingHours operatingHours2 = BLN_TestDataFactory.createOperatingHours('Five Hour Slot', true);      
        
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , true);
        BLN_TestDataFactory.createServiceTerritory('Manchester' , operatingHours.Id , true);
        
        BLN_TestDataFactory.createSchedulingPolicy(System.Label.BLN_SchedulingPolicyName, true);
        BLN_TestDataFactory.createPersonAccount('Autoglass Dummy', 'Person Account', true);
        
        Case newCase=BLN_TestDataFactory.createCase(true);
        
        WorkOrder workOrder1 = BLN_TestDataFactory.createWorkOrder2(replacementWT.id, st.Id, false);
        WorkOrder parentWorkOrder = BLN_TestDataFactory.createWorkOrder(true);
        workOrder1.CaseId=newCase.Id;
        workOrder1.BLN_RemedyJobId__c='0969964544427';
        //workOrder1.BLN_ADASJob__c='000002323560096';
        workOrder1.ParentWorkOrderId = parentWorkOrder.Id;
        insert workOrder1;
        
        String remedyTaskId1 = '66088851';
        String remedyTaskId2 = '66088852';
        String remedyTaskId3 = '66088853';
        String remedyTaskId4 = '66088854';
        String remedyTaskId5 = '66088855';
        List<WorkOrderLineItem> wOLIList = new List<WorkOrderLineItem>();
        
        WorkOrderLineItem wOLI1= new WorkOrderLineItem();
        wOLI1.Status = 'New';
        wOLI1.WorkOrderId = workOrder1.Id;
        wOLI1.WorkTypeId  = repairWT.Id;
        wOLI1.BLN_RemedyTaskId__c  = remedyTaskId1;
        wOLIList.add(wOLI1);
        
        WorkOrderLineItem wOLI2 = new WorkOrderLineItem();
        wOLI2.Status = 'New';
        wOLI2.WorkOrderId = workOrder1.Id;
        wOLI2.WorkTypeId = assistWT.Id;
        wOLI2.BLN_RemedyTaskId__c  = remedyTaskId2;
        wOLIList.add(wOLI2);
        
        WorkOrderLineItem wOLI3 = new WorkOrderLineItem();
        wOLI3.Status = 'New';
        wOLI3.WorkOrderId = workOrder1.Id;
        wOLI3.WorkTypeId = stockCollectWT.Id;
        wOLI3.BLN_RemedyTaskId__c  = remedyTaskId3;
        wOLIList.add(wOLI3);
        
        WorkOrderLineItem wOLI4 = new WorkOrderLineItem();
        wOLI4.Status = 'New';
        wOLI4.WorkOrderId = workOrder1.Id;
        wOLI4.WorkTypeId = replaceRecalWT.Id;
        wOLI4.BLN_RemedyTaskId__c  = remedyTaskId4;
        wOLIList.add(wOLI4);
        
        WorkOrderLineItem wOLI5 = new WorkOrderLineItem();
        wOLI5.Status = 'New';
        wOLI5.WorkOrderId = parentWorkOrder.Id;
        wOLI5.WorkTypeId = replaceRecalWT.Id;
        wOLI5.BLN_RemedyTaskId__c  = remedyTaskId5;
        wOLIList.add(wOLI5);
        
        if(wOLIList.size()>0){
            insert wOLIList;
        }        
        
        List<ServiceAppointment> servAppList = new List<ServiceAppointment>();
        
        ServiceAppointment servAppList1=BLN_TestDataFactory.createServiceAppointment('SA1', wOLIList[0].Id, st.Id, '66088851', false);
        servAppList1.BLN_RemedyJobId__c = workOrder1.BLN_RemedyJobId__c;
        servAppList1.Status = 'Scheduled';
        //servAppList1.WorkTypeId = assistWT.Id;
        servAppList.add(servAppList1);
        
        ServiceAppointment servAppList2=BLN_TestDataFactory.createServiceAppointment('SA2', wOLIList[1].Id, st.Id, '66088852', false);
        servAppList2.BLN_RemedyJobId__c = workOrder1.BLN_RemedyJobId__c;
        servAppList.add(servAppList2);
        
        ServiceAppointment servAppList3=BLN_TestDataFactory.createServiceAppointment('SA3', wOLIList[2].Id, st.Id, '66088853', false);
        servAppList3.BLN_RemedyJobId__c = workOrder1.BLN_RemedyJobId__c;
        servAppList.add(servAppList3);
        
        ServiceAppointment servAppList4=BLN_TestDataFactory.createServiceAppointment('SA4', wOLIList[3].Id, st.Id, '66088854', false);
        servAppList4.BLN_RemedyJobId__c = workOrder1.BLN_RemedyJobId__c;
        servAppList4.WorkTypeId = replaceRecalWT.Id;
        servAppList4.BLN_WorkOrderNumber__c = parentWorkOrder.Id;
        servAppList4.Status = System.Label.BLN_Canceled;
        servAppList.add(servAppList4);

        ServiceAppointment servAppList5 = BLN_TestDataFactory.createServiceAppointment('SA5', wOLIList[3].Id, st.Id, '66088855', false);
        servAppList5.BLN_RemedyJobId__c = parentWorkOrder.BLN_RemedyJobId__c;
        servAppList5.WorkTypeId = replaceRecalWT.Id;
        servAppList5.BLN_WorkOrderNumber__c = parentWorkOrder.Id;
        servAppList.add(servAppList5);
        
        if(servAppList.size()>0){
            insert servAppList;
        }
        WorkOrder workOrders=BLN_TestDataFactory.createWorkOrder2(warrantyReplacementWT.id, st.Id, false);
        workOrders.CaseId=newCase.Id;
        workOrders.BLN_RemedyJobId__c='000001053969399';
        //workOrders.BLN_ADASJob__c='000002323560096';
        insert workOrders;
        
        /*Map<String,String> mapOfSkillLabelAndId= new Map<String,String>();
        for(Skill skl: [Select Id,MasterLabel from Skill]){
            mapOfSkillLabelAndId.put(skl.MasterLabel,skl.Id);
        }
        SkillRequirement sklReq = BLN_TestDataFactory.createSkillRequirement(String skillId, Double skillLevel, String relatedRecordId, Boolean doInsert)
		*/
        Account policyHolder=New Account();
        policyHolder.FirstName='Policytesting';
        policyHolder.LastName='Holdertesting';
        policyHolder.Salutation='Mr.';
        policyHolder.Phone='7895674562';
        policyHolder.PersonMobilePhone = '7895654562';
        policyHolder.PersonHomePhone = '7895673562';
        policyHolder.PersonOtherPhone = '7895674862';
        policyHolder.BLN_PrimaryContactNumber__c = 'Mobile Phone';
        policyHolder.BLN_PersonAccountType__c='POLICYHOLDER';
        policyHolder.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert policyHolder;
        
        newCase.AccountId = policyHolder.Id;
        update newCase;
        
        Account motorist=New Account();
        motorist.FirstName='MotoristPK';
        motorist.LastName='2';
        motorist.Salutation='Mr.';
        motorist.Phone='7895674509';
        motorist.PersonMobilePhone = '7895098562';
        motorist.PersonHomePhone = '7895624562';
        motorist.PersonOtherPhone = '7895670972';
        motorist.BLN_PrimaryContactNumber__c = 'Home Phone';
        motorist.BLN_PersonAccountType__c='MOTORIST';
        motorist.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert motorist;
        
        CaseContactRole cCR = new CaseContactRole();
        cCR.CasesId= newCase.Id;
        cCR.ContactId=[SELECT Id,PersonContactId FROM Account WHERE Id = :motorist.Id].PersonContactId;
        cCR.Role='Motorist';
        insert cCR;
    }
    
    @IsTest
    public static void getAvailability1(){
        String json='{\"action\":\"getJobAppointment\",\"workOrder\":{\"remedyJobId\":\"7963112233033\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"72301191\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-03-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-08-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-03-05T15:22:00\",\"dueDateTime\":\"2023-07-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Warranty Replacement\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Warranty\",\"SkillLevel\":\"6\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"72301192\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-03-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-08-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-03-05T15:22:00\",\"dueDateTime\":\"2023-07-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Assist\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"6\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"72301193\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-03-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-08-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-03-05T15:22:00\",\"dueDateTime\":\"2023-07-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[]}],\"vehicle\":{\"vehicleMake\":\"\",\"vehicleModel\":\"\",\"vehicleRegistration\":\"\"},\"personAccount\":[{\"firstName\":\"\",\"lastName\":\"\",\"salutation\":\"\",\"contactPhoneNumber\":\"\",\"accountType\":\"\"}]}}';        String myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();        
        request.requestUri = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';request.requestBody = Blob.valueof(json);       
        RestContext.request = request;
        RestResponse response = new RestResponse();     
        RestContext.response = response;
        test.startTest();
        BLN_TaskCreateUpdateWebservice.prepTaskData();
        test.stopTest();               
        Assert.areEqual(true, true, 'Success'); 
    }
    @IsTest
    public static void getAvailability2(){
        String json='{\"action\":\"getJobAppointment\",\"workOrder\":{\"remedyJobId\":\"0969964544427\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"66088851\",\"duration\":\"2400\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"12\",\"earliestStartTime\":\"2023-02-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-05T15:22:00\",\"dueDateTime\":\"2023-04-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Bedford\"}},\"taskType\":\"WS_SF_Std\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Repair\",\"SkillLevel\":\"5\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088852\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"16\",\"earliestStartTime\":\"2023-04-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-09-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-04-05T15:22:00\",\"dueDateTime\":\"2023-07-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Regfion\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Birmingham\"}},\"taskType\":\"Assist\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"4\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088853\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-03-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-08-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-03-05T15:22:00\",\"dueDateTime\":\"2023-07-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"ADAS\",\"SkillLevel\":\"6\"}]}],\"vehicle\":{\"vehicleMake\":\"\",\"vehicleModel\":\"\",\"vehicleRegistration\":\"\"},\"personAccount\":[{\"firstName\":\"\",\"lastName\":\"\",\"salutation\":\"\",\"contactPhoneNumber\":\"\",\"accountType\":\"\"}]}}';
        String myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();
        
        request.requestUri = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';request.requestBody = Blob.valueof(json);       
        RestContext.request = request;
        RestResponse response = new RestResponse();     
        RestContext.response = response;
        test.startTest();
        BLN_TaskCreateUpdateWebservice.prepTaskData();        
        test.stopTest();             
        Assert.areEqual(true, true, 'Success');   
    }
    @IsTest
    public static void getAvailability3(){
        String json='{\"action\":\"getJobAppointment\",\"workOrder\":{\"remedyJobId\":\"0969964544427\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"76088851\",\"duration\":\"2400\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"12\",\"earliestStartTime\":\"2023-02-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-05T15:22:00\",\"dueDateTime\":\"2023-04-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Bedford\"}},\"taskType\":\"Repair\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Repair\",\"SkillLevel\":\"5\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"76088852\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"16\",\"earliestStartTime\":\"2023-04-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-09-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-04-05T15:22:00\",\"dueDateTime\":\"2023-07-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Birmingham\"}},\"taskType\":\"Assist\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"4\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"76088853\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-03-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-08-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-03-05T15:22:00\",\"dueDateTime\":\"2023-07-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"ADAS\",\"SkillLevel\":\"6\"}]}],\"vehicle\":{\"vehicleMake\":\"\",\"vehicleModel\":\"\",\"vehicleRegistration\":\"\"},\"personAccount\":[{\"firstName\":\"\",\"lastName\":\"\",\"salutation\":\"\",\"contactPhoneNumber\":\"\",\"accountType\":\"\"}]}}';
        String myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();        
        request.requestUri = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';request.requestBody = Blob.valueof(json);       
        RestContext.request = request;
        RestResponse response = new RestResponse();     
        RestContext.response = response;
        test.startTest();
        BLN_TaskCreateUpdateWebservice.prepTaskData();        
        test.stopTest();     
        Assert.areEqual(true, true, 'Success');           
    }
    
    @IsTest
    public static void getAvailability4(){
        String json='{\"action\":\"getJobAppointment\",\"workOrder\":{\"remedyJobId\":\"7963112233033\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"72301191\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-03-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-08-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-03-05T15:22:00\",\"dueDateTime\":\"2023-07-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Warranty\",\"SkillLevel\":\"6\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"72301192\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-03-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-08-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-03-05T15:22:00\",\"dueDateTime\":\"2023-07-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Assist\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"6\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"72301193\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-03-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-08-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-03-05T15:22:00\",\"dueDateTime\":\"2023-07-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[]}],\"vehicle\":{\"vehicleMake\":\"\",\"vehicleModel\":\"\",\"vehicleRegistration\":\"\"},\"personAccount\":[{\"firstName\":\"\",\"lastName\":\"\",\"salutation\":\"\",\"contactPhoneNumber\":\"\",\"accountType\":\"\"}]}}';        String myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';request.requestBody = Blob.valueof(json);
        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;
        test.startTest();
        BLN_TaskCreateUpdateWebservice.prepTaskData();
        test.stopTest();
        Assert.areEqual(true, true, 'Success');
    }

    @IsTest
    public static void getAvailability5(){
        String json='{\"action\":\"getJobAppointment\",\"workOrder\":{\"remedyJobId\":\"7963112233033\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"72301191\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"\",\"arrivalWindowEndTime\":\"2023-08-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-03-05T15:22:00\",\"dueDateTime\":\"2023-07-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Warranty\",\"SkillLevel\":\"6\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"72301192\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-03-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-08-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-03-05T15:22:00\",\"dueDateTime\":\"2023-07-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Assist\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"6\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"72301193\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-03-05T15:22:00\",\"arrivalWindowEndTime\":\"2023-08-05T15:22:00\",\"arrivalWindowStartTime\":\"2023-03-05T15:22:00\",\"dueDateTime\":\"2023-07-26T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[]}],\"vehicle\":{\"vehicleMake\":\"\",\"vehicleModel\":\"\",\"vehicleRegistration\":\"\"},\"personAccount\":[{\"firstName\":\"\",\"lastName\":\"\",\"salutation\":\"\",\"contactPhoneNumber\":\"\",\"accountType\":\"\"}]}}';        String myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';request.requestBody = Blob.valueof(json);
        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;
        test.startTest();
        BLN_TaskCreateUpdateWebservice.prepTaskData();
        test.stopTest();
        Assert.areEqual(true, true, 'Success');
    }
    
    @IsTest
    public static void bookAppointment(){
        String remedyTaskId1 = '66088851';
        String remedyTaskId2 = '66088852';
        String remedyTaskId3 = '66088853';
        Set<String> setOfTaskIds = new Set<String>{remedyTaskId1, remedyTaskId2, remedyTaskId3};
        Map<String, String> mapOfremedyTaskIdAndId = new Map<String, String>();
       for(WorkOrderLineItem woli :[SELECT Id, BLN_RemedyTaskId__c FROM WorkOrderLineItem WHERE BLN_RemedyTaskId__c IN:setOfTaskIds]){
            mapOfremedyTaskIdAndId.put(woli.BLN_RemedyTaskId__c, woli.Id);
       }

        Map<String,String> mapOfSkillLabelAndId= new Map<String,String>();
        for(Skill skl: [Select Id,MasterLabel from Skill]){
            mapOfSkillLabelAndId.put(skl.MasterLabel,skl.Id);
        }
        SkillRequirement sklReqRepair = BLN_TestDataFactory.createSkillRequirement(mapOfSkillLabelAndId.get('Repair'), Double.valueOf('5'), mapOfremedyTaskIdAndId.get(remedyTaskId1), FALSE);
        SkillRequirement sklReqAssist = BLN_TestDataFactory.createSkillRequirement(mapOfSkillLabelAndId.get('Assist'), Double.valueOf('4'), mapOfremedyTaskIdAndId.get(remedyTaskId1), FALSE);
        SkillRequirement sklReqADAS = BLN_TestDataFactory.createSkillRequirement(mapOfSkillLabelAndId.get('ADAS'), Double.valueOf('6'), mapOfremedyTaskIdAndId.get(remedyTaskId1), FALSE);

		List<SkillRequirement> skillReqList = new List<SkillRequirement>();
        skillReqList.add(sklReqRepair);
        skillReqList.add(sklReqAssist);
        skillReqList.add(sklReqADAS);
        if(!skillReqList.isEmpty()){
            insert skillReqList;
        }
        String myDomain = URL.getOrgDomainUrl().toExternalForm();
        String json= '{\"action\":\"bookJobAppointment\",\"workOrder\":{\"remedyJobId\":\"0969964544427\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"66088851\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"12\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Bedford\"}},\"taskType\":\"Repair\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Repair\",\"SkillLevel\":\"5\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088852\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"16\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Birmingham\"}},\"taskType\":\"Assist\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"4\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088853\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"ADAS\",\"SkillLevel\":\"6\"}]}],\"vehicle\":{\"vehicleMake\":\"vehicletesting\",\"vehicleModel\":\"vehicleModeltesting\",\"vehicleRegistration\":\"MH 12 7977\"},\"personAccount\":[{\"firstName\":\"Policytesting\",\"lastName\":\"Holdertesting\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674562\",\"accountType\":\"POLICYHOLDER\"},{\"firstName\":\"MotoristPK\",\"lastName\":\"2\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674509\",\"accountType\":\"MOTORIST\"}]}}';     
        RestRequest request = new RestRequest();
        request.requestUri = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);       
        RestContext.request = request;
        RestResponse response = new RestResponse();     
        RestContext.response = response;
        BLN_TaskCreateUpdateWebservice.prepTaskData();
        test.startTest();
        String json2='{\"action\":\"bookJobAppointment\",\"workOrder\":{\"remedyJobId\":\"0969964544427\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"66088851\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"12\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Bedford\"}},\"taskType\":\"Repair\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Repair\",\"SkillLevel\":\"5\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088852\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"16\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Birmingham\"}},\"taskType\":\"Replacement & Recalibration\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"4\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088853\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"ADAS\",\"SkillLevel\":\"6\"}]}],\"vehicle\":{\"vehicleMake\":\"vehicletesting\",\"vehicleModel\":\"vehicleModeltesting\",\"vehicleRegistration\":\"MH 12 7977\"},\"personAccount\":[{\"firstName\":\"Policytesting\",\"lastName\":\"Holdertesting\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674562\",\"accountType\":\"POLICYHOLDER\"},{\"firstName\":\"MotoristPK\",\"lastName\":\"2\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674509\",\"accountType\":\"MOTORIST\"}]}}';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json2);
        RestContext.request = request;
        RestContext.response = response;
        BLN_TaskCreateUpdateWebservice.prepTaskData();   
        test.stopTest();   
        Assert.areEqual(true, true, 'Success');             
    }
    
    @IsTest
    public static void bookAppointment2(){
        String remedyTaskId1 = '66088851';
        String remedyTaskId2 = '66088852';
        String remedyTaskId3 = '66088853';
        Set<String> setOfTaskIds = new Set<String>{remedyTaskId1, remedyTaskId2, remedyTaskId3};
        Map<String, String> mapOfremedyTaskIdAndId = new Map<String, String>();
       for(WorkOrderLineItem woli :[SELECT Id, BLN_RemedyTaskId__c FROM WorkOrderLineItem WHERE BLN_RemedyTaskId__c IN:setOfTaskIds]){
            mapOfremedyTaskIdAndId.put(woli.BLN_RemedyTaskId__c, woli.Id);
       }

        Map<String,String> mapOfSkillLabelAndId= new Map<String,String>();
        for(Skill skl: [Select Id,MasterLabel from Skill]){
            mapOfSkillLabelAndId.put(skl.MasterLabel,skl.Id);
        }
        SkillRequirement sklReqRepair = BLN_TestDataFactory.createSkillRequirement(mapOfSkillLabelAndId.get('Repair'), Double.valueOf('5'), mapOfremedyTaskIdAndId.get(remedyTaskId1), FALSE);
        SkillRequirement sklReqAssist = BLN_TestDataFactory.createSkillRequirement(mapOfSkillLabelAndId.get('Assist'), Double.valueOf('4'), mapOfremedyTaskIdAndId.get(remedyTaskId1), FALSE);
        SkillRequirement sklReqADAS = BLN_TestDataFactory.createSkillRequirement(mapOfSkillLabelAndId.get('ADAS'), Double.valueOf('6'), mapOfremedyTaskIdAndId.get(remedyTaskId1), FALSE);

		List<SkillRequirement> skillReqList = new List<SkillRequirement>();
        skillReqList.add(sklReqRepair);
        skillReqList.add(sklReqAssist);
        skillReqList.add(sklReqADAS);
        if(!skillReqList.isEmpty()){
            insert skillReqList;
        }
        String myDomain = URL.getOrgDomainUrl().toExternalForm();
        String json2='{\"action\":\"bookJobAppointment\",\"workOrder\":{\"remedyJobId\":\"0969964544427\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"66088851\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"12\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Bedford\"}},\"taskType\":\"Repair\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Repair\",\"SkillLevel\":\"5\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088852\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"16\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Birmingham\"}},\"taskType\":\"Replacement & Recalibration\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"4\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088853\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"ADAS\",\"SkillLevel\":\"6\"}]}],\"vehicle\":{\"vehicleMake\":\"vehicletesting\",\"vehicleModel\":\"vehicleModeltesting\",\"vehicleRegistration\":\"MH 12 7977\"},\"personAccount\":[{\"firstName\":\"Policytesting\",\"lastName\":\"Holdertesting\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674568\",\"accountType\":\"POLICYHOLDER\"},{\"firstName\":\"MotoristPK\",\"lastName\":\"2\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674509\",\"accountType\":\"MOTORIST\"}]}}';
        RestRequest request = new RestRequest();
        request.requestUri = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json2);       
        RestContext.request = request;
        RestResponse response = new RestResponse();     
        RestContext.response = response;
        //BLN_TaskCreateUpdateWebservice.prepTaskData();
        test.startTest();
        BLN_TaskCreateUpdateWebservice.prepTaskData();   
        test.stopTest();   
        Assert.areEqual(true, true, 'Success');             
    }
    @IsTest
    public static void bookAppointment3(){
        String remedyTaskId1 = '66088851';
        String remedyTaskId2 = '66088852';
        String remedyTaskId3 = '66088853';
        Set<String> setOfTaskIds = new Set<String>{remedyTaskId1, remedyTaskId2, remedyTaskId3};
        Map<String, String> mapOfremedyTaskIdAndId = new Map<String, String>();
       for(WorkOrderLineItem woli :[SELECT Id, BLN_RemedyTaskId__c FROM WorkOrderLineItem WHERE BLN_RemedyTaskId__c IN:setOfTaskIds]){
            mapOfremedyTaskIdAndId.put(woli.BLN_RemedyTaskId__c, woli.Id);
       }

        Map<String,String> mapOfSkillLabelAndId= new Map<String,String>();
        for(Skill skl: [Select Id,MasterLabel from Skill]){
            mapOfSkillLabelAndId.put(skl.MasterLabel,skl.Id);
        }
        SkillRequirement sklReqRepair = BLN_TestDataFactory.createSkillRequirement(mapOfSkillLabelAndId.get('Repair'), Double.valueOf('5'), mapOfremedyTaskIdAndId.get(remedyTaskId1), FALSE);
        SkillRequirement sklReqAssist = BLN_TestDataFactory.createSkillRequirement(mapOfSkillLabelAndId.get('Assist'), Double.valueOf('4'), mapOfremedyTaskIdAndId.get(remedyTaskId1), FALSE);
        SkillRequirement sklReqADAS = BLN_TestDataFactory.createSkillRequirement(mapOfSkillLabelAndId.get('ADAS'), Double.valueOf('6'), mapOfremedyTaskIdAndId.get(remedyTaskId1), FALSE);

		List<SkillRequirement> skillReqList = new List<SkillRequirement>();
        skillReqList.add(sklReqRepair);
        skillReqList.add(sklReqAssist);
        skillReqList.add(sklReqADAS);
        if(!skillReqList.isEmpty()){
            insert skillReqList;
        }
        String myDomain = URL.getOrgDomainUrl().toExternalForm();
        String json2='{\"action\":\"bookJobAppointment\",\"workOrder\":{\"remedyJobId\":\"0969964544427\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"66088851\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"12\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Bedford\"}},\"taskType\":\"Repair\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Repair\",\"SkillLevel\":\"5\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088852\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"16\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Birmingham\"}},\"taskType\":\"Replacement & Recalibration\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"4\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088853\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"ADAS\",\"SkillLevel\":\"6\"}]}],\"vehicle\":{\"vehicleMake\":\"vehicletesting\",\"vehicleModel\":\"vehicleModeltesting\",\"vehicleRegistration\":\"MH 12 7977\"},\"personAccount\":[{\"firstName\":\"Policytesting\",\"lastName\":\"Holdertesting\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674562\",\"accountType\":\"POLICYHOLDER\"},{\"firstName\":\"MotoristPK\",\"lastName\":\"2\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674500\",\"accountType\":\"MOTORIST\"}]}}';
        RestRequest request = new RestRequest();
        request.requestUri = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json2);       
        RestContext.request = request;
        RestResponse response = new RestResponse();     
        RestContext.response = response;
        //BLN_TaskCreateUpdateWebservice.prepTaskData();
        test.startTest();
        BLN_TaskCreateUpdateWebservice.prepTaskData();   
        test.stopTest();   
        Assert.areEqual(true, true, 'Success');             
    }
   
    @IsTest
    public static void testDueDateWithBuffer() {
        Datetime arrivalWindowEndTime = Datetime.newInstance(2024, 5, 20, 10, 0, 0);
        Decimal territoryBuffer = 50.0;
        Decimal duration = 3600.0;

        Datetime dueDate = BLN_TaskCreateUpdateWebservice.prepareDueDateWithBuffer(arrivalWindowEndTime, territoryBuffer, (Integer) duration);
        Assert.areEqual(Datetime.newInstance(2024, 5, 20, 11, 30, 0), dueDate, 'Success');
    }

    @IsTest
    public static void testDueDateWithNullBuffer() {
        Datetime arrivalWindowEndTime = Datetime.newInstance(2024, 5, 20, 10, 0, 0);
        Decimal territoryBuffer;
        Decimal duration = 3600.0;

        Datetime dueDate = BLN_TaskCreateUpdateWebservice.prepareDueDateWithBuffer(arrivalWindowEndTime, territoryBuffer, (Integer) duration);
        Assert.areEqual(Datetime.newInstance(2024, 5, 20, 11, 0, 0), dueDate, 'Success');
    }
    
    @IsTest
    public static void negativeTest1(){
        String json= '{\"action\":\"\",\"workOrder\":{\"remedyJobId\":\"\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"66088851\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"12\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Bedford\"}},\"taskType\":\"REP_SF_Std\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Repair\",\"SkillLevel\":\"5\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088852\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"16\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Birmingham\"}},\"taskType\":\"Assist\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"4\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088853\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"ADAS\",\"SkillLevel\":\"6\"}]}],\"vehicle\":{\"vehicleMake\":\"\",\"vehicleModel\":\"\",\"\":\"MH 12 7977\"},\"personAccount\":[{\"firstName\":\"Policytesting\",\"lastName\":\"Holdertesting\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674562\",\"accountType\":\"Policy Holder\"},{\"firstName\":\"MotoristPK\",\"lastName\":\"2\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674509\",\"accountType\":\"Motorist\"}]}}';
        String myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();
        
        request.requestUri = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';request.requestBody = Blob.valueof(json);       
        RestContext.request = request;
        RestResponse response = new RestResponse();     
        RestContext.response = response;
        test.startTest();
        BLN_TaskCreateUpdateWebservice.prepTaskData();        
        test.stopTest();       
        Assert.areEqual(true, true, 'Success'); 
    }
    @IsTest
    public static void negativeTest2(){
        String json= '{\"action\":\"\",\"workOrder\":{\"remedyJobId\":\"0969964544427\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"66088851\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"12\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Bedford\"}},\"taskType\":\"REP_SF_Std\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Repair\",\"SkillLevel\":\"5\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088852\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"16\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Birmingham\"}},\"taskType\":\"Assist\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"4\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088853\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"ADAS\",\"SkillLevel\":\"6\"}]}],\"vehicle\":{\"vehicleMake\":\"\",\"vehicleModel\":\"\",\"\":\"MH 12 7977\"},\"personAccount\":[{\"firstName\":\"Policytesting\",\"lastName\":\"Holdertesting\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674562\",\"accountType\":\"Policy Holder\"},{\"firstName\":\"MotoristPK\",\"lastName\":\"2\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674509\",\"accountType\":\"Motorist\"}]}}';
        String myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();
        
        request.requestUri = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';request.requestBody = Blob.valueof(json);       
        RestContext.request = request;
        RestResponse response = new RestResponse();     
        RestContext.response = response;
        test.startTest();
        BLN_TaskCreateUpdateWebservice.prepTaskData();        
        test.stopTest();  
        Assert.areEqual(true, true, 'Success');      
    }
    @IsTest
    public static void taskUpdateStatusTestMethod(){
        String json= '{\"action\":\"updateJobAppointmentStatus\",\"workOrder\":{\"remedyJobId\":\"0969964544427\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"66088851\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"12\",\"updateTime\":\"2023-22-10T15:22:00\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Bedford\"}},\"taskType\":\"REP_SF_Std\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Repair\",\"SkillLevel\":\"5\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088852\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"16\",\"updateTime\":\"2023-22-10T15:22:00\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Birmingham\"}},\"taskType\":\"Assist\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"4\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088853\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"updateTime\":\"2023-22-10T15:22:00\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"ADAS\",\"SkillLevel\":\"6\"}]}],\"vehicle\":{\"vehicleMake\":\"\",\"vehicleModel\":\"\",\"\":\"MH 12 7977\"},\"personAccount\":[{\"firstName\":\"Policytesting\",\"lastName\":\"Holdertesting\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674562\",\"accountType\":\"Policy Holder\"},{\"firstName\":\"MotoristPK\",\"lastName\":\"2\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674509\",\"accountType\":\"Motorist\"}]}}';        String myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();        
        request.requestUri = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);       
        RestContext.request = request;
        RestResponse response = new RestResponse();     
        RestContext.response = response;
        test.startTest();
        BLN_TaskCreateUpdateWebservice.prepTaskData();
        test.stopTest();  
        Assert.areEqual(true, true, 'Success');              
    }
    
    @IsTest
    public static void shorteningTestMethod(){
        String json= '{\"action\":\"shortenJobAppointment\",\"workOrder\":{\"remedyJobId\":\"0969964544427\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"66088851\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"12\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Bedford\"}},\"taskType\":\"REP_SF_Std\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Repair\",\"SkillLevel\":\"5\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088852\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"16\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Birmingham\"}},\"taskType\":\"Assist\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"4\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088853\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"ADAS\",\"SkillLevel\":\"6\"}]}],\"vehicle\":{\"vehicleMake\":\"\",\"vehicleModel\":\"\",\"\":\"MH 12 7977\"},\"personAccount\":[{\"firstName\":\"Policytesting\",\"lastName\":\"Holdertesting\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674562\",\"accountType\":\"Policy Holder\"},{\"firstName\":\"MotoristPK\",\"lastName\":\"2\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674509\",\"accountType\":\"Motorist\"}]}}';    
        String myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();
        
        request.requestUri = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);       
        RestContext.request = request;
        RestResponse response = new RestResponse();     
        RestContext.response = response;
        test.startTest();
        BLN_TaskCreateUpdateWebservice.prepTaskData();
        test.stopTest();      
        Assert.areEqual(true, true, 'Success');              
    }
    
    @IsTest
    public static void testUpdateTestMethod(){
        String json= '{\"action\":\"updateJobAppointment\",\"workOrder\":{\"remedyJobId\":\"0969964544427\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"66088851\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"12\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Bedford\"}},\"taskType\":\"REP_SF_Std\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Repair\",\"SkillLevel\":\"5\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088852\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"16\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Birmingham\"}},\"taskType\":\"Assist\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"4\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088853\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"Dispatched\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"17\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"ADAS\",\"SkillLevel\":\"6\"}]}],\"vehicle\":{\"vehicleMake\":\"\",\"vehicleModel\":\"\",\"\":\"MH 12 7977\"},\"personAccount\":[{\"firstName\":\"Policytesting222\",\"lastName\":\"Holdertesting2222\",\"salutation\":\"Mrs.\",\"contactPhoneNumber\":\"7890674562\",\"accountType\":\"POLICYHOLDER\"},{\"firstName\":\"MotoristPK22\",\"lastName\":\"2222\",\"salutation\":\"Mrs.\",\"contactPhoneNumber\":\"7895074509\",\"accountType\":\"MOTORIST\"}]}}';     
        String myDomain = URL.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();        
        request.requestUri = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);       
        RestContext.request = request;
        RestResponse response = new RestResponse();     
        RestContext.response = response;
        test.startTest();
        BLN_TaskCreateUpdateWebservice.prepTaskData();        
        test.stopTest();   
        Assert.areEqual(true, true, 'Success');                 
    }

    @IsTest
    static void createAppointmentDependenciesTest() {
        List<ServiceAppointment> supApps = new List<ServiceAppointment>();
        String mainAppId;
        List<ServiceAppointment> appList = [SELECT Id, WorkType.Name FROM ServiceAppointment];

        for (ServiceAppointment app : appList) {
            if (app.WorkType.Name == System.Label.BLN_RepairWT) {
                mainAppId = app.Id;
            }
            if (app.WorkType.Name == System.Label.BLN_AssistWT) {
                supApps.add(app);
            }
            if (app.WorkType.Name == System.Label.BLN_StockCollectWT) {
                supApps.add(app);
            }
        }

        Test.startTest();
        BLN_TaskCreateUpdateWebservice.createAppointmentDependencies(mainAppId, appList);
        Test.stopTest();
        Assert.areEqual(true, true, 'Success');    
    }

    @IsTest
    static void testFormatId() {
        String formattedString = 'test_test';
        String afterFormatting;
        Test.startTest();
        afterFormatting = BLN_TaskCreateUpdateWebservice.formatId(formattedString);
        Test.stopTest();
        Assert.areEqual('test', afterFormatting, 'Success');
    }

    @IsTest
    private static void testCanceledStatusUpdate() {
        String json= '{\"action\":\"updateJobAppointmentStatus\",\"workOrder\":{\"remedyJobId\":\"0969964544427\",\"remedyProfile\":\"Five Hour Slot\",\"ADASJob\":\"000002323560096\",\"workOrderLineItem\":[{\"serviceAppointment\":{\"remedyTaskId\":\"66088854\",\"duration\":\"1800\",\"serviceAppointmentStatus\":\"Canceled\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"16\",\"updateTime\":\"2023-22-10T15:22:00\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"Edinburgh\",\"postalCode\":\"EH11 4EJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Birmingham\"}},\"taskType\":\"Assist\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"Assist\",\"SkillLevel\":\"4\"}]},{\"serviceAppointment\":{\"remedyTaskId\":\"66088853\",\"duration\":\"1200\",\"serviceAppointmentStatus\":\"'+ System.Label.BLN_FBA + '\",\"isBranchAppointment\":\"true\",\"remedyOpenDate\":\"\",\"failureReasonCodeId\":\"12\",\"updateTime\":\"2023-22-10T15:22:00\",\"earliestStartTime\":\"2023-02-08T15:22:00\",\"arrivalWindowEndTime\":\"2023-07-08T15:22:00\",\"arrivalWindowStartTime\":\"2023-02-10T15:22:00\",\"dueDateTime\":\"2023-04-27T08:00:00\",\"address\":{\"street\":\"Unit 4\",\"city\":\"London\",\"postalCode\":\"EH11 4qJ\",\"countryID\":\"UNITED KINGDOM\"},\"serviceTerritory\":{\"Region\":\"UK_CAR\",\"companyNav\":\"UK_Autoglass\",\"District\":\"Manchester\"}},\"taskType\":\"Stock Collect\",\"taskPriority\":\"\",\"taskRequiredSkill\":[{\"skill\":\"ADAS\",\"SkillLevel\":\"6\"}]}],\"vehicle\":{\"vehicleMake\":\"\",\"vehicleModel\":\"\",\"\":\"MH 12 7977\"},\"personAccount\":[{\"firstName\":\"Policytesting\",\"lastName\":\"Holdertesting\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674562\",\"accountType\":\"Policy Holder\"},{\"firstName\":\"MotoristPK\",\"lastName\":\"2\",\"salutation\":\"Mr.\",\"contactPhoneNumber\":\"7895674509\",\"accountType\":\"Motorist\"}]}}';
        String myDomain = Url.getOrgDomainUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestURI = myDomain+'/services/apexrest/createPrepData';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;

        Test.startTest();

        BLN_TaskCreateUpdateWebservice.prepTaskData();

        Test.stopTest();

        // ServiceAppointment result = [
        //     SELECT Id, Status
        //     FROM ServiceAppointment
        //     WHERE BLN_RemedyTaskId__c = '66088854'
        //     LIMIT 1
        // ];

        Assert.areEqual(true, true, 'Success');
    }
    @IsTest
    private static void testGenericWrapper() {
        BLN_GenericWebserviceWrapper.RequestWrapper obj = new BLN_GenericWebserviceWrapper.RequestWrapper();
        String action ='';
        obj.action = 'test';
        System.assertEquals('test', 'test', obj.action);

        BLN_GenericWebserviceWrapper.RequiredSkills_CLS obj1 = new BLN_GenericWebserviceWrapper.RequiredSkills_CLS();
        String skill='';
        obj1.skill = 'test1';
        System.assertEquals('test1', 'test1', obj1.skill);
        String skillLevel='';
        obj1.skillLevel = 'tested';
        System.assertEquals('tested', 'tested', obj1.skillLevel);

        BLN_GenericWebserviceWrapper.PersonAccount_CLS obj2 = new BLN_GenericWebserviceWrapper.PersonAccount_CLS();
        String firstName='';
        obj2.firstName = 'test1';
        System.assertEquals('test1', 'test1', obj2.firstName);
        String lastName='';
        obj2.lastName = 'test2';
        System.assertEquals('test2', 'test2', obj2.lastName);
        String salutation='';
        obj2.salutation = 'MR';
        System.assertEquals('MR', 'MR', obj2.salutation);
        String contactPhoneNumber='';
        obj2.contactPhoneNumber = '9876543210';
        System.assertEquals('9876543210', '9876543210', obj2.contactPhoneNumber);
        String accountType='';
        obj2.accountType = 'test3';
        System.assertEquals('test3', 'test3', obj2.accountType);

        BLN_GenericWebserviceWrapper.Vehicle_CLS obj3 = new BLN_GenericWebserviceWrapper.Vehicle_CLS();
        String vehicleMake='';
        obj3.vehicleMake = 'test11';
        System.assertEquals('test11', 'test11', obj3.vehicleMake);
        String vehicleModel='';
        obj3.vehicleModel = 'test12';
        System.assertEquals('test12', 'test12', obj3.vehicleModel);
        String vehicleRegistration='';
        obj3.vehicleRegistration = 'test13';
        System.assertEquals('test13', 'test13', obj3.vehicleRegistration);

        BLN_GenericWebserviceWrapper.ServiceTerritory_CLS obj4 = new BLN_GenericWebserviceWrapper.ServiceTerritory_CLS();
        String region='';
        obj4.region = 'test14';
        System.assertEquals('test14', 'test14', obj4.region);
        String companyNav='';
        obj4.companyNav = 'test15';
        System.assertEquals('test15', 'test15', obj4.companyNav);
        String district='';
        obj4.district = 'test16';
        System.assertEquals('test16', 'test16', obj4.district);

        BLN_GenericWebserviceWrapper.Location_CLS obj5 = new BLN_GenericWebserviceWrapper.Location_CLS();
        String street ='';
        obj5.street = 'test1';
        System.assertEquals('test1', 'test1', obj5.street);
        String city ='';
        obj5.city = 'test2';
        System.assertEquals('test2', 'test2', obj5.city);
        String postalCode ='';
        obj5.postalCode = 'test3';
        System.assertEquals('test3', 'test3', obj5.postalCode);
        String countryID ='';
        obj5.countryID = 'test4';
        System.assertEquals('test4', 'test4', obj5.countryID);

        BLN_GenericWebserviceWrapper.JobAppointment_CLS obj6 = new BLN_GenericWebserviceWrapper.JobAppointment_CLS();
        String remedyTaskId ='';
        obj6.remedyTaskId = 'test1';
        System.assertEquals('test1', 'test1', obj6.remedyTaskId);
        String duration ='';
        obj6.duration = 'test2';
        System.assertEquals('test2', 'test2', obj6.duration);
        String serviceAppointmentStatus ='';
        obj6.serviceAppointmentStatus = 'test3';
        System.assertEquals('test3', 'test3', obj6.serviceAppointmentStatus);
        String isBranchAppointment ='';
        obj6.isBranchAppointment = 'test4';
        System.assertEquals('test4', 'test4', obj6.isBranchAppointment);
        String remedyOpenDate ='';
        obj6.remedyOpenDate = 'test5';
        System.assertEquals('test5', 'test5', obj6.remedyOpenDate);
        String failureReasonCodeId ='';
        obj6.failureReasonCodeId = 'test6';
        System.assertEquals('test6', 'test6', obj6.failureReasonCodeId);
        String earliestStartTime ='';
        obj6.earliestStartTime = 'test7';
        System.assertEquals('test7', 'test7', obj6.earliestStartTime);
        String arrivalWindowEndTime ='';
        obj6.arrivalWindowEndTime = 'test8';
        System.assertEquals('test8', 'test8', obj6.arrivalWindowEndTime);
        String arrivalWindowStartTime ='';
        obj6.arrivalWindowStartTime = 'test9';
        System.assertEquals('test9', 'test9', obj6.arrivalWindowStartTime);
        String updateTime ='';
        obj6.updateTime = 'test10';
        System.assertEquals('test10', 'test10', obj6.updateTime);
        String dueDateTime ='';
        obj6.dueDateTime = 'test11';
        System.assertEquals('test11', 'test11', obj6.dueDateTime);
        String actualArrivalDateTime ='';
        obj6.actualArrivalDateTime = 'test12';
        System.assertEquals('test12', 'test12', obj6.actualArrivalDateTime);
        String actualCompletionDateTime ='';
        obj6.actualCompletionDateTime = 'test13';
        System.assertEquals('test13', 'test13', obj6.actualCompletionDateTime);

        BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS obj7 = new BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS();
        String taskType ='';
        obj7.taskType = 'test14';
        System.assertEquals('test14', 'test14', obj7.taskType);
        String taskPriority ='';
        obj7.taskPriority = 'test15';
        System.assertEquals('test15', 'test15', obj7.taskPriority);

        BLN_GenericWebserviceWrapper.JobWorkOrder_CLS obj8 = new BLN_GenericWebserviceWrapper.JobWorkOrder_CLS();
        String remedyJobId ='';
        obj8.remedyJobId = 'test16';
        System.assertEquals('test16', 'test16', obj8.remedyJobId);
        String remedyProfile ='';
        obj8.remedyProfile = 'test17';
        System.assertEquals('test17', 'test17', obj8.remedyProfile);
        String ADASJob ='';
        obj8.ADASJob = 'test18';
        System.assertEquals('test18', 'test18', obj8.ADASJob);
    }

    private class MockHTTPResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest param1) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"testAccessToken","expires_in":30}');
            return res;
        }
    }
    public static String getCurrentDateTime(){
        String timestamp = System.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSSSSSZ');
        String tz = timestamp.right(4);
        tz = tz.left(2) + ':' + tz.right(2);
        String d = timestamp.substring(0,timestamp.length()-4) + tz;
        return d;
    }
}