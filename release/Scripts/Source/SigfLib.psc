Scriptname SigfLib Hidden
{The Skyrim kit's bricks for stream mods: global functions, call them as SigfLib.Spawn(...). NEVER COMPILED YET.
Distances in game units (a human is about 128 units tall, 64 units = 1 yard). Angles in degrees, 0 = north.
"Front" means in front of the player's facing, which is where the third-person camera looks.}

; ---------- log (the operators' check and QA read these lines in the Papyrus log) ----------

Function Log(string msg) global
	Debug.Trace("SIGF " + msg)
EndFunction

; A problem the mod itself detected: fails the kit check.
Function Error(string msg) global
	Debug.Trace("SIGF_ERROR " + msg)
EndFunction

; ---------- places ----------

; A marker dist units in front of the player, side units to the right (negative = left), on the player's height.
ObjectReference Function Front(float dist = 400.0, float side = 0.0) global
	Actor p = Game.GetPlayer()
	float a = p.GetAngleZ()
	ObjectReference m = p.PlaceAtMe(Game.GetFormFromFile(0x0000003B, "Skyrim.esm")) ; XMarker
	m.MoveTo(p, dist * Math.Sin(a) + side * Math.Cos(a), dist * Math.Cos(a) - side * Math.Sin(a), 0.0)
	return m
EndFunction

; ---------- spawning (each spawn writes SIGF_SPAWN <tag>: the QA test play looks for it) ----------

; An actor (your Npc record, or a vanilla one) in front of the player, turned to face the player.
Actor Function Spawn(ActorBase who, string tag, float dist = 400.0, float side = 0.0) global
	ObjectReference m = Front(dist, side)
	Actor a = m.PlaceAtMe(who) as Actor
	m.Delete()
	if !a
		Error("Spawn " + tag + ": nothing placed")
		return None
	endif
	FaceTo(a, Game.GetPlayer())
	Debug.Trace("SIGF_SPAWN " + tag)
	return a
EndFunction

; Any placeable thing (weapon or item on the ground, static, activator, light, explosion...) in front of the player.
ObjectReference Function Place(Form what, string tag, float dist = 300.0, float side = 0.0, float up = 0.0) global
	ObjectReference m = Front(dist, side)
	ObjectReference r = m.PlaceAtMe(what)
	m.Delete()
	if !r
		Error("Place " + tag + ": nothing placed")
		return None
	endif
	if up != 0.0
		r.MoveTo(r, 0.0, 0.0, up)
	endif
	Debug.Trace("SIGF_SPAWN " + tag)
	return r
EndFunction

; ---------- actors ----------

Function FaceTo(ObjectReference who, ObjectReference target) global
	who.SetAngle(0.0, 0.0, who.GetAngleZ() + who.GetHeadingAngle(target))
EndFunction

; The player turns to look at something (the third-person camera follows).
Function Look(ObjectReference target) global
	FaceTo(Game.GetPlayer(), target)
EndFunction

; Two actors fight each other.
Function Fight(Actor a, Actor b) global
	a.StartCombat(b)
	b.StartCombat(a)
EndFunction

; Gives the player a weapon (or anything) and equips it.
Function Arm(Form item) global
	Actor p = Game.GetPlayer()
	p.AddItem(item, 1, true)
	p.EquipItem(item, false, true)
EndFunction

; ---------- effects ----------

Function Boom(ObjectReference at, Explosion e) global
	at.PlaceAtMe(e)
EndFunction

Function Play(Sound s, ObjectReference at) global
	s.Play(at)
EndFunction

Function Shake(float strength = 0.5, float seconds = 1.0) global
	Game.ShakeCamera(None, strength, seconds)
EndFunction

; Shader on an actor or object (glow, fire, frost...), seconds < 0 = until stopped.
Function Glow(ObjectReference who, EffectShader fx, float seconds = 3.0) global
	fx.Play(who, seconds)
EndFunction

; Casts a spell from a source at a target (an actor, or a marker from Front()).
Function Cast(Spell s, ObjectReference source, ObjectReference target) global
	s.Cast(source, target)
EndFunction

; Top-left notification (Skyrim has no big title text without SKSE or a custom menu).
Function Say(string text) global
	Debug.Notification(text)
EndFunction
