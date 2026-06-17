/* =====================================================================
   Waystation — MVP vertical-slice prototype  (DESIGN.md §16)
   A throwaway, browser-playable design-validation build. The real game
   is built in Godot 4 per DESIGN.md; this proves the spine:
     curate the space -> attract & sustain pets -> pets enrich the space.
   One pet, one room. No build step — just open index.html.
   ===================================================================== */
'use strict';

/* ---------------------------------------------------------------------
   0. Constants & catalogs
   --------------------------------------------------------------------- */
const SAVE_KEY = 'waystation_mvp_v1';
const W = 540, H = 960;                 // virtual portrait resolution (9:16)
const TAGS = ['warmth', 'greenery', 'softness', 'hiding']; // MVP tag set (§16)

// Decor catalog. tags are raw contributions; layer drives placement & Composition.
// behavior is the room-behavior this item *invites* from the pet (the spine, made visible).
const CATALOG = {
  bed:    { name:'Basket bed',  emoji:'🧺', cost:0,  cur:'coin', layer:'floor', behavior:'rest',
            tags:{softness:5, warmth:2}, theme:'cozy', starter:true },
  foodBowl:{name:'Food bowl',   emoji:'🍲', cost:0,  cur:'coin', layer:'floor', behavior:'eat',
            tags:{}, theme:'cozy', starter:true },
  waterBowl:{name:'Water bowl', emoji:'🥣', cost:0,  cur:'coin', layer:'floor', behavior:'drink',
            tags:{}, theme:'cozy', starter:true },

  cushion:{ name:'Plush cushion',emoji:'🛋️', cost:30, cur:'coin', layer:'floor', behavior:'rest',
            tags:{softness:4, warmth:3}, theme:'cozy' },
  rug:    { name:'Wool rug',     emoji:'🟫', cost:25, cur:'coin', layer:'floor', behavior:null,
            tags:{softness:5}, theme:'cozy' },
  box:    { name:'Cardboard box',emoji:'📦', cost:20, cur:'coin', layer:'floor', behavior:'hide',
            tags:{hiding:5}, theme:'plain' },
  tree:   { name:'Cat tree',     emoji:'🪜', cost:70, cur:'coin', layer:'floor', behavior:'climb',
            tags:{hiding:3, softness:2}, theme:'plain' },
  lamp:   { name:'Brass lamp',   emoji:'🪔', cost:40, cur:'coin', layer:'floor', behavior:null,
            tags:{warmth:6}, theme:'warm' },
  fern:   { name:'Potted fern',  emoji:'🪴', cost:35, cur:'coin', layer:'floor', behavior:null,
            tags:{greenery:5}, theme:'leafy' },
  toy:    { name:'Feather toy',  emoji:'🪶', cost:15, cur:'coin', layer:'floor', behavior:'play',
            tags:{}, theme:'plain' },
  shelf:  { name:'Reading nook', emoji:'📚', cost:55, cur:'coin', layer:'floor', behavior:null,
            tags:{warmth:1, hiding:2}, theme:'warm' },

  window: { name:'Sunny window', emoji:'🪟', cost:60, cur:'coin', layer:'wall', behavior:'sunbeam',
            tags:{warmth:6}, theme:'warm' },
  ivy:    { name:'Hanging ivy',  emoji:'🌿', cost:45, cur:'coin', layer:'hang', behavior:null,
            tags:{greenery:6}, theme:'leafy' },

  // Trinket (prestige) tier — high quality, low clutter; demonstrates the Trinket gate (§10)
  ancientFern:{ name:'Ancient fern',emoji:'🌿', cost:5, cur:'trinket', layer:'floor', behavior:null,
            tags:{greenery:7, softness:2}, theme:'leafy', quality:true },
};
const BUYABLE = ['cushion','rug','box','tree','lamp','fern','toy','shelf','window','ivy','ancientFern'];

// The cat's comfort profile (what makes it thrive) and the visiting sparrow's profile (§3).
const CAT_PROFILE     = { warmth:7, softness:8, hiding:4, greenery:2 };
const SPARROW_PROFILE = { greenery:8, softness:3, warmth:3, hiding:1 };

const TRAITS = {
  cozy:    { label:'cozy',    desc:'loves warm, soft spots and long naps' },
  playful: { label:'playful', desc:'chases toys and climbs anything tall' },
  shy:     { label:'shy',     desc:'hides when visitors come, trusts slowly' },
};
const BOND_STAGES = [
  { name:'Wary',        min:0  },
  { name:'Curious',     min:15 },
  { name:'Friendly',    min:35 },
  { name:'Bonded',      min:60 },
  { name:'Inseparable', min:85 },
];

/* ---------------------------------------------------------------------
   1. State + persistence
   --------------------------------------------------------------------- */
let G = null;

function freshState() {
  return {
    v: 1,
    onboarded: false,
    coins: 0,
    trinkets: 0,
    timeOffsetH: 0,          // demo clock override (hours)
    havenWarmth: 0.25,       // restoration glow 0..1 (the haven "warms" as it revives)
    cat: {
      species:'cat', name:'', trait:'cozy',
      x:0.5, d:0.55, tx:0.5, td:0.55, facing:1, moving:false,
      pose:'sit', action:null, actTimer:0, blink:0,
      needs:{ food:80, water:80, enrichment:75 },
      mood:70, bond:2, thriving:20,
      bondDay:'', bondToday:0,
      lastGift:0,
    },
    placed: [],              // { key, x, d, id }  (wall items use x only; d fixed)
    plant: null,             // { plantedAt, lastHarvest, x, d }
    photos: [],
    visitor: null,           // { x, d, tx, td, timer, hops, tipped }
    visitDraw: 0,            // accumulating attraction toward a visit
    lastTick: Date.now(),
    lastStipend: 0,
    seen: { shop:false, plant:false, visitor:false },
  };
}

function save() {
  try { G.lastTick = Date.now(); localStorage.setItem(SAVE_KEY, JSON.stringify(G)); } catch(e){}
}
function load() {
  try {
    const raw = localStorage.getItem(SAVE_KEY);
    if (!raw) return false;
    const s = JSON.parse(raw);
    if (!s || s.v !== 1) return false;
    G = s;
    return true;
  } catch(e){ return false; }
}

// Offline accrual: nothing is punished. Needs settle toward a "content but missing you"
// floor, plants keep growing, the daily stipend accrues. Bond never decays. (§11)
function applyOffline() {
  const now = Date.now();
  const dtMin = Math.min((now - (G.lastTick||now)) / 60000, 60*24*7); // cap a week
  if (dtMin > 1) {
    const floor = 35;
    for (const k of ['food','water','enrichment']) {
      const n = G.cat.needs[k];
      // ease toward floor, never below
      G.cat.needs[k] = Math.max(floor, n - Math.min(n-floor>0 ? (n-floor) : 0, dtMin*1.2));
    }
    // daily stipend / "mail": ~12 coins per real day away, capped
    const days = Math.min(dtMin/1440, 5);
    const stipend = Math.round(days*12);
    if (stipend > 0) { G.coins += stipend; toast(`📬 Mail while you were away: +${stipend} 🪙`); }
  }
  G.lastTick = now;
}

/* ---------------------------------------------------------------------
   2. Ecosystem math — tags, Charm, matches (§3–4)
   --------------------------------------------------------------------- */
