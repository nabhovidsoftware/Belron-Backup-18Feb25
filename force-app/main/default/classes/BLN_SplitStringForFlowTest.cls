/* Created by : Animesh Biswas (PwC-IN)
 * Used in :To cover BLN_SplitStringByInvocable Class
 * FOUK-2877
*/
@isTest
public class BLN_SplitStringForFlowTest {
    @isTest
    static void testSplitStringWithValidInput() {
        
        BLN_SplitStringForFlow.Request req = new BLN_SplitStringForFlow.Request();
        req.inputString = 'Email,Phone,log';
        req.delimiter = ',';
        List<BLN_SplitStringForFlow.Request> requestList = new List<BLN_SplitStringForFlow.Request>{req};
            
        Test.startTest();
        List<List<String>> result = BLN_SplitStringForFlow.splitString(requestList);
        Test.stopTest();
        System.assertNotEquals(null, result, 'The result should not be null');
    }
}