/** @description :  This component is used to show a list of Return Orders.
*   @Story :        
*   @author:        (manoj.varma.ummadisingu@pwc.com(IN))
*   @CreatedDate:   20-09-2024
*/

import { LightningElement } from 'lwc';
import getReturnOrders from '@salesforce/apex/LAD_ReturnOrderHandler.getReturnOrders';
import getAccId from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import { NavigationMixin } from 'lightning/navigation';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import Id from '@salesforce/user/Id';



export default class LAD_ReturnOrderList extends NavigationMixin(LightningElement) {
    accountId;
    returns = [];
    columns = [
        { label: 'Return Order Number', fieldName: 'Name', type: 'text' },
        { label: 'Account', fieldName: 'AccountName', type: 'text' },
        {
            label: 'Action', type: 'button', typeAttributes: {
                variant: 'brand',
                label: 'Detail',
                //  iconPosition: 'center'
            },
            //cellAttributes: { alignment: 'center' }, //UnComment if Detail button is required to be centered
        }
    ];


    connectedCallback() {
        getAccId({ userid: Id })
            .then(result => {
                this.accountId = result;
                console.log("account id=" + result);
                this.handleFetchReturn();
            })
            .catch(error => {
                console.log(error);
            })
    }

    handleFetchReturn() {
        let variable = effectiveAccount.accountId !== null && effectiveAccount.accountId !== undefined ? effectiveAccount.accountId : this.accountId;
        getReturnOrders({ effectiveAccountId: variable })
            .then(result => {
                this.returns = result;
            })
            .catch(error => {
                console.error('ERROR IN FETCHING RETURN ORDERS' + error);
            })
    }


    handleClick(event) {
        let returnid = event.detail.row.Id;
        console.log('Return Order Id: ' + returnid);
        const pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: returnid,
                objectApiName: 'LAD_Return__c',
                actionName: 'view'
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