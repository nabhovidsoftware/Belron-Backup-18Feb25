/**
 * @description : Apex class for making callouts to Mulesoft to send Timesheet data.
 * @author: PwC India
 * @CreatedDate: 03/10/2024
 */
public class BLN_TechnicianTimesheetService implements Queueable, Database.AllowsCallouts {

    private static final String INSTANCE_URL = System.label.BLN_MulesoftKronosQueue; // Destination URL
    private static final String OKTA_INTEGRATION_ENDPOINT = 'callout:OKTAIntegration';
    private static final String CONTENT_TYPE = 'application/json';
    private static final String JMSX_GroupID = '1';
    private static final String BUSINESS_GROUP = 'Customer';
    private static final String DESTINATION_TYPE = 'Queue';

    private List<String> timesheetIds; // Stores the list of timesheet record IDs
    private String accessToken; // OAuth token for authentication with external services
    private String authHeader; // Authorization header for the request
    private String correlationId; // Unique identifier for tracking requests
    public static Integer expiresIn; // Token expiry duration
    private static List<TimeSheetEntry> timesheetEntries;

    /**
     * @InvocableMethod annotation allows this method to be invoked from Process Builder or Flow.
     * @description Queues the job for sending timesheet data.
     * @param timesheetIds List of Timesheet IDs to send.
     */
    @InvocableMethod
    public static void sendTimesheet(List<String> timesheetIds) {
        if (timesheetIds == null || timesheetIds.isEmpty()) {
            return;
        }
        try {
            System.enqueueJob(new BLN_TechnicianTimesheetService(timesheetIds, null));
        } catch (Exception ex) {
            BLN_ExceptionLogger.logExceptionRequest(new list<Exception>{ex},'synctimesheet',timesheetIds[0]);
        }
    }

    /**
     * Constructor for initializing BLN_TechnicianTimesheetService instance.
     * @param timesheetIds List of Timesheet IDs.
     * @param accessToken OAuth access token.
     */
    public BLN_TechnicianTimesheetService(List<String> timesheetIds, String accessToken) {
        this.timesheetIds = timesheetIds;
        this.accessToken = accessToken;
    }

    /**
     * Executes the queued job and makes the callout to Mulesoft.
     * @param context QueueableContext parameter.
     */
    public void execute(QueueableContext context) {
        
        try {
            fetchAccessToken();
            sendTimesheetData(); 
        } catch (Exception ex) {
            BLN_ExceptionLogger.logExceptionRequest(new list<Exception>{ex},'synctimesheet',timesheetIds[0]);
        }       
    }

