/*****************************************
    ClassName : BLN_VehicleSearchParser
    Description : FOUK-3964 This test is used to parse the JSON request. This is the helper class for BLN_VehicleSearchAPI
    CreatedDate: 18-12-2023
    CreatedBy : Shubham Bonde (PWC-India)
    ****************************************/


/*  *@description:This test is used to parse the JSON request. This is the helper class for BLN_VehicleSearchAPI */
public class BLN_VehicleSearchParser {
    public String vehicleVIN;	//W0LPF6ENXCG093317
	public String vehicleRegistration;	//B10RWS  
	public String vehicleRegistrationLicensingAuthority;	//DVLA
	public String providedVehicleBodyTypeName;	//5 DOOR HATCHBACK
	public String providedVehicleModelYear;	//2012
	public String providedVehicleMake;	//VAUXHALL
	public String providedVehicleModel;	//ASTRA SRI CDTI S/S
	public String providedVehicleColour;	//GREY
	public String vehicleIdentifierTypeCode;	//MVRIS_CD
	public String vehicleIdentifierTypeValue;  //D0EUU
    
/*  *@description:This method is used to parse the JSON request.
    *return : String
*/
	public static BLN_VehicleSearchParser parse(String json){
		return (BLN_VehicleSearchParser) System.JSON.deserialize(json, BLN_VehicleSearchParser.class);
	}
}