/** @description : The Apex Webservice PrepData class using getAvailbility to create WO, WOLI, SA, Skills, SA dependecy.
*   @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
*   @author: Ayush Singh(PwC IN)
*    @CreatedDate: 31/05/2023
*/

@RestResource(urlMapping='/createPrepData/*')
global class BLN_TaskCreateUpdateWebservice {
    /** @description : The Apex Webservice PrepData class using getAvailbility to create WO, WOLI, SA, Skills, SA dependecy.
*   @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
*   @author: Ayush Singh(PwC IN)
*    @CreatedDate: 31/05/2023
*/
    @HttpPost
    global static void prepTaskData(){   
        List<Exception> exceptionList = new List<Exception>();
        Datetime startTime = System.Now();
        RestRequest req = RestContext.request;
        RestResponse res= RestContext.response;  
        List<String> serializedIntLogList = new List<String>();
        BLN_GenericWebserviceWrapper.RemedyResponseWrapper rt = new BLN_GenericWebserviceWrapper.RemedyResponseWrapper();
        BLN_GenericWebserviceWrapper.RemedyResponseWrapper2 rt2 = new BLN_GenericWebserviceWrapper.RemedyResponseWrapper2();
        BLN_GenericWebserviceWrapper.RemedyResponseWrapper3 rt3 = new BLN_GenericWebserviceWrapper.RemedyResponseWrapper3();
        String requestBody = req.requestBody.toString();
        String getJobAppointment = System.Label.BLN_GetJobAppointment;
        String bookJobAppointment = System.Label.BLN_BookJobAppointment;
        String updateJobAppointment = System.Label.BLN_UpdateJobAppointment;
        String updateJobAppointmentStatus = System.Label.BLN_UpdateJobAppointmentStatus;
        String shortenJobAppointment = System.Label.BLN_ShortenJobAppointment;
        String operationType = '';
        Boolean isCalloutDone = false;
        BLN_GenericWebserviceWrapper.RequestWrapper wrapperObj = new BLN_GenericWebserviceWrapper.RequestWrapper();
        
        wrapperObj = BLN_GenericWebserviceWrapper.parse(requestBody);
        BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder = wrapperObj.workOrder;
        BLN_IntegrationLogger__c integrat = new BLN_IntegrationLogger__c();
        String responseString = '';
        
        try{            
            wrapperObj = BLN_GenericWebserviceWrapper.parse(requestBody);
            //BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder = wrapperObj.workOrder;
            String action = wrapperObj.action;
            operationType = action;
            
            if(String.isEmpty(jobWorkOrder.remedyJobId)){
                
                rt.isSuccess = 'false';
                rt.isError = 'true';
                rt.errorMessage = 'remedyJobId Not Found.';
                rt.WorkOrder_BLN_RemedyJobId = null;
                rt.workOrder_Id = null;
                rt.ServiceAppointment_BLN_RemedyTaskId = null;
                rt.ServiceAppointment_Id = null;
                rt.ServiceAppointment_Status = null;
            }
            else if(String.isEmpty(action)){
                rt.isSuccess = 'false';
                rt.isError = 'true';
                rt.errorMessage = 'Operation Not Found.';
                rt.WorkOrder_BLN_RemedyJobId = null;
                rt.workOrder_Id = null;
                rt.ServiceAppointment_BLN_RemedyTaskId = null;
                rt.ServiceAppointment_Id = null;
                rt.ServiceAppointment_Status = null;
            }
            else if(
                String.isNotEmpty(action)
                && String.isNotEmpty(jobWorkOrder.remedyJobId)
            ){
                
                if(action.equalsIgnoreCase(getJobAppointment)){
                    rt = getAppointment(jobWorkOrder);
                    isCalloutDone = true;
                    
                }
                else if(action.equalsIgnoreCase(bookJobAppointment)){
                    List<WorkOrder> workOrder = BLN_HandlerWebservice.getWOByRemedyJobId(jobWorkOrder.remedyJobId);
                    if(workOrder == null){
                        rt = getAppointment(jobWorkOrder);
                        isCalloutDone = true;
                    }
                    rt = bookAppointment(jobWorkOrder);
                    isCalloutDone = true;
                }
                else if(action.equalsIgnoreCase(updateJobAppointment)){
                    rt2 = taskUpdate(jobWorkOrder);
                    isCalloutDone = true;  
                }
                else if(action.equalsIgnoreCase(updateJobAppointmentStatus)){
                    
                    rt3 = taskUpdateStatus(jobWorkOrder);
                    isCalloutDone = true;
                }
                else if(action.equalsIgnoreCase(shortenJobAppointment)){
                    
                    rt2 = shortening(jobWorkOrder);  
                    isCalloutDone = true;
                }
            }
            
        }
        
        catch(exception ex){
            exceptionList.add(ex);
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 400;
            string jsonResponse = '{"response": {"status": "Failure", "message": "' + ex.getMessage() + ' '+ex.getLineNumber()+'"}}';
            res.responseBody = blob.valueOf(jsonResponse);
            BLN_ExceptionLogger.LogExceptionRequest(exceptionList, requestBody, jobWorkOrder.remedyJobId);
            return;            
        } 
        
        if(!String.isEmpty(operationType) &&  
           (operationType.equalsIgnoreCase(getJobAppointment) || operationType.equalsIgnoreCase(bookJobAppointment))){
               responseString = JSON.serialize(rt);
           }
        else if(!String.isEmpty(operationType) &&  
                (operationType.equalsIgnoreCase(updateJobAppointment) || operationType.equalsIgnoreCase(shortenJobAppointment))){
                    responseString = JSON.serialize(rt2);
                }
        else if(!String.isEmpty(operationType) &&  operationType.equalsIgnoreCase(updateJobAppointmentStatus) ){
            responseString = JSON.serialize(rt3);
        }
        
        
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(responseString);
        res.statusCode = 200;
        
        if(isCalloutDone == true){
            Datetime endTime = System.Now();
            String apiCallDurationInSeconds = BLN_FSLUtility.calculateDiffBetTime(startTime, endTime);
            integrat.BLN_APICallInSeconds__c = BLN_FSLUtility.calculateDiffBetTime(startTime, endTime);
            integrat.BLN_RecordId__c = jobWorkOrder.remedyJobId; // Map to remedyJobId
            integrat.BLN_RequestBody__c = requestBody;
            integrat.BLN_RequestEndPoint__c = 'Prepdata - '+wrapperObj.action;            
            integrat.BLN_RequestIssuedBy__c = UserInfo.getUserId(); 
            integrat.BLN_RequestSent__c = System.Now();
            integrat.BLN_ResponseBody__c = res.responseBody.toString();
            integrat.BLN_ResponseReceived__c = System.Now();
            integrat.BLN_ResponseStatus__c = String.valueof(res.statusCode);
            integrat.BLN_ResponseStatusCode__c = ''+res.statusCode;
            integrat.BLN_TargetSystem__c = System.label.BLN_TargetSystemSalesforce;
            
            String serializedIntegrat = JSON.serialize(integrat);
            serializedIntLogList.add(serializedIntegrat);        
            if (serializedIntLogList.size() > 0) {
                String serializedIntLogListJSON = '[' + String.join(serializedIntLogList, ',') + ']';
                BLN_IntegrationLoggerFuture.processIntegrationLogger(serializedIntLogListJSON);
            }
            
        }
        
        if(exceptionList!= null && !exceptionList.isEmpty()){
            BLN_ExceptionLogger.LogExceptionRequest(exceptionList, requestBody, jobWorkOrder.remedyJobId);
        }
    }
    
    
    /** @description : getAppointment(BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder) method for operation 'GetAvailability'
* @param : BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder
* @return : BLN_GenericWebserviceWrapper.RemedyResponseWrapper
*/
    
    private static BLN_GenericWebserviceWrapper.RemedyResponseWrapper getAppointment(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder){
        Datetime startTime = System.Now();
        String rebookIdentifier = 'TEMP'+startTime.day()+''+startTime.month()+''+startTime.year()+''+startTime.hour()+''+startTime.minute()+''+startTime.second()+'_';
        BLN_GenericWebserviceWrapper.RemedyResponseWrapper response = new BLN_GenericWebserviceWrapper.RemedyResponseWrapper();
        List<WorkOrder> workOrder = BLN_HandlerWebservice.getWOByLikeRemedyJobId(jobWorkOrder.remedyJobId);
        //System.debug('workOrder'+workOrder[0].BLN_RemedyJobId__c);
        //List<WorkOrder> prnt_workOrder = BLN_HandlerWebservice.getWOByRemedyJobId(jobWorkOrder.remedyJobId);
        String status = workOrder!=null ? workOrder[0].status : '';
        response = workOrder!=null ? jobMatching(jobWorkOrder,workOrder[0].BLN_RemedyJobId__c)==true && (status == 'New') ? prepDataForExistingWorkOrder(jobWorkOrder, workOrder[0]): newJobPrepData(jobWorkOrder,rebookIdentifier,workOrder[0]):  newJobPrepData(jobWorkOrder,'',null);
        return response; 
    }
    
    
    /** @description : newJobPrepData(BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder) method for newJobBooking prepdata
* @param : BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder
* @return : BLN_GenericWebserviceWrapper.RemedyResponseWrapper
*/
    
    private static BLN_GenericWebserviceWrapper.RemedyResponseWrapper newJobPrepData(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder, String taskPrefix, WorkOrder parentWorkOrder){
        
        BLN_GenericWebserviceWrapper.RemedyResponseWrapper rt = new BLN_GenericWebserviceWrapper.RemedyResponseWrapper();
        ServiceTerritory terrRecord = new ServiceTerritory();
        List<ServiceAppointment> lstNewAppointments = new List<ServiceAppointment>();
        List<SkillRequirement> skillRequirements = new List<SkillRequirement>();
        List<WorkOrderLineItem> listOfWOLIs = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> lstRemedyWOLI = new List<WorkOrderLineItem>();
        List<sObject> listOfWOAndWOLI = new List<sObject>();
        
        Map<String, String> mapOf_WOLI_remedyTaskTypeAndId = new Map<String, String>();
        Map<String, Boolean> mapOf_WOLIId_And_ForcedApp = new Map<String, Boolean>();
        Map<String, List<BLN_GenericWebserviceWrapper.RequiredSkills_CLS> > mapOfTaskTypeAndRS= new Map<String, List<BLN_GenericWebserviceWrapper.RequiredSkills_CLS> >();        
        Map<String, String> mapTaskTypeAndWorkTypeId = mapTaskTypeAndWorkTypeId(jobWorkOrder);
        Map<String, String> mapOfSkillNameAndId = BLN_FSLUtility.mapOfSkillNameAndId();
        
        Set<Id> setOfSAIds = new Set<Id>();
        Set<String> setOfMainWorkTypes = BLN_HandlerWebservice.getSetOfMainWorkTypes();
        Set<Id> setOfWOLIIds = new Set<Id>();
        
        String primaryAppId = null;
        String primaryAppStatus = null;
        String primaryAppTaskId = null;
        
        WorkOrder wo = buildWorkOrder(jobWorkOrder,taskPrefix);
        
        terrRecord = getPrimaryAppointmentTerritory(jobWorkOrder);
        
        /*
Case newCase = buildCase(jobWorkOrder);
upsert newCase BLN_RemedyJobId__c;
wo.CaseId = newCase.id;
*/      
        
        //adding parent work order and failure history so the new appointment can 
        //have this information when existing work order is cancelled/rebooked
        
        if(parentWorkOrder != null){
            wo.ParentWorkOrderId = BLN_HandlerWebservice.getWOByRemedyJobId(jobWorkOrder.remedyJobId)!=null ? BLN_HandlerWebservice.getWOByRemedyJobId(jobWorkOrder.remedyJobId)[0].Id : null;
            wo.BLN_AppointmentFailureCount__c = parentWorkOrder.BLN_AppointmentFailureCount__c;
            wo.BLN_AppointmentFailureReasonHistory__c = parentWorkOrder.BLN_AppointmentFailureReasonHistory__c;
        }
        listOfWOAndWOLI.add(wo);
        lstRemedyWOLI = buildWOLI(jobWorkOrder, terrRecord, mapTaskTypeAndWorkTypeId, taskPrefix);
        
        for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
            BLN_GenericWebserviceWrapper.JobAppointment_CLS jobApp = oL.serviceAppointment;
            if(!String.isEmpty(oL.taskType) && oL.taskRequiredSkill.size()>0)
                mapOfTaskTypeAndRS.put(oL.taskType, oL.taskRequiredSkill);
        }
        
        if(lstRemedyWOLI!=null && lstRemedyWOLI.size()>0){
            listOfWOAndWOLI.addAll(lstRemedyWOLI);
            if(listOfWOAndWOLI!=null && listOfWOAndWOLI.size()>0)
                insert listOfWOAndWOLI;
            
            for(WorkOrderLineItem wOLI:lstRemedyWOLI){
                if(wOLI.Id!=null)
                    setOfWOLIIds.add(wOLI.Id);
            }
            
            if(setOfWOLIIds!=null && setOfWOLIIds.size()>0){
                listOfWOLIs = BLN_HandlerWebservice.getWorkOrderLineItemById(setOfWOLIIds);
            }
            
            if(listOfWOLIs!=null && listOfWOLIs.size()>0){
                for(WorkOrderLineItem li:listOfWOLIs){
                    if(li.Id!=null){
                        mapOf_WOLI_remedyTaskTypeAndId.put(li.WorkType.Name, li.Id);
                    }                        
                }
            }
        }
        
        for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){  
            BLN_GenericWebserviceWrapper.JobAppointment_CLS jobApp = oL.serviceAppointment;
            if(oL.taskRequiredSkill.size()>0){
                for(BLN_GenericWebserviceWrapper.RequiredSkills_CLS rs:oL.taskRequiredSkill){                    
                    SkillRequirement sr = new SkillRequirement();
                    sr.RelatedRecordId = mapOf_WOLI_remedyTaskTypeAndId.get(oL.taskType);
                    sr.SkillLevel = String.isEmpty(rs.SkillLevel) == false ? Decimal.valueOf(rs.SkillLevel) :null;
                    sr.SkillId= rs.skill !=null ? mapOfSkillNameAndId.get(rs.skill) :null;
                    if(sr.SkillId != null){
                        skillRequirements.add(sr);
                        Decimal nine = 9;
                        if(sr.SkillLevel==nine){
                            mapOf_WOLIId_And_ForcedApp.put( mapOf_WOLI_remedyTaskTypeAndId.get(oL.taskType),true);                                
                        }
                        else{
                            mapOf_WOLIId_And_ForcedApp.put(mapOf_WOLI_remedyTaskTypeAndId.get(oL.taskType),false);                                
                        }
                    }
                }
            }
            else{
                mapOf_WOLIId_And_ForcedApp.put(mapOf_WOLI_remedyTaskTypeAndId.get(oL.taskType),false);
            }
        }
        
        if(skillRequirements!=null && skillRequirements.size()>0){
            insert skillRequirements;
        }
        
        for(ServiceAppointment serviceApp: buildJobAppointment(jobWorkOrder, wo, terrRecord, mapOf_WOLI_remedyTaskTypeAndId, taskPrefix)){
            if(mapOf_WOLIId_And_ForcedApp.containsKey(serviceApp.ParentRecordId)){
                serviceApp.BLN_IsForcedAppointment__c = mapOf_WOLIId_And_ForcedApp.get(serviceApp.ParentRecordId); 
            }
            serviceApp.BLN_IsPrepDataCall__c = true;
            lstNewAppointments.add(serviceApp);
        }
        
        if(lstNewAppointments.size()>0){
            insert lstNewAppointments;
        }  
        
        for(ServiceAppointment servApp : lstNewAppointments){
            if(servApp.Id!=null)
                setOfSAIds.add(servApp.Id); 
        }
        if(setOfSAIds!=null && setOfSAIds.size()>0){
            lstNewAppointments = BLN_HandlerWebservice.getServiceAppointmentByIds(setOfSAIds);
        }
        
        for(ServiceAppointment servApp: lstNewAppointments){
            if(servApp.WorkType.BLN_IsMainJob__c == true){
                primaryAppId = servApp.Id;
                primaryAppStatus = servApp.Status;
                primaryAppTaskId = servApp.BLN_RemedyTaskId__c;
                break;
            }
        }
        
        if(lstNewAppointments!=null && lstNewAppointments.size()>1){
            //create appointment dependencies when there is more than one appointment
            createAppointmentDependencies(primaryAppId,lstNewAppointments);
        }

       
        rt.isSuccess = 'true';
        rt.isError = 'false';
        rt.errorMessage = null;
        rt.WorkOrder_BLN_RemedyJobId = formatId(wo.BLN_RemedyJobId__c);
        rt.workOrder_Id = wo.Id;
        rt.ServiceAppointment_BLN_RemedyTaskId = formatId(primaryAppTaskId);
        rt.ServiceAppointment_Id = primaryAppId;
        rt.ServiceAppointment_Status = primaryAppStatus  == 'None' ? 'Open' : primaryAppStatus;
        return rt; 
        
    }
    
    
    /** @description : existingJobBooking(BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder) method for existingJobBooking prepdata
* @param : BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder
* @return : BLN_GenericWebserviceWrapper.RemedyResponseWrapper
*/    
    
    private static BLN_GenericWebserviceWrapper.RemedyResponseWrapper prepDataForExistingWorkOrder(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder, WorkOrder wo){
        
        BLN_GenericWebserviceWrapper.RemedyResponseWrapper rt = new BLN_GenericWebserviceWrapper.RemedyResponseWrapper();
        BLN_GenericWebserviceWrapper.ServiceTerritory_CLS primaryTerritory ;
        WorkOrder wOrder = new WorkOrder();
        System.debug('existing work order');
        Map<String, Boolean> mapOf_WOLIremedyTaskId_And_ForcedApp = new Map<String, Boolean>();          
        
        List<ServiceAppointment> updateSAList = new List<ServiceAppointment>(); 
        List<SkillRequirement> srList = new List<SkillRequirement>();
        
        Set<String> setOfMainWorkTypes = BLN_HandlerWebservice.getSetOfMainWorkTypes();
        Set<String> setOfDistricts = new Set<String>();
        Set<String> setOfRemedyTaskIds = new Set<String>();
        Set<String> setOfWorkTypes = new Set<String>();
        Set<String> setOfSAWoliIds = new Set<String>();
        
        String schedulingPolicyId = BLN_HandlerWebservice.getSchedulingPolicy(System.Label.BLN_SchedulingPolicyName)[0].Id;        
        String arrivalWindowEnd = '';
        String arrivalWindowStart = '';
        String dueDate = '';
        String openDate = '';
        String primaryAppId = null;
        String primaryAppStatus = null;
        String primaryAppTaskId = null; 
        String primaryTaskType = null;
        
        Boolean updateRemedyJobId = false;            
        
        
        wOrder = wo;
        System.debug('wOrder>>'+wOrder.BLN_RemedyJobId__c);
        
        primaryTerritory = jobWorkOrder.workOrderLineItem[0].serviceAppointment.serviceTerritory;
        primaryTaskType = jobWorkOrder.workOrderLineItem[0].taskType;
        String workTypeId = BLN_HandlerWebservice.getWorkType(primaryTaskType)[0].Id;           
        
        for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
            BLN_GenericWebserviceWrapper.JobAppointment_CLS jobApp = oL.serviceAppointment;
            if(!String.isEmpty(jobApp.serviceTerritory.District))
                setOfDistricts.add(jobApp.serviceTerritory.District);
        }
        
        List<ServiceTerritory> sTList = new List<ServiceTerritory>();
        Map<String,String> mapOfTerrNameAndId = new Map<String,String>();
        Map<String,String> mapOfTerrIdAndOHId = new Map<String,String>();
        if(setOfDistricts!=null){
            sTList = BLN_HandlerWebservice.getDistrictServiceTerritory(setOfDistricts);            
            if(sTList!=null){
                for(ServiceTerritory servTerritory:sTList){
                    mapOfTerrNameAndId.put(servTerritory.Name, servTerritory.Id);
                    mapOfTerrIdAndOHId.put(servTerritory.Id, servTerritory.OperatingHoursId);
                }
            }
        }
        
        //get the id of main service appointment
        ServiceTerritory sT = BLN_HandlerWebservice.getDistrictServiceTerritory(new Set<String>{primaryTerritory.District})[0];
        String serviceTerrId = sT.Id;
        
        //get the operating hour associated with the territory
        String sTOperatingHoursId = sT.OperatingHoursId;
        
        for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
            if(oL.serviceAppointment.remedyTaskId!=null){                     
                setOfRemedyTaskIds.add(oL.serviceAppointment.remedyTaskId);
            }
            if(oL.taskType!=null){                     
                setOfWorkTypes.add(oL.taskType);
            }
        }            
        
        List<ServiceAppointment> getSAList = BLN_HandlerWebservice.getSAByWorkTypeName(wo.BLN_RemedyJobId__c, setOfWorkTypes);
        
        Map<String, Id> mapWOLIANDWorkTypes = new Map<String, Id>();
        if(getSAList!=null){
            Map<String, ServiceAppointment> mapOfremedyTaskTypeAndSA = new Map<String, ServiceAppointment>();
            for(ServiceAppointment sA:getSAList){
                mapOfremedyTaskTypeAndSA.put(sA.WorkType.Name, sA);
                mapWOLIANDWorkTypes.put(sA.WorkType.Name,sa.ParentRecordId);
            }
            
            for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){                    
                BLN_GenericWebserviceWrapper.JobAppointment_CLS jobApp = oL.serviceAppointment;
                ServiceAppointment sARemedyUpdate = new ServiceAppointment();
                ServiceAppointment existingSA = mapOfremedyTaskTypeAndSA.get(ol.taskType);
                sARemedyUpdate.Id = existingSA.Id;
                setOfSAWoliIds.add(existingSA.ParentRecordId);
                //sARemedyUpdate.BLN_RemedyTaskId__c = jobApp.remedyTaskId;
                sARemedyUpdate.ServiceTerritoryId = serviceTerrId;
                sARemedyUpdate.bln_IsBranchAppointment__c = Boolean.valueOf(jobApp.isBranchAppointment);
                sARemedyUpdate.bln_IsMobileAppointment__c = !Boolean.valueOf(jobApp.isBranchAppointment);
                sARemedyUpdate.BLN_RemedyProfile__c = jobWorkOrder.remedyProfile;
                sARemedyUpdate.Street = jobApp.address.street;
                sARemedyUpdate.City = jobApp.address.city;
                sARemedyUpdate.PostalCode = jobApp.address.postalCode;
                sARemedyUpdate.Country = jobApp.address.countryID;
                
                if(oL.taskType!='Stock Collect' && oL.taskType!='Assist'){
                    //arrivalWindowStart = jobApp.arrivalWindowStartTime;
                    arrivalWindowStart = !String.isEmpty(jobApp.arrivalWindowStartTime) ? jobApp.arrivalWindowStartTime: jobApp.earliestStartTime;
                    arrivalWindowEnd = jobApp.arrivalWindowEndTime;
                    dueDate = jobApp.dueDateTime;
                }
                
                if(oL.taskType=='Stock Collect' && String.isEmpty(jobApp.earliestStartTime)){
                    Datetime aptDateTime = BLN_FSLUtility.changeStrToDateTime(arrivalWindowStart);
                    Date apptDate = date.newinstance(aptDateTime.year(), aptDateTime.month(), aptDateTime.day());
                    sARemedyUpdate.EarliestStartTime = Datetime.newInstance(apptDate,Time.newInstance(6,0,0,0));
                    sARemedyUpdate.ArrivalWindowStartTime = sARemedyUpdate.EarliestStartTime;
                    sARemedyUpdate.ArrivalWindowEndTime = !String.isEmpty(jobApp.arrivalWindowEndTime)==true ? BLN_FSLUtility.changeStrToDateTime(jobApp.arrivalWindowEndTime) : BLN_FSLUtility.changeStrToDateTime(dueDate);
                    
                    
                }  else if(oL.taskType=='Stock Collect' && !String.isEmpty(jobApp.earliestStartTime)){
                    sARemedyUpdate.EarliestStartTime = BLN_FSLUtility.changeStrToDateTime(jobApp.earliestStartTime);
                    sARemedyUpdate.ArrivalWindowEndTime = String.valueof(jobApp.arrivalWindowEndTime)<>'' ? BLN_FSLUtility.changeStrToDateTime(jobApp.arrivalWindowEndTime) : BLN_FSLUtility.changeStrToDateTime(dueDate) ;
                    
                    Datetime scEearlistStartTime = sARemedyUpdate.EarliestStartTime;
                    Date scEarStartDate = date.newinstance(scEearlistStartTime.year(), scEearlistStartTime.month(), scEearlistStartTime.day());
                    
                    Datetime aptDateTime = BLN_FSLUtility.changeStrToDateTime(arrivalWindowStart);
                    Date apptDate = date.newinstance(aptDateTime.year(), aptDateTime.month(), aptDateTime.day());
                    if(scEarStartDate<apptDate){
                        sARemedyUpdate.ArrivalWindowStartTime = Datetime.newInstance(apptDate,Time.newInstance(6,0,0,0));
                    } else{
                        sARemedyUpdate.ArrivalWindowStartTime = sARemedyUpdate.EarliestStartTime;
                    }
                } else{
                    sARemedyUpdate.EarliestStartTime = !String.isEmpty(jobApp.earliestStartTime) == true ? BLN_FSLUtility.changeStrToDateTime(jobApp.earliestStartTime) : BLN_FSLUtility.changeStrToDateTime(arrivalWindowStart) ;
                    sARemedyUpdate.ArrivalWindowStartTime = String.valueof(jobApp.arrivalWindowStartTime)<>''? BLN_FSLUtility.changeStrToDateTime(jobApp.arrivalWindowStartTime) : BLN_FSLUtility.changeStrToDateTime(arrivalWindowStart) ;
                    sARemedyUpdate.ArrivalWindowEndTime = String.valueof(jobApp.arrivalWindowEndTime)<>'' ? BLN_FSLUtility.changeStrToDateTime(jobApp.arrivalWindowEndTime) : BLN_FSLUtility.changeStrToDateTime(arrivalWindowEnd) ;
                }

                    sARemedyUpdate.DueDate = !String.isEmpty(jobApp.dueDateTime)==true ? BLN_FSLUtility.changeStrToDateTime(jobApp.dueDateTime) :BLN_FSLUtility.changeStrToDateTime(dueDate);
               
                
                
                if(setOfMainWorkTypes.contains(oL.taskType)){
                    primaryAppId = existingSA.Id;
                    primaryAppTaskId = jobApp.remedyTaskId;
                    primaryAppStatus = existingSA.Status;                  
                }
                sARemedyUpdate.Status = primaryAppStatus;
                updateSAList.add(sARemedyUpdate);
            }
        }
        if(setOfSAWoliIds.size()>0){
            srList = BLN_HandlerWebservice.getSkillReq(setOfSAWoliIds);
        }
        
        Map<String, List<SkillRequirement>> mapOfWOLIIdAndSR = new Map<String, List<SkillRequirement>>();
        Map<String, List<SkillRequirement>> mapOfremedyTaskIdAndSR = new Map<String, List<SkillRequirement>>();
        List<WorkOrderLineItem> updatedWOLIs = new List<WorkOrderLineItem>();
        Set<Id> setOfRelRecIds = new Set<Id>();
        
        if (srList != null) {
            for (SkillRequirement sr : srList) {
                if (sr.RelatedRecordId != null && sr.Id != null) {
                    if (!mapOfWOLIIdAndSR.containsKey(sr.RelatedRecordId)) {
                        mapOfWOLIIdAndSR.put(sr.RelatedRecordId, new List<SkillRequirement>());
                    }
                    mapOfWOLIIdAndSR.get(sr.RelatedRecordId).add(sr);
                    setOfRelRecIds.add(sr.RelatedRecordId);
                }
            }
        }
        for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){  
            BLN_GenericWebserviceWrapper.JobAppointment_CLS jobApp = oL.serviceAppointment;
            WorkOrderLineItem updatedWOLI = new WorkOrderLineItem();
            updatedWOLI.Id = mapWOLIANDWorkTypes.get(oL.tasktype);
            //updatedWOLI.BLN_RemedyTaskId__c = jobApp.remedyTaskId;
            updatedWOLI.ServiceTerritoryId = serviceTerrId;
            updatedWOLI.Street = jobApp.address.street;
            updatedWOLI.City = jobApp.address.city;
            updatedWOLI.PostalCode = jobApp.address.postalCode;
            updatedWOLI.Country = jobApp.address.countryID;
            
            updatedWOLIs.add(updatedWOLI);
        }
        if(updatedWOLIs.size()>0){
            update updatedWOLIs;
        }            
        List<WorkOrderLineItem> updatedWOLIList = BLN_HandlerWebservice.getWorkOrderLineItemById(setOfRelRecIds);
        if(mapOfWOLIIdAndSR!=null && updatedWOLIList!=null){
            for(WorkOrderLineItem srWoli:updatedWOLIList){
                if(srWoli.Id!=null && srWoli.BLN_remedyTaskId__c!=null){
                    mapOfremedyTaskIdAndSR.put(srWoli.BLN_remedyTaskId__c, mapOfWOLIIdAndSR.get(srWoli.Id));
                }
            }
        }
        
        List<SkillRequirement> updateListSkillRequirements = new List<SkillRequirement>();            
        for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
            BLN_GenericWebserviceWrapper.JobAppointment_CLS jobApp = oL.serviceAppointment; 
            String workOrderLineItemID = mapWOLIANDWorkTypes.get(oL.tasktype);
            
            //Below code checks the new skill requirements against the existing WOLI Skill Requirements
            //and when match found, updates the skill level
            //this also updates appointment as forced appointment where skills level changed to 9 
            if(oL.taskRequiredSkill.size()>0){                    
                for(BLN_GenericWebserviceWrapper.RequiredSkills_CLS rs:oL.taskRequiredSkill){
                    for(SkillRequirement existSkillReq: srList){                            
                        if(existSkillReq.Skill.MasterLabel == rs.skill && existSkillReq.RelatedRecordId==workOrderLineItemID){// && existSkillReq.RelatedRecordId == rs.RelatedRecordId){
                            existSkillReq.SkillLevel = Decimal.valueOf(rs.skilllevel)<>null?Decimal.valueOf(rs.skilllevel):null;
                            if(Decimal.valueOf(rs.skilllevel)==9){
                                mapOf_WOLIremedyTaskId_And_ForcedApp.put(jobApp.remedyTaskId, true);  
                            } else{
                                mapOf_WOLIremedyTaskId_And_ForcedApp.put(jobApp.remedyTaskId, false);  
                            }
                            updateListSkillRequirements.add(existSkillReq) ;                    
                        }                                                     
                    }                        
                }                    
            }else{
                mapOf_WOLIremedyTaskId_And_ForcedApp.put(jobApp.remedyTaskId, false); 
            }
        }
        if(updateListSkillRequirements.size()>0){
            update updateListSkillRequirements;
        }
        for(ServiceAppointment sA:updateSAList){
            sA.BLN_IsForcedAppointment__c = mapOf_WOLIremedyTaskId_And_ForcedApp.get(sA.BLN_RemedyTaskId__c) <> null? mapOf_WOLIremedyTaskId_And_ForcedApp.get(sA.BLN_RemedyTaskId__c):false;
        }
        if(updateSAList!=null && updateSAList.size()>0){
            update updateSAList;
        }
        
        
        rt.isSuccess = 'true';
        rt.isError = 'false';
        rt.errorMessage = null;
        rt.WorkOrder_BLN_RemedyJobId = formatId(wOrder.BLN_RemedyJobId__c);//wOrder.BLN_RemedyJobId__c.contains('REB')?wOrder.BLN_RemedyJobId__c.right(wOrder.BLN_RemedyJobId__c.length()-4):wOrder.BLN_RemedyJobId__c;
        rt.workOrder_Id = wOrder.Id;        
        rt.ServiceAppointment_BLN_RemedyTaskId =formatId(primaryAppTaskId);//primaryAppTaskId.contains('REB')?primaryAppTaskId.right(primaryAppTaskId.length()-4):primaryAppTaskId;
        rt.ServiceAppointment_Id = primaryAppId;
        //We need to translate the 'None' status to 'Open' as Mulesoft ignores None - 
        //Since none is api name and we can't change that to we are modifying this during response
        rt.ServiceAppointment_Status = primaryAppStatus == 'None' ? 'Open' : primaryAppStatus;
        
        return rt; 
    }
    
    
    /** @description : bookAppointment(BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder) method for operation 'BookAppointment'
* @param : BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder
* @return : BLN_GenericWebserviceWrapper.ResponseWrapper
*/
    private static BLN_GenericWebserviceWrapper.RemedyResponseWrapper bookAppointment(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder){
        String workOrderId = null;
        String wORemedyJobId = null;
        String wOCaseId = null;
        String vehicleId = null;
        String makeOfVehicle = null;
        String modelOfVehicle = null;
        String mainSAId = null;
        String mainSATaskId = null;
        String mainSAStatus = null;
        String arrivalWindowStart = '';
        String arrivalWindowEnd = '';
        String rbkStockCollectId = null;
        String rbkAssistId = null;
        String rbkPrimaryAppId = null;
        String dueDate = '';
        String vrnInformation = null;
        String schedulingPolicyId = BLN_HandlerWebservice.getSchedulingPolicy(System.Label.BLN_SchedulingPolicyName)[0].Id;
        Set<String> setOfMainWorkTypes = BLN_HandlerWebservice.getSetOfMainWorkTypes();
        List<WorkOrder> workOrder = BLN_HandlerWebservice.getWOByLikeRemedyJobId(jobWorkOrder.remedyJobId);
        ServiceTerritory serviceTerritory = BLN_QueryHandlerWebservice.getServiceTerritoryByName(jobWorkOrder.workOrderLineItem.get(0).serviceAppointment.serviceTerritory.District);
        Map<String, Boolean> mapOf_WOLIremedyTaskId_And_ForcedApp = new Map<String, Boolean>();          
        List<SkillRequirement> srList = new List<SkillRequirement>();
        Set<String> setOfSAWoliIds = new Set<String>();
        Datetime startTime = System.Now();
        String rebookIdentifier = 'RBK'+startTime.day()+''+startTime.month()+''+startTime.year()+''+startTime.hour()+''+startTime.minute()+''+startTime.second()+'_';
                
        
        String stockCollectWT = System.Label.BLN_StockCollectWT;
        String assistWT = System.Label.BLN_AssistWT;
        
        try {
        Case newCase = buildCase(jobWorkOrder);
        upsert newCase BLN_RemedyJobId__c;
        String caseId = newCase.Id; 
        
        if(workOrder !=null){
            workOrderId = workOrder[0].Id;
            wORemedyJobId = WorkOrder[0].BLN_RemedyJobId__c;
            
            List<Account> personAccounts = new List<Account>();
            Set<String> setOfRemedyTaskIds = new Set<String>();
            Set<String> setOfRemedyTaskTypes = new Set<String>();
List<ServiceAppointment> updateSAList= new List<ServiceAppointment>();
            Map<String, ServiceAppointment> mapOfremedyTaskTypeAndSA = new Map<String, ServiceAppointment>();
            Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Set<id> setOfPersonAccIds = new Set<id>();
            Boolean isRebook = false;
            String policyHolderRecName = System.Label.BLN_PolicyHolder;
            String motoristRecName = System.Label.BLN_Motorist;
            String insertedPolicyHolderId = null;
            String insertedMotoristId = null;
            String phFirstName = '';
            String phLastName = '';
            String phAccountType='';
            String motoristFirstName = '';
            String motoristLastName = '';
            String motoristAccountType='';
            String phMatchString = '';
            String mtMatchString = '';
            Set<String> noOfAccountSet = new Set<string>();
            Map<String,String> accTypeMapping = new Map<String,String>();
            Account personAcc;
            Boolean multiAccountBool = false;  
            Boolean caseUpdatedBool = false;
            Boolean caseContactRoleBool = false;
            Boolean skipMotoristAccountBool = false;
            List<Case> caselist = BLN_HandlerWebservice.getCaseRecordById(caseId);
            List<Account> fetchAccountLst = new List<Account>();
            List<Account> policyHolder = new List<Account>();
            List<Account> motoristPA = new List<Account>();
            Id policyHolderId;
            Id motoristId;
            Id motoristAccountId;
            caseContactRole caseContRole;
            List<Account> insertedAccountLst;
            
            
            for(BLN_GenericWebserviceWrapper.PersonAccount_CLS pA:jobWorkOrder.personAccount){
                String fNStr = pA.firstName.length()>0?pA.firstName.length()>40?pA.firstName.subString(0,40):pA.firstName:pA.firstName;
                String lNStr = pA.lastName.length()>0?pA.lastName.length()>80?pA.lastName.subString(0,80):pA.lastName:'.'; 
                
                List<Account> dupAccList = new List<Account>(BLN_HandlerWebservice.getPersonAccountByName(pA.Salutation, fNStr, lNStr, pA.ContactPhoneNumber));
                if(dupAccList != null){
                    if(dupAccList.size()>0){
                        if(pA.accountType == policyHolderRecName){
                            policyHolderId = dupAccList[0].Id;
                            caselist[0].AccountId = dupAccList[0].Id;
                            caselist[0].ContactId = dupAccList[0].PersonContactId;
                        }
                        else {
                            motoristAccountId = dupAccList[0].Id; 
                            motoristId = dupAccList[0].personContactId;
                        }
                    }
                }
            }
            
            //When Policy holder and Motorist are same person, set this flag to skip
            //Motorist creation
            if(policyHolderId == motoristAccountId){
                skipMotoristAccountBool = true;    
            }
            
            for(BLN_GenericWebserviceWrapper.PersonAccount_CLS pA:jobWorkOrder.personAccount){                
                if(pA.accountType == policyHolderRecName && policyHolderId == NULL){
                    
                    personAcc = new Account();
                    personAcc.RecordTypeId = personAccRecTypeId;
                    personAcc.FirstName = pA.firstName.length()>0?pA.firstName.length()>40?pA.firstName.subString(0,40):pA.firstName:pA.firstName;
                    personAcc.LastName = pA.lastName.length()>0?pA.lastName.length()>80?pA.lastName.subString(0,80):pA.lastName:'.';    
                    personAcc.Salutation = pA.salutation;  
                    personAcc.PersonMobilePhone = pA.ContactPhoneNumber;  
                    //FOUK-12889
                    personAcc.BLN_IsLegacySystemAccount__c = true;
                    personAccounts.add(personAcc);
                    
                    phMatchString = personAcc.Salutation+''+personAcc.FirstName+''+personAcc.LastName+''+personAcc.PersonMobilePhone;
                    phFirstName = personAcc.FirstName;
                    phLastName = personAcc.LastName;
                    phAccountType = pA.accountType;
                    noOfAccountSet.add(phMatchString);
                    accTypeMapping.put(pA.accountType,phMatchString);
                }
                
                if(pA.accountType == motoristRecName && motoristId == Null){
                    personAcc = new Account();
                    personAcc.RecordTypeId = personAccRecTypeId;
                    personAcc.FirstName = pA.firstName.length()>0?pA.firstName.length()>40?pA.firstName.subString(0,40):pA.firstName:pA.firstName;
                    personAcc.LastName = pA.lastName.length()>0?pA.lastName.length()>80?pA.lastName.subString(0,80):pA.lastName:'.';    
                    personAcc.Salutation = pA.salutation;  
                    personAcc.PersonMobilePhone = pA.ContactPhoneNumber; 
                    //FOUK-12889
                    personAcc.BLN_IsLegacySystemAccount__c = true; 
                    personAccounts.add(personAcc);
                    
                    mtMatchString = personAcc.Salutation+''+personAcc.FirstName+''+personAcc.LastName+''+personAcc.PersonMobilePhone;
                    motoristFirstName = personAcc.FirstName;
                    motoristLastName = personAcc.LastName;
                    motoristAccountType = pA.accountType;
                    noOfAccountSet.add(mtMatchString);
                    accTypeMapping.put(pA.accountType,mtMatchString);
                }                               
                
            }
            
            if(noOfAccountSet.size()>1){
                if(personAccounts.size()>0){
                    insert personAccounts;
                    multiAccountBool = true;
                }
            }
            else{
                if(personAcc != NULL){
                    insert personAcc;
                }
            }
            
            if(personAccounts.size()>0 && multiAccountBool){
                for(Account pAcc: personAccounts){                
                    setOfPersonAccIds.add(pAcc.id);
                    
                }                
            }
            if(setOfPersonAccIds.size()>0){
                insertedAccountLst = BLN_HandlerWebservice.getAccountByIdAndType(setOfPersonAccIds);
            }
            if(multiAccountBool && accTypeMapping.size()>0 && insertedAccountLst.size()>0){  
                for(String str : accTypeMapping.keySet()){//policy
                    for(Account acc : insertedAccountLst){//policy
                        String sal = acc.Salutation!=null ? acc.Salutation : ''; 
                        String fname = acc.FirstName!=null ? acc.FirstName : ''; 
                        String lname = acc.LastName!=null ? acc.LastName : ''; 
                        String phone = acc.PersonMobilePhone!=null ? acc.PersonMobilePhone : ''; 
                        String matchingStr = sal + fname + lname + phone;
                        //if(str.equalsIgnoreCase(policyHolderRecName) && accTypeMapping.get(str).equalsIgnoreCase(acc.Salutation+''+acc.FirstName+''+acc.LastName+''+acc.Phone)){
                        if(str.equalsIgnoreCase(policyHolderRecName) && accTypeMapping.get(str).equalsIgnoreCase(matchingStr)){
                            caselist[0].AccountId = acc.Id;
                            caselist[0].ContactId = acc.PersonContactId;
                            policyHolderId = acc.Id;
                        }
                        //if(str.equalsIgnoreCase(motoristRecName) && accTypeMapping.get(str).equalsIgnoreCase(acc.Salutation+''+acc.FirstName+''+acc.LastName+''+acc.Phone)){  
                        else if(str.equalsIgnoreCase(motoristRecName) && accTypeMapping.get(str).equalsIgnoreCase(matchingStr)){  
                            caseContRole = new CaseContactRole();
                            caseContRole.CasesId=caseId;
                            caseContRole.ContactId=acc.personContactId;
                            caseContRole.Role='Motorist';                            
                        }
                    }
                }
            }
            else if(personAcc != NULL){
                caselist[0].AccountId = personAcc.Id;
                policyHolderId = personAcc.Id;
            }
            
            //For existing policyholder Account
            if(policyHolderId != NULL){
                caselist[0].AccountId = policyHolderId;
            }
            
            update caselist;
            
            //For existing CaseContactRole Account
            if(motoristId != NULL && !skipMotoristAccountBool){
                List<CaseContactRole> exCaseConRole = new List<CaseContactRole>(BLN_HandlerWebservice.getCCRByCaseIdAndConId(caseId, motoristId));
                caseContRole = new CaseContactRole();
                caseContRole.CasesId=caseId;
                caseContRole.ContactId=motoristId;
                caseContRole.Role='Motorist';
                if(exCaseConRole!=Null){
                    if(exCaseConRole.size()>0){
                        caseContRole.Id = exCaseConRole[0].Id;
                        update caseContRole;
                        caseContactRoleBool = true;
                    }  
                }
                
            }
            if(!caseContactRoleBool && caseContRole != NULL){
                insert caseContRole;
            }
            
            //When only motorist was sent from remedy 
            //and not policy holder and in this case motorist becomes the policy holder
            if(motoristId != Null && policyHolderId == Null){
                List<Account> ph = BLN_HandlerWebservice.getAccountByPersonConId(new Set<Id>{motoristId});
                policyHolderId = ph[0].Id;
            }
            
            
            WorkOrder wo = workOrder[0];
            wo.AccountId = policyHolderId; 
            wo.CaseId = caseId;
            wo.BLN_RemedyJobId__c = jobWorkOrder.RemedyJobId;
            
            List<WorkOrderLineItem> lstWOLIsToUpdate = new List<WorkOrderLineItem>();
            
            if(WorkOrder[0].ParentWorkOrderId != null){
                String remedyJobId = rebookIdentifier+jobWorkOrder.RemedyJobId.right(5)+'_'+String.valueof(WorkOrder[0].ParentWorkOrderId).right(4);
                isRebook = true;
                WorkOrder parentWO = New WorkOrder();
                parentWo.Id = WorkOrder[0].ParentWorkOrderId;
                parentWo.BLN_RemedyJobId__c = remedyJobId;
                parentWO.Status = 'Canceled';
                update parentWo;
                Set<String> endStatus = new Set<String>{'Failed After Arrive', 'Failed Before Arrive', 'Completed', 'Canceled', 'Cannot Complete'};
                    List<WorkOrderLineItem> lstWOLIs = [SELECT Id, BLN_RemedyTaskId__c, BLN_RemedyJobID__c,Status 
                                                        FROM WorkOrderLineItem
                                                        WHERE WorkOrderId = :WorkOrder[0].ParentWorkOrderId];
                if(lstWOLIs.size()>0){
                    for (WorkOrderLineItem woli :lstWOLIs ){
                        //String newTaskId = 'CNCL__'+woli.BLN_RemedyTaskId__c;
                        String newTaskId = rebookIdentifier+woli.BLN_RemedyTaskId__c+'_'+String.valueof(WorkOrder[0].ParentWorkOrderId).right(4);
                        woli.BLN_RemedyJobId__c = remedyJobId;
                        woli.BLN_RemedyTaskId__c = (newTaskId!= null && newTaskId.length()>80)? newTaskId.subString(0,80): newTaskId;
                        woli.Status = !endStatus.contains(woli.Status) ?'Canceled':woli.Status;
                        lstWOLIsToUpdate.add(woli);
                    }
                    if(lstWOLIsToUpdate.size()>0){
                        update lstWOLIsToUpdate;
                    }
                }
                List<ServiceAppointment> lstApps = [SELECT Id, BLN_RemedyTaskId__c, BLN_RemedyJobID__c,Status, WorkType.Name, BLN_RebookedServiceAppointment__c
                    FROM ServiceAppointment
                    WHERE BLN_WorkOrderNumber__c = :WorkOrder[0].ParentWorkOrderId];
                if(lstApps.size()>0){
                    List<ServiceAppointment> lstAppsToUpdate = new List<ServiceAppointment>();
                    for (ServiceAppointment app :lstApps ){
                        //String newTaskId = 'CNCL__'+app.BLN_RemedyTaskId__c;
                        String newTaskId = rebookIdentifier+app.BLN_RemedyTaskId__c+'_'+String.valueof(WorkOrder[0].ParentWorkOrderId).right(4);
                        app.BLN_RemedyJobId__c = remedyJobId;
                        app.BLN_RemedyTaskId__c = (newTaskId!= null && newTaskId.length()>80)? newTaskId.subString(0,80): newTaskId;
                        app.Status = !endStatus.contains(app.Status) ?'Canceled':app.Status;
                        app.FSL__Pinned__c = false;
                        app.BLN_IsBookingFailed__c = false;
                        rbkStockCollectId = app.WorkType.Name == 'Stock Collect'?app.id:rbkStockCollectId;
                        rbkAssistId = app.WorkType.Name == 'Assist'?app.id:rbkAssistId;
                        rbkPrimaryAppId = app.WorkType.Name != 'Stock Collect' && app.WorkType.Name != 'Assist'?app.id:rbkPrimaryAppId;
                        updateSAList.add(app);
                    }
                }
                
            }
            
            wo.ParentWorkOrderId = null;
            
            
            if(jobWorkOrder.vehicle!=null){
                List<BLN_Vehicle__c> vehicle = BLN_HandlerWebservice.getVehicleByRegNum(jobWorkOrder.vehicle.vehicleRegistration);
                if(vehicle!=null){
                    vehicleId = vehicle[0].Id;
                    makeOfVehicle = vehicle[0].BLN_MakeOfVehicle__c;
                    modelOfVehicle = vehicle[0].BLN_ModelOfVehicle__c;
                    vrnInformation = vehicle[0].BLN_VehicleRegNumber__c;
                }
                else{
                    BLN_Vehicle__c vH = new BLN_Vehicle__c();
                    vH.BLN_MakeOfVehicle__c = jobWorkOrder.vehicle.vehicleMake;
                    vH.BLN_ModelOfVehicle__c = jobWorkOrder.vehicle.vehicleModel;
                    vH.BLN_VehicleRegNumber__c = jobWorkOrder.vehicle.vehicleRegistration;
                    insert vH;
                    vehicleId = vH.Id;
                    makeOfVehicle = vH.BLN_MakeOfVehicle__c;
                    modelOfVehicle = vH.BLN_ModelOfVehicle__c;  
                    vrnInformation = vH.BLN_VehicleRegNumber__c;
                }
            }            
            
            for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
                if(oL.taskType!=null){
                    setOfRemedyTaskTypes.add(oL.taskType);                  
                }
            }
            
            List<ServiceAppointment> getSAList = BLN_HandlerWebservice.getSAByWorkTypeName(wORemedyJobId,setOfRemedyTaskTypes);
            Map<String, Id> mapWOLIANDWorkTypes = new Map<String, Id>();
        
            if(getSAList!=null && getSAList.size()>0){                
                for(ServiceAppointment sA:getSAList){
                    mapOfremedyTaskTypeAndSA.put(sA.WorkType.Name, sA);
                    mapWOLIANDWorkTypes.put(sA.WorkType.Name,sa.ParentRecordId);
                }                
                for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){                    
                    BLN_GenericWebserviceWrapper.JobAppointment_CLS jobApp = oL.serviceAppointment;
                    ServiceAppointment existingSA = mapOfremedyTaskTypeAndSA.get(oL.taskType);
                    ServiceAppointment sARemedyUpdate = new ServiceAppointment();
                    
                    WorkOrderLineItem woli = new WorkOrderLineItem();
                    woli.BLN_RemedyJobId__c = jobWorkOrder.remedyJobId;
                    woli.BLN_RemedyTaskId__c = jobApp.remedyTaskId;
                    woli.Id = existingSA.ParentRecordId;
                    setOfSAWoliIds.add(existingSA.ParentRecordId);
                
                    sARemedyUpdate.Id = existingSA.Id;
                    sARemedyUpdate.BLN_RemedyTaskId__c = jobApp.remedyTaskId;
                    sARemedyUpdate.BLN_RemedyJobId__c = jobWorkOrder.remedyJobId;
                    sARemedyUpdate.BLN_AppointmentRebook__c = isRebook;
                    sARemedyUpdate.BLN_IsPrepDataCall__c = false;
                    sARemedyUpdate.BLN_IsBookingFailed__c = false;
                    ////Setting the lookup to the rebooked appointment when appointments are rescheduled.
                    sARemedyUpdate.BLN_RebookedServiceAppointment__c = oL.taskType == 'Stock Collect' ? rbkStockCollectId : oL.taskType == 'Assist'? rbkAssistId : rbkPrimaryAppId;
                    
                    if(oL.taskType!=stockCollectWT && oL.taskType!=assistWT){
                        //arrivalWindowStart = jobApp.arrivalWindowStartTime;
                        arrivalWindowStart = !String.isEmpty(jobApp.arrivalWindowStartTime) ? jobApp.arrivalWindowStartTime: jobApp.earliestStartTime;
                        arrivalWindowEnd = jobApp.arrivalWindowEndTime;
                        dueDate = jobApp.dueDateTime;
                    }
                    
                    if(setOfMainWorkTypes.contains(oL.taskType)){
                        mainSAId = existingSA.Id;
                        mainSATaskId = jobApp.remedyTaskId;
                        mainSAStatus = existingSA.Status;
                    }
                    
                    if(oL.taskType=='Stock Collect' && String.isEmpty(jobApp.earliestStartTime)){
                        Datetime aptDateTime = BLN_FSLUtility.changeStrToDateTime(arrivalWindowStart);
                        Date apptDate = date.newinstance(aptDateTime.year(), aptDateTime.month(), aptDateTime.day());
                        sARemedyUpdate.EarliestStartTime = Datetime.newInstance(apptDate,Time.newInstance(6,0,0,0));
                        sARemedyUpdate.ArrivalWindowStartTime = sARemedyUpdate.EarliestStartTime;
                        
                    }  else if(oL.taskType=='Stock Collect' && !String.isEmpty(jobApp.earliestStartTime)){
                        sARemedyUpdate.EarliestStartTime = BLN_FSLUtility.changeStrToDateTime(jobApp.earliestStartTime);
                        Datetime scEearlistStartTime = sARemedyUpdate.EarliestStartTime;
                        Date scEarStartDate = date.newinstance(scEearlistStartTime.year(), scEearlistStartTime.month(), scEearlistStartTime.day());
                        
                        Datetime aptDateTime = BLN_FSLUtility.changeStrToDateTime(arrivalWindowStart);
                        Date apptDate = date.newinstance(aptDateTime.year(), aptDateTime.month(), aptDateTime.day());
                        if(scEarStartDate<apptDate){
                            sARemedyUpdate.ArrivalWindowStartTime = Datetime.newInstance(apptDate,Time.newInstance(6,0,0,0));
                        } else{
                            sARemedyUpdate.ArrivalWindowStartTime = sARemedyUpdate.EarliestStartTime;
                        }
                    } else{
                        
                        sARemedyUpdate.ArrivalWindowStartTime = !String.isEmpty(jobApp.arrivalWindowStartTime) == true ? BLN_FSLUtility.changeStrToDateTime(jobApp.arrivalWindowStartTime): BLN_FSLUtility.changeStrToDateTime(arrivalWindowStart);
                        sARemedyUpdate.EarliestStartTime = !String.isEmpty(jobApp.earliestStartTime) == true ? BLN_FSLUtility.changeStrToDateTime(jobApp.earliestStartTime) : sARemedyUpdate.ArrivalWindowStartTime ;
                    }
                    
                    if(oL.taskType=='Stock Collect'){
                        sARemedyUpdate.DueDate = BLN_FSLUtility.changeStrToDateTime(dueDate);
                        sARemedyUpdate.ArrivalWindowEndTime = BLN_FSLUtility.changeStrToDateTime(dueDate);
                    } else if(Boolean.valueOf(jobApp.isBranchAppointment) == true && jobWorkOrder.remedyProfile != label.BLN_FullDaySlots){
                        sARemedyUpdate.ArrivalWindowEndTime = sARemedyUpdate.ArrivalWindowStartTime.addMinutes(30);
                        sARemedyUpdate.DueDate = prepareDueDateWithBuffer(sARemedyUpdate.ArrivalWindowEndTime, serviceTerritory.BLN_TerritoryBuffer__c, Integer.valueOf(jobApp.duration));
                    } else{
                        sARemedyUpdate.ArrivalWindowEndTime = !String.isEmpty(jobApp.ArrivalWindowEndTime) ==true ? BLN_FSLUtility.changeStrToDateTime(jobApp.ArrivalWindowEndTime):BLN_FSLUtility.changeStrToDateTime(arrivalWindowEnd);
                        sARemedyUpdate.DueDate = !String.isEmpty(jobApp.dueDateTime)==true ? BLN_FSLUtility.changeStrToDateTime(jobApp.dueDateTime): BLN_FSLUtility.changeStrToDateTime(dueDate);
                    }
                    
                    if(existingSA.BLN_AppointmentCreatedFromRemedy__c){
                        sARemedyUpdate.BLN_AppointmentCreatedFromRemedy__c = false;
                    }else{
                        sARemedyUpdate.BLN_AppointmentRebook__c = true;
                    }
                    
                    if(vehicleId!=null){
                        sARemedyUpdate.BLN_Vehicle__c = vehicleId;
                        sARemedyUpdate.BLN_MakeOfVehicle__c =  makeOfVehicle;
                        sARemedyUpdate.BLN_ModelOfVehicle__c = modelOfVehicle;
                        sARemedyUpdate.BLN_VRNInformation__c = vrnInformation;
                    }
                    
                    updateSAList.add(sARemedyUpdate);
                    lstWOLIsToUpdate.add(woli);
                } //end of for loop
                
                if(setOfSAWoliIds.size()>0){
                    srList = BLN_HandlerWebservice.getSkillReq(setOfSAWoliIds);
                }
                
                Map<String, List<SkillRequirement>> mapOfWOLIIdAndSR = new Map<String, List<SkillRequirement>>();
                Map<String, List<SkillRequirement>> mapOfremedyTaskIdAndSR = new Map<String, List<SkillRequirement>>();
                List<WorkOrderLineItem> updatedWOLIs = new List<WorkOrderLineItem>();
                Set<Id> setOfRelRecIds = new Set<Id>();
                
                if (srList != null) {
                    for (SkillRequirement sr : srList) {
                        if (sr.RelatedRecordId != null && sr.Id != null) {
                            if (!mapOfWOLIIdAndSR.containsKey(sr.RelatedRecordId)) {
                                mapOfWOLIIdAndSR.put(sr.RelatedRecordId, new List<SkillRequirement>());
                            }
                            mapOfWOLIIdAndSR.get(sr.RelatedRecordId).add(sr);
                            setOfRelRecIds.add(sr.RelatedRecordId);
                        }
                    }
                }
                List<WorkOrderLineItem> updatedWOLIList = BLN_HandlerWebservice.getWorkOrderLineItemById(setOfRelRecIds);
                if(mapOfWOLIIdAndSR!=null && updatedWOLIList!=null){
                    for(WorkOrderLineItem srWoli:updatedWOLIList){
                        if(srWoli.Id!=null && srWoli.BLN_remedyTaskId__c!=null){
                            mapOfremedyTaskIdAndSR.put(srWoli.BLN_remedyTaskId__c, mapOfWOLIIdAndSR.get(srWoli.Id));
                        }
                    }
                }
                
                List<SkillRequirement> updateListSkillRequirements = new List<SkillRequirement>();            
                for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
                    BLN_GenericWebserviceWrapper.JobAppointment_CLS jobApp = oL.serviceAppointment; 
                    String workOrderLineItemID = mapWOLIANDWorkTypes.get(oL.tasktype);
                    
                    //Below code checks the new skill requirements against the existing WOLI Skill Requirements
                    //and when match found, updates the skill level
                    //this also updates appointment as forced appointment where skills level changed to 9 
                    if(oL.taskRequiredSkill.size()>0){                    
                        for(BLN_GenericWebserviceWrapper.RequiredSkills_CLS rs:oL.taskRequiredSkill){
                            for(SkillRequirement existSkillReq: srList){                            
                                if(existSkillReq.Skill.MasterLabel == rs.skill && existSkillReq.RelatedRecordId==workOrderLineItemID){// && existSkillReq.RelatedRecordId == rs.RelatedRecordId){
                                    existSkillReq.SkillLevel = Decimal.valueOf(rs.skilllevel)<>null?Decimal.valueOf(rs.skilllevel):null;
                                    if(Decimal.valueOf(rs.skilllevel)==9){
                                        mapOf_WOLIremedyTaskId_And_ForcedApp.put(jobApp.remedyTaskId, true);  
                                    } else{
                                        mapOf_WOLIremedyTaskId_And_ForcedApp.put(jobApp.remedyTaskId, false);  
                                    }
                                    updateListSkillRequirements.add(existSkillReq) ;                    
                                }                                                     
                            }                        
                        }                    
                    }else{
                        mapOf_WOLIremedyTaskId_And_ForcedApp.put(jobApp.remedyTaskId, false); 
                    }
                }
                
                if(updateListSkillRequirements.size()>0){
                        update updateListSkillRequirements;
                }
                
                for(ServiceAppointment sA:updateSAList){
                    sA.BLN_IsForcedAppointment__c = mapOf_WOLIremedyTaskId_And_ForcedApp.get(sA.BLN_RemedyTaskId__c) <> null? mapOf_WOLIremedyTaskId_And_ForcedApp.get(sA.BLN_RemedyTaskId__c):false;
                }

            } //end of if statement
            
            if(updateSAList.size()>0){
                updateSAList = BLN_GetServiceAppointmentHistory.setAppointmentHistory(updateSAList);                
                update updateSAList;
            }
            if(lstWOLIsToUpdate.size()>0){                
                update lstWOLIsToUpdate;
            }
            update wo;
        }
        
        BLN_GenericWebserviceWrapper.RemedyResponseWrapper rt = new BLN_GenericWebserviceWrapper.RemedyResponseWrapper();
        rt.isSuccess = 'true';
        rt.isError = 'false';
        rt.errorMessage = null;
        rt.WorkOrder_BLN_RemedyJobId = formatId(wORemedyJobId);
        rt.workOrder_Id = workOrderId;
        rt.ServiceAppointment_BLN_RemedyTaskId = formatId(mainSATaskId);
        rt.ServiceAppointment_Id = mainSAId;
        rt.ServiceAppointment_Status = mainSAStatus == 'None' ? 'Open' : mainSAStatus;
        return rt;
        } catch(Exception ex) {
            Set<String> setOfRemedyTaskTypes = new Set<String>();
            for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
                if(oL.taskType!=null){
                    setOfRemedyTaskTypes.add(oL.taskType);
                }
            }
            sendBookingErrorPlatformEvent(BLN_HandlerWebservice.getSAByWorkTypeName(WorkOrder[0].BLN_RemedyJobId__c,setOfRemedyTaskTypes));
            throw ex;
        }
    }

    public static void sendBookingErrorPlatformEvent(List<ServiceAppointment> failedAppointments) {
        if(failedAppointments != null) {
            BLN_BookingFailed__e bookingFailed = new BLN_BookingFailed__e ();
            List<Id> serviceAppointments = new List<Id>();
            for (ServiceAppointment serviceAppointment : failedAppointments) {
                serviceAppointments.add(serviceAppointment.Id);
            }
            bookingFailed.ServiceAppointments__c = JSON.serialize(serviceAppointments);
            EventBus.publish(bookingFailed);
        }
    }
    
    /** @description : taskUpdate(BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder) method for operation 'TaskUpdate'
* @param : BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder
* @return : BLN_GenericWebserviceWrapper.ResponseWrapper2
*/
    private static BLN_GenericWebserviceWrapper.RemedyResponseWrapper2 taskUpdate(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder){
        String workOrderId = null;
        String wORemedyJobId = null;
        String caseId = null;
        String caseAccId = null;
        List<ServiceAppointment> updatedSAList = new List<ServiceAppointment>();
        List<BLN_GenericWebserviceWrapper.sARemedyResponseWrapper> sAWrapperList = new List<BLN_GenericWebserviceWrapper.sARemedyResponseWrapper>();
        Set<String> setOfRemedyTaskIds = new Set<String>();
        Set<String> mandatoryStatusForFailureReasons = new Set<String>{System.Label.BLN_FAA, System.Label.BLN_FBA,System.Label.BLN_Canceled };
            for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
                if(oL.serviceAppointment.remedyTaskId!=null){                     
                    setOfRemedyTaskIds.add(oL.serviceAppointment.remedyTaskId);
                }
            }
        
        List<ServiceAppointment> sAList = BLN_HandlerWebservice.getSAByRemedyTaskId(setOfRemedyTaskIds);
        Map<String, Map<String, String>> failureResonsMap = BLN_FSLUtility.fetchFailureReasonsFromCode();      
        List<BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS> wOLIs = jobWorkOrder.workOrderLineItem;
        Map<String, BLN_GenericWebserviceWrapper.JobAppointment_CLS> mapOfRemedyTaskIdAndWOLI = new Map<String, BLN_GenericWebserviceWrapper.JobAppointment_CLS>();
        if(wOLIs!=null && wOLIs.size()>0){
            for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS wOLI:wOLIs){
                BLN_GenericWebserviceWrapper.JobAppointment_CLS app = wOLI.serviceAppointment;
                mapOfRemedyTaskIdAndWOLI.put(app.remedyTaskId,app);
            }
        }
        if(sAList!=null && sAList.size()>0){
            for(ServiceAppointment sA:sAList){
                BLN_GenericWebserviceWrapper.JobAppointment_CLS jobApp = mapOfRemedyTaskIdAndWOLI.get(sA.BLN_RemedyTaskId__c);
                ServiceAppointment updatedSA = new ServiceAppointment();
                updatedSA.Id = sA.Id;
                updatedSA.Status = sA.Status;
                if(String.isEmpty(jobApp.failureReasonCodeId)){
                    jobApp.failureReasonCodeId='1';
                }
                if(mandatoryStatusForFailureReasons.contains(jobApp.serviceAppointmentStatus) && isCanceledStatusChanged(sa.Status, updatedSa.Status)) {
                    //if(!String.isEmpty(jobApp.failureReasonCodeId) && mandatoryStatusForFailureReasons.contains(jobApp.serviceAppointmentStatus)){
                    updatedSA.BLN_FailureReason__c = failureResonsMap.get(String.valueOf(jobApp.failureReasonCodeId)).get('Level1');
                    updatedSA.BLN_SubFailureReason__c = failureResonsMap.get(String.valueOf(jobApp.failureReasonCodeId)).get('Level2');
                }
                updatedSAList.add(updatedSA);
                BLN_GenericWebserviceWrapper.sARemedyResponseWrapper sAWrapper = new BLN_GenericWebserviceWrapper.sARemedyResponseWrapper();
                sAWrapper.ServiceAppointment_BLN_RemedyTaskId = formatId(sA.BLN_RemedyTaskId__c);
                sAWrapper.ServiceAppointment_Status = updatedSA.Status;
                sAWrapperList.add(sAWrapper);           
            }
        }
        if(updatedSAList!=null && updatedSAList.size()>0){
            update updatedSAList;   
        }
        List<WorkOrder> workOrder = BLN_HandlerWebservice.getWOByRemedyJobId(jobWorkOrder.remedyJobId);
        if(workOrder!=null){
            workOrderId = workOrder[0].Id;
            wORemedyJobId = workOrder[0].BLN_RemedyJobId__c;
            caseId = workOrder[0].CaseId;
            caseAccId = workOrder[0].Case.AccountId;
        }
        
        String phFirstName = '';
        String phLastName = '';
        String phAccountType='';
        String phSalutaion='';
        String phPhone='';
        String motoristFirstName = '';
        String motoristLastName = '';
        String motoristAccountType='';
        String motoristSalutation='';
        String motoristPhone='';
        String policyHolderLabel = System.Label.BLN_PolicyHolder;
        String motoristLabel = System.Label.BLN_Motorist;
        Boolean updateMotorist = false;
        Boolean updatePolicyHolder = false;
        
        
        List<Account> updatedAccountList = new List<Account>();
        for(BLN_GenericWebserviceWrapper.PersonAccount_CLS pA:jobWorkOrder.personAccount){
            if(pA.accountType == policyHolderLabel){ 
                //updatePolicyHolder = (pA.firstName==NULL && pA.lastName==NULL) ? FALSE : TRUE; // Record Lock Issue Fix
                if(pA.firstName.length()==0 && pA.lastName.length()==0){
                    updatePolicyHolder = TRUE;               
                    phAccountType=pA.accountType;    
                    phSalutaion=pA.salutation;
                    phPhone=pA.contactPhoneNumber;
                }
                else{
                    phFirstName = pA.firstName.length()>0?pA.firstName.length()>40?pA.firstName.subString(0,40):pA.firstName:pA.firstName;
                    phLastName = pA.lastName.length()>0?pA.lastName.length()>80?pA.lastName.subString(0,80):pA.lastName:'.';             
                    phAccountType=pA.accountType;    
                    phSalutaion=pA.salutation;
                    phPhone=pA.contactPhoneNumber;
                    updatePolicyHolder = TRUE;
                }
                //updatePolicyHolder = true;
            }
            else if(pA.accountType == motoristLabel){
                if(pA.firstName.length()==0 && pA.lastName.length()==0){
                    updateMotorist = TRUE;
                    motoristAccountType=pA.accountType;
                    motoristSalutation=pA.salutation;
                    motoristPhone=pA.contactPhoneNumber;
                }
                else{                    
                    motoristFirstName = pA.firstName.length()>0?pA.firstName.length()>40?pA.firstName.subString(0,40):pA.firstName:pA.firstName;
                    pA.firstName = motoristFirstName;
                    motoristLastName = pA.lastName.length()>0?pA.lastName.length()>80?pA.lastName.subString(0,80):pA.lastName:'.';
                    pA.lastName = motoristLastName;
                    motoristAccountType=pA.accountType;
                    motoristSalutation=pA.salutation;
                    motoristPhone=pA.contactPhoneNumber;
                    updateMotorist = TRUE;
                }
            }
        }
        Account policyHolder = new Account();
        Account updatedpolicyHolder = new Account();
        Boolean shouldupdatePH = FALSE;
        Account motoristPA = new Account();
        Account updatedmotoristPA = new Account();
        Boolean shouldupdateMTR = FALSE;
        Boolean shouldupdateWOAcc = FALSE;
        List<Account> newAccountList = new List<Account>();
        
        if(updatePolicyHolder==true){
            List<Account> existingCaseAccount = BLN_HandlerWebservice.getAccountByIdAndType(new Set<Id>{caseAccId});
            if(existingCaseAccount!=NULL){
                for(Account paAccount : existingCaseAccount){
                    Account phAccontUpdate = new Account();
                    phAccontUpdate.Salutation = phSalutaion;
                    phAccontUpdate.PersonMobilePhone = phPhone;
                    if(paAccount.Name == System.Label.BLN_RemedyDummyPersonAccountName)
                    {
                        phAccontUpdate.FirstName = phFirstName;
                        phAccontUpdate.LastName = phLastName.length()>0?phLastName:'.';
                        phAccontUpdate.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
                        newAccountList.add(phAccontUpdate);
                    }
                    else{
                        phAccontUpdate.FirstName = phFirstName.length()>0?phFirstName:paAccount.FirstName;
                        phAccontUpdate.LastName = phLastName.length()>0?phLastName:paAccount.LastName;
                        phAccontUpdate.Id = paAccount.Id;
                        updatedAccountList.add(phAccontUpdate);
                    } 
                }
            }
            else{
                Account phAccontNew = new Account();
                phAccontNew.Salutation = phSalutaion;
                phAccontNew.PersonMobilePhone = phPhone;
                phAccontNew.FirstName = phFirstName;
                phAccontNew.LastName = phLastName.length()>0?phLastName:'.';
                phAccontNew.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
                newAccountList.add(phAccontNew);
            }
        }
        if(updateMotorist==true){
            List<CaseContactRole> listCCR = BLN_HandlerWebservice.getCaseConRole(new Set<String>{caseId});
            if(listCCR!=null){
                List<Account> motoristPAList = BLN_HandlerWebservice.getAccountByPersonConId(new Set<Id>{listCCR[0].ContactId});
                Account accontUpdate = new Account();
                if(motoristPAList!=null){
                    String accId = motoristPAList[0].Id;
                    accontUpdate.Salutation = motoristSalutation;
                    accontUpdate.PersonMobilePhone = motoristPhone;
                    if(accontUpdate.Name == System.Label.BLN_RemedyDummyPersonAccountName)
                    {
                        accontUpdate.FirstName = motoristFirstName;
                        accontUpdate.LastName = motoristLastName.length()>0?motoristLastName:'.';
                        accontUpdate.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
                        newAccountList.add(accontUpdate);
                    }
                    else{
                        accontUpdate.FirstName = motoristFirstName.length()>0?motoristFirstName:motoristPAList[0].FirstName;
                        accontUpdate.LastName = motoristLastName.length()>0?motoristLastName:motoristPAList[0].LastName;
                        accontUpdate.Id = accId;
                        updatedAccountList.add(accontUpdate);
                    } 
                }
            }
        }
        if(updatedAccountList.size()>0){
            update updatedAccountList;
        }
        // Record Lock Issue Fix
        if(newAccountList.size()>0){
            insert newAccountList;
            
            Case updatedCase = new Case();            
            List<Case> updatedCaseList = new List<Case>();
            
            updatedCase.Id = caseId;
            updatedCase.AccountId = newAccountList[0].Id;
            updatedCaseList.add(updatedCase);
            if(updatedCaseList.size()>0){
                update updatedCaseList;
            }
            shouldupdateWOAcc = TRUE;
        }
        //Update the WO
        if(!String.isEmpty(workOrderId)){
            WorkOrder updatedWO = new WorkOrder();
            updatedWO.Id = workOrderId;
            updatedWO.BLN_ADASJob__c  = Boolean.valueOf(jobWorkOrder.ADASJob);
            if(shouldupdateWOAcc == TRUE){
                updatedWO.AccountId = newAccountList[0].Id;
            }
            update updatedWO;
        }
        
        BLN_GenericWebserviceWrapper.RemedyResponseWrapper2 rt = new BLN_GenericWebserviceWrapper.RemedyResponseWrapper2();
        rt.isSuccess = 'true';
        rt.isError = 'false';
        rt.errorMessage = null;
        rt.WorkOrder_BLN_RemedyJobId = formatId(wORemedyJobId);
        rt.ServiceAppointments = sAWrapperList;
        return rt;
    }
    
    /** @description : taskUpdateStatus(BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder) method for operation 'TaskUpdateStatus'
* @param : BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder
* @return : BLN_GenericWebserviceWrapper.ResponseWrapper3
*/
    private static BLN_GenericWebserviceWrapper.RemedyResponseWrapper3 taskUpdateStatus(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder){
        String wORemedyJobId = null;
        List<ServiceAppointment> updatedSAList = new List<ServiceAppointment>();
        List<BLN_GenericWebserviceWrapper.sARemedyResponseWrapper2> sAWrapperList = new List<BLN_GenericWebserviceWrapper.sARemedyResponseWrapper2>();
        Set<String> setOfRemedyTaskIds = new Set<String>();
        
        for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
            if(oL.serviceAppointment.remedyTaskId!=null){                     
                setOfRemedyTaskIds.add(oL.serviceAppointment.remedyTaskId);
            }
        }
        List<ServiceAppointment> sAList = BLN_HandlerWebservice.getSAByRemedyTaskId(setOfRemedyTaskIds);
        Map<String, Map<String, String>> failureResonsMap = BLN_FSLUtility.fetchFailureReasonsFromCode();
        Set<String> mandatoryStatusForFailureReasons = new Set<String>{System.Label.BLN_FAA, System.Label.BLN_FBA,System.Label.BLN_Canceled };
            List<BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS> wOLIs = jobWorkOrder.workOrderLineItem;
        Map<String, BLN_GenericWebserviceWrapper.JobAppointment_CLS> mapOfRemedyTaskIdAndWOLI = new Map<String, BLN_GenericWebserviceWrapper.JobAppointment_CLS>();
        if(wOLIs!=null && wOLIs.size()>0){
            for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS wOLI:wOLIs){
                BLN_GenericWebserviceWrapper.JobAppointment_CLS app = wOLI.serviceAppointment;
                mapOfRemedyTaskIdAndWOLI.put(app.remedyTaskId,app);
                
            }
        }
        
        if (sAList!=null && sAList.size() > 0){
            for(ServiceAppointment sA:sAList){
                BLN_GenericWebserviceWrapper.JobAppointment_CLS jobApp = mapOfRemedyTaskIdAndWOLI.get(sA.BLN_RemedyTaskId__c);
                ServiceAppointment updatedSA = new ServiceAppointment();
                updatedSA.Id = sA.Id;
                updatedSA.Status = jobApp.serviceAppointmentStatus;
                updatedSA.FSL__Pinned__c = false;  
                /*FOUK-3341 Start*/
                if(!String.isEmpty(jobApp.actualArrivalDateTime) && ((jobApp.serviceAppointmentStatus.equalsIgnoreCase('Arrived') && !sA.BLN_IsBranchAppointment__c) || (jobApp.serviceAppointmentStatus.equalsIgnoreCase('In Progress') && (sA.BLN_IsBranchAppointment__c || sA.WorkType.Name=='Stock Collect')))){
                    updatedSA.ActualStartTime = BLN_FSLUtility.changeStrToDateTime(jobApp.actualArrivalDateTime);
                    updatedSA.SchedStartTime = BLN_FSLUtility.changeStrToDateTime(jobApp.actualArrivalDateTime);
                    updatedSA.SchedEndTime = updatedSA.SchedStartTime+sA.FSL__Duration_In_Minutes__c/1440;
                }
                else if(!String.isEmpty(jobApp.actualCompletionDateTime) && (jobApp.serviceAppointmentStatus.equalsIgnoreCase('Failed After Arrive') || jobApp.serviceAppointmentStatus.equalsIgnoreCase('Completed'))){
                    updatedSA.ActualEndTime = !String.isEmpty(jobApp.actualCompletionDateTime)?BLN_FSLUtility.changeStrToDateTime(jobApp.actualCompletionDateTime):null;
                    if (updatedSA.ActualEndTime.isSameDay(sA.SchedStartTime)) {
                        updatedSA.SchedEndTime = !String.isEmpty(jobApp.actualCompletionDateTime)?BLN_FSLUtility.changeStrToDateTime(jobApp.actualCompletionDateTime):null;
                    }
                }
                
                /*FOUK-3341 End*/
                
                if(String.isEmpty(jobApp.failureReasonCodeId)){
                    jobApp.failureReasonCodeId='1';
                }
                
                if(mandatoryStatusForFailureReasons.contains(jobApp.serviceAppointmentStatus) && isCanceledStatusChanged(sa.Status, updatedSa.Status)) {
                    //if(!String.isEmpty(jobApp.failureReasonCodeId) && mandatoryStatusForFailureReasons.contains(jobApp.serviceAppointmentStatus)){
                    updatedSA.BLN_FailureReason__c = failureResonsMap.get(String.valueOf(jobApp.failureReasonCodeId)).get('Level1');
                    updatedSA.BLN_SubFailureReason__c = failureResonsMap.get(String.valueOf(jobApp.failureReasonCodeId)).get('Level2');
                }
                updatedSAList.add(updatedSA);
                
                BLN_GenericWebserviceWrapper.sARemedyResponseWrapper2 sAWrapper = new BLN_GenericWebserviceWrapper.sARemedyResponseWrapper2();
                sAWrapper.ServiceAppointment_BLN_RemedyTaskId = formatId(sA.BLN_RemedyTaskId__c);
                sAWrapper.ServiceAppointment_Status =updatedSA.Status;
                sAWrapperList.add(sAWrapper);
                
            }
        }
        if(updatedSAList!=null && updatedSAList.size()>0){
            update updatedSAList;
        }
        List<WorkOrder> workOrder = BLN_HandlerWebservice.getWOByRemedyJobId(jobWorkOrder.remedyJobId);
        if(workOrder!=null){
            
            wORemedyJobId = workOrder[0].BLN_RemedyJobId__c;
        }
        BLN_GenericWebserviceWrapper.RemedyResponseWrapper3 rt = new BLN_GenericWebserviceWrapper.RemedyResponseWrapper3();
        rt.isSuccess = 'true';
        rt.isError = 'false';
        rt.errorMessage = null;
        rt.WorkOrder_BLN_RemedyJobId = formatId(wORemedyJobId);
        rt.ServiceAppointments = sAWrapperList;
        return rt;
    }
    
    
    
    /** 
*  @description : shortening(BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder) method for operation 'Shortening'

*  @param : BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder
*  @return : BLN_GenericWebserviceWrapper.RemedyResponseWrapper2
*/
    
    private static BLN_GenericWebserviceWrapper.RemedyResponseWrapper2 shortening(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder){
        String wORemedyJobId = null;
        List<ServiceAppointment> updatedSAList = new List<ServiceAppointment>();
        List<BLN_GenericWebserviceWrapper.sARemedyResponseWrapper> sAWrapperList = new List<BLN_GenericWebserviceWrapper.sARemedyResponseWrapper>();
        Map<String, String> mapOfSATaskIdAndStatus = new Map<String, String>();
        Set<String> setOfRemedyTaskIds = new Set<String>();
        for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
            if(oL.serviceAppointment.remedyTaskId!=null){                     
                setOfRemedyTaskIds.add(oL.serviceAppointment.remedyTaskId);
            }
        }
        List<ServiceAppointment> sAList = BLN_HandlerWebservice.getSAByRemedyTaskId(setOfRemedyTaskIds);
        List<BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS> wOLIs = jobWorkOrder.workOrderLineItem;
        Map<String, BLN_GenericWebserviceWrapper.JobAppointment_CLS> mapOfRemedyTaskIdAndWOLI = new Map<String, BLN_GenericWebserviceWrapper.JobAppointment_CLS>();
        if(wOLIs!=null && wOLIs.size()>0){
            for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS wOLI:wOLIs){
                BLN_GenericWebserviceWrapper.JobAppointment_CLS app = wOLI.serviceAppointment;
                mapOfRemedyTaskIdAndWOLI.put(app.remedyTaskId,app);
            }
        }
        if(sAList!=null && sAList.size()>0){
            for(ServiceAppointment sA:sAList){
                if(sA.Id!=null && sA.Status!=null)
                    mapOfSATaskIdAndStatus.put(sA.BLN_RemedyTaskId__c, sA.Status);
            }
            for(ServiceAppointment sA:sAList){
                BLN_GenericWebserviceWrapper.JobAppointment_CLS jobApp = mapOfRemedyTaskIdAndWOLI.get(sA.BLN_RemedyTaskId__c);                ServiceAppointment updatedSA = new ServiceAppointment();
                updatedSA.Id = sA.Id;
                updatedSA.EarliestStartTime = BLN_FSLUtility.changeStrToDateTime(jobApp.earliestStartTime);
                updatedSA.ArrivalWindowEndTime = BLN_FSLUtility.changeStrToDateTime(jobApp.arrivalWindowEndTime);
                updatedSA.ArrivalWindowStartTime = BLN_FSLUtility.changeStrToDateTime(jobApp.arrivalWindowStartTime);
                updatedSA.DueDate = BLN_FSLUtility.changeStrToDateTime(jobApp.dueDateTime);
                updatedSAList.add(updatedSA);                
                BLN_GenericWebserviceWrapper.sARemedyResponseWrapper sAWrapper = new BLN_GenericWebserviceWrapper.sARemedyResponseWrapper();
                sAWrapper.ServiceAppointment_BLN_RemedyTaskId = formatId(sA.BLN_RemedyTaskId__c);
                sAWrapper.ServiceAppointment_Status = mapOfSATaskIdAndStatus.get(jobApp.remedyTaskId);
                sAWrapperList.add(sAWrapper);
            }
        }
        if(updatedSAList!=null && updatedSAList.size()>0){
            update updatedSAList;
        }
        List<WorkOrder> workOrder = BLN_HandlerWebservice.getWOByRemedyJobId(jobWorkOrder.remedyJobId);
        if(workOrder!=null){
            wORemedyJobId = workOrder[0].BLN_RemedyJobId__c;
        }
        BLN_GenericWebserviceWrapper.RemedyResponseWrapper2 rt = new BLN_GenericWebserviceWrapper.RemedyResponseWrapper2();
        rt.isSuccess = 'true';
        rt.isError = 'false';
        rt.errorMessage = null;
        rt.WorkOrder_BLN_RemedyJobId = formatId(wORemedyJobId);
        rt.ServiceAppointments = sAWrapperList;
        return rt;
    }
    
    
    /**
* Builds the WorkOrder Object for the given JobWorkOrder_CLS instance.
*
* @param jobWorkOrder The JobWorkOrder_CLS instance containing the necessary data.
* @param taskPrefix - eg. Rebook, ''
* @return The WorkOrder object.
*/
    private static WorkOrder buildWorkOrder(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder,String taskPrefix){
        WorkOrder wo = New WorkOrder();
        String jobType = getPrimaryAppointmentType(jobWorkOrder);
        wo.BLN_RemedyJobId__c  = taskPrefix+jobWorkOrder.remedyJobId;
        wo.AccountId = getDummyAccount().Id;
        wo.WorkTypeId = BLN_HandlerWebservice.getWorkType(jobType)[0].Id;
        wo.ServiceTerritoryId = getPrimaryAppointmentTerritory(jobWorkOrder).Id;
        wo.Subject = 'Work Order for '+jobType;
        wo.Description = 'Work Order for '+jobType;
        return wo;
    }
    
    /**
* Retrieves the primary appointment type eg. 'Repair' 'Replacement' for the given JobWorkOrder_CLS instance.
*
* @param jobWorkOrder The JobWorkOrder_CLS instance containing the necessary data.
* @return The primary Service Appointment Type.
*/
    
    private static String getPrimaryAppointmentType(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder){
        String primaryApp = '';
        primaryApp = jobWorkOrder.WorkOrderLineItem[0].taskType;
        return primaryApp;
    }
    
    /**
* Retrieves the primary Service Territory for the given JobWorkOrder_CLS instance.
*
* @param jobWorkOrder The JobWorkOrder_CLS instance containing the necessary data.
* @return The primary Service Territory object.
*/
    
    private static ServiceTerritory getPrimaryAppointmentTerritory(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder){
        List<ServiceTerritory> primTerr = new List<ServiceTerritory>();
        Set<String> primTerrTypes = new Set<String>();
        primTerrTypes.add(jobWorkOrder.WorkOrderLineItem[0].serviceAppointment.serviceTerritory.District);
        primTerr = BLN_HandlerWebservice.getDistrictServiceTerritory(primTerrTypes);
        return primTerr[0];
    }
    
    /**
* Builds a new Case object based on the provided JobWorkOrder_CLS instance.
*
* @param jobWorkOrder The JobWorkOrder_CLS instance containing the necessary data for building the Case.
* @return Case object.
*/
    
    private static Case buildCase(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder){
        Case newCase = new Case();
        newCase.Origin = 'Remedy';
        //removing account assignment INC0445884
        //newCase.AccountId = getDummyAccount().Id;
        newCase.BLN_RemedyJobId__c = jobWorkOrder.RemedyJobId;
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.BLN_RemedyCaseRecordTypeName).getRecordTypeId();
        return newCase;
    }
    
    
    /**
* Retrieves or creates a dummy Person Account based on the label value for the dummy account name.
*
* @return The dummy Account object.
*/
    
    private static Account getDummyAccount(){
        Account personAccount = new Account();
        List<Account> pAccount = BLN_HandlerWebservice.getDummyPersonAcc(System.Label.BLN_RemedyDummyPersonAccountName);
        if(!(pAccount.size()>0)){
            Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            personAccount.RecordTypeId = personAccRecTypeId;
            personAccount.LastName = System.Label.BLN_RemedyDummyPersonAccountName;
            insert personAccount;
        }else{
            personAccount = pAccount[0];
        }
        
        return personAccount;
    }
    
    /**
* Builds a list of WorkOrderLineItem objects based on the provided JobWorkOrder_CLS instance, ServiceTerritory record, and a mapping of task types to work type IDs.
*
* @param jobWorkOrder The JobWorkOrder_CLS instance containing the necessary data.
* @param terrRec The ServiceTerritory record associated with the jobWorkOrder.
* @param mapTaskTypeAndWorkTypeId A mapping of task types to work type IDs.
* @return A list of WorkOrderLineItem objects.
*/
    
    private static List<WorkOrderLineItem> buildWOLI(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder, ServiceTerritory terrRec, Map<String, String> mapTaskTypeAndWorkTypeId, String taskPrefix){
        List<WorkOrderLineItem> lstWOLI = new List<WorkOrderLineItem>();
        String remedyJobId = taskPrefix+jobWorkOrder.remedyJobId;
        
        for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
            BLN_GenericWebserviceWrapper.JobAppointment_CLS jobApp = oL.serviceAppointment;
            
            WorkOrderLineItem wOLI = new WorkOrderLineItem();
            wOLI.WorkOrder = new WorkOrder(BLN_RemedyJobId__c=remedyJobId);
            wOLI.BLN_RemedyJobId__c = remedyJobId;
            wOLI.BLN_RemedyTaskId__c = taskPrefix+jobApp.remedyTaskId;
            woLI.Subject = 'Task for '+oL.taskType;
            woLI.Description = 'Task for '+oL.taskType;
            wOLI.WorkTypeId = mapTaskTypeAndWorkTypeId.get(oL.taskType);
            
            //In order to prioritize stock collect appointments and schedule them at the beginning of the day, 
            //we utilize a flag that allows for optimization or sliding of these appointments.
            wOLI.Priority = oL.taskType == 'Stock Collect' ? 'Critical' : 'Low';
            
            //visiting hour are only set for branch appointment to restrict the appointment window
            //withinn branch opening and closing time
            wOLI.FSL__VisitingHours__c = Boolean.valueOf(jobApp.isBranchAppointment) && oL.taskType != 'Stock Collect' ? terrRec.OperatingHoursId : null;
            
            wOLI.ServiceTerritoryId = getPrimaryAppointmentTerritory(jobWorkOrder).Id;
            wOLI.Street = !String.isEmpty(jobApp.address.street)==true ? jobApp.address.street : '';
            wOLI.City = jobApp.address.city;
            wOLI.PostalCode = jobApp.address.postalCode;
            wOLI.Country = jobApp.address.countryID;
            
            lstWOLI.add(wOLI);  
        }
        return lstWOLI;
    }
    
    
    /**
* Builds a list of ServiceAppointment objects based on the provided JobWorkOrder_CLS instance, WorkOrder object, ServiceTerritory record,mapOf_WOLI_remedyTaskTypeAndId and mapOf_WOLIId_And_ForcedApp.
*
* @param jobWorkOrder The JobWorkOrder_CLS instance containing the necessary data.
* @param wo The WorkOrder object associated with the jobWorkOrder.
* @param terrRec The ServiceTerritory record associated with the jobWorkOrder.
* @param mapTaskTypeAndWorkTypeId A mapping of task types to work type IDs.
* @return A list of ServiceAppointment objects.
*/
    
    private static List<ServiceAppointment> buildJobAppointment(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder, WorkOrder wo, ServiceTerritory terrRec, Map<String, String> mapOf_WOLI_remedyTaskTypeAndId, String taskPrefix){
        List<ServiceAppointment> lstJobApp = new List<ServiceAppointment>();
        
        String schedulingPolicyId = BLN_HandlerWebservice.getSchedulingPolicy(System.Label.BLN_SchedulingPolicyName)[0].Id;        
        String arrivalWindowStart = '';
        String arrivalWindowEnd = '';
        String dueDate = '';
        String openDate = '';
        String remedyJobId = taskPrefix+jobWorkOrder.remedyJobId;
        
        for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
            BLN_GenericWebserviceWrapper.JobAppointment_CLS jobApp = oL.serviceAppointment;
            
            ServiceAppointment serviceApp = new ServiceAppointment();
            serviceApp.BLN_RemedyTaskId__c = taskPrefix+jobApp.remedyTaskId;
            serviceApp.BLN_RemedyJobId__c = remedyJobId;
            
            //To address the issue of missing arrival window start, end, due date, or open date in the request, 
            //specifically for ASSIST appointments, we have implemented the following logic 
            //to update them from the primary application.
            if(oL.taskType!='Stock Collect' && oL.taskType!= 'Assist'){
                arrivalWindowStart = !String.isEmpty(jobApp.arrivalWindowStartTime) ? jobApp.arrivalWindowStartTime: jobApp.earliestStartTime;
                arrivalWindowEnd = jobApp.arrivalWindowEndTime;  
                dueDate = jobApp.dueDateTime;
                openDate = jobApp.remedyOpenDate;
            }
            
            
            if(oL.taskType=='Stock Collect' && String.isEmpty(jobApp.earliestStartTime)){
                Datetime aptDateTime = BLN_FSLUtility.changeStrToDateTime(arrivalWindowStart);
                Date apptDate = date.newinstance(aptDateTime.year(), aptDateTime.month(), aptDateTime.day());
                serviceApp.EarliestStartTime = Datetime.newInstance(apptDate,Time.newInstance(6,0,0,0));
                serviceApp.ArrivalWindowStartTime = serviceApp.EarliestStartTime;
                serviceApp.ArrivalWindowEndTime = String.valueof(jobApp.arrivalWindowEndTime)<>'' ? BLN_FSLUtility.changeStrToDateTime(jobApp.arrivalWindowEndTime) : BLN_FSLUtility.changeStrToDateTime(dueDate) ;
            
                
            }  else if(oL.taskType=='Stock Collect' && !String.isEmpty(jobApp.earliestStartTime)){
                serviceApp.EarliestStartTime = BLN_FSLUtility.changeStrToDateTime(jobApp.earliestStartTime);
                serviceApp.ArrivalWindowEndTime = String.valueof(jobApp.arrivalWindowEndTime)<>'' ? BLN_FSLUtility.changeStrToDateTime(jobApp.arrivalWindowEndTime) : BLN_FSLUtility.changeStrToDateTime(dueDate) ;
            
                Datetime scEearlistStartTime = serviceApp.EarliestStartTime;
                Date scEarStartDate = date.newinstance(scEearlistStartTime.year(), scEearlistStartTime.month(), scEearlistStartTime.day());
                
                Datetime aptDateTime = BLN_FSLUtility.changeStrToDateTime(arrivalWindowStart);
                Date apptDate = date.newinstance(aptDateTime.year(), aptDateTime.month(), aptDateTime.day());
                
                if(scEarStartDate<apptDate){
                    serviceApp.ArrivalWindowStartTime = Datetime.newInstance(apptDate,Time.newInstance(6,0,0,0));
                } else{
                    serviceApp.ArrivalWindowStartTime = serviceApp.EarliestStartTime;
                }
            } else{
                serviceApp.ArrivalWindowStartTime = String.valueof(jobApp.arrivalWindowStartTime)<>''? BLN_FSLUtility.changeStrToDateTime(jobApp.arrivalWindowStartTime) : BLN_FSLUtility.changeStrToDateTime(arrivalWindowStart) ;
                serviceApp.EarliestStartTime = !String.isEmpty(jobApp.earliestStartTime) == true ? BLN_FSLUtility.changeStrToDateTime(jobApp.earliestStartTime) : serviceApp.arrivalWindowStartTime;
                serviceApp.ArrivalWindowEndTime = String.valueof(jobApp.arrivalWindowEndTime)<>'' ? BLN_FSLUtility.changeStrToDateTime(jobApp.arrivalWindowEndTime) : BLN_FSLUtility.changeStrToDateTime(arrivalWindowEnd) ;
            
            }
            
            serviceApp.DueDate = !String.isEmpty(jobApp.dueDateTime)==true?BLN_FSLUtility.changeStrToDateTime(jobApp.dueDateTime):BLN_FSLUtility.changeStrToDateTime(dueDate);
            
            serviceApp.FSL__Scheduling_Policy_Used__c = schedulingPolicyId;
            serviceApp.BLN_AppointmentCreatedFromRemedy__c = true;  
            serviceApp.BLN_IsBranchAppointment__c = Boolean.valueOf(jobApp.isBranchAppointment);
            
            //To determine if an appointment is mobile or not, 
            //we consider any appointment that is not at the branch as a mobile appointment. 
            //To reflect this information in the appointment, 
            //we use the reverse flag since we only receive the branch flag in the request.
            serviceApp.BLN_IsMobileAppointment__c = !Boolean.valueOf(jobApp.isBranchAppointment);
            
            serviceApp.ParentRecordId = mapOf_WOLI_remedyTaskTypeAndId.get(oL.taskType);
            serviceApp.BLN_WorkOrderLineItem__c = serviceApp.ParentRecordId;
            serviceApp.BLN_WorkOrderNumber__c = wo.Id;
            
            //In order to prioritize stock collect appointments and schedule them at the beginning of the day, 
            //we utilize a flag that allows for optimization or sliding of these appointments.
            serviceApp.FSL__Schedule_over_lower_priority_appointment__c = oL.taskType == 'Stock Collect' ? true : false;
            
            serviceApp.Subject = 'Appointment for '+oL.taskType;
            serviceApp.Description = 'Appointment for '+oL.taskType;
            
            serviceApp.Street = jobApp.address.street;
            serviceApp.City = jobApp.address.city;
            serviceApp.PostalCode = jobApp.address.postalCode;
            serviceApp.Country = jobApp.address.countryID;
            
            serviceApp.ServiceTerritoryId = terrRec.Id;
            serviceApp.DurationType = 'Minutes';
            serviceApp.Duration = (((Decimal)((Decimal.valueOf(jobApp.duration))/60.00)).setScale(2));
            serviceApp.BLN_RemedyProfile__c = jobWorkOrder.remedyProfile;            
            serviceApp.BLN_RemedyOpenDate__c = !String.isEmpty(jobApp.remedyOpenDate) == true ?BLN_FSLUtility.changeStrToDateTime(jobApp.remedyOpenDate): BLN_FSLUtility.changeStrToDateTime(openDate);
            lstJobApp.add(serviceApp);  
        }
        return lstJobApp;
    }
    
    
    /* @description : this method returns map of worktype name and id
* 
*/
    
    private static Map<String,String> mapTaskTypeAndWorkTypeId(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder){
        Map<String, String> mapTaskAndWorkTypeId = new Map<String, String>();
        Set<String> setOfWorkTypes = new Set<String>();
        
        for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
            if(oL.taskType!=null){
                setOfWorkTypes.add(oL.taskType);
            }
        }
        
        if(setOfWorkTypes!=null && setOfWorkTypes.size()>0){
            List<WorkType> listOfWorkTypes = BLN_HandlerWebservice.getWorkType(setOfWorkTypes);
            for(WorkType workType:listOfWorkTypes){
                if(workType.Name!=null && workType.Id!=null)
                    mapTaskAndWorkTypeId.put(workType.Name, workType.Id);
            }
        }
        
        return mapTaskAndWorkTypeId;
        
    }


