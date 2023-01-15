global with sharing class ContestantService {
       
	public static void awardChampionshipPoints(Set<Id> contestantIds) {
	    
        // Awarding championships points should only be done by this class on behalf of the user
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(AccessLevel.SYSTEM_MODE);

		// Apply championship points to given contestants		
		Contestants contestants = 
			new Contestants(
				new ContestantsSelector().selectById(contestantIds));
		contestants.awardChampionshipPoints(uow);

		uow.commitWork();
	}

	public static void retireFromRace(List<RaceRetirement> retirements) {
		throw new ContestantServiceException('Not implemented');
	}

	public class RaceRetirement {
		public Id contestantId;
		public String reason;
	}
		
	global interface IAwardChampionshipPoints
	{
		void calculate(List<Contestant__c> contestants);
	}	
}