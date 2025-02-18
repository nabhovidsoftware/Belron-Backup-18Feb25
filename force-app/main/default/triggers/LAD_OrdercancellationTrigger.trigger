trigger LAD_OrdercancellationTrigger on LAD_OrderCancellation__e (after insert) {

    if(!Trigger.new[0].LAD_Cancellation_Details__c.contains('PriceAdjustment')){
            Map<string,string> orderItemReasonMapping=new Map<string,string>();

object orderitemDetails =JSON.deserializeuntyped(Trigger.new[0].LAD_Cancellation_Details__c);
 
List<object> test=(List<object>)orderitemDetails;

         
for(object a:test){
    Map<String,object> ins=(Map<String,object>)a;

orderItemReasonMapping.put((string)ins.get('orderproductSummaryId'),(string)ins.get('reasonForCancellation'));    
}




                List<ConnectApi.ChangeItemInputRepresentation> changeItemsList=new List<ConnectApi.ChangeItemInputRepresentation>();
                
    try{
                
                                Map<id,orderitemsummary> orderProductItemData=new Map<id,orderitemsummary>([select id,quantity from orderitemsummary where id in :orderItemReasonMapping.keyset()]);
                String randomorderproductid = new List<String> (orderItemReasonMapping.keyset()).get(0); //returns abc
                string orderSummaryId=[select id,OrderSummaryId from OrderItemSummary where id =:randomorderproductid].OrderSummaryId;
          List<OrderItemSummary> updateOrderItemSummary=new List<OrderItemSummary>();
            for(string i:orderItemReasonMapping.keyset()){
                     ConnectApi.ChangeItemInputRepresentation changeItemInput = new ConnectApi.ChangeItemInputRepresentation();
                    changeItemInput.orderItemSummaryId = i;
                    changeItemInput.quantity =orderProductItemData.get(i).quantity ;
                changeItemInput.reason = orderItemReasonMapping.get(i);
                changeItemInput.shippingReductionFlag = true;
                changeItemInput.reasonForChangeText=orderItemReasonMapping.get(i);
                // represents the main input
                changeItemsList.add(changeItemInput);
                updateOrderItemSummary.add(new OrderItemSummary(Id=i,LAD_Status__c='Cancelled'));
                                      
                  }        
                 
                

                ConnectApi.ChangeInputRepresentation changeInput = new ConnectApi.ChangeInputRepresentation();
               
            changeInput.changeItems = new List<ConnectApi.ChangeItemInputRepresentation>(changeItemsList);
                    
                // execution, the first param is the Id of the Order Summary record
        try{
              ConnectApi.SubmitCancelOutputRepresentation output = ConnectAPI.OrderSummary.submitCancel(orderSummaryId, changeInput);

         }catch (Exception e) {
            // Handling the exceptions and log an error message
             BLN_ExceptionLogger.captureException(e);
         }
                          
        
    update updateOrderItemSummary;
             
               integer orderItems=[select count() from orderitemsummary where ordersummaryid=:orderSummaryId and status!='CANCELED' ];
    if(orderItems==0){
        OrderSummary updateorderSummary=new OrderSummary();        updateorderSummary.id=orderSummaryId;        updateorderSummary.Status='CANCELLED';        update updateorderSummary;
    }
    }catch (Exception e) {BLN_ExceptionLogger.captureException(e);}
    }else{
        string orderId=Trigger.new[0].LAD_Cancellation_Details__c.split('-')[1];        ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
        osir.orderId = orderId;        ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir); OrderSummary newOrderSummary = [SELECT Id, Status FROM OrderSummary where OriginalOrderId = :orderId LIMIT 1]; newOrderSummary.Status = 'Amended'; update newOrderSummary;
    }

}