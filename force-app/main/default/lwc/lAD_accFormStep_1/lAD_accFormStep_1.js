import { LightningElement,api,wire } from 'lwc';

export default class LAD_accFormStep_1 extends LightningElement {
  
    renderedCallback()
    {

        setTimeout(() => {
            window.scrollTo({
                top: 0,
                left: 0,
                behavior: 'smooth'
                
            });
        }, 100);
     
        
    }
}