    /**
     * Fetches the OAuth access token from Okta for authentication.
     */
    private void fetchAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(OKTA_INTEGRATION_ENDPOINT);
        req.setBody(System.label.BLN_OktaIntegrationBody);
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200 && res.getBody() != null) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            accessToken = (String) responseMap.get('access_token');
            authHeader = System.label.BLN_Bearer + ' ' + accessToken;
        }
        
    }

    /**
     * Sends timesheet data to Mulesoft.
     */
    private void sendTimesheetData() {
        correlationId = generateCorrelationId();
        HttpRequest req = prepareHttpRequest();
        Http http = new Http();
        HttpResponse res = http.send(req);


        logIntegration(req, res);
        
    }

    /**
     * Prepares the HTTP request to send timesheet data.
     * @return HttpRequest object configured for the API call.
     */
    private HttpRequest prepareHttpRequest() {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(System.Label.BLN_MulesoftEndpoint);
        req.setHeader('Authorization', authHeader);
        req.setHeader('Content-Type', CONTENT_TYPE);
        req.setHeader('X-CORRELATION-ID', correlationId);
        req.setHeader('country-code', 'UK');
        req.setHeader('destination', INSTANCE_URL);
        req.setHeader('destinationType', DESTINATION_TYPE);
        req.setHeader('legacyBroker', 'false');
        req.setHeader('businessGroup', BUSINESS_GROUP);
        req.setHeader('JMSXGroupID',JMSX_GroupID);

        TimesheetPayloadWrapper payload = buildPayload();
        req.setBody(JSON.serialize(payload));

        return req;
    }

    /**
     * Builds the payload for the timesheet data.
     * @return TimesheetPayloadWrapper object.
     */
    private TimesheetPayloadWrapper buildPayload() {
        timesheetEntries = fetchTimesheetEntries();
        TimesheetPayloadWrapper payload = new TimesheetPayloadWrapper();
        payload.entityName = 'Timesheet';
        payload.entityID = timesheetEntries[0].TimeSheet.Id;
        payload.eventType = 'Create';
        payload.sourceSystem = 'SFDC';
        payload.timestamp = generateTimestamp();
        payload.initialisedSystem = 'SFDC';

        List<TimesheetOuter> timesheetOuterList = new List<TimesheetOuter>();

        for (TimeSheetEntry tse : timesheetEntries) {
            TimesheetOuter tsOuter = new TimesheetOuter();
            tsOuter.person = mapTimesheetEntryToPerson(tse);
            timesheetOuterList.add(tsOuter);
        }

        CurrentTimesheet currentTimesheet = new CurrentTimesheet();
        currentTimesheet.timesheet = timesheetOuterList;

        TimesheetData data = new TimesheetData();
        data.current = currentTimesheet;
        payload.data = data;

        return payload;
    }

    /**
     * Maps a TimeSheetEntry to the Person object required in the payload.
     * @param tse TimeSheetEntry record.
     * @return Person object.
     */
    private Person mapTimesheetEntryToPerson(TimeSheetEntry tse) {
        WorkerTimesheetLine workerTimesheetLine = new WorkerTimesheetLine();
        workerTimesheetLine.workerId = tse.TimeSheet.ServiceResource.BLN_OracleEmployeeId__c;
        workerTimesheetLine.workerTimesheetLineStartDatetime = tse.StartTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        workerTimesheetLine.workerTimesheetLineEndDatetime = (tse.EndTime != null) ? tse.EndTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') : null;
        workerTimesheetLine.workerTimesheetLineStatusTypeWorkerTimesheetLineStatusTypeId = tse.BLN_ShiftStatus__c;
        workerTimesheetLine.lastModifiedDate = tse.LastModifiedDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');

        Worker worker = new Worker();
        worker.workerTimesheetLine = new List<WorkerTimesheetLine>{workerTimesheetLine};

        Person person = new Person();
        person.worker = worker;
        person.partyIdentification = new List<PartyIdentification>{
            new PartyIdentification(tse.TimeSheet.ServiceResource.BLN_OracleEmployeeId__c, 'Workday Employee ID')
        };

        return person;
    }

    /**
     * Fetches the TimesheetEntry records based on the provided timesheetIds.
     * @return List of TimeSheetEntry records.
     */
    private List<TimeSheetEntry> fetchTimesheetEntries() {
        return [SELECT Id, BLN_ShiftStatus__c, Status, StartTime, EndTime, LastModifiedDate,
                TimeSheet.ServiceResource.BLN_OracleEmployeeId__c,TimeSheet.Id
                FROM TimeSheetEntry WHERE Id IN :timesheetIds];
    }

    /**
     * Logs the integration request and response for audit purposes.
     * @param req HttpRequest object sent.
     * @param res HttpResponse object received.
     */
    private void logIntegration(HttpRequest req, HttpResponse res) {

        String headerString = '';
        for (String key : res.getHeaderKeys()) {
            headerString += key + ': ' + res.getHeader(key) + '\n';
        }

        List<BLN_IntegrationLogger__c> intLogList = new List<BLN_IntegrationLogger__c>();
        BLN_IntegrationLogger__c logger = new BLN_IntegrationLogger__c();
        logger.BLN_RequestBody__c = req.getBody();
        logger.BLN_RequestMethod__c = req.getMethod();
        logger.BLN_RequestEndPoint__c = req.getEndpoint();
        logger.BLN_ResponseHeaders__c = headerString;
        logger.BLN_ResponseBody__c = res.getBody();
        logger.BLN_RecordId__c = timesheetEntries[0].Id;
        logger.BLN_CorrelationId__c = correlationId;
        logger.BLN_ResponseStatus__c = String.valueOf(res.getStatus());
        logger.BLN_ResponseStatusCode__c = String.valueOf(res.getStatusCode());
        logger.BLN_TargetSystem__c = System.label.BLN_TargetSystemMulesoft;
        intLogList.add(logger);

        BLN_IntegrationLogger.logRequest(intLogList);
    }

    /**
     * Generates a random correlation ID in UUID format.
     * @return String UUID as correlation ID.
     */
    public static String generateCorrelationId() {
        Blob blobKey = Crypto.GenerateAESKey(128);
        String hexKey = EncodingUtil.ConvertTohex(blobKey);
        return hexKey.substring(0, 8) + '-' + hexKey.substring(8, 12) + '-' +
               hexKey.substring(12, 16) + '-' + hexKey.substring(16, 20) + '-' +
               hexKey.substring(20);
    }


    /**
     * Generates a timestamp in the required format for the request.
     * @return String timestamp.
     */
    public static String generateTimestamp() {
        String currentDateTime = System.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSSSSZ');
        String last2Chars = currentDateTime.right(2);
        currentDateTime = currentDateTime.removeEnd(last2Chars);
        return currentDateTime + ':' + last2Chars;
    }

    // Payload Wrapper Classes for Timesheet Data
    public class TimesheetPayloadWrapper {
        public String entityName {get; set;}
        public String entityID {get; set;}
        public String eventType {get; set;}
        public String sourceSystem {get; set;}
        public String timestamp {get; set;}
        public String initialisedSystem {get; set;}
        public TimesheetData data {get; set;}
    }

    public class TimesheetData {
        public CurrentTimesheet current {get; set;}
    }

    public class CurrentTimesheet {
        public List<TimesheetOuter> timesheet {get; set;}
    }

    public class TimesheetOuter {
        public Person person {get; set;}
    }

    public class Person {
        public List<PartyIdentification> partyIdentification {get; set;}
        public Worker worker {get; set;}
    }

    public class Worker {
        public List<WorkerTimesheetLine> workerTimesheetLine {get; set;}
    }

    public class WorkerTimesheetLine {
        public String workerId {get; set;}
        public String workerTimesheetLineStartDatetime {get; set;}
        public String workerTimesheetLineStatusTypeWorkerTimesheetLineStatusTypeId {get; set;}
        public String workerTimesheetLineEndDatetime {get; set;}
        public String lastModifiedDate {get; set;}
    }

    public class PartyIdentification {
        public String partyIdentificationNum {get; set;}
        public String partyIdentificationTypeName {get; set;}

        public PartyIdentification(String num, String typeName) {
            this.partyIdentificationNum = num;
            this.partyIdentificationTypeName = typeName;
        }
    }
}