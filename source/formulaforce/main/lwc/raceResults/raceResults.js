import { LightningElement, api, wire, track } from 'lwc';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import refreshRaceResults from '@salesforce/messageChannel/RefreshRaceResults__c';
import getRaceResults from '@salesforce/apex/RaceResultsComponentController.getRaceResults';

const columns = [
    { label: 'Driver', fieldName: 'Driver' },
    { label: 'Team', fieldName: 'Team' },
    { label: 'Grid', fieldName: 'Grid', type: 'number', fixedWidth: 70 },
    { label: 'Race Time', fieldName: 'RaceTime' },
    { label: 'Points', fieldName: 'Points', type: 'number', fixedWidth: 100 }
];

export default class RaceResults extends LightningElement {

    // Public properties
    @api
    recordId;

    // Internal properties
    subscription = null;
    @wire(MessageContext)
    messageContext;    
    @wire(getRaceResults, { raceId: '$recordId' })
    results;
    @track
    columns = columns;
    @track
    raceName = '';
    get raceTitle() {
        return 'Results ' + this.raceName;
    }

    /**
     * Listen to raceSelected component event to update the race results
     */
    connectedCallback() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                refreshRaceResults,
                (message) => this.handleRaceSelected(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }    
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    /**
     * Update the bound raceId to the @wire to refresh race details
     * @param {} message 
     */
    handleRaceSelected(message) {
        this.recordId = message.raceId;
        this.raceName = message.raceName;
    }
}