/**
 * Created by gciesielsk001 on 28.03.2024.
 */

public with sharing class BLN_ProcessBookingErrorTriggerHandler extends BLN_TriggerHandler{

    public override void afterInsert() {
        BLN_ProcessBookingErrorTriggerHelper.processBookingErrors((List<BLN_BookingFailed__e>) Trigger.new);
    }

}