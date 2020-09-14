# -*- coding: utf-8 -*-
"""
Created on Mon Jul 27 22:13:21 2020

@author: Sadiq
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from mpl_toolkits.mplot3d import proj3d
from matplotlib.patches import FancyArrowPatch

import sys
sys.path.insert(0, r'F:/OneDrive - unige.it/ViveStudy/4_Software/PythonWorkspace/lib')
import PdlFileGen_lib as pfg

np.set_printoptions(precision=8)

# Units in millimeter, degree

freq = 100; #Hz
dt = 1/freq; #seconds

# Visualisation trigger
visualize_data = True;

# Loading the text files
fname_tf= "data/SA_V2";
data = []
with open(fname_tf+ ".txt") as inputfile:   
    for line in inputfile:
        data.append(line.rstrip().split(','))
        
    # Removing the parenthesis from the list
    for sub in data:
        sub[:] = map(float, (s.rsplit("'", 1)[0] for s in sub))



traj_data = data;
N = len(traj_data);

## ENTER THE PROGRAM NAME
pname = "SA_V2_T"

# Writing to a txt file
pfg.write_file(pname, traj_data)

# Loading the trajectory file
data = pfg.load_traj_file(pname)

# Generate motion program PDL file
lin_spd = 0.2 #m/s
rot_spd = 0.2 #rad/s
tool_frame_offset = [0, 0, 45, 0, 0, 0] # Tool frame offset for vive tracker mount 44.9
#tool_frame_offset = [50, 0, 211, 0, 0, 0] # Tool frame offset for vive controller mount
#tool_frame_offset = [0, 0, 146, 0, 0, 0] # Tool frame offset for vive hmd mount 146.387
pfg.gen_pdl_file_StaticAnalysis(pname, data, lin_spd, rot_spd, "mf",tool_frame_offset) # "mf" for tcp connection

# Moving the files that need to be copied into robot into a folder with the name of the program
# for TCP IP connection data extraction #Sampling rate will vary, should resample while post proccesing, Matlab scripts available for post processing
pfg.move_files_Net(pname)

###############################################################################
# Calculating duration of run #

def dist(a1, a2):
    d = np.sqrt(np.square(a2[0]-a1[0]) + np.square(a2[1]-a1[1]) + np.square(a2[2]-a1[2]) )
    return d

d_total = 0.0
for itr4 in range(len(traj_data)-1):
    d_total = d_total + dist(traj_data[itr4][0:3], traj_data[itr4+1][0:3])

d_total = d_total/1000

t_sec = d_total/lin_spd
t_min = t_sec/60
t_hr = t_sec/3600