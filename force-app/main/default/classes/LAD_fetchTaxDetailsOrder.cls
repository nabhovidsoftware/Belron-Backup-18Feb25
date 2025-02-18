public class LAD_fetchTaxDetailsOrder implements queueable,Database.allowscallouts {

    string orderId;
    string bearer;
    public LAD_fetchTaxDetailsOrder(string orderId,string bearer){
        this.orderId=orderId;
        this.bearer=bearer;
       
    }
    public void execute(queueableContext context){
        getTaxInfo(bearer,orderId);
    }
 
    public static void getTaxInfo(string bearer, string orderId){
        
           
            List<OrderItemTaxLineItem> orderItemtaxList=new List<OrderItemTaxLineItem>();
            List<OrderItem> orderItemInfo=[select id,order.CurrencyIsoCode,quantity,UnitPrice,ListPrice,TotalPrice,AdjustedLineAmount from OrderItem where orderId=:orderId];
            List<string> queryinstance=new List<string>();
            string currencydetails='';
            string basePrefix='{"isoCurrencyCodeAlpha": "GBP","documentDate": "2024-08-02","bsId": "69489897","tradeAccountId": "","vatRegistrationNumber": "","delegatedAuthority": "","sellerCountry": "United Kingdom","customerCountry": "United Kingdom","lineItems": [';
            string baseSuffix=']}';
            Map<string,decimal> itemQtyMap=new Map<string,decimal>();
            Map<integer,string> itemNumberIdmap=new Map<integer,string>();
            system.debug('itemNumberIdmap');
            integer counter=1;
            for(OrderItem i:orderItemInfo){
                itemNumberIdmap.put(counter,i.id);currencydetails=i.order.CurrencyIsoCode!=null?i.order.CurrencyIsoCode:'GBP';decimal quantity=i.quantity!=null?i.quantity:0;decimal price=i.AdjustedLineAmount;
                system.debug(price+'--'+quantity);
                string instance='{"lineItemNumber":'+counter+',"cpqPartNumber": "8580AGAGYVW","quantity":'+quantity+',"unitPrice":'+price+',"extendedPrice": '+price+'}';
             //   string instance='{      "lineItemId": "'+i.id+'",      "lineItemNumber": 27716,      "extendedPrice": '+price+',      "unitPrice": '+price+',       "taxOverride": {            "overrideType": "TAXABLE"        },      "quantity": {        "value": '+quantity+'      },"customer": {"destination": {"country": "GB"}  }, "seller": {    "physicalOrigin": {      "country": "GB"    }  }    }';
                queryinstance.add(instance);itemQtyMap.put(i.id,price*quantity);counter++;
            }
            

            system.debug(itemNumberIdmap);
            
            HttpRequest req=new HttpRequest();
            string urlEndpoint='https://tst.eu.api.belron.com/gbl/cpq/v1/taxes/quotations';
            req.setEndpoint(urlEndpoint);
            req.setMethod('POST');
            req.setheader('Content-Type','application/json');
            system.debug(basePrefix+string.join(queryinstance,',')+baseSuffix);
            req.setbody(basePrefix+string.join(queryinstance,',')+baseSuffix);
			req.setHeader('Authorization', 'Bearer ' +bearer);
		
            Http httpReq=new Http();
            HttpResponse responsefromRequest=httpReq.send(req);
            system.debug(responsefromRequest);
            system.debug(responsefromRequest.getbody());
		
            
            string bearerToken='';
        
        	LAD_OrderSummaryCreation.returnWrapper i=new LAD_OrderSummaryCreation.returnWrapper();
        	i.itemNumberIdmap=itemNumberIdmap;
        	
        
        	if(responsefromRequest.getStatusCode()!=200){
                system.debug('Failed');
                i.LineItemWrapper=null;
            }else{
			LAD_OrderSummaryCreation.LineItemWrapper wrapper = (LAD_OrderSummaryCreation.LineItemWrapper) JSON.deserialize(responsefromRequest.getbody(), LAD_OrderSummaryCreation.LineItemWrapper.class);
        	i.LineItemWrapper= wrapper;
        	
            
            }
       
         	if(!Test.isRunningTest()){
        	system.enqueueJob(new LAD_InvokeConnectApi(orderId,i));
            }
          //////            
          
        
    } 
   
    
}