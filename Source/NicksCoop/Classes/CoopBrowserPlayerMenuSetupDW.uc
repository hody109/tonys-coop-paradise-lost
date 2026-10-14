//=============================================================================
// CoopBrowserPlayerMenuSetupDW.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserPlayerMenuSetupDW extends UWindowDialogClientWindow;

var bool bDummyZoomRequest;
var bool bDummySizeUpdate;

var Texture InFrameBackTex;

var CoopBrowserPlayerMenuSetupDummy SetupDummyActor;

var localized string DummyWindowZoomInText;
var localized string DummyWindowZoomOutText;

function Created()
{
	local PlayerController PC;

	PC = root.ViewportOwner.Actor;
	if( SetupDummyActor == None )
		SetupDummyActor = PC.Spawn(class'CoopBrowserPlayerMenuSetupDummy', PC);
}

function SetDummySkin(string NewSkin)
{
	local Material NewSkinMaterial;

	if( SetupDummyActor != None && NewSkin != "" )
	{
		NewSkinMaterial = Material(DynamicLoadObject(NewSkin, class'Material'));
		SetupDummyActor.Skins[0] = NewSkinMaterial;
	}
}

///steam 25/11/2016
function SetDummyMesh(Mesh NewMesh)
{
	if( SetupDummyActor != None && NewMesh != None )
		SetupDummyActor.LinkMesh(NewMesh);
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	if( SetupDummyActor != None )
	{
		SetupDummyActor.Destroy();
		SetupDummyActor = None;
	}
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, Y, fFovAngle;
	local PlayerController PC;
	///local Actor ViewTarget;
	local rotator CameraRotation;
	local vector CameraLocation;
	local vector DummyPos;
	local vector DummyDir;
	local rotator DummyRot;
	local vector DummyFrame;

	C.SetDrawColor(255, 255, 255);
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
	C.SetDrawColor(250, 250, 250);
	DrawStretchedTexture(C, 4, 4, WinWidth-8, WinHeight-8, InFrameBackTex);

	if( SetupDummyActor != None && P2RootWindow(Root).IsMenuShowing() )
	{
		C.Style = 1; //ERenderStyle.STY_Normal;
		C.SetDrawColor(255, 255, 255);

		fFovAngle = 90;
		PC = root.ViewportOwner.Actor;
		if( PC != None )
			fFovAngle = PC.FovAngle;
		///PC.PlayerCalcView(ViewTarget, CameraLocation, CameraRotation);
		C.GetCameraLocation(CameraLocation, CameraRotation);

		//WindowToGlobal(WinWidth, WinHeight, X, Y);
		X = C.OrgX;
		Y = C.OrgY;
		DummyPos.X = X+(WinWidth*0.5);
		DummyPos.Y = Y+(WinHeight*0.5);
		DummyPos = C.ScreenToWorld(DummyPos);
		DummyPos *= 2*(85/fFovAngle);

		//C.Font = Root.Fonts[F_Normal];
		//C.SetDrawColor(0, 0, 0);
		//ClipText(C, MouseX, MouseY, "Zoom");

		DummyDir = vect(-1,0,0) >> CameraRotation;

		SetupDummyActor.SetLocation(DummyPos+CameraLocation);
		SetupDummyActor.SetRotation(Rotator(DummyDir));

		DummyRot = rot(0,0,65535)*(MouseX/WinWidth);
		SetupDummyActor.SetBoneRotation('MALE01 pelvis', DummyRot, 0, 1);

		if( !SetupDummyActor.bReachFrameSize && (bDummySizeUpdate || SetupDummyActor.ScreenWidth != C.SizeX) )
		{
			if( SetupDummyActor.ScreenWidth != C.SizeX )
			{
				DummyFrame.X = X;
				DummyFrame.Y = Y;
			}
			else
			{
				if( bDummyZoomRequest )
				{
					DummyFrame.X = X+(WinWidth*0.5)+(C.SizeX*0.5);
					DummyFrame.Y = Y+(WinHeight*0.5)+(C.SizeY*0.5);
				}
				else
				{
					DummyFrame.X = X;
					DummyFrame.Y = Y;
				}
			}
			DummyFrame = C.ScreenToWorld(DummyFrame);
			DummyFrame *= 2*(85/fFovAngle);

			SetupDummyActor.FrameSize = VSize(DummyPos-DummyFrame)*0.5;
			if( SetupDummyActor.OldFrameSize == 0 || SetupDummyActor.ScreenWidth != C.SizeX )
			{
				SetupDummyActor.SetDrawScale(SetupDummyActor.default.DrawScale);
				SetupDummyActor.OldFrameSize = 0;
				bDummyZoomRequest = false;
			}
			SetupDummyActor.ScreenWidth = C.SizeX;
			SetupDummyActor.bReachFrameSize = true;
			bDummySizeUpdate = false;
		}

		C.DrawActor(SetupDummyActor, false, true, fFovAngle);

		C.Font = Root.Fonts[F_Normal];
		C.SetDrawColor(0, 0, 0);
		if( !bDummyZoomRequest )
			ClipText(C, MouseX-8, MouseY-8, DummyWindowZoomInText);
		else ClipText(C, MouseX-8, MouseY-8, DummyWindowZoomOutText);
	}
}

simulated function Click(float X, float Y) 
{
	if( SetupDummyActor != None && !SetupDummyActor.bReachFrameSize && !bDummySizeUpdate )
	{
		bDummySizeUpdate = true;
		bDummyZoomRequest = !bDummyZoomRequest;
	}
	/*if( InFrameBackTex == default.InFrameBackTex )
		InFrameBackTex = Texture'BlackTexture';
	else InFrameBackTex = default.InFrameBackTex;*/
}

defaultproperties
{
	DummyWindowZoomInText="Zoom in"
	DummyWindowZoomOutText="Zoom out"

	//InFrameBackTex=Texture'Editor.BkgndHi'
	//InFrameBackTex=Texture'P2Misc.Background.flames'
	//InFrameBackTex=Texture'Editor.Bkgnd'
	InFrameBackTex=Texture'Engine.ConsoleBdr'
}