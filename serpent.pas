
(*******************************************************************************
INSA ROUEN NORMANDIE
DEPARTEMENT STPI - PROJET INFO

Liyu ZHANG, Tonglin Yan, Augustin SCHWARTZ
Superviseur: Jean-Baptiste LOUVET

20 December 2018
*******************************************************************************)

Program serpent;

Uses crt, sysutils, math, rank;



//! ----------------------------------------------------------------------------
//!                              VARIABLE DECLARATION
//! ----------------------------------------------------------------------------

Var indice,len,dir,dirnew,beans_amount,beans_amount_default:   Integer;
    space_width,space_height:   Integer;
    wall_number,wall_length,wall_amount:   Integer;
    body:   array[0..254, 0..1] Of Integer;
    // coordinates of snake
    buff:   array[0..254, 0..1] Of LongInt;
    // snake buff: effect
    beans:   array Of array Of LongInt;
    // coordinates of bean
    hWalls:   array Of array Of Integer;
    // coordinates of horizontal wall
    vWalls:   array Of array Of Integer;
    // coordinates of vertical wall
    diff,start:   String;
    key:   Char;
    score,speed,life:   Integer;
    f:   File Of ranking;
    r:   ranking;



    //! ----------------------------------------------------------------------------
    //!                                   FUNCTION
    //! ----------------------------------------------------------------------------
    //* when snake meets wall
Function snakeCollision():   Boolean;
(*  Check if a part of snake has touched the obstacle
    INPUT
        (none)
    OUTPUT
        snakeCollision: if collision, true; if not, false [Boolean]
*)
Begin
    snakeCollision := false;
    If (body[0,0] < 2) Or (body[0,0] >= space_width) Then
        snakeCollision := true;
    If (body[0,1] < 4) Or (body[0,1] >= space_height-1) Then
        snakeCollision := true;
End;

Function snakeContain(x,y:Integer):   Boolean;
(*  Check if a point is already existed in snake body
    INPUT
        x: X coordinate [int]
        y: Y coordinate [int]
    OUTPUT
        snakeContain: if existant, true; else, false [Boolean]
*)
Var i:   Integer;
Begin
    snakeContain := false;
    For i := 0 To len-1 Do
        Begin
            If (body[i,0] = x) And (body[i,1] = y) Then
                Begin
                    snakeContain := true;
                    break;
                End
        End;
End;

Function wallContain(x,y:Integer):   Boolean;
(*  Check if a point is already existed in snake body
    INPUT
        x: X coordinate [int]
        y: Y coordinate [int]
    OUTPUT
        snakeContain: if existant, true; else, false [Boolean]
*)
Var i:   Integer;
Begin
    wallContain := false;
    For i := 0 To wall_amount-1 Do
        Begin
            If (hWalls[i,0] = x) And (hWalls[i,1] = y) Then
                Begin
                    wallContain := true;
                    break;
                End;
            If (vWalls[i,0] = x) And (vWalls[i,1] = y) Then
                Begin
                    wallContain := true;
                    break;
                End;
        End;
End;

Function convertToInt(t:TDateTime):   LongInt;
(*  Convert TDateTime to LongInt
    INPUT
        t: time [TDateTime]
    OUTPUT
        convertToInt: time in second [LongInt]
*)
Var HH, MM, SS, MS:   Word;
Begin
    DecodeTime(t, HH, MM, SS, MS);
    convertToInt := HH*3600 + MM*60 + SS;
End;



//! ----------------------------------------------------------------------------
//!                                   PROCEDURE
//! ----------------------------------------------------------------------------
//* draw perimeter
Procedure drawbox(x0,y0,width,height:Integer; title:String);
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
Var i1,i2:   Integer;
Begin
    For i2 := 1 To height Do
        Begin
            gotoXY(x0,y0+i2-1);
            For i1 := 1 To width Do
                Begin
                    If (i2 = 1) Or (i2 = height) Then
                        If (i1 = 1) Or (i1 = width) Then
                            write('+')
                    Else
                        write('-')
                    Else If (i1 = 1) Or (i1 = width) Then
                             write('|')
                    Else
                        write(' ')
                End;
        End;
    If (title <> '') Then
        Begin
            i1 := y0+floor((height-1)/2);
            i2 := x0+floor(width/2-length(title)/2);
            gotoXY(i2,i1);
            write(title);
        End;
