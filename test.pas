program test;

const max=15;
var score:array [1..max] of Integer;
    name:array [1..max] of string;
    ind,pp,i,s,newp:integer;
    n:string;

begin
    for i:=1 to 3 do
    begin
        writeln('entrez le nom et le numero',i);
        readln(name[i]);
        readln(score[i]);
    end;
    ind:=15;
    writeln(ind);
    readln(name[ind]);
    readln(score[ind]);
    //*******************************************************
    //start to refresh 
    s:=score[ind];
    n:=name[ind];
    //newp find out positon of new record
    newp:=0;
    repeat
        newp:=newp+1;
    until (s>=score[newp]);
    //check out if player played before
    pp:=0;
    repeat
        pp:=pp+1;
    until (n=name[pp]) or (pp=ind);
    //player played before but not break his record
    //n position of previous record of same player
    if (name[pp]=n) and (score[pp]>=s) then
        begin
            name[ind]:='';
            score[ind]:=0;
        end
    //player played before and break his record
    else if (name[pp]=n) and (score[pp]<s) then
        begin
            for i:=pp downto newp+1 do 
            begin
                score[i]:=score[i-1];
                name[i]:=name[i-1];
            end;  
            score[newp]:=s;
            name[newp]:=n;
            name[ind]:='';
            score[ind]:=0;
        end 
    //player haven't played before
    else
        begin
            for i:=ind downto newp+1 do 
            begin
                score[i]:=score[i-1];
                name[i]:=name[i-1];
            end;    
            score[newp]:=s;
            name[newp]:=name[ind];   
        end;
    for i:=1 to max do
    begin
        write(name[i],' ',score[i]);
        writeln();
    end;
end. 
