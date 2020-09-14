# -*- coding: utf-8 -*-
"""
Created on Wed Feb 19 15:19:09 2020

@author: Sadiq
"""

# -*- coding: utf-8 -*-
"""
Created on Wed Feb 19 04:50:37 2020

@author: Sadiq
"""
import numpy as np
import sys
sys.path.insert(0, r'F:/OneDrive - unige.it/ViveStudy/4_Software/PythonWorkspace/lib')
import PdlFileGen_lib as pfg

np.set_printoptions(precision=8)

# Units in millimeter, degree

freq = 100; #Hz
dt = 1/freq; #seconds

jjj= range(10)
for j in jjj:
    j = j +1
    ffilename = "SA_C_path"+ str(j)
    # Loading the text files
    fname_BU= "data/"+ffilename;
    data = []
    with open(fname_BU+ ".txt") as inputfile:   
        for line in inputfile:
            data.append(line.rstrip().split(','))
            
        # Removing the parenthesis from the list
        for sub in data:
            sub[:] = map(float, (s.rsplit("'", 1)[0] for s in sub))

    
    
    traj_data = data;
    
    # ENTER THE PROGRAM NAME
    pname = ffilename
    
    # Writing to a txt file
    pfg.write_file(pname, traj_data)
    
    # Loading the trajectory file
    data = pfg.load_traj_file(pname)
    
    # Generate motion program PDL file
    lin_spd = 0.1 #m/s
    rot_spd = 0.5 #rad/s
    #tool_frame_offset = [0, 0, 45, 0, 0, 0] # Tool frame offset for vive tracker mount 44.9
    tool_frame_offset = [50, 0, 211, 0, 0, 0] # Tool frame offset for vive controller mount
    #tool_frame_offset = [0, 0, 146, 0, 0, 0] # Tool frame offset for vive hmd mount 146.387
    pfg.gen_pdl_file_StaticAnalysis(pname, data, lin_spd, rot_spd, "mf",tool_frame_offset) # "mf" for tcp connection
    
    # Moving the files that need to be copied into robot into a folder with the name of the program
    # for TCP IP connection data extraction #Sampling rate will vary, should resample while post proccesing, Matlab scripts available for post processing
    pfg.move_files_Net(pname)
    