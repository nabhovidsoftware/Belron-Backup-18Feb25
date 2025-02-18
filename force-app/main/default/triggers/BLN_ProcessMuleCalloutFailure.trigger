trigger BLN_ProcessMuleCalloutFailure on BLN_MuleCalloutFailure__e (after insert) {
    new BLN_MuleCalloutFailureTriggerHandler().run();
}