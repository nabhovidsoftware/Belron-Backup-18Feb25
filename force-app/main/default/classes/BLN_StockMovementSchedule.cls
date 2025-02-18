public with sharing class BLN_StockMovementSchedule implements Schedulable{
    public Id caseId;
    public Boolean updateSA = false;
    
    public void execute(SchedulableContext context){
        try{
        Case caseRecord = [SELECT Id, BLN_ISPAddress__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
        Order ord = [SELECT Id FROM Order WHERE Status = :System.label.BLN_Accepted AND BLN_Case__c =: caseId WITH SECURITY_ENFORCED ORDER BY createddate DESC LIMIT 1];
        List<OrderItem> selectedOI = [SELECT Id, BLN_StocksPreviousAppointment__c, BLN_ServiceAppointment__c, BLN_ServiceAppointment__r.ArrivalWindowStartTime, BLN_ServiceAppointment__r.AppointmentNumber, BLN_BranchThreshold__c FROM OrderItem WHERE orderId = :ord.Id AND BLN_OutOfStock__c = false AND BLN_IsProductSelected__c = true WITH SECURITY_ENFORCED];
        
        List<Id> orderItemIdsStockCall = new List<Id>();
        if(!updateSA && (!caseRecord.BLN_ISPAddress__c || test.isRunningTest())){
            for(OrderItem rec : selectedOI){
                orderItemIdsStockCall.add(rec.Id);
            	}
            //Future method for stock movement request
            BLN_StockReservationController.stockMovementCallout(orderItemIdsStockCall);
        	}
        else if(updateSA && !caseRecord.BLN_ISPAddress__c)
        {
            List<String> saNumber = new List<String>();
            for(OrderItem oi: selectedOI)
            {
                if(oi.BLN_StocksPreviousAppointment__c!=null && !saNumber.contains(oi.BLN_StocksPreviousAppointment__c))
                {
                    saNumber.add(oi.BLN_StocksPreviousAppointment__c);
                }
            }
            List<ServiceAppointment> prevSA = new List<ServiceAppointment>();
            Map<String,ServiceAppointment> appNoSaMap = new Map<String,ServiceAppointment>();
            if(saNumber!=null)
            {
                for(ServiceAppointment sa: [SELECT Id, AppointmentNumber, ArrivalWindowStartTime FROM ServiceAppointment WHERE AppointmentNumber IN :saNumber WITH SECURITY_ENFORCED])
                {
                    appNoSaMap.put(sa.AppointmentNumber, sa);
                }
            }
            for(OrderItem rec : selectedOI){
                Decimal threshold = rec.BLN_BranchThreshold__c != null?rec.BLN_BranchThreshold__c:0;
                if((rec.BLN_StocksPreviousAppointment__c!=null && appNoSaMap.containsKey(rec.BLN_StocksPreviousAppointment__c) && rec.BLN_ServiceAppointment__c!=null) && (rec.BLN_ServiceAppointment__r.ArrivalWindowStartTime > (appNoSaMap.get(rec.BLN_StocksPreviousAppointment__c).ArrivalWindowStartTime + threshold) || rec.BLN_ServiceAppointment__r.ArrivalWindowStartTime < appNoSaMap.get(rec.BLN_StocksPreviousAppointment__c).ArrivalWindowStartTime)){
                    orderItemIdsStockCall.add(rec.Id);
                }
            }
            if(orderItemIdsStockCall!=null)
            {
                BLN_QuotesAndStocksAPICallout.makeStockRequestCalloutForSaUpdate(orderItemIdsStockCall, orderItemIdsStockCall, false);
            }
        }
        }
        catch(Exception ex)
		{BLN_ExceptionLogger.captureException(ex);}
        System.abortJob(context.getTriggerId());
    }
    
    public BLN_StockMovementSchedule (Id setcaseId, Boolean setUpdateSA) {
        if ( setcaseId != null || setcaseId != '' ) {
            this.caseId = setcaseId;
        }
        if(setUpdateSA != null)
        {
            this.updateSA = setUpdateSA;
        }
    }
}