// Diminishing returns: repeated contributions to a tag matter less and less,
// so spamming one item type can't dominate. Variety is forced. (§4)
function roomTags() {
  const buckets = {}; TAGS.forEach(t => buckets[t] = []);
  for (const p of G.placed) {
    const def = CATALOG[p.key]; if (!def.tags) continue;
    for (const t in def.tags) buckets[t].push(def.tags[t] * (def.quality ? 1.25 : 1));
  }
  // plant contributes greenery scaled by growth
  if (G.plant) buckets.greenery.push(2 + 5 * plantGrowth());
  const out = {};
  for (const t of TAGS) {
    const list = buckets[t].sort((a,b)=>b-a);
    let sum = 0;
    list.forEach((v,i) => sum += v / (1 + 0.7*i));
    out[t] = sum;
  }
  return out;
}

// How well the room satisfies a profile, 0..1. Reward matching up to what's wanted;
// going past a desire neither helps nor (much) hurts — multi-axis, can't fern your way in.
function matchProfile(profile) {
  const rt = roomTags();
  let score = 0, total = 0;
  for (const t of TAGS) {
    const want = profile[t] || 0; if (want <= 0) continue;
    total += want;
    score += want * Math.min(1, (rt[t]||0) / want);
  }
  return total ? score/total : 0;
}

// Charm 0..100 from Variety, Composition, Coherence, Harmony (§4). Generous; only
// punishes obvious degeneracy (monoculture, clutter, clash). Free items can hit max.
function charmReport() {
  const items = G.placed.filter(p => !CATALOG[p.key].starter || p.key==='bed');
  const all = G.placed;
  const n = all.length;

  // Variety — distinct decor types (diminishing). Monoculture scores low.
  const types = new Set(all.map(p=>p.key));
  const variety = Math.min(40, types.size * 7);

  // Composition — uses multiple layers (floor/wall/hang) + breathing room (not sparse/cluttered).
  const layers = new Set(all.map(p=>CATALOG[p.key].layer));
  let comp = layers.size * 6;                  // up to 18 for 3 layers
  if (n >= 4 && n <= 12) comp += 7;            // comfortable density
  else if (n > 14) comp -= (n-14)*2;           // clutter penalty
  else if (n < 3) comp -= (3-n)*3;             // too bare
  comp = clamp(comp, 0, 25);

  // Coherence — dominant theme share.
  const themes = {};
  all.forEach(p => { const th=CATALOG[p.key].theme||'plain'; themes[th]=(themes[th]||0)+1; });
  const dom = Math.max(0, ...Object.values(themes));
  const coherence = n ? clamp(Math.round((dom/n)*20), 0, 20) : 0;

  // Harmony — penalize too many clashing themes at once.
  const themeCount = Object.keys(themes).length;
  const harmony = clamp(15 - Math.max(0, themeCount-3)*4, 0, 15);

  // Quality bonus — a single gorgeous piece lifts the room.
  const quality = all.some(p=>CATALOG[p.key].quality) ? 6 : 0;

  let charm = clamp(Math.round(variety + comp + coherence + harmony + quality), 0, 100);

  // Gentle, specific tip (the friendly Room Report).
  let tip;
  if (n < 3)               tip = 'Feels a little bare — add a few things.';
  else if (n > 14)         tip = 'A bit cluttered — try removing a few things.';
  else if (types.size <= 2)tip = 'Add some variety — one type can\'t do it all.';
  else if (themeCount > 3) tip = 'Mixing a lot of styles — lean into one theme.';
  else if (charm >= 75)    tip = 'Lovely and balanced. ✨';
  else                     tip = 'Coming together nicely.';

  return { charm, variety, comp, coherence, harmony, tip, n };
}

/* ---------------------------------------------------------------------
   3. Clock / time of day (§11)
   --------------------------------------------------------------------- */
function gameHour() {
  const d = new Date();
  return ( (d.getHours() + d.getMinutes()/60 + G.timeOffsetH) % 24 + 24) % 24;
}
function phaseOf(h) {
  if (h >= 5 && h < 8)  return 'dawn';
  if (h >= 8 && h < 17) return 'day';
  if (h >= 17 && h < 20)return 'dusk';
  return 'night';
}
function isDaylight() { const p = phaseOf(gameHour()); return p==='day'||p==='dawn'||p==='dusk'; }

/* ---------------------------------------------------------------------
   4. Plant (§10) — grows on a (prototype-accelerated) real-time clock
   --------------------------------------------------------------------- */
const PLANT_MATURE_S = 180;   // prototype: ~3 min to mature (real game: days)
function plantGrowth() {
  if (!G.plant) return 0;
  const since = (Date.now() - G.plant.lastHarvest) / 1000;
  return clamp(since / PLANT_MATURE_S, 0, 1);
}
function plantStage() {
  const g = plantGrowth();
  if (g >= 1)   return { i:3, emoji:'🌼', name:'flowering — ready to harvest', ready:true };
  if (g >= 0.5) return { i:2, emoji:'🌿', name:'growing', ready:false };
  if (g >= 0.15)return { i:1, emoji:'🌱', name:'sprouting', ready:false };
  return { i:0, emoji:'🌰', name:'just planted', ready:false };
}

/* ---------------------------------------------------------------------
   5. Cat AI — needs, bond, thriving, utility behaviors (§8)
   --------------------------------------------------------------------- */
function bondStageIndex() {
  let idx = 0;
  BOND_STAGES.forEach((s,i)=>{ if (G.cat.bond >= s.min) idx = i; });
  return idx;
}
function placedOf(key) { return G.placed.filter(p=>p.key===key); }
function nearestOf(behavior) {
  let best=null, bestDist=1e9;
  for (const p of G.placed) {
    if (CATALOG[p.key].behavior !== behavior) continue;
    const dx=p.x-G.cat.x, dd=(p.d||0.5)-G.cat.d, dist=dx*dx+dd*dd;
    if (dist<bestDist){bestDist=dist;best=p;}
  }
  return best;
}
function sunbeamPos() {
  const win = placedOf('window')[0];
  if (!win || !isDaylight()) return null;
  return { x: clamp(win.x, 0.15, 0.85), d: 0.34 };
}

