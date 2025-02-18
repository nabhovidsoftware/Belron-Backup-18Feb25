/** @description : BLN_GenerateSkillRequirementTest Class used for testing BLN_GenerateSkillRequirement.
*  	@author: Wasim Akram
* 	@Story: 
*	@Created Date: 11/12/2023
*/
@isTest
public class BLN_GenerateSkillRequirementTest {
    @testSetup
    private static void testSetup() {
        // Setup user and run
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        // Setup test data
        BLN_Vehicle__c vehicle = new BLN_Vehicle__c();
        vehicle.BLN_SpecialVehicle__c = false;
        insert vehicle;

        Product2 prd = new Product2();
        prd.BLN_ProductCategory__c = 'Sunroof';
        prd.BLN_ProductVanSize__c = 6;
        prd.BLN_SkillComplexity__c = 9;
        prd.Name = 'Sunroof';
        insert prd;
    }

    //sets up data for skills, work types, work orders, cases, products, operating hours, and service territories, then tests the createSkillRequirement method
    @isTest
    public static void generateSkillRequirementRepair() {
        testSetup();//Calls a helper method 'testSetup'
        
        //skill map initialization
        map<string,string> skillMapData = new map<string,string>();
        List<Skill> skills = [SELECT ID, masterlabel FROM Skill];
        for (Skill sk : skills) {
            skillMapData.put(sk.MasterLabel, sk.Id);
        }
        
        //Work Type Initialization
        map<string,worktype> workTypeMapData = new map<string,worktype>();//Initializes a map to store work type data
        WorkType worktype = BLN_TestDataFactory.createWorkType('Repair', 11.00, true, true); 
        workTypeMapData.put(worktype.Id, worktype);
        
        //Creates and inserts 'workorder' and 'workorderlineItem' record
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders;  
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = '6565653';
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        insert wOLI;
        
        //Creates and inserts 'Case' record
        Case cases = new Case();
        cases.BLN_Vehicle__c = [SELECT Id FROM BLN_Vehicle__c LIMIT 1].Id;
        insert cases;
        
        //Creates 'OperatingHours' & 'ServiceTerritory' record using TestDatafactory method
        List<Product2> prodList = [SELECT Id, BLN_SkillComplexity__c,BLN_ProductCategory__c FROM Product2];
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Test op', true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('Test Territory', opertatingHr.id, 'United Kingdom', false);
        
        //Calls createSkillRequirement Method
        BLN_GenerateSkillRequirement.createSkillRequirement(wOLI, skillMapData, cases, true, prodList, workTypeMapData, serviceTerritory);   
        system.assertEquals(9, prodList[0].BLN_SkillComplexity__c, 'DifficultyFactor Should be same');
    }

    //sets up data for skills, work types, work orders, cases, products, operating hours, and service territories, then tests the createSkillRequirement method
    @isTest
    public static void generateSkillRequirementRepair2() {
        testSetup();

        map<string,string> skillMapData = new map<string,string>();
        List<Skill> skills = [SELECT ID, masterlabel FROM Skill];
        for (Skill sk : skills) {
            skillMapData.put(sk.MasterLabel, sk.Id);
        }

        map<string,worktype> workTypeMapData = new map<string,worktype>();
        WorkType worktype = BLN_TestDataFactory.createWorkType('Repair', 11.00, true, true); 
        workTypeMapData.put(worktype.Id, worktype);

        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders;  
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = '6565653';
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        insert wOLI;
        
        //queries and Updating vehicle record
        BLN_Vehicle__c vehicle = [SELECT Id FROM BLN_Vehicle__c LIMIT 1];
        vehicle.BLN_SpecialVehicle__c = true;
        update vehicle;

        Case cases = new Case();
        cases.BLN_Vehicle__c = vehicle.Id;
        insert cases;
        
        Case cas = [SELECT Id, BLN_Vehicle__c, BLN_Vehicle__r.BLN_SpecialVehicle__c FROM Case WHERE Id = :cases.Id];
        Product2 prd = [SELECT Id, BLN_SkillComplexity__c, BLN_ProductCategory__c, BLN_ProductVanSize__c, Name FROM Product2 LIMIT 1];
        
        List<Product2> prd1 = [SELECT Id, BLN_SkillComplexity__c, BLN_ProductCategory__c, BLN_ProductVanSize__c, Name FROM Product2 WHERE Id = :prd.Id];  
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Test op', true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('Test Territory', opertatingHr.id, 'United Kingdom', false);

        BLN_GenerateSkillRequirement.createSkillRequirement(wOLI, skillMapData, cas, true, prd1, workTypeMapData, serviceTerritory);   
        system.assertEquals(9, prd.BLN_SkillComplexity__c, 'DifficultyFactor Should be same');
    }

