@isTest
public class BLN_StockCheckInListTest {
    @testSetup
    public static void makeSetupData(){
        Schema.Location locations = new Schema.Location();
        locations.Name = 'Test Data';
        locations.LocationType = 'Van';
        locations.IsMobile = true;
        locations.IsInventoryLocation = true;
        insert locations;
        
        ServiceResource sr = BLN_TestDataFactory.createServiceResource('Test Resource',true);
        sr.LocationId = locations.Id;
        sr.relatedrecordId = userinfo.getuserId();
        update sr;
        
        WorkType workType = BLN_TestDataFactory.createWorkType('Replacement', 1.0, true, true);
        WorkOrder workOrder = BLN_TestDataFactory.createWorkOrder(false);
        workOrder.status = 'completed';
        insert workOrder;
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        //wOLI.BLN_RemedyTaskId__c = '5454545';
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrder.id;
        wOLI.status = 'Completed';
        wOLI.BLN_IsStockCheckInCompleted__c = false;
        insert wOLI;  
        
        ServiceTerritory servicesTerritories = BLN_TestDataFactory.createServiceTerritories('ST Test', true);
        ServiceAppointment servApp = BLN_TestDataFactory.createServiceAppntmnt('Replacement', True);
        servApp.BLN_WorkOrderLineItem__c = wOLI.Id;
        servApp.WorkTypeId = workType.Id;
        servApp.BLN_WorkOrderNumber__c = workOrder.Id;
        servApp.BLN_AssignedServiceResource__c = sr.ID;
        update servApp;
        ServiceAppointment st = [Select Id,BLN_WorkOrderLineItem__c from ServiceAppointment where Id=: servApp.ID];
        
        Product2 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'W-001';
        insert product;
        
        ProductRequired productReq = new ProductRequired();
        productReq.parentrecordid = wOLI.id;
        productReq.Product2Id = product.Id;
        productReq.QuantityRequired = 6;
        insert productReq;
    }
    @isTest
    public static void stockCheckInTest(){
        test.startTest();
        String recievedProduct = BLN_StockCheckInList.returnData();
        list<BLN_StockCheckInListUtility.WrapperList> pdWrapper = (list<BLN_StockCheckInListUtility.WrapperList>)JSON.deserialize(recievedProduct, list<BLN_StockCheckInListUtility.WrapperList>.class);
        system.debug('wdrapmmer '+pdWrapper);
        string selectedProduct;
        for(BLN_StockCheckInListUtility.WrapperList w : pdWrapper){
            for(BLN_StockCheckInListUtility.UnusedProductsOptions options : w.unUsedProductLists){
                selectedProduct = options.value;
            }
        }
        boolean b = BLN_StockCheckInList.createPT(selectedProduct);
        
        
        test.stopTest(); 
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
@isTest
static void myUnitTest() {
ServiceResource sr = BLN_TestDataFactory.createServiceResource('Test Resource',true);
List<Schema.Location> records = [SELECT Name,LocationType FROM Location where LocationType = 'Van'];
System.debug(records);
Schema.Location lo = new Schema.Location();
lo.Id = sr.LocationId;
lo.Name = 'test name';
lo.LocationType = 'Van';
lo.IsInventoryLocation = true;
lo.IsMobile = true;
insert lo;
sr.LocationId = lo.Id;
sr.relatedrecordId = userinfo.getuserId();
update sr;

ProductRequired prodReq = new ProductRequired();
prodReq


test.startTest();
BLN_StockCheckInList.returnData();
// BLN_StockCheckInList.createPT('Test String');
test.stopTest();
}
*/
}