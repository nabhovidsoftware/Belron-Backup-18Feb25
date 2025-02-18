/** @description : BLN_AppointmentRebookTest Class used for testing BLN_AppointmentRebook.
*  	@author: Wasim Akram
* 	@Story: 
*	@Created Date: 22/05/2024
*/
@isTest
public class BLN_AppointmentRebookTest {

    @isTest
    public static void unitTest() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, null, 'Profile Should be available');
        }
        
        // Create test data
        Account accountObj =  BLN_TestDataFactory.createAccount('Sample', 'PersonAccount', '8698023890');
        insert accountObj;

        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest', 'Job Request', 'New');
        caseObj.AccountId = accountObj.Id;
        caseObj.Priority = System.label.BLN_Critical;
        insert caseObj;

        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.Name = 'Test';
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        prod.BLN_ADASRecalibrationNeeded__c = false;
        prod.ProductCode = '1234';
        Prod.BLN_MDMID__c = '1234';
        insert prod;

        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , true);
        WorkType replacementWT = BLN_TestDataFactory.createWorkType(System.label.BLN_WarrantyReplacement, 4 , true ,  true);

        WorkOrder wo = new WorkOrder();
        wo.BLN_RemedyJobId__c = '001005';
        wo.WorkTypeId = replacementWT.Id;
        wo.ServiceTerritoryId = st.id;
        insert wo;

        WorkOrderLineItem woLi = BLN_AppointmentDataCreationService.generateWoLi(wo, replacementWT);
        woLi.workTypeId = replacementWT.Id;
        insert woLi;
        
        Datetime now = Datetime.now();
        ServiceAppointment oldSA = new ServiceAppointment();
        oldSA.ParentRecordId = accountObj.id;
        oldSA.Status = 'open';
        oldSA.EarliestStartTime = now;
        oldSA.DueDate = now.addMinutes(30);
        oldSA.worktypeid = replacementWT.id;
        oldSA.ServiceTerritoryId = st.Id;
        oldSA.BLN_WorkOrderNumber__c = wo.Id;
        insert oldSA;

        ServiceAppointment newSA = new ServiceAppointment();
        newSA.ParentRecordId = accountObj.id;
        newSA.status = 'open';
        newSA.EarliestStartTime = now.addMinutes(30);
        newSA.DueDate = now.addMinutes(60);
        newSA.worktypeid = replacementWT.id;
        newSA.ServiceTerritoryId = st.Id;
        newSA.BLN_WorkOrderNumber__c = wo.Id;
        insert newSA;

        /*List<Object> objList = new List<Object>();
        Map<String, Object> obj = new Map<String, Object>{
            'productCode' => prod.ProductCode,
            'quantity' => 5
        };
        objList.add(obj);*/
        List<BLN_AppointmentDataCreationService.ProductData> objList = new List<BLN_AppointmentDataCreationService.ProductData>();
        BLN_AppointmentDataCreationService.ProductData prodData = new BLN_AppointmentDataCreationService.ProductData();
        prodData.productCode = prod.BLN_MDMID__c;
        prodData.quantity = 5;
        objList.add(prodData);
        
        List<BLN_AppointmentRebook.RebookDetail> rebookDetailsList = new List<BLN_AppointmentRebook.RebookDetail>();
        
        for (Integer i = 0; i < 3; i++) {
            BLN_AppointmentRebook.RebookDetail rebook = new BLN_AppointmentRebook.RebookDetail();
            rebook.saId = newSA.Id;
            rebook.oldSAId = oldSA.Id;
            rebook.slotStart = DateTime.now();
            rebook.slotFinish = DateTime.now().addHours(1);
            // rebook.isDropOff = true;
            rebook.cancellationReason = 'Repair';
            rebook.subReason = 'Too Large to Repair';
            if (i == 0) {
                rebook.action = 'New';
            } else if (i == 1) {
                rebook.action = 'Existing';
            } else if (i == 2) {
                rebook.action = 'Cancel';
            }
            rebook.productList = objList;
            rebookDetailsList.add(rebook);
        }

        BLN_AppointmentRebook.RebookParams rebookParam = new BLN_AppointmentRebook.RebookParams();
        rebookParam.caseId = caseObj.id;
        rebookParam.rebookDetails = rebookDetailsList;

        List<Object> paramsForRebook = new List<Object>{ rebookParam };

        Test.startTest();
        BLN_AppointmentRebook.appointmentRebook(paramsForRebook);
        Test.stopTest();
    }
}