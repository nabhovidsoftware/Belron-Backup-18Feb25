/** @description :  Test class for LAD_FetchCustomLabels.
*  @author:         (binayak.debnath@pwc.com (IN))
*  @story:          FOUK-8069; FOUK-8057
*/
@isTest
public class LAD_FetchCustomLabelsTest {

    @istest
    public static void fetchTest(){
        List<String> labels = new List<String>();
        labels.add('LAD_AccountOnHold_Title');
        labels.add('LAD_AccountOnHold_Body');
        Test.startTest();
        Map<String,String> returnMap = LAD_FetchCustomLabels.fetchLabels(labels);
        labels.add('Test');
        Map<String,String> returnMapEx = LAD_FetchCustomLabels.fetchLabels(labels);
        Test.stopTest();
        Assert.areEqual(System.Label.LAD_AccountOnHold_Title, returnMap.get('LAD_AccountOnHold_Title'));
        Assert.areEqual(System.Label.LAD_AccountOnHold_Body, returnMap.get('LAD_AccountOnHold_Body'));
    }
}