    //sets up data for skills, work types, work orders, cases, products, operating hours, and service territories, then tests the createSkillRequirement method 
    @isTest
    public static void generateSkillRequirementAssist() {
        testSetup();

        map<string,string> skillMapData = new map<string,string>();
        List<Skill> skills = [SELECT ID, masterlabel FROM Skill];
        for (Skill sk : skills) {
            skillMapData.put(sk.MasterLabel, sk.Id); 
        }

        map<string,worktype> workTypeMapData = new map<string,worktype>();
        WorkType worktype = BLN_TestDataFactory.createWorkType('Assist', 11.00, true, true); 
        workTypeMapData.put(worktype.Id, worktype);

        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders;  
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = '6565653';
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        insert wOLI;
        
        Case cases = new Case();
        cases.BLN_Vehicle__c = [SELECT Id FROM BLN_Vehicle__c LIMIT 1].Id;
        insert cases;

        Product2 prd = [SELECT Id, BLN_SkillComplexity__c, BLN_ProductCategory__c, BLN_ProductVanSize__c, Name FROM Product2 LIMIT 1];
        List<Product2> prd1 = [SELECT Id, BLN_SkillComplexity__c, BLN_ProductCategory__c, BLN_ProductVanSize__c, Name FROM Product2 WHERE Id = :prd.Id];        
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Test op',true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('Test Territory',opertatingHr.id,'United Kingdom',false);

        BLN_GenerateSkillRequirement.createSkillRequirement(wOLI,skillMapData,cases,true,prd1,workTypeMapData,serviceTerritory);   
        system.assertEquals(9, prd.BLN_SkillComplexity__c, 'DifficultyFactor Should be same'); 
    }

    //sets up data for skills, work types, work orders, cases, products, operating hours, and service territories, then tests the createSkillRequirement method 
    @isTest
    public static void generateSkillRequirementVan() {
        testSetup();

        map<string,string> skillMapData = new map<string,string>();
        List<Skill> skills = [SELECT ID, masterlabel FROM Skill];
        for (Skill sk : skills) {
            skillMapData.put(sk.MasterLabel, sk.Id);
        }  

        map<string,worktype> workTypeMapData = new map<string,worktype>();
        WorkType worktype = BLN_TestDataFactory.createWorkType('Assist', 11.00, true,false); 
        worktype.BLN_IsMainJob__c = true;
        insert worktype;
        workTypeMapData.put(worktype.Id,worktype);

        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders;  
        
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Test op',true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('Test Territory',opertatingHr.id,'United Kingdom',false);
        serviceTerritory.BLN_AnyDurationAssist__c = true;
        serviceTerritory.BLN_Type__c = 'Mobile';
        insert serviceTerritory;
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = '6565653';
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        wOLI.serviceterritoryId = serviceTerritory.Id;
        insert wOLI;

        WorkOrderLineItem woli1 = [SELECT ID, BLN_RemedyTaskId__c, WorkTypeId, WorkOrderId, serviceterritoryId, serviceterritory.BLN_Type__c, serviceterritory.BLN_AnyDurationAssist__c FROM WorkOrderLineItem WHERE Id = :wOLI.Id];
        Case cases = new Case();
        cases.BLN_Vehicle__c = [SELECT Id FROM BLN_Vehicle__c LIMIT 1].Id;
        insert cases;

        Product2 prd = [SELECT Id, BLN_SkillComplexity__c, BLN_ProductCategory__c, BLN_ProductVanSize__c, Name FROM Product2 LIMIT 1];
        List<Product2> prd1 = [SELECT Id, BLN_SkillComplexity__c, BLN_ProductCategory__c, BLN_ProductVanSize__c, Name FROM Product2 WHERE Id = :prd.Id];

        BLN_GenerateSkillRequirement.createSkillRequirement(wOLI, skillMapData, cases, true, prd1, workTypeMapData, serviceTerritory);  
        system.assertEquals(9, prd.BLN_SkillComplexity__c, 'DifficultyFactor Should be same');  
    }
    
