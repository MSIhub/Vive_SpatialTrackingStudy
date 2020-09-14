#ifndef TCPSERVER_H_
#define TCPSERVER_H_

#pragma once

#undef UNICODE


#include <iostream>
#include <WS2tcpip.h>
#include <windows.h>
#include <iomanip>
#include <intrin.h>


#define WIN32_LEAN_AND_MEAN
#define DEFAULT_BUFLEN 4096
#define DEFAULT_PORT "54000"



struct data_packet
{
	uint64_t timestamp;
	double transform00;
	double transform01;
	double transform02;
	double transform03;

	double transform10;
	double transform11;
	double transform12;
	double transform13;

	double transform20;
	double transform21;
	double transform22;
	double transform23;
	int id; // HMD=1, CONT = 2, TRACK = 3

	// member initialisation list/constructur
	data_packet()
	{
		timestamp = 0;
		transform00 = 0.0;
		transform01 = 0.0;
		transform02 = 0.0;
		transform03 = 0.0;
		transform10 = 0.0;
		transform11 = 0.0;
		transform12 = 0.0;
		transform13 = 0.0;
		transform20 = 0.0;
		transform21 = 0.0;
		transform22 = 0.0;
		transform23 = 0.0;
		id = 0;
	}

	~data_packet() {}

};




// Server Socket
void tcpipServerSetupTest();
SOCKET startServerConn();
void endServerConn(SOCKET ClientSocket);
void sendDataServer(SOCKET ClientSocket, data_packet td);

#endif
