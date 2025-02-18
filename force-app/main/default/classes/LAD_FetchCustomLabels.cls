/** @description :  This apex class is used to return Custom Label content.
*  @author:         (binayak.debnath@pwc.com (IN))
*  @story:          FOUK-8069; FOUK-8057
*/
public with sharing class LAD_FetchCustomLabels {
    //fetchLabels method
    @AuraEnabled
    public static Map<String,string> fetchLabels(List<String> devNames){
        Map<String, string> labelMap = new Map<String, string>();
        try {
            for(Integer i=0; i<devNames.size(); i++){
                labelMap.put(devNames[i], System.Label.get('',devNames[i]));
            }
            return labelMap;
        } catch (Exception ex) {
            labelMap.put('Exception',ex.getMessage());
            return labelMap;
        }
    }
    
}