// Utility scoring: each behavior scores by need + mood + trait + nearby decor; highest wins,
// with a little noise for surprise. Emergent life, cheaply. (§8)
function chooseAction() {
  const c = G.cat, nd = c.needs;
  const cand = [];
  const trait = c.trait;
  const sb = sunbeamPos();
  const visitor = G.visitor;

  if (sb)                         cand.push({ type:'sunbeam', s: 22 + (trait==='cozy'?14:0) + (100-nd.enrichment)*0.05, pos:sb, dur:16, pose:'sleep' });
  if (placedOf('bed').length)     cand.push({ type:'rest', s: 16 + (trait==='cozy'?8:0) + Math.max(0,(70-c.mood))*0.2, pos:anchor('rest'), dur:14, pose:'sleep' });
  if (placedOf('cushion').length) cand.push({ type:'rest', s: 14 + (trait==='cozy'?6:0), pos:anchor('rest'), dur:12, pose:'sleep' });
  if (placedOf('box').length)     cand.push({ type:'hide', s: 12 + (trait==='shy'?16:0) + (visitor?22:0), pos:anchor('hide'), dur:11, pose:'hide' });
  if (placedOf('tree').length)    cand.push({ type:'climb', s: 12 + (trait==='playful'?18:0), pos:anchor('climb'), dur:8, pose:'climb' });
  if (placedOf('toy').length && nd.enrichment < 70)
                                  cand.push({ type:'play', s: 10 + (100-nd.enrichment)*0.25 + (trait==='playful'?12:0), pos:anchor('play'), dur:6, pose:'play' });
  if (placedOf('foodBowl').length && nd.food < 55)
                                  cand.push({ type:'eat', s: (60-nd.food)*0.7, pos:anchor('eat'), dur:5, pose:'eat' });
  if (placedOf('waterBowl').length && nd.water < 55)
                                  cand.push({ type:'drink', s: (60-nd.water)*0.6, pos:anchor('drink'), dur:4, pose:'eat' });

  // always-available fallbacks
  cand.push({ type:'groom', s: 6 + Math.random()*4, pos:null, dur:5, pose:'groom' });
  cand.push({ type:'wander', s: 5 + Math.random()*5, pos:randSpot(), dur:7, pose:'walk' });
  cand.push({ type:'sit',    s: 5, pos:null, dur:6, pose:'sit' });

  // a shy cat that just saw a visitor strongly prefers hiding
  cand.forEach(a => a.s += Math.random()*3);
  cand.sort((a,b)=>b.s-a.s);
  const pick = cand[0];

  c.action = pick.type;
  c.actTimer = pick.dur;
  c.pose = pick.pose;
  if (pick.pos) { c.tx = pick.pos.x; c.td = pick.pos.d; c.moving = true; }
  else { c.moving = false; }
}
function anchor(behavior){ const p = nearestOf(behavior); return p ? {x:p.x, d:p.d||0.5} : randSpot(); }
function randSpot(){ return { x: 0.18 + Math.random()*0.64, d: 0.35 + Math.random()*0.5 }; }

function updateCat(dt) {
  const c = G.cat, nd = c.needs;

  // Needs decay slowly & forgivingly; never a fail state, just a quieter pet (§8).
  const rate = dt/60;  // per-minute units
  nd.food       = clamp(nd.food       - 2.4*rate, 0, 100);
  nd.water      = clamp(nd.water      - 2.0*rate, 0, 100);
  nd.enrichment = clamp(nd.enrichment - 2.8*rate, 0, 100);

  // Thriving eases toward how well the room matches the cat's comfort profile × Charm gate.
  const charm = charmReport().charm;
  const targetThrive = matchProfile(CAT_PROFILE) * (0.4 + 0.6*charm/100) * 100;
  c.thriving += (targetThrive - c.thriving) * Math.min(1, dt*0.15);

  // Mood blends needs, thriving and a little bond warmth.
  const needAvg = (nd.food+nd.water+nd.enrichment)/3;
  const targetMood = clamp(needAvg*0.5 + c.thriving*0.35 + bondStageIndex()*4, 0, 100);
  c.mood += (targetMood - c.mood) * Math.min(1, dt*0.2);

  // Haven warmth eases up with charm & care — the room visibly revives (§13).
  const targetWarm = clamp(0.25 + charm/180 + c.thriving/300, 0.25, 1);
  G.havenWarmth += (targetWarm - G.havenWarmth) * Math.min(1, dt*0.05);

  // Movement toward target.
  if (c.action == null) chooseAction();
  if (c.moving) {
    const dx=c.tx-c.x, dd=c.td-c.d, dist=Math.hypot(dx,dd);
    if (dist < 0.02) { c.moving=false; }
    else {
      const sp = 0.12*dt;
      c.x += dx/dist*Math.min(sp,dist);
      c.d += dd/dist*Math.min(sp,dist);
      c.facing = dx<0?-1:1;
      c.pose='walk';
    }
  } else {
    c.actTimer -= dt;
    if (c.actTimer <= 0) chooseAction();
  }

  // Bonded+ residents occasionally bring a Trinket while thriving (§8, §10).
  if (bondStageIndex() >= 3 && c.thriving > 55 && Date.now()-c.lastGift > 45000 && Math.random() < dt*0.02) {
    c.lastGift = Date.now(); G.trinkets += 1;
    toast(`💎 ${c.name} brought you a little treasure!`);
  }

  c.blink -= dt; if (c.blink<=0) c.blink = 2+Math.random()*3;
}

// Care actions — bonding interactions, not chores. Soft daily bond ceiling (§8).
function doCare(kind) {
  const c = G.cat;
  const today = new Date().toDateString();
  if (c.bondDay !== today) { c.bondDay = today; c.bondToday = 0; }
  const bondRoom = Math.max(0, 6 - c.bondToday);   // soft daily cap ~6/day

  let msg='';
  if (kind==='feed')  { c.needs.food = clamp(c.needs.food+38,0,100); msg='🍲 A good meal.'; }
  if (kind==='water') { c.needs.water= clamp(c.needs.water+45,0,100);msg='💧 Fresh water.'; }
  if (kind==='play')  { c.needs.enrichment = clamp(c.needs.enrichment+42,0,100); msg='🪶 Play time!'; gainBond(1.2, bondRoom); c.action=null; }
  if (kind==='pet')   { msg='🫳 A slow, happy blink.'; gainBond(2.0, bondRoom); c.mood=clamp(c.mood+6,0,100); }
  if (kind==='feed'||kind==='water') gainBond(0.6, bondRoom);

  toast(msg);
  refreshInspect();
  updateHUD();
}
function gainBond(amt, room) {
  const c = G.cat;
  const give = Math.min(amt, Math.max(0,room));
  if (give<=0) { return; }
  const before = bondStageIndex();
  c.bond = clamp(c.bond + give, 0, 100);
  c.bondToday += give;
  const after = bondStageIndex();
  if (after>before) {
    toast(`💞 ${c.name} is now ${BOND_STAGES[after].name}!`);
  }
}

/* ---------------------------------------------------------------------
   6. Visitor (sparrow) — the ecosystem loop end to end (§9, §16)
   --------------------------------------------------------------------- */
function updateVisitor(dt) {
  if (G.visitor) {
    const v = G.visitor;
    v.timer -= dt;
    // hop around
    if (!v.moving || Math.hypot(v.tx-v.x, v.td-v.d) < 0.02) {
      v.tx = 0.2 + Math.random()*0.6; v.td = 0.45 + Math.random()*0.4; v.moving=true; v.hops++;
    }
    const dx=v.tx-v.x, dd=v.td-v.d, dist=Math.hypot(dx,dd);
    const sp=0.1*dt; v.x+=dx/dist*Math.min(sp,dist); v.d+=dd/dist*Math.min(sp,dist); v.facing=dx<0?-1:1;
    if (v.timer<=0) {
      // Visitor leaves a small "thank-you" tip on the way out (§10).
      if (!v.tipped) { const tip=4+Math.floor(Math.random()*5); G.coins+=tip; toast(`🐦 The sparrow left a thank-you: +${tip} 🪙`); v.tipped=true; }
      G.visitor=null; hideBanner(); updateHUD();
    }
    return;
  }

  // Attraction = tag match × Charm (§4). Accrues a "draw"; when full, a visitor arrives.
  const match = matchProfile(SPARROW_PROFILE);
  const charm = charmReport().charm/100;
  const attraction = match * (0.3 + 0.7*charm);
  if (isDaylight() && attraction > 0.32) {
    G.visitDraw += (attraction-0.3) * dt * 0.6;
  } else {
    G.visitDraw = Math.max(0, G.visitDraw - dt*0.05);
  }
  if (G.visitDraw >= 1) {
    G.visitDraw = 0;
    G.visitor = { x:0.5, d:0.5, tx:0.6, td:0.6, timer:22, hops:0, tipped:false, moving:true, facing:1 };
    showBanner('🐦 A sparrow is visiting! Snap a photo?');
    if (!G.seen.visitor) { G.seen.visitor=true; toast('Your room crossed the sparrow\'s tag threshold — that\'s the spine: the room you built decided who showed up.'); }
  }
}

