#include "main.h"


int main()
{
	std::thread ClientComau(tcpClient_Comau);
	std::thread ClientVive(tcpClient_Vive);
	ClientVive.join();
	ClientComau.join();
	//std::cout << "Started thread id=" << std::this_thread::get_id() << std::endl;
}


uint64_t GetCurrentTimeNs()
{
	uint64_t now = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
	return now;
}


void tcpClient_Comau()
{
	std::cout << "Started Comau client : thread id=" << std::this_thread::get_id() << std::endl;
	// openFiles_Comau() inserted here to have one function one thread 
	/* Part 1: Open file to store data***************************/
	/*      a. Creates "dataLogV1" dir relative to the working directory if does not exist */
	/*      b. Creates "comau" dir relative to the dataLogV1 directory if does not exist */
	/*      c. Creates  a txt file with name "rawComauData_(timestamp in ns).txt" -- timestamp in ns ensures a unique time*/
	std::ofstream file_comau;
	std::string str_comau;
	uint64_t ct;
	std::string str_logdirname = "dataLog";
	//std::string str_logsubdir = "comau";


	CreateDirectoryA((str_logdirname.c_str()), NULL); // will create a dir and return zero if issue
	//CreateDirectoryA(std::string(str_logdirname + "/" + str_logsubdir).c_str(), NULL);

	ct = GetCurrentTimeNs();
	std::string str_time = std::to_string(ct);
	std::string str_filetype = ".txt";

	std::string str_filename = "rawComauData_";

	//str_comau = std::string(str_logdirname + "/" + str_logsubdir + "/" + str_filename + str_time + str_filetype);
	str_comau = std::string(str_logdirname + "/" + str_filename + str_time + str_filetype);

	file_comau.open(str_comau, std::fstream::app);

	if (!file_comau.is_open())
	{
		printf("Comau data storage file not open\n");
	}


	/* Part 2: TCP/IP COMAU CONNECTION AND DATA STREAM*************************************************************/
	/*      a. Creates a client socket with the mentioned port and ipAddress*/
	std::string ipAddress = IP_COMAU; // IP Address of the COMAU robot
	int port = PORT_COMAU; // Listening port number on the server -- if changed other than 12345, make sure to change at the comau end
	char buf[DEFAULT_BUFLEN];

	// Initialize Winsock
	WSAData data;
	WORD ver = MAKEWORD(2, 2);
	int wsResult = WSAStartup(ver, &data);

	if (wsResult != 0)
	{
		std::cerr << "Can't start winsock, Err num " << wsResult << std::endl;
		return;
	}

	// Create socket
	SOCKET sock = socket(AF_INET, SOCK_STREAM, 0);

	if (sock == INVALID_SOCKET)
	{
		std::cerr << "Can't create socket, Err #" << WSAGetLastError() << std::endl;
		return;
	}

	// Fill in  a hint structure
	sockaddr_in hint;
	hint.sin_family = AF_INET;
	hint.sin_port = htons(port);
	inet_pton(AF_INET, ipAddress.c_str(), &hint.sin_addr);

	// Connect to server
	int connResult = connect(sock, (sockaddr*)&hint, sizeof(hint));

	if (connResult == SOCKET_ERROR)
	{
		std::cerr << "Can't connect to server ERR #" << WSAGetLastError() << std::endl;
		closesocket(sock);
		WSACleanup();
		return;
	}
	std::cout << "@msihub: Comau data collection is in progress....\n		#To stop data collection \n			->Either kill the terminal \n			->Or stop the motion_feedack.cod in teaching Pendant of the robot" << std::endl;
	while (true)
	{
		ZeroMemory(buf, DEFAULT_BUFLEN);

		// Wait for client to send data
		int bytesReceived = recv(sock, buf, DEFAULT_BUFLEN, 0);

		if (bytesReceived == SOCKET_ERROR)
		{
			std::cerr << "Error in recv(). Quitting" << std::endl;
			break;
		}

		if (bytesReceived == 0)
		{
			std::cout << "Client disconnected " << std::endl;
			break;
		}

		try
		{
			uint64_t currtime = GetCurrentTimeNs();

			data_packet_comau dd;

			memcpy(&dd, &buf, sizeof(dd));

			if (isDataValidComau(dd))
			{
				file_comau << std::fixed << std::setprecision(FLOAT_PRECISION) << currtime << DELIMITER << dd.timestamp << DELIMITER << dd.cp1 << DELIMITER << dd.cp2 << DELIMITER << dd.cp3
					<< DELIMITER << dd.cp4 << DELIMITER << dd.cp5 << DELIMITER << dd.cp6 << DELIMITER << dd.vel << std::endl;
			}
			

			ZeroMemory(&dd, sizeof(dd));

		}
		catch (const std::exception&)
		{
			std::cerr << "null ptr error" << std::endl;
			return;
		}
	}

	// Gracefully close down everything
	closesocket(sock);
	WSACleanup();
	std::cout << "Socket closed." << std::endl << std::endl;

}

