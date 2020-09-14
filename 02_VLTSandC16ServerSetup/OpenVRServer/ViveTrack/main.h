#pragma once

#undef UNICODE

#define WIN32_LEAN_AND_MEAN
#define FLOAT_PRECISION 8
#define DEFAULT_DELAYSECS 8 // 120Hz sampling , time in milliseconds

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include "LighthouseTracking.h"
#include "cpTime.h"
#include <cstring>
#include <strings.h>
#include <chrono>
#include <inttypes.h>
#include <unistd.h>
#include <csignal>
#include <exception>
#include <string>

void openFiles();
uint64_t GetCurrentTimeNs();
void signalHandler( int signum);
