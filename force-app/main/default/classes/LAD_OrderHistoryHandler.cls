/** @description :  This apex class is used to handle Order History List and Reorder functionality
*   @Story :        FOUK-9870; FOUK-9872
*   @author:        binayak.debnath@pwc.com (IN)
*   @CreatedDate:   10-09-2024
*/
public with sharing class LAD_OrderHistoryHandler {
    @testvisible  private static Boolean allowException;

    public class SearchParameters{
        @auraenabled public String effectiveAccountId{get; set;}
        @auraenabled public String startDate{get; set;}
        @auraenabled public String endDate{get; set;}
        @auraenabled public String communityId{get; set;}
    }
    
    /**@MethodName :    fetchOrderDetails
    * @description :    This method is used to fetch all Order Details required for Order History List.
    * @param:           SearchParameters searchDetails
    * @return:          OrderDetailsWrapper
    */
    @AuraEnabled
    public static OrderDetailsWrapper fetchOrderDetails(SearchParameters searchDetails){
        List<OrderSummary> orderSummaryDetails = new List<OrderSummary>();
        Set<String> productIds = new Set<String>();
        Map<String, String> prodIdProdUrlMap = new Map<String,String>();
        List<OrderDetails> orderDetailsList = new List<OrderDetails>();
        OrderDetailsWrapper returnWrapper = new OrderDetailsWrapper();

        try {
            if(searchDetails.startDate != null && searchDetails.endDate != null){
                Date startDate = Date.valueOf(searchDetails.startDate);
                Date endDate = Date.valueOf(searchDetails.endDate).addDays(1);

                orderSummaryDetails = [ SELECT  Id, 
                                                CurrencyIsoCode,
                                                OrderNumber, 
                                                OrderedDate, 
                                                GrandTotalAmount, 
                                                Status, 
                                                PoNumber, 
                                                CreatedDate,
                                                (SELECT Product2Id ,LAD_Date_Selected_By_Customer__c,LAD_Product_Availability_Date__c
                                                FROM OrderItemSummaries) 
                                        FROM OrderSummary 
                                        WHERE AccountId = :searchDetails.effectiveAccountId AND OrderedDate >= :startDate AND OrderedDate <= :endDate
                                        ORDER BY OrderedDate DESC
                                        LIMIT 500];
            }
            else{
                orderSummaryDetails = [ SELECT  Id, 
                                                OrderNumber,
                                                CurrencyIsoCode, 
                                                OrderedDate, 
                                                GrandTotalAmount, 
                                                Status, 
                                                PoNumber, 
                                                CreatedDate,
                                                (SELECT Product2Id ,LAD_Date_Selected_By_Customer__c,LAD_Product_Availability_Date__c
                                                FROM OrderItemSummaries) 
                                        FROM OrderSummary 
                                        WHERE AccountId = :searchDetails.effectiveAccountId AND OrderedDate != null
                                        ORDER BY OrderedDate DESC];                     
            }

            for(OrderSummary sum : orderSummaryDetails){
                for(OrderItemSummary item : sum.OrderItemSummaries){
                    productIds.add(item.Product2Id);
                }
            }

            String webStoreId;
            if(!Test.isRunningTest() || allowException){
                webStoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId  = :searchDetails.communityId LIMIT 1].WebStoreId;
            }
            else{
                webStoreId = searchDetails.communityId;
            }

            for(String prodId : productIds){
                if(Test.isRunningTest()){
                    prodIdProdUrlMap.put(prodId, 'http://test.com');
                }
                else{
                    try{
                    ConnectApi.ProductDetail prodDetail = ConnectApi.CommerceCatalog.getProduct(webStoreId, prodId, searchDetails.effectiveAccountId, null, true, null, false, true, true);
                    system.debug(prodDetail.defaultImage.url);
                    prodIdProdUrlMap.put(prodId, URL.getOrgDomainURL().toExternalForm() + prodDetail.defaultImage.url);
                }
                    catch(Exception e){
                        system.debug(e.getLineNumber() + ' - ' + e.getMessage());
                    }
                    
                }
            }


            for(OrderSummary sum : orderSummaryDetails){
                OrderDetails currOrder = new OrderDetails();
                currOrder.OrderSummaryId = sum.Id;
                currOrder.OrderSummaryNumber = sum.OrderNumber;
                currOrder.OrderStatus = sum.Status;
                currOrder.OrderedDate = sum.OrderedDate != null ? (String.valueOf(sum.OrderedDate)).substring(0, 10) : (String.valueOf(sum.CreatedDate)).substring(0, 10);
                currOrder.GrandTotalAmount = LAD_checkoutPageController.returnSymbol(sum.CurrencyIsoCode) + String.valueOf(sum.GrandTotalAmount);
                currOrder.OrderPONumber = sum.PoNumber;
                List<ProductURL> currImageUrlList = new List<ProductURL>();
                for(OrderItemSummary item : sum.OrderItemSummaries){ 
                    ProductURL currUrl = new ProductURL();  
                    currUrl.ProductURL = prodIdProdUrlMap.get(item.Product2Id);
                    
                    //FOUK-10604
                    if(item.LAD_Product_Availability_Date__c==null || (item.LAD_Product_Availability_Date__c<=item.LAD_Date_Selected_By_Customer__c)){
                        currOrder.isAnyOrderProductDelayed=false;
                    }else{
                         currOrder.isAnyOrderProductDelayed=true;

                    }
                    
                    
                    if(currUrl.ProductURL != null){
                        currImageUrlList.add(currUrl);
                    }
                    if(currImageUrlList.size() == 4){
                        break;
                    }
                }
                currOrder.ProductImages = currImageUrlList;

                orderDetailsList.add(currOrder);
            }

            returnWrapper.orderDetails = orderDetailsList;
            returnWrapper.status = 'Success';
            
            system.debug(returnWrapper);

        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            returnWrapper.status = 'Failure';
            returnWrapper.message = e.getLineNumber()+' - '+e.getMessage();
        }

        return returnWrapper;
    }

    public class OrderDetailsWrapper{
        @auraenabled public String status;
        @auraenabled public String message;
        @auraenabled public List<OrderDetails> orderDetails;

    }
    public class OrderDetails{
        @auraenabled public string OrderSummaryId;
        @auraenabled public string OrderSummaryNumber;
        @auraenabled public string OrderStatus;
        @auraenabled public string OrderedDate;
        @auraenabled public string GrandTotalAmount;
        @auraenabled public string OrderPONumber;
        @auraenabled public List<ProductURL> ProductImages;
        @auraenabled public boolean isAnyOrderProductDelayed;//FOUK-10604

    }

    public class ProductURL{
        @auraenabled public string ProductURL;

    }

}