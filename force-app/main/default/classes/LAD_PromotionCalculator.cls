/**
  * @description This sample is for the situations where Promotion Calculation needs to be extended or overridden via the
  * extension point for the Promotion Calculator. You are expected to refer this and write your own implementation.
  * This class must extend the CartExtension.PromotionsCartCalculator class to be processed.
  */
public without sharing class LAD_PromotionCalculator extends CartExtension.PromotionsCartCalculator {

	@testvisible private boolean istest=false;
    
    
    public virtual override   void calculate(CartExtension.CartCalculateCalculatorRequest request) {
        
       
       Map<string,CartExtension.CartItemPriceAdjustment> priceAdjustmentList= new map<string,CartExtension.CartItemPriceAdjustment>();

        Iterator<CartExtension.CartItem> ciIter = request.getCart().getCartItems().iterator();
        while(ciIter.hasNext()) {

            CartExtension.CartItem ci = ciIter.next();
            Iterator<CartExtension.CartItemPriceAdjustment> ciaIter = ci.getCartItemPriceAdjustments().iterator();
			
            integer counter=0;
            while(ciaIter.hasNext()) {
                CartExtension.CartItemPriceAdjustment cip=ciaIter.next();
				counter++;
                priceAdjustmentList.put(ci.getId()+'-'+counter,cip);
            }
           
        }

        
       
                    super.calculate(request);

        
           
       system.debug(41);


        Iterator<CartExtension.CartItem> ciNewIter = request.getCart().getCartItems().iterator();

        while(ciNewIter.hasNext()) {
            CartExtension.CartItem ci = ciNewIter.next();

            for(string i:priceAdjustmentList.keyset()){
                if(i.contains(ci.getId())){

                            CartExtension.CartItemPriceAdjustment existingPromotion =priceAdjustmentList.get(i);
                            

                            CartItemPriceAdjustment cia = new CartItemPriceAdjustment();
                            cia.AdjustmentAmountScope=string.valueof(existingPromotion.getAdjustmentAmountScope());
                            cia.AdjustmentSource=string.valueof(existingPromotion.getAdjustmentSource());
                            cia.AdjustmentTargetType=string.valueof(existingPromotion.getAdjustmentTargetType());
                           cia.AdjustmentType=string.valueof(existingPromotion.getAdjustmentTargetType());
                           cia.AdjustmentValue=existingPromotion.getAdjustmentValue();

                            cia.AdjustmentBasisReferenceId=existingPromotion.getAdjustmentBasisReferenceId();
                            cia.TotalAmount=existingPromotion.getTotalAmount();
                            cia.PriceAdjustmentCauseId=existingPromotion.getPriceAdjustmentCauseId();
                            cia.Name=existingPromotion.getName();
                           cia.CartItemId=ci.getId();
                    system.debug('CIA>>>'+cia);


                        system.debug(ci.getCustomField('LAD_UnitPriceAdjustment__c'));
                    system.debug(ci.getQuantity());
						system.debug((Decimal)ci.getCustomField('LAD_UnitPriceAdjustment__c')*ci.getQuantity());
                    decimal price=(Decimal)ci.getCustomField('LAD_UnitPriceAdjustment__c')*ci.getQuantity();
                    system.debug(price);
                        CartExtension.CartItemPriceAdjustment ciaInstant = new
                        CartExtension.CartItemPriceAdjustment(cartextension.CartAdjustmentTargetTypeEnum.ITEM, // AdjustmentTargetType
                                                              existingPromotion.getTotalAmount(), // TotalAmount
                                                              cartextension.PriceAdjustmentSourceEnum.PROMOTION, // AdjustmentSource
                                                              cartextension.AdjustmentTypeEnum.ADJUSTMENT_AMOUNT, // AdjustmentType
                                                              price,
                                                             // existingPromotion.getAdjustmentValue(), // AdjustmentValue
                                                              existingPromotion.getPriceAdjustmentCauseId()); // PriceAdjustmentCauseId
                     
                                                              ciaInstant.setPriority(1);
                                                              ciaInstant.setAdjustmentAmountScope(cartextension.AdjustmentAmountScopeEnum.TOTAL);
                                                              ciaInstant.setDescription('PromotionCalculator');
                    										ciaInstant.setAdjustmentBasisReferenceId(existingPromotion.getAdjustmentBasisReferenceId());
                        ci.getCartItemPriceAdjustments().add(ciaInstant);

						ci.setTotalPromoAdjustmentAmount(price);
                		ci.setTotalAdjustmentAmount( price);
                		ci.setTotalPriceAfterAllAdjustments(ci.getTotalPrice() + price);



                }
            }


       
            
           
        }
  
        
    }
     
    
    
     
    
    
  
}