Scriptname SigfTracked extends Actor
{Attach to your Npc records in plugin.json (scripts: name SigfTracked, property Tag): every death writes SIGF_KILL <Tag> to the Papyrus log, which QA counts.}

string Property Tag = "sigf" Auto

Event OnDeath(Actor akKiller)
	Debug.Trace("SIGF_KILL " + Tag)
EndEvent
