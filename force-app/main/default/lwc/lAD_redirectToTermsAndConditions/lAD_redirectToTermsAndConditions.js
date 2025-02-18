import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//import helpURL from '@salesforce/label/c.LAD_HelpURL';

export default class LAD_redirectToTermsAndConditions extends NavigationMixin(LightningElement) {


   @track pageURL;

   

   handleClick(){ 
   //window.location.href=helpURL;
    const invoicePage = {
        type: 'comm__namedPage',
        attributes: {
            name: 'Terms_of_business__c',
        },
    };
    this[NavigationMixin.GenerateUrl](invoicePage)
        .then(url => {
            console.log('Generated URL:', url);
            this.pageURL = url;
            console.log('url'+this.pageURL);
            // Redirect to the generated URL
            window.open(url, "_blank");
        })
        .catch(error => {
            console.error('Error generating URL:', error);
        });
   }

   


}