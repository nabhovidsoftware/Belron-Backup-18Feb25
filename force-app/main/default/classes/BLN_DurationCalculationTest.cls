/** @description : BLN_DurationCalculationTest Class used for testing BLN_DurationCalculation.
*  	@author: Wasim Akram
* 	@Story: 
*	@Created Date: 11/12/2023
*/
@isTest
public class BLN_DurationCalculationTest {
    @testSetup
    static void testSetup() {
        //Stock Collect
        WorkType worktypeSC = BLN_TestDataFactory.createWorkType('Stock Collect', 11.00, true, true);
        OperatingHours opertatingHrSC = BLN_TestDataFactory.createOperatingHour('Test op Stock Collect',true);
        //Replacement
        WorkType workTypeRe = BLN_TestDataFactory.createWorkType('Replacement', 11.00, true, true);
        OperatingHours opertatingHrRe = BLN_TestDataFactory.createOperatingHour('Test op Replacement',true);
        //Assist
        WorkType workTypeAs = BLN_TestDataFactory.createWorkType('Assist', 11.00, true, true);
        OperatingHours opertatingHrAs = BLN_TestDataFactory.createOperatingHour('Test op Assist',true);
        
        List<ServiceTerritory> ServiceTerritoryList = new List<ServiceTerritory>();

        ServiceTerritory serviceTerritorySC = BLN_TestDataFactory.createServiceTerritory('Test Territory Stock Collect',opertatingHrSC.id,'United Kingdom',false);
        serviceTerritorySC.BLN_AnyDurationAssist__c = true;
        ServiceTerritoryList.add(serviceTerritorySC);

        ServiceTerritory serviceTerritoryRe = BLN_TestDataFactory.createServiceTerritory('Test Territory Replacement',opertatingHrRe.id,'United Kingdom',false);
        serviceTerritoryRe.BLN_AnyDurationAssist__c = true;
        ServiceTerritoryList.add(serviceTerritoryRe);

        ServiceTerritory serviceTerritoryAs = BLN_TestDataFactory.createServiceTerritory('Test Territory Assist',opertatingHrAs.id,'United Kingdom',false);
        serviceTerritoryAs.BLN_AnyDurationAssist__c = true;
        ServiceTerritoryList.add(serviceTerritoryAs);

        insert ServiceTerritoryList;
        
        WorkOrder workOrdSC = BLN_TestDataFactory.createWorkOrder2(worktypeSC.Id, serviceTerritorySC.Id, true);

        WorkOrder workOrdRe = BLN_TestDataFactory.createWorkOrder2(workTypeRe.Id, serviceTerritoryRe.Id, true);

        WorkOrder workOrdAs = BLN_TestDataFactory.createWorkOrder2(workTypeAs.Id, serviceTerritoryAs.Id, true);
        
        List<WorkOrderLineItem> WorkOrderLineItemList = new List<WorkOrderLineItem>();

        WorkOrderLineItem wOLISC = new WorkOrderLineItem();
        wOLISC.BLN_RemedyTaskId__c = '6565651';
        wOLISC.WorkTypeId = worktypeSC.Id;
        wOLISC.WorkOrderId = workOrdSC.id;
        WorkOrderLineItemList.add(wOLISC);
        
        WorkOrderLineItem wOLIRe = new WorkOrderLineItem();
        wOLIRe.BLN_RemedyTaskId__c = '6565652';
        wOLIRe.WorkTypeId = workTypeRe.Id;
        wOLIRe.WorkOrderId = workOrdRe.id;
        WorkOrderLineItemList.add(wOLIRe);
        
        WorkOrderLineItem wOLIAs = new WorkOrderLineItem();
        wOLIAs.BLN_RemedyTaskId__c = '6565653';
        wOLIAs.WorkTypeId = workTypeAs.Id;
        wOLIAs.WorkOrderId = workOrdAs.id;
        WorkOrderLineItemList.add(wOLIAs);

        insert WorkOrderLineItemList;
    }
    /*@Description : This method is used to test Calculation of stock collect*/
    @isTest
    public static void durationCalculationStock(){
        
        
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }

        WorkType worktype =[SELECT id,Name from WorkType WHERE Name = 'Stock Collect' LIMIT 1];
        ServiceTerritory serviceTerritorys =[SELECT id,Country FROM ServiceTerritory WHERE Name = 'Test Territory Stock Collect' LIMIT 1];
        WorkOrderLineItem wOLI =[SELECT id,BLN_RemedyTaskId__c,WorkTypeId,WorkOrderId FROM WorkOrderLineItem WHERE BLN_RemedyTaskId__c = '6565651' LIMIT 1];