/* ---------------------------------------------------------------------
   7. Rendering (3/4 diorama, layered, warm) (§15)
   --------------------------------------------------------------------- */
const cv = document.getElementById('game');
const ctx = cv.getContext('2d');
let DPR = 1, flash = 0;

function resize() {
  const r = cv.getBoundingClientRect();
  DPR = Math.min(window.devicePixelRatio||1, 2);
  cv.width = Math.round(r.width*DPR);
  cv.height= Math.round(r.height*DPR);
}
window.addEventListener('resize', resize);

// virtual->screen scale (canvas is drawn in virtual W×H then scaled to fit)
function vscale(){ return Math.min(cv.width/W, cv.height/H); }
function voff(){ const s=vscale(); return { x:(cv.width-W*s)/2, y:(cv.height-H*s)/2, s }; }

const FTOP=H*0.42, FBOT=H*0.88;
function floorPos(x,d){
  const sy=FTOP+(FBOT-FTOP)*d;
  const halfW=(0.60+0.38*d)*W/2;
  const sx=W/2+(x-0.5)*2*halfW;
  return { sx, sy, scale:0.62+0.6*d };
}
function invFloor(px,py){
  let d=clamp((py-FTOP)/(FBOT-FTOP),0,1);
  const halfW=(0.60+0.38*d)*W/2;
  const x=clamp(0.5+(px-W/2)/(2*halfW),0,1);
  return {x,d};
}
function wallPos(x){ return { sx: W*0.10 + x*W*0.80, sy: H*0.14 }; }

function tint(phase){
  switch(phase){
    case 'dawn':  return { sky:'#5a4a6a', amb:'rgba(255,200,150,0.10)', dark:0.18 };
    case 'day':   return { sky:'#6d7fa0', amb:'rgba(255,225,170,0.06)', dark:0.05 };
    case 'dusk':  return { sky:'#7a4a48', amb:'rgba(255,150,90,0.16)',  dark:0.18 };
    default:      return { sky:'#241f3a', amb:'rgba(120,140,220,0.05)', dark:0.42 };
  }
}

function draw() {
  const o=voff();
  ctx.setTransform(1,0,0,1,0,0);
  ctx.clearRect(0,0,cv.width,cv.height);
  ctx.fillStyle='#000'; ctx.fillRect(0,0,cv.width,cv.height);
  ctx.setTransform(o.s,0,0,o.s,o.x,o.y);

  const ph=phaseOf(gameHour());
  const T=tint(ph);

  // --- back wall ---
  const wg=ctx.createLinearGradient(0,0,0,FTOP);
  wg.addColorStop(0, shade('#4a3a52', G.havenWarmth));
  wg.addColorStop(1, shade('#5a4658', G.havenWarmth));
  ctx.fillStyle=wg; ctx.fillRect(0,0,W,FTOP);

  // window light glow on wall (sky color)
  const win=placedOf('window')[0];
  if (win){ const wp=wallPos(win.x);
    ctx.fillStyle=T.sky; roundRect(wp.sx-46,wp.sy-44,92,80,8); ctx.fill();
    if(isDaylight()){ ctx.fillStyle=T.amb; ctx.fillRect(0,0,W,FTOP);} }

  // --- floor ---
  const fg=ctx.createLinearGradient(0,FTOP,0,FBOT);
  fg.addColorStop(0, shade('#6b4f3e', G.havenWarmth));
  fg.addColorStop(1, shade('#8a6a4f', G.havenWarmth));
  ctx.fillStyle=fg; ctx.fillRect(0,FTOP,W,H-FTOP);
  // baseboard
  ctx.fillStyle='rgba(0,0,0,0.18)'; ctx.fillRect(0,FTOP-6,W,8);

  // --- sunbeam patch on floor (daytime + window) ---
  const sb=sunbeamPos();
  if (sb){ const p=floorPos(sb.x,sb.d);
    ctx.save(); ctx.globalAlpha=0.5+0.2*Math.sin(performance.now()/900);
    const grd=ctx.createRadialGradient(p.sx,p.sy,4,p.sx,p.sy,90);
    grd.addColorStop(0,'rgba(255,225,150,0.55)'); grd.addColorStop(1,'rgba(255,225,150,0)');
    ctx.fillStyle=grd; ctx.beginPath(); ctx.ellipse(p.sx,p.sy,80,38,0,0,7); ctx.fill(); ctx.restore(); }

  // --- build a draw list (depth sorted) ---
  const items=[];
  for (const p of G.placed){
    const def=CATALOG[p.key];
    if (def.layer==='wall'){ const wp=wallPos(p.x); items.push({z:-1, draw:()=>emoji(def.emoji, wp.sx, wp.sy, 1.5)}); continue; }
    if (def.layer==='hang'){ const wp=wallPos(p.x); items.push({z:0, draw:()=>emoji(def.emoji, wp.sx, FTOP*0.55, 1.6)}); continue; }
    const fp=floorPos(p.x,p.d); items.push({z:fp.sy, draw:()=>decor(def,fp,p)});
  }
  if (G.plant){ const fp=floorPos(G.plant.x,G.plant.d); const st=plantStage(); items.push({z:fp.sy, draw:()=>emoji(st.emoji, fp.sx, fp.sy, 1.1+st.i*0.15, true)}); }
  // cat
  { const fp=floorPos(G.cat.x,G.cat.d); items.push({z:fp.sy+1, draw:()=>drawCat(fp)}); }
  // visitor
  if (G.visitor){ const fp=floorPos(G.visitor.x,G.visitor.d); items.push({z:fp.sy, draw:()=>drawSparrow(fp)}); }

  items.sort((a,b)=>a.z-b.z);
  items.forEach(it=>it.draw());

  // --- ambient darkening / vignette by time of day ---
  ctx.save();
  ctx.fillStyle=`rgba(10,8,20,${T.dark*(1.1-G.havenWarmth*0.4)})`; ctx.fillRect(0,0,W,H);
  const vg=ctx.createRadialGradient(W/2,H*0.5,H*0.2,W/2,H*0.5,H*0.62);
  vg.addColorStop(0,'rgba(0,0,0,0)'); vg.addColorStop(1,'rgba(0,0,0,0.45)');
  ctx.fillStyle=vg; ctx.fillRect(0,0,W,H);
  ctx.restore();

  // photo flash
  if (flash>0){ ctx.fillStyle=`rgba(255,255,255,${flash})`; ctx.fillRect(0,0,W,H); flash-=0.05; }
}