    //sets up data for skills, work types, work orders, cases, operating hours, and service territories, then tests the createSkillRequirement method 
    @isTest
    public static void generateSkillRequirementNoProduct(){
        testSetup();
        
        //Van with Product null.
        map<string,string> skillMapData = new map<string,string>();
        List<Skill> skills = new List<Skill>([SELECT ID,masterlabel from skill]);
        for(Skill sk:skills){          
            skillMapData.put(sk.MasterLabel,sk.Id); 
        }  
        map<string,worktype> workTypeMapData = new map<string,worktype>();
        
        WorkType worktype = BLN_TestDataFactory.createWorkType('Warranty Replacement', 11.00, true, false); 
        worktype.BLN_IsMainJob__c = true;
        insert worktype;
        workTypeMapData.put(worktype.Id,worktype);
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders;  
        
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Test op',true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('Test Territory',opertatingHr.id,'United Kingdom',false);
        serviceTerritory.BLN_AnyDurationAssist__c = true;
        serviceTerritory.BLN_Type__c = 'Mobile';
        insert serviceTerritory;
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = '6565653';
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        wOLI.serviceterritoryId = serviceTerritory.Id;
        insert wOLI;
        WorkOrderLineItem woli1 = [select ID,BLN_RemedyTaskId__c,WorkTypeId,WorkOrderId,serviceterritory.BLN_Type__c,workType.BLN_IsMainJob__c from WorkOrderLineItem where Id=:woli.ID];

        BLN_Vehicle__c vehicle = new BLN_Vehicle__c();
        vehicle.BLN_SpecialVehicle__c = false;
        insert vehicle;
        
        Case cases = new Case();
        cases.BLN_Vehicle__c = vehicle.Id;
        insert cases;

        List<Product2> prodList1 = new List<Product2>();
        BLN_GenerateSkillRequirement.createSkillRequirement(wOLI1,skillMapData,cases,true,prodList1,workTypeMapData,serviceTerritory); 
        system.assertEquals('Warranty Replacement', worktype.Name, 'Work Type Should be same');  
    }
    
