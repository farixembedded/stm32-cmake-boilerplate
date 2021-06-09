/*
 * Copyright (c) 2021, Fractal Embedded LLC
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* Sane stubs for newlib portable syscalls are provided below.
 */
#include <sys/stat.h>

// called when the CRT (c run time) exits the main function or exit is called
// we should never get here, so trap and loop forever
void _exit(int status) {
	while (1)
		;
}

// there is no process management in our system so this is a noop
void _kill(int pid, int dig) {}

// get the PID of the current process. We don't have process managemnt so just return 1
int _getpid() {
	return 1;
}

// request an increase in the size of the heap. We don't do any dynamic allocations so this just
// returns failure.
void* _sbrk(int bytes) {
	return (void*)0;
}

// write to a file descriptor. We do nothing now, return 0 bytes written.
int _write(int file, char* ptr, int len) {
	return 0;
}

// close a file descriptor. We don't support this, return failure.
int _close(int file) {
	return -1;
}

// seek in a file descriptor. We don't support this so return 0 (start of file)
int _lseek(int file, int ptr, int dir) {
	return 0;
}

// read from a file descriptor. We don't support this so return 0 bytes read.
int _read(int file, char* ptr, int len) {
	return 0;
}

// get stats for a file descriptior. Return everything as a char file.
int _fstat(int file, struct stat* st) {
	st->st_mode = S_IFCHR;
	return 0;
}

// Are we attached to a tty? Why not, sure.
int _isatty(int file) {
	return 1;
}
