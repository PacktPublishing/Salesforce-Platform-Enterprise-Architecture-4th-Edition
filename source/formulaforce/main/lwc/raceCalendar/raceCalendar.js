import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { publish, MessageContext } from 'lightning/messageService';
import refreshRaceResults from '@salesforce/messageChannel/RefreshRaceResults__c';
import getRaceCalendar from '@salesforce/apex/RaceCalendarComponentController.getRaceCalendar';

export default class RaceCalendar extends LightningElement {

    @wire(CurrentPageReference)
    pageRef;
    @wire(getRaceCalendar)
    calendar;
    currentlySelectedRate;
    @wire(MessageContext)
    messageContext;    

    handleSelect(event) {
        // Determine selected Race details
        const raceId = event.detail;
        const selectedRace = this.calendar.data.find(race => race.Id === raceId);
        const raceName = selectedRace.Name;
        // Toggle selected Race
        if(this.currentlySelectedRate!=null) {
            this.currentlySelectedRate.selected = false;
        }
        this.currentlySelectedRate = event.currentTarget;
        this.currentlySelectedRate.selected = true;
        // Send refreshRaceResults component message 
        const payload = { raceId: raceId, raceName: raceName };
        publish(this.messageContext, refreshRaceResults, payload);
    }
}