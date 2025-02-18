public with sharing class  BLN_CurrentDateTimeOfUserAccToLocalTime {
    @InvocableMethod(label = 'Get User Local DateTime' description = 'Returns the current date and time according to the user local time zone')
    public static List<String> getUserLocalDateTime(List<Id> userId){
        List<String> formatedDateTime = new List<String>();
        User usr = new User();
        usr = [Select Id,TimeZoneSidKey From User Where Id =: userId WITH SECURITY_ENFORCED LIMIT 1];
        Datetime gmtDateTime = System.now();
        String strConvertedDate = ''; 
        strConvertedDate = gmtDateTime.format('yyyy-MM-dd-HH:mm:ss', usr.TimeZoneSidKey);
        formatedDateTime.add(strConvertedDate);
        return formatedDateTime;
    }
}