End;

//* make wall
Procedure horizontalWalls(wall_number,wall_length,wall_amount:Integer);
(* Make horizontal walls
*)
Var ind,l,pos,x,y:   Integer;
Begin
    setLength(hWalls, wall_amount, 2);
    For ind := 0 To wall_number-1 Do
        Begin
            // find a random position for new wall
            Repeat
                x := random(space_width-3-wall_length)+2;
                y := random(space_height-5-wall_length)+4;
            Until Not snakeContain(x,y);
            // build wall
            For l := 1 To wall_length Do
                Begin
                    pos := ind * wall_length + l - 1;
                    hWalls[pos,0] := x + l - 1;
                    hWalls[pos,1] := y;
                    gotoXY(hWalls[pos,0],hWalls[pos,1]);
                    textColor(lightblue);
                    write('-');
                End;
        End;
    textColor(lightred);
    // reset color to red
End;

Procedure verticalWalls(wall_number,wall_length,wall_amount:Integer);
(* Make vertical walls
*)
Var ind,l,pos,x,y:   Integer;
Begin
    setLength(vWalls, wall_amount, 2);
    For ind := 0 To wall_number-1 Do
        Begin
            // find a random position for new wall
            Repeat
                x := random(space_width-3-wall_length)+2;
                y := random(space_height-5-wall_length)+4;
            Until Not snakeContain(x,y);
            // build wall
            For l := 1 To wall_length Do
                Begin
                    pos := ind * wall_length + l - 1;
                    vWalls[pos,0] := x;
                    vWalls[pos,1] := y + l - 1;
                    gotoXY(vWalls[pos,0],vWalls[pos,1]);
                    textColor(lightblue);
                    write('|');
                End;
        End;
    textColor(lightred);
    // reset color to red
End;

//* draw snake
Procedure drawsnake;
(*  INPUT
        (none)
    OUTPUT
        (none)
*)
Var tmp:   Integer;
Begin
    For tmp := 0 To len-1 Do
        Begin
            gotoXY(body[tmp,0], body[tmp,1]);
            If (tmp = 0) Then write('o')
            Else write('x');
        End;
End;

//*reorder the rank
Procedure refreshRank(ind:Integer);
(*  Add new score to file
    INPUT
        ind: the total number of player [Integer]
    OUTPUT
        (none)
*)
Var pp,i,s,newp:   Integer;
    n:   String;
Begin
    //start to refresh 
    s := r.score[ind];
    n := r.name[ind];
    //newp find out positon of new record
    newp := 0;
    Repeat
        newp := newp+1;
    Until (s>=r.score[newp]);
    //check out if player played before
    pp := 0;
    Repeat
        pp := pp+1;
    Until (n=r.name[pp]) Or (pp=ind);
    //player played before but not break his record
    //n position of previous record of same player
    If (r.name[pp]=n) And (r.score[pp]>=s) Then
        Begin
            r.name[ind] := '';
            r.score[ind] := 0;
        End
        //player played before and break his record
    Else If (r.name[pp]=n) And (r.score[pp]<s) Then
             Begin
                 For i:=pp Downto newp+1 Do
                     Begin
                         r.score[i] := r.score[i-1];
                         r.name[i] := r.name[i-1];
                     End;
                 r.score[newp] := s;
                 r.name[newp] := n;
                 r.name[ind] := '';
                 r.score[ind] := 0;
             End
             //player haven't played before
    Else
        Begin
            For i:=ind Downto newp+1 Do
                Begin
                    r.score[i] := r.score[i-1];
                    r.name[i] := r.name[i-1];
                End;
            r.score[newp] := s;
            r.name[newp] := r.name[ind];
        End;
    For i:=1 To max Do
        Begin
            write(r.name[i],' ',r.score[i]);
            writeln();
        End;
End;

//* store the score 
Procedure creatFile;
(* Save score to disk
   INPUT       
       (none)
   OUTPUT
       (none)
*)
Var i:   Integer;
Begin
    ClrScr;
    assign(f,'store.txt');
    Reset(f);
    While Not eof(f) Do
        i := 0;
    Repeat
        read(f,r);
        i := i+1;
    Until (r.name[i]='');
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
End;

