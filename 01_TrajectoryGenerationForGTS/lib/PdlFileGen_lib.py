# -*- coding: utf-8 -*-
"""
Created on Wed May 29 16:47:51 2019
Last edit: Fri Jan 03 11:32:22 2020

@author: Sadiq@msihub

Library with functions for task level programming for pdl2 COMAU.
Refer main_example.py for a use case.
More queries contact: mohamedsadiq.ikbal@edu.unige.it
"""

import numpy as np
import shutil, os

def write_file(fname, data):
    """
     PREREQUISITE:
         Data format in the main_example.py file must be followed to avoid errors as the code is not tested for any other formats

     INPUT:
         fname: Name of the program and the name of the Generating txt file.
         data: 6dof cartesian_positions path the robot has to follow

     OUTPUT/PURPOSE :
         Creates a txt file for the designed trajectory. File is created in the same working directory

     TO IMPROVE:
    """
    append_write = 'w'   # make a new file if not
    f = open(fname + ".txt", append_write)
    for i in data:
        f.write(",".join(repr(e) for e in i))  # Converting list to string and removing the brackets
        f.write("\n")
    f.close()


def load_traj_file(fname_traj):
    """
     PREREQUISITE:
         txt file must be created using "write_file" function in the same lib.

     INPUT:
         fname_traj: Name of the generated txt file to be loaded.

     OUTPUT/PURPOSE :
          Load the trajectory file created by "write_file" function.

     TO IMPROVE:
    """
    # Creating a list of lists from the text file
    data = []
    with open(fname_traj+ ".txt") as inputfile:
        for line in inputfile:
           data.append(line.rstrip().split(','))

    # Removing the parenthesis from the list
    for sub in data:
        sub[:] = map(float, (s.rsplit("(", 1)[0] for s in sub))
    return data


