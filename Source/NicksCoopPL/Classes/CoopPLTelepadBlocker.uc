class CoopPLTelepadBlocker extends CoopTelepadBlocker;
var bool bPLOpen;
var bool bPLAppliedOpen;

replication
{
    reliable if(Role==ROLE_Authority) bPLOpen;
}

simulated event Tick(float Delta)
{
    // Apply the same wall state to client prediction and server movement.
    if(Role<ROLE_Authority && bPLAppliedOpen!=bPLOpen)
    {
        bPLAppliedOpen=bPLOpen;
        SetCollision(!bPLOpen,!bPLOpen,!bPLOpen);
    }
}

function TravelAccessControl(bool Granted)
{
    if(bPLOpen==Granted) return;
    bPLOpen=Granted;
    if(Granted)
    {
        // Remove the wall before enabling Touch callbacks on its telepad.
        SetCollision(false,false,false);
        bHidden=true;
        ControlTelepadCollision(true);
    }
    else
    {
        ControlTelepadCollision(false);
        SetCollision(true,true,true);
        bHidden=false;
    }
    Log("PLTRAVEL|gate|open=" $ Granted $ "|pad=" $ Owner);
}
function Timer()
{
	local float fCollRadius;
	if( nFrame < TimerFrameTex.Length )
	{
		Texture = TimerFrameTex[nFrame];
		SetTimer(FrameTime, false);
		nFrame++;
	}
	else if( bSentinel )
	{
		Sentinel = spawn(class'CoopPLTravelSentinel',self,,Location);
		if( Sentinel != None )
		{
			if( CollisionRadius >= 1800 )
				fCollRadius = CollisionRadius*1.1;
			else if( CollisionRadius >= 900 )
				fCollRadius = CollisionRadius*1.2;
			else if( CollisionRadius >= 400 )
				fCollRadius = CollisionRadius*1.3;
			else fCollRadius = CollisionRadius*1.6;

			Sentinel.SetCollisionSize(fCollRadius, CollisionHeight*1.1);
			Texture = SentinelStatusTex;
			bHidden = true;
		}
		else CallSafeDestroy();
	}
	else CallSafeDestroy();
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=True
}

