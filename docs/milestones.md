# Bone & Barrow: Development Milestones

**Target:** 6 months solo development
**Tech Stack:** Godot 4.x, GDScript, Midjourney + Aseprite, SFXR
**Vision:** See `vision.md` for game philosophy
**Balance:** See `game_balance.gd` for all numbers

---

## Milestone 1: Playable Prototype
**Timeline:** Weeks 1-4
**Goal:** Prove the core loop feels good

### Features to Build
- [ ] Player movement + soul bolt attack
- [ ] 1 enemy type (squire) with pathfinding to Crypt Heart
- [ ] "E to raise corpse" mechanic (feels satisfying!)
- [ ] 1 skeleton type (warrior) that follows player
- [ ] Basic Crypt Heart (can be destroyed)
- [ ] 1 wave with burst-lull-burst pattern
- [ ] Simple placeholder art (colored shapes OK)

### Success Criteria
- **Raising skeletons feels satisfying** (juice/feedback/timing)
- **Commanding a small horde (3-5 skeletons) is fun**
- **Combat has clear feedback** (damage numbers, sounds, screen shake)
- Can play one 2-minute wave loop repeatedly without boredom

### Critical Decision Point
**If this doesn't feel good, pivot immediately.** The entire game rests on "raising enemies mid-combat" being fun. If it's tedious or confusing after iteration, the concept may not work.

### Risks to Watch
- Skeleton AI too dumb/frustrating (getting stuck, not attacking)
- Raising corpses feels too slow/clunky
- Not enough feedback (raising feels "empty")

**Mitigation:** Keep skeleton AI dead simple (just follow + attack nearest). Add particle effects and sound EARLY. If pathfinding is hard, make skeletons teleport to player if far away.

---

## Milestone 2: First Full Run
**Timeline:** Weeks 5-8
**Goal:** One complete run with progression

### Features to Add
- [ ] 3 enemy types (squire, archer, priest)
- [ ] 3 skeleton types (warrior, archer, brute)
- [ ] 5 waves with burst-lull pacing
- [ ] Shop system (pick 1 of 3 upgrades between waves)
- [ ] Win condition (survive 15 min to "dawn")
- [ ] Lose condition (Crypt Heart destroyed)
- [ ] Gold payout based on performance
- [ ] Basic UI (HP bars, wave counter, shop cards)

### Success Criteria
- **Can play full 15-minute run start to finish**
- **Difficulty curve feels reasonable** (each wave harder than last)
- **Shop choices matter** (player can feel difference)
- Wave 1 beatable by average player 50%+ of the time
- Wave 5 beatable only by skilled players with good builds

