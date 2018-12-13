(*******************************************************************************
INSA ROUEN NORMANDIE
DEPARTEMENT STPI - PROJET INFO

Liyu ZHANG, Tonglin Yan, Augustin SCHWARTZ
Superviseur: Jean-Baptiste LOUVET

20 December 2018
*******************************************************************************)

program serpent;
uses crt, sysutils, math, rank;

//! 【规！定！】
//! 有错误就一个一个改，发现bug，先解决掉，然后再添加新功能。
//! 不要一股脑加一堆新东西上去，然后都有问题，没一个达到预期 能用的。 
//! 使用Git的一个好处，就是让你可以一步一步跟踪进展，“屁胡走向胜利”。一下子加这么多，而且
//! 上一个都还有bug没有解决掉的，就加新的东西 而且新的里面也还有bug，这会让人很难去跟踪每个问
//! 题的错误，解决每个问题对应的bug。

//todo:蛇撞自己不会死 => Done !
//todo:待处理的bug:创建文件存分数
//1 pomme : fait gagner 1 points et fait gagner en taille le serpent.
//2 bombe : fait perdre une vie, disparaît après 10 secondes.
//3 snakeSpeedUp: speed increases for 5 seconds. => Done !
//4 strewberry : fait gagner 10 points, disparaît après 5 secondes
//5 diamant : écran rempli de pommes, disparaît après 5 secondes



//! ----------------------------------------------------------------------------
//!                              VARIABLE DECLARATION
//! ----------------------------------------------------------------------------
var i,j,len,dir,dirnew,beans_amount:Integer;
    space_width,space_height:Integer;
    wall_number,wall_length,wall_amount:Integer;
    //整个蛇是由一个2维数组来表示的，这个数组记载了蛇每一截所在的坐标（x,y）。行数代表蛇的长度
    //第一行是蛇头。第一列是横坐标x，第二列是纵坐标y——如果我没记错的话
	body:array[0..254, 0..1] of Integer; // coordinates of snake
    buff:array[0..254, 0..1] of LongInt; // snake buff: effect
    beans:array of array of LongInt; // coordinates of bean
    hWalls:array of array of Integer; // coordinates of horizontal wall
    vWalls:array of array of Integer; // coordinates of vertical wall
	diff,start:String;
	k:Char;
	score,speed:Integer;
    f:file of ranking;
	r:ranking;


//! ----------------------------------------------------------------------------
//!                                   FUNCTION
//! ----------------------------------------------------------------------------
//* when snake meets wall
function snakeCollision():boolean;
(*  Check if a part of snake has touched the obstacle
    INPUT
        (none)
    OUTPUT
        snakeCollision: if collision, true; if not, false [boolean]
*)
begin
	snakeCollision := false;
    if (body[0,0] < 2) or (body[0,0] >= space_width) then
        snakeCollision := true;
    if (body[0,1] < 4) or (body[0,1] >= space_height-1) then
        snakeCollision := true;
end;

function snakeContain(x,y:integer):boolean;
(*  Check if a point is already existed in snake body
    INPUT
        x: X coordinate [int]
        y: Y coordinate [int]
    OUTPUT
        snakeContain: if existant, true; else, false [boolean]
*)
// var i:integer;
begin
	snakeContain := false;
	for i := 0 to len-1 do
	begin
        if (body[i,0] = x) and (body[i,1] = y) then
        begin
            snakeContain := true;
            break;
        end
	end;
end;

function convertToInt(t:TDateTime):LongInt;
(*  Convert TDateTime to LongInt
    INPUT
        t: time [TDateTime]
    OUTPUT
        convertToInt: time in second [LongInt]
*)
var HH, MM, SS, MS:Word;
begin
    DecodeTime(t, HH, MM, SS, MS);
    convertToInt := HH*3600 + MM*60 + SS;
end;


//! ----------------------------------------------------------------------------
//!                                   PROCEDURE
//! ----------------------------------------------------------------------------
//* draw perimeter
procedure drawbox(x0,y0,width,height:integer; title:string);
(*  Draw a box (for title board, perimeter, ...)
    INPUT
        x0: X coordinate of top-left point [int]
        y0: Y coordinate of top-left point [int]
        width: width of box [int]
        height: height of box [int]
        title: insert a title inside the box [str]
    OUTPUT
        (none)
*)
var i1,i2:integer;
begin
	for i2 := 1 to height do
	begin
		gotoXY(x0,y0+i2-1);
		for i1 := 1 to width do
		begin
			if (i2 = 1) or (i2 = height) then
				if (i1 = 1) or (i1 = width) then
					write('+')
				else
					write('-')
			else if (i1 = 1) or (i1 = width) then
					write('|')
				else
					write(' ')
		end;
	end;
	if (title <> '') then
	begin
		i1 := y0+floor((height-1)/2);
		i2 := x0+floor(width/2-length(title)/2);
		gotoXY(i2,i1);
		write(title);
	end;
