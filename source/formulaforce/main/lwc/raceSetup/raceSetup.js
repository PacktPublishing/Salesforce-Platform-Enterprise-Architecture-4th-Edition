import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { publish, MessageContext } from 'lightning/messageService';
import refreshView from '@salesforce/messageChannel/RefreshView__c';

import getDriverList from '@salesforce/apex/RaceSetupComponentController.getDriverList';
import addDrivers from '@salesforce/apex/RaceSetupComponentController.addDriversLwc';

const columns = [
    { label: 'Driver', fieldName: 'Name' }
];

export default class RaceSetup extends LightningElement {
    @api
    recordId;
    @wire(getDriverList)
    drivers;
    columns = columns;
    @wire(MessageContext)
    messageContext;    

    handleCancel() {
        // Close modal
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleAddDrivers() {
        // Construct list of selected drivers
        var selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        var selectedDrivers = [];
        selectedRows.forEach(element => {
            selectedDrivers.push(element.RecordId);
            });
        // Call Apex controller methods to add drivers
        addDrivers(
                { raceId : this.recordId, 
                  driversToAdd : selectedDrivers  })
            .then(result => {
                // Send toast confirmation to user
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Add Drivers',
                        message: 'Add ' + result + ' drivers.',
                        variant: 'success',
                    }));
                // Close modal
                this.dispatchEvent(new CloseActionScreenEvent());
                // Send Refresh View message to RefreshView component (must be on page)
                publish(this.messageContext, refreshView, {});
            })
            .catch(error => {
                // Send toast confirmation to user
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Add Drivers',
                        message : error.body.message,
                        variant: 'error',
                    }));
            });            
    }
}