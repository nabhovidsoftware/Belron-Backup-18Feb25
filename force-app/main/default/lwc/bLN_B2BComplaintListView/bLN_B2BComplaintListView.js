// bln_B2BComplaintListView.js
import { LightningElement, wire, api, track } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import { NavigationMixin } from 'lightning/navigation';
import CASE_OBJECT from '@salesforce/schema/Case';
import Id from '@salesforce/schema/Case.Id';

const columns = [
    { label: 'Case Number', fieldName: 'CaseNumber', type: 'button', 
      typeAttributes: { label: { fieldName: 'CaseNumber' }, name: 'urlredirect', variant: 'base' }
    },
    { label: 'Subject', fieldName: 'subject', type: 'text' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Date/Time Opened', fieldName: 'CreatedDate', type: 'date' },
    { label: 'Date/Time Closed', fieldName: 'ClosedDate', type: 'date' }
];
 
export default class BLN_B2BComplaintListView extends NavigationMixin(LightningElement) {
    @api tablevalue;
    @api recordId;
    @track tabledata;
    columns = columns;

    @wire(getListUi, { objectApiName: CASE_OBJECT, listViewApiName: 'Bln_Complaints' })
    listView;
 
    
    get cases() {
        this.tabledata = [];
        if (this.listView.data && this.listView.data.records) {
            this.listView.data.records.records.forEach(item => {
                this.tabledata.push({
                    CaseNumber: item.fields.CaseNumber.value,
                    subject: item.fields.Subject.value,
                    status: item.fields.Status.value,
                    CreatedDate: item.fields.CreatedDate.value,
                    ClosedDate: item.fields.ClosedDate.value,
                    Id: item.id
                });
            });
        }
        return this.tabledata;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }

    connectedCallback() {
        this.setMobileViewport();
    }

    setMobileViewport() {
        const viewportMeta = document.createElement('meta');
        viewportMeta.name = 'viewport';
        viewportMeta.content = 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no';
        document.head.appendChild(viewportMeta);
    }
}