//* vvvvvvvvvvvvvvvvvvvvvvvvv Beans and Effects vvvvvvvvvvvvvvvvvvvvvvvvv
Procedure generateBean(ind:Integer);
(*  Generate a new bean after eating or disappearing
    INPUT
        (none)
    OUTPUT
        (none)
*)
Var x,y,r:   Integer;
Begin
    Repeat
        // random position for new bean
        x := random(space_width-3)+2;
        y := random(space_height-5)+4;
    Until Not snakeContain(x,y);
    beans[ind,0] := x;
    beans[ind,1] := y;
    gotoXY(x,y);
    r := random(9);
    r := 7;
    Case r Of 
        2: // mushroom
             Begin
                 beans[ind,2] := 2;
                 beans[ind,3] := 999999;
                 textColor(brown);
                 write('*');
             End;
        3: // heart
             Begin
                 beans[ind,2] := 3;         
                 beans[ind,3] := convertToInt(time+encodeTime(0,0,5,0));
                 textColor(magenta);
                 write('*');
             End;
        4: // bomb
             Begin
                 beans[ind,2] := 4;
                 beans[ind,3] := convertToInt(time+encodeTime(0,0,10,0));
                 textColor(black);
                 write('X');
             End;
        5: // strewberry
             Begin
                 beans[ind,2] := 5;     
                 beans[ind,3] := 999999;
                 textColor(red);
                 write('*');
             End;
        6: // speed-up bean
             Begin
                 beans[ind,2] := 6;
                 beans[ind,3] := 999999;
                 textColor(blue);
                 write('*');
             End;
        7: // diamond
             Begin
                 beans[ind,2] := 7; 
                 beans[ind,3] := convertToInt(time+encodeTime(0,0,5,0));
                 textColor(lightcyan);
                 write('◊');
             End;
        8: // magic box
             Begin
                 beans[ind,2] := random(7)+1;
                 Case beans[ind,2] Of 
                     3:   beans[ind,3] := convertToInt(time+encodeTime(0,0,5,0));
                     4:   beans[ind,3] := convertToInt(time+encodeTime(0,0,10,0));
                     7:   beans[ind,3] := convertToInt(time+encodeTime(0,0,5,0));
                     Else
                         beans[ind,3] := 999999;
                 End;
                 textColor(white);
                 write('?');
             End;
        Else // apple (normal bean)
            beans[ind,2] := 1;
        beans[ind,3] := 999999;
        textColor(green);
        write('*');
    End;
    textColor(lightred);
End;

Procedure initiateBean(amount:Integer);
(*  Initiate beans by a given number of beans
    INPUT
        amount: initial number of beans [int]
    OUTPUT
        (none)
*)
Var ind:   Integer;
Begin
    setLength(beans, amount, 4);
    For ind := 0 To amount-1 Do
        Begin
            generateBean(ind);
        End;
End;

//* #1 apple (normal bean)
Procedure snakeGrow(x,y:Integer);
(*  Increase the length of snake by 1 and win 5 points
    INPUT
        x: X coordinate [int]
        y: Y coordinate [int]
    OUTPUT
        (none)
*)
Begin
    inc(score,5);
    // win 5 points
    inc(len,1);
    // grow up 1
    body[len-1,0] := x;
    body[len-1,1] := y;
    gotoXY(x,y);
    write('x');
    gotoXY(2,2);
    // move cursor back to score panel
    textColor(lightred);
    write(' Point: ',score);
End;

//* #2 mushroom
Procedure snakeReduce;
(*  Reduce the length of snake by 1 and loss 5 points
    INPUT
        (none)
    OUTPUT
        (none)
*)
Begin
    inc(score,-5);
    // loss 5 points
    gotoXY(body[len-1,0], body[len-1,1]);
    write(' ');
    body[len-1,0] := 0;
    body[len-1,1] := 0;
    inc(len,-1);
    // reduce 1
    gotoXY(2,2);
    // move cursor back to score panel
    textColor(lightred);
    write(' Point: ',score);
End;

//* #3 heart
Procedure snakeLifeUp;
(*  Win 1 extra life
    INPUT
        (none)
    OUTPUT
        (none)
*)
Begin
    inc(life, 1);
    gotoXY(space_width-9,2);
    writeln(' Life: ',life);
End;

