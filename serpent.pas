(*******************************************************************************
INSA ROUEN NORMANDIE
DEPARTEMENT STPI - PROJET INFO

Liyu ZHANG, Tonglin Yan, Augustin SCHWARTZ
Superviseur: Jean-Baptiste LOUVET

20 December 2018
*******************************************************************************)

program serpent;
uses crt, sysutils, math, rank;

//TODO 待处理的bug:创建文件存分数
//TODO bug: intro界面，第一次无论按什么，只要第二次按了C，都能开始游戏
//1 apple : win 5 scores and grow up 1  => Done !
//2 mushroom : loss 5 scores and reduce 1 => Done !
//3 heart : get 1 life, disappear in 5 seconds => Done !
//4 bomb : loss 1 life, disappear in 10 seconds => Done !
//5 strewberry : win 50 scores => Done !
//6 speed-up : speed increases for 5 seconds. => Done !
//7 diamond : fill screen by apples for 5 seconds => Done !
//8 magic box : a random bean => Done !



//! ----------------------------------------------------------------------------
//!                              VARIABLE DECLARATION
//! ----------------------------------------------------------------------------
var indice,len,dir,dirnew,beans_amount,beans_amount_default:Integer;
    space_width,space_height:Integer;
    wall_number,wall_length,wall_amount:Integer;
	body:array[0..254, 0..1] of Integer; // coordinates of snake
    buff:array[0..254, 0..1] of LongInt; // snake buff: effect
    beans:array of array of LongInt; // coordinates of bean
    hWalls:array of array of Integer; // coordinates of horizontal wall
    vWalls:array of array of Integer; // coordinates of vertical wall
	diff,start:String;
	key:Char;
	score,speed,life:Integer;
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
var i:Integer;
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

function wallContain(x,y:integer):boolean;
(*  Check if a point is already existed in snake body
    INPUT
        x: X coordinate [int]
        y: Y coordinate [int]
    OUTPUT
        snakeContain: if existant, true; else, false [boolean]
*)
var i:Integer;
begin
	wallContain := false;
	for i := 0 to wall_amount-1 do
	begin
        if (hWalls[i,0] = x) and (hWalls[i,1] = y) then
        begin
            wallContain := true;
            break;
        end;
        if (vWalls[i,0] = x) and (vWalls[i,1] = y) then
        begin
            wallContain := true;
            break;
        end;
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
    setLength(hWalls, wall_amount, 2);
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
            hWalls[pos,0] := x + l - 1;
            hWalls[pos,1] := y;
            gotoXY(hWalls[pos,0],hWalls[pos,1]);
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
    setLength(vWalls, wall_amount, 2);
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
            vWalls[pos,0] := x;
            vWalls[pos,1] := y + l - 1;
            gotoXY(vWalls[pos,0],vWalls[pos,1]);
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
procedure generateBean(ind:Integer);
(*  Generate a new bean after eating or disappearing
    INPUT
        (none)
    OUTPUT
        (none)
*)
var x,y,r:integer;
begin
    repeat // random position for new bean
        x := random(space_width-3)+2;
        y := random(space_height-5)+4;
    until not snakeContain(x,y);
	beans[ind,0] := x;
	beans[ind,1] := y;
	gotoXY(x,y);
    r := random(9);
    // r := 7; //* JUST FOR DEBUGGING
    case r of 
        2:
        begin
            beans[ind,2] := 2; // mushroom
            beans[ind,3] := 999999;
            gotoXY(x,y);
            textColor(brown);
            write('*');
        end;
        3:
        begin
            beans[ind,2] := 3; // heart
            beans[ind,3] := convertToInt(time+encodeTime(0,0,5,0));
            gotoXY(x,y);
            textColor(magenta);
            write('*');
        end;
        4:
        begin
            beans[ind,2] := 4; // bomb
            beans[ind,3] := convertToInt(time+encodeTime(0,0,10,0));
            gotoXY(x,y);
            textColor(black);
            write('X');
        end;
        5:
        begin
            beans[ind,2] := 5; // strewberry
            beans[ind,3] := 999999;
            gotoXY(x,y);
            textColor(red);
            write('*');
        end;
        6:
        begin
            beans[ind,2] := 6; // speed-up bean
            beans[ind,3] := 999999;
            gotoXY(x,y);
            textColor(blue);
            write('*');
        end;
        7:
        begin
            beans[ind,2] := 7; // diamond
            beans[ind,3] := convertToInt(time+encodeTime(0,0,5,0));
            gotoXY(x,y);
            textColor(lightcyan);
            write('◊');
        end;
        8:
        begin
            beans[ind,2] := random(7)+1; // magic box
            case beans[ind,2] of
                3: beans[ind,3] := convertToInt(time+encodeTime(0,0,5,0));
                4: beans[ind,3] := convertToInt(time+encodeTime(0,0,10,0));
                7: beans[ind,3] := convertToInt(time+encodeTime(0,0,5,0));
            else
                beans[ind,3] := 999999;
            end;
            gotoXY(x,y);
            textColor(white);
            write('?');
        end;
    else
        beans[ind,2] := 1; // apple (normal bean)
        beans[ind,3] := 999999;
        gotoXY(x,y);
        textColor(green);
        write('*');
    end;
    textColor(lightred);
