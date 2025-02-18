import { LightningElement, wire, track, api } from 'lwc';
import getRelatedProductRequired from '@salesforce/apex/BLN_ProductRequiredController.getRelatedProductRequired';
import createProdTransfer from '@salesforce/apex/BLN_ProductRequiredController.createProdTransfer';
import updateProdReq from '@salesforce/apex/BLN_ProductRequiredController.updateProdReq';
import updateSA from '@salesforce/apex/BLN_ProductRequiredController.updateSA';
import updateSAToCompleted from '@salesforce/apex/BLN_ProductRequiredController.updateSAToCompleted';
import uploadFile from '@salesforce/apex/BLN_ProductRequiredController.uploadFile';
import updateProdReq1 from '@salesforce/apex/BLN_ProductRequiredController.updateProdReq1';


export default class ProductRequiredComponent extends LightningElement {
    @track columns = [
        { label: 'Appointment Number', fieldName: 'appointmentNumber' },
        { label: 'Product Required Number', fieldName: 'productRequiredNumber', type: 'url', typeAttributes: { label: { fieldName: 'productRequiredNumber' }, target: '_blank' } },
        { label: 'Product Name', fieldName: 'productName',type: 'text'},
        { label: 'Product Code', fieldName: 'productCode',type: 'text' }
        //{ label: 'Is WMS Tracked', fieldName: 'IsWMSTracked', type: 'boolean', editable: true } // Added checkbox column
    ];
    @track error;
    @track data;
    @track selectedRows = [];
    @track showModal = false;
    @track showModalVerifyProduct = false;
    @track showModalProdTransfer = false;
    @track showSpinner = false;
    @track showModalAdditionalCheckouPart = false;
    @track showIssueWithPartModal = false;
    @track failureReasonReq;
    @track customFileName;
    @track showValidationPopup = false;
    @track showMainModal = true;
    selectedProdReqId;
    serviceAppId;
    serviceAppWorkOrderNumber;
    notesVal;
    failReasonVal;
    fileData;
    fileUrl;
    @track showImg;
    @track imageUrl;
    workOrderNum;
    prodTime;
    saNum;

    connectedCallback(){
        this.getRelatedProductRequiredList();
    }

    //@wire(getRelatedProductRequired)
    getRelatedProductRequiredList(){
        getRelatedProductRequired()
            .then((data) => {
            console.log('this data', data)
            const transformedData = data.map(item => ({
                serviceAppointmentId: item.serviceAppointmentId,
                prodId: item.prodId,
                prodReqId: item.prodReqId,
                quantityReq: item.quantityReq,
                appointmentNumber: item.appointmentNumber,
                productRequiredNumber: item.productRequiredNumber,
                IsWMSTracked: item.IsWMSTracked,
                serviceAppointmentStatus: item.serviceAppointmentStatus,
                prodReqNotes: item.prodReqNotes,
                prodReqFailureReason: item.prodReqFailureReason,
                workOrderNumber: item.workOrderNumber,
                productTime: item.productTime,
                servAppWorkOrderNumber: item.servAppWorkOrderNumber,
                productName: item.productName,
                productCode: item.productCode
            }));
            this.data = transformedData;
            console.log('transformedData', this.data);
            })
            .catch((error) => {
                this.error = error;
                console.error('Error:', error);
            })
    }
    // renderedCallback(){
    //     console.log('render');
        
