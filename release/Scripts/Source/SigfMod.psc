Scriptname SigfMod extends Quest
{Kart Game Takeover: a kart circuit appears in the meadow east of Riverwood's bridge. The player rides a red kart, four animal
drivers race against it, "?" item boxes give homing shells, banana peels and turbo boosts.}

Static Property SigfKartRed Auto
Static Property SigfKartBlue Auto
Static Property SigfKartGreen Auto
Static Property SigfKartPurple Auto
Static Property SigfQBox Auto
Static Property SigfBanana Auto
Static Property SigfShell Auto
ActorBase Property SigfFoxRacer Auto
ActorBase Property SigfElkRacer Auto
ActorBase Property SigfChickenRacer Auto
ActorBase Property SigfGoatRacer Auto
Explosion Property SigfBlast Auto
Explosion Property SigfDustMed Auto
Explosion Property SigfDustSm Auto
EffectShader Property FireFXTrapShader Auto
EffectShader Property ShockFXShader Auto

int Property RACERS = 5 AutoReadOnly
int Property LAPS_TO_WIN = 3 AutoReadOnly

bool started = false
bool running = false
bool finished = false
float trackLen
float step
float[] tx
float[] ty
float[] tz
float[] th

Actor[] drv
ObjectReference[] kart
string[] names
float[] prog
float[] lane
float[] baseSpeed
float[] spinLeft
float[] spinAng
float[] boostLeft
float[] lastAng
bool[] wrecked

ObjectReference[] boxes
float[] boxRespawn
float[] boxS
float[] boxLane
ObjectReference[] bananas
float[] banAge
int[] banOwner
ObjectReference[] shells
int[] shellTarget
float[] shellAge

int tickN = 0
int pItem = 0
float restartClock = 0.0
float lastT = 0.0
int gen = 0
float curSpeed = 300.0

Event OnInit()
	if IsRunning() && !started
		started = true
		Utility.Wait(6.0)
		StartRace()
	endif
EndEvent


; ---------- the circuit ----------

Function BuildTrack()
	tx = new float[96]
	ty = new float[96]
	tz = new float[96]
	th = new float[96]
	SigfTrack.Fill(tx, ty, tz, th)
	trackLen = SigfTrack.Total()
	step = trackLen / 96.0
EndFunction

float Function Wrap(float s)
	return s - trackLen * Math.Floor(s / trackLen)
EndFunction

float Function PosX(float s, float ln)
	float w = Wrap(s)
	int i = Math.Floor(w / step)
	float f = w / step - i
	int j = (i + 1) % 96
	float x = tx[i] + (tx[j] - tx[i]) * f
	return x + ln * Math.Cos(th[i])
EndFunction

float Function PosY(float s, float ln)
	float w = Wrap(s)
	int i = Math.Floor(w / step)
	float f = w / step - i
	int j = (i + 1) % 96
	float y = ty[i] + (ty[j] - ty[i]) * f
	return y - ln * Math.Sin(th[i])
EndFunction

float Function PosZ(float s)
	float w = Wrap(s)
	int i = Math.Floor(w / step)
	float f = w / step - i
	int j = (i + 1) % 96
	return tz[i] + (tz[j] - tz[i]) * f
EndFunction

float Function Head(float s)
	return th[Math.Floor(Wrap(s) / step)]
EndFunction

; ---------- race set up and tear down ----------

Function StopRace()
	running = false
	UnregisterForUpdate()
	int i = 0
	while drv && i < RACERS
		if drv[i]
			drv[i].Delete()
		endif
		if kart[i]
			kart[i].Delete()
		endif
		i += 1
	endwhile
	i = 0
	while boxes && i < boxes.Length
		if boxes[i]
			boxes[i].Delete()
		endif
		i += 1
	endwhile
	i = 0
	while bananas && i < bananas.Length
		if bananas[i]
			bananas[i].Delete()
		endif
		i += 1
	endwhile
	i = 0
	while shells && i < shells.Length
		if shells[i]
			shells[i].Delete()
		endif
		i += 1
	endwhile
EndFunction

ObjectReference Function MarkerAt(float x, float y, float z)
	Actor p = Game.GetPlayer()
	ObjectReference m = p.PlaceAtMe(Game.GetFormFromFile(0x0000003B, "Skyrim.esm"))
	m.MoveTo(p, x - p.GetPositionX(), y - p.GetPositionY(), z - p.GetPositionZ())
	return m
EndFunction