end;

//* make wall
procedure horizontalWalls(wall_number,wall_length,wall_amount:Integer);
(* Make horizontal walls
*)
var ind,l,pos,x,y:Integer;
begin
    setLength(hWalls, wall_amount, 1);
    for ind := 0 to wall_number-1 do
    begin
        // find a random position for new wall
        repeat
            x := random(space_width-3-wall_length)+2;
            y := random(space_height-5-wall_length)+4;
        until not snakeContain(x,y);
        // build wall
        for l := 1 to wall_length do
        begin
            pos := ind * wall_length + l - 1;
            hWalls[pos,1] := x + l - 1;
            hWalls[pos,2] := y;
            gotoXY(hWalls[pos,1],hWalls[pos,2]);
            textColor(lightblue);
            write('-');
        end;
    end;
    textColor(lightred); // reset color to red
end;

procedure verticalWalls(wall_number,wall_length,wall_amount:Integer);
(* Make vertical walls
*)
var ind,l,pos,x,y:Integer;
begin
    setLength(vWalls, wall_amount, 1);
    for ind := 0 to wall_number-1 do
    begin
        // find a random position for new wall
        repeat
            x := random(space_width-3-wall_length)+2;
            y := random(space_height-5-wall_length)+4;
        until not snakeContain(x,y);
        // build wall
        for l := 1 to wall_length do
        begin
            pos := ind * wall_length + l - 1;
            vWalls[pos,1] := x;
            vWalls[pos,2] := y + l - 1;
            gotoXY(vWalls[pos,1],vWalls[pos,2]);
            textColor(lightblue);
            write('|');
        end;
    end;
    textColor(lightred); // reset color to red
end;


//* draw snake
procedure drawsnake;
(*  INPUT
        (none)
    OUTPUT
        (none)
*)
var tmp:integer;
begin
	for tmp := 0 to len-1 do
	begin
		gotoXY(body[tmp,0], body[tmp,1]);
		if (tmp = 0) then write('o')
		else write('x');
	end;
end;

//* Game over pop-up window
procedure snakeDie;
(*  INPUT
        (none)
    OUTPUT
        (none)
*)
begin
	textColor(lightblue);
	drawbox(1,11,80,3,'');
	gotoXY(37,12);
	textColor(lightred);
	write('Game Over');
	textColor(lightgray);
	gotoXY(20,20);
	delay(1000);
end;


//*reorder the rank
procedure refreshRank(ind:integer);
(*  INPUT
        ind:the total number of player
    OUTPUT
        (none)
*)
var pp,i,s,newp:integer;
    n:string;
begin
    //start to refresh 
    s:=r.score[ind];
    n:=r.name[ind];
    //newp find out positon of new record
    newp:=0;
    repeat
        newp:=newp+1;
    until (s>=r.score[newp]);
    //check out if player played before
    pp:=0;
    repeat
        pp:=pp+1;
    until (n=r.name[pp]) or (pp=ind);
    //player played before but not break his record
    //n position of previous record of same player
    if (r.name[pp]=n) and (r.score[pp]>=s) then
        begin
            r.name[ind]:='';
            r.score[ind]:=0;
        end
    //player played before and break his record
    else if (r.name[pp]=n) and (r.score[pp]<s) then
        begin
            for i:=pp downto newp+1 do 
            begin
                r.score[i]:=r.score[i-1];
                r.name[i]:=r.name[i-1];
            end;  
            r.score[newp]:=s;
            r.name[newp]:=n;
            r.name[ind]:='';
            r.score[ind]:=0;
        end 
    //player haven't played before
    else
        begin
            for i:=ind downto newp+1 do 
            begin
                r.score[i]:=r.score[i-1];
                r.name[i]:=r.name[i-1];
            end;    
            r.score[newp]:=s;
            r.name[newp]:=r.name[ind];   
        end;
    for i:=1 to max do
    begin
        write(r.name[i],' ',r.score[i]);
        writeln();
    end;
end; 



//* store the score 
procedure creatFile;

var i:integer;
begin	
    ClrScr;
    assign(f,'store.txt');
	Reset(f);
	while not eof(f) do
    i:=0;
    repeat
        read(f,r);
        i:=i+1;
    until (r.name[i]='');
    ClrScr;
    textColor(lightred);
    gotoXY(20,5);
    writeln('Entrez votre nom');
    readln(r.name[i]);
