trigger LAD_Cart_Page_ErrorTrigger on LAD_Cart_Page_Errors__e (after insert) {
                       CartValidationOutput temp = new CartValidationOutput();
                     temp.message='This cannot be removed from your cart, please contact us for assistance.';
                     temp.CartId = trigger.new[0].LAD_Cart_ID__c;
                     temp.Name = trigger.new[0].LAD_Cart_ID__c;
                     temp.RelatedEntityId =trigger.new[0].LAD_Cart_Item_ID__c;
                     temp.Type = 'Pricing';
                     temp.Level = 'Error';
                     insert temp;   
}