def gen_pdl_file(pname, data, lin_spd, rot_spd, mf_tigger_src, tool_frame_offset=[-50.900002, 50.900002, 75, 0, 0, 45]):
    """
    PREREQUISITE:
        1. trajectory must be created, writen to the file using "write_file" function and then loaded using load_traj_file function
         in this library to have in proper format to create the pdl file.
        2. Ensure right tool_frame_offset is set.
        3. Be aware of the speed because the safety for speed reduction is overriden.

    INPUT:
        pname: Name of the program and the name of the Generating pdl file. This is a rule of pdl, program name should be the same as the file name
        data: 6dof cartesian_positions path the robot has to follow
        lin_spd: Linear cartesian speed the robot has to follow
        rot_spd: Angular speed the robot has to follow
        mf_tigger_src: Motion feedback tiggering source.
                       Two options are possible: 1-> Directly to a file in the robot temp folder (TD:)
                                                 2-> Create a TCP IP socket server and send the data. In this case, client socket must be running to receive the data
    OUTPUT/PURPOSE :
        Creates a pdl file for the loaded trajectory for Comau NS 16-1.65 robot. File is created in the same working directory

    TO IMPROVE:
        1. Preload Tool frame offset for each devices.


    """

    # Input argument handling
    if not mf_tigger_src:
        mf_tigger_src = pname

    if not tool_frame_offset:
        tool_frame_offset = [-50.900002, 50.900002, 75, 0, 0, 45]

    f = open(pname + ".pdl", "w+")  # Open a file for writing and create it if id does not exist
    # Write lines of data to the file
    f.write("PROGRAM %s HOLD\r\n" % pname) # First line of the program
    f.write("  -------------------------------------------------------------------------------\n  -- Mohamed sadiq ikbal #msihub\n")
    f.write("  -- mohamedsadiq.ikbal@edu.unige.it\n")
    f.write("  -------------------------------------------------------------------------------\n  -- Brief:\n")
    f.write("  -- %s trajectory batch input file\n  -- Press Start button in teaching pendant to begin the execution\n" % pname)
    f.write("  -------------------------------------------------------------------------------\n\n")
    # Node type definition
    f.write("TYPE node_def = NODEDEF\n") # First line of the program
    f.write("\t\t$MAIN_POS\n")
    f.write("\tENDNODEDEF\r\n\n")

    # Varible declaration
    f.write("VAR\n")
    f.write("\tpth : PATH OF node_def \n")
    f.write("\ttrigger_on : BOOLEAN EXPORTED FROM %s\n" % mf_tigger_src) # for initiation of motion feedback
    f.write("\ttrigger_off : BOOLEAN EXPORTED FROM %s\n\n" % mf_tigger_src) # for initiation of motion feedback

    f.write("  -------------------------------------------------------------------------------  \n")
    f.write("  ------------------------------ MAIN FUNCTION ----------------------------------  \n")
    f.write("  -------------------------------------------------------------------------------  \n")

    # Program execution begin statement
    f.write("BEGIN\n")
    f.write("\tWRITE LUN_CRT (NL, '#######Motion program %s started...', NL)\n" % pname)
    f.write("\t$PROG_CNFG :=2\n") # TO override speed reduction by the controller
    f.write("\t$ARM_SPD_OVR :=100\n") # Setting max speed capability
    f.write("\t$ARM_ACC_OVR :=100\n") # Setting max acceleration capability
    f.write("\t$ARM_DEC_OVR :=100\n") # Setting max deceleration capability
    ################################  SET SPEED HERE   ##########################################################
    #f.write("\t$LIN_SPD_LIM := 2\n") # Setting linear speed maximum limit in m/s
    f.write("\t$LIN_SPD :=%.3f\n" %lin_spd) # Setting linear speed in m/s
    f.write("\t$ROT_SPD :=%.3f\n" %rot_spd) # Setting rotation speed in rad/s

    f.write("\t$TERM_TYPE := FINE\n")  # Type of termination of each segment of trajectory (Options: FINE, COARSE)

    ############################### SET FRAME REFERENCES HERE ###################################################
    f.write("\t$UFRAME := POS(0, 0, 0, 0, 0, 0, ' ')\n")
    f.write("\t$TOOL := POS(%f, %f, %f, %f, %f, %f, ' ')\n\n" % (tool_frame_offset[0], tool_frame_offset[1], tool_frame_offset[2], tool_frame_offset[3], tool_frame_offset[4], tool_frame_offset[5]) )  # setting user frame and tool frame

    ############################### MOVING TO STARTING POINT OF TRAJECTORY ######################################
    f.write("\n\tWRITE LUN_CRT (NL, '#######Moving to starting point...', NL)")
    f.write("\n\tMOVE TO POS(%s,' ')\n" % ",".join(repr(e) for e in data[0]))
    ############################### DATA IS SET TO NODE PATH ###################################################
    num_of_data = len(data)
    f.write("\n\tNODE_APP(pth,%d)\n" % num_of_data)  # Appending nodes to the path
    curr_lin = 1
    for i in data:
        f.write("\tpth.NODE[%d].$MAIN_POS :=" % curr_lin)
        f.write("POS(%s,' ')\n" % ",".join(repr(e) for e in i))
        curr_lin = curr_lin + 1

    f.write("\n\ttrigger_on:= TRUE\n")  # triggering the motion feedback thread
    f.write("\ttrigger_off:= FALSE\n")

    f.write("\n\tWRITE LUN_CRT (NL, '#######Starting trajectory...', NL)")
    f.write("\n\tMOVE ALONG pth WITH $MOVE_TYPE = LINEAR, $SPD_OPT = SPD_LIN \n") # Cmd to move along the trajectory

    f.write("\tCANCEL ALL\n") # cancel all motions before ending the program(reduntant safety)
    f.write("\tNODE_DEL(pth, 1, %d)\n\n" % num_of_data) # delete all the path node points freeing memory for next run
    f.write("\ttrigger_on:= FALSE\n")  # shutdown signal for the motion feedback thread
    f.write("\ttrigger_off:= TRUE\n")

    f.write("\tWRITE LUN_CRT (NL, '#######Motion program %s end...', NL)\n" %pname)

    f.write("\nEND %s" % pname) # End of the program
    # Close the file when done
    f.close()





