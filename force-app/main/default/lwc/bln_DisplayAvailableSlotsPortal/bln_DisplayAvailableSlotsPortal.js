/**
 * @description       :
 * @author            : Sourabh Bhattacharjee
 * @group             :
 * @last modified on  : 09-12-2024
 * @last modified by  : Sourabh Bhattacharjee
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   09-04-2024   Sourabh Bhattacharjee   Initial Version
**/
import { LightningElement, track, api, wire } from 'lwc';
import NoSlotAvailable from '@salesforce/label/c.BLN_NoSlotAvailable';
import WaitingDropOff from '@salesforce/label/c.BLN_WaitingDropOff';
import Waiting from '@salesforce/label/c.BLN_Waiting';
import DropOff from '@salesforce/label/c.BLN_DropOff';
import SelectSlot from '@salesforce/label/c.BLN_SelectSlot';
import SlotColumns from '@salesforce/label/c.BLN_SlotColumns';
import updateDate from '@salesforce/apex/BLN_AppointmentSlots.updateAppointmentPortal';
import getBranchSlots from '@salesforce/apex/BLN_AppointmentCreateUpdate.getBranchSlots';
import getMobileSlots from '@salesforce/apex/BLN_AppointmentCreateUpdate.getMobileSlots';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from "lightning/confirm";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import arrivalWindowStartTime from "@salesforce/schema/ServiceAppointment.ArrivalWindowStartTime";
import forceAppointment from "@salesforce/schema/ServiceAppointment.BLN_IsForcedAppointment__c";
import forceDropOff from '@salesforce/label/c.BLN_ForceAppointmentLabel'
const fields = [arrivalWindowStartTime, forceAppointment];
import LightningAlert from 'lightning/alert';
import checkPermission from '@salesforce/apex/BLN_ProductAuthorisation.checkCurrentLoggedinUser';
//import BLN_LEFTLOGO from '@salesforce/resourceUrl/BLN_Leftarrow';
//import BLN_RIGHTLOGO from '@salesforce/resourceUrl/BLN_Rightarrow';
//import getPortalCancellationOptions from '@salesforce/apex/Bln_PortalCancellationOptions.getPortalCancellationOptions'; //R2.1 FOUK:8452
import updatenewSA from "@salesforce/apex/BLN_PortalAppoinmentUpdate.updateServiceRequest";//R2.1 FOUK:8452
import saSchedule from "@salesforce/apex/BLN_AppointmentBooking.scheduleAppointment";//R2.1 FOUK:8452

import { NavigationMixin } from 'lightning/navigation';
import LightningModal from 'lightning/modal';

export default class Bln_DisplayAvailableSlotsPortal extends NavigationMixin(LightningElement) {

  label = {
    NoSlotAvailable,
    WaitingDropOff,
    Waiting,
    DropOff,
    SelectSlot,
    SlotColumns,
    forceDropOff
  }

  @api leftarrowUrl;
  @api rightarrowUrl;
  @track showError = false;
  @api saList; //added by vedita
  @api isCashJourney;
  @api jsonProductData; //added by vedita
  @api selectedSlotApp;
  @track slots;
  @track date1;
  onloadportal = true;
  @track date2;
  @track date3 = new Date();
  @track whiteStyle = "height:2rem;width:11.6rem; border:1px solid black;"; //background:white
  @track locStyle = "height:3rem;width:58.3rem; border:1px solid black;background:Darkgreen"; "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester";
  @track boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_4-of-12 tester slds-listbox__item";
  @track product = [];
  @track appSlots = [];
  @track checkUncheck;
  @track checkUncheckDateSlot;
  @track dateString;
  @track checkSelectSlot = false;
  @track selectSlotDate;
  @track appointmentId;
  @track newSlotDate;
  @track newEndSlotDate;
  @track finalSlot = [];
  @api openModal;
  @api appointmentId;
  @track slotArray = [];
  @api isMobileLocation;
  @track dateMap = [];
  @track arreyMap = [];
  @api currentPayload;
  @api selectedProductList;
  newload = true;
  /*Re-booking Start*/
  newSADetails = '';
  @api oldSlotDetails;
  @api oldAppointmentId;
  @api isRebooking = false;
  isDateChange = false;
  rebookReasonValue = '';
  rebookSubReasonOptionValue = '';
  isRebookingRequestModel = false;
  datePart = '';
  timeRange = '';
  startTime = '';
  endTime = '';
  /*Re-booking END*/
  @api caseId;
  @api setProductDataList;
  @api productDataList = [];
  finalSlotMap = [];
  tenDates = [];
  testList1 = [];
  rightArrowDisabled = false;
  slotDateCheck;
  someMap = new Map();
  missingDaysArray = [];
  startSlotTime = '';
  endSlotTime = '';
  orderId = '';
  isDropOff = '';
  endDate;
  startDate;
  selectUnselectSlot;
  showSpinner = false;
  today;
  firstDate;
  leftArrowDisabled = false;
  dateStringCheck;
  dateValue;
  isInsurance = false;
  myDate;
  isShowModal = true;
  confirmDisabled = false;
  isDisable = true;
  @track subSection = false;
  @track showModal = false; // added by vedita
  showModalBk = true;
  timeOptions = [];
  EndtimeOptions = [];
  @track forceAppt = false;
  @track noslotcheck = false;
  noSlotBoolean = false;
  @track startSelectedTime = false;
  @track endSelectedTime = false;
  checkPermissionName = false;
  @api getQuotePayload = [];
  IsModalHide = false;
  portalCancellationOptions; //R2.1 FOUK:8452
  onloadportal = true;
  ShowCancelForm = false;
  @track slotValueNew = 'none';
 @track isLoadingOKpopup =false;
  @track arrayMap = [];
  @track splitArray = [];
  @track okPopup = false;
  rightIndex;
  leftIndex;
  disableRightArrow;
  disableLeftArrow;
  appId;
  scaseid;
//timeSlotArray = [];
mainSpiner =true;
  @wire(getRecord, {
    recordId: "$appointmentId",
    fields: fields
  })
  SARecord;

  //R2.1 FOUK:8452 starts
 /* @wire(getPortalCancellationOptions)
  wiredPortalCancellationOptions({ error, data }) {
    if (data) {
      this.portalCancellationOptions = data;
      console.log('this.portalCancellationOptions------>', this.portalCancellationOptions);
    } else if (error) {
      console.error('Error fetching Portal Cancellation Options', error);
    }
  }

  get isMessage1() {
    if (!this.portalCancellationOptions) {
      return false;
    }
    return this.portalCancellationOptions.some(option => option.BLN_CancellationMethod__c === 'Message');
  }

  get isMessage2() {
    if (!this.portalCancellationOptions) {
      return false;
    }
    return this.portalCancellationOptions.some(option =>
      option.BLN_CancellationMethod__c === 'Cancellation with Charge' ||
      option.BLN_CancellationMethod__c === 'Cancellation without Charge');
  }

*/
  // isMessage1(cancellationMethod) {
  //   console.log('this.portalCancellationOptions------>cancellationMethod:Message');
  //     return cancellationMethod === 'Message';
  // }

  // isMessage2(cancellationMethod) {
  //   console.log('this.portalCancellationOptions------>cancellationMethod: Cancellation with Charge');
  //     return cancellationMethod === 'Cancellation with Charge' || cancellationMethod === 'Cancellation without Charge';
  // }



  //R2.1 FOUK:8452 ENDS


