/** @description :  This apex class is used to handle Checkout Page Functionality
*   @Story :        
*   @author:        (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   19-06-2024
*/
public without sharing class LAD_checkoutPageController {

    /** @description :  This apex method is used to get time limit for collection and delivery from stock availability date
    *   @Story :        FOUK-9758; FOUK-9759; FOUK-9940; FOUK-9941
    *   @author:        (binayak.debnath@pwc.com (IN))
    *   @CreatedDate:   09-08-2024
    */
    @AuraEnabled
    public static Map<String, Integer> fetchPreferredTimeLimits(){
        Map<String, Integer> returnMap = new Map<String, Integer>();

        try {
            //FOUK-9758; FOUK-9759
            String collectionLabel = System.Label.LAD_Time_Limit_for_Collection;
            collectionLabel = collectionLabel.trim();
            if(!collectionLabel.isNumeric() || collectionLabel.contains('.')){
                returnMap.put('CollectionLimit' , 7);
            }
            else{
                returnMap.put('CollectionLimit' , Integer.valueOf(collectionLabel));
            }

            //FOUK-9940; FOUK-9941
            String deliveryLabel = System.Label.LAD_Time_Limit_for_Delivery;
            deliveryLabel = deliveryLabel.trim();
            if(!deliveryLabel.isNumeric() || deliveryLabel.contains('.')){
                returnMap.put('DeliveryLimit' , 7);
            }
            else{
                returnMap.put('DeliveryLimit' , Integer.valueOf(deliveryLabel));
            }
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            returnMap.put('CollectionLimit' , 7);
            returnMap.put('DeliveryLimit' , 7);
        }

        return returnMap;
    }
    
    /** @description :  This apex method is used to get cartid corrosponding to a user
*   @Story :        
*   @author:        (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   19-06-2024
*/
    @AuraEnabled
    public static IdWrapper getCartId(Id userId,Id accountId) {
        Id cartId;
        Id existingOrderId = null;
		boolean isSpecialOrderCart=false;
        List<WebCart> carts = [SELECT Id,LAD_Order__c,LAD_Special_Order_Cart__c FROM WebCart WHERE OwnerId = :userId AND Status IN ('Active','Checkout') and accountId=:accountId LIMIT 1];
        
        if (carts.size() > 0) {
            cartId = carts[0].Id;
            existingOrderId=carts[0].LAD_Order__c;
            isSpecialOrderCart=carts[0].LAD_Special_Order_Cart__c;
        }
        IdWrapper returnWrapper = new IdWrapper(cartId, existingOrderId,isSpecialOrderCart);
        return returnWrapper;
    }

    public class IdWrapper{
        @auraenabled public Id cartId;
        @auraenabled public Id orderId;
        @auraenabled public boolean isSpecialOrderCart;

        public IdWrapper(Id cartId, Id orderId,boolean isSpecialOrderCart){
            this.cartId = cartId;
            this.orderId = orderId;
            this.isSpecialOrderCart=isSpecialOrderCart;
        }

    }
    
/** @description :  This apex method is used to get cartitems corrosponding to a cart
*   @Story :        
*   @author:        (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   19-06-2024
*/

    
    @AuraEnabled
    public static List<Map<String, Object>> getCartItems(Id cartId) {
        List<Map<String, Object>> cartItems = new List<Map<String, Object>>();
        
        try{
            
            List<Map<String, String>> cartItemToUserMap = new List<Map<String, String>>();
            List<CartItem> cartItemsList = [SELECT Id, Name,TotalPriceAfterAllAdjustments,CurrencyIsoCode,Quantity,LAD_Associated_Location__r.LAD_Available_for_Delivery__c, ListPrice,NetUnitPrice,SalesPrice, Product2Id,Product2.LAD_Eligible_for_Collection_Discount__c, CreatedById, Product2.Name, Product2.Description, Product2.ProductCode, LAD_Associated_Location__c,LAD_Associated_Location__r.Location.Name
                                            FROM CartItem 
                                            WHERE CartId = :cartId and product2.StockKeepingUnit!='PSER00405A'];
            
            Map<string,boolean> cartItemCollectionDiscountEligibility=returnCollectionDiscountEligibility(cartItemsList,cartId);

            List<Id> associatedLocationIds = new List<Id>();
            
            for (CartItem cartItem : cartItemsList) {
                Map<String, String> cartItemUserMap = new Map<String, String>();
                cartItemUserMap.put('CartItemId', cartItem.Id);
                cartItemUserMap.put('UserId', cartItem.CreatedById);
                cartItemToUserMap.add(cartItemUserMap);
                associatedLocationIds.add(cartItem.LAD_Associated_Location__c);
            }
            
            system.debug('associatedLocationIds>>'+associatedLocationIds);
            //Retrieving all Associated Locations, Location Names and Assigned Addresses
            List<AssociatedLocation> allLocations = [SELECT Id, LAD_Location_Type__c,LAD_Available_for_Delivery__c,Location.Name, (SELECT id,name,LAD_Is_default__c, lad_address__r.address FROM Assigned_Address__r) FROM AssociatedLocation WHERE Id IN :associatedLocationIds];
            system.debug('allLocations>>>'+allLocations);
            //Map to store all assigned Addresses with Location Names as key
            Map<String, List<AddressWrapper>> locAddressMap= new Map<String, List<AddressWrapper>>();
            Map<string,boolean> locAvailableforDeliverymap=new Map<String,boolean>();
            for(AssociatedLocation loc : allLocations ){
                List<AddressWrapper> addWrapList = new  List<AddressWrapper>();
                if(loc.LAD_Location_Type__c=='Primary'){
                    locAvailableforDeliverymap.put(loc.Location.Name,loc.LAD_Available_for_Delivery__c);

                    for(LAD_Assigned_Address__c add : loc.Assigned_Address__r){
                        AddressWrapper addWrap = new AddressWrapper();
                        addWrap.isDefault = add.LAD_Is_default__c;
                        addWrap.addressId=add.Id;
                        addWrap.address = add.lad_address__r.address;
                        addWrapList.add(addWrap);
                        system.debug('addWrapList>>'+addWrapList);
                    }
                    locAddressMap.put(loc.Location.Name, addWrapList);
                }
                
            }
            
            system.debug('locAddressMap>>'+locAddressMap);
            system.debug('cartItemToUserMap>'+cartItemToUserMap);
            List<Map<String, String>> deldatemap = getPreferenceData(cartItemToUserMap);
            
            Promotion collectionDiscountDetail=[select id,LAD_Discount_Type__c,LAD_Discount_Value__c,LAD_CanBeCombinedWithOtherPromotions__c from Promotion where LAD_Collection_Discount__c=true limit 1];            //FOUK-10903 


            for (CartItem cartItem : cartItemsList) {
                Map<String, Object> item = new Map<String, Object>();
                item.put('Id', cartItem.Id);
               item.put('Quantity', cartItem.Quantity);
                item.put('CartItemName', cartItem.Name);
                item.put('ProductId', cartItem.Product2Id);
                item.put('ProductName', cartItem.Product2.Name);
                item.put('CartItemCurrencySymbol',returnSymbol(cartitem.CurrencyIsoCode));
                item.put('ProductDescription', cartItem.Product2.Description);
                item.put('ProductCode', cartItem.Product2.ProductCode);

                item.put('ListPrice', cartItem.TotalPriceAfterAllAdjustments/cartItem.Quantity);
                
                item.put('ImageURL', '/img/b2b/default-product-image.svg');
                String location = cartItem.LAD_Associated_Location__r.Location.Name;
                system.debug('loc>>'+location);
                item.put('Addresses', locAddressMap.get(location));
                item.put('AvailableForDelivery',locAvailableforDeliverymap.get(location));
                system.debug('check2>>>'+cartItemCollectionDiscountEligibility.get(cartItem.Product2Id));
                item.put('eligibleForCollectionDiscount',cartItemCollectionDiscountEligibility.get(cartItem.Product2Id));
                if(collectionDiscountDetail!=null && collectionDiscountDetail.LAD_Discount_Type__c=='Amount'){
                    item.put('collectionDiscountAmount',collectionDiscountDetail.LAD_Discount_Value__c);
                }else if(collectionDiscountDetail!=null && collectionDiscountDetail.LAD_Discount_Type__c=='Percentage'){
                    item.put('collectionDiscountAmount',(cartItem.TotalPriceAfterAllAdjustments/cartItem.Quantity)*(collectionDiscountDetail.LAD_Discount_Value__c)/100);

                }
                for (Map<String, String> pref : deldatemap) {
                    if (pref.get('CartItemId') == cartItem.Id) {
                        item.put('DeliveryDate', pref.get('DeliveryDate'));
                        item.put('LocationName', pref.get('LocationName'));
                    }
                }
                
                cartItems.add(item);
                
            }
            
            system.debug('cartItems map >>'+cartItems);
        }catch(exception e){
            BLN_ExceptionLogger.captureException(e);
            
        } 
        return cartItems;
        
    }
    
        
/** @description :  This method  is used to check whether product in cart item is eligible for collection discount
*   @Story :        
*   @author:        (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   19-06-2024
*/


@AuraEnabled
public static Map<string,boolean> returnCollectionDiscountEligibility( List<cartItem> cartItemList,string cartId){
    try {
        Map<string,boolean> cartItemEligibility=new map<string,boolean>();
        string accountId=[select id,accountid from webcart where id=:cartId].accountid;
        Boolean isAccountEligible=[select id,LAD_Eligible_for_Collection_Discount__c from account where id=:accountId].LAD_Eligible_for_Collection_Discount__c;
        Map<string,boolean> productGroupEligibility=new map<string,boolean>();
        Map<string,string> productIdCategory=new map<string,string>();

        for(cartItem i:cartItemList){
            productGroupEligibility.put(i.product2id,false);
        }

        List<ProductCategoryProduct> ProductCategoryProductList=[select id,ProductId,LAD_Eligible_for_Collection_Discount__c,ProductCategoryId from ProductCategoryProduct where ProductId in :productGroupEligibility.keyset()];

        for(ProductCategoryProduct i:ProductCategoryProductList){
            productIdCategory.put(i.ProductId,i.ProductCategoryId);
        }
        system.debug(productIdCategory.values());
        Map<Id,ProductCategory> cartegoryList=new Map<Id,ProductCategory>([select id,LAD_Eligible_for_Collection_Discount__c from ProductCategory where id in :productIdCategory.values()]);
		system.debug(188);
        system.debug(cartegoryList);
        for(string i:productIdCategory.keyset()){
            if(cartegoryList.get(productIdCategory.get(i))!=null){
                            productGroupEligibility.put(i,cartegoryList.get(productIdCategory.get(i)).LAD_Eligible_for_Collection_Discount__c);

            }
        }

        for(cartItem i:cartItemList){
            boolean isEligible=(i.Product2.LAD_Eligible_for_Collection_Discount__c || productGroupEligibility.get(i.Product2id))&& isAccountEligible && (i.LAD_Associated_Location__r.LAD_Available_for_Delivery__c);
            system.debug('isEligible>>'+isEligible);
            cartItemEligibility.put(i.product2id,isEligible);
        }
        return cartItemEligibility;
    } catch (Exception e) {
        BLN_ExceptionLogger.captureException(e);
        return null;
    }
}
        
/** @description :  This method  is used to get user preference data corrosponding to a cartItems
*   @Story :        
*   @author:        (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   19-06-2024
*/
    
    @AuraEnabled
    public static List<Map<String, String>> getPreferenceData(List<Map<String, String>> cartItemsdata) {
        
        system.debug('cartItemsdata >>' + cartItemsdata);
        
        Set<Id> cartItemIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        
        for (Map<String, String> cartItemData : cartItemsdata) {
            cartItemIds.add(cartItemData.get('CartItemId'));
            userIds.add(cartItemData.get('UserId'));
        }
        
        List<LAD_MDC_Preference__c> preferences = [
            SELECT LAD_Cartitem__c, LAD_User__c, LAD_Delivery_Date__c ,LAD_Associated_Location__r.Location.Name,LAD_Associated_Location__r.LAD_Available_for_Delivery__c
            FROM LAD_MDC_Preference__c 
            WHERE LAD_Cartitem__c IN :cartItemIds AND LAD_User__c IN :userIds
        ];
        
        system.debug('preferences >>' + preferences);
        
        List<Map<String, String>> preferenceData = new List<Map<String, String>>();
        
        for (Map<String, String> cartItemData : cartItemsdata) {
            for (LAD_MDC_Preference__c preference : preferences) {
                if (preference.LAD_Cartitem__c == cartItemData.get('CartItemId') && 
                    preference.LAD_User__c == cartItemData.get('UserId')) {
                        Map<String, String> item = new Map<String, String>();
                        item.put('CartItemId', preference.LAD_Cartitem__c);
                        item.put('DeliveryDate', preference.LAD_Delivery_Date__c);
                        item.put('LocationName', preference.LAD_Associated_Location__r.Location.Name);
                        item.put('AvailableForDelivery',preference.LAD_Associated_Location__r.LAD_Available_for_Delivery__c?'true':'false');
                        preferenceData.add(item);
                    }
            }
        }
        
        system.debug('preferenceData >>' + preferenceData);
        return preferenceData;
    }
    
            
/** @description :  This method  is used to get map Currency Codes symbol corrosponding to a currency.
*   @Story :        
*   @author:        (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   19-06-2024
*/
    @AuraEnabled
    public static string returnSymbol(string currencycode){
        Map<String, String> currencySymbolsByIsoCode = new Map<String, String>{
            'AUD' => 'A$',
                'GBP' => '£',
                'AWG' => 'ƒ',
                'BDT' => '৳',
                'CAD' => 'CAD$',
                'CNY' => '¥',
                'CRC' => '₡',
                'DKK' => 'kr',
                'EGP' => '£',
                'EUR' => '€',
                'FKP' => '£',
                'GBP' => '£',
                'GIP' => '£',
                'ILS' => '₪',
                'INR' => '₹',
                'ISK' => 'kr',
                'JPY' => '¥',
                'JPY' => '¥',
                'KHR' => '៛',
                'KRW' => '₩',
                'KZT' => '₸',
                'LBP' => '£',
                'NGN' => '₦',
                'NOK' => 'kr',
                'PHP' => '₱',
                'PYG' => '₲',
                'RUB' => '₽',
                'SDG' => '£',
                'SEK' => 'kr',
                'SHP' => '£',
                'SYP' => '£',
                'TRY' => '₺',
                'USD' => '$',
                '' => '¤' // The currency sign ¤ is a character used to denote an unspecified currency.
                };
                    return(currencySymbolsByIsoCode.get(currencycode));
    }
    
    //Binayak Method //
    @AuraEnabled
    public static List<Map<String, Object>> getProdLocAddresses(Id cartId) {
        system.debug('cartId>>'+cartId);
        List<Map<String, Object>> cartItems = new List<Map<String, Object>>();
        
        List<CartItem> cartItemsList = [SELECT Id, Name, Quantity, ListPrice, Product2Id, Product2.Name, Product2.Description, LAD_Associated_Location__c, LAD_Associated_Location__r.Location.Name
                                        FROM CartItem 
                                        WHERE CartId = :cartId];
        
        system.debug('cartItems list >>'+cartItemsList);
        List<Id> associatedLocationIds = new List<Id>();
        
        for (CartItem cartItem : cartItemsList) {
            associatedLocationIds.add(cartItem.LAD_Associated_Location__c);
        }
        //Retrieving all Associated Locations, Location Names and Assigned Addresses
        AssociatedLocation[] allLocations = [SELECT Id, LAD_Location_Type__c,Location.Name, (SELECT name,LAD_Is_default__c, lad_address__r.address FROM Assigned_Address__r) FROM AssociatedLocation WHERE Id IN :associatedLocationIds];
        //Map to store all assigned Addresses with Location Names as key
        Map<String, List<AddressWrapper>> locAddressMap= new Map<String, List<AddressWrapper>>();
        for(AssociatedLocation loc : allLocations ){
            List<AddressWrapper> addWrapList = new  List<AddressWrapper>();
            for(LAD_Assigned_Address__c add : loc.Assigned_Address__r){
                AddressWrapper addWrap = new AddressWrapper();
                addWrap.isDefault = add.LAD_Is_default__c;
                addWrap.address = add.lad_address__r.address;
                addWrapList.add(addWrap);
            }
            locAddressMap.put(loc.Location.Name, addWrapList);
        }
        
        for (CartItem cartItem : cartItemsList) {
            Map<String, Object> item = new Map<String, Object>();
            item.put('Id', cartItem.Id);
            item.put('Quantity', cartItem.Quantity);
            item.put('CartItemName', cartItem.Name);
            item.put('ProductId', cartItem.Product2Id);
            item.put('ProductName', cartItem.Product2.Name);
            item.put('ProductDescription', cartItem.Product2.Description);
            item.put('ListPrice', cartItem.ListPrice);
            item.put('ImageURL', '/img/b2b/default-product-image.svg');
            String location = cartItem.LAD_Associated_Location__r.Location.Name;
            item.put('Location', location);
            item.put('Addresses', locAddressMap.get(location));
            cartItems.add(item);
        }
        
        system.debug('cartItems map >>'+cartItems);
        return cartItems;
    }
    
    //Wrapper Class for Assigned Addresses
    public class AddressWrapper{
        //isDefault
        @auraenabled public boolean isDefault {get;set;}
        //addressId
        @auraenabled public string addressId{get;set;}
        //address
        @auraenabled public Address address {get;set;}
        //availableForDelivery
        @auraenabled public boolean availableForDelivery {get;set;}
    }
    
    public static String getConnectedapiData(){
        // String webstoreId = '0ZEFg00000180ofOAA';
        // String effectiveAccountId = '001Fg00000EWyHEIA1';
        // ConnectApi.ProductSearchInput productSearchInput = new ConnectApi.ProductSearchInput();
        // productSearchInput.searchTerm = 'Body';
        // ConnectApi.ProductSearchResults results = ConnectApi.CommerceSearch.searchProducts(webstoreId, effectiveAccountId, productSearchInput);
        
        String channelId = '0apFg00000007JGIAY';
        // String managedContentIds;
        Integer pageParam = 0;
        Integer pageSize = 25;
        String language = 'en_US';
        String managedContentType = 'cms_image';
        Boolean showAbsoluteUrl = true;
        Boolean includeMetadata = true;
        String startDate = '2011-02-25T18:24:31.000Z';
        String endDate = '2025-02-25T18:24:31.000Z';
        String contentKeyOrId = 'MCQ222OQMLM5BV5BB2OSLG44U57Q';
        String siteId ='0DMFg00000014eIOAQ';
        // ConnectApi.ManagedContentVersionCollection results = ConnectApi.ManagedContent.getAllContent(channelId, pageParam, pageSize, language, managedContentType, includeMetadata, startDate, endDate, showAbsoluteUrl);
        
        //ConnectApi.ManagedContentDeliveryDocument results = ConnectApi.ManagedContentDelivery.getManagedContentForChannel(channelId, contentKeyOrId, showAbsoluteUrl);
        ConnectApi.ManagedContentDeliveryDocument results = ConnectApi.ManagedContentDelivery.getManagedContentForSite(siteId, contentKeyOrId, showAbsoluteUrl);
        
        system.debug('connectapi results >>'+JSON.serialize(results));
        
        system.debug('connectapi results==>'+results.contentBody); 
        
        //unwrap contentBody field in res
        Map<String,Object> contentBody = (Map<String,Object>)ConnectApi.ConnectUtilities.unwrapApexWrapper(results.contentBody);
        
        //after contentBody field ApexWrapper is unwrapped, but image field still wrapped
        system.debug('contentBody'+contentBody);
        
        //before image field ApexWrapper is unwrapped 
        system.debug('get img >>'+contentBody.get('Image')); 
        
        //unwrap Image field in contentBody
        Map<String,Object> Image = (Map<String,Object>)ConnectApi.ConnectUtilities.unwrapApexWrapper(contentBody.get('Image'));
        
        //after image field ApexWrapper is unwrapped 
        system.debug('image >>'+Image); 
        return JSON.serialize(results);
    }
    
    @auraenabled
    public static List<cartitem> returnPrefilledData(string cartId){
        
        List<cartitem> cartitemdetails=[SELECT id,LAD_PO_Number__c,cart.LAD_Comment__c,cart.PoNumber,cartdeliverygroup.name,product2id,cartdeliverygroup.LAD_Address_Key__c, cartDeliveryGroup.LAD_Date_Selected_By_Customer__c FROM cartitem WHERE cartId=:cartId /* AND cartdeliverygroup.name!='Cart Delivery Group' */];
        
        return cartitemdetails;
    }
   
                
/** @description :  This method  is used to update PO details corrosponding to a cartItem
*   @Story :        
*   @author:        (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   19-06-2024
*/
    
    @auraenabled 
    public static void updatePoDetails(string cartItemId,string poNumber){
        cartItem getcartitem=[select id,LAD_PO_Number__c from cartitem where id=:cartItemId];
        getcartitem.LAD_PO_Number__c=poNumber;
        update getcartitem;
        
    }

/** @description :  This method  is used to create delivery groups and update cart items from checkout page.
*   @Story :        
*   @author:        (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   19-06-2024
*/
    
    @auraenabled
    public static void createDelGrp(string cartId,List<object> cartdetails,string cartComment,string cartPoNumber){
        system.debug(cartComment);        
        List<parsedataWrapper> cartinfo=new List<parsedataWrapper>();
        Map<string,object> cartItemsForCollectionDiscount=new Map<string,object>();
        Set<string> locationSet = new Set<string>();
        //Set of Assigned Address Ids
        Set<String> assignedAddressIdSet = new Set<String>();
        system.debug(cartdetails);
        Map<string,string> poMap = new Map<string,string>();
        
        
        //Arrange Cart Item Details into Cart Item Wrapper Object
        for(object i:cartdetails){
            Map<string,object> dataMap = (Map<string,object>)JSON.deserializeUntyped(JSON.serialize(i));
            
            parsedataWrapper instance=new parsedataWrapper();
            instance.location=(string)dataMap.get('location');
            instance.method=(string)dataMap.get('method');
            instance.address=(string)dataMap.get('address');
            instance.cartitemid=(string)dataMap.get('cartitemid');
            instance.deliverydate=(string)dataMap.get('deliverydate');
            instance.poNumber= (string)dataMap.get('poNumber');
            instance.preferredDate = (string)dataMap.get('preferredDate'); //FOUK-9758; FOUK-9759; FOUK-9940; FOUK-9941
            instance.invokeCollectionDiscount=(Boolean)dataMap.get('invokeCollectionDiscount'); //Collection Discount

            cartinfo.add(instance);
            locationSet.add((string)dataMap.get('location'));
            assignedAddressIdSet.add((string)dataMap.get('address'));
            poMap.put((string)dataMap.get('cartitemid'),(string)dataMap.get('poNumber'));
            
        } 

        //Fetch Existing Cart Details
        webcart fetchCartDetails=[select id, accountid,currencyisocode from webcart where id =:cartId];
        //Fetch All Associated Locations used in the Cart Items
        List<AssociatedLocation> associatedLocDetails=[SELECT Id,Location.name, ParentRecordid, Locationid FROM AssociatedLocation where ParentRecordid=:fetchCartDetails.AccountId and Location.name in :locationSet];
        //Map of all Cart Item Ids to Location Ids
       /*  Map<string,string> locationMap=new Map<string,string>();
        for(AssociatedLocation i:associatedLocDetails){          	
            locationMap.put(i.Location.name,i.Locationid);
        }  */

        

        //Map of all Cart Item Ids to Location Ids
        Map<string,string> cartItemIdLocationIdMap = new Map<string,string>();
        for(LAD_MDC_Preference__c mdc : [   SELECT  LAD_Associated_Location__r.LocationId, 
                                                    LAD_CartItem__c 
                                            FROM LAD_MDC_Preference__c 
                                            WHERE LAD_Associated_Location__r.ParentRecordId = :fetchCartDetails.AccountId 
                                            AND LAD_CartItem__c IN :poMap.keySet() AND LAD_Account__c = :fetchCartDetails.AccountId]){
            cartItemIdLocationIdMap.put(mdc.LAD_CartItem__c, mdc.LAD_Associated_Location__r.LocationId);
        }

        //Map of Location Id to Location Records
        Map<String, Schema.Location> locationIdLocationMap = new Map<String, Schema.Location>();
        for(Schema.Location l : [SELECT   Id,
                                        Name, 
                                        VisitorAddress.Street, 
                                        VisitorAddress.City, 
                                        VisitorAddress.State, 
                                        VisitorAddress.PostalCode, 
                                        VisitorAddress.Country 
                                FROM Location 
                                WHERE id IN :cartItemIdLocationIdMap.values()]){
            locationIdLocationMap.put(l.Id, l);
        }

        //Map of Assigned Address Id to Assigned Address Records
        Map<String, LAD_Assigned_Address__c> cartItemIdAssignedAddressMap = new Map<String, LAD_Assigned_Address__c>();
        for(LAD_Assigned_Address__c add: [SELECT    id,
                                                    name,
                                                    LAD_Address__r.Street, 
                                                    LAD_Address__r.City, 
                                                    LAD_Address__r.State, 
                                                    LAD_Address__r.PostalCode, 
                                                    LAD_Address__r.Country 
                                        FROM LAD_Assigned_Address__c 
                                        WHERE id IN : assignedAddressIdSet]){
            cartItemIdAssignedAddressMap.put(add.id, add);
        }

        //Map of Order Delivery Method Name to Id
        List<String> methodList = new List<String>{System.Label.LAD_LocationCheckCheckout_LaddawCollection, System.Label.LAD_LocationCheckCheckout_Laddaw_Delivery};
        Map<String, String> orderDelMethodNameIdMap = new Map<String, String>();
        for(OrderDeliveryMethod ord : [SELECT id, Name FROM OrderDeliveryMethod WHERE Name IN :methodList]){
            orderDelMethodNameIdMap.put(ord.Name, ord.Id);
        }
        //List of Cart Delivery Groups to be inserted 
        List<CartDeliveryGroup> cartItemDelGrpList=new List<CartDeliveryGroup>();            
        //Map of new Cart Delivery Groups Names to Id
        Map<string,string> cartdelfrpNamemapNew=new Map<String,string>();
        
            
        for(parsedataWrapper i:cartinfo){
            if(i.invokeCollectionDiscount){
                cartItemsForCollectionDiscount.put(i.cartitemid,i);
            }
            CartDeliveryGroup cartItemDelGrp=new CartDeliveryGroup();
            
            
            if(i.method==System.Label.LAD_LocationCheckCheckout_LaddawCollection){
                
                
                Schema.Location deliveryAddress = locationIdLocationMap.get(cartItemIdLocationIdMap.get(i.cartitemid));
                cartItemDelGrp.DeliverToStreet = deliveryAddress.VisitorAddress.Street;
                cartItemDelGrp.DeliverToCity = deliveryAddress.VisitorAddress.City;
                cartItemDelGrp.DeliverToState = deliveryAddress.VisitorAddress.State;
                cartItemDelGrp.DeliverToPostalCode = deliveryAddress.VisitorAddress.PostalCode;
                cartItemDelGrp.DeliverToCountry = deliveryAddress.VisitorAddress.Country;
                cartItemDelGrp.Name = i.location+'-'+i.method+'-'+deliveryAddress.id+'-'+i.preferredDate;
                cartItemDelGrp.DesiredDeliveryDate = date.valueof(i.deliverydate);
                cartItemDelGrp.LAD_Date_Selected_By_Customer__c  =  Date.valueOf(i.preferredDate); //FOUK-9758 & FOUK-9759
                cartItemDelGrp.LAD_Deliver_to_Location__c = cartItemIdLocationIdMap.get(i.cartitemid); //FOUK-10272
                cartItemDelGrp.cartId = cartId;
                cartItemDelGrp.LAD_Address_Key__c = deliveryAddress.id;
                
                cartItemDelGrp.DeliveryMethodId = orderDelMethodNameIdMap.get(i.method);

                cartdelfrpNamemapNew.put(i.cartitemid,cartItemDelGrp.Name);
                
            }else if(i.method==System.Label.LAD_LocationCheckCheckout_Laddaw_Delivery){
                LAD_Assigned_Address__c assignedAddressDetails = cartItemIdAssignedAddressMap.get(i.address);
                cartItemDelGrp.DeliverToStreet = assignedAddressDetails.LAD_Address__r.Street;
                cartItemDelGrp.DeliverToCity = assignedAddressDetails.LAD_Address__r.City;
                cartItemDelGrp.DeliverToState = assignedAddressDetails.LAD_Address__r.State;
                cartItemDelGrp.DeliverToPostalCode = assignedAddressDetails.LAD_Address__r.PostalCode;
                cartItemDelGrp.DeliverToCountry = assignedAddressDetails.LAD_Address__r.Country;
                cartItemDelGrp.Name = i.location+'-'+i.method+'-'+assignedAddressDetails.id+'-'+i.preferredDate;
                cartItemDelGrp.cartId = cartId;
                cartItemDelGrp.DesiredDeliveryDate = date.valueof(i.deliverydate);
                cartItemDelGrp.LAD_Deliver_to_Location__c = cartItemIdLocationIdMap.get(i.cartitemid); //FOUK-10272
                cartItemDelGrp.LAD_Address_Key__c = assignedAddressDetails.id;
                cartItemDelGrp.DeliveryMethodId = orderDelMethodNameIdMap.get(i.method);
                cartItemDelGrp.LAD_Date_Selected_By_Customer__c  =  Date.valueOf(i.preferredDate); //FOUK-9940 & FOUK-9941

                cartdelfrpNamemapNew.put(i.cartitemid,cartItemDelGrp.Name);                   
            }
            system.debug('<<CHECK>>');
            system.debug(cartItemDelGrp);
            cartItemDelGrpList.add(cartItemDelGrp);
            
        }
        system.debug(JSON.serialize(cartItemDelGrpList));
        
        system.debug(cartItemDelGrpList);
        
        system.debug(JSON.serialize(cartItemDelGrpList));
        //Insert all Cart Delivery Groups
        insert  cartItemDelGrpList;

        //Fetch all Cart Delivery Groups and Cart Items
        Map<string,string> delgroupNameIdMap = new map<string,string>();
        List<cartdeliverygroup> getdelgrp = [select id,name from cartdeliverygroup where cartid = :cartId];
        for(cartdeliverygroup o:getdelgrp){
            delgroupNameIdMap.put(o.name,o.id);
        }
        Set<id> deliverygrpinUse = new Set<id>();
        List<cartItem> fetchCartItems = [select id, CartDeliveryGroupId,LAD_Po_Number__c from cartitem where cartid = :cartId and product2.StockKeepingUnit!='PSER00405A'];
        system.debug(JSON.serialize(delgroupNameIdMap));
        system.debug(JSON.serialize(cartdelfrpNamemapNew));
        
        //Update Cart Items with Cart Delivery Groups inserted and PO Number value
        for(cartItem k:fetchCartItems){
            system.debug(JSON.serialize(k.id));
            system.debug(JSON.serialize(cartdelfrpNamemapNew.get(k.id)));
            system.debug(JSON.serialize(delgroupNameIdMap.get(cartdelfrpNamemapNew.get(k.id))));
            
            k.CartDeliveryGroupId = delgroupNameIdMap.get(cartdelfrpNamemapNew.get(k.id)); 
            k.LAD_PO_Number__c = poMap.get(k.id);
            deliverygrpinUse.add(delgroupNameIdMap.get(cartdelfrpNamemapNew.get(k.id)));
        }
        system.debug(JSON.serialize(deliverygrpinUse));
        update fetchCartItems;
		List<cartItem> DeliveryCostlist=[select id,CartDeliveryGroupId  from cartitem where product2.StockKeepingUnit!='PSER00405A'];
        if(DeliveryCostlist.size()!=0){
            deliverygrpinUse.add(DeliveryCostlist[0].CartDeliveryGroupId);
        }
        // Delete all Cart Delivery Groups not in use
        List<cartdeliverygroup> deleteList = [select id from cartdeliverygroup where cartid = :cartId and id not in : deliverygrpinUse];
        if(deleteList.size()!= 0){
            //delete deleteList;
        }

        //Update Cart with Additional Information and PO Number
        WebCart updatecart = new WebCart();
        updatecart.id = cartId;
        updatecart.LAD_Comment__c = cartComment;
        updatecart.PoNumber = cartPoNumber;
        update updatecart;
        
        Promotion collectionDiscountDetail=[select id,LAD_Discount_Type__c,LAD_Discount_Value__c,LAD_CanBeCombinedWithOtherPromotions__c from Promotion where LAD_Collection_Discount__c=true limit 1];
        system.debug(collectionDiscountDetail);
        if(collectionDiscountDetail.LAD_Discount_Type__c=='Amount'){
            invokeCollectionDiscountAmount(cartItemsForCollectionDiscount,cartId,collectionDiscountDetail.LAD_Discount_Value__c,collectionDiscountDetail.id,collectionDiscountDetail.LAD_CanBeCombinedWithOtherPromotions__c);
        }else if(collectionDiscountDetail.LAD_Discount_Type__c=='Percentage'){
            invokeCollectionDiscountPercentage(cartItemsForCollectionDiscount,cartId,collectionDiscountDetail.LAD_Discount_Value__c,collectionDiscountDetail.id,collectionDiscountDetail.LAD_CanBeCombinedWithOtherPromotions__c);
        }
        	
        
    }
    
    public static void invokeCollectionDiscountPercentage(Map<string,object> cartItemsForCollectionDiscount,string cartId,decimal discount,string causeId,boolean canBeCombined){
        List<CartItemPriceAdjustment> collectionDiscount=new List<CartItemPriceAdjustment>();
        List<cartitem> cartItemList=new  List<cartitem>();
        List<CartItemPriceAdjustment> getExistingPriceAdjustment=[select id,cartitemid,TotalAmount from CartItemPriceAdjustment where PriceAdjustmentCauseId=:causeId and cartid=:CartId];
        List<CartItemPriceAdjustment> getRemainingPriceAdjustment=[select id,cartitemid from CartItemPriceAdjustment where  cartid=:CartId and id not in :getExistingPriceAdjustment];
        Map<string,integer> cartItemCouponMap=new  Map<string,integer>();
        for(CartItemPriceAdjustment i:getRemainingPriceAdjustment){
            integer existingCounter=cartItemCouponMap.get(i.cartitemid)!=null?cartItemCouponMap.get(i.cartitemid):0;
            cartItemCouponMap.put(i.cartitemid,existingCounter+1);
        }
        
        Map<string,decimal> CartItemDiscountMap=new Map<string,decimal>();
        for(CartItemPriceAdjustment i:getExistingPriceAdjustment){
            CartItemDiscountMap.put(i.cartitemid,i.TotalAmount);
        }
        restorePriceAdjustmentAmount(CartItemDiscountMap);
        
        delete(getExistingPriceAdjustment);
        Map<id,cartitem> cartItemMap=new Map<id,cartItem>([select id,LAD_UnitPriceAdjustment__c,TotalAdjustmentAmount,TotalPromoAdjustmentAmount,TotalPriceAfterAllAdjustments,quantity,UnitAdjustmentAmount from cartitem where cartid=:cartId]);
        system.debug(cartItemsForCollectionDiscount);
        for(string i:cartItemsForCollectionDiscount.keyset()){
            if(cartItemCouponMap.get(i)==null ||(cartItemCouponMap.get(i)!=null && canBeCombined==true)){
                
            
            decimal finalDiscount=cartItemMap.get(i).TotalPriceAfterAllAdjustments*discount/100;
			collectionDiscount.add(new CartItemPriceAdjustment(Name='Collection Discount',
                                                           CartItemId = i,
                                                           TotalAmount= -(finalDiscount),
                                                           CurrencyIsoCode = 'GBP',
                                                           AdjustmentSource = 'Promotion',
                                                           AdjustmentValue = -(finalDiscount),
                                                           AdjustmentType = 'AdjustmentAmount',
                                                           PriceAdjustmentCauseId = causeId,
                                                           AdjustmentAmountScope='Total',
                                                           CartId = cartId,
                                                           AdjustmentTargetType = 'Item') );
            
            
            CartItem upItem = new CartItem(Id=i,
                              LAD_UnitPriceAdjustment__c= (cartItemMap.get(i).LAD_UnitPriceAdjustment__c!=null?cartItemMap.get(i).LAD_UnitPriceAdjustment__c:0)+(-(finalDiscount)),
                              TotalAdjustmentAmount =cartItemMap.get(i).TotalAdjustmentAmount+(-(finalDiscount)),
                              TotalPriceAfterAllAdjustments=cartItemMap.get(i).TotalPriceAfterAllAdjustments+(-(finalDiscount)),
                              TotalPromoAdjustmentAmount =cartItemMap.get(i).TotalPromoAdjustmentAmount+(-(finalDiscount)),
                              UnitAdjustmentAmount = cartItemMap.get(i).UnitAdjustmentAmount+(-(finalDiscount)));
			cartItemList.add(upItem);
                }
        }
        insert collectionDiscount;
        system.debug(collectionDiscount);
        update cartItemList;
        system.debug(cartItemList);
    }
    
    	
    public static void invokeCollectionDiscountAmount(Map<string,object> cartItemsForCollectionDiscount,string cartId,decimal discount,string causeId,boolean canBeCombined){
        try{
            List<CartItemPriceAdjustment> collectionDiscount=new List<CartItemPriceAdjustment>();
        List<cartitem> cartItemList=new  List<cartitem>();
        List<CartItemPriceAdjustment> getExistingPriceAdjustment=[select id,cartitemid,TotalAmount from CartItemPriceAdjustment where PriceAdjustmentCauseId=:causeId and cartid=:CartId];
        Map<string,decimal> CartItemDiscountMap=new Map<string,decimal>();
        for(CartItemPriceAdjustment i:getExistingPriceAdjustment){
            CartItemDiscountMap.put(i.cartitemid,i.TotalAmount);
        }
        
       List<CartItemPriceAdjustment> getRemainingPriceAdjustment=[select id,cartitemid from CartItemPriceAdjustment where  cartid=:CartId and id not in :getExistingPriceAdjustment];
        Map<string,integer> cartItemCouponMap=new  Map<string,integer>();
        for(CartItemPriceAdjustment i:getRemainingPriceAdjustment){
            integer existingCounter=cartItemCouponMap.get(i.cartitemid)!=null?cartItemCouponMap.get(i.cartitemid):0;
            cartItemCouponMap.put(i.cartitemid,existingCounter+1);
        }
            
            
            restorePriceAdjustmentAmount(CartItemDiscountMap);
        delete(getExistingPriceAdjustment);
        
        Map<id,cartitem> cartItemMap=new Map<id,cartItem>([select id,LAD_UnitPriceAdjustment__c,TotalAdjustmentAmount,TotalPromoAdjustmentAmount,UnitAdjustmentAmount,TotalPriceAfterAllAdjustments,quantity from cartitem where cartid=:cartId]);
        
        for(string i:cartItemsForCollectionDiscount.keyset()){
           if(cartItemCouponMap.get(i)==null ||(cartItemCouponMap.get(i)!=null && canBeCombined==true)){

            decimal quantityAdjusteddiscount=discount*cartItemMap.get(i).quantity;
			collectionDiscount.add(new CartItemPriceAdjustment(Name='Collection Discount',
                                                           CartItemId = i,
                                                           TotalAmount= -(quantityAdjusteddiscount),
                                                           CurrencyIsoCode = 'GBP',
                                                           AdjustmentSource = 'Promotion',
                                                           AdjustmentValue = -(quantityAdjusteddiscount),
                                                           AdjustmentType = 'AdjustmentAmount',
                                                           PriceAdjustmentCauseId = causeId,
                                                           AdjustmentAmountScope='Total',
                                                           CartId = cartId,
                                                           AdjustmentTargetType = 'Item') );
            
            
            CartItem upItem = new CartItem(Id=i,
                              LAD_UnitPriceAdjustment__c= (cartItemMap.get(i).LAD_UnitPriceAdjustment__c!=null?cartItemMap.get(i).LAD_UnitPriceAdjustment__c:0)+(-(quantityAdjusteddiscount)),
                              TotalAdjustmentAmount =cartItemMap.get(i).TotalAdjustmentAmount+(-(quantityAdjusteddiscount)),
                              TotalPriceAfterAllAdjustments=cartItemMap.get(i).TotalPriceAfterAllAdjustments+(-(quantityAdjusteddiscount)),
                              TotalPromoAdjustmentAmount =cartItemMap.get(i).TotalPromoAdjustmentAmount+(-(quantityAdjusteddiscount)),
                              UnitAdjustmentAmount = cartItemMap.get(i).UnitAdjustmentAmount+(-(quantityAdjusteddiscount)));
			cartItemList.add(upItem);
           }
        }
        insert collectionDiscount;
        update cartItemList;
             } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            
        }
    }
    
    public static void restorePriceAdjustmentAmount(Map<string,decimal> cartItemDiscountMap){
        List<cartitem> cartItemList= [select id,LAD_UnitPriceAdjustment__c,TotalAdjustmentAmount,TotalPromoAdjustmentAmount,UnitAdjustmentAmount,TotalPriceAfterAllAdjustments,quantity from cartitem where id in:cartItemDiscountMap.keyset()];
        for(cartitem i:cartItemList){
            i.LAD_UnitPriceAdjustment__c=i.LAD_UnitPriceAdjustment__c-cartItemDiscountMap.get(i.id);
            i.TotalAdjustmentAmount=i.TotalAdjustmentAmount-cartItemDiscountMap.get(i.id);
            i.TotalPriceAfterAllAdjustments=i.TotalPriceAfterAllAdjustments-cartItemDiscountMap.get(i.id);
            i.TotalPromoAdjustmentAmount=i.TotalPromoAdjustmentAmount-cartItemDiscountMap.get(i.id);
			i.UnitAdjustmentAmount=i.UnitAdjustmentAmount-cartItemDiscountMap.get(i.id);    
        }
        update cartItemList;
        
        
    }

    
