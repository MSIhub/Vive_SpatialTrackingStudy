%%Create folder structure for raw data collection

vel = 'V0_3';
baseDirectory = './RawData/';

parentDir = [baseDirectory, char(vel)];
mkdir(parentDir)

subDir1 = [parentDir, char('/XO1')]; 
mkdir(subDir1);

subDir2 = [parentDir, char('/YO1')];
mkdir(subDir2);

subDir3 = [parentDir, char('/XO2')];
mkdir(subDir3);

subDir4 = [parentDir, char('/YO2')];
mkdir(subDir4);

subDir5 = [parentDir, char('/XO3')];
mkdir(subDir5);

subDir6 = [parentDir, char('/YO3')];
mkdir(subDir6);