void tcpClient_Vive()
{
	std::cout << "Started vive client: thread id=" << std::this_thread::get_id() << std::endl;

	std::ofstream file_hmd;
	std::ofstream file_controller3;
	std::ofstream file_controller4;
	std::ofstream file_tracker5;
	std::ofstream file_tracker6;

	std::string str_hmd;
	std::string str_controller3;
	std::string str_controller4;
	std::string str_tracker5;
	std::string str_tracker6;
	uint64_t ct;
	std::string str_logdirname = "dataLog";
	//std::string str_logsubdir_hmd = "hmd";
	//std::string str_logsubdir_controller = "controller";
	//std::string str_logsubdir_tracker = "tracker";

	// Creates necessary folders for data storage, if folders exists does nothing
	CreateDirectoryA((str_logdirname.c_str()), NULL); // will create a dir and return zero if issue
	//CreateDirectoryA(std::string(str_logdirname + "/" + str_logsubdir_hmd).c_str(), NULL);
	//CreateDirectoryA(std::string(str_logdirname + "/" + str_logsubdir_controller).c_str(), NULL);
	//CreateDirectoryA(std::string(str_logdirname + "/" + str_logsubdir_tracker).c_str(), NULL);

	ct = GetCurrentTimeNs();
	std::string str_time = std::to_string(ct);
	std::string str_filetype = ".txt";

	std::string str_filename_hmd = "rawViveDataHMD_";
	std::string str_filename_controller3 = "rawViveDataController3_";
	std::string str_filename_controller4 = "rawViveDataController4_";
	std::string str_filename_tracker5 = "rawViveDataTracker5_";
	std::string str_filename_tracker6 = "rawViveDataTracker6_";

	//str_hmd = std::string(str_logdirname + "/" + str_logsubdir_hmd + "/" + str_filename_hmd + str_time + str_filetype);
	//str_controller3 = std::string(str_logdirname + "/" + str_logsubdir_controller + "/" + str_filename_controller3 + str_time + str_filetype);
	//str_controller4 = std::string(str_logdirname + "/" + str_logsubdir_controller + "/" + str_filename_controller4 + str_time + str_filetype);
	//str_tracker5 = std::string(str_logdirname + "/" + str_logsubdir_tracker + "/" + str_filename_tracker5 + str_time + str_filetype);
	//str_tracker6 = std::string(str_logdirname + "/" + str_logsubdir_tracker + "/" + str_filename_tracker6 + str_time + str_filetype);

	str_hmd = std::string(str_logdirname + "/" + str_filename_hmd + str_time + str_filetype);
	str_controller3 = std::string(str_logdirname + "/" + str_filename_controller3 + str_time + str_filetype);
	str_controller4 = std::string(str_logdirname + "/" + str_filename_controller4 + str_time + str_filetype);
	str_tracker5 = std::string(str_logdirname + "/" + str_filename_tracker5 + str_time + str_filetype);
	str_tracker6 = std::string(str_logdirname + "/" + str_filename_tracker6 + str_time + str_filetype);

	file_hmd.open(str_hmd, std::fstream::app);
	file_controller3.open(str_controller3, std::fstream::app);
	file_controller4.open(str_controller4, std::fstream::app);
	file_tracker5.open(str_tracker5, std::fstream::app);
	file_tracker6.open(str_tracker6, std::fstream::app);

	if (!file_hmd.is_open())
	{
		printf("HMD File not open\n");
	}

	if (!file_controller3.is_open())
	{
		printf("Controller 3 File not open\n");
	}

	if (!file_controller4.is_open())
	{
		printf("Controller 4 File not open\n");
	}

	if (!file_tracker5.is_open())
	{
		printf("Tracker File not open\n");
	}

	if (!file_tracker6.is_open())
	{
		printf("Tracker File not open\n");
	}


	//********************TCP/IP VIVE CONNECTION AND DATA STREAM*************************************************************/
	//*_______________________________________________________________________________________________________________________*/

	std::string ipAddress = "127.0.0.1"; // IP Address of the LOCAL host
	int port = 54000; // Listening port number on the server

	// Initialize Winsock
	WSAData data;
	WORD ver = MAKEWORD(2, 2);
	int wsResult = WSAStartup(ver, &data);

	if (wsResult != 0)
	{
		std::cerr << "Can't start winsock, Err num " << wsResult << std::endl;
		return;
	}

	// Create socket
	SOCKET sock = socket(AF_INET, SOCK_STREAM, 0);

	if (sock == INVALID_SOCKET)
	{
		std::cerr << "Can't create socket, Err #" << WSAGetLastError() << std::endl;
		return;
	}

	// Fill in  a hint structure
	sockaddr_in hint;
	hint.sin_family = AF_INET;
	hint.sin_port = htons(port);
	inet_pton(AF_INET, ipAddress.c_str(), &hint.sin_addr);

	// Connect to server
	int connResult = connect(sock, (sockaddr*)&hint, sizeof(hint));

	if (connResult == SOCKET_ERROR)
	{
		std::cerr << "Can't connect to server ERR #" << WSAGetLastError() << std::endl;
		closesocket(sock);
		WSACleanup();
		return;
	}

	char buf[4096];
	while (true)
	{
		ZeroMemory(buf, 4096);

		// Wait for client to send data
		int bytesReceived = recv(sock, buf, 4096, 0);
		//std::cout << buf << std::endl;

		if (bytesReceived == SOCKET_ERROR)
		{
			std::cerr << "Error in recv(). Quitting" << std::endl;
			break;
		}

		if (bytesReceived == 0)
		{
			std::cout << "Client disconnected " << std::endl;
			break;
		}

		// decoding
		try
		{
			uint64_t currtime;

			currtime = GetCurrentTimeNs();

			
			data_packet_vive dd = *reinterpret_cast<data_packet_vive*>(&buf);
			// 0 HMD | 1, 2 BS | 3, 4 Controller | 5> Trackers
			if (isDataValid(dd))
			{
				if (dd.id == 0)
				{
					file_hmd << std::fixed << std::setprecision(FLOAT_PRECISION) << dd.id << DELIMITER << currtime << DELIMITER << dd.timestamp << DELIMITER << dd.transform00 << DELIMITER << dd.transform01 << DELIMITER << dd.transform02 << DELIMITER << dd.transform03 << DELIMITER <<
						dd.transform10 << DELIMITER << dd.transform11 << DELIMITER << dd.transform12 << DELIMITER << dd.transform13 << DELIMITER <<
						dd.transform20 << DELIMITER << dd.transform21 << DELIMITER << dd.transform22 << DELIMITER << dd.transform23 << "\n";
				}
				else if (dd.id == 3)
				{
					file_controller3 << std::fixed << std::setprecision(FLOAT_PRECISION) << dd.id << DELIMITER << currtime << DELIMITER << dd.timestamp << DELIMITER << dd.transform00 << DELIMITER << dd.transform01 << DELIMITER << dd.transform02 << DELIMITER << dd.transform03 << DELIMITER <<
						dd.transform10 << DELIMITER << dd.transform11 << DELIMITER << dd.transform12 << DELIMITER << dd.transform13 << DELIMITER <<
						dd.transform20 << DELIMITER << dd.transform21 << DELIMITER << dd.transform22 << DELIMITER << dd.transform23 << "\n";
				}
				else if (dd.id == 4)
				{
					file_controller4 << std::fixed << std::setprecision(FLOAT_PRECISION) << dd.id << DELIMITER << currtime << DELIMITER << dd.timestamp << DELIMITER << dd.transform00 << DELIMITER << dd.transform01 << DELIMITER << dd.transform02 << DELIMITER << dd.transform03 << DELIMITER <<
						dd.transform10 << DELIMITER << dd.transform11 << DELIMITER << dd.transform12 << DELIMITER << dd.transform13 << DELIMITER <<
						dd.transform20 << DELIMITER << dd.transform21 << DELIMITER << dd.transform22 << DELIMITER << dd.transform23 << "\n";
				}
				else if (dd.id == 5)
				{
					file_tracker5 << std::fixed << std::setprecision(FLOAT_PRECISION) << dd.id << DELIMITER << currtime << DELIMITER << dd.timestamp << DELIMITER << dd.transform00 << DELIMITER << dd.transform01 << DELIMITER << dd.transform02 << DELIMITER << dd.transform03 << DELIMITER <<
						dd.transform10 << DELIMITER << dd.transform11 << DELIMITER << dd.transform12 << DELIMITER << dd.transform13 << DELIMITER <<
						dd.transform20 << DELIMITER << dd.transform21 << DELIMITER << dd.transform22 << DELIMITER << dd.transform23 << "\n";
				}
				else if (dd.id == 6)
				{
					file_tracker6 << std::fixed << std::setprecision(FLOAT_PRECISION) << dd.id << DELIMITER << currtime << DELIMITER << dd.timestamp << DELIMITER << dd.transform00 << DELIMITER << dd.transform01 << DELIMITER << dd.transform02 << DELIMITER << dd.transform03 << DELIMITER <<
						dd.transform10 << DELIMITER << dd.transform11 << DELIMITER << dd.transform12 << DELIMITER << dd.transform13 << DELIMITER <<
						dd.transform20 << DELIMITER << dd.transform21 << DELIMITER << dd.transform22 << DELIMITER << dd.transform23 << "\n";
				}
			}


			ZeroMemory(&dd, sizeof(dd));
		}
		catch (const std::exception&)
		{
			std::cerr << "null ptr error" << std::endl;
			return;
		}
	//std::this_thread::sleep_for(std::chrono::milliseconds(1));
	}

	// Gracefully close down everything
	closesocket(sock);
	WSACleanup();
	std::cout << "Socket closed." << std::endl << std::endl;

	// closing the files
	file_hmd << std::endl;
	file_controller3 << std::endl;
	file_controller4 << std::endl;
	file_tracker5 << std::endl;
	file_tracker6 << std::endl;
	// close the stream to the output file
	file_hmd.close();
	file_controller3.close();
	file_controller4.close();
	file_tracker5.close();
	file_tracker6.close();
	printf("\nFiles closed without any interrupt\n");
}


