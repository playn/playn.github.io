function add_invader (y) {
  if (y > document.body.offsetHeight) return; // done!
  var scale = 2;
  var box = document.createElement('div')
  box.className = 'bg';
  var img = document.createElement('img')
  var which = Math.floor(Math.random() * 3);
  img.src = '/images/invaders' + which + '.png';
  img.onload = function () {
    var iwidth = img.width/2;
    var x = Math.round(Math.random() * document.body.offsetWidth - scale*iwidth/2);
    box.style.left = x + 'px';
    box.style.top = y + 'px';
    box.style.width = (scale*iwidth) + 'px';
    box.style.height = (scale*img.height) + 'px';
    img.style.opacity = 0.20;
    img.style.position = 'absolute';
    if (Math.random() > 0.5) img.style.left = -(scale*iwidth) + 'px';
    add_invader(y+3*img.height);
  }
  box.appendChild(img);
  document.body.appendChild(box);
}
add_invader(0);