def gen_pdl_file_StaticAnalysis(pname, data, lin_spd, rot_spd, mf_tigger_src, tool_frame_offset=[0,0,65.9, 0, 0, 0]):
    """
    """

    # Input argument handling
    if not mf_tigger_src:
        mf_tigger_src = pname

    if not tool_frame_offset:
        tool_frame_offset = [-50.900002, 50.900002, 75, 0, 0, 45]

    f = open(pname + ".pdl", "w+")  # Open a file for writing and create it if id does not exist
    # Write lines of data to the file
    f.write("PROGRAM %s HOLD\r\n" % pname) # First line of the program
    f.write("  -------------------------------------------------------------------------------\n  -- Mohamed sadiq ikbal #msihub\n")
    f.write("  -- mohamedsadiq.ikbal@edu.unige.it\n")
    f.write("  -------------------------------------------------------------------------------\n  -- Brief:\n")
    f.write("  -- %s Static Analysis trajectory generation\n  -- Press Start button in teaching pendant to begin the execution\n" % pname)
    f.write("  -------------------------------------------------------------------------------\n\n")

    # Varible declaration
    f.write("VAR\n")
    f.write("\ttrigger_on : BOOLEAN EXPORTED FROM %s\n" % mf_tigger_src) # for initiation of motion feedback
    f.write("\ttrigger_off : BOOLEAN EXPORTED FROM %s\n\n" % mf_tigger_src) # for initiation of motion feedback

    f.write("  -------------------------------------------------------------------------------  \n")
    f.write("  ------------------------------ MAIN FUNCTION ----------------------------------  \n")
    f.write("  -------------------------------------------------------------------------------  \n")

    # Program execution begin statement
    f.write("BEGIN\n")
    f.write("\tWRITE LUN_CRT (NL, '#######Motion program %s started...', NL)\n" % pname)
    f.write("\t$PROG_CNFG :=2\n") # TO override speed reduction by the controller
    f.write("\t$ARM_SPD_OVR :=100\n") # Setting max speed capability
    f.write("\t$ARM_ACC_OVR :=100\n") # Setting max acceleration capability
    f.write("\t$ARM_DEC_OVR :=100\n") # Setting max deceleration capability
    ################################  SET SPEED HERE   ##########################################################
    #f.write("\t$LIN_SPD_LIM := 2\n") # Setting linear speed maximum limit in m/s
    f.write("\t$LIN_SPD :=%.2f\n" %lin_spd) # Setting linear speed in m/s
    f.write("\t$ROT_SPD :=%.2f\n" %rot_spd) # Setting rotation speed in rad/s

    f.write("\t$TERM_TYPE := FINE\n")  # Type of termination of each segment of trajectory (Options: FINE, COARSE)

    ############################### SET FRAME REFERENCES HERE ###################################################
    f.write("\t$UFRAME := POS(0, 0, 0, 0, 0, 0, ' ')\n")
    f.write("\t$TOOL := POS(%f, %f, %f, %f, %f, %f, ' ')\n\n" % (tool_frame_offset[0], tool_frame_offset[1], tool_frame_offset[2], tool_frame_offset[3], tool_frame_offset[4], tool_frame_offset[5]) )  # setting user frame and tool frame

    ############################### MOVING TO STARTING POINT OF TRAJECTORY ######################################
    f.write("\n\tWRITE LUN_CRT (NL, '#######Moving to starting point...', NL)")
    f.write("\n\tMOVE TO POS(%s,' ')\n" % ",".join(repr(e) for e in data[0]))
    
    ############################### Starting motion feedback ###################################################
    
    f.write("\n\ttrigger_on:= TRUE\n")  # triggering the motion feedback thread
    f.write("\ttrigger_off:= FALSE\n")
    
    ################# DATA IS SET TO MOVE LINEAR FUNCTION WITH 10 SECONDS PAUSE ON EACH POINT ##################
    curr_lin = 1
    for i in data:
        f.write("\n\tWRITE LUN_CRT (NL, '## Moving to point %d', NL)" % curr_lin)
        f.write("\n\tMOVE TO POS(%s,' ') WITH $MOVE_TYPE = LINEAR, $SPD_OPT = SPD_LIN" % ",".join(repr(e) for e in i))
        f.write("\n\tDELAY 10000")
        curr_lin = curr_lin + 1
    
    ############################### Stopping motion feedback ###################################################
    
    f.write("\n\n\ttrigger_on:= FALSE\n")  # shutdown signal for the motion feedback thread
    f.write("\ttrigger_off:= TRUE\n")

    f.write("\tWRITE LUN_CRT (NL, '#######Motion program %s end...', NL)\n" %pname)

    f.write("\nEND %s" % pname) # End of the program
    # Close the file when done
    f.close()






