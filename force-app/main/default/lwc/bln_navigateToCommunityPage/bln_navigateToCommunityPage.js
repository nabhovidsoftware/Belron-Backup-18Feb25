import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import insuranceLinkText from "@salesforce/label/c.BLN_InsuranceLinkText";

export default class NavigateToCommunityPage extends NavigationMixin(LightningElement) {
    @api caseId;
    insuranceLinkText = insuranceLinkText;
    navigateHandler(){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Insurance_Details__c'
                },
                state: {
                    'CaseId': this.caseId
                }
            });
        
      }
        
    }