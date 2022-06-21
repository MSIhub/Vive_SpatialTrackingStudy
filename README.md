# Vive_SpatialTrackingStudy
This repository contains the source code for the architecture of the system developed to study the spatial tracking performance of HTC Vive lighthouse tracking system under dynamic conditions using a Comau NS16. This repository includes the C++ source code of the data collection API, the Python path to PDL parser script, and the MATLAB scripts developed for post-processing, transformation, generation of the performance metrics, and also for the registration algorithm tested.

![Refer SystemArchitecture.jpg for code organizational structure and flow](https://github.com/MSIhub/Vive_SpatialTrackingStudy/blob/master/SystemArchitecture.jpg)

The architecture of the experimental setup to evaluate the VLTS is elucidated in Fig. SystemArchitecture.jpg. It describes the integration of two systems (COMAU NS 16 and VLTS) in four primary blocks. The requirement of this system is to provide pose and time data feedback synchronized in the same reference frame with a time latency of less than 22 ms.

1) The role of the first block is to prepare our ground truth system C16 to perform the required motion. The trajectories are designed as per the design of experiments. With the use of the Universal Robot Description Format (URDF) file, the generated trajectory was simulated in MATLAB to ensure the trajectories are within the workspace. After verification, our Python PDL Parser generates the path file and send it to the C16.

2) The second block is the server setup for VLTS and C16. The custom application built with OpenVR SDK (C++) and WinC4G API (PDL-Comau custom scripting) acts as a server of a TCP/IP network to stream the data of VLTS and C16 respectively.

3) The third block highlights the data collection software developed. The data collection API receives both the data stream in parallel, inserts the time data for synchronization, and logs it in a ".txt" file.

4) The final block features the data post-processing. This process is done offline after the experimentation to reduce computation time and thereby latency while collecting the data. The stored data from both C16 and VLTS are synchronized and re-sampled at 100 Hz. Then the relative transformation and pose error are calcullated. Finally, the performance metrics are evaluated.