//todo:directly readln the score
    writeln('Entrez votre point');
    readln(r.score[i]);
	assign(f,'ranking');
	rewrite(f);
    refreshRank(i);
	write(f,r);
	close(f);
end;

//* vvvvvvvvvvvvvvvvvvvvvvvvv Beans and Effects vvvvvvvvvvvvvvvvvvvvvvvvv
procedure initiateBean(amount:integer);
(*  Initiate beans at the begining of game
    INPUT
        amount: initial number of beans [int]
    OUTPUT
        (none)
*)
var x,y,ind,r:integer;
begin
    setLength(beans, amount, 4);
    for ind := 0 to amount-1 do
    begin
        // find a random position for new bean
        repeat
            x := random(space_width-3)+2;
            y := random(space_height-5)+4;
        until not snakeContain(x,y);
        beans[ind,0] := x;
        beans[ind,1] := y;
        r := random(30)+1;
        Case r Of 
            27:
            begin
                beans[ind,2] := 2; // bomb
                beans[ind,3] := convertToInt(time+encodeTime(0,0,10,0));
                gotoXY(x,y);
                textColor(black);
                write('X');
            end; 
            28:
            begin
                beans[ind,2] := 3; // snakeSpeedUp
                beans[ind,3] := 999999;
                gotoXY(x,y);
                textColor(blue);
                write('*');
            end;   
            29:
            begin
                beans[ind,2] := 4; // strewberry
                beans[ind,3] := convertToInt(time+encodeTime(0,0,5,0));
                gotoXY(x,y);
                textColor(red);
                write('*');
            end;
            30:
            begin
                beans[ind,2] := 5; // diamond
                beans[ind,3] := convertToInt(time+encodeTime(0,0,5,0));
                gotoXY(x,y);
                textColor(lightcyan);
                write('*');
            end;
        Else
            beans[ind,2] := 1; // normal bean
            beans[ind,3] := 999999;
            gotoXY(x,y);
            textColor(green);
            write('*');
        end;
    end;
    textColor(lightred); // reset color to red
end;

procedure refreshBean(ind:Integer);
(*  Refresh a new bean after eating or disappearing
    INPUT
        (none)
    OUTPUT
        (none)
*)
var x,y,r,randomfood:integer;
begin
    repeat // random position for new bean
        x := random(78)+1;
        y := random(19)+4;
    until not snakeContain(x,y);
	beans[ind,0] := x;
	beans[ind,1] := y;
	gotoXY(x,y);
    r := random(40)+1;
    Case r Of 
        27:   randomfood := 2; // bomb
        28:   randomfood := 3; // speed-up
        29:   randomfood := 4; // strewberry
        30:   randomfood := 5; // diamond
    Else
        randomfood := 1; // normal bean
    end; 
    beans[ind,2] := randomfood; 
    beans[ind,3] := 0;
    gotoXY(x,y);
    case beans[ind,2] of
        1: begin textColor(green); write('*'); end; // normal bean
        2: begin textColor(black); write('X'); end; // bomb
        3: begin textColor(blue); write('*'); end; // speed-up
        4: begin textColor(red); write('*'); end; // strewberry
        5: begin textColor(lightcyan); write('*'); end; // diamond
    end;
    textColor(lightred);
end;

//* #1 when snake eats a normal bean
procedure snakeGrow(x,y,tmp:Integer);
(*  increase the length of snake if it eats a bean
    INPUT
        x: X coordinate [int]
        y: Y coordinate [int]
    OUTPUT
        (none)
*)
begin
    inc(score,1);
	inc(len,1);
	body[len-1,0] := x;
	body[len-1,1] := y;
	gotoXY(x,y);
	write('x');
	gotoXY(2,2); // move cursor back to score panel
    textColor(lightred);
	write(' Point: ',score);
end;


//TODO #2 when snake eats a bomb

//TODO #3 when snake eats a speed-up bean
procedure snakeSpeedUp;
var endtime: LongInt;
begin
    inc(speed, -100);
    endtime := convertToInt(time+encodeTime(0,0,10,0)); // i.e. last 10s
    for i := 0 to 254 do // find an unused position to save buff
    begin
        if (buff[i,0] = 0) then
        begin
            buff[i,0] := endtime;
            buff[i,1] := 100;
            break;
        end;
    end;
end;

//TODO #4 when snake eats a strawberry
procedure snakeBoostScore;
begin
    inc(score, 10);
    gotoXY(2,2);
    write(' Point: ',score);
