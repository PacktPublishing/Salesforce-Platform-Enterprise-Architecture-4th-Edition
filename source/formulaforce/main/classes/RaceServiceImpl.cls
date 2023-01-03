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

        // Commit work
        uow.commitWork();
    }

}