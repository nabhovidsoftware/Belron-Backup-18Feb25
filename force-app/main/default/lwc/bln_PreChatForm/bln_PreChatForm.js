import { LightningElement, api, track } from 'lwc';
import yes from '@salesforce/label/c.BLN_Yes'; 
import no from '@salesforce/label/c.BLN_No';
import existingBooking from '@salesforce/label/c.BLN_DoyouhaveanExistingBooking';
import howCanWeHelp from '@salesforce/label/c.BLN_Howcanwehelp';
import preChat from '@salesforce/label/c.BLN_PreChat';
import choiceList from '@salesforce/label/c.BLN_ChoiceListChoiceList';
import preChatSubmit from '@salesforce/label/c.BLN_PreChatSubmit';
import large from '@salesforce/label/c.BLN_Large';
import desktopLaptop from '@salesforce/label/c.BLN_DesktopLaptop';
import tablet from '@salesforce/label/c.BLN_Tablet';
import small from '@salesforce/label/c.BLN_Small';
import phone from '@salesforce/label/c.BLN_MDMPhone';
import operaLink from '@salesforce/label/c.BLN_OperaLink';
import safariLink from '@salesforce/label/c.BLN_SafariLink';
import firefoxLink from '@salesforce/label/c.BLN_FireboxLink';
import edgLink from '@salesforce/label/c.BLN_EdgLink';
import chromeLink from '@salesforce/label/c.BLN_ChormeLink';
import chromiumLink from '@salesforce/label/c.BLN_ChromiumLink';
import criosLink from '@salesforce/label/c.BLN_CriosLink';
import msieLink from '@salesforce/label/c.BLN_MsieLink';
import opera from '@salesforce/label/c.BLN_BrowserOpera';
import edge from '@salesforce/label/c.BLN_BrowserEdge';
import chrome from '@salesforce/label/c.BLN_BrowserChrome';
import safari from '@salesforce/label/c.BLN_BrowserSafari';
import firefox from '@salesforce/label/c.BLN_BrowserFirefox';
import ie from '@salesforce/label/c.BLN_BrowserIE';
import other from '@salesforce/label/c.BLN_Other';
import value from '@salesforce/label/c.BLN_MelissaValue';
import browserLabel from '@salesforce/label/c.BLN_Browser';
import deviceTypeLabel from '@salesforce/label/c.BLN_DeviceType';
import platformLabel from '@salesforce/label/c.BLN_Platform';
import startConversation from '@salesforce/label/c.BLN_StartConversation';

export default class Bln_PreChatForm extends LightningElement{

    label = {
        startConversation,
    };

    @api configuration = {};
    @track fields = [];
    @track hiddenFields=[];

    connectedCallback() {
        if(this.configuration.forms){
            const prechatForm = this.configuration.forms.find(form => form.formType === preChat);
            if (prechatForm) {
                this.fields = JSON.parse(JSON.stringify(prechatForm.formFields)).sort((a, b) => a.order - b.order);
                                this.hiddenFields=JSON.parse(JSON.stringify(prechatForm.hiddenFormFields));
            }
        }
       this.fields = this.addChoiceListValues(this.fields);
           }

    //This method is used to get the choice list values of the fields
    addChoiceListValues(fields){
        fields.forEach(fld => {
            if(fld.type === choiceList){
                fld.isChoiceList = true;
                const matchingChoice = this.configuration.choiceListConfig.choiceList.find(choice => choice.choiceListId === fld.choiceListId);
                if(matchingChoice){
                    fld.choiceListValues = matchingChoice.choiceListValues.map( (x) =>{ return {...x, value : x.choiceListValueName}}) || [];
                }
            } else {
                fld.isChoiceList = false;
            }
        });
        return fields;
    }

    //This method is used to display the fields based on the selection of choice list value of the exciting booking field
    handleChange(event){
        const fieldName = event.target.name;
        const fieldValue = event.detail.value;
        const changedField = this.fields.find(fld => fld.name === event.target.name);
        changedField.value = fieldValue;
        
        if(fieldName === existingBooking && fieldValue === yes){
            this.fields.forEach(fld => {
                if(fld.name === existingBooking){
                    fld.value = fieldValue;
                }
                fld.visible = true;
            });
        } else if(fieldName === existingBooking && fieldValue === no){
            this.fields.forEach(fld => {
                if(fld.name === existingBooking || fld.name === howCanWeHelp){
                    fld.visible = true;
                } else {
                    fld.visible = false;
                }
            });
        }
    }

    //This method is created to send the values to the omni routing flow once the user click on Start Conversion button
    onClickStartConversation() {
        let hldfld=[];
        const prechatData = {};
        this.fields.forEach(field => {
            if(field.value){
                prechatData[field.name] = String(field.value);
            }
        });
        hldfld=this.hiddenMethod();
        hldfld.forEach(row => {
            this.hiddenFields.forEach(hFld => {
                if(row.name == hFld.name){
                    hFld[value] = row.value;
                }
            });
        })
        this.hiddenFields.forEach(hiddenFld => {
            prechatData[hiddenFld.name] = String(hiddenFld.value);
        });
        this.dispatchEvent(new CustomEvent(
            preChatSubmit,
            {
                detail: { value: prechatData }
            }
        ));
    }

    //This method is used to get the details of hidden fields
    hiddenMethod(){
        let hField=[];
        let deviceType='';
        let browser='';
        let platform='';

        if(screen.width > large){
            deviceType=desktopLaptop;
        }else if(screen.width <= small){
            deviceType=phone;
        }else{
            deviceType=tablet;
        }

        platform = navigator.platform;

        if(navigator.userAgent.toLowerCase().includes(operaLink)){
            browser=opera;
        }else if(navigator.userAgent.toLowerCase().includes(edgLink)){
            browser=edge;
        }else if(navigator.userAgent.toLowerCase().includes(chromeLink,chromiumLink,criosLink)){
            browser=chrome;
        }else if(navigator.userAgent.toLowerCase().includes(safariLink)){
            browser=safari;
        }else if(navigator.userAgent.toLowerCase().includes(firefoxLink)){
            browser=firefox;
        }else if(navigator.userAgent.toLowerCase().includes(msieLink)){
            browser=ie;
        }else{
            browser=other;
        }
        hField.push({name: browserLabel, value : browser});
        hField.push({name: deviceTypeLabel, value :deviceType});
        hField.push({name: platformLabel, value :platform});
        return hField;
    }

}