/**
 * @description       :
 * @author            : Sourabh Bhattacharjee
 * @last modified on  : 16-10-2024
 * @last modified by  : dheeraj sharma
 * Modifications Log
**/
public without sharing class BLN_PortalAppoinmentUpdate {  
    public static String updateSrId;  
  
    // Method to update the service request with a new appointment  
    @AuraEnabled  
    public static String updateServiceRequest(Id recordId, Id newAppointmentId, Date selectslotdate, String starttime, String endtime, String oldAppId) {  
        try {
            
            String[] startimearray = starttime.split(':');  
            String[] endtimearray = endtime.split(':');  
            List<String> orderIdList = new List<String>();
            DateTime arrivalwindowstart = DateTime.newInstance(selectslotdate.year(), selectslotdate.month(), selectslotdate.day(), Integer.valueOf(startimearray[0]), Integer.valueOf(startimearray[1]), 0);  
            DateTime arrivalwindowend = DateTime.newInstance(selectslotdate.year(), selectslotdate.month(), selectslotdate.day(), Integer.valueOf(endtimearray[0]), Integer.valueOf(endtimearray[1]), 0);  
            arrivalwindowend = arrivalwindowend.addDays(1);  
            // List<String> testList = new List<String>();
            ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            ServiceAppointment sa = [SELECT ID, AppointmentNumber,AccountId, ArrivalWindowStartTime, ArrivalWindowEndTime, BLN_Case__c,BLN_Case__r.ownerid,BLN_IsPrepDataCall__c, Status, DueDate, BLN_RebookedServiceAppointment__c, BLN_AppointmentRebook__c, BLN_RebookSource__c,BLN_RebookHistory__c,city,country,geocodeAccuracy,latitude,longitude,postalCode,state,street  
                                     FROM ServiceAppointment  
                                     WHERE ID = :newAppointmentId AND BLN_Case__c = :recordId  
                                     LIMIT 1];
            ServiceAppointment oldSa=[SELECT ID,AppointmentNumber, AccountId, ArrivalWindowStartTime, ArrivalWindowEndTime, BLN_Case__c, Status, DueDate,BLN_IsPrepDataCall__c, BLN_RebookedServiceAppointment__c, BLN_AppointmentRebook__c, BLN_RebookSource__c,BLN_OriginalScheduledStartTime__c,BLN_OriginalScheduledEndTime__c,city,country,geocodeAccuracy,latitude,longitude,postalCode,state,street  
                                     FROM ServiceAppointment  
                                     WHERE ID = :oldAppId AND BLN_Case__c = :recordId  
                                     LIMIT 1];
                            
            OrderItem.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            List<OrderItem> orderItemList = [SELECT Id,BLN_StockLineNumber__c FROM OrderItem WHERE BLN_ServiceAppointment__c =: oldAppId];
            for (OrderItem orderItm : orderItemList) {
                orderIdList.add(orderItm.Id);
            }
         //  String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            if (sa.Id != null) {  
               // sa.Status = System.label.BLN_ScheduledStatus;  
                sa.BLN_Case__c = recordId;  
                sa.ArrivalWindowStartTime = arrivalwindowstart;  
                sa.EarliestStartTime = arrivalwindowstart;  
                sa.DueDate = arrivalwindowend;
                sa.BLN_OriginalScheduledStartTime__c = oldSa.ArrivalWindowStartTime;
                sa.BLN_OriginalScheduledEndTime__c = oldSa.ArrivalWindowEndTime;
                sa.BLN_RebookedServiceAppointment__c = oldAppId;  
                sa.BLN_RebookSource__c = System.label.BLN_PortalValue;  
                sa.BLN_AppointmentRebook__c = true;
                sa.BLN_RebookHistory__c = sa.AppointmentNumber + ' is created via rebooking of ' + oldSa.AppointmentNumber;
                sa.ownerId = sa.BLN_Case__r.ownerid ;
                sa.BLN_IsPrepDataCall__c = false;
                 // Map address fields from old service appointment to new service appointment  
                sa.city = oldSa.city;  
                sa.country = oldSa.country;  
                sa.geocodeAccuracy = oldSa.geocodeAccuracy;  
                sa.latitude = oldSa.latitude;  
                sa.longitude = oldSa.longitude; 
                sa.postalCode = oldsa.postalCode;
                sa.state = oldsa.state;
                sa.street = oldsa.street;
               // sa.BLN_RebookHistory__c = '<a href="' + baseUrl + '/' + recordId1 + '" style="color:green;">' + recordId1 + '</a> is created via rebooking of <a href="' + baseUrl + '/' + recordId2 + '" style="color:green;">' + recordId2 + '</a>';
            }  
            Database.SaveResult saveResult = Database.update(sa, false); 
            if (saveResult.isSuccess()) {                
                updateSrId = saveResult.getId();
                /*String apptUpdateResponse= BLN_AppointmentBooking.scheduleAppointment(newAppointmentId);
		    	System.debug('response---->'+apptUpdateResponse);*/
                if (!String.isBlank(updateSrId)) {  
                    BLN_PortalAppoinmentUpdate.updateOldServiceRequest(oldAppId,recordId,newAppointmentId,selectslotdate,starttime);  
                }  
            }  
  
            return updateSrId;  
        } catch (Exception e) {  
           // throw new AuraHandledException(e.getMessage() + '--' + e.getLineNumber() + '==' + e.getCause() + '...' + e.getStackTraceString()); 
             return 'Error updating old service request.';
        }  
    }  
  
    // Method to update an old service request and its appointments  
    @AuraEnabled  
    public static void updateOldServiceRequest(String oldAppointmentId,Id recordId,Id newAppointmentId,Date selectslotdate, String starttime) {  
        try {    

                BLN_PortalAppoinmentUpdate.scheduleAppointment(newAppointmentId);
                        
            ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            ServiceAppointment sa = [SELECT ID, Status, AppointmentNumber,BLN_FailureReason__c,BLN_CancellationSource__c,BLN_CustomerName__c,BLN_CancellationBy__c, BLN_SubFailureReason__c,BLN_CancellationComments__c, BLN_RebookedServiceAppointment__c, BLN_AppointmentRebook__c   FROM ServiceAppointment  WHERE ID = :oldAppointmentId   LIMIT 1];  
  
            if (sa != null) {  
                sa.Status = System.label.BLN_Canceled;  
                sa.BLN_FailureReason__c = System.label.BLN_CustomerIssue;  
                sa.BLN_SubFailureReason__c = 'Cust Unavailable/Cancelled';  
                sa.BLN_CancellationSource__c = System.label.BLN_PortalValue;
                sa.BLN_CancellationBy__c = 'Belron';
                sa.BLN_CancellationComments__c = sa.AppointmentNumber + ' is cancelled via rebooking by Portal user ' + sa.BLN_CustomerName__c ;
            }  
            ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable();
            Database.update(sa, false);  
            // Call the additional method after the update as a future method   

                BLN_PortalAppoinmentUpdate.getOrderItemIdsByOrder(oldAppointmentId,recordId,newAppointmentId,selectslotdate,starttime);  
        
        } catch (Exception e) {  
            BLN_ExceptionLogger.captureException(e);
           // throw new AuraHandledException('Error updating old service request: ' + e.getMessage());  
        }  
    }  
    public static void getOrderItemIdsByOrder(String oldAppointmentId, Id recordId, Id newAppointmentId, Date selectslotdate, String starttime) {                   
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();          
        List<OrderItem> originalOrderItems = new List<OrderItem>(); // List to store original OrderItem records          
        List<OrderItem> updatedOrderItems = new List<OrderItem>();  // List to store updated OrderItem records          
      
        try { 
            String[] startimearray = starttime.split(':');   
            DateTime arrivalwindowstartn = DateTime.newInstance(selectslotdate.year(), selectslotdate.month(), selectslotdate.day(), Integer.valueOf(startimearray[0]), Integer.valueOf(startimearray[1]), 0);  

            OrderItem.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            List<OrderItem> oIList = [SELECT Id, BLN_ServiceAppointment__c, BLN_StockOrderAppointmentDate__c   
                                      FROM OrderItem          
                                      WHERE Order.BLN_Case__c = :recordId AND BLN_IsProductSelected__c = true and Order.Status = 'Accepted'];          
      
            // Debug statement to log the retrieved OrderItem list          
           // System.debug('Retrieved OrderItems: ' + oIList);          
      
            if (oIList.isEmpty()) {  
               // System.debug('No OrderItems found for the given criteria.');  
                return;  
            }  
       
            // Update the OrderItems with the new appointment          
            for (OrderItem oi : oIList) {          
                oi.BLN_ServiceAppointment__c = newAppointmentId;          
                oi.BLN_StockOrderAppointmentDate__c = arrivalwindowstartn;          
                orderItemsToUpdate.add(oi);       
                // Add updated OrderItem to the updatedOrderItems list          
                updatedOrderItems.add(oi.clone(true, true, true, true)); // Clone to keep the updated state          
            }          
      
            if (!orderItemsToUpdate.isEmpty()) {          
                updateOrderItems(orderItemsToUpdate, originalOrderItems, updatedOrderItems);          
            } else {  
             //   System.debug('No OrderItems to update.'); 
             return; 
            }  
        } catch (Exception e) {                  
           //  System.debug('Exception occurred: ' + e.getMessage());          
            BLN_ExceptionLogger.captureException(e);          
            // throw new AuraHandledException('Error retrieving order items: ' + e.getMessage());          
        }        
    }      
      
    public static void updateOrderItems(List<OrderItem> orderItemsToUpdate, List<OrderItem> originalOrderItems, List<OrderItem> updatedOrderItems) {    
        try {    
            update orderItemsToUpdate;    
      
            // Extract IDs from originalOrderItems and updatedOrderItems          
            List<Id> originalOrderItemIds = new List<Id>();          
            List<Id> updatedOrderItemIds = new List<Id>();          
      
            for (OrderItem oi : originalOrderItems) {          
                originalOrderItemIds.add(oi.Id);          
            }          
      
            for (OrderItem oi : updatedOrderItems) {          
                updatedOrderItemIds.add(oi.Id);          
            }          
                     
            makeStockRequestCallout(updatedOrderItemIds, originalOrderItemIds);      
        } catch (Exception e) {    
            // Debug statement to log the exception message          
           // System.debug('Exception occurred during update: ' + e.getMessage());          
            BLN_ExceptionLogger.captureException(e);          
            // throw new AuraHandledException('Error updating order items: ' + e.getMessage());          
        }    
    }    
    
    @future(callout=true)    
    public static void makeStockRequestCallout(List<Id> updatedOrderItemIds, List<Id> originalOrderItemIds) {    
        try {    
            HttpResponse response = BLN_QuotesAndStocksAPICallout.makeStockRequestCalloutFromPortal(updatedOrderItemIds, updatedOrderItemIds, false);    
      
            // Check if the response is null or empty          
            if (response == null || String.isBlank(response.getBody())) {  
                return ;
              //  System.debug('Response is null or empty');          
                // throw new AuraHandledException('Received empty response from the API');          
            }    
        } catch (Exception e) {    
            // Debug statement to log the exception message          
           // System.debug('Exception occurred during callout: ' + e.getMessage());          
            BLN_ExceptionLogger.captureException(e);          
            // throw new AuraHandledException('Error during callout: ' + e.getMessage());          
        }    
    }    
    
  
    // New method to retrieve Case fields  
    @AuraEnabled  
    public static Case getCaseFields(Id caseId) {  
            Case caseRecord = [SELECT Id, Subject, Status, BLN_IsForceReprice__c FROM Case WHERE Id = :caseId];  
            return caseRecord;     
    } 
    
    // future method for schedule appoinment via FSL
     @future
    public static void scheduleAppointment(String appointmentId){
      // System.debug('scheduleAppointment enter.');
        FSL.ScheduleResult result = new FSL.ScheduleResult();
        String returnCode = '';
        try{
            ServiceTerritory serviceTerritory = BLN_PortalHandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);
          
            if( !Test.isRunningTest() && serviceTerritory != null){           
                if(Boolean.valueOf(System.Label.BLN_IsSchedulingBypass) != true){
                    result = FSL.ScheduleService.schedule(serviceTerritory.BLN_SchedulingPolicy__c, appointmentId);
                   // System.debug('result enter.'+result);
                }else{
                    result = null;
                }               
            }
            if(result != null){
                returnCode = System.Label.BLN_SchedulingSuccess; //'{"returnCode": "Success"}';
              //  System.debug('returnCode enter 47.'+returnCode);
            } else {
                BLN_PortalAppoinmentUpdate.updateFailedAppointment(appointmentId);
                returnCode = System.Label.BLN_SchedulingFailed; //'{"returnCode": "Scheduling Fail"}';
               // System.debug('returnCode enter 50.'+returnCode);
            }
        } catch(exception ex) {
            BLN_ExceptionLogger.captureException(ex);
            BLN_PortalAppoinmentUpdate.updateFailedAppointment(appointmentId);
            returnCode = System.Label.BLN_SchedulingFailed; //'{"returnCode": "Scheduling Fail"}';
            //System.debug('returnCode enter 56.'+returnCode);
        }
        //return returnCode;
        
    }

     @future
    public static void updateFailedAppointment(String appointmentId) {   
        ServiceAppointment serviceApp = BLN_PortalQueryHandlerWebservice.getServiceAppointment(appointmentId);
        if(serviceApp != null){
            serviceApp.BLN_IsBookingFailed__c = true;
        }
        if(Schema.sObjectType.ServiceAppointment.isUpdateable()){
            UPDATE serviceApp;
        }
    }
    
}