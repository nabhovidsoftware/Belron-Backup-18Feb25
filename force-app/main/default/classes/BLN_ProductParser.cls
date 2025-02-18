/*****************************************
    ClassName : BLN_ProductParser
    Description : FOUK-3681, 4049 This class is used to deserialize the response.
    CreatedDate: 24-11-2023
    CreatedBy : PWC-India
    ****************************************/

/*  *@description:This class is used to deserialize the response */
public class BLN_ProductParser {
    public String discount;	//10%
	public Cls_Quote[] quote;
	public Errors[] errors;
    public String quoteId;
	public String locationId;
	public Double totalTax;
	public Integer totalRepair;
	public Double totalReplacement;
	public Double totalCalibration;
	public Double totalSundries;
    public String totalIncludingTaxMotorist;
    public String totalIncludingTaxInsuranceCompany;
	public String totalIncludingTaxTrade;
	public String totalIncludingTax;
	public String priceExpirationDate;
	public List<AvailabilityDetails> availabilityDetails;
    public InsuranceDetails insuranceDetails;
    public DiscountThresholdAmount discountThresholdAmount;
    public List<Parts> parts;
    //GPS Variables
    public List<Results> results;
    public VehicleDamage vehicleDamage;
    public Question question;
    //schematic 
    public List<List<Schematics>> schematics;
	public List<OuterWrapper> outerWrapper;
	public List<List<SchemeticWrapper>> schemeticWrapper;
	public String digitalReferenceName;

	// schematic error
	public class Errors {
		public Integer status;	//500
		public String title;	//The backend responded with an error
		public String detail;
	}





    // Service Certainty
	public ServCertainity glassDamageDocument {get;set;}

        
    
		
	public class ServCertainity {
		public String glassDamageDocumentID {get;set;}
		public String uploadURL {get;set;}
	}	



/*  *@description:This is  quote class and quote related class are used.*/  
	public class Cls_Quote {
		public String quotename;	//Quote1
		public String location;	//XYZ
        public String liability;
        public String net;
        public String vat;
        public String total;
		public String earliestAppointmentAvailability;	//Sepetember 23th,2024
		public String weatherGuard;	//Sepetember 23th,2024
		public Cls_quoteLineItem[] quoteLineItem;   
	}

/*  *@description:This is  quoteLineItem class.*/
	public class Cls_quoteLineItem {
		public String name;	//prodct1
		public Integer qty;	//1
        public String net;	//10,001
		public String vat;
        public String total;
		public Integer price;	//100
		public boolean isVap;
	}
    
/*  *@description:This is method is used to parse JSON.*/
	public static BLN_ProductParser parse(String json){
		return (BLN_ProductParser) System.JSON.deserialize(json, BLN_ProductParser.class);
	}
    
	/*  *@description:This is Parts class in which part related fields and discount fields are declared.*/
    public class Parts {
        
        // old json response
		/*public String partId;
		public Object parentPartId;
		public Object bundleName;
		public Integer partNumber;
		public String partDescription;
		public Integer priceQuantity;
		public Double baseListPrice;
		public String voucherCode;
		public Boolean inStock;
		public Double voucherDiscount;
		public Double netPriceAfterPromotion;
		public Double taxRate;
		public Double totalTax;
		public Object dynamicDiscount;
		public Double netPriceIncludingTax;
		public String optional;
		public Boolean partOfBundle;
		public Object bundleHierarchy;
		public Object nonBundlePrice;*/
        
        // new json response
		public String partId;
		public String documentnumber;
		public String parentDocumentNumber;
		public String bundleName;
		public Integer partNumber;
		public String partDescription;
		public Integer priceQuantity;
		public Double baseListPrice;
		public Double netPriceAfterPromotion;
		public Integer taxRate;
		public Double totalTax;
		public String dynamicDiscount;
		public Double netPriceIncludingTax;
		public String optional;
		public Boolean partOfBundle;
		public String bundleHierarchy;
		public String nonBundlePrice;
	}
	/*  *@description:This is AvailabilityDetails class in which stock fields are declared.*/
	public class AvailabilityDetails {
		public String stockLocationId;
		public String availableFrom;
	}
    public class DiscountThresholdAmount {
		public String discountThresholdAmountA;
		public String discountThresholdAmountB;
		public String discountThresholdAmountC;
	}

	/*  *@description:This is InsuranceDetails class in which insurance related fields are declared.*/
	public class InsuranceDetails {
        // old json Insurance Details
		/*public Double totalPayableByInsurance;
		public Integer totalPayableByMotorist;
		public Double payableByInsuranceRepair;
		public Double payableByInsuranceReplacement;
		public Double payableByInsuranceCalibration;
		public Double payableByInsuranceSundry;
		public Double payableByMotoristRepair;
		public Double payableByMotoristReplacement;
		public Double payableByMotoristCalibration;
		public Double payableByMotoristSundry; */
        
        // new json Insurance Details
        public Double totalPayableByInsurance;
		public Integer totalPayableByMotorist;
		public Integer totalPayableBytrade;
		public Integer totalTaxPayablebyMotorist;
		public Integer totalTaxPayablebyInsurance;
		public Integer totalTaxPayablebyTrade;
		public Integer payableByInsuranceRepair;
		public Double payableByInsuranceReplacement;
		public Integer payableByInsuranceCalibration;
		public Integer payableByInsuranceSundry;
		public Integer payableByMotoristRepair;
		public Integer payableByMotoristReplacement;
		public Integer payableByMotoristCalibration;
		public Integer payableByMotoristSundry;
		public Integer payableBytradeRepair;
		public Double payableBytradeReplacement;
		public Integer payableByTradeCalibration;
		public Integer payableByTradeSundry;
	}
    
	
/*  *@description:This is Results class in which bomID and Partnumber field are decleard.*/
    	public class Results {
		public Integer bomId;
		public String partNumber;
	}

/*  *@description:This is VehicleDamage class in which vehicle field are decleard.*/
    public class VehicleDamage {
		public String transactionId;
		public String status;
		public integer vehicleId;
        public Integer vehicleHoleId;
	}


/*  *@description:This is Question class in which question field are decleard.*/
	public class Question {
		public String questionTypeName;
		public String feature;
		public String question; 
	}

/*  *@description:This is Schematics class.*/
    public class Schematics {
		public Integer vehicleHoleId;
		public String vehicleHoleTypeCode;
		public String display;
	}

/*  *@description:This is Wrapper class.*/
	public class OuterWrapper {
		public string row;
		public SchemeticWrapper schemeticWrap;
	}

/*  *@description:This is Wrapper class.*/
	public class SchemeticWrapper {
		public string vehicleHoleId ;
		public string vehicleHoleTypeCode;
		public string display;
		public string staticResource;
		public string row;
	}

	// public class VehicleDamage {
    //     public String transactionId;
    //     public String status;
    //     public Integer vehicleId;
    // }

	/*  *@description:This method is used to parse the JSON.*/
    public static BLN_ProductParser parseGPS(String jsonGPS) {
        
		return (BLN_ProductParser) System.JSON.deserialize(jsonGPS, BLN_ProductParser.class);
	}
  /*  public static list<BLN_ProductParser> parseProduct(String jsonPro){
        		return (List<BLN_ProductParser>) System.JSON.deserialize(jsonPro, list<BLN_ProductParser>.class);
    } */

}