bool isDataValid(data_packet_vive dd)
{
	unsigned int trans_threshold = 5; // assuming the maximum value is 5 meters and the elements of rotation matrix are not more than 1
	unsigned int rot_threshold = 1; // the value range of the elements of the rotation matrix is [-1 to +1]
	if (abs(dd.transform03) > trans_threshold || abs(dd.transform13) > trans_threshold || abs(dd.transform23) > trans_threshold)
	{
		return 0;
	}
	else if (abs(dd.transform00) > rot_threshold || abs(dd.transform01) > rot_threshold || abs(dd.transform02) > rot_threshold || abs(dd.transform10) > rot_threshold || abs(dd.transform11) > rot_threshold || abs(dd.transform12) > rot_threshold || abs(dd.transform20) > rot_threshold || abs(dd.transform21) > rot_threshold || abs(dd.transform22) > rot_threshold)
	{
		return 0;
	}
	else if (isnan(dd.transform00) || isnan(dd.transform01) || isnan(dd.transform02) || isnan(dd.transform03) || isnan(dd.transform10) || isnan(dd.transform11) || isnan(dd.transform12) || isnan(dd.transform13) || isnan(dd.transform20) || isnan(dd.transform21) || isnan(dd.transform22) || isnan(dd.transform23))
	{
		return 0;
	}
	// Checking for identity matrix 
	else if (abs(dd.transform03) == 0 && abs(dd.transform13) == 0 && abs(dd.transform23) == 0)
	{
		return 0;
	}
	else if (abs(dd.transform00) == 1 && abs(dd.transform01) == 0 && abs(dd.transform02) == 0 && abs(dd.transform10) == 0 && abs(dd.transform11) == 1 && abs(dd.transform12) == 0 && abs(dd.transform20) == 0 && abs(dd.transform21) == 0 && abs(dd.transform22) == 1)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

bool isDataValidComau(data_packet_comau dd)
{
	int threshold = 5000; // mm - maximum linear motion is 5 m
	// There is continous rotation motion, more than 360 degree thus no rot limit is evaluated;
	if(abs(dd.cp1) > threshold || abs(dd.cp2) > threshold || abs(dd.cp3) > threshold)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}