  async connectedCallback() {
   // this.leftarrowUrl = BLN_LEFTLOGO;
    //this.rightarrowUrl = BLN_RIGHTLOGO;

    console.log('generateTimeSlots');
    this.generateTimeSlots();
    //this.generateEndTimeSlots();
    console.log('this.timeOptions', this.timeOptions);
    console.log('display2323' + JSON.stringify(this.productDataList));
    console.log('display4545' + JSON.stringify(this.setProductDataList));
    // console.log('selectedProductList1212'+selectedProductList);
    this.isShowModal = this.openModal;
    console.log('appointmentId12345', this.appointmentId);
    
    // if(this.appointmentId){
    //   this.scheduleSa();
    // }
    console.log('selectedSlotApp', this.selectedSlotApp);
    console.log('isMobileLocation', this.isMobileLocations);
    const startingDate = this.selectedSlotApp.earlierAvailabilityDateHeader;
    const currentUrl = window.location.href;
    const url = new URL(currentUrl);
    const pathSegments = url.pathname.split('/');  
    // Assuming the structure is always the same and the case ID is the 5th segment  
      const caseid = pathSegments[4]; // Index 4 is correct based on the provided URL  
    const searchParams = new URLSearchParams(url.search);
    const sid = searchParams.get('sid');
    this.appId = sid;
    this.scaseid=caseid;

      // Adding console logs for debugging  
      console.log('Starting Date:', startingDate);  
      console.log('Current URL:', currentUrl);  
      console.log('URL Path Segments:', pathSegments);  
      console.log('Case ID:', caseid);  
      console.log('Search Params:', searchParams.toString());  
      console.log('SID:', sid);  
      console.log('App ID:', this.appId);  
      console.log('Scase ID:', this.scaseid);  


    // checkPermission()
    // .then(result => {
    //   if(result!=null && result == true){

    //   this.checkPermissionName = true;
    //   console.log('checkPermission', this.checkPermissionName);
    //   }
    //   console.log('resultpermission',result);
    // })
    // .catch(error => {
    //   console.log('error', error);
    // });

    if (startingDate != null) {
      this.today = startingDate;
    }
    console.log('startingDate', startingDate);
    this.selectedOptionValue = Waiting;
    console.log('this.selectedOptionValue', this.selectedOptionValue)
    this.dateUpdate();

    if (startingDate != null) {
      this.showSpinner = true;
      this.arreyMap = [];
      const slotDateCheck = this.selectedSlotApp.earlierAvailabilityDateHeader;
      console.log('slotDateCheck', slotDateCheck);
      let date = new Date(slotDateCheck);

      this.selectSlotDate = new Date(date.getTime() - (date.getTimezoneOffset() * 60000)).toISOString();
      console.log('--originalDate in selectSlot-->', this.selectSlotDate);
      console.log('Date is selected')

      let newDateArray = [];
      //   updateDate({
      //     appointmentId: this.appointmentId,
      //     arrivalStartAndEndDate: this.selectSlotDate
      //   })
      //     .then((result) => {
      //       console.log('updateAppointmentDate', result);

      //     })
      //     .catch((error) => {
      //       console.log('updateAppointmentDateError', error);
      //     })

      if (this.isMobileLocation == false) {
        await getBranchSlots({
          appointmentId: this.appointmentId
        })
          .then((slots) => {
            let dateSort = [];
            console.log('branch slots called method-->::', JSON.stringify(slots));
            console.log('branch slots called method-->::', JSON.stringify(slots.isSuceess));
            console.log('branchslots called method-->::', JSON.stringify(slots.dropOffSlots));
            console.log('branch  called method-->::', JSON.stringify(slots.waitingSlots));

            console.log('slots Length:: ', slots.isSuceess);
            if (slots.isSuceess == false) {
              this.showSpinner = false;
              this.noSlotBoolean = true;
              if (this.noSlotBoolean == true && this.checkPermissionName == true) {
                console.log('check no slot');
                this.noslotcheck = true;
                this.showSpinner = false;
              }
            }
            //console.log('SARecord', JSON.stringify(this.SARecord));
            //console.log('SARecord123', JSON.stringify(getFieldValue(this.SARecord.data, forceAppointment)));
            //console.log('forceAppointment',this.SARecord.BLN_IsForcedAppointment__c.value);
            //let AppoitnemntForce = getFieldValue(this.SARecord.data, forceAppointment);
            //console.log('noSlotBoolean',this.noSlotBoolean);
            //console.log('checkingapptforce', AppoitnemntForce);



            else {
              this.noSlotBoolean = false;
              console.log('false No slot', this.noSlotBoolean);
              if (this.selectedOptionValue == Waiting) {
                dateSort = slots.waitingSlots;
                this.isDropOff = false;
              } else {
                dateSort = slots.dropOffSlots;
                this.isDropOff = true;
              }
              this.finalSlot = dateSort;
              this.newload = true;
              // newDateArray = this.showBranchSlots(this.finalSlot, this.selectSlotDate);
              console.log(' this.finalSlot getDatesWithTimings ::', this.finalSlot);
              console.log('this.finalSlot branch getDatesWithTimings', JSON.stringify(this.finalSlot));
              this.getDatesWithTimings();
            }


          }
          );
      }
      else {
        await getMobileSlots({
          appointmentId: this.appointmentId
        })
          .then((slots) => {
            let slotReturnValue = slots[0].isSuceess;
            console.log('getMobileSlots is called')
            console.log('mobile slots called method-->::', slots[0].isSuceess);
            console.log('mobile slots called method-->::', JSON.stringify(slots));

            console.log('slots Length:: ', slots.length);
            console.log('mobile slots msg method-->::', slots[0].msg);
            if (slots[0].msg == "Could not find relevant slots") {
              this.showSpinner = false;
              this.noSlotBoolean = true;
              // FOUK-7148
              console.log('noSlotBoolean', this.noSlotBoolean);
              console.log('checkPermissionName', this.checkPermissionName);
              if (this.noSlotBoolean == true && this.checkPermissionName == true) {
                console.log('check no slot');
                this.noslotcheck = true;
                this.showSpinner = false;
              }

              console.log('inside if', slots[0].msg)
            } else {
              this.noSlotBoolean = false;
              // this.finalSlot = slots;
              let mobileSlots = [];

              // Function to convert slots to desired format
              function convertSlots(slots) {
                return slots.map(slot => {
                  let slotDate = slot.slotDate;
                  let startTime = new Date(`${ slotDate }T${ slot.slotStart }:00.000Z`);
                  let endTime = new Date(`${ slotDate }T${ slot.slotEnd }:00.000Z`);

                  return {
                    endTime: endTime.toISOString().replace('.000Z', '.000+0000'),
                    startTime: startTime.toISOString().replace('.000Z', '.000+0000')
                  };
                });
              }

              // Update finalSlot with the converted slots
              this.newload = true;
              this.finalSlot = convertSlots(slots);

              this.getDatesWithTimings();
            }

          })
      }
      // if (this.checkUncheckDateSlot == this.selectedSlotApp.earlierAvailabilityDateHeader) {
      //   this.checkUncheckDateSlot = this.selectedSlotApp.earlierAvailabilityDateHeader;
      // }
      // else {
      //   this.checkUncheckDateSlot = this.selectedSlotApp.earlierAvailabilityDateHeader;
      // }
      // this.dateMap.forEach(ele => {
      //   if (ele.dateValue == this.checkUncheckDateSlot && this.checkUncheckDateSlot) {
      //     ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center  boxeffect true bagroundcolor_slotB";
      //   } else {
      //     ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center  boxeffect bagroundcolor_slotA";
      //   }
      // });
    }

    if(this.newload == true) {
      // Specify your initial date
    //   let initialDate = new Date(this.selectSlotDate); // Replace with your specific date
      let initialDate = new Date(this.today); 
  
      // Add 7 days to the initial date
  
  
    //   let returnVal = this.addDays(initialDate, 7);
    //   initialDate.setDate(initialDate.getDate() + 14);
    //   initialDate.setDate(initialDate.getDate() + 0);
  
      // Log details to the console
      console.log('Initial Date:', initialDate);
      console.log('Initial Date as String:', initialDate.toDateString());
      console.log('Full Date Object:', initialDate);
  
      // Convert the updated date back to an ISO string
      let selectSlotDatePlus7 = initialDate.toISOString();
      console.log('-- Select Slot Date Plus 7 Days (ISO) -->', selectSlotDatePlus7);
  
      // Manually format the date to "Month Day, Year"
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      let formattedDate = `${ months[initialDate.getMonth()] } ${ initialDate.getDate() }, ${ initialDate.getFullYear() }`;
    //   console.log('-- Select Slot Date Plus 7 Days (Formatted) -->', formattedDate);
	  console.log('Initial Date: 438', initialDate);
	//   console.log('formattedDate: 439', formattedDate);
  
      // Update the date
      await updateDate({
        appointmentId: this.appointmentId,
        arrivalStartAndEndDate: selectSlotDatePlus7,
        startDate: initialDate,
        interval: 10
      })
        .then(async(result) => {
          console.log('Update Appointment Date Result:', result);
  
          if (this.isMobileLocation == false) {
            await getBranchSlots({
              appointmentId: result
            })
              .then((slots) => {
                let dateSort = [];
                console.log('branch slots called method-->::', JSON.stringify(slots));
                console.log('branch slots called method-->::', JSON.stringify(slots.isSuceess));
                console.log('branchslots called method-->::', JSON.stringify(slots.dropOffSlots));
                console.log('branch  called method-->::', JSON.stringify(slots.waitingSlots));
  
                console.log('slots Length:: ', slots.isSuceess);
                if (slots.isSuceess == false) {
                  this.showSpinner = false;
                  this.noSlotBoolean = true;
                  if (this.noSlotBoolean == true && this.checkPermissionName == true) {
                    console.log('check no slot');
                    this.noslotcheck = true;
                    this.showSpinner = false;
                  }
                }
                //console.log('SARecord', JSON.stringify(this.SARecord));
                //console.log('SARecord123', JSON.stringify(getFieldValue(this.SARecord.data, forceAppointment)));
                //console.log('forceAppointment',this.SARecord.BLN_IsForcedAppointment__c.value);
                //let AppoitnemntForce = getFieldValue(this.SARecord.data, forceAppointment);
                //console.log('noSlotBoolean',this.noSlotBoolean);
                //console.log('checkingapptforce', AppoitnemntForce);
  
  
  
                else {
  
                  this.noSlotBoolean = false;
                  console.log('false No slot', this.noSlotBoolean);
                  if (this.selectedOptionValue == Waiting) {
                    dateSort = slots.waitingSlots;
                    this.isDropOff = false;
                  } else {
                    dateSort = slots.dropOffSlots;
                    this.isDropOff = true;
                  }
                  this.finalSlot = dateSort;
                  // newDateArray = this.showBranchSlots(this.finalSlot, this.selectSlotDate);
                  console.log(' this.finalSlot getDatesWithTimings ::', this.finalSlot);
                  console.log('this.finalSlot branch getDatesWithTimings', JSON.stringify(this.finalSlot));
                  this.getDatesWithTimings();
                }
  
  
              }
              );
          }
          else {
        await getMobileSlots({
              appointmentId: result
        })
          .then((slots) => {
            let slotReturnValue = slots[0].isSuceess;
            console.log('getMobileSlots is called')
            console.log('mobile slots called method-->::', slots[0].isSuceess);
            console.log('mobile slots called method-->::', JSON.stringify(slots));
  
            console.log('slots Length:: ', slots.length);
            console.log('mobile slots msg method-->::', slots[0].msg);
            if (slots[0].msg == "Could not find relevant slots") {
              this.showSpinner = false;
              this.noSlotBoolean = true;
              // FOUK-7148
              console.log('noSlotBoolean',this.noSlotBoolean);
              console.log('checkPermissionName',this.checkPermissionName);
              if(this.noSlotBoolean == true && this.checkPermissionName == true){
              console.log('check no slot');
              this.noslotcheck = true;
              this.showSpinner = false;
            }
              
              console.log('inside if', slots[0].msg)
            } else {
              this.noSlotBoolean = false;
                  // this.finalSlot = slots;
                  let mobileSlots = [];
  
                  // Function to convert slots to desired format
                  function convertSlots(slots) {
                    return slots.map(slot => {
                      let slotDate = slot.slotDate;
                      let startTime = new Date(`${ slotDate }T${ slot.slotStart }:00.000Z`);
                      let endTime = new Date(`${ slotDate }T${ slot.slotEnd }:00.000Z`);
  
                      return {
                        endTime: endTime.toISOString().replace('.000Z', '.000+0000'),
                        startTime: startTime.toISOString().replace('.000Z', '.000+0000')
                      };
                    });
                  }
  
                  // Update finalSlot with the converted slots
                  this.finalSlot = convertSlots(slots);
  
                  this.getDatesWithTimings();
                }
  
              })
          }
  
        })
        .catch((error) => {
          console.error('Update Appointment Date Error:', error);
        });

		// Update the date 2nd time
		initialDate.setDate(initialDate.getDate() + 10);
		console.log('Initial Date:', initialDate);
		selectSlotDatePlus7 = initialDate.toISOString();
		// formattedDate = `${ months[initialDate.getMonth()] } ${ initialDate.getDate() }, ${ initialDate.getFullYear() }`;
		await updateDate({
			appointmentId: this.appointmentId,
			arrivalStartAndEndDate: selectSlotDatePlus7,
			startDate: initialDate,
			interval: 10
		  })
			.then(async (result) => {
			  console.log('Update Appointment Date Result:', result);
	  
			  if (this.isMobileLocation == false) {
				await getBranchSlots({
				  appointmentId: result
				})
				  .then((slots) => {
					let dateSort = [];
					console.log('branch slots called method-->::', JSON.stringify(slots));
					console.log('branch slots called method-->::', JSON.stringify(slots.isSuceess));
					console.log('branchslots called method-->::', JSON.stringify(slots.dropOffSlots));
					console.log('branch  called method-->::', JSON.stringify(slots.waitingSlots));
	  
					console.log('slots Length:: ', slots.isSuceess);
					if (slots.isSuceess == false) {
					  this.showSpinner = false;
					  this.noSlotBoolean = true;
					  if (this.noSlotBoolean == true && this.checkPermissionName == true) {
						console.log('check no slot');
						this.noslotcheck = true;
						this.showSpinner = false;
					  }
					}
					//console.log('SARecord', JSON.stringify(this.SARecord));
					//console.log('SARecord123', JSON.stringify(getFieldValue(this.SARecord.data, forceAppointment)));
					//console.log('forceAppointment',this.SARecord.BLN_IsForcedAppointment__c.value);
					//let AppoitnemntForce = getFieldValue(this.SARecord.data, forceAppointment);
					//console.log('noSlotBoolean',this.noSlotBoolean);
					//console.log('checkingapptforce', AppoitnemntForce);
	  
	  
	  
					else {
	  
				  this.noSlotBoolean = false;
				  console.log('false No slot', this.noSlotBoolean);
				  if (this.selectedOptionValue == Waiting) {
					dateSort = slots.waitingSlots;
					this.isDropOff = false;
				  } else {
					dateSort = slots.dropOffSlots;
					this.isDropOff = true;
				  }
				  this.finalSlot = dateSort;
					  // newDateArray = this.showBranchSlots(this.finalSlot, this.selectSlotDate);
					  console.log(' this.finalSlot getDatesWithTimings ::', this.finalSlot);
					  console.log('this.finalSlot branch getDatesWithTimings', JSON.stringify(this.finalSlot));
					  this.getDatesWithTimings();
					}
	  
	  
			  }
			  );
		  }
		  else {
			await getMobileSlots({
              appointmentId: result
            })
              .then((slots) => {
                let slotReturnValue = slots[0].isSuceess;
                console.log('getMobileSlots is called')
                console.log('mobile slots called method-->::', slots[0].isSuceess);
                console.log('mobile slots called method-->::', JSON.stringify(slots));
  
                console.log('slots Length:: ', slots.length);
                console.log('mobile slots msg method-->::', slots[0].msg);
                if (slots[0].msg == "Could not find relevant slots") {
                  this.showSpinner = false;
                  this.noSlotBoolean = true;
                  // FOUK-7148
                  console.log('noSlotBoolean', this.noSlotBoolean);
                  console.log('checkPermissionName', this.checkPermissionName);
                  if (this.noSlotBoolean == true && this.checkPermissionName == true) {
                    console.log('check no slot');
                    this.noslotcheck = true;
                    this.showSpinner = false;
                  }
  
                  console.log('inside if', slots[0].msg)
                } else {
                  this.noSlotBoolean = false;
                  // this.finalSlot = slots;
                  let mobileSlots = [];
  
                  // Function to convert slots to desired format
                  function convertSlots(slots) {
                    return slots.map(slot => {
                      let slotDate = slot.slotDate;
                      let startTime = new Date(`${ slotDate }T${ slot.slotStart }:00.000Z`);
                      let endTime = new Date(`${ slotDate }T${ slot.slotEnd }:00.000Z`);
  
                      return {
                        endTime: endTime.toISOString().replace('.000Z', '.000+0000'),
                        startTime: startTime.toISOString().replace('.000Z', '.000+0000')
                      };
                    });
                  }
  
                  // Update finalSlot with the converted slots
                  this.finalSlot = convertSlots(slots);
  
                  this.getDatesWithTimings();
                }
  
              })
          }
  
        })
        .catch((error) => {
          console.error('Update Appointment Date Error:', error);
        });
    }
    this.mainSpiner =false;
//this.timeSlotArray = this.splitArray;
  }

  
 
