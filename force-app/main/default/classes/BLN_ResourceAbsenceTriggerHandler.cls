public with sharing class BLN_ResourceAbsenceTriggerHandler extends BLN_TriggerHandler{

    public override void beforeInsert() {
        BLN_ResourceAbsenceTriggerHelper.mapResourceAbsence((List<ResourceAbsence>) Trigger.new);
    }
}