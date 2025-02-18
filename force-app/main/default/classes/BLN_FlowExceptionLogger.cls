/*****************************************
ClassName : BLN_FlowExceptionLogger
Description : This is for invocable method which will accept fault message of flow and throw exception.
@Story : FOUK-2048
CreatedDate: 28/08/2023
CreatedBy : PwC-India
****************************************/

public class BLN_FlowExceptionLogger{
    
    public class MyException extends Exception {}
    @InvocableMethod(label='Invoke BLN_FlowExceptionLogger')
    
    public static void throwCustomException(List<String> excmessage){
        
        String errorMessage = Label.BLN_FlowExceptionError + excmessage[0];
        throw new MyException(errorMessage);
    }
    
}