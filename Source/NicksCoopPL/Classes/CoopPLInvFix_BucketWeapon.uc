//=============================================================================
// CoopPLInvFix_BucketWeapon.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLInvFix_BucketWeapon extends BucketWeapon;

var PLCowPawn ClientMilkingCow;
var float ClientCowMilk;
var float ClientCowMilkMax;

replication
{
	unreliable if( Role == ROLE_Authority )
		ClientMilkingCow , ClientCowMilk , ClientCowMilkMax;

	// functions client sends to server
	reliable if (Role < ROLE_Authority)
		xCallEndStream;
}

function xCallEndStream()
{
	GotoState('EndStream');
}

simulated state Streaming
{
	simulated function RenderOverlays(Canvas Canvas)
	{
		local float ScreenX, ScreenY, Width, Height, Border, Perc;

		if( Instigator != None && Instigator.Controller != None && Instigator.Controller.Buoyancy == 75 )
		{
			Super.RenderOverlays(Canvas);
			return;
		}

		if( ClientMilkingCow != None
			&& ClientCowMilkMax > 0 )
		{
			ScreenX = Canvas.SizeX/2;
			ScreenY = Canvas.SizeY*4/5;
			Width = Canvas.SizeX/4;
			Height = Canvas.SizeY/20;
			Border = 2;
			Perc = ClientCowMilk / ClientCowMilkMax;
			DrawPercBar(Canvas, ScreenX, ScreenY, Width, Height, Border, ProgressBarColor, Perc);
		}
		Super.RenderOverlays(Canvas);
	}

	simulated function Tick( float DeltaTime )
	{
		if( AmmoType != None && !AmmoType.bDeleteMe )
		{
			if (AmmoType.AmmoAmount > 0.75*AmmoType.MaxAmmo)
				Skins[MILK_TEX_INDEX] = MilkTex;
		}
		// Cut immediately if you stop early
		if( NotDedOnServer() )
		{
			if( Instigator==None || !Instigator.PressingFire() )
			{
				xCallEndStream();
				GotoState('EndStream');
			}
		}
		else
		{
			// Find a cow and milk it
			MilkACow(DeltaTime);
		}
	}

	simulated function EndState()
	{
		Super.EndState();
	}

	simulated function BeginState()
	{
		Super.BeginState();
	}
Begin:
	// Null out streaming sounds, we only want them to play when the dude is milking
	Sleep(1.0);
	// If the dude tries to milk an "empty" cow for longer than a second, have him comment on it
	bCowEmpty = false;
}

function MilkACow(float DeltaTime)
{
	if( MilkingCow != None && !MilkingCow.bDeleteMe )
	{
		ClientMilkingCow = MilkingCow;
		ClientCowMilk = MilkingCow.CowMilk;
		ClientCowMilkMax = MilkingCow.CowMilkMax;
	}
	else ClientMilkingCow = None;

	Super.MilkACow(DeltaTime);
}

function GiveTo(Pawn Other)
{
	Super.GiveTo(Other);
	if( CoopGameInfo(Level.Game) != None 
		&& CoopGameInfo(Level.Game).CoopIsMap("PL-MEADOW") )
	{
		P2AmmoInv(AmmoType).bShowAmmoOnHud = true;
		P2AmmoInv(AmmoType).bShowMaxAmmoOnHud = true;
		P2AmmoInv(AmmoType).bShowAmmoAsPercent = true;
		AmmoType.AmmoAmount = 0;
		AmmoType.MaxAmmo = 45;//MilkRequired;
		Event = 'MilkingGameCompleted';//CompletedEvent;
		SecondaryMilkRequired = 15;//MilkRequiredSecondary;
		SecondaryEvent = 'Cutscene_02_MadCows';//SecondaryEvent;
	}
}

defaultproperties
{
	ThirdPersonRelativeLocation=(X=-25.0,Y=-15.0,Z=40.0)
	AttachmentClass=class'CoopPLInvFix_BucketAttachment'
	AmmoName=class'CoopPLInvFix_BucketAmmoInv'
}
