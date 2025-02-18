/** @description : This Apex is called from Service Appointment and call OKTA to get Access Token of MuleSoft
*   @Story : FOUK-198, 679, 680, 681
*   @author: Kanchan Mishra (PwC)
*   @CreatedDate: 31/07/2023
*/
public class BLN_HTTPCallOutToOkta implements Queueable, Database.AllowsCallouts{
    public Integer expiresIn;
    public List<ServiceAppointment> serviceAppointList = new List<ServiceAppointment>();
    
    public BLN_HTTPCallOutToOkta (List<ServiceAppointment> serviceAppointList){
        this.serviceAppointList = serviceAppointList;
    }
    
    public BLN_HTTPCallOutToOkta (){ 
    	string test = 'PMD'; // Added this line because of PMD issue, please remove this line if you want to add logic in this block
    }
    
    public void execute(QueueableContext context) {
        List<Exception> exceptionList = new List<Exception>();
        List<String> serializedServiceAppointments = new List<String>();
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
            String serializedService = JSON.serialize(serviceAppointList);
            serializedServiceAppointments.add(serializedService);
            //if(!test.isRunningTest()){
                   // System.enqueueJob(new BLN_HTTPCallOutToMuleSoft(serializedService, accessToken));
            //}
            
            if((res.getstatusCode() == 200 || res.getstatusCode() == 201) && res.getbody() != null){
                // Store Integration Logger Record
                String correlationId = randomCodeGenerator();
                List<BLN_IntegrationLogger__c> intLogList = new List<BLN_IntegrationLogger__c>();
                BLN_IntegrationLogger__c integrat = new BLN_IntegrationLogger__c();
                integrat.BLN_APICallInSeconds__c = secondsGap;
                integrat.BLN_CorrelationId__c = correlationId;
                integrat.BLN_RecordId__c = serviceAppointList[0].Id;
                integrat.BLN_RequestBody__c = req.getBody();
                integrat.BLN_RequestEndPoint__c = req.getEndpoint();
                integrat.BLN_RequestHeaders__c = reqHeader(auth, correlationId, instanceUrl);
                integrat.BLN_RequestIssuedBy__c = UserInfo.getUserId();
                integrat.BLN_RequestMethod__c = req.getMethod();
                integrat.BLN_RequestSent__c = System.today();
                integrat.BLN_ResponseBody__c = res.getBody();
                integrat.BLN_ResponseHeaders__c = resHeaders(res);
                integrat.BLN_ResponseReceived__c = System.today();
                integrat.BLN_ResponseStatus__c = res.getStatus();
                integrat.BLN_ResponseStatusCode__c = ''+res.getStatusCode();
                integrat.BLN_TargetSystem__c = System.label.BLN_TargetSystemOkta;
                intLogList.add(integrat);
                
                BLN_IntegrationLogger.logRequest(intLogList);
            }
        } catch (DmlException dmlx) {
            // Store Exception Logger Record
            exceptionList.add(dmlx);
        } catch (Exception ex) {
            // Store Exception Logger Record
            exceptionList.add(ex);
        }
        if(exceptionList!= null && !exceptionList.isEmpty()){
            BLN_ExceptionLogger.LogException(exceptionList, serviceAppointList[0].Id);
        }
    }
    
    public static String randomCodeGenerator() {
        Blob blobKey = Crypto.GenerateAESKey(128);
        String hexKey = EncodingUtil.ConvertTohex(blobKey);
        String uid = hexKey.SubString(0,8)+ '-' + hexKey.SubString(8,12) + '-' + hexKey.SubString(12,16) + '-' + hexKey.SubString(16,20) + '-' + hexKey.substring(20);
        return uid;
    }
    
    public static String resHeaders(HttpResponse res){
        //get the list of header names (keys)
        String[] headerKeys = res.getHeaderKeys();
        String headers;
        
        //iterate through they keys, and populate your map
        for(String headerKey : headerKeys){
            headers = res.getHeader(headerKey) + ',';
        }
        return headers;
    }
    
    public static String reqHeader(String auth, String correlationId, String instanceUrl){
        String reqHeader = 'Authorization: ' + auth + ' Content-Type: application/json ' + 'X-CORRELATION-ID: ' + correlationId + ' destination: '
            + instanceUrl;
        return reqHeader;
    }
}