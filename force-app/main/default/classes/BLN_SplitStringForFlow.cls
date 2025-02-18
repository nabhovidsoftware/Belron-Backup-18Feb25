/* Created by : Animesh Biswas (PwC-IN)
 * Used in : Flow --> BLN_IndividualCreationOnPersonAccount
 * Description : Splits a string based on delimiter 
 * FOUK-2877
*/

public with sharing class BLN_SplitStringForFlow {
	@InvocableMethod(label='String Splitter Method')
    public static List<List<String>> splitString(List<Request> inputRequest){
        List<List<String>> outputStringList = new List<List<String>>();
        
        if(String.isNotBlank(inputRequest[0].inputString)){
            List<String> stringList = inputRequest[0].inputString.split(inputRequest[0].delimiter);
            outputStringList.add(stringList);
        }
        else{
            outputStringList.add(new List<String>());
        }
        return outputStringList;
    }
    
    public class Request{
        @InvocableVariable(label='Input String' description='Single Text Variable')
        public String inputString;
        
        @InvocableVariable(label='Delimiter' description='Data type = String' required=true)
        public String delimiter;
    }
}