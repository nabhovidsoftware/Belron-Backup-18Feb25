/** @description :  This component is used to show a list of Quotes based on Permissions of the user.
*   @Story :        
*   @author:        (ashwin.r.raja@pwc.com (IN))
*   @CreatedDate:   27-08-2024
*/

import { LightningElement } from 'lwc';
import getQuotes from '@salesforce/apex/LAD_QuoteHandler.getQuotes';
import getAccId from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import { NavigationMixin } from 'lightning/navigation';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import Id from '@salesforce/user/Id';



export default class Lad_QuoteList extends NavigationMixin(LightningElement) {
    accountId;
    quotes = [];
    columns = [
        { label: 'Quote Number', fieldName: 'QuoteNumber', type: 'text' },
        { label: 'Account', fieldName: 'AccountName', type: 'text' },
        { label: 'Contact', fieldName: 'ContactName', type: 'text' },
        { label: 'Total Price', fieldName: 'TotalPrice', type: 'Number' },
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
                this.handleFetchQuote();
            })
            .catch(error => {
                console.log(error);
            })
    }

    handleFetchQuote() {
        let variable = effectiveAccount.accountId !== null && effectiveAccount.accountId !== undefined ? effectiveAccount.accountId : this.accountId;
        getQuotes({ effectiveAccountId: variable })
            .then(result => {
                this.quotes = result;
            })
            .catch(error => {
                console.error('ERROR IN FETCHING QUOTES' + error);
            })
    }


    handleClick(event) {
        let quoteid = event.detail.row.Id;
        console.log('Quote Id: ' + quoteid);
        const pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: quoteid,
                objectApiName: 'LAD_Quote__c',
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