Function StartRace()
	gen += 1
	int my = gen
	StopRace()
	if !tx
		BuildTrack()
	endif
	Actor p = Game.GetPlayer()
	finished = false
	drv = new Actor[5]
	kart = new ObjectReference[5]
	prog = new float[5]
	lane = new float[5]
	baseSpeed = new float[5]
	spinLeft = new float[5]
	spinAng = new float[5]
	boostLeft = new float[5]
	lastAng = new float[5]
	wrecked = new bool[5]
	names = new string[5]
	boxes = new ObjectReference[12]
	boxRespawn = new float[12]
	boxS = new float[12]
	boxLane = new float[12]
	bananas = new ObjectReference[8]
	banAge = new float[8]
	banOwner = new int[8]
	shells = new ObjectReference[4]
	shellTarget = new int[4]
	shellAge = new float[4]
	names[0] = "You"
	names[1] = "Rocket Fox"
	names[2] = "Antler Andy"
	names[3] = "Cluck Norris"
	names[4] = "Billy Gruff"
	baseSpeed[0] = 330.0
	baseSpeed[1] = 322.0
	baseSpeed[2] = 338.0
	baseSpeed[3] = 316.0
	baseSpeed[4] = 326.0
	; starting grid, just behind the line (s = trackLen)
	prog[0] = trackLen - 60.0
	lane[0] = 0.0
	prog[1] = trackLen - 60.0
	lane[1] = 62.0
	prog[2] = trackLen - 60.0
	lane[2] = -62.0
	prog[3] = trackLen - 250.0
	lane[3] = 30.0
	prog[4] = trackLen - 250.0
	lane[4] = -30.0

	; the player is carried to the grid
	p.MoveTo(MarkerAt(PosX(prog[0], 0.0), PosY(prog[0], 0.0), PosZ(prog[0]) + 30.0))
	Utility.Wait(0.5)
	if my != gen
		return
	endif
	kart[0] = p.PlaceAtMe(SigfKartRed)
	kart[1] = p.PlaceAtMe(SigfKartBlue)
	kart[2] = p.PlaceAtMe(SigfKartGreen)
	kart[3] = p.PlaceAtMe(SigfKartPurple)
	kart[4] = p.PlaceAtMe(SigfKartBlue)
	drv[1] = p.PlaceAtMe(SigfFoxRacer) as Actor
	drv[2] = p.PlaceAtMe(SigfElkRacer) as Actor
	drv[3] = p.PlaceAtMe(SigfChickenRacer) as Actor
	drv[4] = p.PlaceAtMe(SigfGoatRacer) as Actor
	drv[1].SetScale(1.5)
	drv[2].SetScale(0.6)
	drv[3].SetScale(2.4)
	drv[4].SetScale(0.8)
	int k = 1
	while k < RACERS
		drv[k].EnableAI(false)
		drv[k].SetActorValue("Aggression", 0.0)
		Debug.Trace("SIGF_SPAWN racer" + k)
		k += 1
	endwhile
	Debug.Trace("SIGF_SPAWN kart")
	k = 0
	while k < RACERS
		lastAng[k] = Head(prog[k])
		Place(k, 0.0)
		k += 1
	endwhile
	PlaceBoxes()

	SigfLib.Say("KART GAME TAKEOVER!")
	Utility.Wait(1.5)
	if my != gen
		return
	endif
	SigfLib.Say("3...")
	SigfLib.Shake(0.2, 0.4)
	Utility.Wait(1.0)
	if my != gen
		return
	endif
	SigfLib.Say("2...")
	SigfLib.Shake(0.3, 0.4)
	Utility.Wait(1.0)
	if my != gen
		return
	endif
	SigfLib.Say("1...")
	SigfLib.Shake(0.4, 0.4)
	Utility.Wait(1.0)
	if my != gen
		return
	endif
	SigfLib.Say("GO GO GO!")
	SigfLib.Shake(0.8, 0.8)
	running = true
	tickN = 0
	lastT = Utility.GetCurrentRealTime()
	RegisterForSingleUpdate(0.05)
EndFunction

Function PlaceBoxes()
	int row = 0
	while row < 4
		int c = 0
		while c < 3
			int b = row * 3 + c
			boxS[b] = trackLen + trackLen * row / 4.0 + 650.0
			boxLane[b] = (c - 1) * 125.0
			SpawnBox(b)
			c += 1
		endwhile
		row += 1
	endwhile
EndFunction

Function SpawnBox(int b)
	ObjectReference m = MarkerAt(PosX(boxS[b], boxLane[b]), PosY(boxS[b], boxLane[b]), PosZ(boxS[b]) + 85.0)
	m.SetAngle(0.0, 0.0, 0.0)
	boxes[b] = m.PlaceAtMe(SigfQBox)
	boxes[b].SetScale(0.55)
	m.Delete()
	boxRespawn[b] = 0.0
	Debug.Trace("SIGF_SPAWN qbox")
EndFunction

; ---------- the race loop ----------