//* #4 bomb
Procedure snakeLifeDown;
(*  Loss 1 life
    INPUT
        (none)
    OUTPUT
        (none)
*)
Begin
    inc(life, -1);
    gotoXY(space_width-9,2);
    writeln(' Life: ',life);
End;

//* #5 strewberry
Procedure snakeBoostScore;
(*  When snake eats a strawberry
    INPUT
        (none)
    OUTPUT
        (none)
*)
Begin
    inc(score, 50);
    // win 50 points
    gotoXY(2,2);
    textColor(lightred);
    write(' Point: ',score);
End;

//* #6 speed-up bean
Procedure snakeSpeedUp;
(*  When snake eats a speed-up bean
    INPUT
        (none)
    OUTPUT
        (none)
*)
Var i:   Integer;
    endtime:   LongInt;
Begin
    If (speed <> 0) Then inc(speed, -100);
    endtime := convertToInt(time+encodeTime(0,0,10,0));
    // i.e. last 10s
    For i := 0 To 254 Do
        // find an unused position to save buff
        Begin
            If (buff[i,0] = 0) Then
                Begin
                    buff[i,0] := endtime;
                    buff[i,1] := 100;
                    break;
                End;
        End;
End;

//* #7 diamond
Procedure snakeBoostBean;
(*  When snake eats a diamond
    INPUT
        (none)
    OUTPUT
        (none)
*)
Var i,j,ind:   Integer;
    endtime:   LongInt;
Begin
    // fill the screen
    textColor(green);
    If (diff = 'd') Then
        Begin
            //TODO correct the unfinished bug
            For i := 2 To space_width-1 Do
                For j := 4 To space_height-2 Do
                    If Not (snakeContain(i,j)) And Not (wallContain(i,j)) Then
                        Begin
                            ind := (i-1) * (j-3) - 1;
                            beans[ind,2] := 1;
                            // apple (normal bean)
                            beans[ind,3] := 999999;
                            gotoXY(i,j);
                            writeln('*');
                        End;
        End
    Else
        Begin
            ind := 0;
            beans_amount := 1;
            For i := 2 To space_width-1 Do
                For j := 4 To space_height-2 Do
                    If Not (snakeContain(i,j)) Then
                        Begin

                      // ind := (space_height-6) + (space_height-5)*(i-3) + (j-3); // 19*i + j - 42;
                            setLength(beans, beans_amount, 4);
                            beans[ind,0] := i;
                            // apple (normal bean)
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
                        End;
        End;
    beans_amount := beans_amount - 1;
    // set endtime
    endtime := convertToInt(time+encodeTime(0,0,5,0));
    // i.e. last 5s
    For i := 0 To 254 Do
        // find an unused position to save buff
        Begin
            If (buff[i,0] = 0) Then
                Begin
                    buff[i,0] := endtime;
                    buff[i,1] := 666;
                    break;
                End;
        End;
    gotoxy(2,2);
    textColor(lightred);
End;

Procedure snakeRecoverBean;
(*  After snake eats a diamond, set back to default configuration of beans
    INPUT
        (none)
    OUTPUT
        (none)
*)
Var i,j:   Integer;
Begin
    For i := 2 To space_width-1 Do
        For j := 4 To space_height-2 Do
            Begin
                gotoXY(i,j);
                write(' ');
            End;
    drawsnake;
    initiateBean(beans_amount_default);
    beans_amount := beans_amount_default;
End;

//* Game Over
Procedure snakeDie;
(*  When snake eats a bomb or the game is over or be manually closed
    INPUT
        (none)
    OUTPUT
        (none)
*)
Begin
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
End;

Procedure checkSnakeStatus(x,y,ind:Integer);
(*  Find out which kind of bean that has been eaten by snake and snake status
    after eating
    INPUT
        x: X coordinate [int]
        y: Y coordinate [int]
        ind: index of bean [int]
    OUTPUT
*)
Var i:   Integer;
    renew:   Boolean;
