window.onload=drawSnake;
const lowerBorder=0;
const MouseRad=500;
const SnakeHeadRad=400;
var dimension;
setDimension();
var upperBorder=400/dimension;
var WinCountBorder=getVictoryConv();
var Snake=[[dimension, dimension], [dimension, dimension*2], [dimension*2, dimension*2], [dimension*2, dimension*3]];
var Mouse;
var IsGaming=false;
var Length=4;
var greater=false;
var winFail=false;
genNewMouse();
function drawSnake(){
    var svgDoc = document.getElementById('snakeArea').contentDocument;
    var svggr =  svgDoc.getElementById('svggr');
    while (svggr.firstChild) {
            svggr.removeChild(svggr.firstChild);
    }
    if (!winFail && !IsGaming){
        var line = svgDoc.createElementNS("http://www.w3.org/2000/svg",'text');
        line.setAttribute('x', dimension*(upperBorder/3));
        line.setAttribute('y', dimension*(upperBorder/3));
        line.setAttribute('fill', 'red');
        line.setAttribute('transform', 'rotate(30 20,40)');
        line.setAttribute('style', 'font-size:'+(upperBorder+30)+';');
        line.textContent='Select game mode';
        svggr.appendChild(line);
    }
    svgDoc.getElementById('mouse').setAttribute('viewBox', 
            (-(Mouse[0]*(320/(dimension))-(MouseRad/2)))+' '+
            (-(Mouse[1]*(320/(dimension))-(MouseRad/2)))+' '+
            (MouseRad*(320/(dimension)))+' '+(MouseRad*(320/(dimension))));
    var isGray=true;
    for (var i=0; i<Length-1; i++){
        var line = svgDoc.createElementNS("http://www.w3.org/2000/svg",'line');
        line.setAttribute('x1', Snake[i][0]);
        line.setAttribute('y1', Snake[i][1]);
        line.setAttribute('x2', Snake[i+1][0]);
        line.setAttribute('y2', Snake[i+1][1]);
        if (isGray){
        line.setAttribute('style', 
                "stroke:darkcyan;stroke-width:"+(dimension-5)+";stroke-linecap:round;");
        } else {
        line.setAttribute('style', 
                "stroke:brown;stroke-width:"+(dimension-5)+";stroke-linecap:round;");
        }
        isGray=!isGray;
        svggr.appendChild(line);
    }
    svgDoc.getElementById('head').setAttribute('viewBox', 
            (-(Snake[Length-1][0]*(8/(dimension/10))-(80)))+' '+
            (-(Snake[Length-1][1]*(8/(dimension/10))-(80)))+' '+
            SnakeHeadRad/(dimension/80)+' '+SnakeHeadRad/(dimension/80));
}

