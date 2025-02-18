global class BLN_PortalSACreateSharingBatch implements Database.Batchable<SObject>, Database.Stateful {  
  
    global Database.QueryLocator start(Database.BatchableContext BC) {  
        // Query to retrieve the ServiceAppointment records that meet the criteria 
        ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        return Database.getQueryLocator([  
            SELECT Id, BLN_RebookSource__c, BLN_ServiceTerritoryName__c, Status, BLN_ReadyToDispatch_Portal__c  
            FROM ServiceAppointment  
            WHERE BLN_RebookSource__c = 'portal'  
                AND BLN_ServiceTerritoryName__c != null  
                AND Status = 'Scheduled'  
                AND BLN_ReadyToDispatch_Portal__c = false  
        ]);  
    }  
  
    global void execute(Database.BatchableContext BC, List<SObject> scope) {  
        List<ServiceAppointmentShare> sharesToCreate = new List<ServiceAppointmentShare>();  
        Set<String> territoryNameSet = new Set<String>();  
        List<ServiceAppointment> serviceAppointmentsToUpdate = new List<ServiceAppointment>();  
        Map<Id, ServiceAppointment> saMap = new Map<Id, ServiceAppointment>(); // Map to hold ServiceAppointment by Id  
  
        // Collect all BLN_ServiceTerritoryName__c values to query groups in one go  
        for (SObject sObj : scope) {  
            ServiceAppointment sa = (ServiceAppointment)sObj;  
            territoryNameSet.add(sa.BLN_ServiceTerritoryName__c);  
            saMap.put(sa.Id, sa); // Add ServiceAppointment to the map  
        }  
  
        // Query groups based on the territory names  
        Map<String, Group> groupMap = new Map<String, Group>(); 
         Group.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        if (!territoryNameSet.isEmpty()) {  
            for (Group g : [SELECT Id, Name FROM Group WHERE Name IN :territoryNameSet]) {  
                groupMap.put(g.Name, g);  
            }  
        }  
  
        for (SObject sObj : scope) {  
            ServiceAppointment sa = (ServiceAppointment)sObj;  
            try {  
                if (groupMap.containsKey(sa.BLN_ServiceTerritoryName__c)) {  
                    // Create a new ServiceAppointmentShare record  
                    ServiceAppointmentShare saShare = new ServiceAppointmentShare();  
                    saShare.ParentId = sa.Id; // Link to the ServiceAppointment record  
                    saShare.UserOrGroupId = groupMap.get(sa.BLN_ServiceTerritoryName__c).Id; // Get the group Id based on the territory name  
                    saShare.RowCause = Schema.ServiceAppointmentShare.RowCause.Manual; // Set the sharing reason to 'manual'  
                    saShare.AccessLevel = 'Edit'; // Set the access level to 'Edit'  
  
                    sharesToCreate.add(saShare);  
  
                    // Mark ServiceAppointment as ready to dispatch  
                    sa.BLN_ReadyToDispatch_Portal__c = true;  
                }  
            } catch (Exception e) {  
               // System.debug('An error occurred for ServiceAppointment Id: ' + sa.Id + ' - ' + e.getMessage());  
                // Skip the current ServiceAppointment and continue with the next one  
                continue;  
            }  
        }  
  
        // Insert the ServiceAppointmentShare records  
        if (!sharesToCreate.isEmpty()) {  
            try {  
                Database.SaveResult[] SR = Database.insert(sharesToCreate, false);  
               // System.debug('SaveResult: ' + SR);  
  
                for (Integer i = 0; i < SR.size(); i++) {  
                    if (SR[i].isSuccess()) { // Only look at successes  
                        // Retrieve the corresponding ServiceAppointment from the map  
                        ServiceAppointment sa = saMap.get(sharesToCreate[i].ParentId);  
                        if (sa != null) {  
                            serviceAppointmentsToUpdate.add(sa);  
                        }  
                    } 
                }  
  
                // Update the ServiceAppointment records only if the insert succeeds  
                if (!serviceAppointmentsToUpdate.isEmpty()) {  
                    update serviceAppointmentsToUpdate;  
                }  
  
            } catch (DmlException e) {  
               // System.debug('An error occurred while creating ServiceAppointmentShare records: ' + e.getMessage());  
            }  
        }  
    }  
  
    global void finish(Database.BatchableContext BC) {  
       // System.debug('Batch processing completed.');  
    }  
}