  scheduleSa(){
    
    saSchedule({
      appointmentId: this.appointmentId,
  })
      .then(result => {
        
          console.log('result inner if new for saSchedule', result)
      })
      .catch(err => {
          console.log('afterhr Error new saschedule', JSON.stringify(err));
      })

  }
  



  formatDayOfWeek(date) {
    let days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.getDay()];
  }

  formatDayOfMonth(date) {
    return date.getDate() < 10 ? '0' + date.getDate() : date.getDate();
  }

  formatMonth(date) {
    let months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.getMonth()];
  }


  dateUpdate() {
    let dateStringa = this.today;
    console.log('dateStringa', dateStringa);
    dateStringa = dateStringa.replace('th', '');
    let startDate = new Date(dateStringa);
    let currentData = new Date(startDate);
    this.tenDates.push(new Date(currentData));
    for (let i = 0; i <= 8; i++) {
      currentData.setDate(currentData.getDate() + 1);
      this.tenDates.push(new Date(currentData));
    }


    console.log('Incremented Date', JSON.stringify(this.tenDates));
    this.dateMap = [];
    let dateString = this.today;
    let date = new Date(dateString);
    this.dateString = date;
    this.leftArrowDisabled = true;
    let dateA = date;

    // let dateParts = date1.split("/");
    // let newFormat = dateParts[1] + "/x" + dateParts[0];

    let date1 = new Intl.DateTimeFormat('en-US').format(date);// This is your date object, adjust as needed

    // Define days and months arrays for easy access
    let dayOfWeek = this.formatDayOfWeek(date);
    let dayOfMonth = this.formatDayOfMonth(date);
    let month = this.formatMonth(date);
    let newFormat = `${ dayOfWeek } ${ dayOfMonth } ${ month }`;

    // Format the date
    //let newFormat = days[date.getDay()] + ' ' + date.getDate() + ' ' + months[date.getMonth()];

    // Output the formatted date
    console.log(newFormat); // Example output: "Mon 27 Jun" (depending on the current date)

    // Assigning to your variables
    this.date1 = newFormat;
    this.dateStringCheck = newFormat;

    let datea = new Date(date1);

    const slotDateCheck = datea;
    console.log('slotDateCheck before map', slotDateCheck);
    let dateCheck1 = new Date(slotDateCheck);

    let selectSlotDate1 = new Date(dateCheck1.getTime() - (dateCheck1.getTimezoneOffset() * 60000)).toISOString();
    console.log('--originalDate in selectSlot before map-->', selectSlotDate1.split('T')[0]);


    this.dateMap.push({
      dateValue: this.date1,
      dateTranfer: date1,
      dateCheck: datea,
      date: selectSlotDate1.split('T')[0]
    })

    date.setDate(date.getDate() + 1)
    let dateB = date;
    let date2 = new Intl.DateTimeFormat('en-US').format(date);
    // let datePartsA = date2.split("/");
    // let newFormatA = datePartsA[1] + "/y" + datePartsA[0];

    let newFormatA = this.formatDayOfWeek(date) + ' ' + this.formatDayOfMonth(date) + ' ' + this.formatMonth(date);
    this.date2 = newFormatA;
    let dateb = new Date(date2);

    const slotDateCheck2 = dateb;
    console.log('slotDateCheck before map', slotDateCheck2);
    let dateCheck2 = new Date(slotDateCheck2);

    let selectSlotDate2 = new Date(dateCheck2.getTime() - (dateCheck2.getTimezoneOffset() * 60000)).toISOString();
    console.log('--originalDate in selectSlot before map-->', selectSlotDate2.split('T')[0]);

    this.dateMap.push({
      dateValue: this.date2,
      dateTranfer: date2,
      dateCheck: dateb,
      date: selectSlotDate2.split('T')[0]
    })

    date.setDate(date.getDate() + 1)
    let dateC = date;
    let date3 = new Intl.DateTimeFormat('en-US').format(date);
    // let datePartsB = date3.split("/");
    // let newFormatB = datePartsB[1] + "/z" + datePartsB[0];


    // Format the date
    let newFormatB = this.formatDayOfWeek(date) + ' ' + this.formatDayOfMonth(date) + ' ' + this.formatMonth(date);
    //let newFormatB = days[date.getDay()] + ' ' + date.getDate() + ' ' + months[date.getMonth()];
    this.date3 = newFormatB;
    let datec = new Date(date3);

    const slotDateCheck3 = datec;
    console.log('slotDateCheck before map', slotDateCheck3);
    let dateCheck3 = new Date(slotDateCheck3);

    let selectSlotDate3 = new Date(dateCheck3.getTime() - (dateCheck3.getTimezoneOffset() * 60000)).toISOString();
    console.log('--originalDate in selectSlot before map-->', selectSlotDate3.split('T')[0]);

    this.dateMap.push({
      dateValue: this.date3,
      dateTranfer: date3,
      dateCheck: datec,
      date: selectSlotDate3.split('T')[0]

    })

    // this.dateMap.forEach(ele => {
    //   ele.slotWeathercss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center boxeffect  bagroundcolor_slotA";
    //   ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center  boxeffect  bagroundcolor_slotA";
    // });
    console.log('this.dateMap', this.dateMap);
  }
  increaseDates() {
    this.date1 = '';
    this.date2 = '';
    this.date3 = '';
    this.dateMap = [];

    let newDate = this.dateString;
    this.leftArrowDisabled = false;
    let increateDate1 = newDate.setDate(newDate.getDate() + 1)
    let date1 = new Intl.DateTimeFormat('en-US').format(newDate);
    // let dateParts = date1.split("/");
    // let newFormat = dateParts[1] + "/xx" + dateParts[0];

    let days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    let months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    let dayOfWeek = days[newDate.getDay()];
    let dayOfMonth = newDate.getDate() < 10 ? '0' + newDate.getDate() : newDate.getDate();
    let month = months[newDate.getMonth()];
    // Format the date
    let newFormat = this.formatDayOfWeek(newDate) + ' ' + this.formatDayOfMonth(newDate) + ' ' + this.formatMonth(newDate);
    //let newFormat = days[newDate.getDay()] + ' ' + newDate.getDate() + ' ' + months[newDate.getMonth()];
    this.date1 = newFormat;
    let dated = new Date(date1);

    const slotDateCheck4 = dated;
    console.log('slotDateCheck before map', slotDateCheck4);
    let dateCheck4 = new Date(slotDateCheck4);

    let selectSlotDate4 = new Date(dateCheck4.getTime() - (dateCheck4.getTimezoneOffset() * 60000)).toISOString();
    console.log('--originalDate in selectSlot before map-->', selectSlotDate4.split('T')[0]);

    this.firstDate = newDate;
    this.dateMap.push({
      dateValue: this.date1,
      dateTranfer: date1,
      dateIncrementCheck: newDate,
      dateName: 'available',
      dateCheck: dated,
      date: selectSlotDate4.split('T')[0]
    });

    let increateDate2 = newDate.setDate(newDate.getDate() + 1)
    let date2 = new Intl.DateTimeFormat('en-US').format(newDate);
    // let datePartsA = date2.split("/");
    // let newFormatA = datePartsA[1] + "/yy" + datePartsA[0];


    // Format the date
    let newFormatA = this.formatDayOfWeek(newDate) + ' ' + this.formatDayOfMonth(newDate) + ' ' + this.formatMonth(newDate);
    // let newFormatA = days[newDate.getDay()] + ' ' + newDate.getDate() + ' ' + months[newDate.getMonth()];
    this.date2 = newFormatA;
    let datee = new Date(date2);

    const slotDateCheck5 = datee;
    console.log('slotDateCheck before map', slotDateCheck5);
    let dateCheck5 = new Date(slotDateCheck5);

    let selectSlotDate5 = new Date(dateCheck5.getTime() - (dateCheck5.getTimezoneOffset() * 60000)).toISOString();
    console.log('--originalDate in selectSlot before map-->', selectSlotDate5.split('T')[0]);

    this.dateMap.push({
      dateValue: this.date2,
      dateTranfer: date2,
      dateIncrementCheck: newDate,
      dateName: 'available',
      dateCheck: datee,
      date: selectSlotDate5.split('T')[0]
    });

    let increateDate3 = newDate.setDate(newDate.getDate() + 1);
    let date3 = new Intl.DateTimeFormat('en-US').format(newDate);
    // let datePartsB = date3.split("/");
    // let newFormatB = datePartsB[1] + "/zz" + datePartsB[0];


    // Format the date
    let newFormatB = this.formatDayOfWeek(newDate) + ' ' + this.formatDayOfMonth(newDate) + ' ' + this.formatMonth(newDate);
    //let newFormatB= days[newDate.getDay()] + ' ' + newDate.getDate() + ' ' + months[newDate.getMonth()];
    this.date3 = newFormatB;
    let datef = new Date(date3);

    const slotDateCheck6 = datef;
    console.log('slotDateCheck before map', slotDateCheck6);
    let dateCheck6 = new Date(slotDateCheck6);

    let selectSlotDate6 = new Date(dateCheck6.getTime() - (dateCheck6.getTimezoneOffset() * 60000)).toISOString();
    console.log('--originalDate in selectSlot before map-->', selectSlotDate6.split('T')[0]);

    this.dateMap.push({
      dateValue: this.date3,
      dateTranfer: date3,
      dateIncrementCheck: newDate,
      dateName: 'available',
      dateCheck: datef,
      date: selectSlotDate6.split('T')[0]
    });
    let dateflg = false;
    let dateCheckerArrey = [];
    this.tenDates.forEach(ele => {
      let datetest = new Intl.DateTimeFormat('en-US').format(ele);
      datetest.split("/");
      dateCheckerArrey.push(datetest);
    });

    let flagArrey = [];
    this.dateMap.forEach(ele => {
      if (dateCheckerArrey.includes(ele.dateTranfer)) {
        flagArrey.push(false);

      } else {
        flagArrey.push(true);
      }
    });

    this.rightArrowDisabled = flagArrey.includes(true);
    if (this.rightArrowDisabled == true) {

      this.dateMap[1].dateValue = 'NA'
      this.dateMap[1].dateName = 'NA'
      this.dateMap[2].dateValue = 'NA'
      this.dateMap[2].dateName = 'NA'
      // this.dateMap.forEach(ele => {
      //   ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center   bagroundcolor_slotA";

      // });

    }
    // this.dateMap.forEach(ele => {
    //   ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center boxeffect  bagroundcolor_slotA";
    //   ele.slotWeathercss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center  boxeffect  bagroundcolor_slotA";
    // });

  }
  decreaseDates() {
    this.arreyMap = [];
    this.date1 = '';
    this.date2 = '';
    this.date3 = '';
    this.dateMap = [];
    this.rightArrowDisabled = false;
    let newDatea = this.firstDate;

    newDatea.setDate(newDatea.getDate() - 5)
    let date1 = new Intl.DateTimeFormat('en-US').format(newDatea);
    // let dateParts = date1.split("/");
    // let newFormat = dateParts[1] + "/a" + dateParts[0];

    let days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    let months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    let dayOfWeek = days[newDatea.getDay()];
    let dayOfMonth = newDatea.getDate() < 10 ? '0' + newDatea.getDate() : newDatea.getDate();
    let month = months[newDatea.getMonth()];
    // Format the date
    let newFormat = this.formatDayOfWeek(newDatea) + ' ' + this.formatDayOfMonth(newDatea) + ' ' + this.formatMonth(newDatea);
    // let newFormat = days[newDatea.getDay()] + ' ' + newDatea.getDate() + ' ' + months[newDatea.getMonth()];
    this.date1 = newFormat;
    let dateg = new Date(date1);

    const slotDateCheck7 = dateg;
    console.log('slotDateCheck before map', slotDateCheck7);
    let dateCheck7 = new Date(slotDateCheck7);

    let selectSlotDate7 = new Date(dateCheck7.getTime() - (dateCheck7.getTimezoneOffset() * 60000)).toISOString();
    console.log('--originalDate in selectSlot before map-->', selectSlotDate7.split('T')[0]);

    this.dateMap.push({
      dateValue: this.date1,
      dateTranfer: date1,
      dateCheck: dateg,
      date: selectSlotDate7.split('T')[0]
    });
    if (this.dateStringCheck == this.date1) {
      this.leftArrowDisabled = true;
    } else {
      this.leftArrowDisabled = false;
    }
    newDatea.setDate(newDatea.getDate() + 1)
    let date2 = new Intl.DateTimeFormat('en-US').format(newDatea);
    // let datePartsA = date2.split("/");
    // let newFormatA = datePartsA[1] + "/b" + datePartsA[0];


    // Format the date
    let newFormatA = this.formatDayOfWeek(newDatea) + ' ' + this.formatDayOfMonth(newDatea) + ' ' + this.formatMonth(newDatea);
    //let newFormatA = days[newDatea.getDay()] + ' ' + newDatea.getDate() + ' ' + months[newDatea.getMonth()];
    this.date2 = newFormatA;
    let dateh = new Date(date2);

    const slotDateCheck8 = dateh;
    console.log('slotDateCheck before map', slotDateCheck8);
    let dateCheck8 = new Date(slotDateCheck8);

    let selectSlotDate8 = new Date(dateCheck8.getTime() - (dateCheck8.getTimezoneOffset() * 60000)).toISOString();
    console.log('--originalDate in selectSlot before map-->', selectSlotDate8.split('T')[0]);

    this.dateMap.push({
      dateValue: this.date2,
      dateTranfer: date2,
      dateCheck: dateh,
      date: selectSlotDate8.split('T')[0]
    });
    newDatea.setDate(newDatea.getDate() + 1)
    let date3 = new Intl.DateTimeFormat('en-US').format(newDatea);
    // let datePartsB = date3.split("/");
    // let newFormatB = datePartsB[1] + "/c" + datePartsB[0];


    // Format the date
    let newFormatB = this.formatDayOfWeek(newDatea) + ' ' + this.formatDayOfMonth(newDatea) + ' ' + this.formatMonth(newDatea);
    //let newFormatB = days[newDatea.getDay()] + ' ' + newDatea.getDate() + ' ' + months[newDatea.getMonth()];
    this.date3 = newFormatB;
    let datei = new Date(date3);

    const slotDateCheck9 = datei;
    console.log('slotDateCheck before map', slotDateCheck9);
    let dateCheck9 = new Date(slotDateCheck9);

    let selectSlotDate9 = new Date(dateCheck9.getTime() - (dateCheck9.getTimezoneOffset() * 60000)).toISOString();
    console.log('--originalDate in selectSlot before map-->', selectSlotDate9.split('T')[0]);

    this.dateMap.push({
      dateValue: this.date3,
      dateTranfer: date3,
      dateCheck: datei,
      date: selectSlotDate9.split('T')[0]
    });


    // this.dateMap.forEach(ele => {
    //   ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center boxeffect bagroundcolor_slotA";
    //   ele.slotWeathercss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center  boxeffect  bagroundcolor_slotA";
    // });
  }

  get options() {
    return [
      { label: Waiting, value: Waiting },
      { label: DropOff, value: DropOff }
    ];
  }

  handleSlotOptionChange(event) {
    console.log('event.detail.value', event.target.value);
    this.selectedOptionValue = event.target.value;

  }

  /*This method will show Branch slots */
  showBranchSlots(dateSort, selectedDate) {
    this.arreyMap = [];
    console.log('inside method', JSON.stringify(dateSort));
    let timslotArreystartTime = [];
    let timeslotArreyendTime = [];
    if (dateSort.length == 0 || dateSort == '') {
      this.showSpinner = false;
      this.noSlotBoolean = true;
    }

    if (dateSort.length > 0) {
      this.finalSlotMap = [];
      this.startDateParam = [];
      this.endDateParam = [];

      let dateParts;
      let dateendfilter;
      let datePartsa;
      let datestartfilter;
      let endTimeFilter;
      if (dateSort.length != 0) {
        this.showSpinner = false;
        dateSort.forEach(ele => {
          endTimeFilter = ele.endTime;

          dateParts = endTimeFilter.split('T');
          dateendfilter = dateParts[0];
          this.appSlots.push(ele);
        });
      }
    }
    console.log('APP SLOTS LIST --> ', JSON.stringify(this.appSlots));
    if (this.appSlots.length > 0) {
      this.appSlots.forEach(element => {
        this.startDateParam.push(element.startTime);
        const timestampStart = element.startTime;
        const dateObject = new Date(timestampStart);
        const hours = dateObject.getUTCHours().toString().padStart(2, '0');
        const minutes = dateObject.getUTCMinutes().toString().padStart(2, '0');
        const timeString = `${ hours }:${ minutes }`;
        let formattedTime = timeString.replace(/\s?[AP]M$/i, '');

        timslotArreystartTime.push(formattedTime);
      });

      this.appSlots.forEach(element => {
        this.endDateParam.push(element.endTime);
        const timestampEnd = element.endTime;
        const dateObject = new Date(timestampEnd);
        const hours = dateObject.getUTCHours().toString().padStart(2, '0');
        const minutes = dateObject.getUTCMinutes().toString().padStart(2, '0');
        const timeString = `${ hours }:${ minutes }`;
        let formattedTime = timeString.replace(/\s?[AP]M$/i, '');

        timeslotArreyendTime.push(formattedTime);
      });

      for (let i = 0; i <= this.appSlots.length; i++) {
        let startTime = timslotArreystartTime[i];
        let endTime = timeslotArreyendTime[i];
        let startTimePara = this.startDateParam[i];
        let enddatePara = this.endDateParam[i];
        this.finalSlotMap.push({
          value: startTime + '-' + endTime,
          starttime: startTimePara,
          endtime: enddatePara
        });
      }
    }

    this.finalSlotMap = this.finalSlotMap.filter(item => item.value != undefined);
    this.finalSlotMap.splice(-1, 1);
    console.log('finalSlotMap content:: ', JSON.stringify(this.finalSlotMap));
    console.log('finalSlotMap Length:: ', this.finalSlotMap.length);
    let newArray = [];
    console.log('selectedDate-->', JSON.stringify(selectedDate));

    let selectedStartDate = selectedDate.split('T');
    console.log('selectedStartDate', selectedStartDate[0])
    this.finalSlotMap.forEach(ele => {
      // console.log('finalMap ele',JSON.stringify(ele.starttime))
      let startTime = ele.starttime.split('T');
      console.log('startTime[0]', startTime[0])
      if (startTime[0] == selectedStartDate[0]) {
        newArray.push(ele);
      }

    })
    console.log('newArray', JSON.stringify(newArray));
    console.log('newArray', newArray.length);
    this.finalSlotMap = newArray;
    newArray = [];
    console.log('Mobile final Slot }}:+>', JSON.stringify(this.finalSlotMap));
    console.log('Mobile final Slot }}:+>', this.finalSlotMap.length);
    if (this.finalSlotMap.length == 0) {
      this.noSlotBoolean = true;
      //FOUK-7148
      console.log('noSlotBoolean', this.noSlotBoolean);
      console.log('checkPermissionName', this.checkPermissionName);
      if (this.noSlotBoolean == true && this.checkPermissionName == true) {
        console.log('check no slot');
        this.noslotcheck = true;
        this.showSpinner = false;
      }
    }

    if (this.finalSlotMap.length > 0) {
      this.noslotcheck = false;
      for (let i = 0; i < this.finalSlotMap.length;) {
        let testList1 = [];
        for (let j = 0; j < 3 && i < this.finalSlotMap.length; j++) {
          testList1.push(this.finalSlotMap[i]);
          i++;
        }
        console.log('row', this.row);
        console.log('testList1 -->', JSON.stringify(testList1));

        testList1 = testList1.filter(item => item != null);
        this.arreyMap.push({
          row: this.row,
          List: JSON.parse(JSON.stringify(testList1))

        });
        this.row++;

      }
      console.log('arreyMap5 final-->', JSON.stringify(this.arreyMap));
      // this.arreyMap.forEach(element => {
      //   element.List.forEach(ele => {
      //     ele.boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester boxstyle slds-listbox__item";

      //   });
      // });
    }

    dateSort = [];
    this.appSlots = [];
    return this.arreyMap;
  }

  /*This method will show Mobile slots */
  showMobileSlots(dateSort, selectedDate) {
    console.log('inside new method', JSON.stringify(dateSort));
    if (dateSort.length == 0 || dateSort == '') {
      this.showSpinner = false;
      this.noSlotBoolean = true;
    }

    if (dateSort.length > 0) {
      this.finalSlotMap = [];
      this.showSpinner = false;

      dateSort.forEach(ele => {
        this.finalSlotMap.push({
          value: ele.slotStart + '-' + ele.slotEnd,
          starttime: ele.slotDate,
          endtime: ele.slotDate
        });
      });
    }


    // this.finalSlotMap = this.finalSlotMap.filter(item => item.value != undefined);
    // this.finalSlotMap.splice(-1, 1);
    console.log('finalSlotMap Length:: ', this.finalSlotMap.length);
    console.log('finalSlotMap context in mobile slots:: ', JSON.stringify(this.finalSlotMap));
    let newArray = [];
    console.log('selectedDate-->', JSON.stringify(selectedDate));

    let selectedStartDate = selectedDate.split('T');
    console.log('selectedStartDate', selectedStartDate[0])
    this.finalSlotMap.forEach(ele => {
      // console.log('finalMap ele',JSON.stringify(ele.starttime))
      let slotStartDate = ele.starttime;
      console.log('slotStartDate', slotStartDate)
      if (slotStartDate == selectedStartDate[0]) {
        newArray.push(ele);
      }

    })
    console.log('newArray', JSON.stringify(newArray));
    console.log('newArray', newArray.length);
    this.finalSlotMap = newArray;
    newArray = [];
    console.log('Mobile final Slot }}:>', JSON.stringify(this.finalSlotMap));
    console.log('Mobile final Slot }}:>', this.finalSlotMap.length);
    if (this.finalSlotMap.length == 0) {
      this.noSlotBoolean = true;
      console.log('noSlotBoolean', this.noSlotBoolean);
      console.log('checkPermissionName', this.checkPermissionName);
      if (this.noSlotBoolean == true && this.checkPermissionName == true) {
        console.log('check no slot');
        this.noslotcheck = true;
        this.showSpinner = false;
      }
    }

    if (this.finalSlotMap.length > 0) {
      this.noslotcheck = false;
      for (let i = 0; i < this.finalSlotMap.length;) {
        let testList1 = [];
        for (let j = 0; j < 3 && i < this.finalSlotMap.length; j++) {
          testList1.push(this.finalSlotMap[i]);
          i++;
        }
        console.log('row', this.row);
        console.log('testList1 -->', JSON.stringify(testList1));

        testList1 = testList1.filter(item => item != null);
        this.arreyMap.push({
          row: this.row,
          List: JSON.parse(JSON.stringify(testList1))

        });
        this.row++;

      }
      console.log('arreyMap5 final-->', JSON.stringify(this.arreyMap));
      this.arreyMap = this.arreyMap;
      // this.arreyMap.forEach(element => {
      //   element.List.forEach(ele => {
      //     ele.boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center tester boxstyle slds-listbox__item";

      //   });
      // });
    }

    dateSort = [];
    this.appSlots = [];
    return this.arreyMap;
  }

  pushMissingDays(currentDate, prevDate) {
    if (prevDate != undefined && (prevDate < currentDate.setDate(currentDate.getDate() - 1))) {
      console.log('currentDate missing', prevDate, currentDate);

      let dayOfWeek = this.formatDayOfWeek(new Date(currentDate));
      let dayOfMonth = this.formatDayOfMonth(new Date(currentDate));
      let month = this.formatMonth(new Date(currentDate));
      let newFormat = `${ dayOfWeek } ${ dayOfMonth } ${ month }`;

      let obj = {
        startTimeToDisplay: 'No Slot',
        endTimeToDisplay: 'No Slot',
        startTime: Math.random(),//ele.startTime,
        endTime: 'No Slot',
        slotTime: 'No Slots',
        isButtonDisabled: true
      }

      this.missingDaysArray.push({
        date: newFormat,
        slot: obj
      });
      return this.pushMissingDays(currentDate, prevDate);
    }
    else {
      this.missingDaysArray.reverse().forEach(ele => {
        if (!(this.someMap.has(ele.date))) {
          this.someMap.set(ele.date, [ele.slot]);
        }
      });
      this.missingDaysArray = [];
    }
  }

  pushMissingDaysToArray(currentDate, prevDate) {
    if (prevDate != undefined && (prevDate < currentDate.setDate(currentDate.getDate() - 1))) {
      console.log('currentDate missing', prevDate, currentDate);

      let dayOfWeek = this.formatDayOfWeek(new Date(currentDate));
      let dayOfMonth = this.formatDayOfMonth(new Date(currentDate));
      let month = this.formatMonth(new Date(currentDate));
      let newFormat = `${ dayOfWeek } ${ dayOfMonth } ${ month }`;

      let obj = {
        startTimeToDisplay: 'No Slot',
        endTimeToDisplay: 'No Slot',
        startTime: Math.random(),//ele.startTime,
        endTime: 'No Slot',
        slotTime: 'No Slots',
        isButtonDisabled: true
      }

      this.missingDaysArray.push({
        date: newFormat,
        slot: obj
      });
      return this.pushMissingDays(currentDate, prevDate);
    }
    else {
      this.missingDaysArray.reverse().forEach(ele => {
        this.arrayMap.push({
          date: ele.date,
          slotList: [ele.slot]
        });
        // if(!(this.someMap.has(ele.date))){
        //     this.someMap.set(ele.date,[ele.slot]);
        // }
      });
      this.missingDaysArray = [];
    }
  }


  getDatesWithTimings() {
    const tempList = [ ]
    console.log('tempp', tempList);

    let prevDate = new Date(this.selectedSlotApp.earlierAvailabilityDateHeader);
    let finalDate = new Date();
    finalDate.setDate(prevDate.getDate() + 7, prevDate);
    if (prevDate.getDate() > finalDate.getDate()) {
      finalDate.setMonth(prevDate.getMonth() + 1);
    }
    if (prevDate.getMonth() > finalDate.getMonth()) {
      finalDate.setFullYear(finalDate.getFullYear() + 1);
    }
    console.log('finalDate', finalDate);

    this.finalSlot.forEach(ele => {
      //tempList.forEach(ele => {
      let currentDate = new Date(ele.startTime.split('T')[0]);
      this.pushMissingDays(currentDate, prevDate);
      prevDate = new Date(ele.startTime.split('T')[0]);


      console.log('tempList', ele);
      let dayOfWeek = this.formatDayOfWeek(new Date(ele.startTime.split('T')[0]));
      let dayOfMonth = this.formatDayOfMonth(new Date(ele.startTime.split('T')[0]));
      let month = this.formatMonth(new Date(ele.startTime.split('T')[0]));
      let newFormat = `${ dayOfWeek } ${ dayOfMonth } ${ month }`;


      let objTime = {
        startTimeToDisplay: ele.startTime.split('T')[1],
        endTimeToDisplay: ele.endTime.split('T')[1],
        startTime: ele.startTime,
        endTime: ele.endTime,
        slotTime: `${ (ele.startTime.split('T')[1]).split(':00.000+')[0] } - ${ (ele.endTime.split('T')[1]).split(':00.000+')[0] }`,
        isButtonDisabled: false

      }
      console.log('objtime', objTime);
      console.log('this.someMap----', this.someMap);

      if (this.someMap.has(newFormat)) {
        this.someMap.get(newFormat).push(objTime);
        console.log('someMap in', this.someMap);
      }
      else {
        this.someMap.set(newFormat, [objTime]);
        console.log('someMap in', this.someMap);
      }
    });

    const iterator = this.someMap.entries();
    console.log('iterator--1238--', iterator);

    

    
    let prevLoopDate;

    
    for (let i = 0; i < 28; i++) {

      // if(i == 7||i==8||i==9){
      //   this.arrayMap.push({
      //     date: 'NA',
      //     slotList: 'NA'
      // });

      // }
      console.log('this.someMap--1248---', this.someMap);

      if (i >= this.someMap.size) {
        console.log('hit-->', i);
        console.log('datess', finalDate, prevLoopDate[1][0].startTime, new Date(prevLoopDate[1][0].startTime));
        this.pushMissingDaysToArray(finalDate, new Date(prevLoopDate[1][0].startTime));
        break;
      }


      let currentLoopDate = iterator.next().value;

      if (currentLoopDate && currentLoopDate[0].startTime > finalDate) {
        break;
      }
      
      console.log('currentLoopDate--1265--', currentLoopDate);

      if (currentLoopDate) {
       
       
        this.arrayMap.push({
          date: currentLoopDate[0],
          slotList: currentLoopDate[1]
        });
      }
      prevLoopDate = currentLoopDate;
    }
    

    

    // Array.from(this.someMap,([key,value]) => {

    //     this.arrayMap.push({
    //            date: key,
    //            slotList: value
    //          });
    // });


    //console.log('dsss', Json.parse(Json.stringify(this.arrayMap)));
    console.log('dsss', JSON.parse(JSON.stringify(this.arrayMap)));  

    const uniqueMap = new Map();


    // Function to split the date into day, date, and month  
    function splitKey(dateStr) {  
        const [day, date, month] = dateStr ? dateStr.split(' ') : [undefined, undefined, undefined];  
        return { day, date, month };  
    }  

    // Iterate through arrayMap and add each element to the Map using a combination of 'day', 'date', and 'month' as the key  
    this.arrayMap.forEach(element => {  
        const { day, date, month } = splitKey(element.date);  
        if (!date) return; // Skip if the date is undefined  
      const uniqueKey = `${ day }-${ date }-${ month }`;
        // Check if the uniqueKey is not already in the Map; if not, add it  
        if (!uniqueMap.has(uniqueKey)) {  
            const newElement = { ...element, day, date, month };  
            uniqueMap.set(uniqueKey, newElement);  
      }
    });

    // Convert the Map values back into an array to get the unique elements
    this.arrayMap = Array.from(uniqueMap.values());
    const startIndex = this.arrayMap.findIndex(item => item.slotList.length > 1);

    console.log('startIndex after dss', startIndex);
    if (startIndex) {
      this.arrayMap = this.arrayMap.slice(startIndex);
      console.log('new ArrayMp 1337 in if ', JSON.parse(JSON.stringify(this.arrayMap)));
    }
    const uniqueArray = this.arrayMap.filter((value, index, self) =>
      this.arrayMap === self.findIndex((t) => (
        t.startTime === value.startTime && t.endTime === value.endTime
      ))
    );

    console.log('uniqueArra', JSON.parse(JSON.stringify(uniqueArray)));
    // Log the updated arrayMap
    // Log the updated arrayMap
    console.log('Updated arrayMap with unique dates and split properties:', JSON.parse(JSON.stringify(this.arrayMap)));
    this.arrayMap.forEach((dateObj) => {
      dateObj.slotList = dateObj.slotList.filter((value, index, self) =>
        index === self.findIndex(
          (t) => t.startTime === value.startTime && t.endTime === value.endTime
        )
      );
    });
    
    // Log the updated array
    console.log('Updated arrayMap with unique dates and split properties new:', JSON.parse(JSON.stringify(this.arrayMap)));
  



    




    // console.log(res)

    this.leftIndex = 0;
    this.rightIndex = 2;
    let partialList = [];
    for (let i = this.leftIndex; i < this.arrayMap.length; i++) {
      if (i <= this.rightIndex) {
        partialList.push(this.arrayMap[i]);
      }
    }
    this.splitArray = [...partialList];
 	//this.timeSlotArray = this.splitArray;
    this.disableRightArrow = false;
    this.disableLeftArrow = true;
    this.showSpinner = false;
  }



  handleRightArrowClick() {
    console.log('this.arrayMap', this.arrayMap);
    console.log(this.arrayMap.length, 'this.leftIndex + 3 ----->>>', this.leftIndex + 3);
		if (this.leftIndex + 1 <= 1000) {
			this.leftIndex += 1;
			this.rightIndex += 1;
      console.log('this.rightIndex', this.rightIndex);
      let partialList = [];
      this.splitArray = [];
      for (let i = this.leftIndex; i <= ((this.rightIndex < this.arrayMap.length - 1) ? this.rightIndex : this.arrayMap.length - 1); i++) {
        partialList.push(this.arrayMap[i]);
      }
      setTimeout(() => {
        this.splitArray = [...partialList];
        console.log('splitArray', this.splitArray);
      }, 1);
      //this.timeSlotArray = this.splitArray;
      this.disableLeftArrow = false;
      if (this.rightIndex < this.arrayMap.length - 1) {
        this.disableRightArrow = false;
      }
      else {
        this.disableRightArrow = true;
       



      }
    }
    console.log("this.leftIndex  right", this.leftIndex);
    console.log("this.rightIndex right", this.rightIndex);
    console.log('arraymap size -->', this.arrayMap.length);
  }

 

  addDays(date, days) {
    console.log(days, 'date---1549---', date);
    const newDate = new Date(date);
    newDate.setDate(date.getDate() + days);
    console.log('--->>>', newDate.setDate(date.getDate() + Number(days)));

    return newDate;
  }


  handleLeftArrowClick() {
    console.log('this.arrayMap', this.arrayMap);

		this.leftIndex -= 1;
		this.rightIndex -= 1;

    this.splitArray = [];

    let partialList = [];
    for (let i = this.leftIndex; i <= this.rightIndex; i++) {
      partialList.push(this.arrayMap[i]);
    }
    setTimeout(() => {
      this.splitArray = [...partialList];
    }, 1);
    console.log('splitArray', this.splitArray);



//this.timeSlotArray = this.splitArray;

    this.disableRightArrow = false;

    if (this.leftIndex == 0) {
      this.disableLeftArrow = true;
     

    }
    else {
      this.disableLeftArrow = false;


    }

    console.log("this.leftIndex  right", this.leftIndex);
    console.log("this.rightIndex right", this.rightIndex);
    console.log('arraymap size -->', this.arrayMap.length);

  }

 


  /*This method will show slots branch/mobile slots by clicking on date*/
  selectSlot(event) {
    console.log('event click', event.currentTarget.dataset.value);
    this.showSpinner = true;
    this.arreyMap = [];
    const slotDateCheck = event.currentTarget.dataset.datecheck;
    console.log('slotDateCheck', slotDateCheck);
    let date = new Date(slotDateCheck);

    this.selectSlotDate = new Date(date.getTime() - (date.getTimezoneOffset() * 60000)).toISOString();
    console.log('--originalDate in selectSlot-->', this.selectSlotDate);
    console.log('Date is selected')

    let newDateArray = [];
   

    if (this.isMobileLocation == false) {
      getBranchSlots({
        appointmentId: this.appointmentId
      })
        .then((slots) => {
          let dateSort = [];
          console.log('branch slots called method-->::', JSON.stringify(slots));
          console.log('branch slots called method-->::', JSON.stringify(slots.isSuceess));
          console.log('branchslots called method-->::', JSON.stringify(slots.dropOffSlots));
          console.log('branch  called method-->::', JSON.stringify(slots.waitingSlots));

          console.log('slots Length:: ', slots.isSuceess);
          if (slots.isSuceess == false) {
            this.showSpinner = false;
            this.noSlotBoolean = true;
            if (this.noSlotBoolean == true && this.checkPermissionName == true) {
              console.log('check no slot');
              this.noslotcheck = true;
              this.showSpinner = false;
            }
          }
          



          else {

            this.noSlotBoolean = false;
            console.log('false No slot', this.noSlotBoolean);
            if (this.selectedOptionValue == Waiting) {
              dateSort = slots.waitingSlots;
              this.isDropOff = false;
            } else {
              dateSort = slots.dropOffSlots;
              this.isDropOff = true;
            }
            this.finalSlot = dateSort;
            newDateArray = this.showBranchSlots(this.finalSlot, this.selectSlotDate);
          }
          console.log(' this.finalSlot slots ::', this.finalSlot);

        }
        );
    }
    else {
      getMobileSlots({
        appointmentId: this.appointmentId
      })
        .then((slots) => {
          let slotReturnValue = slots[0].isSuceess;
          console.log('getMobileSlots is called')
          console.log('mobile slots called method-->::', slots[0].isSuceess);
          console.log('mobile slots called method-->::', JSON.stringify(slots));

          console.log('slots Length:: ', slots.length);
          console.log('mobile slots msg method-->::', slots[0].msg);
          if (slots[0].msg == "Could not find relevant slots") {
            this.showSpinner = false;
            this.noSlotBoolean = true;
            // FOUK-7148
            console.log('noSlotBoolean', this.noSlotBoolean);
            console.log('checkPermissionName', this.checkPermissionName);
            if (this.noSlotBoolean == true && this.checkPermissionName == true) {
              console.log('check no slot');
              this.noslotcheck = true;
              this.showSpinner = false;
            }

            console.log('inside if', slots[0].msg)
          } else {
            this.noSlotBoolean = false;
            this.finalSlot = slots;
            let mobileSlots = [];

            mobileSlots = this.showMobileSlots(this.finalSlot, this.selectSlotDate);
            console.log('mobileSlots', JSON.stringify(mobileSlots))
          }
        })
    }
    if (this.checkUncheckDateSlot == event.currentTarget.dataset.value) {
      this.checkUncheckDateSlot = event.currentTarget.dataset.value;
    }
    else {
      this.checkUncheckDateSlot = event.currentTarget.dataset.value;
    }
    
  }


  handleCheck(event) {
    if (this.checkUncheck == event.currentTarget.dataset.id) {
      this.checkUncheck = '';
    }
    else {
      this.checkUncheck = event.currentTarget.dataset.id;
    }

  

  }

  hideModalBox() {
    this.isShowModal = false;

    if (this.isShowModal == false) {  
  
      // Update the date  
      updateDate({  
        appointmentId: this.appointmentId,
          arrivalStartAndEndDate: this.selectedSlotApp.slotDateTimeFinish,
          startDate: initialDate
         
      })  
      .then((result) => {  
          console.log('Update Appointment Date Result cancel:', result);  
      })  
      .catch((error) => {  
          console.error('Update Appointment Date cancel Error:', error.body.message); 
          
      });  
  }  
}  




    // this.dispatchEvent(new CustomEvent('close'))
  
  showModalBox() {
    this.isShowModal = false;
    this.ShowCancelForm = true;
  }


  /*This method will be called after clicking on slot value */
  handleSlot(event) {
    this.slotValue = event.target.dataset.id;
    this.slotValueNew = this.slotValue;
    this.startDate = event.target.dataset.startdate;
    this.endDate = event.target.dataset.enddate;
    this.selectSlotDate = this.startDate;
    console.log('slotValue', this.slotValue);
    console.log('this.startDate', this.startDate);
    console.log('this.endDate', this.endDate);

  }

  convertDate(actualDate) {
    const options = {
      year: "numeric",
      month: "long",
      day: "numeric",
    };
    let convertedDate = actualDate.toLocaleDateString("en-US", options);
    return convertedDate;
  }

  /*Re-book code */
  @wire(getRecord, {
    recordId: "$appointmentId", // newly created SA id
    fields
  }) newSADetails;

  

  /*If slot value is present then slot data will be send to parent component */

  extractDateTime(dateTimeString) {
    const dateTimeRegex = /^(.+?) (\d{1,2}:\d{2}-\d{1,2}:\d{2})$/;
    const match = dateTimeString.match(dateTimeRegex);

    if (match) {
      this.datePart = match[1].trim();
      this.timeRange = match[2].trim();

    }
  }
  /*Re-book code END*/

  splitTimeRange(timeRange) {
    const [start, end] = timeRange.split('-').map(time => time.trim());
    this.startTime = start;
    this.endTime = end;
  }

  /*If slot value is present then slot data will be send to parent component */
  handleConfirm(event) {
    console.log('event', event);
    console.log(this.slotValueNew, 'SlotValueNew');
    if (this.slotValueNew === 'none') {
      console.log('oldSltimeRangetDetails in display slots', this.timeRange);
      this.showError = true;
      console.error('Conditions for slot value not met');
      // Uncomment the line below if you intend to set a property
      // this.isDateChange = true;
    }
    else {
      //this.IsModalHide = true;
      this.isDateChange = true;
          this.isRebookingRequestModel = true;
          this.isShowModal = false;
      console.log('this.setProductDataList121212', JSON.stringify(this.setProductDataList));
      let slotSelectedDate = this.convertDate(new Date(this.selectSlotDate));
      console.log('this.isRebooking', this.isRebooking);

      console.log('this.isDropOff in date cmp-->', this.isDropOff);
      console.log('this.startDate in date cmp-->', this.startDate);
      console.log('this.endDate in date cmp-->', this.endDate);
      //FOUK-7148
      if (this.startSelectedTime != null && this.startSelectedTime != undefined && this.startSelectedTime != '' && this.endSelectedTime != null && this.endSelectedTime != undefined && this.endSelectedTime != '') {
        this.slotValue = this.startSelectedTime + '-' + this.endSelectedTime;
        let startSlotDate = this.selectSlotDate.split('T');
        let newSlotDate = new Date(startSlotDate[0] + 'T' + this.startSelectedTime + ':00.000Z').toISOString();
        this.startDate = newSlotDate;
        console.log('newSlotDate', newSlotDate);
        let newEndSlotDate = new Date(startSlotDate[0] + 'T' + this.endSelectedTime + ':00.000Z').toISOString();
        this.endDate = newEndSlotDate;
        this.isDropoff = false;
        console.log('newEndSlotDate', newEndSlotDate);
      }

      /*Re-book code*/
      if (this.oldSlotDetails != '') {
        console.log('oldSlotDetails in display slots', this.oldSlotDetails);
        

        const dateTimeString = this.oldSlotDetails;
        this.extractDateTime(dateTimeString);
        console.log('this.datePart', this.datePart);
        console.log('this.timeRange', this.timeRange);
        let oldDate = new Date(this.datePart);
        let newDate = new Date(slotSelectedDate);

        //trial Code Start
        let timeRange1 = this.slotValue
        let timeRange2 = this.timeRange
        let [start1, end1] = timeRange1.split('-').map(time => {
          const [hours, minutes] = time.split(':');
          return parseInt(hours) * 60 + parseInt(minutes);
        });
        console.log('start1', start1 + '-' + 'end1', end1);

        let [start2, end2] = timeRange2.split('-').map(time => {
          const [hours, minutes] = time.split(':');
          return parseInt(hours) * 60 + parseInt(minutes);
        });
        console.log('start2', start2 + '-' + 'end2', end2);
        //trial Code End

        if (oldDate != newDate || start1 != start2) { //&& end2 != end1

          this.isDateChange = true;
          this.isRebookingRequestModel = true;
          this.isShowModal = false;
          console.log('isDateChange true if', this.isDateChange);
        } else {
          this.isDateChange = false;
          this.isRebookingRequestModel = false;
          this.isShowModal = false;
          console.log('isDateChange true else', this.isDateChange);
        }


      }

      /*Re-book code end*/

      if (this.slotValue != undefined && this.isDateChange == false) {
        this.isDisable = false;

        const selectedDateEvent = new CustomEvent('selecteddata', {
          detail: {
            date: slotSelectedDate, slot: this.slotValue, isDropOff: this.isDropOff,
            startDate: this.startDate, endDate: this.endDate, rebookReasonValue: this.rebookReasonValue,
            rebookSubReasonOptionValue: this.rebookSubReasonOptionValue, isForceAppointment: this.subSection
          }
        });
        


      }
     

    }

  }

  get formattedSlotDate() {
    const date = new Date(this.selectSlotDate);
    const weekday = date.toLocaleDateString('en-US', { weekday: 'short' });
    const day = date.getDate();
    const month = date.toLocaleDateString('en-US', { month: 'short' });
    //  alert(`${weekday} ${day} ${month}`);
    // alert('this.selectSlotDate',this.selectSlotDate);

    return `${ weekday } ${ day } ${ month }`;
  }


  get formattedTime() {
    // Split the selectslot string to extract the start time
    const startTime = this.slotValue.split('-')[0].trim();
    const endTime = this.slotValue.split('-')[1].trim();
    this.starttime = startTime;
    this.endtime = endTime;
    //  alert('starttime=>'+startTime);
    // alert('selectslot=>'+this.slotValue);
    return startTime; // Return the formatted start time
  }


  async handleChangeNow(event) {  
    event.preventDefault(); // Prevent default action if tied to a form submission  
    
    const startTime = this.slotValue.split('-')[0].trim();
    const endTime = this.slotValue.split('-')[1].trim();
    this.starttime = startTime;
    this.endtime = endTime;
    this.isLoadingOKpopup =true;

    console.log('this.appointmentId new2', this.appointmentId);
    console.log('this.starttime new2', this.starttime);
    console.log('this.endtime new2', this.endtime);
    console.log('this.selectSlotDate new2', this.selectSlotDate.split('T')[0]);

    try {  
      const result = await updatenewSA({  
        recordId: this.scaseid,  
      newAppointmentId: this.appointmentId,
      selectslotdate: this.selectSlotDate.split('T')[0],
      starttime: this.starttime,
      endtime: this.endtime,
      oldAppId: this.appId
      });  
    
      console.log('result new2', result);  
     // alert('enter success newappoinmetid 2036');  
      this.okPopup = true;
      this.isDateChange=false;
      this.isLoadingOKpopup =false;
      console.log("okpopup ",this.okPopup)
    
      // Comment out redirection for debugging  
      // let url = `/SelfServe/s/case/${this.caseId}/detail?sid=${this.appointmentId}`;  
      // window.location.href = url;  
    
    } catch (error) {  
      console.log('afterhr Error', JSON.stringify(error));  
    }  
  }  
  
  
  

  // handleChangeNow(event) {
  //   const startTime = this.slotValue.split('-')[0].trim();
  //   const endTime = this.slotValue.split('-')[1].trim();
  //   this.starttime = startTime;
  //   this.endtime = endTime;

  //   console.log('this.appointmentId new2', this.appointmentId);
  //   console.log('this.starttime new2', this.starttime);
  //   console.log('this.endtime new2', this.endtime);
  //   console.log('this.selectSlotDate new2', this.selectSlotDate.split('T')[0]);



   

  //   try {
  //     updatenewSA({
  //       recordId: this.scaseid,
  //       //recordId: this.caseId,
  //       newAppointmentId: this.appointmentId,
  //       selectslotdate: this.selectSlotDate.split('T')[0],
  //       starttime: this.starttime,
  //       endtime: this.endtime,
  //       oldAppId: this.appId
  
  //     })
  //       .then(result => {
  
  //         console.log('result new2', result)
          
  //         // if(result){
  //         //   const event = new CustomEvent('loadpage', {
  //         //     detail: false // You can pass any detail if needed
  //         // });
  //         //this.dispatchEvent(event);
  //         // this.scheduleSa();
  //         alert('enter success newappoinmetid 2036')

  //         })
  //       .catch(err => {
  //         console.log('afterhr Error', JSON.stringify(err));
  //       })
  //       // .finally(() => {
  
  //       //  // alert('enter success newappoinmetid '+this.appoinmetId);
  //       //   // window.location.reload();
  //       // })} catch(err => {
  //       //   console.log('afterhr Error', JSON.stringify(err));
  //       // })
       
  //      // alert('enter success newappoinmetid '+this.appoinmetId);
  //     // let url = '/SelfServe/s/case/';
  //     // url += this.caseId + '/detail' + '?sid=' + this.appointmentId;
  //     // // Navigate to the URL using NavigationMixin
  //     // this[NavigationMixin.Navigate]({
  //     //   type: 'standard__webPage',
  //     //   attributes: {
  //     //     url: url
  //     //   }
  
  //     // });
  //     // window.location.href = url;
      
  
  //     // let url = `/SelfServe/s/case/${this.caseId}/detail?sid=${this.appointmentId}`;  
    
  //     // // Using NavigationMixin to navigate  
  //     // this[NavigationMixin.Navigate]({  
  //     //     type: 'standard__webPage',  
  //     //     attributes: {  
  //     //         url: url  
  //     //     }  
  //     // }, true);  
        
  //     // // Optionally, refresh the page after a short delay  
  //     // setTimeout(() => {  
  //     //     window.location.reload();  
  //     // }, 6000);
  //   } catch (error) {
  //     console.log('error on catch try 2080 ',error)
  //   }

    


  // }
  HandlechangeOK(){
    let url = `/SelfServe/s/case/${this.caseId}/detail?sid=${this.appointmentId}`;
  
    // Using NavigationMixin to navigate  
    this[NavigationMixin.Navigate]({  
        type: 'standard__webPage',  
        attributes: {  
            url: url  
        }  
    }, true);  
  }

  okclose(){
    let url = `/SelfServe/s/`;  
  
    // Using NavigationMixin to navigate  
    this[NavigationMixin.Navigate]({  
        type: 'standard__webPage',  
        attributes: {  
            url: url  
        }  
    }, true); 
  }

  cancel() {
    this.isDateChange = false;
    this.isShowModal = true;
  }



  closeModal() {
    console.log('--closemodal');
    //this.showModal = false;
    this.showModalBk = false;
    console.log('-showModalBk-', this.showModalBk);

  }

  markTrue(event) {
    console.log('check2', event.target.checked)
    this.subSection = event.target.checked;
  }

  generateTimeSlots() {
    let times = [];
    let start = new Date();
    start.setHours(0, 0, 0, 0);

    for (let num = 0; num < 48; num++) {
      let hourCal = start.getHours();
      let texthourcal = hourCal.toString();
      let minutes = start.getMinutes();
      let textminutes = minutes.toString();
      let timeString = `${ texthourcal.padStart(2, "0") }:${ textminutes.padStart(2, "0") }`;
      times.push(timeString);
      start.setMinutes(start.getMinutes() + 30);
      console.log('times', times);
      console.log('start', start);
    }
    this.timeOptions = times.map(time => {
      console.log('timeOptions', this.timeOptions);
      return { label: time, value: time };

    });
  }
  handleStartTime(event) {
    console.log('startSelected', event.target.value);
    this.startSelectedTime = event.target.value;
    console.log(this.startSelectedTime, 'startSelectedTime');
  }


  handleEndTime(event) {
    console.log('EndSelected', event.target.value);
    this.endSelectedTime = event.target.value;
    console.log(this.endSelectedTime, 'EndSelected');

  }
  handleOkay() {
    this.close('okay');
  }
}