function shade(hex, warm){
  // nudge a hex color warmer/brighter by warm 0..1
  const c=parseInt(hex.slice(1),16); let r=(c>>16)&255,g=(c>>8)&255,b=c&255;
  r=clamp(r+warm*40,0,255); g=clamp(g+warm*22,0,255); b=clamp(b-warm*10,0,255);
  return `rgb(${r|0},${g|0},${b|0})`;
}
function emoji(ch,x,y,scale=1, base=false){
  ctx.save();
  ctx.globalAlpha=0.28; ctx.fillStyle='#000';
  ctx.beginPath(); ctx.ellipse(x, y+ (base?2:6)*scale, 18*scale, 6*scale,0,0,7); ctx.fill();
  ctx.globalAlpha=1;
  ctx.font=`${30*scale}px serif`; ctx.textAlign='center'; ctx.textBaseline='alphabetic';
  ctx.fillText(ch, x, y);
  ctx.restore();
}
function decor(def,fp,p){
  if (p===G.dragItem){ ctx.save(); ctx.globalAlpha=0.85;
    ctx.strokeStyle='rgba(242,183,101,0.9)'; ctx.lineWidth=2;
    ctx.beginPath(); ctx.ellipse(fp.sx,fp.sy+4*fp.scale,22*fp.scale,8*fp.scale,0,0,7); ctx.stroke(); ctx.restore(); }
  emoji(def.emoji, fp.sx, fp.sy, fp.scale);
}

function drawCat(fp){
  const c=G.cat, s=fp.scale*1.0, x=fp.sx, y=fp.sy;
  const col = c.species==='dog' ? '#c79a5b' : '#d98a4a';
  const dark = c.species==='dog' ? '#a87c40' : '#b86a32';
  ctx.save(); ctx.translate(x,y); ctx.scale(c.facing*s, s);
  // shadow
  ctx.globalAlpha=0.3; ctx.fillStyle='#000'; ctx.beginPath(); ctx.ellipse(0,4,22,7,0,0,7); ctx.fill(); ctx.globalAlpha=1;

  const sleeping = c.pose==='sleep';
  const hiding = c.pose==='hide';
  if (hiding){
    // peeking — just ears + eyes low
    ctx.fillStyle=col; ctx.beginPath(); ctx.ellipse(0,-2,16,9,0,Math.PI,2*Math.PI); ctx.fill();
    ctx.fillStyle=col; tri(-8,-9,-12,-20,-3,-12); tri(8,-9,12,-20,3,-12);
    ctx.fillStyle='#2a1d12'; ctx.beginPath(); ctx.arc(-5,-4,1.6,0,7); ctx.arc(5,-4,1.6,0,7); ctx.fill();
    ctx.restore(); return;
  }
  if (sleeping){
    ctx.fillStyle=col; ctx.beginPath(); ctx.ellipse(0,-4,22,14,0,0,7); ctx.fill();
    // curled tail
    ctx.strokeStyle=dark; ctx.lineWidth=6; ctx.beginPath(); ctx.arc(14,-4,12,-0.4,2.4); ctx.stroke();
    // head tucked
    ctx.fillStyle=col; ctx.beginPath(); ctx.arc(-14,-6,10,0,7); ctx.fill();
    ctx.fillStyle=dark; tri(-20,-12,-23,-22,-15,-15); tri(-9,-13,-6,-23,-13,-16);
    // closed eye
    ctx.strokeStyle='#2a1d12'; ctx.lineWidth=1.4; ctx.beginPath(); ctx.arc(-16,-6,2,0.2,2.9); ctx.stroke();
    // zzz
    ctx.fillStyle='rgba(247,236,223,0.8)'; ctx.font='10px sans-serif'; ctx.scale(c.facing,1);
    ctx.fillText('z',c.facing* -26,-22); ctx.fillText('z',c.facing*-22,-28);
    ctx.restore(); return;
  }

  const bob = c.pose==='walk' ? Math.sin(performance.now()/120)*1.5 : 0;
  const play = c.pose==='play' ? Math.abs(Math.sin(performance.now()/150))*6 : 0;
  ctx.translate(0,-play);
  // tail
  ctx.strokeStyle=dark; ctx.lineWidth=5; ctx.beginPath(); ctx.moveTo(16,-4);
  ctx.quadraticCurveTo(28,-14-bob,22,-26); ctx.stroke();
  // body
  ctx.fillStyle=col; ctx.beginPath(); ctx.ellipse(2,-6+bob,18,13,0,0,7); ctx.fill();
  // legs
  ctx.strokeStyle=dark; ctx.lineWidth=4;
  ctx.beginPath(); ctx.moveTo(-6,4); ctx.lineTo(-6,8+bob); ctx.moveTo(8,4); ctx.lineTo(8,8-bob); ctx.stroke();
  // head
  const hy = c.pose==='eat' ? 2 : -16;
  ctx.fillStyle=col; ctx.beginPath(); ctx.arc(-12, hy+bob, 11, 0,7); ctx.fill();
  // ears
  ctx.fillStyle=dark;
  if (c.species==='dog'){ ctx.beginPath(); ctx.ellipse(-20,hy-2+bob,4,8,0.4,0,7); ctx.ellipse(-4,hy-2+bob,4,8,-0.4,0,7); ctx.fill(); }
  else { tri(-19,hy-6+bob,-22,hy-18+bob,-14,hy-9+bob); tri(-6,hy-7+bob,-3,hy-18+bob,-10,hy-10+bob); }
  // eyes
  const blink = c.blink<0.15;
  ctx.fillStyle='#2a1d12';
  if (blink){ ctx.strokeStyle='#2a1d12'; ctx.lineWidth=1.3; ctx.beginPath(); ctx.moveTo(-16,hy-1+bob); ctx.lineTo(-13,hy-1+bob); ctx.moveTo(-10,hy-1+bob); ctx.lineTo(-7,hy-1+bob); ctx.stroke(); }
  else { ctx.beginPath(); ctx.arc(-14,hy-1+bob,1.8,0,7); ctx.arc(-9,hy-1+bob,1.8,0,7); ctx.fill(); }
  // nose
  ctx.fillStyle=c.species==='dog'?'#3a2a1a':'#e0708a'; ctx.beginPath(); ctx.arc(-11.5,hy+3+bob,1.4,0,7); ctx.fill();
  ctx.restore();
}
function drawSparrow(fp){
  const x=fp.sx, y=fp.sy, s=fp.scale*0.7, v=G.visitor;
  const hop=Math.abs(Math.sin(performance.now()/180))*5;
  ctx.save(); ctx.translate(x,y-hop); ctx.scale(v.facing*s,s);
  ctx.globalAlpha=0.3; ctx.fillStyle='#000'; ctx.beginPath(); ctx.ellipse(0,hop/s+4,9,3,0,0,7); ctx.fill(); ctx.globalAlpha=1;
  ctx.fillStyle='#8a6648'; ctx.beginPath(); ctx.ellipse(0,0,11,8,0,0,7); ctx.fill();
  ctx.fillStyle='#6b4e36'; ctx.beginPath(); ctx.moveTo(8,-2); ctx.lineTo(20,2); ctx.lineTo(8,5); ctx.fill(); // tail
  ctx.fillStyle='#9c7a58'; ctx.beginPath(); ctx.arc(-9,-5,6,0,7); ctx.fill(); // head
  ctx.fillStyle='#e0a030'; tri(-15,-5,-20,-4,-15,-2); // beak
  ctx.fillStyle='#1a120a'; ctx.beginPath(); ctx.arc(-11,-6,1.3,0,7); ctx.fill();
  ctx.restore();
}
function tri(x1,y1,x2,y2,x3,y3){ ctx.beginPath(); ctx.moveTo(x1,y1); ctx.lineTo(x2,y2); ctx.lineTo(x3,y3); ctx.closePath(); ctx.fill(); }
function roundRect(x,y,w,h,r){ ctx.beginPath(); ctx.moveTo(x+r,y); ctx.arcTo(x+w,y,x+w,y+h,r); ctx.arcTo(x+w,y+h,x,y+h,r); ctx.arcTo(x,y+h,x,y,r); ctx.arcTo(x,y,x+w,y,r); ctx.closePath(); }