Begin
    Case beans[ind,2] Of 
        1: // #1 apple(normal bean) snakeGrow(x,y);
             Begin
                 snakeGrow(x,y);
             End;
        2: // #2 mushroom
             Begin
                 snakeReduce;
             End;
        3: // #3 heart
             Begin
                 snakeLifeUp;
             End;
        4: // #4 bomb
             Begin
                 snakeLifeDown;
             End;
        5: // #5 strawberry
             Begin
                 snakeBoostScore;
             End;
        
        6: // #6 speed-up
             Begin
                 snakeSpeedUp;
             End;
        7: // #7 diamond
             Begin
                 snakeBoostBean;
             End;
    End;
    If (life = 0) Or (len = 0) Then snakeDie;
    // check if it's necessary to generate new bean
    renew := True;
    If (beans[ind,2] <> 7) Then
        Begin
            For i := 0 To 254 Do
                Begin
                    If (buff[i,1] = 666) Then
                        Begin
                            renew := False;
                            break;
                        End;
                End;
        End;
    If renew Then generateBean(ind);
End;


//* vvvvvvvvvvvvvvvvvvvvvvvvv Snake Movement Control vvvvvvvvvvvvvvvvvvvvvvvvv
Procedure checkTime;
(*  Check if buff is time's up
    INPUT
        (none)
    OUTPUT
        (none)
*)
Var now:   LongInt;
    i,ind:   Integer;
Begin
    now := convertToInt(time);
    // check/disappear buff
    If (buff[0,0] <> 0) And (now >= buff[0,0]) Then
        Begin
            If (buff[0,1] = 100) Then
                Begin
                    inc(speed, 100);
                End
            Else If (buff[0,1] = 666) Then // recover origin beans
                     Begin
                         snakeRecoverBean;
                     End;
            // clear this buff
            For i := 1 To 254 Do
                Begin
                    buff[i-1,0] := buff[i,0];
                    buff[i-1,1] := buff[i,1];
                End;
        End;
    // check/disappear beans
    For ind := 0 To beans_amount-1 Do
        Begin
            If (now >= beans[ind,3]) Then
                Begin
                    gotoXY(beans[ind,0], beans[ind,1]);
                    write(' ');
                    generateBean(ind);
                End;
        End;
End;

Procedure moveSnake;
(*  Change the direction of moving
    INPUT
        (none)
    OUTPUT
        (none)
*)
Var x,y,wasx,wasy,tmp:   Integer;
Begin
    // get direction from main program
    Case dir Of 
        1:
             Begin
                 x :=  1;
                 y := 0;
             End;
        // right (i.e. east)
        2:
             Begin
                 x :=  0;
                 y := 1;
             End;
        // down (i.e. south)
        3:
             Begin
                 x := -1;
                 y := 0;
             End;
        // left (i.e. west)
        4:
             Begin
                 x :=  0;
                 y := -1;
             End;
        // up (i.e. north)
    End;
    // ***** Moving *****
    gotoXY(body[0,0], body[0,1]);
    write('x');
    // change snake head to body
    wasx := body[len-1,0];
    wasy := body[len-1,1];
    gotoXY(wasx, wasy);
    write(' ');
    // change snake tail to empty
    // check if snake meets itself
    If (snakeContain(body[0,0]+x, body[0,1]+y)) Then snakeDie;
    // change segment of snake: from previous position to next position
    For tmp := 0 To len-2 Do
        Begin
            body[len-tmp-1,0] := body[len-tmp-2,0];
            body[len-tmp-1,1] := body[len-tmp-2,1];
        End;
    // change snake head: add new position
    body[0,0] := body[0,0] + x;
    body[0,1] := body[0,1] + y;
    gotoXY(body[0,0], body[0,1]);
    write('o');
    // ***** Eating *****
    For tmp := 0 To beans_amount-1 Do
        Begin
            If (snakeContain(beans[tmp,0],beans[tmp,1])) Then // a bean is eaten
                Begin
                    checkSnakeStatus(wasx, wasy, tmp);
                    // generateBean(tmp);
                    break;
                End;
        End;
    // ***** Hitting *****
    If diff='d' Then
        Begin
            For tmp := 0 To wall_amount-1 Do
                // snake meets wall
                Begin
                    If (snakeContain(hWalls[tmp,0],hWalls[tmp,1])) Or
                       (snakeContain(vWalls[tmp,0],vWalls[tmp,1])) Then
                        Begin
                            snakeDie;
                        End;
                End;
        End;
    If (snakeCollision) Then snakeDie;
    // meets perimeters
End;

