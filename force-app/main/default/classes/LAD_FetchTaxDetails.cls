/**
* @description       : This is a custom Tax Calaulation Class for Dsplaying Tax details on Checkout page and Updation of cart items corrosponding a cart.
* @author            : Prajjawal Tiwari
* @group             : B2B Commerce - Belron
* @last modified on  : 06-11-2024
* @last modified by  : Prajjawal Tiwari
**/

public class LAD_FetchTaxDetails {
    
    public static void isTaxCreatedFromAmendment(Set<id> cartItemDetails){
        id first = new List<id> (cartItemDetails).get(0); //returns abc

        cartItem cartDetail=[select id,cart.Lad_order__c from cartitem where id=:first];
        if(cartDetail.cart.Lad_order__c==null){
            
              List<CartTax> exitingTax=[select id from carttax where CartItemId in :cartItemDetails];
            delete exitingTax;
            getTaxInfo(cartItemDetails);
        }
        
    }
    
     @TestVisible public static string returnBearerTokens(){
     
		String octaEndpoint = 'https://belron-qa.oktapreview.com/oauth2/aus3y4d618foXQcFa0x7/v1/token?grant_type=client_credentials&scope=read';

		Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(octaEndpoint);
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        String username = '0oa7aj1weyriv995x0x7';
        String password = 'Tq8CqPYi1BhQ_qbU0Ok5x77r3dzC6l0_nzkewKR4MnBcg0u8HvDY5nNDczaZwbH0';
        request.setMethod('POST');

        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic '+
        EncodingUtil.base64Encode(headerValue);
		system.debug('authorizationHeader>>'+authorizationHeader);
        request.setHeader('Authorization', authorizationHeader);
		HTTPResponse response = http.send(request);
        Map<string,object> parseJson=(Map<string,object>)json.deserializeuntyped(response.getbody());
		string bearer=(string)parseJson.get('access_token');
		return bearer;
    }
    
    @future(callout=true)
    public static void getTaxInfo(Set<id> cartItemDetails){
       
        try{
            List<carttax> carttaxList=new List<cartTax>();
            List<CartItem> cartItemInfo=[select id,cart.CurrencyIsoCode,quantity,NetUnitPrice,SalesPrice,TotalPriceAfterAllAdjustments from cartitem where id in:cartItemDetails];
            List<string> queryinstance=new List<string>();
            string currencydetails='';
            string basePrefix='{"isoCurrencyCodeAlpha": "GBP","documentDate": "2024-08-02","bsId": "69489897","tradeAccountId": "","vatRegistrationNumber": "","delegatedAuthority": "","sellerCountry": "United Kingdom","customerCountry": "United Kingdom","lineItems": [';
            string baseSuffix=']}';
            Map<string,decimal> itemQtyMap=new Map<string,decimal>();
            Map<integer,string> itemNumberIdmap=new Map<integer,string>();
            system.debug('itemNumberIdmap');
            integer counter=1;
            for(cartitem i:cartItemInfo){
                itemNumberIdmap.put(counter,i.id);
                currencydetails=i.cart.CurrencyIsoCode!=null?i.cart.CurrencyIsoCode:'GBP';
                decimal quantity=i.quantity!=null?i.quantity:0;
                decimal price=i.TotalPriceAfterAllAdjustments;
                system.debug(price+'--'+quantity);
                string instance='{"lineItemNumber":'+counter+',"cpqPartNumber": "8580AGAGYVW","quantity":'+quantity+',"unitPrice":'+price+',"extendedPrice": '+price+'}';
             //   string instance='{      "lineItemId": "'+i.id+'",      "lineItemNumber": 27716,      "extendedPrice": '+price+',      "unitPrice": '+price+',       "taxOverride": {            "overrideType": "TAXABLE"        },      "quantity": {        "value": '+quantity+'      },"customer": {"destination": {"country": "GB"}  }, "seller": {    "physicalOrigin": {      "country": "GB"    }  }    }';
                queryinstance.add(instance);
                itemQtyMap.put(i.id,price*quantity);
                counter=counter+1;
            }
            

            system.debug(itemNumberIdmap);
            
            HttpRequest req=new HttpRequest();
            string urlEndpoint='https://tst.eu.api.belron.com/gbl/cpq/v1/taxes/quotations';
            req.setEndpoint(urlEndpoint);
            req.setMethod('POST');
            req.setheader('Content-Type','application/json');
            system.debug(basePrefix+string.join(queryinstance,',')+baseSuffix);
            req.setbody(basePrefix+string.join(queryinstance,',')+baseSuffix);
			req.setHeader('Authorization', 'Bearer ' +returnBearerTokens());
		
            Http httpReq=new Http();
            HttpResponse responsefromRequest=httpReq.send(req);
            system.debug(responsefromRequest);
            system.debug(responsefromRequest.getbody());
		
            
            string bearerToken='';
            if(responsefromRequest.getStatusCode()!=200){
                system.debug('Failed');
            }else{
			LineItemWrapper wrapper = (LineItemWrapper) JSON.deserialize(responsefromRequest.getbody(), LineItemWrapper.class);
        
        	// Access the lineItems list from the wrapper
        	for (LineItem item : wrapper.lineItems) {
            System.debug('Total Tax: ' + item.totalTax);
            System.debug('Tax Rate: ' + item.taxRate);
            System.debug('Tax Code: ' + item.taxCode);
            System.debug('Line Item Number: ' + item.lineItemNumber);
                
            CartTax tax = new CartTax( 
                    Amount =item.totalTax,
                    CartItemId = itemNumberIdmap.get(integer.valueof(item.lineItemNumber)),
                    Name = 'Tax',
                    TaxCalculationDate = Date.today(),
                    TaxRate = item.taxRate,
                    TaxType = 'Actual'
                );
            carttaxList.add(tax);    
        }
                
                
                
            }
            

            system.debug(117+'-'+carttaxList);
            Map<string,string> cartItem_taxMap=new Map<string,string>();
            map<string,datetime> carttaxDates=new Map<String,datetime>();
             insert carttaxList;
            List<CartTax> fetchallTaexes=[select id,cartitemid,createddate from carttax where CartItemId in :cartItemDetails];
            for(CartTax i:fetchallTaexes){
                if(!cartItem_taxMap.keyset().contains(i.cartitemid)){
                    cartItem_taxMap.put(i.cartitemid,i.id);
                    carttaxDates.put(i.cartitemid,i.CreatedDate);
                }else{
                    if(i.createddate>carttaxDates.get(i.cartitemid)){
					cartItem_taxMap.put(i.cartitemid,i.id);
                    carttaxDates.put(i.cartitemid,i.CreatedDate);                        
                    }
                }
            }
           

            List<CartTax> deleteUnwantedTaxes=[select id from carttax where  CartItemId in :cartItemDetails and (not id in : cartItem_taxMap.values())];
            delete deleteUnwantedTaxes;
              }catch(exception ex){
            BLN_ExceptionLogger.captureException(ex);
            
        }
       
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
}