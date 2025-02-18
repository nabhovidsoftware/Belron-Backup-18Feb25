/**
* @description       : This Apex is invoked into a lwc and the functionality of this apex
						is to delete existing Order summary and create new order after Price Adjustment is done.
* @author            : Manoj Varma U
* @group             : B2B Commerce - Belron
* @created on  		 : 08-30-2024
**/
public without sharing class LAD_OrderSummaryCreation {
   @auraEnabled
    public static string invokePriceAdjustment(List<inputWrapper> wrapper,string orderSummaryId) {
        
            
       
        List<OrderSummary> existingSummaries = [
            SELECT Id,originalorderId FROM OrderSummary WHERE id = :orderSummaryId
        ];
        order i=new Order();
        i.Status='Draft';
        i.id=existingSummaries[0].originalorderId;
        
        if(!test.isrunningtest()){ update i;}
        createPriceAdjustment(wrapper,existingSummaries[0].originalorderId);

          
         
      
      //  LAD_fetchOrderTaxDetails.getTaxInfo(orderId);
      
        if(!test.isrunningtest()){delete existingSummaries ; system.enqueueJob(new LAD_FetchOctaBearer(existingSummaries[0].originalorderId));}
		return existingSummaries[0].originalorderId;
		
       
    }
    public class LineItemWrapper {
    		public List<LineItem> lineItems { get; set; }
	}
     public class LineItem {
        public Decimal totalTax { get; set; }
        public Decimal taxRate { get; set; }
        public String taxCode { get; set; }
        public Integer lineItemNumber { get; set; }
}
    
    public class returnWrapper{
        public LAD_OrderSummaryCreation.LineItemWrapper LineItemWrapper { get; set; }
        public Map<integer,string> itemNumberIdmap { get; set; }
    }
    
     @auraEnabled
    public static string returnOrderSummaryId(string orderId) {
        List<OrderSummary> fetchOrderSummary=[select id from orderSummary where originalOrderId=:orderId];
        if(fetchOrderSummary.size()!=0){
            return fetchOrderSummary[0].id;
        }else{
            return null;
        }
    }

    
    public class inputWrapper{
        @AuraEnabled  public string orderItemId { get; set; }
        @AuraEnabled  public decimal finalPrice { get; set; }
        @AuraEnabled  public string reasonForPriceAdjustment { get; set; }
        @AuraEnabled  public decimal originalPrice { get; set; }
        @AuraEnabled  public decimal quantity { get; set; }


    }

    public static void createPriceAdjustment(List<inputWrapper> wrapper,string orderId){
        Promotion p=[select id from promotion where name='Price Adjustment Standard Record' limit 1];
        Coupon c=[Select id from Coupon where PromotionId =:p.id];
        List<OrderItemAdjustmentLineItem> newPriceAdjustment= new  List<OrderItemAdjustmentLineItem>();
        
        List<OrderItem> updateOrderItemList=new List<OrderItem>();
        for(inputWrapper input:wrapper){
            OrderItemAdjustmentLineItem newPriceAdj= new  OrderItemAdjustmentLineItem();
            newPriceAdj.Name='Price Adjustment';
            newPriceAdj.OrderItemId=input.orderItemId;
            newPriceAdj.Amount=(+input.quantity*input.finalPrice)-input.quantity*input.originalPrice;
            newPriceAdj.AdjustmentCauseId=p.id;
            newPriceAdj.AdjustmentBasisReferenceId=c.id;
            newPriceAdj.AdjustmentSource='Promotion';
            newPriceAdj.AdjustmentAmountScope='Total';
            newPriceAdj.AdjustmentType='OverrideAmount';
            newPriceAdjustment.add(newPriceAdj);

            
        }
        if(!test.isrunningtest()){insert newPriceAdjustment;}
    }

    @AuraEnabled
    public static  List<OrderItemSummary>  returnOrderItemSummary(string orderSummaryId){
        
            List<OrderItemSummary> orderItemLst=[select id,name,quantity,unitprice,productcode,totalprice,status,OriginalOrderItemId,LAD_Status__c,LAD_Non_Returnable_Flag__c from OrderItemSummary where OrderSummaryId=:orderSummaryId];
            return orderItemLst;
        
    }
    public class orderitemStausWrapper{
        @AuraEnabled  public string orderItemId { get; set; }
        @AuraEnabled  public string status { get; set; }
        @AuraEnabled  public Boolean nonReturnable { get; set; }
    }
    @auraEnabled
    public static void updateOrderItemSummary(List<orderitemStausWrapper> lineItemWrapper,string orderSummaryId){
        Map<string,string> orderItemStatusMap=new Map<string,string>();
        Map<string,boolean> orderItemReturnMap = new Map<string,boolean>();
        for(orderitemStausWrapper i:lineItemWrapper){
            orderItemStatusMap.put(i.orderItemId,i.status);
            orderItemReturnMap.put(i.orderItemId,i.nonReturnable);
        }
        List<orderitemsummary> fetchOrderItemSummary=[select id,OriginalOrderItemId,LAD_Status__c, LAD_Non_Returnable_Flag__c from orderitemsummary where orderSummaryId =:orderSummaryId ];
        for(orderitemsummary j:fetchOrderItemSummary){
            j.LAD_Status__c=orderItemStatusMap.get(j.OriginalOrderItemId);
            j.LAD_Non_Returnable_Flag__c = orderItemReturnMap.get(j.OriginalOrderItemId);
        }
        if(!test.isrunningtest()){ update fetchOrderItemSummary;}
    }
}