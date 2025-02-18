import { LightningElement, api, track } from 'lwc';
export default class Bln_ArpDataCollectPicklist extends LightningElement {
    @api optionsFromFlow;
    @track options;
    @api value;

    connectedCallback() {
        let tempOptions = [];

        console.log('@@@', this.optionsFromFlow);
        console.log('@@@', this.value);

        let tempoptionsFromFlow = JSON.parse(JSON.stringify(this.optionsFromFlow));
        console.log('$$$', tempoptionsFromFlow);

        tempoptionsFromFlow.forEach(item => {
            let obj = {};
            obj.label = item;
            obj.value = item;
            tempOptions.push(obj);
        });
        this.options = tempOptions;
    }

    handleChange(event) {
        console.log(event.detail.value);
        this.value = event.detail.value;
    }
}