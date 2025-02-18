/** @description : This Apex is used as Test class to remove html markup
*   @author: (PwC-India)
*   @CreatedDate: 25/06/2024
*/


@isTest
public class BLN_RemoveHTMLMarkupTest {
   
    
    /** @description : This Test method for stripHtmlTags method
*/
    @isTest
    static void stripHtmlTags() {
       
        List<string> removeHTML = New List<String>{'<html><body>This is a Test</body></html>'};
        List<string> withoutHTML = New List<String>{'This is a Test'};

        System.assertEquals(withoutHTML, BLN_RemoveHTMLMarkup.stripHtmlTags(removeHTML),'Test Confirmed');
    }
}