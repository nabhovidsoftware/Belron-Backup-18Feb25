import { LightningElement,track, api  } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
class optionObject{
    constructor(value){ 
        this.value = value;
        this.label = value.replace(/%/g, '');
        if(value.endsWith('%')){
            this.labelWithOperation = 'CONTAINS: ' + this.label;
        }else if (value.startsWith('%')){
            this.labelWithOperation = 'BEGINS WITH: ' + this.label;
        }
        else this.labelWithOperation = 'EQUALS: ' + this.label;
    }
}
export default class Bln_MultiSelectCmp extends LightningElement {
    @api options;
    @api label;
    @api componentName;
    @api minChar = 2;
    @api disabled;
    @track optionData;
    @track searchString;
    @track isSearchByBeginWith = true;

    connectedCallback() {
        var optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : [];
        //console.log('optionData:-'+optionData);
		
        this.optionData = optionData;
        
        if(this.disabled){
            var elementBlock = this.template.querySelector('[data-id="pillId"]');
            //console.log('elementBlock:-'+elementBlock);
            if(elementBlock){
                this.template.querySelector('[data-id="pillId"]').classList.remove('slds-pill__remove');
            }
        }
        

    }

    filterOptions(event) {
        this.searchString = event.target.value;
        var isEnterPressed =false;
        if(event.keyCode === 13){
            event.preventDefault();
            isEnterPressed =true;
        }
        if( isEnterPressed && this.searchString && this.searchString.length >= this.minChar ) {
                var optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : [];
                //console.log('Press Enter Executed');
                //console.log('filterOptions optionData:-'+optionData.length);
                var tempSearchStr = '%' + this.searchString;
                if(!this.isSearchByBeginWith){tempSearchStr=tempSearchStr+'%';}
                optionData.push(new optionObject(tempSearchStr));
                this.optionData = optionData;
                //console.log('filterOptions this.optionData:-'+this.optionData);
                let ev = new CustomEvent('selectoption', {detail:this.optionData});
                this.dispatchEvent(ev);
                this.dispatchEvent(new RefreshEvent());
        }
	}

    closePill(event) {
        if(!this.disabled){
            var value = event.currentTarget.name;
            //console.log('closePill1:-'+value);
            var options = JSON.parse(JSON.stringify(this.optionData));
            for(var i = 0; i < options.length; i++) {
                if(options[i].value === value) {
                    //console.log('closePill2:-'+options[i].value);
                    this.optionData.splice(i, 1);
                    break;
                }
            }
            //this.optionData = options;
            //console.log('closePill:-'+JSON.stringify(this.optionData));
            let ev = new CustomEvent('selectoption', {detail:this.optionData});
            this.dispatchEvent(ev);
            this.dispatchEvent(new RefreshEvent());
        }
    }

    handleToggle(event){
        this.isSearchByBeginWith = !this.isSearchByBeginWith;
    }
}