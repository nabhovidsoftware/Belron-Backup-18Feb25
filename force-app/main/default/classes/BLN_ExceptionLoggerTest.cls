/*****************************************
ClassName : BLN_ExceptionLoggerTest
Description : This is test class for BLN_ExceptionLogger
@Story : FOUK-252
CreatedDate: 05/09/2023
CreatedBy : PwC-India
****************************************/
@IsTest
public class BLN_ExceptionLoggerTest {
    @TestSetup 
    static void setup() {
        Case ca =  BLN_TestDataFactory.createCase('BLN_B2BSalesCase','Feedback','New');
        insert ca;
    }

/*  *@description: This method is used to test LogException method for BLN_ExceptionLogger class.
        *@return : void
    */
  @IsTest
    public static void unitTest(){
        List<Exception> exList = new List<Exception>();
        List<BLN_ExceptionLogger__c> exceptionLogger = new List<BLN_ExceptionLogger__c>();
        exceptionLogger = BLN_TestDataFactory.exeptionLoggerData('testException', true);
        try{
          insert new Lead();
        } catch (Exception ex){
            exList.add(ex);
            Test.startTest();
            BLN_ExceptionLogger.LogException(exList, '1234567');
            Test.stopTest();
            System.assertEquals(exceptionLogger.size(), 1,'Not equal');
        }
    }
    
 @IsTest
    public static void testCaptureException(){
        
        List<BLN_ExceptionLogger__c> exList = new List<BLN_ExceptionLogger__c>();
        Case ca =  BLN_TestDataFactory.createCase('BLN_B2BSalesCase','Feedback','New');
        insert ca;
        Test.startTest();
        try{
          
            ca.BLN_SubType__c = 'Job Request';
            update ca;
        
        } catch (Exception ex){
            
            BLN_ExceptionLogger.captureException(ex);
        }
        Test.stopTest();
        exList = [SELECT Id from BLN_ExceptionLogger__c];
        Assert.isTrue(exList.size()>0,'list size is greater than zero');
    }
    
/*  *@description: This method is used to test captureException method for BLN_ExceptionLogger class.
        *@return : void
    */
    @IsTest
    public static void testCaptureException2s(){
        List<BLN_ExceptionLogger__c> exListNew = new List<BLN_ExceptionLogger__c>();
        List<Case> caseList=[SELECT Id, BLN_SubType__c from Case where Type='Feedback'];
        Case caseObject;
        Test.startTest();
        try{
        if (caseList!=null && !caseList.isEmpty()) {
            caseObject=caseList.get(0);
            caseObject.BLN_SubType__c = 'Job Request';
            Update caseObject;
        }
        }catch (Exception ex){            
            BLN_ExceptionLogger.captureException(ex);
        }
        Test.stopTest();
        exListNew = [SELECT Id from BLN_ExceptionLogger__c];
        Assert.isTrue(exListNew.size()>0,'list size is greater than zero');
    }

  /*  *@description: This method is used to test logExceptionRequest method for BLN_ExceptionLogger class.
        *@return : void
    */  
    /*R2 Code Changes*/
    @IsTest
    public static void logExceptionRequestTest(){
        List<Exception> exList = new List<Exception>();
        List<BLN_ExceptionLogger__c> exceptionLogger = new List<BLN_ExceptionLogger__c>();
        exceptionLogger = BLN_TestDataFactory.exeptionLoggerData('testException', true);
        try{
          insert new Lead();
        } catch (Exception ex){
            exList.add(ex);
            Test.startTest();
            BLN_ExceptionLogger.logExceptionRequest(exList,'test string','test String');
            Test.stopTest();
            System.assertEquals(exceptionLogger.size(), 1,'Not equal');
        }
    }
    
}