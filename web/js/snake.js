window.onload=drawSnake;
const dimention=40;
const upperBorder=400/dimention;
const lowerBorder=0;
const MouseRad=dimention-5;
const SnakeHead=MouseRad;
const WinCountBorder=((upperBorder*upperBorder)/3);
var Snake=[[dimention, dimention], [dimention, dimention*2], [dimention*2, dimention*2], [dimention*2, dimention*3]];
var Mouse=[dimention*8, dimention*5];
var IsGaming=true;
var Length=4;
function drawSnake(){
    var svgDoc = document.getElementById('snakeArea').contentDocument;
    var svggr =  svgDoc.getElementById('svggr');
    while (svggr.firstChild) {
            svggr.removeChild(svggr.firstChild);
    }
    var circle = svgDoc.createElementNS("http://www.w3.org/2000/svg",'circle');
    circle.setAttribute('cx', Mouse[0]);
    circle.setAttribute('cy', Mouse[1]);
    circle.setAttribute('r', MouseRad);
    circle.setAttribute('fill', 'grey');
    svggr.appendChild(circle);
    var isGray=true;
    for (var i=0; i<Length-1; i++){
        var line = svgDoc.createElementNS("http://www.w3.org/2000/svg",'line');
        line.setAttribute('x1', Snake[i][0]);
        line.setAttribute('y1', Snake[i][1]);
        line.setAttribute('x2', Snake[i+1][0]);
        line.setAttribute('y2', Snake[i+1][1]);
        if (isGray){
        line.setAttribute('style', 
                "stroke:darkcyan;stroke-width:"+(dimention-5)+";stroke-linecap:round;");
        } else {
        line.setAttribute('style', 
                "stroke:brown;stroke-width:"+(dimention-5)+";stroke-linecap:round;");
        }
        isGray=!isGray;
        svggr.appendChild(line);
    }
    var head = svgDoc.createElementNS("http://www.w3.org/2000/svg",'circle');
    head.setAttribute('cx', Snake[Length-1][0]);
    head.setAttribute('cy',Snake[Length-1][1]);
    head.setAttribute('r', MouseRad);
    head.setAttribute('fill', 'yellow');
    svggr.appendChild(head);
}

$(document).bind('keypress', function (e){
    if(IsGaming){
        if(e.which== 104){//h-left
            if(!(Snake[Length-2][0]==Snake[Length-1][0]-dimention
                    && Snake[Length-2][1]==Snake[Length-1][1])){
                if(!headEquals(Mouse[0], Mouse[1])){
                    Snake=rolLeft(Snake);
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0]-dimention;
                    Snake[Length-1][1]=Snake[Length-2][1];
                    drawSnake();
                } else {
                    genNewMouse();
                    drawSnake();
                    Length++;
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0]-dimention;
                    Snake[Length-1][1]=Snake[Length-2][1];
                    drawSnake();
                }
            }
        } else if(e.which== 106){//j-down
            if(!(Snake[Length-2][0]==Snake[Length-1][0]
                    && Snake[Length-2][1]==Snake[Length-1][1]+dimention)){
                if(!headEquals(Mouse[0], Mouse[1])){
                    Snake=rolLeft(Snake);
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0];
                    Snake[Length-1][1]=Snake[Length-2][1]+dimention;
                    drawSnake();
                } else {
                    genNewMouse();
                    drawSnake();
                    Length++;
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0];
                    Snake[Length-1][1]=Snake[Length-2][1]+dimention;
                    drawSnake();
                }
            }
        } else if(e.which== 107){//k-up
            if(!(Snake[Length-2][0]==Snake[Length-1][0]
                    && Snake[Length-2][1]==Snake[Length-1][1]-dimention)){
                if(!headEquals(Mouse[0], Mouse[1])){
                    Snake=rolLeft(Snake);
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0];
                    Snake[Length-1][1]=Snake[Length-2][1]-dimention;
                    drawSnake();
                } else {
                    genNewMouse();
                    drawSnake();
                    Length++;
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0];
                    Snake[Length-1][1]=Snake[Length-2][1]-dimention;
                    drawSnake();
                }
            }
        } else if(e.which== 108){//l-right
            if(!(Snake[Length-2][0]==Snake[Length-1][0]+dimention
                    && Snake[Length-2][1]==Snake[Length-1][1])){
                if(!headEquals(Mouse[0], Mouse[1])){
                    Snake=rolLeft(Snake);
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0]+dimention;
                    Snake[Length-1][1]=Snake[Length-2][1];
                    drawSnake();
                } else {
                    genNewMouse();
                    drawSnake();
                    Length++;
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0]+dimention;
                    Snake[Length-1][1]=Snake[Length-2][1];
                    drawSnake();
                }
            }
        }
        if(((Snake[Length-1][0]<=lowerBorder) || (Snake[Length-1][0]>=dimention*upperBorder))
            || (Snake[Length-1][1]>=dimention*upperBorder || Snake[Length-1][1]<=lowerBorder)
            ||isOnTail(Snake[Length-1][0], Snake[Length-1][1])){
            var svgDoc = document.getElementById('snakeArea').contentDocument;
            var svggr =  svgDoc.getElementById('svggr');
            var line = svgDoc.createElementNS("http://www.w3.org/2000/svg",'text');
            line.setAttribute('x', dimention*(upperBorder/3));
            line.setAttribute('y', dimention*(upperBorder/3));
            line.setAttribute('fill', 'red');
            line.setAttribute('transform', 'rotate(30 20,40)');
            line.setAttribute('style', 'font-size:'+(upperBorder+30)+';');
            line.textContent='GAME OVER';
            svggr.appendChild(line);
            IsGaming=false;
        }
        if(Length>=WinCountBorder){
            var svgDoc = document.getElementById('snakeArea').contentDocument;
            var svggr =  svgDoc.getElementById('svggr');
            var line = svgDoc.createElementNS("http://www.w3.org/2000/svg",'text');
            line.setAttribute('x', dimention*(upperBorder/25));
            line.setAttribute('y', dimention*(upperBorder/10));
            line.setAttribute('fill', 'red');
            line.setAttribute('transform', 'rotate(45 45,40)');
            line.setAttribute('style', 'font-size:'+(upperBorder+30)+';');
            line.textContent='XD !1!1!YOU WIN!1!1! XD';
            svggr.appendChild(line);
            IsGaming=false;
        }
    }
});

function headEquals(x,y){
    return (Snake[Length-1][0]==x && Snake[Length-1][1]==y)? true : false;
}

function rolLeft(list){
    var newlist=[];
    for(var i=Length-1; i>0; i--){
        newlist[i-1]=list[i];
    }
    return newlist;
}

function isOnTail(x, y){
    var c=0;
    for(var i=0; i<Length-2;i++)
        if (Snake[i][0]==x && Snake[i][1]==y) c++;
    if (c!=0) return true;
    return false;
}

function genNewMouse(){
    var x=0, y=0;
    do {
        x=(Math.floor((Math.random() * (upperBorder-1)) + (lowerBorder+1)))*dimention;
        y=(Math.floor((Math.random() * (upperBorder-1)) + (lowerBorder+1)))*dimention;
    } while(isOnTail(x,y))
    Mouse[0]=x;
    Mouse[1]=y;
}
