import { LightningElement, track, wire, api } from 'lwc';
import updateCase from '@salesforce/apex/BLN_CustomButtonCommunityController.updateCase';

export default class Bln_CancelServiceAppoinmentForm extends LightningElement {
    @api CaseRecordId;
    @api ServiceAppointmentId;
    @api caseId;
    @api serviceAppointment;
    @track isShowModal = true;
    @track isUpdating = false;
    @track showCard = false;
    @track currentUrl = '';
    @track caseId;
    @track sid;
    @track selectedReason = 'None'; 
    @track showError = false;

    connectedCallback() {
        // Get the current URL when the component is connected
        this.currentUrl = window.location.href;
        this.extractIdsFromUrl();
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `
    .overrideslds .fix-slds-input_faux {
       
        line-height: max(1.875rem, calc(1.2em - 2px));
        background: #FAFAFA !important;
        color: var(--theme-color-text-matt, #8B9196);
border-bottom: 2px solid black;
        font-family: var(--theme-typography-font-family-body, Roboto);
        font-size: var(--theme-typography-font-size-m, 16px);
        font-style: normal;
        font-weight: var(--theme-typography-font-weight-regular, 400);
        line-height: 150%; /* 24px */
        background-color: #FAFAFA !important;
            height: 56px !important;
    padding-top: 15px !important;
       
    }`;
        try {
         this.template.querySelector('.overrideslds').appendChild(style);
        }
        catch (err) {
        }
    }

    extractIdsFromUrl() {
        // Create a URL object from the current URL
        let urlObject = new URL(this.currentUrl);

        // Extract case ID from the path using regex
        let caseIdRegex = /\/case\/([^\/?]+)/i;
        let caseIdMatch = urlObject.pathname.match(caseIdRegex);
        if (caseIdMatch) {
            this.caseId = caseIdMatch[1];
        }

        // Extract SID from query parameters using URLSearchParams
        let searchParams = new URLSearchParams(urlObject.search);
        if (searchParams.has('sid')) {
            this.sid = searchParams.get('sid');
            
        }
    }

    options = [
        { label: "Select Option", value: 'None' },
        { label: "My appointment time isn't suitable", value: 'time' },
        { label: "My appointment location isn't suitable", value: 'location' },
        { label: "My appointment is too expensive", value: 'expense' }
    ];

    handleChange(event) {
        this.selectedReason = event.detail.value;
        this.showError = false;
    }

    handleSubmit() {
        if(this.selectedReason === 'None'){
            this.showError = true;
        }
        else{
            this.isUpdating = true;
            console.log('this.selectedReason', this.selectedReason) ;
        updateCase({ reason: this.selectedReason, caseId : this.caseId, serviceAppointment: this.sid})
            .then(result => {
                // Handle success if needed
                console.log('Case updated successfully', this.sid, this.caseId) ;
                this.isUpdating = false;
                this.isShowModal = false;
                this.showCard = true;

            })
            .catch(error => {
                // Handle error if needed
                console.error('Error:', error);
            });
    }
        
    }
    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
        this.showCard = false;
       
    }
    hideModalBoxOk(){
        this.isShowModal = false;
        this.showCard = false;
        window.location.reload();

    }
    handleOkClick() {
        this.showCard = false;
    }
}