def move_files_Net(pname):
    """
    move_files_Net:
    PREREQUISITE:
        1. pdl file of motion program must be created in the same directory of the script calling this function.
    (Best practice, use this function in the same script for creating the pdl file of motion program. Next line to gen_pdl_file func would be the ideal place)
        2. The lib folder must exists in "F:/ViveDynTrackTest/PythonWorkspace/lib/motion_feedback.pdl"
    INPUT:
        name of the motion program
    OUTPUT/PURPOSE:
        Creates a relative directory called "ToRobot" from the working directory if it does not exist. Then creates a folder in the name of the motion program if it exists, it will
    delete the previous folder and files in it and create a fresh one. Then it will move the two pdl files: motion program and the motion_feedback pdl to the created folder.
    TO IMPROVE:
        1. Instead of deleting the old folder, rename it with a iteration number. - for now its overkill.
    """
    directory = pname
    parent_dir = os.getcwd()
    # Delete the text file used for filling the pdl
    txtfilename = directory+".txt"
    if os.path.isfile(os.path.join(parent_dir,txtfilename)):
        os.remove(os.path.join(parent_dir,txtfilename))

    # Create if does not exist folder named "ToRobot"
    path_torobot = os.path.join(parent_dir, "ToRobot")
    if not os.path.exists(path_torobot):
        os.mkdir(path_torobot)
    # Delete the previous exisiting directory if exists and create a new directory named pname
    path_file = os.path.join(path_torobot, pname)
    if os.path.exists(path_file):
        for root, dirs, files in os.walk(path_file):
            for name in files:
                os.remove(os.path.join(root, name))
            for name in dirs:
                os.rmdir(os.path.join(root, name))
        os.rmdir(path_file)

    os.mkdir(path_file)

    # copy the files generated by gen_pdl_file to the new folder
    shutil.move(pname + ".pdl", path_file)

    # copy the motion_feedback.cod file to the new folder
    filepath_motionfeedbackpdl = "F:/OneDrive - unige.it/ViveStudy/4_Software/PythonWorkspace/lib/motion_feedback.pdl"
    filepath_mf = os.path.join(path_file, "motion_feedback.pdl")
    shutil.copyfile(filepath_motionfeedbackpdl, filepath_mf)