/** @description :  This   is  a wrapper class used in createDelGrp.
*   @Story :        
*   @author:        (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   19-06-2024
*/
    public class parsedataWrapper{
        //cartId
        @auraenabled public string cartId {get;set;}
        //location
        @auraenabled  public string location {get;set;}
        //method
        @auraenabled  public string method {get;set;}
        //address
        @auraenabled  public string address {get;set;}
        //cartitemid
        @auraenabled  public string cartitemid {get;set;}
        //deliverydate
        @auraenabled  public string deliverydate {get;set;}
        //ponumber
        @auraenabled  public string  poNumber {get;set;}
        //cartPoNumber
        @auraenabled public string cartPoNumber{get;set;}
       
        //preferredDate FOUK-9758 & FOUK-9759
        @auraenabled public string preferredDate{get; set;}
        @auraenabled public boolean invokeCollectionDiscount{get;set;}

        
    }
    
    @auraenabled
    public static List<OrderItemSummary> returnOrderItems(string orderId){
        return [SELECT Id, Quantity, Product2Id, OrderSummaryId,OrderDeliveryGroupSummary.OrderDeliveryMethod.name FROM OrderItemSummary where OrderSummary.originalorderid = :orderId];
    }
      @auraEnabled
    public static string getWebStoreId(){
        return [select id from webstore where name='Laddaw' limit 1].id;
    }
    
    
    @auraenabled
    public static string checkIfCartExists(string userId,string effectiveAccountId){
        string accountId='';
        if(effectiveAccountId==null || effectiveAccountId==''){
            List<user> accidfromuser = [select id, AccountId  from user where id =:userid  limit 1];
            if (!accidfromuser.isEmpty()) {
                accountId = accidfromuser[0].AccountId;
            }
        }else{
            accountId=effectiveAccountId;
        }
        system.debug(accountId);
        List<webcart> fetchCart=[select id,LAD_Special_Order_Cart__c from webcart where accountId=:accountId and ownerId=:userId and status='Active'];
        system.debug(fetchCart);
        if(fetchCart.size()==0){
            system.debug('No Cart Exists');
            return 'No Cart Exists';
        }else if(fetchCart[0].LAD_Special_Order_Cart__c==false){
            system.debug('Not a special Order cart');

            return 'Not a special Order cart';
        }else{
            system.debug('Special Order cart');

            return 'Special Order cart';
        }
    }
    	@auraenabled

     public static void updateSpecialOrderflagOnCart(string userId,string effectiveAccountId){
        string accountId='';
        if(effectiveAccountId==null || effectiveAccountId==''){
            List<user> accidfromuser = [select id, AccountId  from user where id =:userid  limit 1];
            if (!accidfromuser.isEmpty()) {
                accountId = accidfromuser[0].AccountId;
            }
        }else{
            accountId=effectiveAccountId;
        }
        List<webcart> fetchCart=[select id,LAD_Special_Order_Cart__c from webcart where accountId=:accountId and ownerId=:userId and status='Active'];
       	fetchCart[0].LAD_Special_Order_Cart__c=true;
        update fetchCart;
    }




    /** @description :  Credit limit check
    *   @Story :        FOUK-FOUK-10647
    *   @author:        (hrithas.sardar@pwc.com (IN))
    *   @CreatedDate:   09-10-2024
    */
    @auraenabled
    public static string creditlimit(string accountId ,Id userId){
	
        Account fetchacc = [Select Id,LAD_Remaining_Credit_Balance__c from Account where Id =: accountId LIMIT 1];
        IdWrapper wrapperId = getCartId(userId, accountId);
       
        WebCart cartData = [SELECT Id, Name, Account.Name, Owner.Name, GrandTotalAmount FROM WebCart WHERE Id =: wrapperId.cartId];
      
       

        if(cartData.GrandTotalAmount > fetchacc.LAD_Remaining_Credit_Balance__c)
        {
           
            system.debug('CreditLimit'+ fetchacc.LAD_Remaining_Credit_Balance__c);
            system.debug('GrandTotalAmount'+cartData.GrandTotalAmount);
            system.debug('If true');
            return '1'+fetchacc.LAD_Remaining_Credit_Balance__c;
        }
           
        else {
            
            system.debug('CreditLimit'+ fetchacc.LAD_Remaining_Credit_Balance__c);
            system.debug('GrandTotalAmount'+cartData.GrandTotalAmount);
            system.debug('If false');
            return '0'+fetchacc.LAD_Remaining_Credit_Balance__c;
           
        }
       

    }

    @AuraEnabled
    public static string currencyfetch(string accountId ,Id userId){
        IdWrapper wrapperId = getCartId(userId, accountId);
       
        WebCart cartData = [SELECT Id,CurrencyIsoCode FROM WebCart WHERE Id =: wrapperId.cartId];
      
        return cartData.CurrencyIsoCode;
    }

    @auraenabled
    public static Id getAccId(string userid){
        try {
            system.debug('userid'+userid);
            Id accountId;
            List<user> accidfromuser = [select id, AccountId  from user where id =:userid  limit 1];
            if (!accidfromuser.isEmpty()) {
                accountId = accidfromuser[0].AccountId;
            }
            system.debug('accountId>>'+accountId);
            return accountId;
        } catch (Exception e) {
            // Handling the exceptions and log an error message
           
            return null;
        }
       
    } 

}