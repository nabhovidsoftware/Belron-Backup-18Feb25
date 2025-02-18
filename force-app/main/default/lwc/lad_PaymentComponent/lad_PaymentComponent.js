import { LightningElement, track } from 'lwc';


export default class Lad_PaymentComponent extends LightningElement {
    finDocIdList;
    accountId;
    vfRoot = 'https://belronint--ukst2--c.sandbox.vf.force.com';

    renderedCallback() {
        window.addEventListener("message", (message) => {
            console.log(message.origin);
            if (message.origin !== this.vfRoot) {
                //Not the expected origin
                return;
            }

            //handle the message
            if (message.data.name == "EmbedVflwc") {
                this.messageFromVF = message.data.payload;
                console.log(this.messageFromVF);

                const url = new URL(window.location.href);
                this.finDocIdList = url.searchParams.getAll('finDocId');
                this.accountId = url.searchParams.get('accountId');
                console.log('PARAMS IN LWC ', this.finDocIdList);
                this.passParamsToVF();
            }
        });

    }

    passParamsToVF() {
        const vfPage = this.template.querySelector("iframe");
        console.log('VF PAGE iframe ', vfPage);
        if (vfPage) {
            console.log('IN POST MESSAGE');
            vfPage.contentWindow.postMessage({
                finDocIds: this.finDocIdList,
                accountId: this.accountId,
            }, this.vfRoot);
        }
    }

}