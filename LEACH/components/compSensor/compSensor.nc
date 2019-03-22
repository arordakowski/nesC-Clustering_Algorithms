
interface compSensor {
	command GetCHElectionParams();
	command GetJoinParams();
	command AddNeighbor();
	command AddProbe();
	command AddCandidateCH();
	command AddCandidateMember();
	command ManageRoundCommand();
	command ProcessMessage();
	command ResendStartFlooding();
}
