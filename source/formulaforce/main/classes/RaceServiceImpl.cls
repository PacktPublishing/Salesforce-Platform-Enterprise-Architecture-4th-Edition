public inherited sharing class RaceServiceImpl implements IRaceService {
    
    public Map<Id, List<RaceServiceResults.ProvisionalResult>> calculateProvisionResults(Set<Id> raceIds) {           
        throw new RaceServiceException('Not implemented');
    }

    public void applyRaceResults(Map<Id, List<RaceServiceResults.ProvisionalResult>> provisionalResultsByRaceId) {
        throw new RaceServiceException('Not implemented');
    }

    public void awardChampionshipPoints(Set<Id> raceIds) {
        
        // Awarding championships points should only be done by this class on behalf of the user
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(AccessLevel.SYSTEM_MODE);

        // Query Races and contestants and bulkify list of all contestants
        List<Contestant__c> contestants = new List<Contestant__c>();
        for(Race__c race : new RacesSelector().selectByIdWithContestants(raceIds)) {
            contestants.addAll(race.Contestants__r);            
        }
        
        // Delegate to Contestant Domain class
        new Contestants(contestants).awardChampionshipPoints(uow);

        // Send event notifying the press that the results are published
        uow.registerPublishBeforeTransaction(
            new RaceNewsFeed__e(
                Category__c = 'Race News', 
                Content__c = 'Championship points have been officially calculated'));

        // Commit work
        uow.commitWork();
    }
    
	public String generateSummaryAsCSV(Set<Id> raceIds)
	{ 
		// Query summaries via custom selector method
		Map<Id, List<ContestantsSelector.Summary>> summariesByRaceId = 
			new ContestantsSelector().selectByRaceIdWithContestantSummary(raceIds);
        List<ContestantsSelector.Summary> allSummaries = new List<ContestantsSelector.Summary>();
        for(List<ContestantsSelector.Summary> summaries : summariesByRaceId.values()) {
            allSummaries.addAll(summaries);
        }

        // Load and run the DataWeave script to convert all the summaries to CSV
        DataWeave.Script dwscript = DataWeave.Script.createScript('raceSummaryToCsv');
        DataWeave.Result dwresult = dwscript.execute(new Map<String, Object>{'records' => allSummaries});
		return (String) dwresult.getValue();
	}
	
    public Map<Id, Integer> addDrivers(Map<Id, List<Id>> driversByRaceId) {
        
        // TODO: Provide a means to determine drivers current car for the season
        List<Car__c> cars = new CarsSelector().selectAll();
        if(cars.size()==0) {
            throw new RaceService.RaceServiceException('Must have at least one Car record in the system');          
        }        
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
 
        // Create Contestant__c records for each Driver for the given Race
        Map<Id, Integer> addedDriversByRace = new Map<Id, Integer>();
        for(Id raceId : driversByRaceId.keySet()) {
            for(Id driverId : driversByRaceId.get(raceId)) {
                Contestant__c contestant = new Contestant__c();
                contestant.Race__c = raceId;
                contestant.Driver__c = driverId;
                contestant.Car__c = cars[0].Id;
                uow.registerNew(contestant);                
            }
            addedDriversByRace.put(raceId, driversByRaceId.get(raceId).size());
        }       
 
        // Commit work
        uow.commitWork();
        
        return addedDriversByRace;
    }	
}