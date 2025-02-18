/**@description : This apex class is called from BLN_SendBoschJobCardBatch for making callout to Mulesoft-Bosch
*  @author: PwC India
*  @Story: FOUK-5582
*  @CreatedDate: 13/03/2024
*/
public class BLN_SendBoschJobCard implements Queueable, Database.AllowsCallouts{
    List<ServiceAppointment> sAList;
    String accessToken;
    String auth;
    String instanceUrl;
    String correlationId;
    String reqHeader;
    Boolean fromFlow;
    public static Integer expiresIn;

    @InvocableMethod
    public static void sendBoschJobCardFromFlow (List<Id> sAListId)
    {try{
        if(sAListId.isEmpty())
        {
            return;
        }
        List<ServiceAppointment> sAList = [Select Id, BLN_WorkOrderLineItem__c, BLN_Vehicle__c, BLN_Vehicle__r.BLN_VehicleRegNumber__c , BLN_Vehicle__r.BLN_MakeOfVehicle__c, BLN_Vehicle__r.BLN_ModelOfVehicle__c, BLN_Vehicle__r.BLN_VIN__c, AccountId, Account.FirstName, Account.LastName, BLN_IsBoschJobCardSent__c from ServiceAppointment where Id = :sAListId[0] WITH SECURITY_ENFORCED];

        Set<String> woliId = new Set<String>();
        
        for (ServiceAppointment sARecord : sAList) {
            woliId.add(sARecord.BLN_WorkOrderLineItem__c);
        }

        List<WorkOrderLineItem> woliRecords = [SELECT Id, WorkTypeId, ServiceTerritory.BLN_GUID__c, ServiceTerritory.BLN_MDMId__c, (SELECT product2Id FROM productsRequired) FROM WorkOrderLineItem WHERE Id IN :woliId WITH SECURITY_ENFORCED];

        Set<String> productId = new Set<String>();

        for(WorkOrderLineItem woliRec: woliRecords)
        {
            for(productRequired pr: woliRec.productsRequired){
                productId.add(pr.product2Id);
            }
        }
        List<BLN_RecalibrationJobCard__c> recalRecords = [SELECT Id, BLN_Product__c, BLN_SortOrder__c, BLN_TaskName__c, BLN_TaskType__c FROM BLN_RecalibrationJobCard__c WHERE BLN_Product__c IN :productId WITH SECURITY_ENFORCED];
        if(recalRecords != null && !recalRecords.isEmpty()){
            System.enqueueJob(new BLN_SendBoschJobCard(sAList, null, true));
        }
    } catch (Exception ex) {BLN_ExceptionLogger.captureException(ex); }
    }
    
    public BLN_SendBoschJobCard (List<ServiceAppointment> sAList, String accessToken, Boolean fromFlow){
        this.sAList = sAList;
        this.accessToken = accessToken;
        this.fromFlow = fromFlow;
    }
    