def get_equidistant_points(p1, p2, parts):  # Generating linearly spaced points between two poses
    """
    get_equidistant_points:
    PREREQUISITE:
        None
    INPUT:
        p1: Starting point 6dof
        p2: Ending point 6dof
        parts: Number of points -1 points between p1 and p2
    OUTPUT/PURPOSE:
        A list of lineraly spaced (parts-1) number of points between p1 and p2
    TO IMPROVE:
        1. Add more options for non-linear.
    """
    results = zip(np.linspace(p1[0], p2[0], parts+1), np.linspace(p1[1], p2[1], parts+1),\
               np.linspace(p1[2], p2[2], parts+1), np.linspace(p1[3], p2[3], parts+1),\
               np.linspace(p1[4], p2[4], parts+1), np.linspace(p1[5], p2[5], parts+1)) # zip() returns list of tuples
    return [list(elem) for elem in results]  # Converting list of tuples to list of lists




# , refer readme for more info
def gen_motion_feedback_file(pname, sampling_rate): # create NOHOLD pdl file for obtaining data from COMAU winC4G as a text file
    """
    PREREQUISITE:
        File generated through this function must accompany any motion program for COMAU.
        Make sure to run this program before pressing start in the teaching pendant of the robot.

    INPUT:
        pname: Name of the program and the name of the Generating pdl file. This is a rule of pdl, program name should be the same as the file name
        sampling_rate: Frequency in which the data must be collected

    OUTPUT/PURPOSE :
        Generates file for the motion feedback to a txt file without networking. File is in the TD directory of the robot. TD is temporary directory,
        make sure to save the data before switching of the robot otherwise the data will be lost.
        # The generated pdl file will be named with motionprogramname_mf.pdl. Copy that file to the robot manually and activate it.
        # Upon activation and when the motion program starts the trajectory, this file will send the data to the text file until the motion program stops.

    TO IMPROVE:
        1. Integrate the motion files for networking and text in same function.


    """
    sampling_time  = int(round((1/sampling_rate) * 1000)) # Hz to milliseconds
    mfname = pname + "_mf"
    tname = mfname + "_data.txt"
    mf1 = open(tname, "w+" ) # Open a text file for writing motion feedback data
    mf1.close()
    mf2 = open(mfname + ".pdl", "w+" ) # Open a file for writing the program for getting the motion feedback
    # Write program into pdl file
    mf2.write("PROGRAM %s NOHOLD, PROG_ARM=1\r\n" % mfname) # First line of the program
    mf2.write("  -------------------------------------------------------------------------------\n  -- Mohamed sadiq ikbal #msihub\n")
    mf2.write("  -- mohamedsadiq.ikbal@edu.unige.it\n")
    mf2.write("  -------------------------------------------------------------------------------\n  -- Brief:\n")
    mf2.write("  -- %s trajectory motion feedback extraction program from COMAU\n" % pname)
    mf2.write("  -------------------------------------------------------------------------------\n\n")
    # Variable declaration
    mf2.write("VAR\n")
    mf2.write("\t lun_mf : INTEGER\n")
    mf2.write("\t cartesian_positions : ARRAY[6] OF REAL\n")
    mf2.write("\t cpos : POSITION\n")
    mf2.write("\t str : STRING[33]\n")
    mf2.write("\t trigger_on : BOOLEAN EXPORTED FROM %s\n" % pname)
    mf2.write("\t trigger_off : BOOLEAN EXPORTED FROM %s\n" % pname)
    mf2.write("\t timestamp : INTEGER\n")
    mf2.write("\t clk : INTEGER\n\n")
    # Main function
    mf2.write("BEGIN\n")
    mf2.write("\t WRITE LUN_CRT (NL, 'Motion feedback for %s initiated', NL)\n" % pname)
    mf2.write("\t trigger_off:= TRUE\n")
    mf2.write("\t trigger_on:= FALSE\n")
    mf2.write("\t $TIMER[1]:=0\n\n")
    mf2.write("\t OPEN FILE lun_mf ('TD:%s', 'rw')\n" % tname)
    mf2.write("\t WAIT FOR trigger_on=TRUE\n")
    mf2.write("\t WRITE LUN_CRT (NL, 'Data collection for %s in process', NL)\n" % pname)
    mf2.write("\t REPEAT\n")
    mf2.write("\t\t timestamp:=$TIMER[1]\n")
    mf2.write("\t\t clk :=CLOCK\n")
    mf2.write("\t\t cpos := ARM_POS\n")
    mf2.write("\t\t POS_XTRT(cpos, cartesian_positions[1], cartesian_positions[2], cartesian_positions[3], cartesian_positions[4], cartesian_positions[5], cartesian_positions[6], str)\n")
    mf2.write("\t\t WRITE lun_mf (clk, timestamp, cartesian_positions[1], cartesian_positions[2], cartesian_positions[3], cartesian_positions[4], cartesian_positions[5], cartesian_positions[6], NL)\n")
    mf2.write("\t\t DELAY %d\n" % sampling_time)
    mf2.write("\t UNTIL trigger_off\n")
    mf2.write("\t WRITE LUN_CRT (NL, 'Data collection for %s completed', NL)\n\n" % pname)
    mf2.write("\t DELAY 1000\n")
    mf2.write("\t CLOSE FILE lun_mf\n\n")
    mf2.write("\t WRITE LUN_CRT('Motion feedback program %s terminated', NL)\n" %pname)
    mf2.write(" END %s" % mfname)
    mf2.close()


