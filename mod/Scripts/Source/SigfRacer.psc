Scriptname SigfRacer extends Actor
{A kart driver. SigfMod drives the kart and the animal along the circuit; this script only reports kills.}

string Property Tag = "racer" Auto

Event OnDeath(Actor akKiller)
	Debug.Trace("SIGF_KILL " + Tag)
EndEvent
