/**
 * Created by mluniewski002 on 17.01.2024.
 */

public without sharing class BLN_GenerateOktaToken {

    @Future(callout=true)
    public static void generateOktaToken(Id recordId)  {
        List<BLN_IntegrationLogger__c> integrationLogs = new List<BLN_IntegrationLogger__c>();
        List<BLN_ExceptionLogger__c> exceptionLogs = new List<BLN_ExceptionLogger__c>();
        Integer expiresIn;
        List<Exception> exceptionList = new List<Exception>();
        BLN_CalloutSettings__c customSetting = BLN_CalloutSettings__c.getInstance();
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
                customSetting.BLN_IsEventPublished__c = false;
            }

            if((res.getstatusCode() == 200 || res.getstatusCode() == 201) && res.getbody() != null){
                // Store Integration Logger Record
                integrationLogs.add(BLN_IntegrationLogger.createIntegrationLoggers(secondsGap, res, req, recordId, auth, instanceUrl, System.Label.BLN_TargetSystemOkta, false));
            }
        } catch (DmlException dmlx) {
            // Store Exception Logger Record
            exceptionList.add(dmlx);
        } catch (Exception ex) {
            // Store Exception Logger Record
            exceptionList.add(ex);
        }
        if(exceptionList!= null && !exceptionList.isEmpty()){
            exceptionLogs.addAll(BLN_ExceptionLogger.LogException(exceptionList, false, recordId));
        }
        if(Schema.sObjectType.BLN_ExceptionLogger__c.isCreateable()){
            insert exceptionLogs;
        }
        if(Schema.sObjectType.BLN_IntegrationLogger__c.isCreateable()){
            insert integrationLogs;
        }
    }
}