/* ---------------------------------------------------------------------
   8. Input
   --------------------------------------------------------------------- */
let tool = 'inspect';
let pending = null;        // catalog key awaiting placement
G_dragInit();
function G_dragInit(){}

function canvasPoint(ev){
  const r=cv.getBoundingClientRect();
  const o=voff();
  const px=( (ev.clientX-r.left)*DPR - o.x )/o.s;
  const py=( (ev.clientY-r.top )*DPR - o.y )/o.s;
  return {px,py};
}
function hitDecor(px,py){
  // topmost (largest z) floor item within radius
  let best=null,bestZ=-1;
  for (const p of G.placed){
    const def=CATALOG[p.key]; if (def.layer!=='floor'||def.starter&&p.key!=='bed'&&p.key!=='box') {/*allow drag of most*/}
    if (def.layer!=='floor') continue;
    const fp=floorPos(p.x,p.d);
    if (Math.hypot(px-fp.sx,py-(fp.sy-12))<26*fp.scale){ if(fp.sy>bestZ){bestZ=fp.sy;best=p;} }
  }
  return best;
}

let pointerDown=false, dragMoved=false;
cv.addEventListener('pointerdown', e=>{
  if (!G.onboarded) return;
  pointerDown=true; dragMoved=false;
  const {px,py}=canvasPoint(e);

  if (pending){ placePending(px,py); return; }

  // start dragging a placed item (build or inspect tool)
  const hit=hitDecor(px,py);
  if (hit){ G.dragItem=hit; G.dragOff={dx:0,dy:0}; }
});
cv.addEventListener('pointermove', e=>{
  if (!pointerDown||!G.dragItem) return;
  dragMoved=true;
  const {px,py}=canvasPoint(e);
  const inv=invFloor(px,py+12);
  G.dragItem.x=inv.x; G.dragItem.d=inv.d;
});
cv.addEventListener('pointerup', e=>{
  pointerDown=false;
  if (G.dragItem){ if(dragMoved){ updateEco(); save(); } G.dragItem=null; return; }
  // tap on cat -> open inspect
  if (!G.onboarded) return;
  const {px,py}=canvasPoint(e);
  const fp=floorPos(G.cat.x,G.cat.d);
  if (Math.hypot(px-fp.sx,py-(fp.sy-14))<40){ setTool('inspect'); openSheet('inspectSheet'); }
});

function placePending(px,py){
  const def=CATALOG[pending];
  const cost=def.cost, cur=def.cur;
  if ((cur==='coin'?G.coins:G.trinkets) < cost){ toast('Not enough '+(cur==='coin'?'Coins':'Trinkets')); return; }
  let item;
  if (def.layer==='wall'||def.layer==='hang'){ const x=clamp((px)/W,0.08,0.92); item={key:pending,x,d:0}; }
  else { const inv=invFloor(px,py+12); item={key:pending,x:inv.x,d:inv.d}; }
  item.id=Math.random().toString(36).slice(2);
  G.placed.push(item);
  if (cur==='coin') G.coins-=cost; else G.trinkets-=cost;
  toast(`Placed ${def.name}.`);
  pending=null; hidePlaceHint();
  // re-pick the cat's action so it reacts to the new item promptly (decoration -> behavior)
  G.cat.action=null;
  updateEco(); updateHUD(); save();
}

/* ---------------------------------------------------------------------
   9. UI wiring
   --------------------------------------------------------------------- */
const $=id=>document.getElementById(id);

function setTool(t){
  document.querySelectorAll('.tool').forEach(el=>el.classList.toggle('active', el.dataset.tool===t));
  tool=t;
  closeSheets();
  if (pending){ pending=null; hidePlaceHint(); }
  if (t==='inspect') openSheet('inspectSheet');
  if (t==='build')  { openSheet('shopSheet'); buildShop(); G.seen.shop=true; }
  if (t==='plant')  { openSheet('plantSheet'); buildPlant(); G.seen.plant=true; }
  if (t==='gallery'){ openSheet('gallerySheet'); buildGallery(); }
  if (t==='photo')  { takePhoto(); setTool('inspect'); }
}
document.querySelectorAll('.tool').forEach(el=>el.addEventListener('click',()=>setTool(el.dataset.tool)));
document.querySelectorAll('[data-close]').forEach(el=>el.addEventListener('click', closeSheets));
document.querySelectorAll('.care').forEach(el=>el.addEventListener('click',()=>doCare(el.dataset.care)));
$('placeCancel').addEventListener('click',()=>{ pending=null; hidePlaceHint(); });
$('clockChip').addEventListener('click',()=>{ G.timeOffsetH=(G.timeOffsetH+3)%24; updateHUD(); toast('⏩ (demo) time advanced 3h'); });

function openSheet(id){ closeSheets(); $(id).classList.add('open'); if(id==='inspectSheet') refreshInspect(); }
function closeSheets(){ document.querySelectorAll('.sheet').forEach(s=>s.classList.remove('open')); }

