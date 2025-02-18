@isTest
public class LAD_OrderSummaryCreationTest {
     
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success", "message": "This is a mocked response"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
   
    
    @isTest(Seealldata=true)
    static void testHandleOrderItemSummaries() {
        List<LAD_OrderSummaryCreation.inputWrapper> wraplist=new List<LAD_OrderSummaryCreation.inputWrapper>();
        LAD_OrderSummaryCreation.inputWrapper wrap=new LAD_OrderSummaryCreation.inputWrapper();
        wrap.orderItemId='802Fg0000078iizIAA';
        wrap.finalPrice=100;
        wrap.reasonForPriceAdjustment='any';
        wrap.originalPrice=100;
        wrap.quantity=10;
        wraplist.add(wrap);
        
        LAD_OrderSummaryCreation.invokePriceAdjustment(wraplist,[select id from ordersummary limit 1].id);
        LAD_OrderSummaryCreation.LineItem lineItemWrapper=new  LAD_OrderSummaryCreation.LineItem();
        LAD_OrderSummaryCreation.createPriceAdjustment(wraplist,[select id from ordersummary limit 1].id);
        LAD_OrderSummaryCreation.returnOrderItemSummary([select id from ordersummary limit 1].id);
     LAD_OrderSummaryCreation.returnOrderSummaryId('801Fg00000NYiPcIAL');
        
        List<LAD_OrderSummaryCreation.orderitemStausWrapper> wrapperList=new List<LAD_OrderSummaryCreation.orderitemStausWrapper>();

        LAD_OrderSummaryCreation.orderitemStausWrapper i=new LAD_OrderSummaryCreation.orderitemStausWrapper();
        i.orderItemId='802Fg0000078iizIAA';
        i.status='Shipped';
        i.nonReturnable=true;
        wrapperList.add(i);
        LAD_OrderSummaryCreation.updateOrderItemSummary(wrapperList,[select id from ordersummary limit 1].id);
    }
     @isTest
    static void LAD_FetchOctaBearertest() {
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         Test.startTest();        
        System.enqueueJob(new LAD_FetchOctaBearer('199'));
        Test.stopTest();
        
     
    }
     @isTest
    static void LAD_fetchTaxDetailsOrdertest() {
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         Test.startTest();        
        System.enqueueJob(new LAD_fetchTaxDetailsOrder('199','100'));
        Test.stopTest();
        
     
    }
    
     @isTest
    static void LAD_InvokeConnectApitest() {
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
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         Test.startTest();        
        System.enqueueJob(new LAD_InvokeConnectApi(orderId,retWrap));
        Test.stopTest();
        LAD_OrderSummaryCreation.returnOrderSummaryId(orderId);
     
    }
    
   
}