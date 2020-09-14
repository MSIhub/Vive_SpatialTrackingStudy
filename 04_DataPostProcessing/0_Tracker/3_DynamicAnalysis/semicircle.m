function semicircle(S,E, sign,pattern, LineStyle, color)
mirrorFlag = false;
C_se = (S+ E)/2;
R = sqrt((C_se(1) - S(1))^2 + (C_se(2) - S(2))^2);
if pattern == 'Y'
    th = linspace( 0, pi, 100);
    if sign == true
        th = linspace( 0, -pi, 100);
    end
end

if pattern == 'X'
    th = linspace( pi/2, -pi/2, 100);
    if sign == true
        mirrorFlag = true;
    end
end
x = R*cos(th) + C_se(1);
y = R*sin(th) + C_se(2);

if mirrorFlag
    flipx = min(x);
    x_flipped = x - flipx;
    x = flipx - x_flipped;
    
end

hold on;
plot(x,y,LineStyle, 'color', color); axis equal;


end