# -*- coding: utf-8 -*-
"""
Created on Wed Jan 22 21:51:33 2020

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

# Parameters of the cube boundary
A =[-500.0, -1300.0, 1000.0, -88.0, 45.0, 68.0] # starting point of cube [6dof]
length_of_cube = 1000; # distance in +X direction [mm]
width_of_cube = 550; # distance in +Y direction [mm]
height_of_cube = 600; # distance in +Z direction [mm]

# Discretisation of the cube 
nx = 6 # Number of points the length has to be divided
nz = 6 # Number of points the height has to be divided
#N = (nx*2)*nz; # total number of points

# Increamental step calculation 
dx = length_of_cube/nx;
dy = width_of_cube;
dz = height_of_cube/nz;

## Cube traversing zig zag
result = []; 
A = np.array(A);
for itr0 in range(nz+1): # nx +1 : to reach the limits otherwise is it stops a step below the limit
    #itr0 += 1;
    for itr1 in range(nx+1):
        #itr1 += 1; # to avoid 0 count
        result = result + list([list(A + np.array([itr1 * dx, 0,itr0 * dz,0,0,0])), list(A + np.array([itr1 * dx, dy,itr0 * dz, 0, 0, 0]))]);

traj_data = result;
N = len(traj_data);

## ENTER THE PROGRAM NAME
pname = "PWTraverse"

# Writing to a txt file
pfg.write_file(pname, traj_data)

# Loading the trajectory file
data = pfg.load_traj_file(pname)

# Generate motion program PDL file
lin_spd = 0.003 #m/s
rot_spd = 0.1 #rad/s
tool_frame_offset = [0, 0, 45, 0, 0, 0] # Tool frame offset for vive tracker mount
pfg.gen_pdl_file(pname, data, lin_spd, rot_spd, "mf",tool_frame_offset) # "mf" for tcp connection

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

############################################################################################################
############################################################################################################

####### 

class Arrow3D(FancyArrowPatch):
    def __init__(self, xs, ys, zs, *args, **kwargs):
        FancyArrowPatch.__init__(self, (0,0), (0,0), *args, **kwargs)
        self._verts3d = xs, ys, zs

    def draw(self, renderer):
        xs3d, ys3d, zs3d = self._verts3d
        xs, ys, zs = proj3d.proj_transform(xs3d, ys3d, zs3d, renderer.M)
        self.set_positions((xs[0],ys[0]),(xs[1],ys[1]))
        FancyArrowPatch.draw(self, renderer)


#-----------------------------------------------------------------------------------#
        #Plotting#
#-----------------------------------------------------------------------------------#
if (visualize_data == True or not('visualize_data' in globals())):
    # extracting data for plotting
    xdata = [];
    ydata = [];
    zdata = [];
    Adata = []; # angle [AER] ZYZ' conv
    Edata = [];
    Rdata = [];
    
    for items in result:
        xdata.append(items[0]);
        ydata.append(items[1]);
        zdata.append(items[2]);
        Adata.append(items[3]);
        Edata.append(items[4]);
        Rdata.append(items[5]);

    #-----------------------------------------------------------------------------------#
    # ploting the translational trajectory
    fig = plt.figure(figsize=(20, 15))
    ax = Axes3D(fig)
    ax.scatter(xdata, ydata, zdata,  s=100, c='g', marker='o', label='trajectory points')  # Plot the trajectory
    ax.text(xdata[0], ydata[0], zdata[0], '%s(%s,%s,%s)' % ('A',str(xdata[0]), str(ydata[0]), str(zdata[0])), size=30, zorder=5, color='k')
    for itr2 in range(len(xdata)-1):
        arw = Arrow3D([xdata[itr2],xdata[itr2+1]],[ydata[itr2],ydata[itr2+1]],[zdata[itr2],zdata[itr2+1]], arrowstyle="->", color="purple", lw = 3, mutation_scale=25)
        ax.add_artist(arw)
    
    ax.set_xlabel('X [mm]', fontsize=30, labelpad=20)
    ax.set_ylabel('Y [mm]', fontsize=30, labelpad=20)
    ax.set_zlabel('Z [mm]', fontsize=30, labelpad=20)
    ax.tick_params(axis='both', which='major', labelsize=20)
    ax.tick_params(axis='both', which='minor', labelsize=15)
    plt.grid(True,  ls=':')
    plt.title('Trajectory', fontsize=30)
    plt.axis(aspect='equal')
    plt.legend(loc='best', prop={'size': 20})
    plt.show()
    fig.canvas.draw()
    fig.canvas.flush_events()
    
    #-----------------------------------------------------------------------------------#
    
    # ploting the rotational trajectory
    fig = plt.figure(figsize=(20, 15))
    plt.polar(Adata, range(len(Adata)), 'ro', label = 'A')
    plt.polar(Edata, range(len(Adata)), 'go', label = 'E')
    plt.polar(Rdata, range(len(Adata)), 'bo', label = 'R')
    plt.title('Polar plot of AER -> ZYZ\' conv', fontsize=30)
    plt.tick_params(axis='both', which='major', labelsize=20)
    plt.tick_params(axis='both', which='minor', labelsize=15)
    plt.grid(True,  ls=':')
    
    plt.axis(aspect='equal')
    plt.legend(loc='best', prop={'size': 20})
    plt.show()
    fig.canvas.draw()
    fig.canvas.flush_events()
    
    
    #-----------------------------------------------------------------------------------#
    
    # Individual dof 
    fig = plt.figure(figsize=(20, 15))
    plt.plot(range(len(xdata)), xdata, c='g', marker='o', label='posX')
    plt.grid(True,  ls=':')
    plt.title('Position in X', fontsize=30)
    plt.xlabel('Index [int]', fontsize=30, labelpad=20)
    plt.ylabel('X [mm]', fontsize=30, labelpad=20)
    plt.axis(aspect='equal')
    plt.legend(loc='best', prop={'size': 20})
    plt.tick_params(axis='both', which='major', labelsize=20)
    plt.tick_params(axis='both', which='minor', labelsize=15)
    plt.show()
    fig.canvas.draw()
    fig.canvas.flush_events()
    
    #-----------------------------------------------------------------------------------#
    
    fig = plt.figure(figsize=(20, 15))
    plt.plot(range(len(ydata)), ydata, c='g', marker='o', label='posY')
    plt.grid(True,  ls=':')
    plt.title('Position in Y', fontsize=30)
    plt.xlabel('Index [int]', fontsize=30, labelpad=20)
    plt.ylabel('Y [mm]', fontsize=30, labelpad=20)
    plt.axis(aspect='equal')
    plt.legend(loc='best', prop={'size': 20})
    plt.tick_params(axis='both', which='major', labelsize=20)
    plt.tick_params(axis='both', which='minor', labelsize=15)
    plt.show()
    fig.canvas.draw()
    fig.canvas.flush_events()
    
    #-----------------------------------------------------------------------------------#
    
    fig = plt.figure(figsize=(20, 15))
    plt.plot(range(len(zdata)), zdata, c='g', marker='o', label='posZ')
    plt.grid(True,  ls=':')
    plt.title('Position in Z', fontsize=30)
    plt.xlabel('Index [int]', fontsize=30, labelpad=20)
    plt.ylabel('Z [mm]', fontsize=30, labelpad=20)
    plt.axis(aspect='equal')
    plt.legend(loc='best', prop={'size': 20})
    plt.tick_params(axis='both', which='major', labelsize=20)
    plt.tick_params(axis='both', which='minor', labelsize=15)
    plt.show()
    fig.canvas.draw()
    fig.canvas.flush_events()
    
    #-----------------------------------------------------------------------------------#
    
    fig = plt.figure(figsize=(20, 15))
    ax1 = plt.subplot(2, 1, 1)
    ax1.plot(range(len(Adata)), Adata, c='g', marker='o', label='A')
    plt.grid(True,  ls=':')
    ax1.set_title('Orientation in A [AER -> ZYZ\' conv]', fontsize=30)
    ax1.set_xlabel('Index [int]', fontsize=30, labelpad=20)
    ax1.set_ylabel('A [degrees]', fontsize=30, labelpad=20)
    plt.axis(aspect='equal')
    plt.legend(loc='best', prop={'size': 20})
    plt.tick_params(axis='both', which='major', labelsize=20)
    plt.tick_params(axis='both', which='minor', labelsize=15)
    
    ax2 = plt.subplot(2, 1, 2, projection='polar')
    ttl = ax2.set_title('Polar plot of A [AER -> ZYZ\' conv]', fontsize=30)
    ttl.set_position([.5, 1.15]) # to increase the space between the title and the plot
    plt.polar(Adata, range(len(Adata)), 'ro')
    plt.tick_params(axis='both', which='major', labelsize=20)
    plt.tick_params(axis='both', which='minor', labelsize=15)
    
    plt.subplots_adjust(hspace=0.6) # to increase the space between two subplots
    plt.show()
    fig.canvas.draw()
    fig.canvas.flush_events()
    
    #-----------------------------------------------------------------------------------#
    
    fig = plt.figure(figsize=(20, 15))
    ax1 = plt.subplot(2, 1, 1)
    ax1.plot(range(len(Edata)), Edata, c='g', marker='o', label='E')
    plt.grid(True,  ls=':')
    ax1.set_title('Orientation in E [AER -> ZYZ\' conv]', fontsize=30)
    ax1.set_xlabel('Index [int]', fontsize=30, labelpad=20)
    ax1.set_ylabel('E [degrees]', fontsize=30, labelpad=20)
    plt.axis(aspect='equal')
    plt.legend(loc='best', prop={'size': 20})
    plt.tick_params(axis='both', which='major', labelsize=20)
    plt.tick_params(axis='both', which='minor', labelsize=15)
    
    ax2 = plt.subplot(2, 1, 2, projection='polar')
    ttl = ax2.set_title('Polar plot of E [AER -> ZYZ\' conv]', fontsize=30)
    ttl.set_position([.5, 1.15]) # to increase the space between the title and the plot
    plt.polar(Edata, range(len(Edata)), 'ro')
    plt.tick_params(axis='both', which='major', labelsize=20)
    plt.tick_params(axis='both', which='minor', labelsize=15)
    
    plt.subplots_adjust(hspace=0.6) # to increase the space between two subplots
    plt.show()
    fig.canvas.draw()
    fig.canvas.flush_events()
    
    #-----------------------------------------------------------------------------------#
    
    fig = plt.figure(figsize=(20, 15))
    ax1 = plt.subplot(2, 1, 1)
    ax1.plot(range(len(Rdata)), Rdata, c='g', marker='o', label='R')
    plt.grid(True,  ls=':')
    ax1.set_title('Orientation in R [AER -> ZYZ\' conv]', fontsize=30)
    ax1.set_xlabel('Index [int]', fontsize=30, labelpad=20)
    ax1.set_ylabel('R [degrees]', fontsize=30, labelpad=20)
    plt.axis(aspect='equal')
    plt.legend(loc='best', prop={'size': 20})
    plt.tick_params(axis='both', which='major', labelsize=20)
    plt.tick_params(axis='both', which='minor', labelsize=15)
    
    ax2 = plt.subplot(2, 1, 2, projection='polar')
    ttl = ax2.set_title('Polar plot of R [AER -> ZYZ\' conv]', fontsize=30)
    ttl.set_position([.5, 1.15]) # to increase the space between the title and the plot
    plt.polar(Rdata, range(len(Rdata)), 'ro')
    plt.tick_params(axis='both', which='major', labelsize=20)
    plt.tick_params(axis='both', which='minor', labelsize=15)
    
    plt.subplots_adjust(hspace=0.6) # to increase the space between two subplots
    plt.show()    
    fig.canvas.draw()
    fig.canvas.flush_events()
    