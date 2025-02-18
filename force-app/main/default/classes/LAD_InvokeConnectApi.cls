public class LAD_InvokeConnectApi implements queueable {

    string orderId;
	LAD_OrderSummaryCreation.returnWrapper returnWrapper;
    public LAD_InvokeConnectApi(string orderId,LAD_OrderSummaryCreation.returnWrapper returnWrapper){
        this.orderId=orderId;
		this.returnWrapper=returnWrapper;       
    }
    
    public void execute(queueableContext context){
       		 List<OrderItemTaxLineItem> taxDetails=[select id from OrderItemTaxLineItem where orderId=:orderId];
        if(!Test.isRunningTest()){delete taxDetails;}
        	List<OrderItemTaxLineItem> orderItemtaxList=new List<OrderItemTaxLineItem>();
        	for (LAD_OrderSummaryCreation.LineItem item : returnWrapper.LineItemWrapper.lineItems) {
            System.debug('Total Tax: ' + item.totalTax);
            System.debug('Tax Rate: ' + item.taxRate);
            System.debug('Tax Code: ' + item.taxCode);
            System.debug('Line Item Number: ' + item.lineItemNumber);
              
            OrderItemTaxLineItem tax = new OrderItemTaxLineItem( 
                    name = 'Tax',
                    Amount = item.totalTax,
                    OrderItemId = returnWrapper.itemNumberIdmap.get(integer.valueof(item.lineItemNumber)),
                    TaxeffectiveDate = Date.today(),
                    Type = 'Actual'
                
                );
            orderItemtaxList.add(tax);    
        }
        system.debug(117+'-'+orderItemtaxList);
        	if(!Test.isRunningTest()){insert orderItemtaxList;}        
        
        
        	List<order> updateOrder=[select id,status from order where id=:orderId]; 
            if(updateOrder.size()!=0){
                updateOrder[0].status='Activated';
            	update updateOrder;
            }
     //   if(!Test.isRunningTest()){ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();osir.orderId = orderId; ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);OrderSummary newOrderSummary = [SELECT Id, Status FROM OrderSummary where OriginalOrderId = :orderId LIMIT 1];newOrderSummary.Status = 'Amended';update newOrderSummary;}
        LAD_OrderCancellation__e platformEvent=new LAD_OrderCancellation__e();
        platformEvent.LAD_Cancellation_Details__c='PriceAdjustment-'+orderId;
        EventBus.publish(platformEvent);     
    }
}