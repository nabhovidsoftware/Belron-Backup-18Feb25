/** @description :  This is component is used for displaying the contacts of the account associated to the external user.
*   @Story :        FOUK-9572, FOUK-9573, FOUK-9576
*   @author:        (ashwin.r.raja@pwc.com (IN))
*   @CreatedDate:   26-08-2024
*/

import { LightningElement, api, track } from 'lwc';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import getAccId  from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import getRelatedContacts from '@salesforce/apex/LAD_fetchContacts.getRelatedContacts';
import Id from '@salesforce/user/Id';
import Toast from 'lightning/toast';

export default class Lad_userManagement extends LightningElement {
    @api accountId;
    @track flowStarted=false;
    @track showModal=false;
    @track contactid = [];
    contacts = [];
    columns = [

        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Email(Username)', fieldName: 'Email', type: 'text' },
        { label: 'Phone Number', fieldName: 'Phone', type: 'Number' },
        { label: 'Role', fieldName: 'LAD_Role__c', type: 'text' },
        { label: 'Status', fieldName: 'LAD_Status__c', initialWidth: 100,type: 'text' },
        { label: 'Action', type: 'button', initialWidth: 200,typeAttributes: {
            variant: {fieldName : 'buttonVariant'},
            label:'Amend/Deactivate', 
            disabled: {fieldName: 'disableButton'},
            iconPosition: 'left'
        }
        }
    ];
    
    connectedCallback()
    {   
        getAccId({userid:Id})
        .then(result => {
            this.accountId=result;
            console.log("account id="+result);
            this.fetchDetails();
        })
        .catch(error=>{
            console.log(error);
        })
    }

    fetchDetails()
    {   let variable = effectiveAccount.accountId!=null & effectiveAccount.accountId!=undefined? effectiveAccount.accountId:this.accountId
        console.log("variable from usermanagement:"+variable);
        getRelatedContacts({accountId:variable}) 
        .then(result => {
            this.contacts = JSON.parse(JSON.stringify(result));
            console.log("here contacts:"+JSON.stringify(result));
            this.setDisabled();
        })
        .catch(error => {
            console.log(error);
            console.log("in error contacts");
        });
    }

    setDisabled(){
        console.log('inside set disabled')
        this.contacts.forEach((i) => {
            console.log('in the pending loop');
            if(i.LAD_Status__c=='Pending'){
            i.disableButton = true;
            i.buttonVariant = 'brand';
            console.log('disable value:'+JSON.stringify(i.disableButton));
            }
        });
    }
    
    handleClick(event){
        this.contactid = [
            {
                name: 'recordId',
                type: 'String',
                value: event.detail.row.Id
            }
        ];
        this.flowStarted=true;
        this.showModal = true;
        console.log('Contact id value:'+event.detail.row.Id);
        console.log('Flow started');
        console.log("inside amend/deactivate");
    }

    handleCloseModal(){
        this.showModal = false;
    }

    handleStatuschange(event){
        const { status } = event.detail;
        console.log('Flow status changed:', status);
        if (status === 'FINISHED' || status === 'FINISHED_SCREEN') {
            setTimeout(()=>{window.location.reload();},3000);
            this.flowStarted = false;
            this.showModal = false;
            Toast.show({
                label: 'Success',
                message:'Changes submitted successfully.',
                variant: 'success',
                mode: 'sticky'
            }); 
            this.dispatchEvent();         
        }
        else if(status === 'ERROR' || status === 'ERROR_SCREEN')
        {
            setTimeout(()=>{window.location.reload();},3000);
        }
    }
}