float Function Dist2(ObjectReference a, ObjectReference b)
	float dx = a.GetPositionX() - b.GetPositionX()
	float dy = a.GetPositionY() - b.GetPositionY()
	return dx * dx + dy * dy
EndFunction

; Put kart k (and its driver) where its progress says; dt = 0 means jump there
Function Place(int k, float dt)
	if wrecked[k]
		return
	endif
	float s = prog[k]
	float x = PosX(s, lane[k])
	float y = PosY(s, lane[k])
	float z = PosZ(s)
	float hop = 0.0
	if spinLeft[k] > 0.0
		spinLeft[k] = spinLeft[k] - dt
		spinAng[k] = spinAng[k] + 330.0 * dt
		hop = 45.0 * Math.Sin(spinAng[k] * 0.5)
		if hop < 0.0
			hop = 0.0 - hop
		endif
	else
		spinAng[k] = 0.0
	endif
	float a = Head(s) + spinAng[k]
	a = a - 360.0 * Math.Floor(a / 360.0)
	float d = a - lastAng[k]
	lastAng[k] = a
	if dt <= 0.0 || d > 180.0 || d < -180.0
		; jump (start, or the angle wrapped around north)
		kart[k].SetPosition(x, y, z)
		kart[k].SetAngle(0.0, 0.0, a)
		if k > 0
			drv[k].SetPosition(x, y, z + 14.0)
			drv[k].SetAngle(0.0, 0.0, a)
		else
			Game.GetPlayer().SetAngle(0.0, 0.0, a)
		endif
		return
	endif
	kart[k].TranslateTo(x, y, z + hop, 0.0, 0.0, a, curSpeed, 420.0)
	if k > 0
		drv[k].TranslateTo(x, y, z + 14.0 + hop, 0.0, 0.0, a, curSpeed, 420.0)
	else
		Game.GetPlayer().TranslateTo(x, y, z + 14.0 + hop, 0.0, 0.0, a, curSpeed, 420.0)
	endif
EndFunction

Event OnUpdate()
	if !running
		return
	endif
	float now = Utility.GetCurrentRealTime()
	float dt = now - lastT
	lastT = now
	if dt > 0.6
		dt = 0.6
	endif
	if dt < 0.03
		dt = 0.03
	endif
	tickN += 1
	if finished
		restartClock -= dt
		if restartClock <= 0.0
			StartRace()
		else
			RegisterForSingleUpdate(0.05)
		endif
		return
	endif

	int i = 0
	while i < RACERS
		if !wrecked[i]
			float v = baseSpeed[i]
			if boostLeft[i] > 0.0
				boostLeft[i] = boostLeft[i] - dt
				v = v * 1.8
			endif
			if spinLeft[i] > 0.0
				v = v * 0.25
			endif
			prog[i] = prog[i] + v * dt
			curSpeed = v * 1.15
			Place(i, dt)
			if tickN % 4 == i % 4
				kart[i].PlaceAtMe(SigfDustSm)
			endif
			if i > 0 && drv[i].IsDead()
				wrecked[i] = true
				kart[i].PlaceAtMe(SigfBlast)
				SigfLib.Say(names[i] + " is wrecked!")
			endif
		endif
		i += 1
	endwhile

	; item boxes
	i = 0
	while i < boxes.Length
		if boxes[i]
			boxes[i].TranslateTo(boxes[i].GetPositionX(), boxes[i].GetPositionY(), boxes[i].GetPositionZ(), 0.0, 0.0, boxes[i].GetAngleZ() + 36.0, 1.0, 300.0)
			int j = 0
			while j < RACERS && boxes[i]
				if kart[j] && !wrecked[j] && Dist2(boxes[i], kart[j]) < 15000.0
					Pickup(j, i)
				endif
				j += 1
			endwhile
		else
			boxRespawn[i] = boxRespawn[i] - dt
			if boxRespawn[i] <= 0.0
				SpawnBox(i)
			endif
		endif
		i += 1
	endwhile

	; banana peels
	i = 0
	while i < bananas.Length
		if bananas[i]
			banAge[i] = banAge[i] + dt
			int j = 0
			while j < RACERS && bananas[i]
				if kart[j] && !wrecked[j] && spinLeft[j] <= 0.0 && (j != banOwner[i] || banAge[i] > 3.0) && Dist2(bananas[i], kart[j]) < 9000.0
					bananas[i].PlaceAtMe(SigfDustMed)
					bananas[i].Delete()
					bananas[i] = None
					SigfLib.Say(names[j] + " slipped on a banana!")
					Hit(j, 18.0, false)
				endif
				j += 1
			endwhile
			if bananas[i] && banAge[i] > 40.0
				bananas[i].Delete()
				bananas[i] = None
			endif
		endif
		i += 1
	endwhile

	; homing shells
	i = 0
	while i < shells.Length
		if shells[i]
			shellAge[i] = shellAge[i] + dt
			int t = shellTarget[i]
			if shellAge[i] > 7.0 || !kart[t]
				shells[i].Delete()
				shells[i] = None
			else
				shells[i].TranslateTo(kart[t].GetPositionX(), kart[t].GetPositionY(), kart[t].GetPositionZ() + 45.0, 0.0, 0.0, shells[i].GetAngleZ() + 90.0, 900.0, 600.0)
				if Dist2(shells[i], kart[t]) < 24000.0
					shells[i].Delete()
					shells[i] = None
					SigfLib.Say(names[t] + " got blasted by a shell!")
					Hit(t, 38.0, true)
				endif
			endif
		endif
		i += 1
	endwhile

	; race status
	float goal = trackLen * (1.0 + LAPS_TO_WIN)
	if prog[0] >= goal
		finished = true
		restartClock = 9.0
		SigfLib.Say("FINISH! You placed " + Rank() + " of " + RACERS)
		SigfLib.Shake(0.7, 1.5)
		kart[0].PlaceAtMe(SigfBlast)
	elseif tickN % 100 == 0
		SigfLib.Say("Lap " + Math.Floor(prog[0] / trackLen) + "/" + LAPS_TO_WIN + "   Place " + Rank() + "/" + RACERS)
	endif
	RegisterForSingleUpdate(0.05)
