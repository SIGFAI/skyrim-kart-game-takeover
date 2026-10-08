Scriptname SigfDemo extends Quest
{The demo: restarts the kart race from the starting grid so the clip opens with the countdown.}

SigfMod Property Mod Auto

Event OnInit()
	if IsRunning()
		RegisterForSingleUpdate(0.5)
	endif
EndEvent

Event OnUpdate()
	Debug.Trace("SIGF_DEMO start")
	Mod.StartRace()
	Utility.Wait(70.0)
	Debug.Trace("SIGF_DEMO end")
EndEvent
