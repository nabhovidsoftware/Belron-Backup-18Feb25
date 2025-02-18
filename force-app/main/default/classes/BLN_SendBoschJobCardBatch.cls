/**@description : This batch class handles the data sent to Mulesoft-Bosch
*  @author: PwC India
*  @Story: FOUK-5582
*  @CreatedDate: 13/03/2024
*/
public class BLN_SendBoschJobCardBatch implements Database.Batchable<sObject>,  Database.AllowsCallouts, Schedulable{
    public static Integer expiresIn;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        string statusScheduled = System.label.BLN_ScheduledStatus;
        string statusDispatched = System.label.BLN_DispatchedStatus;
        string statusOpen = 'None';
        
        Datetime dateBegins = System.now();
        Time endTime = Time.newInstance(23, 59, 59, 0);
        DateTime dateEnds = DateTime.newInstance(system.today(), endTime);
        Boolean isBoschJobCardSent = False;

        String query = 'Select Id, BLN_WorkOrderLineItem__c, BLN_Vehicle__c, BLN_Vehicle__r.BLN_VehicleRegNumber__c , BLN_Vehicle__r.BLN_MakeOfVehicle__c, BLN_Vehicle__r.BLN_ModelOfVehicle__c, BLN_Vehicle__r.BLN_VIN__c, AccountId, Account.FirstName, Account.LastName, BLN_IsBoschJobCardSent__c from ServiceAppointment where (((Status = :statusOpen or Status = :statusScheduled or Status = :statusDispatched) and ArrivalWindowStartTime >= :dateBegins and ArrivalWindowStartTime <= :dateEnds) or ((Status = :statusScheduled or Status = :statusDispatched) and SchedStartTime >= :dateBegins and SchedStartTime <= :dateEnds)) and BLN_IsBoschJobCardSent__c = :IsBoschJobCardSent and ServiceTerritory.BLN_ConsiderforR1__c = false';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<ServiceAppointment> records){
        DateTime expiresIn;
        String oktaToken;
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.OKTAIdP');
        expiresIn = (DateTime)orgPart.get('OKTATokenExpirationDateTime');
        oktaToken = (String)orgPart.get('OKTAAccessToken');

        if(expiresIn == null || oktaToken == '' || expiresIn <= Datetime.now() || Test.isRunningTest()){
            setOktaAccessToken();
            expiresIn = (DateTime)orgPart.get('OKTATokenExpirationDateTime');
            oktaToken = (String)orgPart.get('OKTAAccessToken');
        }
        if(oktaToken != '' && expiresIn > Datetime.now()){
            System.enqueueJob(new BLN_SendBoschJobCard(records, oktaToken, false));
        }
    }

    public void finish(Database.BatchableContext bc){
        try{
            AsyncApexJob job = new AsyncApexJob();
            job = [SELECT Id, JobType, ApexClassId, Status, NumberOfErrors, MethodName, CompletedDate FROM AsyncApexJob WHERE Id =: bc.getJobId()];
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
    }

    public void execute(SchedulableContext ctx) {
        integer batchSize = 200;
        BLN_SendBoschJobCardBatch p = new BLN_SendBoschJobCardBatch();
        database.executeBatch(p,batchSize);
    }

    public static void setOktaAccessToken(){
        List<Exception> exceptionList = new List<Exception>();
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setMethod('POST');
            req.setEndpoint('callout:OKTAIntegration');
            req.setBody(System.label.BLN_OktaIntegrationBody);
            DateTime t1 = System.Now();
            res = http.send(req);
            DateTime t2 = System.Now();
            
            Decimal decSec2 = t2.getTime();
            Decimal decSec1 = t1.getTime();
            Decimal miliDiff = decsec2 - decsec1;
            Decimal secDiff = miliDiff/1000;
            Decimal rounded = secDiff.setScale(3);
            String secondsGap = String.valueOf(rounded);
            
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String accessToken;
            Datetime expireTime;
            
            if((res.getstatusCode() == 200 || res.getstatusCode() == 201) && res.getbody() != null){
                accessToken = (String)results.get('access_token');
                expiresIn = (Integer)results.get('expires_in');
                Integer sec = expiresIn - 60;            
                DateTime now = DateTime.now();
                expireTime = now.addSeconds(sec);
            }
            
            String auth = 'Bearer ' + accessToken;
            String instanceUrl = System.label.BLN_CurrentOrgInitials;
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.OKTAIdP');
            if(String.isNotBlank(accessToken)){
                orgPart.put('OKTAAccessToken', accessToken);
                orgPart.put('OKTATokenExpirationDateTime', expireTime);
            }
            
            if((res.getstatusCode() == 200 || res.getstatusCode() == 201) && res.getbody() != null){
                // Store Integration Logger Record
                String correlationId = BLN_SendBoschJobCard.randomCodeGenerator();
                List<BLN_IntegrationLogger__c> intLogList = new List<BLN_IntegrationLogger__c>();
                BLN_IntegrationLogger__c integrat = new BLN_IntegrationLogger__c();
                integrat.BLN_APICallInSeconds__c = secondsGap;
                integrat.BLN_CorrelationId__c = correlationId;
                integrat.BLN_RequestBody__c = req.getBody();
                integrat.BLN_RequestEndPoint__c = req.getEndpoint();
                integrat.BLN_RequestHeaders__c = '';
                integrat.BLN_RequestIssuedBy__c = UserInfo.getUserId();
                integrat.BLN_RequestMethod__c = req.getMethod();
                integrat.BLN_RequestSent__c = System.today();
                integrat.BLN_ResponseBody__c = res.getBody();
                integrat.BLN_ResponseHeaders__c = BLN_SendBoschJobCard.resHeaders(res);
                integrat.BLN_ResponseReceived__c = System.today();
                integrat.BLN_ResponseStatus__c = res.getStatus();
                integrat.BLN_ResponseStatusCode__c = ''+res.getStatusCode();
                integrat.BLN_TargetSystem__c = System.label.BLN_TargetSystemOkta;
                intLogList.add(integrat);
                
                BLN_IntegrationLogger.logRequest(intLogList);
            }
        }
        catch (Exception ex) {
            // Store Exception Logger Record
            BLN_ExceptionLogger.captureException(ex);
        }
    }
}