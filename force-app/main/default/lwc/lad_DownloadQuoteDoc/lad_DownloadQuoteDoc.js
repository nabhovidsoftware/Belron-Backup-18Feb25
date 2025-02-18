import { LightningElement, wire } from 'lwc';
import generateQuoteDoc from '@salesforce/apex/LAD_QuoteHandler.generateQuoteDoc';
import { registerListener, unregisterAllListeners } from 'c/lad_pubsub';
import { CurrentPageReference } from 'lightning/navigation';



export default class Lad_DownloadQuoteDoc extends LightningElement {
    replacementMap;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('downloadQuote', this.setReplacementMap, this);

    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    setReplacementMap(response) {
        console.log('Response ' + response);
        this.replacementMap = response;
        console.log('REPLACEMENT MAP RECEIVED  ' + JSON.stringify(this.replacementMap));
    }

    handleQuoteGenerate(event) {
        /* let replacementMap = {
            'AccountName': 'Test Account',
            'ContactName': 'Test Contact',
            'QuoteNumber': 'QUO-0000001',
            'Date': '2024-08-27',
            'ProductCode': 'ABC\nEFG\nIJK',
            'ProductDescription': 'Product A\nProduct B\nProduct C',
            'ProductPrice': 'GBP 10\nGBP 20\nGBP 30',
            'TotalPrice': 'GBP 60',
            'Notes': 'Sample Notes'

        } */
        event.stopPropagation();

        if (this.replacementMap !== null && this.replacementMap !== undefined) {
            generateQuoteDoc({ replacementMap: this.replacementMap })
                .then(result => {
                    this.downloadFile(result, 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,', 'QuoteDoc.xlsx');
                })
                .catch(e => {
                    console.error('Error in Text Replacement---> ' + e);
                })
        }
        else {
            console.log('IN TOAST');
            Toast.show({
                label: 'Error',
                message: 'No Quote Details available',
                mode: 'sticky',
                variant: 'error'
            }, this);
        }

    }

    downloadFile(blobData, mimeType, filename) {
        try {
            const link = document.createElement('a');
            //link.href = URL.createObjectURL(new Blob([blobData], { type: mimeType }));
            link.href = mimeType + blobData;
            link.download = filename;
            link.click();
            //window.open('data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,' + blobData, filename);



        } catch (e) {
            console.error('Error in Encoding---> ' + e);
        }
    }
}