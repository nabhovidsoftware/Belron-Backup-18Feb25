import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createCaseRecord from '@salesforce/apex/BLN_ComplaintRaisecontroller.createCaseRecord';
import isVRNRegistered from '@salesforce/apex/BLN_ComplaintRaisecontroller.isVRNRegistered';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

export default class BLN_ComplaintRaise extends NavigationMixin(LightningElement) {
    contactName;
    email;
    phone;
    vrn;
    firstName;
    lastName;
    description;
    fileData = {};
    isLoading = false; // Initialize isLoading property

    // Wire service to fetch current user's information
    @wire(getRecord, { recordId: USER_ID, fields: ['User.Name', 'User.Email', 'User.Phone'] })
    wiredUser({ error, data }) {
        if (data) {
            this.contactName = data.fields.Name.value;
            this.email = data.fields.Email.value;
            this.phone = data.fields.Phone.value;
        } else if (error) {
            console.error('Error fetching user information:', error);
        }
    }

    // Handle change event for input fields
    handleChange(event) {
        const fieldName = event.target.dataset.fieldname;
        const value = event.target.value;
        this[fieldName] = value;
    }

    // Handle file upload event
    handleFileUpload(event) {
        const fileRecord = event.target.files[0];
        let reader = new FileReader();

        reader.onload = () => {
            let base64String = reader.result.split(',')[1];
            this.fileData = {
                fileName: fileRecord.name,
                base64Data: base64String
            };
        };
        reader.readAsDataURL(fileRecord);
    }

    // Handle form submission
    handleSubmit() {
        if (!this.vrn || !this.description) {
            this.showToast('Error', 'Please fill in all required fields.', 'error');
            return;
        }

        this.isLoading = true; // Activate spinner before submitting

        isVRNRegistered({ vrn: this.vrn })
            .then(vehicleId => {
                if (vehicleId) {
                    const caseData = {
                        BLN_Vehicle__c: vehicleId,
                        Bln_CustomerFirstname__c: this.firstName,
                        Bln_CustomerLastName__c: this.lastName,
                        Description: this.description
                    };

                    // Determine if file attachment is provided
                    if (this.fileData && this.fileData.base64Data && this.fileData.fileName) {
                        // Submit case with file attachment
                        this.createCaseWithAttachment(caseData, this.fileData);
                    } else {
                        // Submit case without file attachment
                        this.createCaseWithoutAttachment(caseData);
                    }
                } else {
                    throw new Error('Vehicle with this VRN does not exist.');
                }
            })
            .catch(error => {
                console.error('Error checking VRN registration:', error);
                this.showToast('Error', error.message, 'error');
                this.isLoading = false; // Deactivate spinner on error
            });
    }

    // Helper method to create case record with file attachment
    createCaseWithAttachment(caseData, fileData) {
        createCaseRecord({ caseData: caseData, base64Data: fileData.base64Data, fileName: fileData.fileName })
            .then(result => {
                // console.log('Case created or updated:', result);
                
                const caseNumber = result.CaseNumber; // Extract the case number from the result
                const successMessage = `Complaint has been submitted  ${caseNumber}`; // Construct success message with case number
                this.showToast('Success', successMessage, 'success');
                this.navigateToRecordPage(result.Id);
                this.isLoading = false; // Deactivate spinner after processing
            })
            .catch(error => {
                console.error('Error creating or updating case:', error);
                this.showToast('Error', 'Error creating or updating case', 'error');
                this.isLoading = false; // Deactivate spinner on error
            });
    }

    // Helper method to create case record without file attachment
    createCaseWithoutAttachment(caseData) {
        createCaseRecord({ caseData: caseData, base64Data: null, fileName: null })
            .then(result => {
                // console.log('result: ' + JSON.stringify(result));
                // console.log('Case created or updated without file:', result);
                const caseNumber = result.CaseNumber; // Extract the case number from the result
                
                const successMessage = `Complaint has been submitted  ${caseNumber}`; // Construct success message with case number
                console.log('Success message:', successMessage);
                this.showToast('Success', successMessage, 'success');
                this.navigateToRecordPage(result.Id);
                this.isLoading = false; // Deactivate spinner after processing
            })
            .catch(error => {
                console.error('Error creating or updating case:', error);
                this.showToast('Error', 'Error creating or updating case', 'error');
                this.isLoading = false; // Deactivate spinner on error
            });
    }

    // Helper method to navigate to the created Case record page
    navigateToRecordPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    // Helper method to show toast message
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}