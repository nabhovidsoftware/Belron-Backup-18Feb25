/** @description : This Apex is for Mulesoft Integration
*   @Story : FOUK-198, 679, 680, 681
*   @author: Kanchan Mishra (PwC)
*   @CreatedDate: 27/07/2023
*/
public without sharing class BLN_HTTPCallOutToMuleSoft implements Queueable, Database.AllowsCallouts{
    List<List<String>> calloutBodyList;
    Boolean eventTriggered;
    List<SObject> listOfIntegrationLogs;
    List<ServiceAppointment> successServiceAppointments;
    List<ServiceAppointment> failureServiceAppointments;
    final static String CURRENT = 'current';
    final static String PREVIOUS = 'previous';

    public BLN_HTTPCallOutToMuleSoft (List<List<String>> calloutBodyList, Boolean eventTriggered){
        this.calloutBodyList = calloutBodyList;
        this.eventTriggered = eventTriggered;
    }

    public void execute(QueueableContext context) {
        System.debug('BLN_HTTPCallOutToMuleSoft execute called');        
        this.successServiceAppointments = new List<ServiceAppointment>();
        this.failureServiceAppointments = new List<ServiceAppointment>();
        Boolean isApiCalloutLimitReached = false;
        Id processedRecord;
        this.listOfIntegrationLogs = new List<SObject>();
        List<List<String>> serviceAppointments = new List<List<String>>();
        serviceAppointments.addAll(calloutBodyList);
        Integer calloutExecutedCounter = 0;
        List<Exception> exceptionList = new List<Exception>();
        Datetime dtLastMinuteAgo = System.now();
        dtLastMinuteAgo = dtLastMinuteAgo.addMinutes(-1);
        BLN_CalloutSettings__c calloutOptions = BLN_CalloutSettings__c.getInstance();
        List<AggregateResult> integrationLogsInLastMinute = [
                SELECT
                        COUNT(Id)
                FROM
                        BLN_IntegrationLogger__c
                WHERE
                        (BLN_TargetSystem__c = 'Mulesoft'
                        OR BLN_TargetSystem__c = 'Okta')
                AND
                        CreatedDate > :dtLastMinuteAgo
        ];
        List<AggregateResult> exceptionLogsInLastMinute = [
                SELECT
                        COUNT(Id)
                FROM
                        BLN_ExceptionLogger__c
                WHERE
                        (BLN_EntityName__c = 'BLN_HTTPCallOutToMuleSoft'
                        OR BLN_EntityName__c = 'BLN_GenerateOktaToken')
                        AND
                        CreatedDate > :dtLastMinuteAgo
        ];

        Integer apiCalloutLogsInLastMinute = (Integer)integrationLogsInLastMinute.get(0).get('expr0') + (Integer)exceptionLogsInLastMinute.get(0).get('expr0');

        Integer scopeSize = Integer.valueOf(calloutOptions.BLN_CurrentMulesoftAPILimit__c) < 100 ?
                Integer.valueOf(calloutOptions.BLN_CurrentMulesoftAPILimit__c)
                : 100;


        AsyncOptions options = new AsyncOptions();
        options.MinimumQueueableDelayInMinutes = Integer.valueOf(calloutOptions.BLN_MinutesOfDelay__c);
        if ((Integer.valueOf(calloutOptions.BLN_CurrentMulesoftAPILimit__c) <= apiCalloutLogsInLastMinute)) {
            System.enqueueJob(new BLN_HTTPCallOutToMuleSoft(calloutBodyList, eventTriggered), options);
            isApiCalloutLimitReached = true;
        }

        if (!isApiCalloutLimitReached && calloutBodyList != null && !calloutBodyList.isEmpty()) {
            scopeSize = Integer.valueOf(calloutOptions.BLN_CurrentMulesoftAPILimit__c) - apiCalloutLogsInLastMinute < scopeSize ?
                    Integer.valueOf(calloutOptions.BLN_CurrentMulesoftAPILimit__c) - apiCalloutLogsInLastMinute
                    : scopeSize;
            String auth;

            try {
                Cache.OrgPartition orgPart = Cache.Org.getPartition('local.OKTAIdP');
                DateTime expiresIn = (DateTime) orgPart.get('OKTATokenExpirationDateTime');
                String oktaToken = (String) orgPart.get('OKTAAccessToken');
                auth = System.label.BLN_Bearer + ' ' + oktaToken;
                String correlationId = BLN_IntegrationLogger.randomCodeGenerator();
                String instanceUrl = System.label.BLN_CurrentOrgInitials;
                String endPointMulesoft = System.label.BLN_MulesoftEndpoint;
                System.debug('BLN_HTTPCallOutToMuleSoft execute try start' +
                ' scopeSize '+scopeSize+
                ' calloutExecutedCounter '+calloutExecutedCounter+
                ' expiresIn '+expiresIn+
                ' expireeventTriggeredsIn '+eventTriggered+
                ' oktaToken '+oktaToken);
                
                
                for (List<String> currentScope : calloutBodyList) {
                    processedRecord = null;
                    System.debug('BLN_HTTPCallOutToMuleSoft execute for loop'); 
                    if (calloutExecutedCounter < scopeSize && expiresIn != null && oktaToken != null && expiresIn > Datetime.now().addSeconds(Integer.valueOf(calloutOptions.BLN_ExpiresTimeBuffer__c)) && eventTriggered) {
                        this.eventTriggered = false;
                    }
                    if (calloutExecutedCounter < scopeSize && !eventTriggered && (expiresIn == null || oktaToken == null || expiresIn < Datetime.now().addSeconds(Integer.valueOf(calloutOptions.BLN_ExpiresTimeBuffer__c)))) {
                        this.eventTriggered = true;
                            BLN_OktaCallout__e eventOctaCallout = new BLN_OktaCallout__e(BLN_ServiceAppointmentId__c = currentScope[1]);
                            EventBus.publish(eventOctaCallout);
                            break;
                    } else if(calloutExecutedCounter < scopeSize && eventTriggered){
                        System.debug('BLN_HTTPCallOutToMuleSoft execute try break');
                        System.debug('BLN_HTTPCallOutToMuleSoft makeCalloutToMulesoft Vars '
                        + ' auth-'+ auth
                        + ' correlationId-'+ correlationId
                        + ' instanceUrl-'+ instanceUrl
                        + ' currentScope-'+ currentScope
                        + ' endPointMulesoft-'+ endPointMulesoft);
                        break;
                    }
                    else {
                        serviceAppointments.remove(0);
                        processedRecord = (Id)currentScope[1];
                        makeCalloutToMulesoft( auth, correlationId, instanceUrl, currentScope, endPointMulesoft);
                        calloutExecutedCounter++;
                    }

                }
                System.debug('BLN_HTTPCallOutToMuleSoft execute try end'); 
                System.debug('serviceAppointments.size() ->'+ serviceAppointments.size());
                System.debug('serviceAppointments String ->'+ serviceAppointments.toString());
                if (serviceAppointments.size() > 0 && eventTriggered && !Test.isRunningTest()) {
                    System.debug('BLN_HTTPCallOutToMuleSoft enqueueJob true'); 
                    System.enqueueJob(new BLN_HTTPCallOutToMuleSoft(serviceAppointments, eventTriggered), options);
                }
                if(serviceAppointments.size() > 0 && !eventTriggered && !Test.isRunningTest()){
                    System.debug('BLN_HTTPCallOutToMuleSoft enqueueJob false'); 
                    System.enqueueJob(new BLN_HTTPCallOutToMuleSoft(serviceAppointments, eventTriggered));
                }
            } catch (DmlException dmlx) {
                // Store Exception Logger Record
                System.debug('BLN_HTTPCallOutToMuleSoft DmlException'); 
                exceptionList.add(dmlx);
                listOfIntegrationLogs.addAll(BLN_ExceptionLogger.LogException(exceptionList, processedRecord, false, processedRecord));
                    System.enqueueJob(new BLN_HTTPCallOutToMuleSoft(serviceAppointments, eventTriggered));
            } catch (Exception ex) {
                // Store Exception Logger Record
                System.debug('BLN_HTTPCallOutToMuleSoft Exception'); 
                exceptionList.add(ex);
                listOfIntegrationLogs.addAll(BLN_ExceptionLogger.LogException(exceptionList, processedRecord, false, processedRecord));
                if (!Test.isRunningTest()) {
                    System.enqueueJob(new BLN_HTTPCallOutToMuleSoft(serviceAppointments, eventTriggered));
                }
            }
            if (!successServiceAppointments.isEmpty()) {
                System.debug('BLN_HTTPCallOutToMuleSoft successServiceAppointments'); 
                BLN_MuleCalloutFailureHelper.MuleCalloutSuccess(successServiceAppointments);
            }
            if (!failureServiceAppointments.isEmpty()) {
                System.debug('BLN_HTTPCallOutToMuleSoft failureServiceAppointments'); 
                BLN_MuleCalloutFailureHelper.addMuleCalloutFailure(failureServiceAppointments);
            }
            System.debug('BLN_HTTPCallOutToMuleSoft insert this.listOfIntegrationLogs'); 
            insert this.listOfIntegrationLogs;
        }
    }

    public static BLN_ServiceAppJSON createJsonBody(BLN_HTTPCallOutToMuleSoftHelper.ServiceAppointmentHelper currentCallout) {
        BLN_ServiceAppJSON.Data data = new BLN_ServiceAppJSON.Data();
        data.current = processSingleServiceAppointment(currentCallout.newServiceAppointment, CURRENT, currentCallout);
        data.previous = processSingleServiceAppointment(currentCallout.oldServiceAppointment, PREVIOUS, currentCallout);
        BLN_ServiceAppJSON jsonBody = new BLN_ServiceAppJSON();
        jsonBody.entityName = System.label.BLN_MuleEntityName;
        jsonBody.entityID = currentCallout.Id;
        jsonBody.eventType = System.label.BLN_Update;
        jsonBody.sourceSystem = System.label.BLN_sfdc;
        jsonBody.timestamp = System.Now();
        jsonBody.initialisedSystem = System.label.BLN_Update;
        jsonBody.data = data;
        return jsonBody;
    }
    
    private static BLN_ServiceAppJSON.Previous processSingleServiceAppointment(ServiceAppointment serviceAppointment2process, String whichSA, BLN_HTTPCallOutToMuleSoftHelper.ServiceAppointmentHelper currentScope) {
        String firstLegacyId;
        User userList;
        List<BLN_SFReasonFailureCodeMapping__mdt> failureReasons = getFailureReasons(serviceAppointment2process);

        if (currentScope.newUser != null && whichSA == CURRENT) {
            userList = currentScope.newUser;
            firstLegacyId = currentScope.newServiceResourceOracleId;
        }
        else if (currentScope.oldUser != null && whichSA == PREVIOUS) {
            userList = currentScope.oldUser;
            firstLegacyId = currentScope.oldServiceResourceOracleId;
        }

        BLN_ServiceAppJSON.Address addr = new BLN_ServiceAppJSON.Address();
        addr.addressLineOne = String.isNotBlank(serviceAppointment2process.street)?serviceAppointment2process.street:'';
        addr.addressPostalCode = String.isNotBlank(serviceAppointment2process.postalCode)?serviceAppointment2process.postalCode:'';

        BLN_ServiceAppJSON.AddressExtended addExt = new BLN_ServiceAppJSON.AddressExtended();
        addExt.addressRegion = String.isNotBlank(serviceAppointment2process.country)?serviceAppointment2process.country:'';
        addExt.addressDistrict = String.isNotBlank(currentScope.serviceTerritoryDistrict) ? currentScope.serviceTerritoryDistrict: '';
        addr.addressExtended = addExt;

        BLN_ServiceAppJSON.City city = new BLN_ServiceAppJSON.City();
        city.cityName = String.isNotBlank(serviceAppointment2process.city)?serviceAppointment2process.city:'';
        addr.city = city;

        BLN_ServiceAppJSON.Country country = new BLN_ServiceAppJSON.Country();
        country.countryName = String.isNotBlank(serviceAppointment2process.country)?serviceAppointment2process.country:'';
        addr.country = country;

        BLN_ServiceAppJSON.TaskTypeHeritage taskType = new BLN_ServiceAppJSON.TaskTypeHeritage();
        taskType.taskTypeName = String.isNotBlank(currentScope.workTypeName) ? currentScope.workTypeName : '';

        BLN_ServiceAppJSON.JobWorkOrderLineHeritage jobWOL = new BLN_ServiceAppJSON.JobWorkOrderLineHeritage();
        jobWOL.taskTypeHeritage = taskType;

        BLN_ServiceAppJSON.JobWorkOrderHeritage jWOH = new BLN_ServiceAppJSON.JobWorkOrderHeritage();
        jWOH.remedyJobWorkOrderId = String.isNotBlank(serviceAppointment2process.BLN_RemedyJobId__c)?serviceAppointment2process.BLN_RemedyJobId__c:'';

        BLN_ServiceAppJSON.JobAppointmentHeritage jAHer = new BLN_ServiceAppJSON.JobAppointmentHeritage();
        jAHer.remedyJobAppointmentId = String.isNotBlank(serviceAppointment2process.BLN_RemedyTaskId__c)?serviceAppointment2process.BLN_RemedyTaskId__c:'';

        List<BLN_ServiceAppJSON.JobAppointmentHeritage> jAHerList = new List<BLN_ServiceAppJSON.JobAppointmentHeritage>();
        jAHerList.add(JAHer);

        BLN_ServiceAppJSON.JobAppointmentStatus jobAppStatus = new BLN_ServiceAppJSON.JobAppointmentStatus();
        jobAppStatus.jobAppointmentStatusName = String.isNotBlank(serviceAppointment2process.Status)?serviceAppointment2process.Status:'';

        BLN_ServiceAppJSON.Location loc = new BLN_ServiceAppJSON.Location();
        loc.companyNav = String.isNotBlank(System.label.BLN_CompanyNav)?System.label.BLN_CompanyNav:'';

        BLN_ServiceAppJSON.LocationAddress locAdd = new BLN_ServiceAppJSON.LocationAddress();
        locAdd.address = addr;

        List<BLN_ServiceAppJSON.LocationAddress> locationAddress = new List<BLN_ServiceAppJSON.LocationAddress>();
        locationAddress.add(locAdd);
        loc.locationAddress = locationAddress;

        BLN_ServiceAppJSON.PartyIdentification pI = new BLN_ServiceAppJSON.PartyIdentification();
        if(userList != null){
            pI.partyIdentificationId = String.isNotBlank(firstLegacyId)?firstLegacyId:'';
        }
        else{
            pI.partyIdentificationId = '';
        }

        List<BLN_ServiceAppJSON.PartyIdentification> partyIdentification = new List<BLN_ServiceAppJSON.PartyIdentification>();
        partyIdentification.add(pI);

        BLN_ServiceAppJSON.Party party = new BLN_ServiceAppJSON.Party();
        party.partyIdentification = partyIdentification;

        BLN_ServiceAppJSON.Person person = new BLN_ServiceAppJSON.Person();
        if (userList != null) {
            person.firstName = String.isNotBlank(userList.FirstName)?userList.FirstName:'';
            person.lastName = String.isNotBlank(userList.LastName)?userList.LastName:'';
            person.salutation = String.isNotBlank(userList.Title)?userList.Title:'';
        }
        else {
            person.firstName = '';
            person.lastName = '';
            person.salutation = '';
        }
        person.party = party;

        BLN_ServiceAppJSON.PersonRole personRole = new BLN_ServiceAppJSON.PersonRole();
        personRole.person = person;

        BLN_ServiceAppJSON.Worker worker = new BLN_ServiceAppJSON.Worker();
        worker.personRole = personRole;

        BLN_ServiceAppJSON.WorkerShift wShift = new BLN_ServiceAppJSON.WorkerShift();
        wShift.worker = worker;

        List<BLN_ServiceAppJSON.JobAppointmentWorkerAssignment> jobAppointmentWorkerAssignmentList = new List<BLN_ServiceAppJSON.JobAppointmentWorkerAssignment>();
        BLN_ServiceAppJSON.JobAppointmentWorkerAssignment jobAppWA = new BLN_ServiceAppJSON.JobAppointmentWorkerAssignment();
        jobAppWA.workerShift = wShift;
        jobAppointmentWorkerAssignmentList.add(jobAppWA);

        List<BLN_ServiceAppJSON.JobAppointment> jobAppList = new List<BLN_ServiceAppJSON.JobAppointment>();
        BLN_ServiceAppJSON.JobAppointment jobApp = new BLN_ServiceAppJSON.JobAppointment();
        jobApp.JobAppointmentHeritage = jAHerList;
        jobApp.jobAppointmentPriority = currentScope.priority;
        jobApp.duration = Integer.valueOf(serviceAppointment2process.Duration*60);
        jobApp.jobAppointmentId = String.isNotBlank(serviceAppointment2process.Id)?serviceAppointment2process.Id:'';
        jobApp.jobAppointmentStatus = jobAppStatus;
        if (whichSA == CURRENT) {
            jobApp.failureReasonCodeId = failureReasons.size()> 0 ?String.valueOf(Integer.valueOf(failureReasons[0].BLN_RemedyFailureCode__c)):'';
        } else if (whichSA == PREVIOUS) {
            jobApp.failureReasonCodeId = String.isNotBlank(serviceAppointment2process.BLN_FailureReason__c)?serviceAppointment2process.BLN_FailureReason__c:'';
        }

        jobApp.appointmentDateTime = BLN_FSLUtility.formatGMT(serviceAppointment2process.BLN_RemedyOpenDate__c);
        jobApp.earliestStartDateTime = BLN_FSLUtility.formatGMT(serviceAppointment2process.EarliestStartTime);
        jobApp.latestCompletionDueDate = BLN_FSLUtility.formatGMT(serviceAppointment2process.DueDate);
        jobApp.scheduledStartDateTime = BLN_FSLUtility.formatGMT(serviceAppointment2process.SchedStartTime);
        jobApp.scheduledCompletionDateTime = BLN_FSLUtility.formatGMT(serviceAppointment2process.SchedEndTime);
        jobApp.estimatedArrivalWindowStartDateTime = BLN_FSLUtility.formatGMT(serviceAppointment2process.ArrivalWindowStartTime);
        jobApp.estimatedArrivalWindowEndDateTime = BLN_FSLUtility.formatGMT(serviceAppointment2process.ArrivalWindowEndTime);
        jobApp.location = loc;
        jobApp.jobAppointmentWorkerAssignment = jobAppointmentWorkerAssignmentList;
        jobAppList.add(jobApp);

        List<BLN_ServiceAppJSON.JobWorkOrderLine> jWOLList = new List<BLN_ServiceAppJSON.JobWorkOrderLine>();

        BLN_ServiceAppJSON.JobWorkOrderLine jWOL = new BLN_ServiceAppJSON.JobWorkOrderLine();
        jWOL.jobWorkOrderLineHeritage = jobWOL;
        jWOL.jobAppointment = jobAppList;
        jWOLList.add(JWOL);

        List<BLN_ServiceAppJSON.JobWorkOrder> jWRList = new List<BLN_ServiceAppJSON.JobWorkOrder>();
        BLN_ServiceAppJSON.JobWorkOrder jWR = new BLN_ServiceAppJSON.JobWorkOrder();
        jWR.jobWorkOrderId = String.isNotBlank(serviceAppointment2process.BLN_WorkOrderNumber__c)?serviceAppointment2process.BLN_WorkOrderNumber__c:'';
        jWR.jobWorkOrderHeritage = jWOH;
        jWR.jobWorkOrderLine = jWOLList;
        jWRList.add(jWR);
        BLN_ServiceAppJSON.SalesOpportunity salesOpp = new BLN_ServiceAppJSON.SalesOpportunity();
        salesOpp.jobWorkOrder = jWRList;

        BLN_ServiceAppJSON.MotoristSalesOpportunity motor = new BLN_ServiceAppJSON.MotoristSalesOpportunity();
        motor.salesOpportunity = salesOpp;

        BLN_ServiceAppJSON.Previous toReturn = new BLN_ServiceAppJSON.Previous();
        toReturn.motoristSalesOpportunity = motor;

        return toReturn;
    }

    private static List<BLN_SFReasonFailureCodeMapping__mdt> getFailureReasons (ServiceAppointment serviceAppointment) {
        List<BLN_SFReasonFailureCodeMapping__mdt> failureCodes = BLN_SFReasonFailureCodeMapping__mdt.getAll().values();
        List<BLN_SFReasonFailureCodeMapping__mdt> toReturn = new List<BLN_SFReasonFailureCodeMapping__mdt>();

        for (BLN_SFReasonFailureCodeMapping__mdt failureCode : failureCodes ) {
            if( failureCode.BLN_SFSReasonLevel1__c == serviceAppointment.BLN_FailureReason__c && failureCode.BLN_SFSReasonLevel2__c == serviceAppointment.BLN_SubFailureReason__c) {
                toReturn.add(failureCode);
            }
        }

        return toReturn;
    }

    private  String makeCalloutToMulesoft(String auth, String correlationId, String instanceUrl, List<String> scope,
            String endPointMulesoft) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        System.debug('makeCalloutToMulesoft called');
        System.debug('scope:'+scope);
        System.debug('correlationId:'+correlationId);
        System.debug('instanceUrl:'+instanceUrl);
        System.debug('endPointMulesoft:'+endPointMulesoft);
        req.setMethod('POST');
        req.setHeader('Authorization', auth);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('X-CORRELATION-ID', correlationId);
        if(String.isNotBlank(scope[2])){
            req.setHeader('country-code', scope[2]);
        }
        req.setHeader('destination', instanceUrl);
        req.setHeader('destinationType', 'Topic');
        req.setEndpoint(endPointMulesoft);

        req.setBody(scope[0]);
        req.setTimeout(30000);
        DateTime t1 = System.Now();
        HttpResponse res;
        if (!Test.isRunningTest()) {
         res = http.send(req);
        }
        DateTime t2 = System.Now();

        Decimal decSec2 = t2.getTime();
        Decimal decSec1 = t1.getTime();
        Decimal miliDiff = decsec2 - decsec1;
        Decimal secDiff = miliDiff/1000;
        Decimal rounded = secDiff.setScale(3);
        String secondsGap = String.valueOf(rounded);
        this.listOfIntegrationLogs.add(BLN_IntegrationLogger.createIntegrationLoggers(secondsGap, res, req, (Id)scope[1], auth, instanceUrl, System.label.BLN_TargetSystemMulesoft, scope[2], true));
        if (res.getStatusCode() == 429) {
            this.failureServiceAppointments.add(new ServiceAppointment(Id = (Id)scope[1], Status = scope[3]));
        } else if (res.getStatusCode() == 201 || res.getStatusCode() == 200){
            this.successServiceAppointments.add(new ServiceAppointment(Id = (Id)scope[1], Status = scope[3]));
        }
        return String.valueOf(res.getStatusCode());
    }
}