//* vvvvvvvvvvvvvvvvvvvvvvvvv Welcome Window vvvvvvvvvvvvvvvvvvvvvvvvv
Procedure intros;
(*  Instructions and rules of the game
    INPUT
        (none)
    OUTPUT
        (none)
*)
Var i:   Integer;
Begin
    gotoXY(24,4);
    writeln('Bienvenue au jeu de serpent!');
    gotoXY(26,5);
    writeln('Voici les règles de ce jeu：');
    gotoXY(2,6);
    writeln('Vous pouvez utiliser les flèches sur le clavier pour controler la',
            'direction');
    gotoXY(8,7);
    writeln('Vous ne pouvez pas toucher les murs et le corps du serpent');
    gotoXY(17,8);
    writeln('Maintenant vous pouvez choisir la difficulté');
    gotoXY(19,9);
    writeln('Entrez f pour facile et d pour difficile');
    readln(diff);
    i := 10;
    If (diff<>'d') And (diff<>'f') Then
        Begin
            Repeat
                gotoxy(19,i);
                writeln('Error! Vous devez entrer la lettre f ou d');
                gotoxy(19,i+1);
                writeln('Entrez f pour facile et d pour difficile');
                readln (diff);
                i := i+1;
            Until (diff='f') Or (diff='d');
        End;
    If diff='f' Then
        Begin
            gotoXY(23,i+1);
            writeln('Vous avez choisir la mode facile');
        End;
    If diff='d' Then
        Begin
            gotoXY(21,i+1);
            writeln('Vous avez choisir la mode difficile');
        End;
    gotoXY(24,i+2);
    writeln('Entrez c pour commencer la jeu');
    readln(start);
End;



//! ----------------------------------------------------------------------------
//!                                  MAIN PROGRAM
//! ----------------------------------------------------------------------------
Begin
    // ***** Initiation *****
    ClrScr;
    Randomize;
    dir := 1;
    // initial direction {1=east, 2=south, 3=west, 4=north}
    len := 3;
    // initial length of snake
    life := 3;
    // initial lives of snake
    score := 0;
    // initial score
    speed := 400;
    // initial time to delay
    beans_amount := 15;
    // initial amount of beans
    beans_amount_default := beans_amount;
    wall_number := 4;
    wall_length := 3;
    wall_amount := wall_number * wall_length;
    space_width := 80;
    // width of gaming space
    space_height := 24;
    // height of gaming space
    // initiate snake and buff array
    For indice := 0 To 254 Do
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
    If start = 'c' Then
        Begin
            ClrScr;
            textColor(lightblue);
            drawbox(1,1,space_width,space_height,'');
            //moving space, wall
            drawbox(1,1,space_width,3,'Jeu de Serpent (c) 2018');
            // title of the game
            // print initial snake on screen
            textColor(lightred);
            drawsnake;
            gotoXY(2,2);
            writeln(' Point: ',score);
            gotoXY(space_width-9,2);
            writeln(' Life: ',life);
            // initiate beans
            initiateBean(beans_amount);
            // initiate beans by a given number
            If diff='d' Then
                Begin
                    horizontalWalls(wall_number,wall_length,wall_amount);
                    // create horizontal walls
                    verticalWalls(wall_number,wall_length,wall_amount);
                    // create vertical walls
                End;

            // ***** Start Game *****
            Repeat
                delay(speed);
                If (keypressed) Then
                    Begin
                        key := readkey;
                        If (key = #0) Then
                            Begin
                                key := readkey;
                                Case key Of 
                                    #77:   dirnew := 1;
                                    // right (i.e. east)
                                    #80:   dirnew := 2;
                                    // down (i.e. south)
                                    #75:   dirnew := 3;
                                    // left (i.e. west)
                                    #72:   dirnew := 4;
                                    // up (i.e. north)
                                End;
                                If (dir = 1) And (dirnew <> 3) Then dir := dirnew;
                                If (dir = 2) And (dirnew <> 4) Then dir := dirnew;
                                If (dir = 3) And (dirnew <> 1) Then dir := dirnew;
                                If (dir = 4) And (dirnew <> 2) Then dir := dirnew;
                            End;
                        If (key = #27) Then snakeDie;
                        // press ESC key
                    End;
                movesnake;
                checkTime;
                gotoXY(2,2);
            Until false;
            textColor(lightgray);
            gotoXY(1,25);
        End;
End.