$(document).bind('keypress', function (e){
    if(IsGaming){
        if(e.which== 104){//h-left
            if(!(Snake[Length-2][0]==Snake[Length-1][0]-dimension
                    && Snake[Length-2][1]==Snake[Length-1][1])){
                if(!headEquals(Mouse[0], Mouse[1]) && !greater){
                    Snake=rolLeft(Snake);
                }
                if (greater) {
                    Length++;
                    greater=false;
                }
                Snake[Length-1]=[];
                Snake[Length-1][0]=Snake[Length-2][0]-dimension;
                Snake[Length-1][1]=Snake[Length-2][1];
                if(headEquals(Mouse[0], Mouse[1])){
                    genNewMouse(true, false);
                    greater=true;
                }
                drawSnake();
            }
        } else if(e.which== 106){//j-down
            if(!(Snake[Length-2][0]==Snake[Length-1][0]
                    && Snake[Length-2][1]==Snake[Length-1][1]+dimension)){
                if(!headEquals(Mouse[0], Mouse[1]) && !greater){
                    Snake=rolLeft(Snake);
                } 
                if (greater) {
                    Length++;
                    greater=false;
                }
                Snake[Length-1]=[];
                Snake[Length-1][0]=Snake[Length-2][0];
                Snake[Length-1][1]=Snake[Length-2][1]+dimension;
                if(headEquals(Mouse[0], Mouse[1])){
                    genNewMouse(true, true);
                    greater=true;
                }
                drawSnake();
            }
        } else if(e.which== 107){//k-up
            if(!(Snake[Length-2][0]==Snake[Length-1][0]
                    && Snake[Length-2][1]==Snake[Length-1][1]-dimension)){
                if(!headEquals(Mouse[0], Mouse[1]) && !greater){
                    Snake=rolLeft(Snake);
                } 
                if (greater) {
                    Length++;
                    greater=false;
                }
                Snake[Length-1]=[];
                Snake[Length-1][0]=Snake[Length-2][0];
                Snake[Length-1][1]=Snake[Length-2][1]-dimension;
                if(headEquals(Mouse[0], Mouse[1])){
                    genNewMouse(false, true);
                    greater=true;
                }
                drawSnake();
            }
        } else if(e.which== 108){//l-right
            if(!(Snake[Length-2][0]==Snake[Length-1][0]+dimension
                    && Snake[Length-2][1]==Snake[Length-1][1])){
                if(!headEquals(Mouse[0], Mouse[1]) && !greater){
                    Snake=rolLeft(Snake);
                } 
                if (greater) {
                    Length++;
                    greater=false;
                }
                Snake[Length-1]=[];
                Snake[Length-1][0]=Snake[Length-2][0]+dimension;
                Snake[Length-1][1]=Snake[Length-2][1];
                if(headEquals(Mouse[0], Mouse[1])){
                    genNewMouse(false, false);
                    greater=true;
                }
                drawSnake();
            }
        }
        if(((Snake[Length-1][0]<=lowerBorder) || (Snake[Length-1][0]>=dimension*upperBorder))
            || (Snake[Length-1][1]>=dimension*upperBorder || Snake[Length-1][1]<=lowerBorder)
            ||isHeadOnTail(Snake[Length-1][0], Snake[Length-1][1])){
            var svgDoc = document.getElementById('snakeArea').contentDocument;
            var svggr =  svgDoc.getElementById('svggr');
            var line = svgDoc.createElementNS("http://www.w3.org/2000/svg",'text');
            line.setAttribute('x', dimension*(upperBorder/3));
            line.setAttribute('y', dimension*(upperBorder/3));
            line.setAttribute('fill', 'red');
            line.setAttribute('transform', 'rotate(30 20,40)');
            line.setAttribute('style', 'font-size:'+(upperBorder+30)+';');
            line.textContent='GAME OVER';
            svggr.appendChild(line);
            IsGaming=false;
            winFail=true;
        }
        if(Length>=WinCountBorder && IsGaming){
            var svgDoc = document.getElementById('snakeArea').contentDocument;
            var svggr =  svgDoc.getElementById('svggr');
            var line = svgDoc.createElementNS("http://www.w3.org/2000/svg",'text');
            line.setAttribute('x', dimension*(upperBorder/25));
            line.setAttribute('y', dimension*(upperBorder/10));
            line.setAttribute('fill', 'red');
            line.setAttribute('transform', 'rotate(45 45,40)');
            line.setAttribute('style', 'font-size:'+(upperBorder+30)+';');
            line.textContent='XD !1!1!YOU WIN!1!1! XD';
            svggr.appendChild(line);
            IsGaming=false;
            winFail=true;
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

function isHeadOnTail(x, y){
    var c=0;
    for(var i=0; i<Length-1;i++)
        if (Snake[i][0]==x && Snake[i][1]==y) c++;
    if (c!=0) return true;
    return false;
}

function isMouseOnTail(x, y, left, up){
        var c=0;
        for(var i=0; i<Length;i++)
            if (Snake[i][0]==x && Snake[i][1]==y) c++;
        if (c!=0) return true;
        return false;
}

function genNewMouse(left, up){
        var x=0, y=0;
        Mouse=[];
        do {
            x=(Math.floor((Math.random() * (upperBorder-1)) + (lowerBorder+1)))*dimension;
            y=(Math.floor((Math.random() * (upperBorder-1)) + (lowerBorder+1)))*dimension;
        } while(isMouseOnTail(x, y, left, up))
        Mouse[0]=x;
        Mouse[1]=y;
}

function setDimension(){
    if(document.getElementById('dim_low').checked) dimension=20;
    if(document.getElementById('dim_middle').checked) dimension=40;
    if(document.getElementById('dim_high').checked) dimension= 80;
    upperBorder=400/dimension;
}

function getVictoryConv(){
    if(document.getElementById('d_hard').checked) return (2*(upperBorder*upperBorder)/3);
    if(document.getElementById('d_middle').checked) return ((upperBorder*upperBorder)/2);
    if(document.getElementById('d_ligth').checked) return ((upperBorder*upperBorder)/3);
}

function startGame(){
    if (!IsGaming && !winFail){
        setDimension();
        WinCountBorder=getVictoryConv();
        IsGaming=true;
        drawSnake();
    }
}

var rad = document.dim_form.dimension;
for(var i = 0; i < rad.length; i++) 
    rad[i].onclick = function() { 
        if (!IsGaming){
            setDimension();
            Snake=[[dimension, dimension], [dimension, dimension*2], [dimension*2, dimension*2], [dimension*2, dimension*3]]; 
            genNewMouse();
            drawSnake();
        }
    };