end;


//TODO #5 when snake eats a diamond
//TODO #5 after 10 seconds, the beans disappear and reinitialize beans
procedure diamond(x,y,tmp:integer);

var i,j:integer;
begin
    textColor(green);
    for i:=2 to 79 do 
        for j:=4 to 22 do 
            if (snakeContain(i,j)=False) then 
                begin
                gotoXY(i,j);
                writeln('*');
                end;
end;

//todo: finish it
procedure disappearBean(amount,speed:Integer);
(* bomb disappear after 10 seconds
*)
var ind:integer;
begin
    for ind:=1 to amount do 
    begin 
        beans[ind,3]:= beans[ind,3]+speed;
        if (beans[ind,2]=2) and (beans[ind,3]>10000) then
        begin
            gotoXY(beans[ind,0],beans[ind,1]);
            write('');			
        end;
    end;
end;


procedure checkSnakeStatus(x,y,ind:integer);
(*  Find out which kind of bean that has been eaten by snake
    INPUT
        x: X coordinate [int]
        y: Y coordinate [int]
        ind: index of bean [int]
    OUTPUT
*)
begin
    case beans[ind,2] of
        1: begin snakeGrow(x,y,ind); end; // normal bean snakeGrow(x,y,ind);
        2: begin snakeDie; end; // bomb
        3: begin snakeSpeedUp; end; // speed-up
        4: begin snakeBoostScore; end; // strawberry
        5: begin diamond(x,y,ind); end;// diamond
    end;
end;


//* vvvvvvvvvvvvvvvvvvvvvvvvv Snake Movement Control vvvvvvvvvvvvvvvvvvvvvvvvv
procedure checkTime;
(*  Check if buff is time's up
    INPUT
        (none)
    OUTPUT
        (none)
*)
var now:LongInt; //ind:Integer;
begin
    now := convertToInt(time);
    // check buff
    if (buff[0,0] <> 0) and (now >= buff[0,0]) then
    begin
        inc(speed, buff[0,1]);
        for i := 1 to 254 do
        begin
            buff[i-1,0] := buff[i,0];
            buff[i-1,1] := buff[i,1];
        end;
    end;

    // check beans
    // for ind := 0 to beans_amount-1 do
    // begin
    //     if (now >= beans[ind,3]) then
    //     begin
    //         refreshBean(ind);
    //     end;
    // end;

    //* JUST FOR DEBUGGING vvv
    gotoXY(30,2);
    write(' hist, effect:', buff[0,0], ', ', buff[0,1]);
    gotoXY(30,3);
    write(' hist, effect:', buff[1,0], ', ', buff[1,1]);
    gotoXY(60,2);
    write(' speed:', speed);
    gotoXY(60,3);
    write(' time:', now);
    //* END OF DEBUGGING ^^^
end;

procedure movesnake;
(*  Change the direction of moving
    INPUT
        (none)
    OUTPUT
        (none)
*)
var x,y,wasx,wasy,tmp:integer;
begin
    // get direction from main program
	case dir of
		1: begin x :=  1; y := 0; end; // right (i.e. east)
		2: begin x :=  0; y := 1; end; // down (i.e. south)
		3: begin x := -1; y := 0; end; // left (i.e. west)
		4: begin x :=  0; y :=-1; end; // up (i.e. north)
	end;
    // ***** Moving *****
	gotoXY(body[0,0], body[0,1]); write('x'); // change snake head to body
	gotoXY(body[len-1,0], body[len-1,1]); write(' '); // change snake tail to empty
	wasx := body[len-1,0];
	wasy := body[len-1,1];
    // check if snake meets itself
	if (snakeContain(body[0,0]+x, body[0,1]+y)) then
        begin
            snakeDie;
            creatFile;
        end;
    // change segment of snake: from previous position to next position
	for tmp := 0 to len-2 do
	begin
		body[len-tmp-1,0] := body[len-tmp-2,0];
		body[len-tmp-1,1] := body[len-tmp-2,1];
	end;
    // change snake head: add new position
	body[0,0] := body[0,0] + x;
	body[0,1] := body[0,1] + y;
	gotoXY(body[0,0], body[0,1]); write('o');
    // ***** Eating *****
    for tmp := 0 to beans_amount-1 do
    begin
        if (snakeContain(beans[tmp,0],beans[tmp,1])) then // a bean is eaten
        begin
            checkSnakeStatus(wasx, wasy, tmp);
            refreshBean(tmp);
            break;
        end;
    end;
    // ***** Hitting *****
    if diff='d' then
    begin
        for tmp := 0 to wall_amount-1 do
        begin
            if (snakeContain(hWalls[tmp,1],hWalls[tmp,2])) or
               (snakeContain(vWalls[tmp,1],vWalls[tmp,2])) then // snake meets wall
            begin
                snakeDie;
                creatFile;
            end;
        end;
    end;
	if (snakeCollision) then 
    begin
        snakeDie; // meets perimeters
        creatFile;
    end;
