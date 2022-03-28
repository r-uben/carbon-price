function theta = draw_truncated_student(c,sig,nu,pos)

pd = makedist('tlocationscale',c,sig,nu);
if pos == 1
    t = truncate(pd,0,inf);
elseif pos == -1
    t = truncate(pd,-inf,0);
end 

theta = random(t);