EndEvent

int Function Rank()
	int r = 1
	int i = 1
	while i < RACERS
		if prog[i] > prog[0]
			r += 1
		endif
		i += 1
	endwhile
	return r
EndFunction

; ---------- items ----------

Function Pickup(int i, int b)
	boxes[b].PlaceAtMe(SigfDustMed)
	boxes[b].Delete()
	boxes[b] = None
	boxRespawn[b] = 6.0
	int kind
	if i == 0
		kind = pItem % 3
		pItem += 1
	else
		kind = Utility.RandomInt(0, 2)
	endif
	if kind == 0
		if !FireShell(i)
			DropBanana(i)
		endif
	elseif kind == 1
		Boost(i)
	else
		DropBanana(i)
	endif
EndFunction

Function Boost(int i)
	SigfLib.Say(names[i] + ": TURBO BOOST!")
	boostLeft[i] = 2.5
	if i > 0
		FireFXTrapShader.Play(drv[i], 2.5)
	else
		FireFXTrapShader.Play(kart[0], 2.5)
		SigfLib.Shake(0.4, 0.8)
	endif
	kart[i].PlaceAtMe(SigfBlast)
EndFunction

Function DropBanana(int i)
	int s = 0
	while s < bananas.Length && bananas[s]
		s += 1
	endwhile
	if s >= bananas.Length
		return
	endif
	SigfLib.Say(names[i] + " dropped a banana!")
	ObjectReference m = MarkerAt(PosX(prog[i] - 190.0, lane[i]), PosY(prog[i] - 190.0, lane[i]), PosZ(prog[i] - 190.0))
	bananas[s] = m.PlaceAtMe(SigfBanana)
	m.Delete()
	bananas[s].SetAngle(0.0, 0.0, Utility.RandomFloat(0.0, 360.0))
	banAge[s] = 0.0
	banOwner[s] = i
	Debug.Trace("SIGF_SPAWN banana")
EndFunction

bool Function FireShell(int i)
	int s = 0
	while s < shells.Length && shells[s]
		s += 1
	endwhile
	if s >= shells.Length
		return false
	endif
	; the nearest racer ahead of us (any other one if we lead)
	int best = -1
	float bd = 99999999.0
	int j = 0
	while j < RACERS
		if j != i && kart[j] && !wrecked[j]
			float d = prog[j] - prog[i]
			if d < 0.0
				d = 99999.0 - d
			endif
			if d < bd
				bd = d
				best = j
			endif
		endif
		j += 1
	endwhile
	if best < 0
		return false
	endif
	SigfLib.Say(names[i] + " fired a homing shell at " + names[best] + "!")
	shells[s] = kart[i].PlaceAtMe(SigfShell)
	shells[s].MoveTo(kart[i], 0.0, 0.0, 70.0)
	shellTarget[s] = best
	shellAge[s] = 0.0
	Debug.Trace("SIGF_SPAWN shell")
	return true
EndFunction

; A kart got hit: boom, spin out, hurt the animal driver
Function Hit(int j, float dmg, bool big)
	spinLeft[j] = 1.5
	spinAng[j] = 0.0
	if big
		kart[j].PlaceAtMe(SigfBlast)
	endif
	if j > 0
		ShockFXShader.Play(drv[j], 1.5)
		drv[j].DamageActorValue("Health", dmg)
	else
		SigfLib.Shake(0.7, 1.0)
	endif
EndFunction