    // }
    // wiredProductRequired({ error, data }) {
    //     if (data) {
    //         console.log('this data', data)
    //         const transformedData = data.map(item => ({
    //             serviceAppointmentId: item.serviceAppointmentId,
    //             prodId: item.prodId,
    //             prodReqId: item.prodReqId,
    //             quantityReq: item.quantityReq,
    //             appointmentNumber: item.appointmentNumber,
    //             productRequiredNumber: item.productRequiredNumber,
    //             IsWMSTracked: item.IsWMSTracked,
    //             serviceAppointmentStatus: item.serviceAppointmentStatus,
    //             prodReqNotes: item.prodReqNotes,
    //             prodReqFailureReason: item.prodReqFailureReason,
    //             workOrderNumber: item.workOrderNumber,
    //             productTime: item.productTime,
    //             servAppWorkOrderNumber: item.servAppWorkOrderNumber,
    //             productName: item.productName,
    //             productCode: item.productCode
    //         }));
    //         this.data = transformedData;
    //         console.log('transformedData', this.data);
    //     } else if (error) {
    //         this.error = error;
    //         console.error('Error:', error);
    //     }
    // }
    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        console.log('this.selectedRows', event.detail.selectedRows);
        this.serviceAppId = this.selectedRows[0].serviceAppointmentId
        this.selectedProdReqId = this.selectedRows[0].prodReqId;
        this.failReasonVal = this.selectedRows[0].prodReqFailureReason;
        this.notesVal = this.selectedRows[0].prodReqNotes;
        this.workOrderNum =  this.selectedRows[0].workOrderNumber;
        this.prodTime =  this.selectedRows[0].productTime;
        this.saNum = this.selectedRows[0].appointmentNumber;
        this.serviceAppWorkOrderNumber = this.selectedRows[0].servAppWorkOrderNumber;
        console.log('this.selectedRows', event.detail.selectedRows);
    }
    handleClick() {
        this.showMainModal = false;
        if (this.selectedRows.length > 0) {
            console.log('Continue button clicked');
            // Check if BLN_IsWMSTracked__c is unchecked for any selected row
            const hasUncheckedWMS = this.selectedRows.some(row => !row.IsWMSTracked);
            if (hasUncheckedWMS) {
                // Display modal box 
                console.log('Show Modal for PART OK?')
                this.showModal = true;
            } else {
                this.showModalVerifyProduct = true;
                // Continue with your existing logic or add additional actions
                console.log('Continue clicked with all WMS checked.');
                // If isWMSTracked is checked, open the new popup
                const isWMSTrackedChecked = this.selectedRows.every(row => row.IsWMSTracked);
                console.log('isWMSTrackedChecked', isWMSTrackedChecked);
                if (isWMSTrackedChecked) {
                    console.log('Inside if isWMSTrackedChecked', isWMSTrackedChecked);
                    // Display modal for Correct Part and Incorrect Part
                    //this.showCorrectIncorrectModal = true;
                }
            }
        } else {
            console.log('Please select at least one row.');
        }
    }

    closeshowMainModal(){
        this.showMainModal = false;
    }

    handleVerifyProduct() {
        this.showModalVerifyProduct = false;
        this.showModal = true;
        console.log('Inside Verify Product');
    }

    handleCorrectPart() {
        // Redirect to the Part OK modal box
        this.showCorrectIncorrectModal = false;
        this.showModal = false;
    }
    handleIncorrectPart() {
        console.log('Showing dialog for Incorrect Part');
    }

    handleModalNo() {
        updateSA({serviceAppId: this.serviceAppId})
        .catch(error => {
            console.error('Error in updating service appointment records:', error);
        });
        this.showModal = false;
        this.showCorrectIncorrectModal = false;
        this.showPartOKModal = false;
        this.showIssueWithPartModal = true;
        this.failureReasonReq = true;
    }

    handleValidationModal() {
        this.showValidationPopup = false;
        this.showIssueWithPartModal = true;
    }

    onChangeFailReason(event) {
        this.failReasonVal = event.detail.value;
        console.log('this.failReasonVal=>', this.failReasonVal);
    }
    onChangeNotes(event) {
        this.notesVal = event.detail.value;
    }

    handleContinueClick() {
        if (this.failureReasonReq == true && (this.failReasonVal == '' || this.failReasonVal == undefined)) {
            console.log('this.failureReasonReq', this.failureReasonReq);
            this.showIssueWithPartModal = false;
            this.showValidationPopup = true;
        } else {
            updateProdReq({ prodReqId: this.selectedProdReqId, prodReqStatus: 'Failed', prodReqFailReason: this.failReasonVal, prodReqNotes: this.notesVal })
                .catch(error => {
                    console.error('Error creating ProductTransfer records:', error);
                });
            updateProdReq1({ prodReqId: this.selectedProdReqId})
                .catch(error => {
                    console.error('Error creating ProductTransfer records:', error);
                });
            this.showIssueWithPartModal = false;
        }
        if (this.fileData) {
            const { base64, filename, recordId } = this.fileData
            uploadFile({ base64, filename, recordId }).then(result => {
                this.fileData = null
                let title = `${filename} uploaded successfully!!`

                alert(title);
            })
        }
        this.getRelatedProductRequiredList();
        this.showMainModal =true;
    }

    closeIssueWithPartModal() {
        this.showMainModal = true;
        this.showIssueWithPartModal = false;
        this.showModal = false;
        this.showModalVerifyProduct = false;
        this.showModalProdTransfer = false;
        this.showModalAdditionalCheckouPart = false;
    }

    get acceptedFormats() {
        return ['.png', '.PNG', '.jpg', '.JPG'];
    }

    openfileUpload(event) {
        const file = event.target.files[0];
        let nameExt = file.name.split('.');
        let ext = nameExt[1];
        if(ext != 'jpg' || ext != 'png' || ext == 'PNG' || ext != 'JPG'){
            ext = 'jpg';
        }
        let imgName = this.workOrderNum+'-'+this.saNum+'-'+this.prodTime+'.'+ext;
        console.log('imgName',imgName);
        console.log('name=> '+ext);
        this.fileUrl = URL.createObjectURL(file);
        //file.name = 'Test';
        var reader = new FileReader()
        reader.onload = (event) => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': imgName,
                'base64': base64,
                'recordId': this.selectedProdReqId
            }
            console.log('abct', this.fileData);
            this.showImg = true;
            this.imageUrl = event.target.result;

        }
        reader.readAsDataURL(file)
    }

    handleModalYes() {
        // Handle Yes button click
        console.log('User clicked Yes');
        var prodIdMap = this.selectedRows[0];
        createProdTransfer({ prodId: prodIdMap.prodId, QuantReq: prodIdMap.quantityReq, prodReqId: prodIdMap.prodReqId })
            .catch(error => {
                console.error('Error creating ProductTransfer records:', error);
                // Handle error appropriately
            });
        updateSA({serviceAppId: this.serviceAppId})
        .catch(error => {
            console.error('Error in updating service appointment status:', error);
        });
        this.showModal = false;
        this.showCorrectIncorrectModal = false;
        this.showPartOKModal = false;
        this.showModalProdTransfer = true;
    }
    handleContinueModal(event) {
        this.showModalProdTransfer = false;
        this.showModalAdditionalCheckouPart = true;
        //this.handlePageReload();
    }
    handleModalYesAddCheck() {
        this.showModalAdditionalCheckouPart = false;
        this.handlePageReload();
    }
    handleModalNoAddCheck() {
        updateSAToCompleted({serviceAppId: this.serviceAppId})
        .catch(error => {
            console.error('Error Updating SA Status:', error);
        });
        this.showModalAdditionalCheckouPart = false;
        this.getRelatedProductRequiredList();
        this.showMainModal =true;
    }

    handlePageReload() {
        this.showSpinner = true;
        setTimeout(() => {
            // Reload the page
            window.location.reload();
        }, 500);
    }
}