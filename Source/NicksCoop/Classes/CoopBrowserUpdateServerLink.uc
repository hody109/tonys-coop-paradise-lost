class CoopBrowserUpdateServerLink extends UTBrowserUpdateServerLink;

function SetupURIs()
{
	Super.SetupURIs();

	// We need to override only MOTD
	URIs[3] = "/p2mp/p2_motd.html";
}

defaultproperties
{
	UpdateServerAddress="developerfuntime.com"
}