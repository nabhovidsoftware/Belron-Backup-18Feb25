/** @description : This webservice is used by EWP team to get the nearest branch and mobile locations.
*   @Story : FOUK-4639
*   @Author: PwC-India
*   @lastmodifiedDate: 05/07/2024
*/


@RestResource(urlMapping='/nearest-locations')
global without sharing class BLN_ServiceLocationEWPDataController {
    
    @HttpGet
    global static void getNearestServiceLocationsByCoords(){
        BLN_IntegrationLogger__c integrat = new BLN_IntegrationLogger__c();
        integrat.BLN_RequestSent__c = System.now();
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<LocationWrapper> nearestLocationDetails = new List<LocationWrapper>();
        LocationWrapper locWrapper;
        List<ServiceTerritory> branchST = new List<ServiceTerritory>();
        ReturnWrapperSuccess ret = new ReturnWrapperSuccess();
        try{
        Double latitude = Double.valueOf(req.params.get('latitude'));
        Double longitude = Double.valueOf(req.params.get('longitude'));
        Boolean isSpecial = req.params.get('specialVehicle') == 'true' || req.params.get('specialVehicle') == 'True' ? true : false;  
		
            branchST = isSpecial ? [SELECT Id,Address,Latitude,Longitude,BLN_GUID__c,BLN_CostCenter__c,BLN_OrgCodeLocation__c,BLN_Type__c,DISTANCE(Address,GEOLOCATION(:latitude,:longitude),'mi') distanceChart FROM ServiceTerritory WHERE BLN_ConsiderforR1__c = false AND IsActive = true AND BLN_Type__c = :System.label.BLN_Branch AND BLN_Specials__c = true AND BLN_GUID__c != '' AND Latitude != null AND Longitude != null AND BLN_CostCenter__c != '' WITH SECURITY_ENFORCED ORDER BY DISTANCE(Address,GEOLOCATION(:latitude,:longitude),'mi') ASC LIMIT 3] :
            [SELECT id,Address,BLN_GUID__c,BLN_CostCenter__c,BLN_OrgCodeLocation__c,BLN_Type__c,DISTANCE(Address,GEOLOCATION(:latitude,:longitude),'mi') sampleDistance FROM ServiceTerritory WHERE BLN_ConsiderforR1__c = false AND IsActive=true AND BLN_Type__c= :System.label.BLN_Branch AND Latitude != null AND Longitude != null AND BLN_GUID__c != '' AND BLN_CostCenter__c != '' WITH SECURITY_ENFORCED ORDER BY DISTANCE(Address,GEOLOCATION(:latitude,:longitude),'mi') ASC LIMIT 3];
            for(ServiceTerritory st : branchST){
                locWrapper = new LocationWrapper();
                locWrapper.costCenterId = st.BLN_OrgCodeLocation__c;
                locWrapper.locationId = st.BLN_GUID__c;
                locWrapper.mobileLocationIndicator = false;
                nearestLocationDetails.add(locWrapper);
            }
            
            if(!isSpecial){
                List<FSL__Polygon__c> polygonList = new List<FSL__Polygon__c>();
                if(FSL__Polygon__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){  
                    
                    polygonList = [SELECT id,FSL__Service_Territory__r.BLN_GUID__c,FSL__Service_Territory__r.BLN_CostCenter__c,FSL__Service_Territory__r.BLN_OrgCodeLocation__c,FSL__Service_Territory__r.BLN_Type__c,FSL__Service_Territory__r.Address FROM FSL__Polygon__c WHERE FSL__Service_Territory__r.BLN_ConsiderforR1__c = false AND FSL__Service_Territory__r.isActive = true AND FSL__Service_Territory__r.BLN_Type__c = :System.label.BLN_Mobile AND Id IN :FSL.PolygonUtils.getAllPolygonsByLatLong(longitude,latitude) WITH SECURITY_ENFORCED ORDER BY DISTANCE(FSL__Service_Territory__r.Address,GEOLOCATION(:latitude,:longitude),'mi') ASC LIMIT 1]; 
                    
                    for(FSL__Polygon__c poly : polygonList){
                        locWrapper = new LocationWrapper();
                        locWrapper.costCenterId = poly.FSL__Service_Territory__r.BLN_OrgCodeLocation__c;
                        locWrapper.locationId = poly.FSL__Service_Territory__r.BLN_GUID__c;
                        locWrapper.mobileLocationIndicator = true;
                        nearestLocationDetails.add(locWrapper);
                    }
            	}
        	}
              
            if(!nearestLocationDetails.isEmpty()){
                ret.locations = nearestLocationDetails;     
            }
            else{
                ret.locations = new List<LocationWrapper>();  
            }
            ret.status = 'success';
                res.addHeader('Content-Type', 'application/json');
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(ret));
            }
    	catch(Exception e){
        	String status = ret.status = 'error';
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(ret));
            List<Exception> exceptionList = new List<Exception>();
            exceptionList.add(e);
            BLN_ExceptionLogger.LogExceptionRequest(exceptionList, status, '');
    	}
        
    //Logging api request through Integration Logger
    List<String> serializedIntLogList = new List<String>();
    integrat.BLN_RequestBody__c = req.params.toString();
    integrat.BLN_RequestEndPoint__c = '/nearest-locations';
    integrat.BLN_RequestMethod__c = req.httpMethod;
    integrat.BLN_RequestHeaders__c = req.headers.toString();
    integrat.BLN_RequestIssuedBy__c = UserInfo.getUserId();
    integrat.BLN_ResponseBody__c = res.responseBody?.toString();
    integrat.BLN_ResponseHeaders__c = res.headers.toString();
    integrat.BLN_ResponseStatus__c = String.valueOf(res.statusCode);
    integrat.BLN_ResponseStatusCode__c = String.valueof(res.statusCode);
    integrat.BLN_TargetSystem__c = System.label.BLN_TargetSystemSalesforce;
    integrat.BLN_ResponseReceived__c = System.Now();
    serializedIntLogList.add(JSON.serialize(integrat));
    String serializedIntLogListJSON = '[' + String.join(serializedIntLogList, ',') + ']';
    BLN_IntegrationLoggerFuture.processIntegrationLogger(serializedIntLogListJSON);

    return;
    }
     
    global class ReturnWrapperSuccess{
        private String status;
        private List<LocationWrapper> locations;
    }
    
    global class LocationWrapper {
        private String costCenterId;
        private String locationId;
        private Boolean mobileLocationIndicator;         
    }
}