import { LightningElement, api, wire } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import BLN_LOGOHEAD from '@salesforce/resourceUrl/BLN_LOGOREDYELLOW';
import { getRecord } from 'lightning/uiRecordApi';
import USER_NAME_FIELD from '@salesforce/schema/User.Name';
import USER_EMAIL_FIELD from '@salesforce/schema/User.Email';
import USER_PHONE_FIELD from '@salesforce/schema/User.Phone';
import USER_USERNAME_FIELD from '@salesforce/schema/User.Username'; // Correct field reference
//import fileUploadStyle from '@salesforce/resourceUrl/BLN_communitycss';

export default class Changecardbuttons extends LightningElement {
    @api headUrl;
    userId = USER_ID;

    // User data properties
    name;
    email;
    phone;
    username;

    @wire(getRecord, { recordId: '$userId', fields: [USER_NAME_FIELD, USER_EMAIL_FIELD, USER_PHONE_FIELD, USER_USERNAME_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            console.log('User Data:', data);
            this.name = data.fields.Name.value;
            this.email = data.fields.Email.value;
            this.phone = data.fields.Phone.value;
            this.username = data.fields.Username.value; // Correct property reference
        } else if (error) {
            console.error('Error fetching user data:', error);
        }
    }

    connectedCallback() {
        this.headUrl = BLN_LOGOHEAD;
        /*Promise.all([
            loadStyle(this, fileUploadStyle)
        ]).then(() => {
            // console.log('Upload success');
        }).catch((error) => {
            console.error('Failed to load styles:', error);
        });*/
    }
}