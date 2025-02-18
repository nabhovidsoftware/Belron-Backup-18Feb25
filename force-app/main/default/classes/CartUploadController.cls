/*
 * Copyright (c) 2021, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


/* description :  B2b LE cart Upload 
       			  This Class is Used to Add bulk product using CSV or from text area to the cart.
				  SKU and QTY is use as input from csv ot text area.
				  In this class we store UserId(Line 92) and product list(Line 472) required for MDC prefernce.	
	author:       (punam.patil@pwc.com (IN))
    Story:         FOUK-8487
	Create Date : 01/07/2024
*/


public with sharing class CartUploadController {
    public static List<String> productList=new List<String>();
    public static List<Decimal> productqty=new List<Decimal>();
	public static String uid;
    public static string cartIdforError;
    public static string AccountId;
    public static list <LAD_Upload_Error__c> insertError = new list <LAD_Upload_Error__c>();
   @AuraEnabled(cacheable=false)
   public static Map<String, Object> getInfo(String userId,String effectiveAccountId,String communityId, String webstoreId) {

        Map<String, Object> responseMap = new Map<String, Object>();
		uid=userId;
        AccountId=effectiveAccountId;
        if(webstoreId == null) {
            webstoreId = resolveCommunityIdToWebstoreId(communityId);
        }
		System.debug('webstoreId2: ' + webstoreId);
        
        User u = [select id,Contact.Accountid from User where id=:userId];
        effectiveAccountId=u.Contact.AccountId;
                //webstoreId='0ZE5j000000odITGAY'; 
        
        System.debug('effectiveAccountId: ' + effectiveAccountId);
        System.debug('userId: ' + userId+' uid:'+uid);
        System.debug('communityId: ' + communityId);
        System.debug('webstoreId: ' + webstoreId);
      
        
        String cartId = null;
        
        if(Test.isRunningTest() == false) {
            // Call the Connect Apex API

            if(effectiveAccountId != null && effectiveAccountId != '000000000000000'){
                ConnectApi.CartSummary cart = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webstoreId, effectiveAccountId, 'active');
                cartId = cart.cartId;
            }

        }
        system.debug('cartId-'+cartId);
        

        responseMap.put('cartId', cartId);
        responseMap.put('webstoreId', webstoreId);

        responseMap.put('maxUploadRows', B2BAddToCartUtil.MAX_UPLOAD_ROWS);
			
        return responseMap;

    }

    @AuraEnabled
    public static Map<String, Object> processData(
        String userId, 
        List<String> rows, 
        String webstoreId, 
        String effectiveAccountId, 
        String cartId, 
        Boolean hasHeaderRow, 
        Boolean ignoreInvalidSkus,
        Boolean emailResults) {
        System.debug('begin processData()');
           /* if(Test.isRunningTest() == True)
            {
                B2BAddToCartUtil.MAX_UPLOAD_ROWS = 1;
            }*/

        Long startTime = System.now().getTime();

        Map<String, Object> responseMap = new Map<String, Object>();

        Set<String> invalidSkuSet = new Set<String>();

        List<B2BAddToCartUtil.ImportItem> itemsList = new List<B2BAddToCartUtil.ImportItem>();

        System.debug('userId: ' + userId);
        System.debug('webstoreId: ' + webstoreId);
        System.debug('effectiveAccountId: ' + effectiveAccountId);
        System.debug('cartId: ' + cartId);
        System.debug('hasHeaderRow: ' + hasHeaderRow);
        System.debug('ignoreInvalidSkus: ' + ignoreInvalidSkus);
        System.debug('emailResults: ' + emailResults);
		uid=userId;
        AccountId=effectiveAccountId;    
            
         //assign cart id to store with error
        
        cartIdforError = cartId;
        system.debug('cartIdforError'+cartIdforError);    
            
        //Savepoint sp = Database.setSavepoint();

        try {

            String activeCartOrId = cartId;
             //String activeCartOrId = '0a6J4000000k9fKIAQ';

            List<ConnectApi.CartItemInput> linesToAdd = new List<ConnectApi.CartItemInput>();

            List<ConnectApi.BatchInput> batchInputList = new List<ConnectApi.BatchInput>();

            ConnectApi.BatchResult[] batchResults = null;

            itemsList = createItemList(rows, hasHeaderRow);

            System.debug('itemsList size = ' + itemsList.size());

            if (itemsList.size() > B2BAddToCartUtil.MAX_UPLOAD_ROWS) {

                
                System.debug('Too many rows error');

                B2BAddToCartUtil.addMessage(new B2BAddToCartUtil.Message(
                    Label.B2B_Cart_Upload_Processing_Error, 
                    Label.B2B_CU_Max_Upload_Rows_Exceeded.replace('{0}', B2BAddToCartUtil.MAX_UPLOAD_ROWS.format()), 
                    B2BAddToCartUtil.ERROR), 
                    0, responseMap);

                    B2BAddToCartUtil.updateResponseMapTotalValue('totErrors', 1, responseMap);

                throw new CustomException('Too many rows');

            }

            invalidSkuSet = verifySkus(itemsList, responseMap, webstoreId, effectiveAccountId);

            System.debug('invalidSkuSet size = ' + invalidSkuSet.size());

            if (invalidSkuSet.size() > 0) {

                // Invalid SKUs aren't included in subsequent processing, so totErrors is updated here.
                B2BAddToCartUtil.updateResponseMapTotalValue('totErrors', invalidSkuSet.size(), responseMap);

                processInvalidSkus(itemsList, responseMap, ignoreInvalidSkus);

                if (ignoreInvalidSkus == false) {

                    B2BAddToCartUtil.addMessage(new B2BAddToCartUtil.Message(
                        Label.B2B_CU_Invalid_SKUs_found, 
                        Label.B2B_CU_Please_correct_the_invalid_SKUs_and_resubmit, 
                        B2BAddToCartUtil.ERROR), 
                        0, responseMap);

                    throw new CustomException('Invalid SKUs');

                }

            }

            linesToAdd = createCartItems(itemsList, responseMap);

            System.debug('linesToAdd size = ' + linesToAdd.size());

            batchInputList = createBatchInputLines(linesToAdd, responseMap);

            System.debug('batchInputList size = ' + batchInputList.size());

            if(batchInputList.size() <= B2BAddToCartUtil.ADD_TO_CART_MAX) {

                if(Test.isRunningTest() == false) {

                    // This will only work if there are less than 100 items in the input file.
                    // If the cart will contain more than 500 items, an error will be thrown.
                    batchResults = B2BAddToCartUtil.addItemsToCart(webstoreId, effectiveAccountId, activeCartOrId, batchInputList);

                    System.debug('batchResults: ' + JSON.serialize(batchResults));

                    System.debug('batchResults size = ' + batchResults.size());

                    B2BAddToCartUtil.processBatchResults(batchResults, itemsList, responseMap);

                    responseMap.put('totItems', batchInputList.size());
                }
                else {

                    B2BAddToCartUtil.processBatchResults(batchResults, itemsList, responseMap);

                    // Pretend we called the Connect Api
                    responseMap.put('totItems', linesToAdd.size());
                }

            }
            else {

                List<B2BAddToCartUtil.ImportItem> processedItemsList = addItemsToCartInBatches(webstoreId, effectiveAccountId, activeCartOrId, batchInputList, itemsList, responseMap);
                itemsList = processedItemsList;
                
            }

            Integer totErrors = (Integer)responseMap.get('totErrors');
            if(totErrors > 0) {
                processAddToCartErrors(itemsList, responseMap);
            }

        }
        catch (CustomException ce) {}
        catch (Exception err) {

            //System.debug('rolling back transactions');
            //Database.rollback(sp);

            System.debug(Label.B2B_Cart_Upload_Processing_Error + ': ' + err.getMessage());
            System.debug('Line #: ' + err.getLineNumber());
            System.debug(err.getStackTraceString());

            B2BAddToCartUtil.addMessage(new B2BAddToCartUtil.Message( 
                    Label.B2B_Cart_Upload_Processing_Error, 
                    err.getMessage(), 
                    B2BAddToCartUtil.ERROR), 
                    0, responseMap);

            B2BAddToCartUtil.updateResponseMapTotalValue('totErrors', 1, responseMap);

        } finally {
                
            Integer totErrors = (Integer)responseMap.get('totErrors');
            Integer totSuccess = (Integer)responseMap.get('totSuccess');

            if(totErrors > 0) {

                B2BAddToCartUtil.addMessage(new B2BAddToCartUtil.Message(
                    Label.B2B_Cart_Upload_Processing_Error, 
                    Label.B2B_Items_not_added_to_cart.replace('{0}', totErrors.format()), 
                    B2BAddToCartUtil.ERROR,
                    true), 
                    0, responseMap);

            }

            if(totSuccess > 0) {

                B2BAddToCartUtil.addMessage(new B2BAddToCartUtil.Message(
                    Label.B2B_Add_to_cart_processing_complete, 
                    Label.B2B_Items_added_to_cart_successfully.replace('{0}', totSuccess.format()), 
                    B2BAddToCartUtil.SUCCESS,
                    true), 
                    0, responseMap);
            }

            List<B2BAddToCartUtil.Message> retMessages = (List<B2BAddToCartUtil.Message>)responseMap.get('messages');

            String messagesJson = JSON.serialize(retMessages);
            System.debug('messagesJson: ' + messagesJson);
            responseMap.put('messagesJson', messagesJson);

            if(emailResults) {
                sendEmailSummary(itemsList, responseMap, userId);
            }

            Long endTime = System.now().getTime();

            Long milliseconds = endTime - startTime;
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            Long hours = minutes / 60;
            Long days = hours / 24;

            System.debug('execution time: ' + (days > 0 ? days + ' days, ' : '') + (hours > 0 ? hours + ' hours, ' : '') + (minutes > 0 ? minutes + ' minutes, ' : '') + (seconds > 0 ? seconds + ' seconds, ' : '') + milliseconds + ' milliseconds');


            System.debug('--- processData() exit');
        }

        return responseMap;

    }

    /*
        Process each line uploaded by the user.
        Creates an ImportItem object for each line.
        Returns a list of ImportItem objects.
    */
    private static List<B2BAddToCartUtil.ImportItem> createItemList(List<String> lines, Boolean hasHeaderRow) {

        System.debug('--- createItemList() begin');

        List<B2BAddToCartUtil.ImportItem> itemsList = new List<B2BAddToCartUtil.ImportItem>();

        Map<String, B2BAddToCartUtil.ImportItem> skuMap = new Map<String, B2BAddToCartUtil.ImportItem>();

        // Only skip the first row when hasHeaderRow is true
        boolean isFirst = hasHeaderRow ? true : false;

        Integer row = 0;

        for (String singleLine : lines) {

            row++;

            //System.debug('Parsing line: ' + singleLine);

            if(singleLine.length() <= 0) {
                continue;
            }

            // Skip the header row

            if (isFirst) {
                isFirst = false;
                continue;
            }

            List<String> values = singleLine.split(',');
           // System.debug('values-----' + values);
           //  System.debug('values-----1--' + values[0]);
           //  System.debug('values-----2--' + values[1]);
           //  System.debug('values-----3--' + values[2]);

            if (values[1] != null) {

                String sku = values[1];
                 System.debug('values-----SKU--' + sku);
                
                 // po
                string po;
                Decimal qty;
                 System.debug('values-----values.size1() --' +values.size() );
                if (values.size() == 1 || String.isEmpty(values[0]) || String.isBlank(values[0])|| values[0] == null) {
                    po = '';
                } else {
                    po = values[0].trim();
                }

                 System.debug('values-----values.size2() --' +values.size() );
               // System.debug('values-----String.isEmpty(values[2]) --' +String.isEmpty(values[2]) );
                //System.debug('values-----String.isBlank(values[2]) --' +String.isBlank(values[2]) );
                
                if (values.size() == 2||String.isEmpty(values[2]) || String.isBlank(values[2])) {
                    
                    system.debug('QTY here');  
                    
                    qty = 1;
                    
                } else {
                    if(Decimal.valueOf(values[2].trim())>0){
                   
                   
                        qty = Decimal.valueOf(values[2].trim());
                 
                     }
                    else
                    {
                         qty = Decimal.valueOf(values[2].trim());
                         LAD_Upload_Error__c er= new LAD_Upload_Error__c();
                                    er.LAD_SKU__c = sku;
                                    er.LAD_Row__c = row;
                                    er.LAD_Qty__c = Decimal.valueOf(values[2].trim());
                                    er.LAD_Cart__c = cartIdforError;
                                    //er.LAD_Description__c= 'Quantity on SKU:'+sku+' '+'is Negative ['+ Decimal.valueOf(values[2].trim())+']';
                        			er.LAD_Description__c = sku+': Could not add cart item because: Argument : quantity ['+ Decimal.valueOf(values[2].trim()) +'] in the commerce.cart.AddItemRequest is not currently supported.';
	
                                  insertError.add(er);
                    }
                
                }   

                B2BAddToCartUtil.ImportItem item = null;

                if(skuMap.containsKey(sku)) {
                    item = skuMap.get(sku);
                    item.qty += qty;
                }
                else {
                    item = new B2BAddToCartUtil.ImportItem();
                    item.row = row;
                    item.sku = sku;
                    item.qty = qty;
                    item.po = po;
                 }

                skuMap.put(sku, item);

            }
            
        }

        itemsList.addAll(skuMap.values());

        //System.debug(JSON.serialize(itemsList));
        System.debug('LinesToAdd as itemsList'+ JSON.serialize(itemsList));

        return itemsList;

    }

    /*
        Verifies that each SKU in the input is contained in the product search index.
        This does not take into account data changes within the org that have not yet been reflected in the product search index.
    */
    private static Set<String> verifySkus(List<B2BAddToCartUtil.ImportItem> itemsList, Map<String, Object> responseMap, String webstoreId, String effectiveAccountId) {

        System.debug('--- verifySkus() begin');

        List<String> skuList = new List<String>();
        Set<String> invalidSkuSet = new Set<String>();

        Map<String, Object> fetchInputData = new Map<String, Object>();

        // Get all SKUs from the items List

        for(B2BAddToCartUtil.ImportItem item : itemsList) {
            skuList.add(item.sku);
        }

        System.debug('skus: ' + skuList);

        System.debug('verifying product SKUs...');
                    

        Map<String, String> validSkuMap = B2BProductEntitlementCheck.productSearch(skuList, webstoreId, effectiveAccountId, 50);

        Set<String> validSkuSet = new Set<String>();

        // Verify each SKU in the item List has a matching Product2 record.
        
		//list<string> ProductValidId = new list<string>();
        for(B2BAddToCartUtil.ImportItem item : itemsList) {
            String sku = item.sku;

            if(validSkuMap.containsKey(sku)) {

                item.isValid = true;
                item.productId = validSkuMap.get(sku);
                //ProductValidId.add( item.productId);
            }
            else {
                invalidSkuSet.add(sku);

               // String msg = 'Invalid SKU: ' + sku;
               
                String msg = sku;

                System.debug(msg);

                item.isSuccess = false;
                item.errorMsg = 'SKU is not valid';
            }
        }

        responseMap.put('totUniqueSkus', validSkuMap.size());
        responseMap.put('totInvalidSkus', invalidSkuSet.size());
        
        System.debug('--- validSkuMap'+validSkuMap);

        System.debug('--- invalidSkuSet'+invalidSkuSet);
        System.debug('--- itemsList'+itemsList);
        
        return invalidSkuSet;

    }

    private static void processInvalidSkus(List<B2BAddToCartUtil.ImportItem> itemsList, Map<String, Object> responseMap, Boolean ignoreInvalidSkus) {
        //Add Error in Object
        //
        
        for(B2BAddToCartUtil.ImportItem item : itemsList) {
            
            if(item.isValid == false) {
                
                
                LAD_Upload_Error__c er= new LAD_Upload_Error__c();
                er.LAD_SKU__c = item.sku;
                er.LAD_Row__c = item.row;
                er.LAD_Qty__c = item.qty;
                er.LAD_Cart__c = cartIdforError;
                er.LAD_Description__c= item.sku+' '+item.errorMsg;
                  insertError.add(er);

                String sku = item.sku;

                String msg = Label.B2B_Invalid_SKU + ' ' + sku;

                B2BAddToCartUtil.addMessage(new B2BAddToCartUtil.Message(
                    Label.B2B_SKU_is_not_valid, 
                    msg, 
                    (ignoreInvalidSkus ? B2BAddToCartUtil.WARN : B2BAddToCartUtil.ERROR),
                    false), 
                    0, responseMap);
            }
            
        }
     // insert insertError;
    
               
    } 

    private static void processAddToCartErrors(List<B2BAddToCartUtil.ImportItem> itemsList, Map<String, Object> responseMap) {
        
        for(B2BAddToCartUtil.ImportItem item : itemsList) {
        
            // Only add an error message when the SKU was valid.
            
            if(item.isValid && item.isSuccess == false) {

                B2BAddToCartUtil.addMessage(new B2BAddToCartUtil.Message(
                    Label.B2B_Add_to_cart_error, 
                    item.sku + ': ' + item.errorMsg, 
                    B2BAddToCartUtil.ERROR,
                    false), 
                    0, responseMap);
            }
            
        }

    }

    /*
        Creates a CartItemInput object for each item.
    */
    private static List<ConnectApi.CartItemInput> createCartItems(List<B2BAddToCartUtil.ImportItem> itemsList, Map<String, Object> responseMap) {

        System.debug('--- createCartItems() begin');
        system.debug('createCartItems itemsList'+itemsList);

        List<ConnectApi.CartItemInput> linesToAdd = new List<ConnectApi.CartItemInput>();
        
        //Set<String> invalidSkuProductId = new Set<String>();
        
        //run for loop on itemsList and generate product id list
        for(B2BAddToCartUtil.ImportItem item : itemsList)
        {
              //changes
              if(item.productId !=null)
              {  
                productList.add(item.productId);
              }    
               // productqty.add(item.qty);
                system.debug('productList--'+productList);
        }
            //Call Availability Check based on product id list
                    LAD_ReturnAssociatedLocationDetails.productDetailWrapper productDetails = new LAD_ReturnAssociatedLocationDetails.productDetailWrapper();
                    productDetails.effectiveAccountId=AccountId;
                    productDetails.location= Null;
                    productDetails.productIdList=productList;
                    productDetails.quantity= 10;
                    productDetails.userId=uid;
                    
                    list<LAD_ReturnAssociatedLocationDetails.HttpResponseWrapper> HTTPResponseData = LAD_ReturnAssociatedLocationDetails.getProductAvailability(productDetails);
        			
                    system.debug ('HTTPResponse for stock'+ HTTPResponseData);
        			
                    Map<Id,LAD_ReturnAssociatedLocationDetails.HttpResponseWrapper> HTTpData = new Map<Id, LAD_ReturnAssociatedLocationDetails.HttpResponseWrapper>();
                    
                    for(LAD_ReturnAssociatedLocationDetails.HttpResponseWrapper hData: HTTPResponseData){                      
                                      
                        	HTTpData.put(hData.productId,hData);                  
                    }
                    system.debug('HTTPdata'+HTTpData);  
        
        			if(Test.isRunningTest() == true)
                            {
                               for (B2BAddToCartUtil.ImportItem item : itemsList) {
                                if(item.isValid)
                                {
                                	List<SObject> cartItemList = new List<SObject>();
                                    CartItem cartItem = new CartItem();
                                    cartItem.LAD_PO_Number__c = item.po;
                                    cartItemList.add(cartItem);
                                  
                                    ConnectApi.CartItemInput lineToAdd = new ConnectApi.CartItemInput();
            
                                    lineToAdd.productId = item.productId;
                                    lineToAdd.quantity = item.qty.toPlainString();
                                    lineToAdd.type = ConnectApi.CartItemType.Product;
                            
                                    //add po
                                    lineToAdd.customFields = cartItemList;
                    
                                    System.debug('lineToAdd: ' + lineToAdd);
                    
                                    linesToAdd.add(lineToAdd);
                                }      
                            }
                                return linesToAdd;
                          }
        
                    for (B2BAddToCartUtil.ImportItem item : itemsList) {
                        if(item.isValid)
                        {
                            LAD_ReturnAssociatedLocationDetails.HttpResponseWrapper httpRData =HTTpData.get(item.productId);
                            if(httpRData != null)
                            {	
                               system.debug('HTTPResponseData avlStatus'+httpRData.primarylocations[0].avlStatus);
                                 
                                //if(httpRData.primarylocations[0].avlStatus == System.Label.LAD_LocationCheckPDP_AvailableDeliveryOrCollection)
                                if(!httpRData.primarylocations[0].avlStatus.toLowerCase().contains('not'))    
                                {
                                    system.debug('HTTPResponseData productId'+httpRData.productId+' '+'Item product Id'+item.productId);
                                    system.debug('HTTPResponseData sku'+item.sku);
                                    
                                     //add custom field LAD_PO_Number__c to ConnectApi.CartItemInput
                                    List<SObject> cartItemList = new List<SObject>();
                                    CartItem cartItem = new CartItem();
                                    cartItem.LAD_PO_Number__c = item.po;
                                    cartItemList.add(cartItem);
                                  
                                    ConnectApi.CartItemInput lineToAdd = new ConnectApi.CartItemInput();
            
                                    lineToAdd.productId = item.productId;
                                    lineToAdd.quantity = item.qty.toPlainString();
                                    lineToAdd.type = ConnectApi.CartItemType.Product;
                            
                                    //add po
                                    lineToAdd.customFields = cartItemList;
                    
                                    System.debug('lineToAdd: ' + lineToAdd);
                    
                                    linesToAdd.add(lineToAdd);
                                       
                                }
                                else if(httpRData.primarylocations[0].avlStatus.toLowerCase().contains('not'))
                                {
                                
                                		system.debug('count else');
                                    
                    				  //if Product is out of stock
                             		
                                    B2BAddToCartUtil.addMessage(new B2BAddToCartUtil.Message(
                                    Label.B2b_Product_Stock, 
                                    'Stock'+item.sku, 
                                    B2BAddToCartUtil.ERROR,
                                    false), 
                                    0, responseMap);
                                    
                                    LAD_Upload_Error__c er= new LAD_Upload_Error__c();
                                    er.LAD_SKU__c = item.sku;
                                    er.LAD_Row__c = item.row;
                                    er.LAD_Qty__c = item.qty;
                                    er.LAD_Cart__c = cartIdforError;
                                    er.LAD_Description__c= item.sku+' '+'Product Out of Stock';
                                  insertError.add(er);
                                     
                                 }
                               }
                           }                 
                         }
             			     
        
        
        //in the below for loop, first verify from availability fetched above, if the specific product id is available or not, if not, then don't create cart item and 
        // do error handling, if available proceed as usual.
        /* for (B2BAddToCartUtil.ImportItem item : itemsList) {
            
             //Boolean shouldBreak = false;

            //System.debug('item: ' + item)
            //
          // System.debug('item isValid' + item.productId +'  '+'avlStatus productId'+h.productId);
           
               // system.debug('HTTPResponseData avlStatus'+h.primarylocations[0].avlStatus);
          
            if(item.isValid) {
                
             for(LAD_ReturnAssociatedLocationDetails.HttpResponseWrapper h: HTTPResponseData){
                      system.debug('count here');
              if((h.primarylocations[0].avlStatus == System.Label.LAD_LocationCheckPDP_AvailableDeliveryOrCollection)&& h != null && (item.productId == h.productId)){   
                    system.debug('count if');
                             
                 //add custom field LAD_PO_Number__c to ConnectApi.CartItemInput 
                List<SObject> cartItemList = new List<SObject>();
   			    CartItem cartItem = new CartItem();
                cartItem.LAD_PO_Number__c = item.po;
                cartItemList.add(cartItem);
                      
                ConnectApi.CartItemInput lineToAdd = new ConnectApi.CartItemInput();

                lineToAdd.productId = item.productId;
                lineToAdd.quantity = item.qty.toPlainString();
                lineToAdd.type = ConnectApi.CartItemType.Product;
                
                //add po
                lineToAdd.customFields = cartItemList;

                System.debug('lineToAdd: ' + lineToAdd);

                linesToAdd.add(lineToAdd);
                   // shouldBreak = true;
                   // break;
                }
                else if(h.primarylocations[0].avlStatus == System.Label.LAD_LocationCheckPDP_NotAvailable)
                  {
                      
                      system.debug('count else');
                      //if Product is out of stock
                             
                    B2BAddToCartUtil.addMessage(new B2BAddToCartUtil.Message(
                    'Product Out of Stock', 
                    item.sku + ': ' + 'Product Out of Stock', 
                    B2BAddToCartUtil.ERROR,
                    false), 
                    0, responseMap);
                    
                    LAD_Upload_Error__c er= new LAD_Upload_Error__c();
                    er.LAD_SKU__c = item.sku;
                    er.LAD_Row__c = item.row;
                    er.LAD_Qty__c = item.qty;
                    er.LAD_Cart__c = cartIdforError;
                    er.LAD_Description__c= item.sku+' '+'Product Out of Stock';
                  insertError.add(er);
                                     
                  }
              }
                
                  
            }
            
            
                         
                
        }*/

        System.debug('size = ' + linesToAdd.size());

        System.debug('--- createCartItems() exit');     
        
        insert insertError;

        return linesToAdd;

    }

    /*
        Creates a BatchInput object for each CartInputItem.
        Returns a list of BatchInput objects.
    */
    private static List<ConnectApi.BatchInput> createBatchInputLines(List<ConnectApi.CartItemInput> linesToAdd, Map<String, Object> responseMap) {

        System.debug('--- createBatchInputLines() begin');

        List<ConnectApi.BatchInput> batchInputList = new List<ConnectApi.BatchInput>();

        for (ConnectApi.CartItemInput item : linesToAdd) {
            system.debug('item in 636'+item);
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(item);
            system.debug('batchInput in 638'+batchInput);
            batchInputList.add(batchInput);
        }

        System.debug('batchInputList.size: ' + batchInputList.size());

        System.debug('--- createBatchInputLines() exit');

        return batchInputList;

    }

    /*
        Adds the items to the cart synchronously, in bundles of 100 items.
    */
    private static List<B2BAddToCartUtil.ImportItem> addItemsToCartInBatches(String webstoreId, String effectiveAccountId, String activeCartOrId, List<ConnectApi.BatchInput> batchInputList, List<B2BAddToCartUtil.ImportItem> itemsList, Map<String, Object> responseMap) {

        List<B2BAddToCartUtil.ImportItem> processedItemsList = B2BAddToCartUtil.processBatchInputItems(webstoreId, effectiveAccountId, activeCartOrId, batchInputList, itemsList, responseMap);

        Integer totBatches = (Integer)responseMap.get('totBatches');

        responseMap.put('batchCount', totBatches);
        
        
        return processedItemsList;
    }

    private static void sendEmailSummary(List<B2BAddToCartUtil.ImportItem> itemsList, Map<String, Object> responseMap, String userId) {

        String emailBody = '';

        Integer totErr = 0;
        Integer totProc = itemsList.size();

        List<B2BAddToCartUtil.Message> messages = (List<B2BAddToCartUtil.Message>)responseMap.get('messages');

        for(B2BAddToCartUtil.Message msg : messages) {
            emailBody += '<p>' + msg.message + '</p>';
        }

        String subject = Label.B2B_Add_to_cart_subject;

        String emailAddress = B2BAddToCartUtil.getUserEmailAddress(userId);

        B2BAddToCartUtil.sendEmailMsg(subject, emailBody, emailAddress);

    }

    /*
        This method is used to convert the community Id to the web store Id.
    */
    public static String resolveCommunityIdToWebstoreId(String communityId) {
        if(communityId == null || communityId == '') {
            return null;
        }
        
        String webstoreId = null;

        if(Schema.sObjectType.WebStoreNetwork.fields.WebStoreId.isAccessible()
            && Schema.sObjectType.WebStoreNetwork.fields.NetworkId.isAccessible()) {
            List<WebStoreNetwork> wsnList = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId];

            if(wsnList.size() > 0) {
                WebStoreNetwork wsn = wsnList.get(0);
                webstoreId = wsn.WebStoreId;
            }
        }

        return webstoreId;
    }

    public class CustomException extends Exception {}

}