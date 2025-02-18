import { LightningElement, api, wire,track } from 'lwc';
import getDataFromApex from '@salesforce/apex/BLN_CustomButtonCommunityController.getDataFromApex';


export default class BLN_CustomButtonCommunity extends LightningElement {
    @track isButtonVisible = false; // Default to true
    @api ServiceAppointmentId;


    connectedCallback() {
        // Call the method to retrieve data from Apex controller
        this.getData();
    }


    getData() {
        getDataFromApex({ recordId: this.ServiceAppointmentId })
            .then(result => {
                if (result) {
                    // Handle result from Apex
                    const statusValue = result.Status;
                    const arrivalWindowStart = new Date(result.ArrivalWindowStartTime);
                    const currentDateTime = new Date();
                    const currentDateTime1 = new Date();
                    currentDateTime1.setDate(currentDateTime1.getDate() + 1);

                    if ((statusValue  !== 'Completed' || statusValue !== 'Canceled' ||  statusValue !== 'Failed Before Arrive' ||  statusValue !== 'Failed After Arrive') && (statusValue !== 'Dispatched')) {
                        if(currentDateTime < arrivalWindowStart){
                            console.log(currentDateTime,' ',arrivalWindowStart, 'currentDateTime < arrivalWindowStart After 1st If');                            
                            if(currentDateTime1.getDate() === arrivalWindowStart.getDate()){
                                console.log(currentDateTime1.getDate(),' ',arrivalWindowStart.getDate(), 'currentDateTime1 < arrivalWindowStart After 2st If');                               
                                if(currentDateTime1.getHours() >= 16){
                                    console.log(currentDateTime1.getHours(), 'currentDateTime1.getHours() After 3st If');
                                    this.isButtonVisible = false;
                                }
                                else{
                                    this.isButtonVisible = true;
                                }
                            }
                            else{
                                this.isButtonVisible = true;
                            }  
                        } 
                    } else {
                        this.isButtonVisible = false;
                    }
                }
            })
            .catch(error => {
                // Handle errors
                console.error('Error fetching data from Apex:', error);
            });
    }

    handleButtonClick() {
        console.log('Button clicked');
    }
 }