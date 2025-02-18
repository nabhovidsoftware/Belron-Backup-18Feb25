/**@description : The Apex class handle Stock Check-In Process
*  @author: Sapna Teltumade
*  @Story: FOUK-4139
*  @CreatedDate: 02/01/2024
*/
public with Sharing class BLN_StockCheckInList {
    
    @AuraEnabled(Cacheable = false)
    public static string returnData(){ 
        list<bln_stockcheckinlistutility.wrapperList> l = new list<bln_stockcheckinlistutility.wrapperList>();
        l = BLN_StockCheckInListUtility.stockCheckIn();
        system.debug('data : '+l);
        return JSON.serialize(l);
    }
    
    @AuraEnabled(Cacheable = false)
    public static boolean createPT(string wrapperData){
        system.debug('sdfsdfs '+wrapperData);
        boolean result = false;
        
        if(!string.isBlank(wrapperData)){
            ID mainWoliId;
            BLN_StockCheckInListUtility.productData pdWrapper = (BLN_StockCheckInListUtility.productData)JSON.deserialize(wrapperData, BLN_StockCheckInListUtility.productData.class);
            
            /* Create Product Transfer */
            ProductTransfer pt = BLN_StockCheckInListUtility.createPT(pdWrapper);
            system.debug('PT record to be created : '+pt);
            
            insert pt;
            system.debug('PT record is created successfully.');
            
            /* Update Product Item 
            productItem PI = BLN_StockCheckInListUtility.updateProductItem(pdWrapper, pt);
            system.debug('PI record to be updated : '+PI);
            update PI;*/ 
            
            /* Update Product Required */
            productRequired productReq = BLN_StockCheckInListUtility.updateProductRequired(pdWrapper, pt);
            system.debug('PR record to be updated : '+productReq);
            
            update productReq;
            system.debug('PR record is updated successfully.');
            /* Check All Product Required Completed Condition and update WOLI */
            boolean prChecked = BLN_StockCheckInListUtility.checkAllPrCompleted(pdWrapper);
            system.debug('prcheckd mained :'+prChecked);
            if(prChecked == TRUE){
                workOrderLineItem woli = BLN_StockCheckInListUtility.updateWoli(pdWrapper);
                system.debug('WOLI record to be updated : '+woli);
                update woli;
                system.debug('WOLI is updated successfully.');
            }
            result = true;
        }
        return result;
    }
}