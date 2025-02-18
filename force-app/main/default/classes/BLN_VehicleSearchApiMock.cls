/*****************************************
ClassName : BLN_VehicleSearchApiMock
Description : FOUK-3149 and FOUK-1009 This controller class is used in lwc.
CreatedDate: 03-11-2023
CreatedBy : PwC-India
****************************************/

/** @description :This class is used in BLN_VehicleSearchApiTest class. */
@isTest
Public class BLN_VehicleSearchApiMock implements HttpCalloutMock{
    
/** @description :This method is used send response. 
    @return HTTPResponse
 * */ 
    Public HTTPResponse respond(HTTPRequest request) {
           String jsonRes=		'{'+
		'    '+ System.Label.BLN_vehicleVINW0L +
		'    '+ System.Label.BLN_vehicleRegistration +
		'    '+ System.Label.BLN_vehicleRegistrationLic +
		'    '+ System.Label.BLN_providedVehicleBody +
		'    '+ System.Label.BLN_providedVehicleModel +
		'    '+ System.Label.BLN_providedVehicleMake +
		'    '+ System.Label.BLN_providedVehicleMod +
		'    '+ System.Label.BLN_providedVehicleColour +
		'    '+ System.Label.BLN_vehicleIdentifierTypeValue +
		'}';
        string jsonRes2 = '{'+
		'    '+ System.Label.BLN_vehicleVINW0L +
		'    '+ System.Label.BLN_vehicleRegistration +
		'    '+ System.Label.BLN_vehicleRegistrationLic +
		'    '+ System.Label.BLN_providedVehicleBody +
		'    '+ System.Label.BLN_providedVehicleModel +
		'    '+ System.Label.BLN_providedVehicleMake +
		'    '+ System.Label.BLN_providedVehicleMod +
		'    '+ System.Label.BLN_providedVehicleColour +
		'    '+ System.Label.BLN_vehicleIdentifierType +
		'}';
          if(request.getEndpoint() == 'callout:BLN_OktaAuthToken'){
            HttpResponse response = new HttpResponse();
            response.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"eyJraWQiOiJEcXBZVndSVVh3Vmo1SHVSb0xtZ0N3T2J4b1pDNUZsQUxRQjlEMmJPR1NFIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULmtUaTh3cFItR3ZwdlhSSGJ0V3pNU1hjc0tsOHVXUmxqbFZiS21VT2xobzAiLCJpc3MiOiJodHRwczovL2JlbHJvbi1xYS5va3RhcHJldmlldy5jb20vb2F1dGgyL2F1czN5NGQ2MThmb1hRY0ZhMHg3IiwiYXVkIjoiYXBpOi8vand0YXV0aCIsImlhdCI6MTY5NzIwNDU4OSwiZXhwIjoxNjk3MjA4MTg5LCJjaWQiOiIwb2EzeTRlM2dvTzdrUWlaYTB4NyIsInNjcCI6WyJyZWFkIl0sInN1YiI6IjBvYTN5NGUzZ29PN2tRaVphMHg3In0.IqHWRVQAm2eW0NAeORb2rJO_jyHrq1-cdeCDjg4yiZXZQVc0vL1EqT1to4zdSj_yNQmGeRYPFActpY73HE6CN_YQNZ8AeoJ462bReuwb9VuL0RBCqxG68J2p2K4sfBElh4S4tKQhPG-K7W7QjaWMmqYk9bluRrWb_ye7tV9IeuzE9fGO6knM6zlMtTcEX0IIoO1oTEudeVsYCymy24vMCSRbzMg05Bexxj9CQ4Q2XqU016PiYBd5giWP5h3ko_6AXTyQv4JUy-C2YW2x5toiqJqUW5kZtNjrB8IkGnMRNXxvGX5yKZjivyTrU6KCSPNU3GE-rNpbjPRIKB8P2KG2Pg","scope":"read"}');
            response.setStatusCode(200);
            return response;    //tgrgrg
        }else if(request.getEndpoint().endsWith('BN12OEE')){
            HttpResponse response = new HttpResponse();
            response.setBody(jsonRes);
            response.setStatusCode(200);
            return response; 
        }else if(request.getEndpoint().endsWith('tgrgrg')){
            HttpResponse response = new HttpResponse();
            response.setBody(jsonRes2);
            response.setStatusCode(200);
            return response; 
        }else {
            return null;
        }
        
    }

}