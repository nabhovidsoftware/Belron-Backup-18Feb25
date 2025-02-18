import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPersonAccounts from '@salesforce/apex/BLN_InboundCustomerDetailsController.getPersonAccounts';
import firstName from '@salesforce/label/c.BLN_FirstName';
import lastName from '@salesforce/label/c.BLN_LastName';
import mobilePhone from '@salesforce/label/c.BLN_PersonalMobilePhone';
import homePhone from '@salesforce/label/c.BLN_HomeNumber';

const COLUMNS = [
    { label: firstName, type: 'button', typeAttributes: { label: { fieldName: 'FirstName' }, variant: 'base', name: 'view_details' } },
    { label: lastName, type: 'button', typeAttributes: { label: { fieldName: 'LastName' }, variant: 'base', name: 'view_details' } },
    { label: mobilePhone, fieldName: 'PersonMobilePhone' },
    { label: homePhone, fieldName: 'PersonHomePhone' },
];

export default class Bln_InboundCustomerDetails extends NavigationMixin(LightningElement) {
    @api ani; // This should be set by your flow
    columns = COLUMNS;
    @track records = [];
    

    @wire(getPersonAccounts, { mobilenumber: '$ani' })
    wiredPersonAccounts({ error, data }) {
        if (data) {
            console.log('Retrieved data:', data);
            this.records = data.map(record => ({
                ...record,
                FormattedFirstName: record.FirstName,
                FormattedLastName: record.LastName,
            }));
        } else if (error) {
            // Handle errors if any
            console.error('Error fetching Person Accounts:', error);
        } 
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'view_details') {
            this.openRecord(row.Id);
        }
    }

    openRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view',
            },
        });
    }
}