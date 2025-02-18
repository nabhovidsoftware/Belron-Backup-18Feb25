import { LightningElement ,api} from 'lwc';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import getAccId  from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import { NavigationMixin } from 'lightning/navigation';
import NotEligibleReporting from '@salesforce/apex/LAD_RedirectReporting.NotEligibleReporting';
import Id from '@salesforce/user/Id';
import Buyer from '@salesforce/customPermission/LAD_Laddaw_Buyer_Credit_Info';
import BuyerManager from '@salesforce/customPermission/LAD_Laddaw_Buyer_Manager_Credit_Info';
export default class Lad_redirectreporting extends NavigationMixin(LightningElement) {

    @api accountId;

  

    connectedCallback()
    {   
        if(!Buyer &&!BuyerManager){
         this.redirectToReport();   
        }else{
            
        getAccId({userid:Id})
        .then(result => {

            
            this.accountId=result;
            this.fetchDetails();
        })
        .catch(error=>{
            console.log(error);
        })
        }




    }

     fetchDetails()
     {
        let variable = effectiveAccount.accountId!=null & effectiveAccount.accountId!=undefined? effectiveAccount.accountId:this.accountId
        console.log(variable);

        NotEligibleReporting({recordId:variable})
        .then(result => {
            console.log('This is redirecting:'+result);

            if(result.LAD_Not_eligible_for_Reporting__c == 'Yes')
            { 
                console.log('This is redirecting2222:'+result);
                this.redirectToReport();
            }
            


        })
        .catch(error => {
            console.log('Error redirecting:'+JSON.stringify(error));
        })
        
        
     }


     redirectToReport()
     {

        const pageReference = {                
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'Error'
                            }
                        
                    };
         this[NavigationMixin.GenerateUrl](pageReference)
        .then(url => {
             console.log('Generated URL:', url);

                // Redirect to the generated URL
                window.open(url, "_self");
         })
         .catch(error => {
                console.error('Error generating URL:', error);
         });
     }


}