    //sets up data for skills, work types, work orders, vehicle, cases, products, operating hours, and service territories, then tests the createSkillRequirement method 
    @isTest
    public static void generateSkillRequirementReplacement(){
        testSetup();  
        
        //Van with Product.
        map<string,string> skillMapData = new map<string,string>();
        List<Skill> skills = new List<Skill>([SELECT ID,masterlabel from skill]);
        for(Skill sk:skills){          
            skillMapData.put(sk.MasterLabel,sk.Id); 
        }  
        map<string,worktype> workTypeMapData = new map<string,worktype>();
        
        WorkType worktype = BLN_TestDataFactory.createWorkType('Warranty Replacement', 11.00, true, false); 
        worktype.BLN_IsMainJob__c = true;
        insert worktype;
        workTypeMapData.put(worktype.Id,worktype);
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders;  
        
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Test op',true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('Test Territory',opertatingHr.id,'United Kingdom',false);
        serviceTerritory.BLN_AnyDurationAssist__c = true;
        serviceTerritory.BLN_Type__c = 'Mobile';
        insert serviceTerritory;
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = '6565653';
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        wOLI.serviceterritoryId = serviceTerritory.Id;
        insert wOLI;
        WorkOrderLineItem woli1 = [select ID,BLN_RemedyTaskId__c,WorkTypeId,WorkOrderId,serviceterritory.BLN_Type__c,workType.BLN_IsMainJob__c from WorkOrderLineItem where Id=:woli.ID];

        BLN_Vehicle__c vehicle = new BLN_Vehicle__c();
        vehicle.BLN_SpecialVehicle__c = false;
        insert vehicle;
        
        Case cases = new Case();
        cases.BLN_Vehicle__c = vehicle.Id;
        insert cases;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prd = new Product2();
        prd.BLN_ProductCategory__c = 'Sunroof';
        prd.BLN_ProductVanSize__c = 6;
        prd.BLN_SkillComplexity__c=5;
        prd.Name = 'Sunroof';
        prodlist.add(prd);
        insert prodList;
        
        BLN_GenerateSkillRequirement.createSkillRequirement(wOLI1,skillMapData,cases,true,prodList,workTypeMapData,serviceTerritory);
        system.assertEquals(5, prd.BLN_SkillComplexity__c, 'DifficultyFactor Should be same');   
    }
    
    //sets up data for skills, work types, work orders, vehicle, cases, products, operating hours, and service territories, then tests the createSkillRequirement method 
    @isTest
    public static void generateSkillRequirementSpecial1(){
        testSetup();
        
        //Special.
        map<string,string> skillMapData = new map<string,string>();
        List<Skill> skills = new List<Skill>([SELECT ID,masterlabel from skill]);
        for(Skill sk:skills){
            skillMapData.put(sk.MasterLabel,sk.Id); 
        }
        map<string,worktype> workTypeMapData = new map<string,worktype>();
        
        WorkType worktype = BLN_TestDataFactory.createWorkType('Replacement', 11.00, true, true); 
        workTypeMapData.put(worktype.Id,worktype);
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders;  
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = '6565653';
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        insert wOLI;
        
        BLN_Vehicle__c vehicle = new BLN_Vehicle__c();
        vehicle.BLN_SpecialVehicle__c = true;
        insert vehicle;
        Case cases = new Case();
        cases.BLN_Vehicle__c = vehicle.Id;
        insert cases;
        Case cas = [Select Id,BLN_Vehicle__c,BLN_Vehicle__r.BLN_SpecialVehicle__c from Case where Id=:cases.Id];
        
        Product2 prd = new Product2();
        prd.BLN_ProductCategory__c = '2510';
        prd.BLN_ProductVanSize__c = 6;
        prd.BLN_SkillComplexity__c = 9;
        prd.Name = 'Sunroof';
        insert prd;
        List<Product2> prd1 = [Select Id,BLN_SkillComplexity__c,BLN_ProductCategory__c,BLN_ProductVanSize__c,Name from Product2 where id =:prd.Id];  
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Test op',true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('Test Territory',opertatingHr.id,'United Kingdom',false);

        BLN_GenerateSkillRequirement.createSkillRequirement(wOLI,skillMapData,cas,true,prd1,workTypeMapData,serviceTerritory);   
        system.assertEquals(9, prd.BLN_SkillComplexity__c, 'DifficultyFactor Should be same');  
    }
    
