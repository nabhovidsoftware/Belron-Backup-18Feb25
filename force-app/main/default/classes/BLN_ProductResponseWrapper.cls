/*ClassName : BLN_ProductResponseWrapper
Description : Wrapper class for payload received in BLN_ProductAvailability
@Story : FOUK-3114
CreatedDate: 22/02/2024
CreatedBy : PwC-India
****************************************/
public class BLN_ProductResponseWrapper {    
    public class ResponseErrors {
        public String status;
        public String title;
        public String detail;
    }
  
    /* @description ResponseTaxTotals*/
    public class ResponseTaxTotals {
        public Double totalTaxRepair;
        public Double totalTaxReplacement;
        public Double totalTaxCalibration;
        public Double totalTaxSundries;
    }

    /* @description ResponseLineItems*/
    public class ResponseLineItems {
        public Integer lineItemId;
        public Integer parentLineItemId;
        public String bundleName;
        public String partNumber;
        public String belronPartNumber;
        public String partDescription;
        public Integer quantity;
        public Double baseListPrice;
        public Double netPrice;
        public Double taxRate;
        public Double totalTax;
        public Double netPriceIncludingTax;
        public Boolean selectProduct;
        public Boolean bomMandatory;
        public Boolean partOfBundle;
        public String bundleHierarchy;
        public Double nonBundlePrice;
        public String parentBOMId;
        public Boolean leadingProductIndicator;
        public Double totalPayableByInsurance;
        public Double totalTaxPayableByInsurance;
        public Double totalIncludingTaxPayableByInsurance;
        public Double totalPayableByMotorist;
        public Double totalTaxPayableByMotorist;
        public Double totalIncludingTaxPayableByMotorist;
        public Double payableByTradeTotalTax;
        public Double totalPayableByTrade;
        public Double totalPayableByTradeIncludingTax;
        public String payableByTrade;
        public String poaStatus;
        public Boolean priceFound;
        public String discount; 
        public String payableBy; 
        public String vATPayableBy; 
        public List<ResponseAvailabilityDetails> availabilityDetails;
        public String taxCode;       
    }

    
    /* @description ResponseProduct*/
    public class ResponseProduct {
        public String status;
        public List<ResponseErrors> errors;
        public List<ResponseQuotes> quotes;
    }

    /* @description ResponseMotoristTotals*/
    public class ResponseMotoristTotals {
        public Double motoristLimit;
        public Double payableByMotoristRepair;
        public Double payableByMotoristReplacement;
        public Double payableByMotoristCalibration;
        public Double payableByMotoristSundry;
        public Double totalTaxPayableByMotorist;
        public Double totalPayableByMotorist;
        public Double totalIncludingTaxPayableByMotorist;
    }

    /* @description ResponseTradeCompanyTotals*/
    public class ResponseTradeCompanyTotals {
        public Double payableByTradeRepair;
        public Double totalPayableByTrade;
        public Double totalPayableByTradeIncludingTax;
        public Double payableByTradeSundry;
        public Double payableByTradeReplacement;
        public Double payableByTradeCalibration;
        public Double payableByTradeTotalTax;
    }

    /* @description ResponseInsuranceTotals*/
    public class ResponseInsuranceTotals {
        public Double payableByInsuranceRepair;
        public Double payableByInsuranceReplacement;
        public Double payableByInsuranceCalibration;
        public Double payableByInsuranceSundry;
        public Double totalPayableByInsurance;
        public Double totalTaxPayableByInsurance;
        public Double totalIncludingTaxPayableByInsurance;
    }

    /* @description ResponseAvailabilityDetails*/
    public class ResponseAvailabilityDetails {
        @AuraEnabled
        public String stockLocationId;
        @AuraEnabled
        public String availableFromDate;
        @AuraEnabled 
        public Boolean isOutOfStock;
        
        public ResponseAvailabilityDetails(){
            this.stockLocationId = '';
            this.availableFromDate = '';
            this.isOutOfStock = false;
        }
    }

    /* @description ResponseQuotes*/
    public class ResponseQuotes {
        public String quoteId;
        public String locationId;
        public String appliedExcessType;
        public ResponseQuoteTotals quoteTotals;
        public ResponseInsuranceTotals insuranceTotals;
        public ResponseMotoristTotals motoristTotals;
        public ResponseTaxTotals taxTotals;
        public ResponseTradeCompanyTotals tradeCompanyTotals;
        public Decimal discountThresholdA;
        public Decimal discountThresholdB;
        public Decimal discountThresholdC;
        public String priceExpirationDate;
        public List<ResponseLineItems> lineItems;        
    }


    /* @description ResponseQuoteTotals*/
    public class ResponseQuoteTotals {
        public Double totalPrice;
        public Double totalTax;
        public Double totalRepair;
        public Double totalReplacement;
        public Double totalCalibration;
        public Double totalSundries;
        public Double totalIncludingTax;
        public Double totalPriceOriginal;
    }

    /* @description DiscountBandWrraper*/    
    public class DiscountBandWrapper{
        public Decimal discountThresholdA;
        public Decimal discountThresholdB;
        public Decimal discountThresholdC;
    }

    /* @description DisplayProductsWrapper*/    
    private class DisplayProductsWrapper {
        public Integer quantity;
        public String productName;
        private Decimal netPriceIncludingTax;
        private String bundleName;
        private Decimal discount;
        private String locationName;
        private String earlistAvailabilityDate;
        private String weatherGaurd;
        private Decimal totaltax;
        private Decimal totalPrice;
    }
}