### Risks to Watch
- Wave pacing feels wrong (too easy, too hard, too boring, too exhausting)
- Shop upgrades feel samey (player doesn't care which they pick)
- Balance completely broken (too hard to tune)

**Mitigation:** Expose ALL tuning knobs in `game_balance.gd` (spawn rate, lull duration, enemy HP). Iterate fast. Playtest daily. Can your mom beat Wave 1? Can you beat Wave 5 on run 1?

---

## Milestone 3: Meta-Progression Loop
**Timeline:** Weeks 9-12
**Goal:** Runs feed into permanent progression

### Features to Add
- [ ] Meta-progression menu (spend gold between runs)
- [ ] 5 power upgrades (capped at rank 3 each)
- [ ] 2 skeleton type unlocks (from the 5 total)
- [ ] 2 spell unlocks
- [ ] Save/load system (persist progress)
- [ ] Journal/story beats after runs (flavor text)

### Success Criteria
- **Dying doesn't feel punishing** (you still earned gold)
- **Unlocks make meaningful impact** (player feels stronger)
- **"One more run" loop is strong** (hard to stop playing)
- Economy validated: ~10-12 runs to unlock all rank 1 upgrades

### Risks to Watch
- Gold grind feels too slow (frustration)
- Upgrades trivialize content (no challenge after 5 runs)
- Save system bugs (lost progress = rage quit)

**Mitigation:** Playtest economy carefully. Track: gold per run, runs to first "power spike", player retention. Adjust `gold_multiplier` in balance file if needed.

---

## Milestone 4: Variety & Replayability
**Timeline:** Weeks 13-18
**Goal:** No two runs feel the same

### Features to Add
- [ ] Random start positions (N/S/E crypt placement)
- [ ] Start bonus selection system (choose 1 before each run)
- [ ] Wave modifiers (reinforced, flanking, rapid, etc.)
- [ ] All 5 skeleton types unlockable
- [ ] All 5 spells unlockable
- [ ] Journal expands (more story beats, personality)
- [ ] Run variety testing (track compositions, outcomes)

### Success Criteria
- **Can play 10+ runs without boredom**
- **RNG feels interesting, not frustrating** (never "unfair")
- **Each run feels tactically different** (not just stat variance)
- Player can describe different "builds" or strategies

### Risks to Watch
- Randomization creates unwinnable starts (bad RNG)
- Too much variance = no skill expression
- Content still feels repetitive despite variance

**Mitigation:** Constrained randomness (see `vision.md` "Why Runs Don't Get Boring"). Fixed threat budget per wave. Balanced start bonuses. Playtest with friends: do they complain about RNG or praise variety?

---

## Milestone 5: Juice & Feel
**Timeline:** Weeks 19-22
**Goal:** Make everything feel amazing

### Polish to Add
- [ ] Screen shake on impacts (subtle but noticeable)
- [ ] Particle effects (soul energy, raises, deaths, spells)
- [ ] Sound design (whooshes, bone clatters, ambient fog)
- [ ] Music (2-3 tracks: calm prep, intense combat, victory)
- [ ] UI polish (smooth transitions, hover effects, animations)
- [ ] Camera effects (follow player, slight zoom on boss moments)
- [ ] Finalized sprite art (replace placeholders)

### Success Criteria
- **Game feels "professional"** (compare to Cult of the Lamb polish)
- **Every action has satisfying feedback** (raising/killing/upgrading)
- External playtesters say "this feels good to play"

### Risks to Watch
- Art takes too long (sprite production bottleneck)
- Polish never feels "done" (perfectionism trap)
- Audio/visual doesn't match the tone (too scary or too silly)

**Mitigation:**
- **Art deadline:** 2-3 hours per character max. If slower, cut skeleton types to 3 or use recolors.
- **Polish scope:** Week 19 = particles/shake, Week 20 = sound, Week 21 = music, Week 22 = final UI pass. Don't iterate forever.
- **Tone check:** Reference Cult of the Lamb frequently. Dark-but-charming, not grimdark.

**Nuclear option for art:** Go full abstract (colored shapes, no sprites). Vampire Survivors proved you don't need detailed art.

---

## Milestone 6: Balance & Release Prep
**Timeline:** Weeks 23-26
**Goal:** Ship it

### Tasks
- [ ] Playtesting (friends, family, Discord, Reddit)
- [ ] Balance tuning based on feedback (gold costs, enemy HP, wave timing)
- [ ] Bug fixes (priority: crashes, save corruption, soft locks)
- [ ] Steam page setup (screenshots, trailer, description)
- [ ] Trailer production (30-60 sec, show core loop)
- [ ] Launch day prep (social media, press list, Discord server)
- [ ] Final polish pass (fix ugly bits)

### Success Criteria
- **No critical bugs** (crashes, save loss, unbeatable scenarios)
- **Economy feels fair** (10-12 runs to "complete" core progression)
- **Difficulty feels balanced** (Wave 1 accessible, Wave 5 challenging)
- **Steam page is compelling** (wishlist conversion rate)

### Release Checklist
- [ ] 10+ external playtesters have completed runs
- [ ] Average playtime per session: 30-60 minutes (3-5 runs)
- [ ] "One more run" feedback from 80%+ of testers
- [ ] No game-breaking bugs in last 50 playthroughs
- [ ] Trailer posted, Steam page live for 2+ weeks
- [ ] Backup plan if launch fails (content update? Price adjust?)

---

## Scope Control: The Cut List

**When you're in Month 4 and panicking about scope, cut from this list FIRST:**

### Easy Cuts (Minimal Impact)
- Skeleton types 4 & 5 (start with 3, add later)
- Cosmetic unlocks (lich robes, graveyard decorations)
- Story journal beats (keep minimal flavor text only)
- Dynamic difficulty scaling (use fixed wave compositions)
- Start position randomization (one graveyard layout only)

### Medium Cuts (Noticeable but Acceptable)
- Wave modifiers (keep standard compositions only)
- Spell variety (ship with 2-3 spells instead of 5)
- Enemy type 3 (priests) - keep squires + archers only
- Meta upgrade ranks (cap at rank 2 instead of 3)

### Hard Cuts (Last Resort)
- Meta-progression entirely (pure roguelite, no unlocks)
- Multiple skeleton types (just warriors)
- Shop system (auto-apply upgrades)

**Mantra:** "Does this help me ship in 6 months? No? Cut it."

---

## Key Metrics to Track During Development

### Week 4 (Milestone 1)
- Time to raise first corpse: < 5 seconds (tutorial)
- Player understands mechanic: 90%+ (watch playtesters)
- "This feels fun": 70%+ immediate reaction

### Week 8 (Milestone 2)
- Average first-run survival: Wave 2-3 (good difficulty)
- Time to complete one run: 10-15 minutes (target met)
- Shop pick time: < 10 seconds (clear choices)

### Week 12 (Milestone 3)
- Runs before first "I'm done": 5+ (retention)
- Gold per run variance: 50g - 1200g (working as intended)
- "One more run" quit rate: < 30% (strong loop)

### Week 18 (Milestone 4)
- Runs before "this feels repetitive": 15+ (variety working)
- Unique strategies discovered: 3+ (build diversity)
- "RNG screwed me" complaints: < 20% (fair variance)

### Week 22 (Milestone 5)
- "This feels polished": 80%+ testers (ready for launch)
- Bugs per playtester hour: < 0.5 (stable)

---

## Emergency Pivots

### If Milestone 1 Fails (Core Loop Isn't Fun)
**Options:**
1. **Simplify raising:** Auto-raise nearest corpse on kill (remove button press)
2. **Change mechanic:** Skeletons are "aura" around player, not individual units
3. **Pivot genre:** Become pure tower defense (place skeleton spawners)
4. **Kill project:** This mechanic doesn't work, move to next idea

### If Economy Feels Broken at Milestone 3
**Options:**
1. Multiply all gold payouts by 1.5x (adjust `gold_multiplier`)
2. Cut meta-upgrade costs in half
3. Remove rank 3 upgrades entirely (cheaper progression)
4. Add "daily bonus" gold (300g per day) to speed up casuals

### If Art Bottleneck at Milestone 5
**Options:**
1. Recolor existing sprites (3 skeleton types → 5 via palette swaps)
2. Cut to 3 skeleton types total
3. Use 100% placeholder art (colored shapes + particle effects)
4. Hire artist for $500-1000 (outsource the 10 characters)

---

## How to Use This Document

**Weekly Review:**
- Sunday: Check current milestone, review tasks
- Mark completed tasks, note blockers
- Adjust timeline if slipping (cut scope, don't extend deadline)

**When Stuck:**
- Read "Risks to Watch" for current milestone
- Check "Scope Control: Cut List"
- Ask: "What's the SMALLEST thing I can ship?"

**When Losing Motivation:**
- Read `vision.md` "The Dream" section
- Play your prototype (even broken, it's YOUR game)
- Remember: Done is better than perfect

---

**6 months. 1 game. You got this.**