    //sets up data for skills, work types, work orders, cases, products, operating hours, and service territories, then tests the createSkillRequirement method 
    @isTest
    public static void generateSkillRequirementSpecial2(){
        testSetup();
        
        //Special.
        map<string,string> skillMapData = new map<string,string>();
        List<Skill> skills = new List<Skill>([SELECT ID,masterlabel from skill]);
        for(Skill sk:skills){
            if(sk.MasterLabel == 'Side & Rear'){
                skillMapData.put(System.Label.BLN_Side_RearSkill,sk.Id);
            } else {
                skillMapData.put(sk.MasterLabel,sk.Id);
            }
        }
        
        map<string,worktype> workTypeMapData = new map<string,worktype>();
        
        WorkType worktype = BLN_TestDataFactory.createWorkType('Side & Rear Replacement', 11.00, true, true); 
        workTypeMapData.put(worktype.Id,worktype);
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders;  
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = '6565653';
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        insert wOLI;
        
        BLN_Vehicle__c vehicle = new BLN_Vehicle__c();
        vehicle.BLN_SpecialVehicle__c = false;
        insert vehicle;
        
        Case cases = new Case();
        cases.BLN_Vehicle__c = vehicle.Id;
        insert cases;
        
        Product2 prd = new Product2();
        prd.BLN_ProductCategory__c = '5330';
        prd.BLN_ProductVanSize__c = 6;
        prd.BLN_SkillComplexity__c = 10;
        prd.Name = '5330';
        insert prd;
		List<Product2> prd1 = [Select Id,BLN_SkillComplexity__c,BLN_ProductCategory__c,BLN_ProductVanSize__c,Name from Product2 where id =:prd.Id];        
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Test op',true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('Test Territory',opertatingHr.id,'United Kingdom',false);

        BLN_GenerateSkillRequirement.createSkillRequirement(wOLI,skillMapData,cases,true,prd1,workTypeMapData,serviceTerritory);   
        system.assertEquals(10, prd.BLN_SkillComplexity__c, 'DifficultyFactor Should be same');  
    } 
    
    //sets up data for skills, work types, work orders, cases, products, operating hours, and service territories, then tests the createSkillRequirement method 
     @isTest
    public static void generateSkillRequirementSunroof(){
        testSetup();
        
        //Sunroof.
        map<string,string> skillMapData = new map<string,string>();
        List<Skill> skills = new List<Skill>([SELECT ID,masterlabel from skill]);
        for(Skill sk:skills){            
            skillMapData.put(sk.MasterLabel,sk.Id); 
        }
        map<string,worktype> workTypeMapData = new map<string,worktype>();
        
        WorkType worktype = BLN_TestDataFactory.createWorkType('Replacement & Recalibration', 11.00, true, true); 
        workTypeMapData.put(worktype.Id,worktype);
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders;  
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = '6565653';
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        insert wOLI;
        
        BLN_Vehicle__c vehicle = new BLN_Vehicle__c();
        vehicle.BLN_SpecialVehicle__c = true;
        insert vehicle;

        Case cases = new Case();
        cases.BLN_Vehicle__c = vehicle.Id;
        insert cases;
        Case cas = [Select Id,BLN_Vehicle__c,BLN_Vehicle__r.BLN_SpecialVehicle__c from Case where Id=:cases.Id];
        Product2 prd = new Product2();
        prd.BLN_ProductCategory__c = '20';
        prd.BLN_ProductVanSize__c = 6;
        prd.BLN_SkillComplexity__c = 9;
        prd.Name = 'Sunroof';
        insert prd;
        List<Product2> prd1 = [Select Id,BLN_SkillComplexity__c,BLN_ProductCategory__c,BLN_ProductVanSize__c,Name from Product2 where id =:prd.Id];  
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Test op',true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('Test Territory',opertatingHr.id,'United Kingdom',false);

        BLN_GenerateSkillRequirement.createSkillRequirement(wOLI,skillMapData,cas,true,prd1,workTypeMapData,serviceTerritory);   
        system.assertEquals(9, prd.BLN_SkillComplexity__c, 'DifficultyFactor Should be same');  
    }
}