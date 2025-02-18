/** @description :  This apex class is used to handle Frequently Ordered Products (Top 5)
*   @Story :        FOUK-9940
*   @author:        binayak.debnath@pwc.com (IN)
*   @CreatedDate:   04-09-2024
*/

public with sharing class LAD_FrequentlyOrderedHandler {
    @testvisible  private static Boolean allowException;

    /**@MethodName :    fetchFreqOrderedProducts
    * @description :    This method is used to determine top 5 most ordered products based on quantity and return their details.
    * @param:           String effectiveAccountId
    * @return:          List<ProductWrapper>
    */
    @AuraEnabled
    public static List<ProductWrapper> fetchFreqOrderedProducts(String effectiveAccountId, String communityId){
        List<ProductWrapper> returnList = new List<ProductWrapper>();
        Map<Id, Product2> prodIdProdDetailsMap = new Map<Id, Product2>();
        Map<Id, Integer> prodIdProdQuantityMap = new Map<Id, Integer>();
            try {
                // Get the value of 'n' from the custom label and convert it to an integer
            String daysString = System.Label.LAD_FreqOrdProd_TimeLimit;
            daysString =daysString.trim();
            Integer days;
            
            if(!daysString.isNumeric() || daysString.contains('.')){
                days = 120;
            }
            else{
                days = Integer.valueOf(daysString) > 180 ? 120 : Integer.valueOf(daysString);
            }

            Date cutoffDate = Date.today().addDays(-days);

            List<OrderItem> orderItemList = [SELECT Id, 
                                                    Product2Id,
                                                    Product2.Name, 
                                                    Product2.ProductCode, 
                                                    Quantity 
                                            FROM OrderItem 
                                            WHERE Order.AccountId = :effectiveAccountId AND CreatedDate >= :cutoffDate];
            
            for(OrderItem item : orderItemList){
                Product2 prodItem = new Product2();
                prodItem.Name = item.Product2.Name;
                prodItem.ProductCode = item.Product2.ProductCode;

                prodIdProdDetailsMap.put(item.Product2Id, prodItem);

                if(prodIdProdQuantityMap.containsKey(item.Product2Id)){
                    prodIdProdQuantityMap.put(item.Product2Id, prodIdProdQuantityMap.get(item.Product2Id) + Integer.valueOf(item.Quantity));
                }
                else{
                    prodIdProdQuantityMap.put(item.Product2Id, Integer.valueOf(item.Quantity));
                }
            }

            //Sorting in reverse Order
            List<MapEntry> entryList = new List<MapEntry>();

            for (Id i : prodIdProdQuantityMap.keySet()){
                MapEntry entry = new MapEntry(i, prodIdProdQuantityMap.get(i));
                entryList.add(entry);
            }

            system.debug('unsorted list ' + entryList);
            entryList.sort(new MapValueComparator());
            system.debug('sorted list ' + entryList);

            for(MapEntry entry : entryList){
                ProductWrapper item = new ProductWrapper();
                item.ProductName = prodIdProdDetailsMap.get(entry.key).Name;
                item.ProductCode = prodIdProdDetailsMap.get(entry.key).ProductCode;
                item.ProductId = entry.key;
                returnList.add(item);
                if (returnList.size() == 5){
                    break;
                }
            }
            system.debug(returnList.size());

            String webStoreId;
            if(!Test.isRunningTest() || allowException){
                webStoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId  = :communityId LIMIT 1].WebStoreId;
            }
            else{
                webStoreId = communityId;
            }

            for(ProductWrapper wrap : returnList){
                if(Test.isRunningTest()){
                    wrap.ProductURL = 'http://test.com';
                }
                else{
                    ConnectApi.ProductDetail prodDetail = ConnectApi.CommerceCatalog.getProduct(webStoreId, wrap.ProductId, effectiveAccountId, null, true, null, false, true, true);
                    wrap.ProductURL = URL.getOrgDomainURL().toExternalForm() + prodDetail.defaultImage.url;
                }
            }
            system.debug(String.valueOf(returnList));

            return returnList;
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            return null;
        }
    }

    //Wrapper class for Product Details
    public class ProductWrapper{
        @auraenabled public String ProductName;
        @auraenabled public String ProductCode;
        @auraenabled public Id ProductId;
        @auraenabled public String ProductURL;

    }

    //Wrapper class for sorting
    public class MapEntry{
        public Id key {get; set;}
        public Integer value {get; set;}

        public MapEntry(Id key, Integer value){
            this.key = key;
            this.value = value;
        }
    }

    public class MapValueComparator implements Comparator<MapEntry> {
        public Integer compare(MapEntry entry1, MapEntry entry2){
            if(entry1.value == entry2.value){
                return 0;
            }
            else if(entry1.value > entry2.value){
                return -1;
            }
            return 1;
        }
    }
}