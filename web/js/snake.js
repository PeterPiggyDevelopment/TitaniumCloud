window.onload=drawSnake;
var AC=40;
var upperBorder=400/AC;
var lowerBorder=0;
var Length=4;
var IsGaming=true;
var Mouse=[AC*8, AC*5];
var MouseRad=AC-5;
var Snake=[[AC, AC], [AC, AC*2], [AC*2, AC*2], [AC*2, AC*3]];
var SnakeHead=MouseRad;
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
                "stroke:darkcyan;stroke-width:"+(AC-5)+";stroke-linecap:round;");
        } else {
        line.setAttribute('style', 
                "stroke:brown;stroke-width:"+(AC-5)+";stroke-linecap:round;");
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
            if(!(Snake[Length-2][0]==Snake[Length-1][0]-AC
                    && Snake[Length-2][1]==Snake[Length-1][1])){
                if(!headEquals(Mouse[0], Mouse[1])){
                    Snake=rolLeft(Snake);
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0]-AC;
                    Snake[Length-1][1]=Snake[Length-2][1];
                    drawSnake();
                } else {
                    genNewMouse();
                    drawSnake();
                    Length++;
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0]-AC;
                    Snake[Length-1][1]=Snake[Length-2][1];
                    drawSnake();
                }
            }
        } else if(e.which== 106){//j-down
            if(!(Snake[Length-2][0]==Snake[Length-1][0]
                    && Snake[Length-2][1]==Snake[Length-1][1]+AC)){
                if(!headEquals(Mouse[0], Mouse[1])){
                    Snake=rolLeft(Snake);
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0];
                    Snake[Length-1][1]=Snake[Length-2][1]+AC;
                    drawSnake();
                } else {
                    genNewMouse();
                    drawSnake();
                    Length++;
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0];
                    Snake[Length-1][1]=Snake[Length-2][1]+AC;
                    drawSnake();
                }
            }
        } else if(e.which== 107){//k-up
            if(!(Snake[Length-2][0]==Snake[Length-1][0]
                    && Snake[Length-2][1]==Snake[Length-1][1]-AC)){
                if(!headEquals(Mouse[0], Mouse[1])){
                    Snake=rolLeft(Snake);
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0];
                    Snake[Length-1][1]=Snake[Length-2][1]-AC;
                    drawSnake();
                } else {
                    genNewMouse();
                    drawSnake();
                    Length++;
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0];
                    Snake[Length-1][1]=Snake[Length-2][1]-AC;
                    drawSnake();
                }
            }
        } else if(e.which== 108){//l-right
            if(!(Snake[Length-2][0]==Snake[Length-1][0]+AC
                    && Snake[Length-2][1]==Snake[Length-1][1])){
                if(!headEquals(Mouse[0], Mouse[1])){
                    Snake=rolLeft(Snake);
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0]+AC;
                    Snake[Length-1][1]=Snake[Length-2][1];
                    drawSnake();
                } else {
                    genNewMouse();
                    drawSnake();
                    Length++;
                    Snake[Length-1]=[];
                    Snake[Length-1][0]=Snake[Length-2][0]+AC;
                    Snake[Length-1][1]=Snake[Length-2][1];
                    drawSnake();
                }
            }
        }
        if(((Snake[Length-1][0]<=lowerBorder) || (Snake[Length-1][0]>=AC*upperBorder))
            || (Snake[Length-1][1]>=AC*upperBorder || Snake[Length-1][1]<=lowerBorder)
            ||isOnTail(Snake[Length-1][0], Snake[Length-1][1])){
            var svgDoc = document.getElementById('snakeArea').contentDocument;
            var svggr =  svgDoc.getElementById('svggr');
            var line = svgDoc.createElementNS("http://www.w3.org/2000/svg",'text');
            line.setAttribute('x', AC*6);
            line.setAttribute('y', AC*2);
            line.setAttribute('fill', 'red');
            line.setAttribute('transform', 'rotate(30 20,40)');
            line.setAttribute('style', 'font-size:'+(upperBorder+30)+';');
            line.textContent='GAME OVER';
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
        x=(Math.floor((Math.random() * (upperBorder-1)) + (lowerBorder+1)))*AC;
        y=(Math.floor((Math.random() * (upperBorder-1)) + (lowerBorder+1)))*AC;
    } while(isOnTail(x,y))
    Mouse[0]=x;
    Mouse[1]=y;
}
