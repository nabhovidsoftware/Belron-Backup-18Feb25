import { LightningElement, track, api,wire } from 'lwc';
import fetchRecords from '@salesforce/apex/LAD_ReusableLookup.fetchAccount';
import LAD_AccountSwitcher from '@salesforce/customPermission/LAD_AccountSwitcher';
import { effectiveAccount, ManagedAccountsAdapter, loadEffectiveAccounts } from 'commerce/effectiveAccountApi';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/lad_pubsub';
import Toast from 'lightning/toast';

export default class Lad_switchAccountCustom extends LightningElement {
    @wire(CurrentPageReference) pageRef;

    @api userId;
    @api recordId;
    selectedInputType='AccountNumber';
    @track AccountListMaster;
    @track AccountListView;
    isSearchDisabled = true;
    buttonClicked = false;
    selectedAccount;
    accountName;
    get accountSwitcher() {
        console.log(20,LAD_AccountSwitcher);
        // return true;
         return LAD_AccountSwitcher;
    }

    get buttonDisabled(){
        let check=this.selectedAccount!=null && this.accountName!=null ?false:true;
        return check
    }

    get dataType() {
        return [
            { value: 'AccountNumber', label: 'Account Number' },
            { value: 'AccountName', label: 'Account Name' },

        ]
    }


    connectedCallback() {


        setTimeout(() => {
            this.fetchDetails();
        }, 1000);

       
    }

    fetchDetails(){

        console.log( this.userId,  this.recordId);
        fetchRecords({ userId: this.userId, recordId: this.recordId })
            .then(result => {
                this.AccountListMaster = result;
                this.AccountListMaster = this.AccountListMaster.map(i => {
                    i.iconName = 'utility:add';
                    return i;
                }

                )
                this.AccountListView = this.AccountListMaster;
                console.log(result);
            })
            .catch(error => {
                console.log(error);
            })
    }


    handleUpdateList(event) {
        this.AccountListView =[];
        let enteredString = event.target.value;
        console.log(enteredString + '--' + this.selectedInputType);

         this.AccountListMaster.map(i =>{
            if(this.selectedInputType == 'AccountNumber'){
                if(i.AccountNumber.includes(enteredString)){
                    this.AccountListView.push(i);
                }
            }else if(this.selectedInputType == 'AccountName'){
                if(i.AccountName.includes(enteredString)){
                    this.AccountListView.push(i);
                }
            }
        }            
       
        );
        console.log(this.AccountListView);
    }


    handlePicklistChange(event) {
        this.selectedInputType = event.target.value;
        this.isSearchDisabled = false;
    }
    handleswitchaccount() {
        this.buttonClicked = true;
    }
    handleclose() {
        this.buttonClicked = false;
    }

    handleAccountSwitch(event) {

        if(this.selectedAccount==event.target.accountid){
            this.selectedAccount=null;
            this.accountName =null;
            this.AccountListView = this.AccountListView.map(i => {
                if (i.IdStr === event.target.accountid) {
                    i.iconName = 'utility:add';

                    i.variant='base';

               

                    
                    }
                    return i;
                }
            

            )

        }else{
            this.selectedAccount = event.target.accountid;
            console.log(this.selectedAccount);
            this.AccountListView = this.AccountListView.map(i => {
                if (i.IdStr == this.selectedAccount) {
                    i.iconName = 'utility:check';
                    i.variant='brand';
                    this.accountName = i.AccountName;
                }else{
                    i.variant='base';
                    i.iconName = 'utility:add';
                }

                return i;
            }

            )
        }
        

           


    
       
    }

    handleClick() {
        console.log(this.selectedAccount, this.accountName);


        try {

            effectiveAccount.update(this.selectedAccount, this.accountName);

            Toast.show({
                label: 'Success',
                message: 'You have successfully switched account',
                mode: 'dismissible',
                variant: 'success'
            }, this);
            fireEvent(this.pageRef,'effectiveAccountName',this.accountName);


            setTimeout(() => {
               
                window.location.reload();
            }, 1000);

        } catch (e) {
            console.log(e, 40);
        }
    }

}