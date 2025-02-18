/**
 * Created by gciesielsk001 on 28.03.2024.
 */

public with sharing class BLN_OktaCalloutTriggerHandler extends BLN_TriggerHandler{

    public override void afterInsert() {
        BLN_OktaCalloutTriggerHelper.generateOktaToken((List<BLN_OktaCallout__e>) Trigger.new);
    }

}