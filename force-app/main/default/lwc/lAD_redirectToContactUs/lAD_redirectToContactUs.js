import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import helpURL from '@salesforce/label/c.LAD_HelpURL';

export default class LAD_redirectToContactUs extends NavigationMixin(LightningElement) {


   @track pageURL;

   

   connectedCallback(){ 
   //window.location.href=helpURL;
    const invoicePage = {
        type: 'comm__namedPage',
        attributes: {
            name: 'contact_us__c',
        },
    };
    this[NavigationMixin.GenerateUrl](invoicePage)
        .then(url => {
            console.log('Generated URL:', url);
            this.pageURL = url;
            // Redirect to the generated URL
            window.open(url, "_self");
        })
        .catch(error => {
            console.error('Error generating URL:', error);
        });
   }

   


}