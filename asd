<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>Mario Vocab Mini-Game</title>
<style>
  :root{
    --bg:#0b1020;
    --card:#121a33;
    --accent:#6c63ff;
    --good:#38d46a;
    --bad:#ff5a6b;
    --text:#f3f5ff;
    --muted:#b9c0ff;
    --line:rgba(255,255,255,.12);
  }
  *{box-sizing:border-box}
  body{
    margin:0;
    font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
    background: radial-gradient(1000px 600px at 50% -10%, #1a2b7a 0%, var(--bg) 60%);
    color:var(--text);
    padding:22px;
  }
  .wrap{max-width:900px;margin:0 auto;}
  .hud{
    display:flex; gap:12px; flex-wrap:wrap; align-items:center;
    margin-bottom:14px;
  }
  .pill{
    background:rgba(255,255,255,.08);
    border:1px solid var(--line);
    border-radius:999px;
    padding:8px 12px;
    font-weight:700;
  }
  .bar{
    flex:1;
    min-width:180px;
    background:rgba(255,255,255,.08);
    border:1px solid var(--line);
    border-radius:999px;
    overflow:hidden;
    height:12px;
  }
  .bar > div{
    height:100%;
    width:0%;
    background:linear-gradient(90deg, var(--accent), #5fe1ff);
    transition:width .25s ease;
  }

  .card{
    background:rgba(18,26,51,.92);
    border:1px solid var(--line);
    border-radius:18px;
    padding:18px;
    box-shadow: 0 18px 40px rgba(0,0,0,.35);
  }
  .title{
    display:flex; justify-content:space-between; gap:10px; flex-wrap:wrap;
    align-items:flex-start;
    margin-bottom:8px;
  }
  h1{margin:0;font-size:20px}
  .small{color:var(--muted);margin:0;font-size:14px}

  .levelRow{
    display:flex; gap:10px; align-items:center; flex-wrap:wrap;
    margin:14px 0 10px;
  }
  .pipe{
    height:10px; width:100%;
    background:rgba(255,255,255,.08);
    border:1px solid var(--line);
    border-radius:999px;
    overflow:hidden;
  }
  .pipe > div{
    height:100%;
    width:0%;
    background:linear-gradient(90deg, #3bff7a, #ffe45f);
    transition:width .25s ease;
  }

  .question{
    margin:14px 0 10px;
    font-size:18px;
    line-height:1.3;
  }
  .grid{
    display:grid;
    grid-template-columns:1fr;
    gap:10px;
    margin-top:10px;
  }
  @media (min-width:720px){ .grid{grid-template-columns:1fr 1fr;} }

  .btn{
    width:100%;
    text-align:left;
    padding:12px 12px;
    border-radius:14px;
    border:1px solid var(--line);
    background:rgba(255,255,255,.06);
    color:var(--text);
    font-weight:700;
    cursor:pointer;
    transition:transform .05s ease, background .2s ease, border-color .2s ease;
  }
  .btn:hover{ background:rgba(255,255,255,.10); }
  .btn:active{ transform:scale(.99); }
  .btn[disabled]{ opacity:.65; cursor:not-allowed; }

  .btn.correct{ border-color: rgba(56,212,106,.9); background: rgba(56,212,106,.18); }
  .btn.wrong{ border-color: rgba(255,90,107,.9); background: rgba(255,90,107,.18); }

  .toast{
    margin-top:12px;
    padding:12px;
    border-radius:14px;
    border:1px solid var(--line);
    background:rgba(0,0,0,.25);
    display:none;
  }
  .toast.good{ display:block; border-color:rgba(56,212,106,.6); }
  .toast.bad{ display:block; border-color:rgba(255,90,107,.6); }
  .controls{
    display:flex; gap:10px; flex-wrap:wrap;
    margin-top:14px;
  }
  .control{
    padding:10px 12px;
    border-radius:14px;
    border:1px solid var(--line);
    background:rgba(255,255,255,.08);
    color:var(--text);
    font-weight:800;
    cursor:pointer;
  }
  .control.primary{ background:var(--accent); border-color:transparent; }
  .coin{
    display:inline-block; margin-right:6px;
    filter: drop-shadow(0 2px 8px rgba(255,228,95,.35));
  }
</style>
</head>

<body>
<div class="wrap">
  <div class="hud">
    <div class="pill">🍄 Level: <span id="level">1</span></div>
    <div class="pill"><span class="coin">🪙</span>Coins: <span id="coins">0</span></div>
    <div class="pill">❤️ Lives: <span id="lives">3</span></div>
    <div class="bar" aria-label="Progress"><div id="progress"></div></div>
  </div>

  <div class="card">
    <div class="title">
      <div>
        <h1>Mario Vocab — Choose the correct meaning</h1>
        <p class="small">Answer correctly to collect coins. 3 mistakes = game over.</p>
      </div>
      <div class="pill">Question <span id="qNum">1</span>/<span id="qTotal">10</span></div>
    </div>

    <div class="levelRow">
      <div class="small">🏁 Pipe progress</div>
      <div class="pipe"><div id="pipeFill"></div></div>
    </div>

    <div class="question" id="questionText">Loading...</div>
    <div class="grid" id="options"></div>

    <div class="toast" id="toast"></div>

    <div class="controls">
      <button class="control primary" id="nextBtn" disabled>Next ▶</button>
      <button class="control" id="restartBtn">Restart ↻</button>
    </div>
  </div>
</div>

<script>
/* ✅ EDIT HERE: your vocabulary game questions
   prompt = definition, answer = correct adjective
*/
const QUESTIONS = [
  { prompt: "Having confidence in yourself and your abilities.", answer: "self-confident" },
  { prompt: "Thinking only about one goal you want to achieve.", answer: "single-minded" },
  { prompt: "Not easily upset by negative comments.", answer: "thick-skinned" },
  { prompt: "Relaxed and happy; not worried.", answer: "easy-going" },
  { prompt: "Behaving in an acceptable and polite way.", answer: "well-behaved" },
  { prompt: "Able to think fast and make clever comments.", answer: "quick-witted" },
  { prompt: "Cheerful and not serious.", answer: "light-hearted" },
  { prompt: "Rude; not showing respect.", answer: "bad-mannered" },
  { prompt: "Willing to accept new ideas.", answer: "open-minded" },
  { prompt: "Putting a lot of effort into work or study.", answer: "hard-working" }
];

const ALL_WORDS = [...new Set(QUESTIONS.map(q => q.answer))];

function shuffle(arr){
  const a = arr.slice();
  for(let i=a.length-1;i>0;i--){
    const j = Math.floor(Math.random()*(i+1));
    [a[i],a[j]] = [a[j],a[i]];
  }
  return a;
}

let order = [];
let index = 0;
let coins = 0;
let lives = 3;
let level = 1;
let locked = false;

const levelEl = document.getElementById("level");
const coinsEl = document.getElementById("coins");
const livesEl = document.getElementById("lives");
const qNumEl = document.getElementById("qNum");
const qTotalEl = document.getElementById("qTotal");
const progressEl = document.getElementById("progress");
const pipeFill = document.getElementById("pipeFill");
const questionText = document.getElementById("questionText");
const optionsEl = document.getElementById("options");
const toast = document.getElementById("toast");
const nextBtn = document.getElementById("nextBtn");
const restartBtn = document.getElementById("restartBtn");

qTotalEl.textContent = QUESTIONS.length;

function makeChoices(correct){
  const distractors = shuffle(ALL_WORDS.filter(w => w !== correct)).slice(0,3);
  return shuffle([correct, ...distractors]);
}

function setHUD(){
  levelEl.textContent = level;
  coinsEl.textContent = coins;
  livesEl.textContent = lives;
  qNumEl.textContent = Math.min(index+1, QUESTIONS.length);
  const pct = (index / QUESTIONS.length) * 100;
  progressEl.style.width = pct + "%";
  pipeFill.style.width = ((index % 5) / 5) * 100 + "%"; // 5 questions per "level"
}

function showToast(type, msg){
  toast.className = "toast " + type;
  toast.innerHTML = msg;
}

function clearToast(){
  toast.className = "toast";
  toast.style.display = "none";
}

function loadQuestion(){
  locked = false;
  nextBtn.disabled = true;
  optionsEl.innerHTML = "";
  toast.style.display = "none";

  if(index >= QUESTIONS.length){
    // WIN
    questionText.innerHTML = `🏆 You finished! Coins: <b>${coins}</b>. Great job!`;
    showToast("good", "🎉 Level complete! Click Restart to play again.");
    nextBtn.disabled = true;
    return;
  }

  const q = QUESTIONS[order[index]];
  questionText.textContent = "❓ " + q.prompt;

  const choices = makeChoices(q.answer);
  choices.forEach(choice => {
    const btn = document.createElement("button");
    btn.className = "btn";
    btn.textContent = choice;
    btn.addEventListener("click", () => chooseAnswer(btn, choice, q.answer));
    optionsEl.appendChild(btn);
  });

  setHUD();
}

function chooseAnswer(btn, chosen, correct){
  if(locked) return;
  locked = true;

  const buttons = [...document.querySelectorAll(".btn")];
  buttons.forEach(b => b.disabled = true);

  if(chosen === correct){
    btn.classList.add("correct");
    coins += 1;
    showToast("good", "🪙 +1 coin! <b>Correct!</b>");
  } else {
    btn.classList.add("wrong");
    lives -= 1;
    // highlight correct
    const correctBtn = buttons.find(b => b.textContent === correct);
    if(correctBtn) correctBtn.classList.add("correct");
    showToast("bad", `❌ Wrong. The correct answer is <b>${correct}</b>.`);
  }

  coinsEl.textContent = coins;
  livesEl.textContent = lives;

  if(lives <= 0){
    questionText.innerHTML = "💀 Game Over! You lost all lives.";
    showToast("bad", "Try again — click Restart ↻");
    nextBtn.disabled = true;
    return;
  }

  // Level up every 5 questions
  const nextIndex = index + 1;
  if(nextIndex % 5 === 0 && nextIndex < QUESTIONS.length){
    level += 1;
    pipeFill.style.width = "100%";
  }

  nextBtn.disabled = false;
}

nextBtn.addEventListener("click", () => {
  if(index < QUESTIONS.length){
    index += 1;
    loadQuestion();
  }
});

restartBtn.addEventListener("click", () => {
  order = shuffle([...Array(QUESTIONS.length).keys()]);
  index = 0;
  coins = 0;
  lives = 3;
  level = 1;
  loadQuestion();
});

restartBtn.click(); // auto start
</script>
</body>
</html>
