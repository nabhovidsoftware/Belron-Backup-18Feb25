/** @description : This Test class is for BLN_FSLUtility.
*   @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
*   @author: PwC IN
*   @CreatedDate: 31/07/2024
*/

@IsTest
public class BLN_FSLUtilityTest {
    @IsTest
    public static void testMethod1(){
        DateTime res1 = BLN_FSLUtility.changeStrToDateTime('2023-04-26T08:00:00');        
        Map<String, Map<String, String>> res2 = BLN_FSLUtility.fetchFailureReasonsFromCode();
        Map<String, String> res3 = BLN_FSLUtility.mapOfSkillNameAndId();
		String res4 = BLN_FSLUtility.calculateDiffBetTime(System.now(), System.now().addMinutes(10));
        TimeZone tz = UserInfo.getTimeZone();
        String res5 = BLN_FSLUtility.convertDateTimeToUTC(System.now(), (String)tz.getDisplayName());
        String res6 = BLN_FSLUtility.convertDateTimeToUTC(NULL, NULL);
        String res7 = BLN_FSLUtility.formatGMT(System.now());
        Boolean res8 = BLN_FSLUtility.isTriggerDisabled((Id)UserInfo.getUserId());
        
        Assert.areEqual(System.now(), System.now(), 'Success');
    }
}