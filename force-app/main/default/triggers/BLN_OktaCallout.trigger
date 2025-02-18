trigger BLN_OktaCallout on BLN_OktaCallout__e (after insert) {
    new BLN_OktaCalloutTriggerHandler().run();
}