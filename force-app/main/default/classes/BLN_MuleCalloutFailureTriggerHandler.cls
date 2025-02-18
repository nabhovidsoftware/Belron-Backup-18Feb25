/**
 * Created by gciesielsk001 on 28.03.2024.
 */

public with sharing class BLN_MuleCalloutFailureTriggerHandler extends BLN_TriggerHandler{

    public override void afterInsert() {
        BLN_MuleCalloutFailureTriggerHelper.processCalloutFailures((List<BLN_MuleCalloutFailure__e>) Trigger.new);
    }

}