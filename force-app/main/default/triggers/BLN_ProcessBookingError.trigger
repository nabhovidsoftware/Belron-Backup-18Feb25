trigger BLN_ProcessBookingError on BLN_BookingFailed__e (after insert) {
    new BLN_ProcessBookingErrorTriggerHandler().run();
}