/** @description : This Apex is used to remove html markup
*   @author: (PwC-India)
*   @CreatedDate: 25/06/2024
*/


/** @description : This method is used to remove html markup
*/
public class BLN_RemoveHTMLMarkup{
   
    @InvocableMethod(Label='Removes HTML markup and returns plain text')
    public static List<String> stripHtmlTags(List<String> richText) {
       
        List<String> textContent  = new List<String>();
        for (string s : richText) {
            textContent.add(s.stripHtmlTags());
        }
        return textContent;
    }
}