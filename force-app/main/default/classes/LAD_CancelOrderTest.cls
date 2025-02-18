@isTest
public class LAD_CancelOrderTest {

    @istest
    public static void getFieldsTest(){
        
        
        LAD_CancelOrder.getOrderProductDetails('test');
        LAD_CancelOrder.createPlatformEvent('Test');
        LAD_CancelOrder.checkSpecialOrder('Test');
        LAD_CancelOrderWrapper test =new LAD_CancelOrderWrapper();
        test.orderproductSummaryId='abc';
        test.reasonForCancellation='pqr';
    }
}