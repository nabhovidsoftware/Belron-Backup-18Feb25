import { effectiveAccount } from 'commerce/effectiveAccountApi';
import { LightningElement, api, track } from 'lwc';

import chartjs from '@salesforce/resourceUrl/lwcc__chartjs_v280';


import {loadScript} from 'lightning/platformResourceLoader';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getAllInvoice from '@salesforce/apex/LAD_CsvController.getAllInvoice';
import getAccId from '@salesforce/apex/LAD_CsvController.getAccId';
import Id from '@salesforce/user/Id';
export default class LAD_InvoiceReportAsChart extends LightningElement {

    @api accountId;

    connectedCallback()
    {   
        getAccId({userid:Id})
        .then(result => {

            
            this.accountId=result;
            this.fetchDetails();
        })
        .catch(error=>{
            console.log(error);
        })
    }

    fetchDetails()
    {   let variable = effectiveAccount.accountId!=null & effectiveAccount.accountId!=undefined? effectiveAccount.accountId:this.accountId
        console.log('ChartId :::'+variable);
        getAllInvoice({accountId:variable}) 
        .then(result => {

            for(var key in JSON.parse(JSON.stringify(result))) {
                this.updateChart(result[key].count,result[key].label);
            }
            this.error=undefined;
        })
        .catch(error => {
            console.log(error);
        });
        
    }
  chart;
  chartjsInitialized = false;
  config={
      type : 'doughnut',
      data :{
          datasets :[
          {
              data: [],
              backgroundColor :[
                  'rgb(237, 92, 174)',
                  'rgb(115, 240, 121)',
                  'rgb(127, 227, 217)',
                  'rgb(217, 127, 227)',
                  'rgb(230, 122, 108)',
                  'rgb(230, 204, 108)',
                  'rgb(79, 116, 227)',
                  'rgb(204, 33, 58)',
                  'rgb(79, 227, 163)',],
              label:'Dataset 1'
          }
           ],
      labels:[]
      },
      options: {
          responsive : true,
          legend : {
              position :'right',
              label : 'Month'
          },
          animation:{
              animateScale: true,
              animateRotate : true
          }
      }
  };

  renderedCallback() {
      if(this.chartjsInitialized) {
          return;
      }
      this.chartjsInitialized = true;
      Promise.all([
          loadScript(this,chartjs)
          ]).then(() =>{
              const ctx = this.template.querySelector('canvas.donut')
              .getContext('2d');
              this.chart = new window.Chart(ctx, this.config);
          })
          .catch(error =>{
              this.dispatchEvent(
                  new ShowToastEvent({
                      title : 'Error loading ChartJS',
                      message : error.message,
                      variant : 'error',
              }),
          );
      });
  }

  updateChart(count,label){
      this.chart.data.labels.push(label);
      this.chart.data.datasets.forEach((dataset) => {
          dataset.data.push(count);
      });
      this.chart.update();
  }
}