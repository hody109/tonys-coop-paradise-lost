//=============================================================================
// CoopMatineeCamera.uc
// - 2016 - rework
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015-2016.
//=============================================================================

class CoopMatineeCamera extends Actor
	notplaceable;

const NET_UPDATE_MAX_FREQ = 300;

var bool bNETUpdateViewport;

var vector NETLocation;
var rotator NETRotation;
var vector OldNETLocation;
var rotator OldNETRotation;

var float NETLocInterpFactor;
var float NETRotInterpFactor;

var Texture BlackBackground;

var string sDebugStr;

replication
{
	unreliable if( Role == ROLE_Authority )
		bNETUpdateViewport, NETLocation, NETRotation;
}

simulated function Tick(float DeltaTime)
{
	if( bNETUpdateViewport )
	{
		if( NetUpdateFrequency != NET_UPDATE_MAX_FREQ )
			NetUpdateFrequency = NET_UPDATE_MAX_FREQ;

		NETGetServerData(DeltaTime);
		NETApplyServerData(DeltaTime);
	}
	else
	{
		if( NetUpdateFrequency != default.NetUpdateFrequency )
			NetUpdateFrequency = default.NetUpdateFrequency;
	}
}

simulated function NETGetServerData(float DeltaTime)
{
	if( Role == ROLE_Authority )
	{
		if( Owner != None )
		{
			NETLocation = Owner.Location;
			NETRotation = Owner.Rotation;

			if( VSize(Owner.Location-Location) > 8 )
			{
				SetLocation(Owner.Location);
				SetRotation(Owner.Rotation);
				SetBase(Owner);
			}
		}
	}
}

simulated function NETApplyServerData(float DeltaTime)
{
	if( Role < ROLE_Authority )
		UpdateSimulatedPosition(DeltaTime);
}

///steam 21/03/2017
static final function rotator xRotatorSpringInterpFixed(rotator Dest, rotator Current, float Delta, optional float SpringConst)
{
	local rotator ScrollDelta, ScrollAccel, ScrollVel;

	if(SpringConst == 0)
		SpringConst = 2048.f;

	ScrollDelta = Normalize(Dest - Current);
	ScrollAccel = SpringConst * ScrollDelta;
	ScrollVel = ScrollAccel * Delta;
	return (Current + ScrollVel * Delta);
}

///steam 25/07/2016
simulated function UpdateSimulatedPosition(float DeltaTime)
{
	local float fLocDiff;
	local float fRotDiff;
	local rotator rRotDiff;
	local vector LocInterpStep;
	local rotator RotInterpStep;
	local bool bNoRotUpd;

	bNoRotUpd = false;

	fLocDiff = FMax(VSize(NETLocation-Location),4);
	if( fLocDiff > 150 )///150
	{
		SetLocation(NETLocation);
		SetRotation(NETRotation);
		bNoRotUpd = true;
	}
	else if( fLocDiff > 4 )
	{
		if( NETLocation != OldNETLocation )
			NETLocInterpFactor = (fLocDiff*30)+5;//30,5
		LocInterpStep = VectorSpringInterp(NETLocation, Location, DeltaTime, NETLocInterpFactor);
		SetLocation(LocInterpStep);
	}

	if( !bNoRotUpd )
	{
		rRotDiff = Normalize((Normalize(NETRotation)-Normalize(Rotation)));
		fRotDiff = FMax((abs(rRotDiff.Yaw)+abs(rRotDiff.Roll)+abs(rRotDiff.Pitch))/3,4);
		if( fRotDiff > 4096 )///8192
		{
			SetRotation(NETRotation);
		}
		else if( fRotDiff > 4 )
		{
			if( NETRotation != OldNETRotation )
			{
				if( fRotDiff > 2048 )
					NETRotInterpFactor = fRotDiff*0.8;//fRotDiff/2;
				else NETRotInterpFactor = (fRotDiff/4)+5;
			}
			///sDebugStr = "fLocDiff:"@fLocDiff@"fRotDiff:"@fRotDiff;
			RotInterpStep = xRotatorSpringInterpFixed(NETRotation, Rotation, DeltaTime, NETRotInterpFactor);
			SetRotation(RotInterpStep);
		}
	}

	OldNETLocation = NETLocation;
	OldNETRotation = NETRotation;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	/*local float XL;

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.StrLen("TEST", XL, YL);
	Canvas.SetDrawColor(200,200,200,255);

	YPos = 4;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText("Rotation:");
	YPos += YL;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText(Rotation);

	YPos += YL;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText("NETRotation:");
	YPos += YL;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText(NETRotation);

	YPos += 2*YL;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText("Location:");
	YPos += YL;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText(Location);

	YPos += YL;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText("NETLocation:");
	YPos += YL;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText(NETLocation);

	YPos += 2*YL;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText("NETLocInterpFactor:");
	YPos += YL;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText(NETLocInterpFactor);

	YPos += YL;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText("NETRotInterpFactor:");
	YPos += YL;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText(NETRotInterpFactor);

	if( sDebugStr != "" )
	{
		YPos += 2*YL;
		Canvas.SetPos(4, YPos);
		Canvas.DrawText("sDebugStr:"@sDebugStr);
	}*/

	//DrawCinematicFrames(Canvas);
}

simulated function DrawCinematicFrames(Canvas Canvas)
{
	Canvas.bCenter = false;
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.SetPos(0,0);
	Canvas.DrawTile(BlackBackground, Canvas.SizeX,Canvas.SizeY/5,0,0,1.0, 1.0);

	Canvas.bCenter = false;
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.SetPos(0,Canvas.SizeY-Canvas.SizeY/5);
	Canvas.DrawTile(BlackBackground, Canvas.SizeX,Canvas.SizeY,0,0,1.0, 1.0);
}

///steam 02/08/2016
simulated event FellOutOfWorld()
{
	///STUBED
}

defaultproperties
{
	NETRotInterpFactor=2048.0
	BlackBackground=Texture'nathans.Inventory.blackbox64'

	RemoteRole=ROLE_SimulatedProxy
	NetPriority=3.0
	NetUpdateFrequency=150
	bSkipActorPropertyReplication=false
	bReplicateMovement=false
	bAlwaysTick=true
	bReplicateInstigator=true

	bIgnoreOutOfWorld=true
	bAlwaysRelevant=true
	bBlockActors=false
	bBlockNonZeroExtentTraces=false
	bBlockZeroExtentTraces=false
	bBlockPlayers=false
	bCollideActors=false
	bCollideWorld=false
	bProjTarget=false

	bDirectional=true
	bGameRelevant=true
	bMovable=true
	bStasis=false
	bWorldGeometry=false
	bNoDelete=false
	bHidden=false
	Mass=0.0

	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Engine.InterpCamera_SM'
	Skins(0)=Shader'Timb.Misc.invisible_mask'
	bUnlit=true
	DrawScale=1.00
}