end;

procedure initiateBean(amount:integer);
(*  Initiate beans by a given number of beans
    INPUT
        amount: initial number of beans [int]
    OUTPUT
        (none)
*)
var ind:integer;
begin
    setLength(beans, amount, 4);
    for ind := 0 to amount-1 do
    begin
        generateBean(ind);
    end;
end;

//* #1 apple (normal bean)
procedure snakeGrow(x,y:Integer);
(*  Increase the length of snake by 1 and win 5 points
    INPUT
        x: X coordinate [int]
        y: Y coordinate [int]
    OUTPUT
        (none)
*)
begin
    inc(score,5); // win 5 points
	inc(len,1); // grow up 1
	body[len-1,0] := x;
	body[len-1,1] := y;
	gotoXY(x,y);
	write('x');
	gotoXY(2,2); // move cursor back to score panel
    textColor(lightred);
	write(' Point: ',score);
end;

//* #2 mushroom
procedure snakeReduce;
(*  Reduce the length of snake by 1 and loss 5 points
    INPUT
        (none)
    OUTPUT
        (none)
*)
begin
    inc(score,-5); // loss 5 points
	gotoXY(body[len-1,0], body[len-1,1]);
	write(' ');
	body[len-1,0] := 0;
	body[len-1,1] := 0;
	inc(len,-1); // reduce 1
	gotoXY(2,2); // move cursor back to score panel
    textColor(lightred);
	write(' Point: ',score);
end;

//* #3 heart
procedure snakeLifeUp;
(*  Win 1 extra life
    INPUT
        (none)
    OUTPUT
        (none)
*)
begin
    inc(life, 1);
    gotoXY(space_width-9,2);
    writeln(' Life: ',life);
end;

//* #4 bomb
procedure snakeLifeDown;
(*  Loss 1 life
    INPUT
        (none)
    OUTPUT
        (none)
*)
begin
    inc(life, -1);
    gotoXY(space_width-9,2);
    writeln(' Life: ',life);
end;

//* #5 strewberry
procedure snakeBoostScore;
(*  When snake eats a strawberry
    INPUT
        (none)
    OUTPUT
        (none)
*)
begin
    inc(score, 50); // win 50 points
    gotoXY(2,2);
    textColor(lightred);
    write(' Point: ',score);
end;

//* #6 speed-up bean
procedure snakeSpeedUp;
(*  When snake eats a speed-up bean
    INPUT
        (none)
    OUTPUT
        (none)
*)
var i:Integer;
var endtime:LongInt;
begin
    if (speed <> 0) then inc(speed, -100);
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

