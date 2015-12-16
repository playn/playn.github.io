---
layout: gallery
---

<style>
ul.thumbs {
  list-style-type: none;
  margin: 0;
  padding: 0;
  text-align: center;
}

ul.thumbs li {
  display: inline-block;
  height: 150px;
  margin: 0;
  position: relative;
}

ul.thumbs li:hover span.thumb-text {
  opacity: 1;
}

ul.thumbs img {
  height: 150px;
}

span.thumb-text {
  background: rgba(0,0,0,0.5);
  color: white;
  opacity: 0;
  font-size: x-large;
  cursor: pointer;
  display: table;
  left: 0;
  top: 0;
  position: absolute;
  width: 100%;
  height: 150px;
  -webkit-transition: opacity 300ms;
  -moz-transition: opacity 300ms;
  -o-transition: opacity 300ms;
  transition: opacity 300ms;
}

span.thumb-text span {
  display: table-cell;
  text-align: center;
  vertical-align: middle;
}
</style>

# Gallery

Here are many fine games made using PlayN. Click any image for more details.

<ul class="thumbs">
  <li><a href="pyramid-solitaire">
    <img src="pyramid-solitaire/thumb.jpg">
    <span class="thumb-text"><span>Pyramid Solitaire</span></span>
  </a></li>

  <li><a href="tupsu">
    <img src="tupsu/thumb.jpg">
    <span class="thumb-text"><span>Tupsu</span></span>
  </a></li>

  <li><a href="spellwood">
    <img src="spellwood/thumb.jpg">
    <span class="thumb-text"><span>Spellwood</span></span>
  </a></li>

  <li><a href="everything">
    <img src="everything/thumb.jpg">
    <span class="thumb-text"><span>The Everything Game</span></span>
  </a></li>

  <li><a href="smbbounce">
    <img src="smbbounce/thumb.jpg">
    <span class="thumb-text"><span>Super Monkey Ball Bounce</span></span>
  </a></li>

  <li><a href="pokeros">
    <img src="pokeros/thumb.jpg">
    <span class="thumb-text"><span>Pokeros</span></span>
  </a></li>

  <li><a href="darkattack">
    <img src="darkattack/thumb.jpg">
    <span class="thumb-text"><span>DarkAttack</span></span>
  </a></li>

  <li><a href="frogger">
    <img src="frogger/thumb.jpg">
    <span class="thumb-text"><span>Frogger</span></span>
  </a></li>

  <li><a href="coreminer">
    <img src="coreminer/thumb.jpg">
    <span class="thumb-text"><span>Core Miner</span></span>
  </a></li>

  <li><a href="thelidia-asteroids">
    <img src="thelidia-asteroids/thumb.jpg">
    <span class="thumb-text"><span>Thelidia Asteroid Attack</span></span>
  </a></li>

  <li><a href="unscramble">
    <img src="unscramble/thumb.jpg">
    <span class="thumb-text"><span>Unscramble This</span></span>
  </a></li>

  <li><a href="bobbyjumps">
    <img src="bobbyjumps/thumb.jpg">
    <span class="thumb-text"><span>Bobby Jumps</span></span>
  </a></li>

  <li><a href="huizbrett">
    <img src="huizbrett/thumb.jpg">
    <span class="thumb-text"><span>Huizbrett</span></span>
  </a></li>

  <li><a href="gravityrun">
    <img src="gravityrun/thumb.jpg">
    <span class="thumb-text"><span>Gravity Run</span></span>
  </a></li>

  <li><a href="ufoinvasion">
    <img src="ufoinvasion/thumb.jpg">
    <span class="thumb-text"><span>UFO Invasion</span></span>
  </a></li>

  <li><a href="magiccards">
    <img src="magiccards/thumb.jpg">
    <span class="thumb-text"><span>Magic Cards</span></span>
  </a></li>

  <li><a href="sheepshooter">
    <img src="sheepshooter/thumb.jpg">
    <span class="thumb-text"><span>Sheep Shooter</span></span>
  </a></li>

  <li><a href="pengvparr">
    <img src="pengvparr/thumb.jpg">
    <span class="thumb-text"><span>Penguins vs. Parrots</span></span>
  </a></li>

  <li><a href="dirtyworms">
    <img src="dirtyworms/thumb.jpg">
    <span class="thumb-text"><span>Dirty Worms</span></span>
  </a></li>

  <li><a href="battleshipfriends">
    <img src="battleshipfriends/thumb.jpg">
    <span class="thumb-text"><span>Battleship Friends</span></span>
  </a></li>

  <li><a href="divisioncell">
    <img src="divisioncell/thumb.jpg">
    <span class="thumb-text"><span>Division Cell</span></span>
  </a></li>

  <li><a href="parismetro">
    <img src="parismetro/thumb.jpg">
    <span class="thumb-text"><span>Paris Métro Simulator</span></span>
  </a></li>

  <li><a href="app2solitaire">
    <img src="app2solitaire/thumb.jpg">
    <span class="thumb-text"><span>app²solitaire</span></span>
  </a></li>

  <li><a href="brainteaser">
    <img src="brainteaser/thumb.jpg">
    <span class="thumb-text"><span>Brain Teaser</span></span>
  </a></li>

  <li><a href="bonewars">
    <img src="bonewars/thumb.jpg">
    <span class="thumb-text"><span>The Bone Wars</span></span>
  </a></li>  
</ul>

If you want to add your game to the gallery, fork the [PlayN website repository], add a directory
for your game in the `gallery` directory, a link on the index page, and submit a pull request.

[PlayN website repository]: https://github.com/playn/playn.github.io
