vel_avg = [ 885, 845, 484.0134, 247, 198.65, 174.1033, 149.4215, 124.06514, 99.84, 74.9406, 49.9827, 24.9954 ]';
rmse = [562.7, 363.1446, 343.153, 298.7, 133.24, 31.9130, 24.99,  13.8740, 8.847, 5.2970, 4.4770, 3.7960 ]'; 

test = [vel_avg, rmse];

figure()
plot(vel_avg, rmse);


histogram(test)