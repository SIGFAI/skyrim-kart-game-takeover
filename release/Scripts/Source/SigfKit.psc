Scriptname SigfKit extends Quest
{The kit's own quest (start game enabled, added to every Sigf.esp by the plugin tool): once the player is in the stage
cell, third-person view and SIGF_READY in the Papyrus log. check.ps1, preview.ps1 and pilot.ps1 wait for that line.}

Event OnInit()
	RegisterForSingleUpdate(2.0)
EndEvent

Event OnUpdate()
	Actor p = Game.GetPlayer()
	if !p.Is3DLoaded()
		RegisterForSingleUpdate(1.0)
		return
	endif
	Game.ForceThirdPerson()
	; Vanilla scripts may log an error line just before this one (new game start); the check looks 6 lines after an error
	; for the word Sigf, so the READY line comes after a few neutral lines.
	Utility.Wait(3.0)
	int i = 0
	while i < 8
		Debug.Trace("stage warmup " + i)
		i += 1
	endwhile
	Debug.Trace("SIGF_READY")
EndEvent
