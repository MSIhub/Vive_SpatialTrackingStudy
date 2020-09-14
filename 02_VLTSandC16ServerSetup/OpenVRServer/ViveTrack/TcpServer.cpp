#include "TcpServer.h"

//############################ SOCKET PROGRAMMING FUNCTIONS ###############################################//
/*#########################################################################################################*/

// Function to test the server setup by sending a sample data_packet
void tcpipServerSetupTest() {
	// encoding
	data_packet td;

	td.timestamp = 0;

	td.transform00 = 0;
	td.transform01 = -0.1;
	td.transform02 = 0.2;
	td.transform03 = 0.3;

	td.transform10 = 1;
	td.transform11 = -1.1;
	td.transform12 = 1.2;
	td.transform13 = -1.3;

	td.transform20 = -2;
	td.transform21 = 2.1;
	td.transform22 = 2.2;
	td.transform23 = -2.3;

	SOCKET ClientSocket = startServerConn(); // start server at default port mentioned in header
	sendDataServer(ClientSocket, td); // send data td to the client socket and wait for default delay milliseconds
	endServerConn(ClientSocket); // close the server connection

}


// function to create a TCP/IP socket server for the given DEFAULT_PORT
SOCKET startServerConn()
{
	WSADATA wsaData;
	int iResult;

	SOCKET ListenSocket = INVALID_SOCKET;
	SOCKET ClientSocket = INVALID_SOCKET;

	struct addrinfo* result = NULL;
	struct addrinfo hints;


	// Initialize Winsock
	iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
	if (iResult != 0) {
		printf("WSAStartup failed with error: %d\n", iResult);
	}

	ZeroMemory(&hints, sizeof(hints));
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_protocol = IPPROTO_TCP;
	hints.ai_flags = AI_PASSIVE;

	// Resolve the server address and port
	iResult = getaddrinfo(NULL, DEFAULT_PORT, &hints, &result);
	if (iResult != 0) {
		printf("getaddrinfo failed with error: %d\n", iResult);
		WSACleanup();
	}

	// Create a SOCKET for connecting to server
	ListenSocket = socket(result->ai_family, result->ai_socktype, result->ai_protocol);
	if (ListenSocket == INVALID_SOCKET) {
		printf("socket creation failed with error: %d\n", WSAGetLastError());
		freeaddrinfo(result);
		WSACleanup();
	}

	// Setup the TCP listening socket
	iResult = bind(ListenSocket, result->ai_addr, (int)result->ai_addrlen);
	if (iResult == SOCKET_ERROR) {
		printf("bind failed with error: %d\n", WSAGetLastError());
		freeaddrinfo(result);
		closesocket(ListenSocket);
		WSACleanup();
	}

	freeaddrinfo(result);

	iResult = listen(ListenSocket, SOMAXCONN);
	if (iResult == SOCKET_ERROR) {
		printf("listen failed with error: %d\n", WSAGetLastError());
		closesocket(ListenSocket);
		WSACleanup();
	}

	// Accept a client socket
	ClientSocket = accept(ListenSocket, NULL, NULL);
	if (ClientSocket == INVALID_SOCKET) {
		printf("accept failed with error: %d\n", WSAGetLastError());
		closesocket(ListenSocket);
		WSACleanup();
	}

	// No longer need server socket
	closesocket(ListenSocket);
	return ClientSocket;
}


// shutdown the connection since we're done
void endServerConn(SOCKET ClientSocket)
{
	int iResult;
	iResult = shutdown(ClientSocket, SD_SEND);
	if (iResult == SOCKET_ERROR) {
		printf("shutdown failed with error: %d\n", WSAGetLastError());
		closesocket(ClientSocket);
		WSACleanup();
	}

	// cleanup
	closesocket(ClientSocket);
	WSACleanup();
	printf("Server socket closed.");
}

void sendDataServer(SOCKET ClientSocket, data_packet td)
{
	int iSendResult;
	char recvbuf[DEFAULT_BUFLEN];
	int recvbuflen = DEFAULT_BUFLEN;


	// serialization
	unsigned char* recvbufptr = reinterpret_cast<unsigned char*>(&td); //without unsigned 0.0 and some values like 0.1 or 1.1 will not be casted
	if (recvbufptr != nullptr)
	{
		try {
			memcpy(recvbuf, recvbufptr, DEFAULT_BUFLEN);
			// reseting the pointer
			ZeroMemory(&recvbufptr, sizeof(recvbufptr));
		}
		catch (std::exception & e)
		{
			std::cerr << "casting issue at encoding with exception " << e.what() << "\n" << std::endl;
		}
	}
	// Echo the buffer back to the sender

	iSendResult = send(ClientSocket, recvbuf, recvbuflen, 0);
	if (iSendResult == SOCKET_ERROR)
	{
		printf("Send failed with error: %d\n", WSAGetLastError());
		closesocket(ClientSocket);
		WSACleanup();
		return;
	}
	//printf("Bytes sent: %d\n", iSendResult);
}
