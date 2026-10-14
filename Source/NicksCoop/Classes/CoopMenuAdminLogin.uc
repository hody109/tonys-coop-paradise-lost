//=============================================================================
// CoopMenuAdminLogin.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopMenuAdminLogin extends MenuAdminLogin;

function Login()
{
	if( PasswordControl.GetValue() != "" )
	{
		CoopPlayerController(GetPlayerOwner()).NETGotAdminInv(PasswordControl.GetValue());
	}
	Super.Login();
}

defaultproperties
{
	//MenuWidth	= 400
	//PasswordText= "Password"
	//LoginText	= "Login"
}