function buildShop(){
  const g=$('shopGrid'); g.innerHTML='';
  for (const key of BUYABLE){
    const d=CATALOG[key]; const have=(d.cur==='coin'?G.coins:G.trinkets);
    const can=have>=d.cost; const count=placedOf(key).length;
    const tagStr=Object.entries(d.tags||{}).map(([k,v])=>`${k[0].toUpperCase()}+${v}`).join(' ')||'decor';
    const div=document.createElement('div');
    div.className='card'+(can?'':' cant');
    div.innerHTML=`<div class="em">${d.emoji}</div><div class="nm">${d.name}${count?` ·${count}`:''}</div>
      <div class="pr">${d.cost} ${d.cur==='coin'?'🪙':'💎'}</div><div class="tg">${tagStr}</div>`;
    div.addEventListener('click',()=>{
      if (!can){ toast('Not enough '+(d.cur==='coin'?'Coins':'Trinkets')); return; }
      pending=key; closeSheets(); showPlaceHint(`Tap the room to place the ${d.name}.`);
    });
    g.appendChild(div);
  }
}
function buildPlant(){
  const b=$('plantBody');
  if (!G.plant){
    b.innerHTML=`<div style="text-align:center;padding:8px 0;">
      <div style="font-size:40px">🌰</div>
      <p class="sub" style="margin:8px 0">Plant a <b>catmint</b> seed. It adds greenery and grows on the real clock
      <span class="flag">(prototype: ~3 min to mature)</span>. A mature plant yields a sellable harvest your cat helps boost.</p>
      <button class="btn" id="plantBtn">Plant seed — 20 🪙</button></div>`;
    $('plantBtn').addEventListener('click',()=>{
      if (G.coins<20){ toast('Not enough Coins'); return; }
      G.coins-=20; const spot=randSpot(); G.plant={ lastHarvest:Date.now(), x:spot.x, d:0.45+Math.random()*0.3 };
      G.cat.action=null; updateEco(); updateHUD(); buildPlant(); save(); toast('🌱 Seed planted!');
    });
    return;
  }
  const st=plantStage(); const g=Math.round(plantGrowth()*100);
  const remain=Math.max(0,Math.ceil(PLANT_MATURE_S*(1-plantGrowth())));
  b.innerHTML=`<div style="text-align:center;padding:6px 0;">
    <div style="font-size:48px">${st.emoji}</div>
    <div class="stage-label" style="color:var(--green)">${st.name}</div>
    <div class="bar" style="margin:10px 4px"><i style="width:${g}%;background:linear-gradient(90deg,#5d8a4a,var(--green))"></i></div>
    ${st.ready?`<button class="btn" id="harvestBtn">Harvest 🌼</button>`
      :`<p class="sub">Ready in ~${remain}s. Greenery rises as it grows.</p>`}
    <p class="mini-note">Greenery from this plant: feeds the room's tags and helps draw the sparrow.</p></div>`;
  if (st.ready) $('harvestBtn').addEventListener('click',()=>{
    const loved = G.cat.thriving>50; const yield_=loved?28:18;
    G.coins+=yield_; G.plant.lastHarvest=Date.now();
    toast(`🌼 Harvested catmint: +${yield_} 🪙${loved?' (your cat boosted the yield!)':''}`);
    updateHUD(); buildPlant(); save();
  });
}
function buildGallery(){
  const g=$('galGrid'); g.innerHTML='';
  $('galEmpty').style.display = G.photos.length? 'none':'block';
  G.photos.slice().reverse().forEach(p=>{
    const d=document.createElement('div'); d.className='photo';
    d.innerHTML=`<img src="${p.img}"/><div class="pay">+${p.pay} 🪙</div><div class="cap">${p.cap}</div>`;
    g.appendChild(d);
  });
}

function tellsFor(){
  const c=G.cat, nd=c.needs;
  const where = ()=>{ const a=c.action; return a; };
  let line='';
  switch(c.action){
    case 'sunbeam': line=`<b>${c.name}</b> is stretched out in the sunbeam, half-asleep and content.`; break;
    case 'rest':    line=`<b>${c.name}</b> is curled up, dozing in a soft spot.`; break;
    case 'hide':    line=G.visitor?`<b>${c.name}</b> ducked into the box — a little wary of the visitor.`:`<b>${c.name}</b> is tucked into the box, just watching.`; break;
    case 'climb':   line=`<b>${c.name}</b> scrambled up the cat tree, surveying the room.`; break;
    case 'play':    line=`<b>${c.name}</b> is pouncing on the feather toy!`; break;
    case 'eat':     line=`<b>${c.name}</b> is eating.`; break;
    case 'drink':   line=`<b>${c.name}</b> is having a drink.`; break;
    case 'groom':   line=`<b>${c.name}</b> is grooming, calm and unhurried.`; break;
    case 'walk':    line=`<b>${c.name}</b> is padding across the room.`; break;
    default:        line=`<b>${c.name}</b> sits quietly, watching you.`;
  }
  // need-driven tells layered on top (reading the pet, not the bars)
  let hint='';
  if (nd.food<35)  hint=` Keeps glancing at the food bowl — getting hungry.`;
  else if (nd.water<35) hint=` Lingering by the water bowl.`;
  else if (nd.enrichment<35) hint=` A bit restless — could use some play.`;
  else if (c.thriving>65) hint=` Looks like they're really thriving here.`;
  return line+hint;
}
function refreshInspect(){
  const c=G.cat;
  $('catName').textContent=c.name||'Your cat';
  const si=bondStageIndex();
  $('bondStage').textContent=`${BOND_STAGES[si].name} · ${TRAITS[c.trait].label}`;
  $('bondFill').style.width=`${c.bond}%`;
  $('tellsText').innerHTML=tellsFor();
  // needs (gentle indicators — these would fade with bond in the full game)
  const nb=$('needsBody');
  const rows=[['Food','🍲','food'],['Water','💧','water'],['Enrichment','🪶','enrichment']];
  nb.innerHTML=rows.map(([lab,ic,k])=>{
    const v=Math.round(c.needs[k]); const col=v>60?'var(--good)':v>30?'var(--warn)':'var(--rose)';
    return `<div class="needrow"><div class="nlab">${ic} ${lab}</div>
      <div class="bar"><i style="width:${v}%;background:${col}"></i></div></div>`;
  }).join('') + `<div class="needrow"><div class="nlab">✨ Thriving</div>
      <div class="bar"><i style="width:${Math.round(c.thriving)}%;background:linear-gradient(90deg,var(--gold-deep),var(--gold))"></i></div></div>`;
  // play disabled if no toy
  $$('.care').forEach(el=>{
    if (el.dataset.care==='play') el.classList.toggle('disabled', !placedOf('toy').length);
    if (el.dataset.care==='feed') el.classList.toggle('disabled', !placedOf('foodBowl').length);
    if (el.dataset.care==='water')el.classList.toggle('disabled', !placedOf('waterBowl').length);
  });
}
function $$(s){ return Array.from(document.querySelectorAll(s)); }

function updateHUD(){
  $('coinVal').textContent=Math.floor(G.coins);
  $('trinketVal').textContent=Math.floor(G.trinkets);
  const h=gameHour(); const ph=phaseOf(h);
  const icon={dawn:'🌅',day:'🌤️',dusk:'🌆',night:'🌙'}[ph];
  $('clockIcon').textContent=icon;
  const hh=Math.floor(h), mm=Math.floor((h-hh)*60);
  $('clockVal').textContent=`${String(hh).padStart(2,'0')}:${String(mm).padStart(2,'0')}`+(G.timeOffsetH?' ·demo':'');
}
function updateEco(){
  const r=charmReport();
  $('charmVal').textContent=r.charm;
  $('charmFill').style.width=`${r.charm}%`;
  $('charmTip').textContent=r.tip;
  const rt=roomTags();
  const max=12;
  $('tagBars').innerHTML=TAGS.map(t=>{
    const v=clamp((rt[t]||0)/max,0,1)*100;
    const col={warmth:'var(--gold)',greenery:'var(--green)',softness:'var(--rose)',hiding:'#9b87d6'}[t];
    return `<div class="tagrow"><span>${t}</span></div><div class="bar"><i style="width:${v}%;background:${col}"></i></div>`;
  }).join('');
}

/* toast + banners */
let toastT=null;
function toast(msg){ const el=$('toast'); el.innerHTML=msg; el.classList.add('show');
  clearTimeout(toastT); toastT=setTimeout(()=>el.classList.remove('show'),3200); }