/**
  @description: this method formats string into a remedy compatible format
  @param : String
  @return : String

 */
	@TestVisible
    private static string formatId(String str){
        String formattedString = str;
        if(formattedString.contains('_')){
            Integer index = formattedString.indexOf('_');
            formattedString = formattedString.right(formattedString.length()-index-1);
        }
        return formattedString;
        
    }
     
    
    /** @description : Checks for existing Work Order with Same task types
* @param : BLN_GenericWebserviceWrapper.JobWorkOrder jobWorkOrder
* @return : Boolean
*/  
    
    private static boolean jobMatching(BLN_GenericWebserviceWrapper.JobWorkOrder_CLS jobWorkOrder, String remedyJobId){
        Set<String> setOfWorkTypes = new Set<String>();
        
        for(BLN_GenericWebserviceWrapper.JobWorkOrderLine_CLS oL:jobWorkOrder.workOrderLineItem){
            if(oL.taskType!=null){                     
                setOfWorkTypes.add(oL.taskType);
            }
        }     
        
        Boolean isMatchingAppointemnts = true;
        List<ServiceAppointment> getSAList = BLN_HandlerWebservice.getSAByWorkTypeName(remedyJobId, setOfWorkTypes);
        if(getSAList==null || getSAList.size() != setOfWorkTypes.size()){
            isMatchingAppointemnts = false;
        }
        
        return isMatchingAppointemnts;
    }   
    
    
    
    /* @descripton : this methods creates appointment dependencies based on task type
* 
*/
    
    public static void createAppointmentDependencies(String primaryApp, List<ServiceAppointment> lstAppt){
        List<FSL__Time_Dependency__c> lstAppDependencies = new List<FSL__Time_Dependency__c>();
        for(ServiceAppointment servApp : lstAppt){
            if(servApp.WorkType.Name == 'Stock Collect'){
                FSL__Time_Dependency__c dependency = new FSL__Time_Dependency__c();
                dependency.FSL__Root_Service_Appointment__c = primaryApp;
                dependency.FSL__Service_Appointment_1__c = primaryApp;
                dependency.FSL__Service_Appointment_2__c = servApp.Id;
                dependency.FSL__Dependency__c = 'Start After Finish And Same Day';
                dependency.FSL__Same_Resource__c = true;
                lstAppDependencies.add(dependency);
            }
            else if(servApp.WorkType.Name == 'Assist'){
                FSL__Time_Dependency__c dependency = new FSL__Time_Dependency__c();
                dependency.FSL__Root_Service_Appointment__c = primaryApp;
                dependency.FSL__Service_Appointment_1__c = primaryApp;
                dependency.FSL__Service_Appointment_2__c = servApp.Id;
                dependency.FSL__Dependency__c = 'Same Start';
                dependency.FSL__Same_Resource__c = false;
                lstAppDependencies.add(dependency);
            }
        }
        if(lstAppDependencies!=null && lstAppDependencies.size()>0){
            insert lstAppDependencies;
        }
        
        
        
    }
    
    public static Datetime prepareDueDateWithBuffer(Datetime ArrivalWindowEndTime, Decimal buffer, Integer duration) {
        Datetime dueDate;
        Integer timeToAdd;
 
        if (buffer != null) {
            timeToAdd = (Integer) (duration + (duration * (buffer/100)));
            dueDate = ArrivalWindowEndTime.addSeconds(timeToAdd);
        } else {
            dueDate = ArrivalWindowEndTime.addSeconds(duration);
        }

        return dueDate;
    }
    
    private static Boolean isCanceledStatusChanged(String oldStatus, String newStatus) {
        if (oldStatus == System.Label.BLN_Canceled && oldStatus == newStatus) {
            return false;
        } else {
            return true;
        }
    }
}