        BLN_BU__mdt bu = BLN_BU__mdt.getInstance('United_Kingdom');
        String duration;
        duration = BLN_DurationCalculation.durationCal(worktype,serviceTerritorys,wOLI,11.00,bu,'');
        system.assertNotEquals(Null, duration, 'Duration Cannot be null');
    }
    
    /*@Description : This method is used to test Calculation of Replacement*/

    @isTest
    public static void durationCalculationMain(){
       User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        WorkType worktype =[SELECT id,Name,EstimatedDuration from WorkType WHERE Name = 'Replacement' LIMIT 1];
        ServiceTerritory serviceTerritory =[SELECT id,Country,BLN_MeetAndGreetTime__c FROM ServiceTerritory WHERE Name = 'Test Territory Replacement' LIMIT 1];
        WorkOrderLineItem wOLI =[SELECT id,BLN_RemedyTaskId__c,WorkTypeId,WorkOrderId,BLN_ProductFittingDuration__c FROM WorkOrderLineItem WHERE BLN_RemedyTaskId__c = '6565652' LIMIT 1];
        
        BLN_BU__mdt bu = BLN_BU__mdt.getInstance('United_Kingdom');
        String duration;
        duration = BLN_DurationCalculation.durationCal(worktype,serviceTerritory,wOLI,11.00,bu,'');
        system.assertNotEquals(Null, duration, 'Duration Cannot be null');
    }

     /*@Description : This method is used to test Calculation of Duration*/
    @isTest
    //1
    public static void durationCalculation(){
       User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        WorkType worktype =[SELECT id,Name,EstimatedDuration from WorkType WHERE Name = 'Assist' LIMIT 1];
        ServiceTerritory serviceTerritory =[SELECT id,Country,BLN_AnyDurationAssist__c FROM ServiceTerritory WHERE Name = 'Test Territory Assist' LIMIT 1];
        WorkOrderLineItem wOLI =[SELECT id,BLN_RemedyTaskId__c,WorkTypeId,WorkOrderId FROM WorkOrderLineItem WHERE BLN_RemedyTaskId__c = '6565653' LIMIT 1];
        
        BLN_BU__mdt bu = BLN_BU__mdt.getInstance('United_Kingdom');
        String duration;
        duration = BLN_DurationCalculation.durationCal(worktype,serviceTerritory,wOLI,11.00,bu,'');
        duration = BLN_DurationCalculation.durationCal(worktype,serviceTerritory,wOLI,41.00,bu,'');
        duration = BLN_DurationCalculation.durationCal(worktype,serviceTerritory,wOLI,Null,bu,'');
        system.assertNotEquals(Null, duration, 'Duration Cannot be null');
    }
     /*@Description : This method is used to test Calculation of Duration2*/
    @isTest
    //2
    public static void durationCalculation2(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        WorkType worktype =[SELECT id,Name from WorkType WHERE Name = 'Assist' LIMIT 1];
        ServiceTerritory serviceTerritory =[SELECT id,Country,BLN_AnyDurationAssist__c FROM ServiceTerritory WHERE Name = 'Test Territory Assist' LIMIT 1];
        serviceTerritory.BLN_AnyDurationAssist__c = false;
        update serviceTerritory;
        WorkOrderLineItem wOLI =[SELECT id,BLN_RemedyTaskId__c,WorkTypeId,WorkOrderId FROM WorkOrderLineItem WHERE BLN_RemedyTaskId__c = '6565653' LIMIT 1];
        
        BLN_BU__mdt bu = BLN_BU__mdt.getInstance('United_Kingdom');
        String duration;
        duration = BLN_DurationCalculation.durationCal(worktype,serviceTerritory,wOLI,11.00,bu,'');
        duration = BLN_DurationCalculation.durationCal(worktype,serviceTerritory,wOLI,Null,bu,'');
        system.assertNotEquals(Null, duration, 'Duration Cannot be null');
    }
     /*@Description : This method is used to test Calculation of Duration3*/
    @isTest
    //3
    public static void durationCalculation3(){
       User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        WorkType worktype =[SELECT id,Name from WorkType WHERE Name = 'Assist' LIMIT 1];
        ServiceTerritory serviceTerritory =[SELECT id,Country,BLN_AnyDurationAssist__c FROM ServiceTerritory WHERE Name = 'Test Territory Assist' LIMIT 1];
        serviceTerritory.BLN_AnyDurationAssist__c = false;
        update serviceTerritory;
        WorkOrderLineItem wOLI =[SELECT id,BLN_RemedyTaskId__c,WorkTypeId,WorkOrderId FROM WorkOrderLineItem WHERE BLN_RemedyTaskId__c = '6565653' LIMIT 1];
        
        BLN_BU__mdt bu = BLN_BU__mdt.getInstance('Testing');
        String duration;
        duration = BLN_DurationCalculation.durationCal(worktype,serviceTerritory,wOLI,11.00,bu,'');
        duration = BLN_DurationCalculation.durationCal(worktype,serviceTerritory,wOLI,45,bu,'');
        system.assertNotEquals(Null, duration, 'Duration Cannot be null');
    }
     /*@Description : This method is used to test Calculation of Duration4*/
    @isTest
    //4
    public static void durationCalculation4(){
       User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        WorkType worktype =[SELECT id,Name from WorkType WHERE Name = 'Assist' LIMIT 1];
        ServiceTerritory serviceTerritory =[SELECT id,Country,BLN_AnyDurationAssist__c FROM ServiceTerritory WHERE Name = 'Test Territory Assist' LIMIT 1];
        WorkOrderLineItem wOLI =[SELECT id,BLN_RemedyTaskId__c,WorkTypeId,WorkOrderId FROM WorkOrderLineItem WHERE BLN_RemedyTaskId__c = '6565653' LIMIT 1];
        
        BLN_BU__mdt bu = BLN_BU__mdt.getInstance('Testing');
        String duration;
        duration = BLN_DurationCalculation.durationCal(worktype,serviceTerritory,wOLI,11.00,bu,'');
        system.assertNotEquals(Null, duration, 'Duration Cannot be null');
    }
}