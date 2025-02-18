/**
 * Created by gciesielsk001 on 28.03.2024.
 */

public with sharing class BLN_OktaCalloutTriggerHelper {

    public static void generateOktaToken(List<BLN_OktaCallout__e> newOktaCallouts) {
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.OKTAIdP');
        DateTime expiresIn = (DateTime) orgPart.get('OKTATokenExpirationDateTime');
        String oktaToken = (String) orgPart.get('OKTAAccessToken');
        BLN_CalloutSettings__c customSetting = BLN_CalloutSettings__c.getInstance();
        if ((expiresIn == null || oktaToken == null || expiresIn < Datetime.now().addSeconds(Integer.valueOf(customSetting.BLN_ExpiresTimeBuffer__c))) && !customSetting.BLN_IsEventPublished__c) {
            customSetting.BLN_IsEventPublished__c = true;
            BLN_GenerateOktaToken.generateOktaToken((Id) newOktaCallouts[0].BLN_ServiceAppointmentId__c);
        }
    }

}