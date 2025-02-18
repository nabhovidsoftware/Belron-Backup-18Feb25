/*****************************************
ClassName : BLN_SessionIdController
@description : FOUK-4467 This  class is used to get session id for Queueable class.
CreatedDate: 14-12-2023
CreatedBy : PwC-India
****************************************/
public class BLN_SessionIdController {
    /*MethodName : getSessionId
@description : This method is used to recieve sessionId from vfPage BLN_SessionIdVfPage
@return : SessionId
Input Parameter : PageReference (VfPage)
Output Parameter : String
CreatedDate: 14-12-2023
CreatedBy : Pwc-India
Change log :
****************************************/
    public static String getSessionId(PageReference visualforcePage){
            String content = Test.isRunningTest() ? 'Start_Of_Session_IdTESTEnd_Of_Session_Id':  visualforcePage.getContent().toString();  
            Integer startIndex = content.indexOf('Start_Of_Session_Id')+'Start_Of_Session_Id'.length();
            Integer endIndex = content.indexOf('End_Of_Session_Id');
            return content.subString(startIndex,endIndex);
    }
}