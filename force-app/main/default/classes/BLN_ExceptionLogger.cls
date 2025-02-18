/** @description : This apex class used to store Exceptoin from Apex class
*   @author:Rahul Jain (PwC IN)
*   @CreatedDate: 24.07.2023
*   @Story: FOUK-252
*/
public without sharing class BLN_ExceptionLogger {

       /*****************************************
MethodName : saveExceptions
Description : This is used to save exception
Input Parameter : (List<ExceptionLoggerWrapper>)
Output Parameter : void
CreatedDate: 11/08/2023
CreatedBy : Pwc-India
Change log :
****************************************/

    
    public static void saveExceptions (List<ExceptionLoggerWrapper> exceptionWrappers) {
        
        List<BLN_ExceptionLogger__c> exceptionLogs = new List<BLN_ExceptionLogger__c>();
        
        for(ExceptionLoggerWrapper exceptionWrap : exceptionWrappers){
            
            exceptionLogs.add(exceptionWrap.exceptionLog);
        }
        if(Schema.sObjectType.BLN_ExceptionLogger__c.isCreateable()){
            insert exceptionLogs;
        }
    }
  
    
    /*****************************************
MethodName : captureException
Description : This is used to capture exception
Input Parameter : (Exception)
Output Parameter : void
CreatedDate: 11/08/2023
CreatedBy : Pwc-India
Change log :
****************************************/
    public static void captureException( Exception ex){
        
        List<ExceptionLoggerWrapper> lstwrapper = new List<ExceptionLoggerWrapper>();
        Integer count = 1;
        
        if(ex.getTypeName() == 'System.DmlException'){
            
            count = ex.getNumDml();
        }
        
        for (Integer i = 0; i < count; i++) { 
            
            ExceptionLoggerWrapper objwrapper = new ExceptionLoggerWrapper( ex, i);
            lstwrapper.add(objwrapper);
        }
        
        saveExceptions(lstwrapper);
    }
    

    public static List<BLN_ExceptionLogger__c> logException(List<Exception> execepLogList, String failedRecordId){
        return logException(execepLogList, true, failedRecordId);
    }

    public static List<BLN_ExceptionLogger__c> logException(List<Exception> execepLogList, Id processedRecord, Boolean insertLogs, String failedRecordId){
        List<BLN_ExceptionLogger__c> exceptionLoggs = logException(execepLogList, false, failedRecordId);
        for (BLN_ExceptionLogger__c exceptionLog : exceptionLoggs) {
            exceptionLog.BLN_RecordIdIdentifier__c = processedRecord;
        }
        return exceptionLoggs;
    }

    public static List<BLN_ExceptionLogger__c> logException(List<Exception> execepLogList, Boolean insertLogs, String failedRecordId){
        List<BLN_ExceptionLogger__c> loggerListException  = new  List<BLN_ExceptionLogger__c>();

        for(Exception excepLoggerObj : execepLogList){
            BLN_ExceptionLogger__c objExcepLogger = New BLN_ExceptionLogger__c();
            if(excepLoggerObj instanceof DmlException){
                DmlException dmlException = (DmlException)excepLoggerObj;
                String recordId = excepLoggerObj.getDmlId(0);
                objExcepLogger.BLN_RecordIdIdentifier__c = recordId;
            } else {
                objExcepLogger.BLN_RecordIdIdentifier__c = failedRecordId != null ? failedRecordId : '';
            }
            String stackTrace = excepLoggerObj.getStackTraceString();
            String apexClassName = stackTrace.substringAfter('.').substringBefore('.');
            String classMethodName = stackTrace.substringBefore(':').substringAfter(apexClassName).substringAfter('.');
            objExcepLogger.BLN_EntityName__c = apexClassName;
            objExcepLogger.BLN_ExceptionType__c = excepLoggerObj.getTypeName();
            objExcepLogger.BLN_LineNumber__c = string.valueof(excepLoggerObj.getLineNumber());
            objExcepLogger.BLN_ErrorMessage__c = excepLoggerObj.getMessage();
            objExcepLogger.BLN_MethodStep__c = classMethodName;
            objExcepLogger.BLN_StackTrace__c = stackTrace;

            loggerListException.add(objExcepLogger);
        }

        if (insertLogs) {
            if(Schema.sObjectType.BLN_ExceptionLogger__c.isCreateable()){
                insert loggerListException;
            }
        }

        return loggerListException;
    }
    
    public static void logExceptionRequest(List<Exception> execepLogList, String request, String failedRecordId){
        List<BLN_ExceptionLogger__c> loggerListException  = new  List<BLN_ExceptionLogger__c>();
        
        for(Exception excepLoggerObj : execepLogList){
            BLN_ExceptionLogger__c objExcepLogger = New BLN_ExceptionLogger__c();
            if(excepLoggerObj instanceof DmlException){
                DmlException dmlException = (DmlException)excepLoggerObj;
                String recordId = excepLoggerObj.getDmlId(0);
                objExcepLogger.BLN_RecordIdIdentifier__c = recordId;
            } else {
                objExcepLogger.BLN_RecordIdIdentifier__c = failedRecordId != null ? failedRecordId : '';
            }
            String stackTrace = excepLoggerObj.getStackTraceString();
            String apexClassName = stackTrace.substringAfter('.').substringBefore('.');
            String classMethodName = stackTrace.substringBefore(':').substringAfter(apexClassName).substringAfter('.');
            objExcepLogger.BLN_EntityName__c = apexClassName;
            objExcepLogger.BLN_ExceptionType__c = excepLoggerObj.getTypeName();
            objExcepLogger.BLN_LineNumber__c = string.valueof(excepLoggerObj.getLineNumber());
            objExcepLogger.BLN_ErrorMessage__c = excepLoggerObj.getMessage();
            objExcepLogger.BLN_MethodStep__c = classMethodName;
            objExcepLogger.BLN_StackTrace__c = stackTrace+ '\n\n'+ request;
            
            loggerListException.add(objExcepLogger); 
        }
        if(Schema.sObjectType.BLN_ExceptionLogger__c.isCreateable()){
            insert loggerListException;
        }
    }
    
    /*****************************************
  Description : This is a wrapper class
  ****************************************/ 
  
  public class ExceptionLoggerWrapper {
        
    BLN_ExceptionLogger__c exceptionLog = new BLN_ExceptionLogger__c();
        
        public ExceptionLoggerWrapper(Exception ex, Integer i){
            
            String stackTrace = ex.getStackTraceString().subStringBefore('\n');
            String apexClassName = stackTrace.substringAfter('.').substringBefore('.');
            String classMethodName = stackTrace.substringBefore(':').substringAfter(apexClassName).substringAfter('.');
            exceptionLog.BLN_EntityName__c      = apexClassName;
            exceptionLog.BLN_MethodStep__c      = classMethodName;
            exceptionLog.BLN_ErrorMessage__c    = ex.getMessage();
            exceptionLog.BLN_LineNumber__c      = string.valueof(ex.getLineNumber());
            exceptionLog.BLN_StackTrace__c      = ex.getStackTraceString();
            exceptionLog.BLN_ExceptionType__c   = ex.getTypeName();
            exceptionLog.BLN_CurrentUser__c     = UserInfo.getUserId();
            if(ex.getTypeName() == 'System.DmlException'){
                exceptionLog.BLN_RecordIdIdentifier__c = ex.getDmlId(i);
            }
        }
    }
}