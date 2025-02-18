import { LightningElement, api, track } from 'lwc';
import timeline from '@salesforce/resourceUrl/TimelineVis';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import getInitiatives from '@salesforce/apex/BLN_TimeLineController.getInitiatives';
import { NavigationMixin } from 'lightning/navigation';

export default class Bln_Timeline extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @track viewTimeline;
    @track showTimelineButton = true;

    connectedCallback() {
        const searchParams = new URLSearchParams(window.location.search);
        if(!this.recordId) {
            this.recordId = searchParams.get('c__id');
            this.showTimelineButton = false;
        }

        this.viewTimeline = '/lightning/n/BLN_TimelineView?c__id=' + this.recordId;

        getInitiatives({recId : this.recordId})
        .then(res => {
            let calendarImage = timeline + '/TimelineVis/calendar.png';
            let jsPath = timeline + "/TimelineVis/vis-timeline-graph2d.min.js";
            let cssPath = timeline + "/TimelineVis/vis-timeline-graph2d.min.css";

            res.forEach(item => {
                item.id = item.recId;
                item.start = item.startDate;
                item.end = item.endDate;
                item.content += item.className == 'green' ? '  ✓' : item.className == 'red' ? '  x' : item.className == 'blue' ? ' !' : ' &nbsp; <img src="' + calendarImage + '" height="16px" width="16px" />';
            });

            Promise.all([loadScript(this, jsPath), loadStyle(this, cssPath)])
            .then(() => {

                let items = new vis.DataSet(res);
                let container = this.template.querySelector(".tm");
                let options = { width:'100%' };

                if(container) {
                    window.timeline = new vis.Timeline(container, items, options);
                } else {
                    alert("Container not able to load");
                }
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                                        title: "Error loading Chart",
                                        message: error,
                                        variant: "error",
                                    }),
                );
            });
        })
        .catch(err => {
            console.error(err);
        });
    }
}