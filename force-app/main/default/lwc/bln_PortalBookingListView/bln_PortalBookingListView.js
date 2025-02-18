// import { LightningElement, wire,api,track } from 'lwc';
// import { getListUi } from 'lightning/uiListApi';
//  import CASE_OBJECT from '@salesforce/schema/Case';
// import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';

// const columns = [
//     { label: 'Booking Number', fieldName: 'CaseNumber' },
//     { label: 'AppointmentDate', fieldName: 'BLN_AppointmentDate__c'},
  
// ];
// export default class MyBookingsListView extends LightningElement {
//     @api tablevalue;
//      tabledata;
//     columns = columns;
//     @wire(getListUi, {
//         objectApiName: 'Case',
//         listViewApiName: 'My_Bookings'
        
//     })
//     listView;

    

//     get cases() {
//         this.tabledata=[];
//         console.log(this.listView.data.records.records);
//         this.tablevalue=this.listView.data.records.records;
//         this.tablevalue.map(item=>{
//             this.tabledata.push(
//             {
//                 CaseNumber: item.fields.CaseNumber.value,
//                 BLN_AppointmentDate__c: item.fields.BLN_AppointmentDate__c.value,
//                 Id:item.fields.Id.value
//             }
//             )
//         })
//         console.log(this.tabledata);
//         return this.tabledata;
//         //return this.listView.data.records.records;

        
    
//     }

//     connectedCallback() {
//         // Set viewport settings for mobile responsiveness
//         this.setMobileViewport();
//     }

//     setMobileViewport() {
//         const viewportMeta = document.createElement('meta');
//         viewportMeta.name = 'viewport';
//         viewportMeta.content = 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no';

//         // Add the viewport meta tag to the document head
//         document.head.appendChild(viewportMeta);
//     }
// }

import { LightningElement, wire, api, track } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import { NavigationMixin } from 'lightning/navigation';
import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
import Id from '@salesforce/schema/Case.Id';
import id from '@salesforce/user/Id';

const columns = [
    { label: 'Booking Number', fieldName: 'CaseNumber', type: 'button', typeAttributes: { label: { fieldName: 'BookingNumberLabel' }, name:'urlredirect', variant:'base'}},
    { label: 'Appointment Date', fieldName: 'BLN_AppointmentDate__c' , type: 'date'},
];

export default class MyBookingsListView extends NavigationMixin(LightningElement) {
    @api tablevalue;
    @api recordId;
    tabledata;
    columns = columns;

    @wire(getListUi, {
        objectApiName: 'Case',
        listViewApiName: 'My_Bookings'
    })
    listView;

    get cases() {
        this.tabledata = [];
        this.tablevalue = this.listView.data.records.records;

        this.tablevalue.forEach(item => {
            this.tabledata.push({
                CaseNumber: item.fields.CaseNumber.value,
                BookingNumberLabel: item.fields.CaseNumber.value,
                BLN_AppointmentDate__c: item.fields.BLN_AppointmentDate__c.value,
                Id: item.fields.Id.value
            });
        });

        return this.tabledata;
    }

    // handleBookingNumberClick(event) {
    //     event.preventDefault();
    //     const recordId = event.target.dataset.id;
    //     console.log(id );
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__recordPage',
    //         attributes: {
    //             recordId:id,
    //             actionName: 'view',
    //         },
    //     });
        
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: Id,
        //         actionName: 'view',
        //     },
        // }).then((url) => {
        //     window.open(url, '_self')
        // });
    //}

    handleRowAction(event) {
       // event.preventDefault();
        const actionName = event.detail.action.Name;
        const row = event.detail.row;
        console.log('record id is',row.Id);//this.listView.data.records.records
        //const recordName = event.target.dataset.name; // Assuming you have the record name available
    
        // this[NavigationMixin.Navigate]({
        //     type: 'comm__namedPage',
        //     attributes: {
        //         recordId: '5007Y00000QrZSsQAN',
        //         objectApiName: 'Case',
        //         actionName: 'view'
        //     }
        // });
       // navigateToURL() {
        
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