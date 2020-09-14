#ifndef MAIN_H_
#define MAIN_H_

#pragma once
#include <iostream>
#include <fstream>
#include <string>
#include <WS2tcpip.h>
#include <iomanip> 
#include <intrin.h>
#include <exception> 
#include <chrono>
#include <Windows.h>
#include <stdio.h>
#include <cstdint>
#include <thread>

#pragma comment(lib, "ws2_32.lib")

#define DEFAULT_BUFLEN 4096
#define FLOAT_PRECISION 8
#define DELIMITER ","

#define IP_COMAU "172.22.121.2" // ipAddress of Comau to listen to
#define PORT_COMAU 98765 // Port to listen
#define IP_VIVE
#define PORT_Vive 

struct data_packet_vive
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
	int id;

	// member initialisation list/constructur
	data_packet_vive()
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

	~data_packet_vive() {}

};

struct data_packet_comau 
{
	int timestamp;
	float cp1;
	float cp2;
	float cp3;
	float cp4;
	float cp5;
	float cp6;
	float vel;

	// member init
	data_packet_comau()
	{
		timestamp = 0;
		cp1 = 0.0;
		cp2 = 0.0;
		cp3 = 0.0;
		cp4 = 0.0;
		cp5 = 0.0;
		cp6 = 0.0;
		vel = 0.0;
	}

	~data_packet_comau() {}
};


uint64_t GetCurrentTimeNs();
void tcpClient_Comau();
void tcpClient_Vive();
bool isDataValid(data_packet_vive dd);
bool isDataValidComau(data_packet_comau dd);

#endif // !MAIN_H_