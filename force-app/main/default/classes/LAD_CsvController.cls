public without sharing class LAD_CsvController {
    @AuraEnabled
    public static List<orderItemSummaryWrapper> fetchRecords1(string accountId){

        List<orderItemSummaryWrapper> wrapperList=new List<orderItemSummaryWrapper>();
        for(orderitemsummary i: [select  Name,StockKeepingUnit,ProductCode,Quantity,LAD_PO_Number__c,LAD_Status__c,ordersummary.ordernumber from OrderItemSummary where ordersummary.accountid=:accountId]){
            orderItemSummaryWrapper ins=new orderItemSummaryWrapper();
            ins.name=i.ordersummary.ordernumber!=null?i.ordersummary.ordernumber:'';ins.productSku=i.StockKeepingUnit!=null?i.StockKeepingUnit:''; ins.productCode=i.productCode!=null?i.productCode:''; ins.quantity=i.Quantity!=null?i.Quantity:0; ins.poNumber=i.LAD_PO_Number__c!=null?i.LAD_PO_Number__c:'';ins.status=i.LAD_Status__c!=null?i.LAD_Status__c:'';
            wrapperList.add(ins);
        }
        return wrapperList;
    }
    
    public class orderItemSummaryWrapper{
     @AuraEnabled   public string name {get;set;}
     @AuraEnabled   public string productSku {get;set;}
     @AuraEnabled   public string productCode {get;set;}
     @AuraEnabled   public decimal quantity {get;set;}
     @AuraEnabled   public string poNumber {get;set;}
     @AuraEnabled   public string status {get;set;}

    }
    @AuraEnabled(cacheable = true)
    public static List<LAD_Financial_Document__c> fetchRecords2(string accountId){
       List<LAD_Financial_Document__c> newList23 = [SELECT 	Name, LAD_Type__c,	LAD_Total_Amount__c,	LAD_Remaining_Amount__c,		CurrencyIsoCode,LAD_Status__c,	 LAD_Due_Date__c from LAD_Financial_Document__c  where LAD_Account__c =: accountId];
       
       
      
        return newList23;
    }
    @AuraEnabled(cacheable=true)
    public static List<DataSet> getAllInvoice(string accountId){
       // List<AggregateResult> result =  [SELECT Count(Id) cnt,Name FROM  OrderItemSummary GROUP BY Name];
       List<AggregateResult> result =  [SELECT Count(Id) cnt,CALENDAR_MONTH(CreatedDate) cd FROM  LAD_Financial_Document__c  where LAD_Account__c =: accountId Group By CALENDAR_MONTH(CreatedDate) ];



        List<DataSet> dataSet = new List<DataSet>();

    for(AggregateResult ar : result) {
            
            dataSet.add(new DataSet(returnMonth((Integer)ar.get('cd'))  ,(Integer)ar.get('cnt')));
        }
        return dataSet ;
    }
    @AuraEnabled(cacheable = true)
    public static List<OrderItem> fetchRecords3(string accountId){

        return [Select LAD_Product_Name__c,Quantity from OrderItem where order.accountid=:accountId];
    }
    

    @AuraEnabled(cacheable=true)
    public static List<DataSet> getAllOppsByStage(string accountId){
       // List<AggregateResult> result =  [SELECT Count(Id) cnt,Name FROM  OrderItemSummary GROUP BY Name];
       List<AggregateResult> result =  [SELECT Count(Id) cnt,CALENDAR_MONTH(CreatedDate) cd FROM  OrderItemSummary  where ordersummary.accountid=:accountId Group By CALENDAR_MONTH(CreatedDate) ];



        List<DataSet> dataSet = new List<DataSet>();

    for(AggregateResult ar : result) {
            
            dataSet.add(new DataSet(returnMonth((Integer)ar.get('cd'))  ,(Integer)ar.get('cnt')));
        }
        return dataSet ;
    }

    @AuraEnabled(cacheable=true)
    public static List<DataSet> getAllProductByStage(string accountId){
       // List<AggregateResult> result =  [SELECT Count(Id) cnt,Name FROM  OrderItemSummary GROUP BY Name];
       List<AggregateResult> result =  [SELECT Count(Quantity) cnt,CALENDAR_MONTH(CreatedDate) cd FROM  OrderItem where order.accountid=:accountId Group By CALENDAR_MONTH(CreatedDate) ];


            system.debug('result here'+result);
        List<DataSet> dataSet = new List<DataSet>();

 
        for(AggregateResult ar : result) {
            
            dataSet.add(new DataSet(returnMonth((Integer)ar.get('cd'))  ,(Integer)ar.get('cnt')));
        }
        return dataSet ;
    }

      public class DataSet {
        public DataSet(String label ,Integer count){
            this.label  = label ;
            this.count  = count ;
        }

        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public Integer  count {get;set;}
    }
	
    public static string returnMonth(integer i){
        Map<integer,string> count_Month_Map=new Map<integer,string>{
            1=>'January',
                2=>'February',
                3=>'March',
                 4=>'April',
                5=>'May',
                6=>'June',
                 7=>'July',
                8=>'August',
                9=>'September',
                  10=>'October',
                11=>'November',
                12=>'December'

        };
        return count_Month_Map.get(i);
    }


    @auraenabled
    public static Id getAccId(string userid){
        try {
            system.debug('userid'+userid);
            Id accountId;
            List<user> accidfromuser = [select id, AccountId  from user where id =:userid  limit 1];
            if (!accidfromuser.isEmpty()) {
                accountId = accidfromuser[0].AccountId;
            }
            system.debug('accountId>>'+accountId);
            return accountId;
        } catch (Exception e) {
            // Handling the exceptions and log an error message
           
            return null;
        }
       
    } 
}