//TODO #7 diamond
procedure snakeBoostBean;
var i,j,ind:Integer;
var endtime:LongInt;
begin
    // fill the screen
    textColor(green);
    if (diff = 'd') then
    begin
        for i := 2 to space_width-1 do
        // begin  
            for j := 4 to space_height-2 do
            // begin
                if not (snakeContain(i,j)) and not (wallContain(i,j)) then
                begin
                    ind := (i-1) * (j-3) - 1;
                    beans[ind,2] := 1; // apple (normal bean)
                    beans[ind,3] := 999999;
                    gotoXY(i,j);
                    writeln('*');
                end;
            // end;
        // end;
    end
    else
    begin
        ind := 0;
        beans_amount := 1;
        for i := 2 to space_width-1 do
            for j := 4 to space_height-2 do
                if not (snakeContain(i,j)) then 
                begin
                    // ind := (space_height-6) + (space_height-5)*(i-3) + (j-3); // 19*i + j - 42;
                    setLength(beans, beans_amount, 4);
                    beans[ind,0] := i; // apple (normal bean)
                    beans[ind,1] := j;
                    beans[ind,2] := 1;
                    beans[ind,3] := 999999;
                    gotoXY(i,j);
                    write('*');
                    // gotoXY(i,j);
                    // write('T');
                    // write(ind);
                    // delay(20);
                    ind := ind + 1;
                    beans_amount := beans_amount + 1;
                end;
    end;
    beans_amount := beans_amount - 1;
    // set endtime
    endtime := convertToInt(time+encodeTime(0,0,5,0)); // i.e. last 10s
    for i := 0 to 254 do // find an unused position to save buff
    begin
        if (buff[i,0] = 0) then
        begin
            buff[i,0] := endtime;
            buff[i,1] := 666;
            break;
        end;
    end;
    gotoxy(2,2);
    write('            ',beans_amount);
    textColor(lightred);
end;

procedure snakeRecoverBean;
var i,j:Integer;
begin
    for i := 2 to space_width-1 do
        for j := 4 to space_height-2 do
        begin
            gotoXY(i,j);
            write(' ');
        end;
    gotoxy(2,2);
    write('            ',beans_amount);
    drawsnake;
    initiateBean(beans_amount_default);
    beans_amount := beans_amount_default;
end;