function showBanner(msg){ const b=$('visitBanner'); b.innerHTML=msg; b.style.display='flex'; }
function hideBanner(){ $('visitBanner').style.display='none'; }
function showPlaceHint(msg){ $('placeHintText').textContent=msg; $('placeHint').style.display='flex'; }
function hidePlaceHint(){ $('placeHint').style.display='none'; }

/* ---------------------------------------------------------------------
   10. Photography → Coins (§10)
   --------------------------------------------------------------------- */
function takePhoto(){
  flash=0.9;
  draw(); // ensure current frame
  // capture
  const tmp=document.createElement('canvas'); tmp.width=300; tmp.height=Math.round(300*H/W);
  const tctx=tmp.getContext('2d');
  // redraw a clean frame (without flash) into the thumbnail by copying current canvas
  tctx.drawImage(cv, 0,0, cv.width, cv.height, 0,0, tmp.width, tmp.height);
  const img=tmp.toDataURL('image/jpeg',0.7);

  const c=G.cat; const charm=charmReport().charm;
  const interesting=['sunbeam','play','climb','hide','rest'].includes(c.action);
  let pay=8;
  let capParts=[];
  if (interesting) pay+=6;
  if (G.visitor){ pay+=14; capParts.push('with a visiting sparrow'); }
  pay+=Math.round(charm/6);
  pay+=Math.round(bondStageIndex()*2);
  const actCap={sunbeam:'napping in the sunbeam',rest:'curled up cozy',hide:'peeking from the box',
    climb:'up on the cat tree',play:'mid-pounce',eat:'at the bowl',groom:'grooming',walk:'on the move'}[c.action]||'looking regal';
  const cap=`${c.name} ${actCap}${capParts.length?' '+capParts.join(' '):''} · Charm ${charm}`;
  G.coins+=pay;
  G.photos.push({ img, cap, pay });
  if (G.photos.length>24) G.photos.shift();
  toast(`📷 Sold to the Gazette: +${pay} 🪙`);
  updateHUD(); save();
}

/* ---------------------------------------------------------------------
   11. Onboarding (§13) — hook before teach
   --------------------------------------------------------------------- */
function runIntro(){
  const el=$('intro'); let step=0;
  const species={val:'cat'};
  function render(){
    if (step===0){
      el.innerHTML=`<div class="big">🏚️</div><h1>The Waystation</h1>
        <p>You've inherited a quiet little haven at a crossroads, where wandering creatures stop to rest.</p>
        <p>It's fallen dim and sleepy. Time to wake it up.</p>
        <button class="btn" id="next">There's a knock at the door…</button>`;
      $('next').onclick=()=>{ step=1; render(); };
    } else if (step===1){
      el.innerHTML=`<h1>Who's there?</h1>
        <p>A small traveler, cold and shy, looking for somewhere warm. Will you let them in?</p>
        <div class="choiceRow">
          <div class="choice" data-sp="cat"><div class="big">🐱</div>A cat</div>
          <div class="choice" data-sp="dog"><div class="big">🐶</div>A dog</div>
        </div>`;
      el.querySelectorAll('.choice').forEach(ch=>ch.onclick=()=>{ species.val=ch.dataset.sp; step=2; render(); });
    } else if (step===2){
      el.innerHTML=`<div class="big">${species.val==='dog'?'🐶':'🐱'}</div>
        <h1>You let them in.</h1><p>They pad inside and look up at you. What will you call your new friend?</p>
        <input id="nameInput" maxlength="14" placeholder="${species.val==='dog'?'Biscuit':'Mochi'}"/>
        <button class="btn" id="next">That's the one</button>`;
      $('next').onclick=()=>{
        const nm=$('nameInput').value.trim()|| (species.val==='dog'?'Biscuit':'Mochi');
        G.cat.name=nm; G.cat.species=species.val;
        G.cat.trait = ['cozy','playful','shy'][Math.floor(Math.random()*3)];
        step=3; render();
      };
    } else if (step===3){
      el.innerHTML=`<div class="big">🧺</div><h1>Make a cozy spot</h1>
        <p>The old keeper left you a soft <b>bed</b>. Set it down somewhere — your friend will find it.</p>
        <p class="mini-note">This is the whole game in miniature: <b>what you place shapes what your pet does.</b></p>
        <button class="btn" id="next">Place the bed</button>`;
      $('next').onclick=()=>{
        // grant starters, enter guided placement of the bed
        el.classList.add('hidden');
        G.placed=[
          {key:'foodBowl',x:0.72,d:0.78,id:'fb'},
          {key:'waterBowl',x:0.82,d:0.72,id:'wb'},
        ];
        G.coins=40; // a little seed money so the shop is explorable after onboarding
        pending='bed'; showPlaceHint(`Tap the room to set down ${G.cat.name}'s bed.`);
        guideBed=true; updateEco(); updateHUD();
      };
    }
  }
  render();
}
let guideBed=false;

// hook the guided bed placement to finish onboarding
const _placePending = placePending;
placePending = function(px,py){
  const wasBed = guideBed && pending==='bed';
  _placePending(px,py);
  if (wasBed && !pending){
    guideBed=false;
    // send the cat straight to the bed so decoration->behavior is felt instantly
    G.cat.action='rest'; G.cat.pose='walk'; G.cat.moving=true;
    const bed=placedOf('bed')[0]; if(bed){ G.cat.tx=bed.x; G.cat.td=bed.d; }
    setTimeout(()=>{
      toast(`💞 ${G.cat.name} curls up in the new bed. The haven feels a little warmer already.`);
    },1600);
    setTimeout(()=>{
      G.onboarded=true; save();
      toast('Try 📷 to photograph the moment — the Gazette pays Coins. Then 🛋️ Decorate to shape who visits.');
      setTimeout(()=>{ setTool('inspect'); }, 400);
    },4200);
  }
};

/* ---------------------------------------------------------------------
   12. Boot + main loop
   --------------------------------------------------------------------- */
function clamp(v,a,b){ return v<a?a:v>b?b:v; }

function boot(){
  resize();
  const had=load();
  if (!had){ G=freshState(); }
  applyOffline();

  updateHUD(); updateEco();
  if (!G.onboarded){ runIntro(); }
  else { $('intro').classList.add('hidden'); setTool('inspect'); closeSheets(); }

  let last=performance.now();
  function frame(now){
    let dt=(now-last)/1000; last=now; dt=Math.min(dt,0.1);
    if (G.onboarded){ updateCat(dt); updateVisitor(dt); }
    else { G.cat.blink-=dt; if(G.cat.blink<=0)G.cat.blink=2+Math.random()*3;
           if(G.cat.moving){ const c=G.cat,dx=c.tx-c.x,dd=c.td-c.d,di=Math.hypot(dx,dd);
             if(di<0.02)c.moving=false; else{const sp=0.12*dt;c.x+=dx/di*Math.min(sp,di);c.d+=dd/di*Math.min(sp,di);c.facing=dx<0?-1:1;c.pose='walk';} } }
    draw();
    // periodic UI refresh
    if (!frame.acc) frame.acc=0; frame.acc+=dt;
    if (frame.acc>0.5){ frame.acc=0; updateHUD(); updateEco();
      if ($('inspectSheet').classList.contains('open')) refreshInspect();
      if ($('plantSheet').classList.contains('open') && G.plant) buildPlant(); }
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);

  setInterval(save, 8000);
  window.addEventListener('beforeunload', save);
}
boot();