def move_files_reqforrobot(pname):
    """
    move_files_reqforrobot:
    PREREQUISITE:
        1. pdl file of motion program must be created in the same directory of the script calling this function.
    (Best practice, use this function in the same script for creating the pdl file of motion program. Next line to gen_pdl_file func would be the ideal place)
        2. gen_motion_feedback_file should be run to have the _mf file
    INPUT:
        name of the motion program
    OUTPUT/PURPOSE:
        Creates a relative directory in the name of the motion program if it exists, it will throw error. Then it will move the two pdl files: motion program and the _mf.pdl
        to the created folder and the raw trajectory input data txt file to the folder.
    TO IMPROVE:
        1. Add functionality to delete or iterate the name of the folder if it exists.
    """
    directory = pname
    #parent_dir = "F:/ViveDynTrackTest/PythonWorkspace/Phase3/ToRobot"
    parent_dir = os.getcwd()
    path = os.path.join(parent_dir, directory)
    try:
        os.mkdir(path)
        file1 = pname + "_mf_data.txt"
        file2 = pname + "_mf.pdl"
        file3 = pname + ".pdl"
        files = [file1, file2, file3]
        for f in files:
            shutil.move(f, path)

    except OSError as error:
        print(error)

## Function to create the pdl file to move the starting pose of the trajectory
def createStartPDL(pname, tool_frame_offset, start_pose):
    fstart = open(pname + ".pdl", "w+")  # Open a file for writing and create it if id does not exist
    fstart.write("PROGRAM %s HOLD\r\n" % pname) # First line of the program
    fstart.write("BEGIN\n")
    fstart.write("\t$UFRAME := POS(0, 0, 0, 0, 0, 0, ' ')\n")
    fstart.write("\t$TOOL := POS(%f, %f, %f, %f, %f, %f, ' ')\n\n" % (tool_frame_offset[0], tool_frame_offset[1], tool_frame_offset[2], tool_frame_offset[3], tool_frame_offset[4], tool_frame_offset[5]) )  # setting user frame and tool frame
    fstart.write(start_pose)
    fstart.write("\nEND %s" % pname) # End of the program
    # Close the file when done
    fstart.close()
    


# Prompting meaningful error if run standalone
if __name__ == "__main__":
    print("You are executing a library file, kindly write a python script to utilise this function...")



    """
    if not per_of_spd:
        per_of_spd = 10

    # Speed variable validation
    if per_of_spd > 100 or per_of_spd < 1:
        per_of_spd = 10
        print("Invalid percentage of speed value, default value of 10% have been set. Modify the code line 88 to set the required percentage of speed")
        """