    public void execute(QueueableContext context) {
        if(fromFlow == true)
        {
            try{
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                req.setMethod('POST');
                req.setEndpoint('callout:OKTAIntegration');
                req.setBody(System.label.BLN_OktaIntegrationBody);
                // DateTime t1 = System.Now();
                res = http.send(req);
                
                if((res.getstatusCode() == 200 || res.getstatusCode() == 201) && res.getbody() != null){
                    Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    accessToken = (String)results.get('access_token');
                    }
            }
            catch (Exception ex) {
                // Store Exception Logger Record
                BLN_ExceptionLogger.captureException(ex);
            }
        }
        try{
            HttpResponse res;
            // auth = System.label.BLN_Bearer + ' ' + accessToken;
            instanceUrl = System.label.BLN_BoschMulesoftDestination;
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_BoschJobCard);
            Map<String,String> headerMap = new Map<String,String>();
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+accessToken);
            for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
                headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
            }
            for(String headerKey : headerMap.keyset()){
                req.setHeader(headerKey, headerMap.get(headerKey)); 
            }
            
            correlationId = randomCodeGenerator(); 
            req.setHeader('X-CORRELATION-ID', correlationId);            
            req.setMethod(calloutDetails.BLN_Method__c);
            // req.setMethod('POST');
            // req.setHeader(System.label.BLN_AuthorizationLabel, auth);
            // req.setHeader('Content-Type', 'application/json');
            // req.setHeader('country-code', 'UK');
            // req.setHeader('destination', instanceUrl);
            // req.setHeader('destinationType', 'Topic');
            // req.setHeader('legacyBroker', 'false');
            // req.setHeader('businessGroup', 'Customer');
            
            // reqHeader =	'Authorization: ' + auth +
            //             ' Content-Type: application/json' +
            //             ' X-CORRELATION-ID: ' + correlationId +
            //             ' country-code: ' + 'UK' +
            //             ' destination: '  + instanceUrl +
            //             ' destinationType: Topic'+
            //             ' legacyBroker: false' +
            //             ' businessGroup: Customer' ;   
            reqHeader = calloutDetails.BLN_Headers__c + ' X-CORRELATION-ID: ' + correlationId + 'Authorization: ' + auth;
            
            // String endPoint = System.label.BLN_MulesoftEndpoint;
            String endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c;
            req.setEndpoint(endPoint);

            // Start Prepare JSON for Request Body
            PayloadWrapper payLoad = new PayloadWrapper();
            payLoad.entityName  = System.Label.BLN_BoschCalloutEntityName; //'Jobcards-tst';
            payLoad.entityID = correlationId;
            payLoad.eventType = System.Label.BLN_Create;
            payLoad.sourceSystem = System.Label.BLN_SFDCLabel;
            payLoad.timestamp = makeTimeStamp();//'2024-02-23T06:01:18.9117977-04:00';
            payLoad.initialisedSystem = System.Label.BLN_SFDCLabel;
            List<JobcardsOuter> jobcardsOuterList = new List<JobcardsOuter>();

            //Loop SA List to collect woliid in set
            Set<String> woliId = new Set<String>();
            List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
            Map<String, ServiceAppointment> mapWoliSA = new Map<String, ServiceAppointment>();
            for (ServiceAppointment sARecord : sAList) {
                woliId.add(sARecord.BLN_WorkOrderLineItem__c);
                mapWoliSA.put((String) sARecord.BLN_WorkOrderLineItem__c, sARecord);
            }

            //Query Woli for product List
            ////FOUK-9031 Added ServiceTerritory.BLN_GUID__c, ServiceTerritory.BLN_MDMId__c to SOQL
            List<WorkOrderLineItem> woliRecords = [SELECT Id, WorkTypeId, ServiceTerritory.BLN_GUID__c, ServiceTerritory.BLN_MDMId__c,
                                                        (SELECT product2Id, BLN_WOLI__c FROM productsRequired) 
                                                    FROM WorkOrderLineItem 
                                                    WHERE Id IN :woliId 
                                                    WITH SECURITY_ENFORCED];
            Map<String, List<String>> mpProd = new Map<String, List<String>>();
            Map<String, WorkOrderLineItem> mapWOLI = new Map<String, WorkOrderLineItem>();
            Set<String> productId = new Set<String>();
            Map<String, String> mapOfWOLIIdAndWorkshopId = new Map<String, String>();
            Map<String, String> prodReqWoliMap = new Map<String, String>();
            Map<String, String> prodReqProdMap = new Map<String, String>();
            for(WorkOrderLineItem woliRec: woliRecords)
            {
                List<String> tpProdId = new List<String>();
                for(productRequired pr: woliRec.productsRequired){
                    prodReqWoliMap.put(pr.Id, pr.BLN_WOLI__c);
                    prodReqProdMap.put(pr.Id, pr.product2Id);
                    tpProdId.add(pr.product2Id);
                    productId.add(pr.product2Id);
                }
                if(tpProdId.size()>0){
                    mpProd.put(woliRec.Id,tpProdId);
                    mapWOLI.put(woliRec.id,woliRec);
                }
                if(woliRec.ServiceTerritory.BLN_GUID__c != null){
                    mapOfWOLIIdAndWorkshopId.put(woliRec.Id,woliRec.ServiceTerritory.BLN_GUID__c);
                }else if(woliRec.ServiceTerritory.BLN_MDMId__c !=null){
                    mapOfWOLIIdAndWorkshopId.put(woliRec.Id,woliRec.ServiceTerritory.BLN_MDMId__c);
                }
            }
            //Query Recalibration Job Cards from Extracted products
            List<BLN_RecalibrationJobCard__c> recalRecords = [SELECT Id, BLN_Product__c, BLN_SortOrder__c, BLN_TaskName__c, BLN_TaskType__c FROM BLN_RecalibrationJobCard__c WHERE BLN_Product__c IN :productId WITH SECURITY_ENFORCED];
            
            if(recalRecords == null || recalRecords.isEmpty())
            {//if no recalibration job cards in system
                return;
            }
            
            //Create Map <product ID, list of Recal Jobs>
            Map<String, List<BLN_RecalibrationJobCard__c>> mpProductRecalJob = new Map<String, List<BLN_RecalibrationJobCard__c>>();
            for(BLN_RecalibrationJobCard__c rjc: recalRecords)
            {
                List<BLN_RecalibrationJobCard__c> tempRecalList = new List<BLN_RecalibrationJobCard__c>();
                
                if(mpProductRecalJob.containsKey((String)rjc.BLN_Product__c))
                {
                    tempRecalList =  mpProductRecalJob.get(rjc.BLN_Product__c);
                    tempRecalList.add(rjc);
                    mpProductRecalJob.put((String)rjc.BLN_Product__c, tempRecalList);
                }
                else
                {
                    mpProductRecalJob.put((String)rjc.BLN_Product__c, new List<BLN_RecalibrationJobCard__c>{rjc});
                }
            }
            //Loop on product req
            for(String prodRq: prodReqWoliMap.keySet()) 
            {
                String mapWoliLoop = prodReqWoliMap.get(prodRq);
                JobcardsOuter jBOutter = new JobcardsOuter();
                Vehicle vehicle = new Vehicle();
                CustomerWrapper customer = new CustomerWrapper();
                Jobcards jobcards = new Jobcards();
                list<taskWrapper> tasks = new list<taskWrapper>();
                
                if(mapWoliSA.containsKey(mapWoliLoop)){
                    ServiceAppointment sARecord = mapWoliSA.get(mapWoliLoop);
                    if(sARecord.BLN_Vehicle__c!=null){
                        vehicle.licensePlate = sARecord.BLN_Vehicle__r.BLN_VehicleRegNumber__c!=null ? sARecord.BLN_Vehicle__r.BLN_VehicleRegNumber__c : '';
                        vehicle.make = sARecord.BLN_Vehicle__r.BLN_MakeOfVehicle__c!=null ? sARecord.BLN_Vehicle__r.BLN_MakeOfVehicle__c : '';
                        vehicle.model = sARecord.BLN_Vehicle__r.BLN_ModelOfVehicle__c!=null ? sARecord.BLN_Vehicle__r.BLN_ModelOfVehicle__c : '';
                        vehicle.vin = sARecord.BLN_Vehicle__r.BLN_VIN__c!=null ? sARecord.BLN_Vehicle__r.BLN_VIN__c : '';
                    }
                    else{
                        vehicle.licensePlate = '';
                        vehicle.make = '';
                        vehicle.model = '';
                        vehicle.vin = '';
                    }
                    if(sARecord.AccountId!=null){
                        customer.firstName = sARecord.Account.FirstName!=null ? sARecord.Account.FirstName : '';
                        customer.lastName = sARecord.Account.LastName!=null ? sARecord.Account.LastName : '';
                    }
                    else{
                        customer.firstName = '';
                        customer.lastName = '';
                    }
                    jobcards.orderNr = mapWoliLoop;
                    jobcards.workshopId = mapOfWOLIIdAndWorkshopId.containsKey(mapWoliLoop) ? mapOfWOLIIdAndWorkshopId.get(mapWoliLoop) : '';
                }
                else{
                    vehicle.licensePlate = '';
                    vehicle.make = '';
                    vehicle.model = '';
                    vehicle.vin = '';
                    
                    customer.firstName = '';
                    customer.lastName = '';
                    
                    jobcards.orderNr = '';
                    jobcards.workshopId = '';
                }
                
                String prod = prodReqProdMap.containsKey(prodRq)? prodReqProdMap.get(prodRq):''; //mpProd.get(mapWoliLoop);
                
                
                    List<BLN_RecalibrationJobCard__c> tempJCList = mpProductRecalJob.get(prod);
                    
                    if(tempJCList!=null){
                        for(BLN_RecalibrationJobCard__c rj: tempJCList)
                        {
                            taskWrapper tempTask = new taskWrapper();
                            tempTask.position = String.valueOf(rj.BLN_SortOrder__c);
                            tempTask.taskName = rj.BLN_TaskName__c!=null  ? rj.BLN_TaskName__c : '';
                        tempTask.taskType = rj.BLN_TaskType__c!=null ? rj.BLN_TaskType__c : '';
                            if(tempTask!=null){
                                tasks.add(tempTask);
                            }
                        }
                    }
                if(tasks.size()>0){
                    jobcards.tasks = tasks;
                }
                else{
                    continue;
                }
                jBOutter.vehicle = vehicle;
                jBOutter.customers = customer;
                jBOutter.jobcards = jobcards;
                jobcardsOuterList.add(jBOutter);                
                //update BLN_IsBoschJobCardSent__c on SA
                ServiceAppointment tempSAUpdate = mapWoliSA.containsKey(mapWoliLoop)? mapWoliSA.get(mapWoliLoop):null;
                if(tempSAUpdate!=null) {tempSAUpdate.BLN_IsBoschJobCardSent__c = true;}
                if(!saToUpdate.contains(tempSAUpdate) && tempSAUpdate!=null){saToUpdate.add(tempSAUpdate);}
            }
            Current current = new Current();
            current.jobcards = jobcardsOuterList;
            
            Data data = new Data();
            data.current = current;
            payLoad.data = data;
            req.setBody(JSON.serialize(payLoad));
            req.setTimeout(Integer.valueof(calloutDetails.BLN_APITimeout__c));
            DateTime t1 = System.Now();
            res = http.send(req);
            DateTime t2 = System.Now();
           
            Decimal decSec2 = t2.getTime();
            Decimal decSec1 = t1.getTime();
            Decimal miliDiff = decsec2 - decsec1;
            Decimal secDiff = miliDiff/1000;
            Decimal rounded = secDiff.setScale(3);
            String secondsGap = String.valueOf(rounded);
            
            if (res.getbody() != null) {
                // Store Integration Logger Record
                List<BLN_IntegrationLogger__c> intLogList = new List<BLN_IntegrationLogger__c>();
                BLN_IntegrationLogger__c integrat = new BLN_IntegrationLogger__c();
                integrat.BLN_APICallInSeconds__c = secondsGap;
                integrat.BLN_RequestBody__c = req.getBody();
                integrat.BLN_RequestEndPoint__c = req.getEndpoint();
                integrat.BLN_RequestHeaders__c = reqHeader;
                integrat.BLN_RequestIssuedBy__c = UserInfo.getUserId();
                integrat.BLN_RequestMethod__c = req.getMethod();
                integrat.BLN_RequestSent__c = System.today();
                integrat.BLN_ResponseBody__c = res.getBody();
                integrat.BLN_ResponseHeaders__c = resHeaders(res);
                integrat.BLN_ResponseReceived__c = System.today();
                integrat.BLN_ResponseStatus__c = res.getStatus();
                integrat.BLN_ResponseStatusCode__c = ''+res.getStatusCode();
                integrat.BLN_TargetSystem__c = System.label.BLN_TargetSystemMulesoft;
                intLogList.add(integrat);
                
                update saToUpdate;
               
                BLN_IntegrationLogger.logRequest(intLogList);
            }
        } catch (Exception ex) {
            // Store Exception Logger Record
            BLN_ExceptionLogger.captureException(ex);
        }
    }

    public static String randomCodeGenerator() {
        Blob blobKey = Crypto.GenerateAESKey(128);
        String hexKey = EncodingUtil.ConvertTohex(blobKey);
        String uid = hexKey.SubString(0,8)+ '-' + hexKey.SubString(8,12) + '-' + hexKey.SubString(12,16) + '-' + hexKey.SubString(16,20) + '-' + hexKey.substring(20);
        return uid;
    }

    public static string resHeaders(HttpResponse res){
        //get the list of header names (keys)
        string[] headerkeys = res.getHeaderKeys();
        String headers;
       
        //iterate through they keys, and populate your map
        for(String header : headerkeys){
            headers = res.getHeader(header) + ',';
        }
        return headers;
    }

    public static String makeTimeStamp(){
        String currentDateTime = '';
        currentDateTime = System.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSSSSZ');
        String last2Chars = currentDateTime.right(2);
        currentDateTime = currentDateTime.removeEnd(last2Chars);
        currentDateTime = currentDateTime + ':' + last2Chars;
        return currentDateTime;
    }

    public class PayloadWrapper{
        public String entityName{get;set;}
        public String entityID{get;set;}
        public String eventType{get;set;}
        public String sourceSystem{get;set;}
        public String timestamp{get;set;}
        public String initialisedSystem{get;set;}
        public Data data{get;set;}
    }
    public class Vehicle {
        public String licensePlate{get;set;}
        public String make{get;set;}
        public String model{get;set;}
        public String vin{get;set;}
    }
    public class Jobcards {
        public String orderNr{get;set;}
        public String workshopId{get;set;}//FOUK-9031
        public List<TaskWrapper> tasks{get;set;}
    }
    public class TaskWrapper {
        public String position{get;set;}
        public String taskName{get;set;}
        public String taskType{get;set;}
    }    
    public class CustomerWrapper {
        public String firstName{get;set;}
        public String lastName{get;set;}
    }    
    public class Data {
        public Current current{get;set;}
    }    
    public class Current {
        public List<JobcardsOuter> jobcards{get;set;}
    }    
    public class JobcardsOuter {
        public Vehicle vehicle{get;set;}
        public CustomerWrapper customers{get;set;}
        public Jobcards jobcards{get;set;}
    }
}