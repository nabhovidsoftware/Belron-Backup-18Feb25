/** @description :  This component is used to show error toast on experience site as per Title and Body passed in Custom Labels.
*  @author:         (binayak.debnath@pwc.com (IN))
*  @story:          FOUK-8069; FOUK-8057
*/

import { LightningElement, api } from 'lwc';
import Toast from 'lightning/toast';
import fetchLabels from '@salesforce/apex/LAD_FetchCustomLabels.fetchLabels';

export default class Lad_ShowErrorToastFinal extends LightningElement {

    //Exposed properties in Community for passing Custom Label names
    @api errorTitle;
    @api errorBody;

    connectedCallback() {
        let labels = [];
        labels.push(this.errorTitle);
        labels.push(this.errorBody);
        this.getLabels(labels);

    }

    //Function handling apex call out to fetch content of custom labels
    getLabels(labels) {
        fetchLabels({ devNames: labels })
            .then(result => {
                this.showErrorToast(result);

            })
            .catch(error => {
                console.error('Error fetching response:', error);
            });
    }
    // Function to show error toast message
    showErrorToast(error) {
        console.log('INSIDE TOAST', error);
        Toast.show({
            label: error[this.errorTitle],
            message: error[this.errorBody],
            mode: 'sticky',
            variant: 'error'
        }, this);
    }

}