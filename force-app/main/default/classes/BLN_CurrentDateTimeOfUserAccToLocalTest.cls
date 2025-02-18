@isTest
public class BLN_CurrentDateTimeOfUserAccToLocalTest {
    @isTest
    public static void currentDateTimeOfUserAccToLocalTimeTest(){
        User usr = BLN_TestDataFactory.createAdminUser('Test User');
        System.runAs(new User(Id =UserInfo.getUserId())){
            INSERT usr;
        }
        List<Id> userIdList = new List<Id>();
        userIdList.add(usr.Id);
        Test.StartTest();
        List<String> currentUserDateTime = BLN_CurrentDateTimeOfUserAccToLocalTime.getUserLocalDateTime(userIdList);
        Test.StopTest();
        System.assertNotEquals(null,currentUserDateTime,'currentDateTime should not be null');
    }
}