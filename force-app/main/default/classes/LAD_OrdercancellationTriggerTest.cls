@isTest
public class LAD_OrdercancellationTriggerTest {
	 
     @istest(seealldata=true)
    public static void testTrigger(){
        test.starttest();
        orderitemsummary lst=[select id,ordersummaryid from orderitemsummary limit 1];
    	 LAD_OrderCancellation__e platformEvent=new LAD_OrderCancellation__e();
        platformEvent.LAD_Cancellation_Details__c='[{"orderproductSummaryId":"'+lst.id+'","reasonForCancellation":"test"}]';
        	EventBus.publish(platformEvent);
          
        test.stoptest();

    }
    @istest(seealldata=true)
    public static void testTrigger2(){
 LAD_OrderSummaryCreation.LineItem lineItem=new LAD_OrderSummaryCreation.LineItem();
        lineItem.totalTax=10;
        lineItem.taxRate=.1;
        lineItem.taxCode='CODE';
        lineItem.lineItemNumber=1;
        List<LAD_OrderSummaryCreation.LineItem> lineItemList=new List<LAD_OrderSummaryCreation.LineItem>();
        lineItemList.add(lineItem);
        LAD_OrderSummaryCreation.LineItemWrapper wrapper=new LAD_OrderSummaryCreation.LineItemWrapper();
        wrapper.lineItems=lineItemList;
         LAD_OrderSummaryCreation.returnWrapper retWrap=new LAD_OrderSummaryCreation.returnWrapper();
       Map<integer,string> itemMap=new Map<integer,string>();
        Id orderId='801Fg00000NYiPcIAL';
        itemMap.put(1,orderId);
        retWrap.itemNumberIdmap=itemMap;
        retWrap.LineItemWrapper=wrapper;
      
        System.enqueueJob(new LAD_InvokeConnectApi(orderId,retWrap));        
    }

}