public with sharing class RaceResultsController 
{
	@RemoteAction
	public static List<RaceServiceResults.ProvisionalResult> loadProvisionalResults(Id raceId)
	{
		return RaceService.calculateProvisionResults(
			new Set<Id> { raceId }).get(raceId);
	}

	@RemoteAction
	public static void saveConfirmedResults(Id raceId, List<RaceServiceResults.ProvisionalResult> results)
	{
		RaceService.applyRaceResults(
			new Map<Id, List<RaceServiceResults.ProvisionalResult>> { raceId => results});
	}	
}