end;

//* vvvvvvvvvvvvvvvvvvvvvvvvv Welcome Window vvvvvvvvvvvvvvvvvvvvvvvvv
procedure intros;
begin
	gotoXY(24,4);
	writeln('Bienvenue au jeu de serpent!');
	gotoXY(26,5);
	writeln('Voici les règles de ce jeu：');
	gotoXY(2,6);
	writeln('Vous pouvez utiliser les flèches sur le clavier pour controler la direction');
	gotoXY(8,7);
	writeln('Vous ne pouvez pas toucher les murs et le corps du serpent');
	gotoXY(17,8);
	writeln('Maintenant vous pouvez choisir la difficulté');
	gotoXY(19,9);
	writeln('Entrez f pour facile et d pour difficile');
	readln(diff);
	if diff='f' then
	begin
		gotoXY(23,10);
		writeln('Vous avez choisir la mode facile');
	end;
	if diff='d' then
	begin
		gotoXY(21,10);
		writeln('Vous avez choisir la mode difficile');
	end;
	gotoXY(24,11);
	writeln('Entrez c pour commencer la jeu');
	readln(start);
end;



//! ----------------------------------------------------------------------------
//!                                  MAIN PROGRAM
//! ----------------------------------------------------------------------------
begin
	// ***** Initiation *****
	ClrScr;
	Randomize;
	len := 3; // initial length of snake
	speed := 400; // time to delay
    beans_amount := 10; // initial amount of beans
    wall_number := 4;
    wall_length := 3;
    wall_amount := wall_number * wall_length;
	score:=0;
	dir:=1; // default direction {1=east, 2=south, 3=west, 4=north}
    space_width := 80; // width of gaming space
    space_height := 24; // height of gaming space
	// initiate snake
	for i := 0 to 254 do
        body[i,0] := 0;
        body[i,1] := 0;
    body[0,0] := 12;
    body[0,1] := 12;
    body[1,0] := 11;
    body[1,1] := 12;
    body[2,0] := 10;
    body[2,1] := 12;
    // initiate buff
    for j:=0 to 254 do
        buff[j,0] := 0;
        buff[j,1] := 0;
	// print perimeter on screen
    // textColor(lightblue);
	// drawbox(1,1,space_width,space_height,'');
	// drawbox(1,1,space_width,3,'Jeu de Serpent (c) 2018');
	intros;
	if start = 'c' then
	begin
        ClrScr;
        textColor(lightblue);
        drawbox(1,1,space_width,space_height,''); //moving space, wall
        drawbox(1,1,space_width,3,'Jeu de Serpent (c) 2018');// title of the game
        // print initial snake on screen
        textColor(lightred);
        drawsnake;
        gotoXY(2,2);
        writeln(' Point: ',score);
        // initiate beans
        initiateBean(beans_amount); // initiate beans by a given number
        if diff='d' then
        begin
            horizontalWalls(wall_number,wall_length,wall_amount); // create horizontal walls
            verticalWalls(wall_number,wall_length,wall_amount); // create vertical walls
        end;
        // ***** Start Game *****
        repeat
            delay(speed);
            if (keypressed) then
            begin
                k:=readkey;
                if (k = #0) then
                begin
                    k:=readkey;
                    case k of
                        #77: dirnew := 1; // right (i.e. east)
                        #80: dirnew := 2; // down (i.e. south)
                        #75: dirnew := 3; // left (i.e. west)
                        #72: dirnew := 4; // up (i.e. north)
                    end;
                    if (dir = 1) and (dirnew <> 3) then dir := dirnew;
                    if (dir = 2) and (dirnew <> 4) then dir := dirnew;
                    if (dir = 3) and (dirnew <> 1) then dir := dirnew;
                    if (dir = 4) and (dirnew <> 2) then dir := dirnew;
                end;
                if (k = #27) then // press ESC key
                begin
                    snakeDie;
                    creatFile;
                end;
            end;
            //todo: disappearBean(beans_amount,d);
            movesnake;
            checkTime;
            gotoXY(2,2);
        until false;
        textColor(lightgray);
        gotoXY(1,25);
    end;
end.