//* Game Over
procedure snakeDie;
(*  When snake eats a bomb or the game is over or be manually closed
    INPUT
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
    // creatFile;
    halt;
end;

procedure checkSnakeStatus(x,y,ind:integer);
(*  Find out which kind of bean that has been eaten by snake and snake status
    after eating
    INPUT
        x: X coordinate [int]
        y: Y coordinate [int]
        ind: index of bean [int]
    OUTPUT
*)
var i:Integer;
var renew:Boolean;
begin
    case beans[ind,2] of
        1: begin snakeGrow(x,y); end; // #1 apple(normal bean) snakeGrow(x,y);
        2: begin snakeReduce; end; // #2 mushroom
        3: begin snakeLifeUp; end; // #3 heart
        4: begin snakeLifeDown; end; // #4 bomb
        5: begin snakeBoostScore; end; // #5 strawberry snakeBoostScore;
        6: begin snakeSpeedUp; end; // #6 speed-up snakeSpeedUp;
        7: begin snakeBoostBean; end;// #7 diamond snakeBoostBean;
    end;
    if (life = 0) or (len = 0) then snakeDie;
    // check if it's necessary to generate new bean
    renew := True;
    if (beans[ind,2] <> 7) then
    begin
        for i := 0 to 254 do
        begin
            if (buff[i,1] = 666) then
            begin
                renew := False;
                break;
            end;
        end;
    end;
    if renew then generateBean(ind);
end;


//* vvvvvvvvvvvvvvvvvvvvvvvvv Snake Movement Control vvvvvvvvvvvvvvvvvvvvvvvvv
procedure checkTime;
(*  Check if buff is time's up
    INPUT
        (none)
    OUTPUT
        (none)
*)
var now:LongInt; i,ind:Integer;
begin
    now := convertToInt(time);
    // check/disappear buff
    if (buff[0,0] <> 0) and (now >= buff[0,0]) then
    begin
        if (buff[0,1] = 100) then
        begin
            inc(speed, 100);
        end
        else if (buff[0,1] = 666) then // recover origin beans
        begin
            snakeRecoverBean;
        end;
        // clear this buff
        for i := 1 to 254 do
        begin
            buff[i-1,0] := buff[i,0];
            buff[i-1,1] := buff[i,1];
        end;
    end;

    // check/disappear beans
    for ind := 0 to beans_amount-1 do
    begin
        if (now >= beans[ind,3]) then
        begin
            gotoXY(beans[ind,0], beans[ind,1]);
            write(' ');
            generateBean(ind);
        end;
    end;

    //* JUST FOR DEBUGGING vvv
    gotoXY(30,1);
    write(' buff:', buff[0,0], ', ', buff[0,1]);
    gotoXY(30,2);
    write(' buff:', buff[1,0], ', ', buff[1,1]);
    gotoXY(30,3);
    write(' buff:', buff[2,0], ', ', buff[2,1]);
    // gotoXY(30,4);
    // write(' buff:', buff[3,0], ', ', buff[3,1]);
    gotoXY(60,1);
    write(' speed:', speed);
    gotoXY(60,2);
    write(' len:', len);
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
	wasx := body[len-1,0];
	wasy := body[len-1,1];
	gotoXY(wasx, wasy); write(' '); // change snake tail to empty
    // check if snake meets itself
	if (snakeContain(body[0,0]+x, body[0,1]+y)) then snakeDie;
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
            // generateBean(tmp);
            break;
        end;
    end;
    // ***** Hitting *****
    if diff='d' then
    begin
        for tmp := 0 to wall_amount-1 do // snake meets wall
        begin
            if (snakeContain(hWalls[tmp,0],hWalls[tmp,1])) or
               (snakeContain(vWalls[tmp,0],vWalls[tmp,1])) then
            begin
                snakeDie;
            end;
        end;
    end;
	if (snakeCollision) then snakeDie; // meets perimeters
end;

//* vvvvvvvvvvvvvvvvvvvvvvvvv Welcome Window vvvvvvvvvvvvvvvvvvvvvvvvv
procedure intros;
var i:integer;
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
	i:=10;
	if (diff<>'d') and (diff<>'f') then
	begin
		repeat 
		gotoxy(19,i);
		writeln('Error! Vous devez entrer la lettre f ou d');
		gotoxy(19,i+1);
		writeln('Entrez f pour facile et d pour difficile');
		readln (diff);
		i:=i+1;
		until (diff='f') or (diff='d');
	end;
	if diff='f' then
	begin
		gotoXY(23,i+1);
		writeln('Vous avez choisir la mode facile');
	end;
	
	if diff='d' then
	begin
		gotoXY(21,i+1);
		writeln('Vous avez choisir la mode difficile');
	end;
	gotoXY(24,i+2);
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
	dir := 1; // initial direction {1=east, 2=south, 3=west, 4=north}
	len := 3; // initial length of snake
    life := 3; // initial lives of snake
	score := 0; // initial score
	speed := 400; // initial time to delay
    beans_amount := 15; // initial amount of beans
    beans_amount_default := beans_amount;
    wall_number := 4;
    wall_length := 3;
    wall_amount := wall_number * wall_length;
    space_width := 80; // width of gaming space
    space_height := 24; // height of gaming space
	// initiate snake and buff array
	for indice := 0 to 254 do
        body[indice,0] := 0;
        body[indice,1] := 0;
        buff[indice,0] := 0;
        buff[indice,1] := 0;
    body[0,0] := 12;
    body[0,1] := 12;
    body[1,0] := 11;
    body[1,1] := 12;
    body[2,0] := 10;
    body[2,1] := 12;
    
    // ***** Introduction *****
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
        gotoXY(space_width-9,2);
        writeln(' Life: ',life);
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
                key:=readkey;
                if (key = #0) then
                begin
                    key:=readkey;
                    case key of
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
                if (key = #27) then snakeDie; // press ESC key
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
