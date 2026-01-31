#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/timerfd.h>
#include <sys/select.h>

uint64_t millis = 0;
uint64_t next_send_time = 0;

int millis_timerfd = -1;
int rxfd = STDIN_FILENO;
int txfd = STDOUT_FILENO;
FILE *forth_file = NULL;

void timer_init(void)
{
	struct timespec now;
	struct itimerspec new_value;
	if (clock_gettime(CLOCK_REALTIME, &now) < 0) {
		perror("clock_gettime");
		exit(EXIT_FAILURE);
	}
	new_value.it_value.tv_sec = now.tv_sec;
	new_value.it_value.tv_nsec = now.tv_nsec;
	new_value.it_interval.tv_sec = 0;
	new_value.it_interval.tv_nsec = 1000000;
	millis_timerfd = timerfd_create(CLOCK_REALTIME, 0);
	if (millis_timerfd < 0) {
		perror("millis timerfd_create");
		exit(EXIT_FAILURE);
	}
	if (timerfd_settime(millis_timerfd, TFD_TIMER_ABSTIME, &new_value,
			    NULL) < 0) {
		perror("millis timerfd_settime");
		exit(EXIT_FAILURE);
	}
}

void millis_timerfd_read(void)
{
	int ret;
	uint64_t expir;
	ret = read(millis_timerfd, &expir, sizeof(expir));
	if (ret < 0) {
		perror("millis timerfd read");
		exit(EXIT_FAILURE);
	}
	millis += expir;
}

void rxfd_read(void)
{
	int ret;
	uint8_t buf[BUFSIZ];
	ret = read(rxfd, buf, sizeof(buf));
	if (ret < 0) {
		perror("rxfd read");
		exit(EXIT_FAILURE);
	}
	int i;
	for (i = 0; i < ret; i++) {
		fputc(buf[i], stderr);
		if (buf[i] == 0x06) {
			// ack
			next_send_time = millis + 1;
		}
	}
}

const uint8_t delim_lut[] = {
	0x0A, 0x0D, 0x20,
};
bool isdelim(char c)
{
	unsigned int i;
	for (i = 0; i < sizeof(delim_lut); i++) {
		if (delim_lut[i] == c) {
			return true;
		}
	}
	return false;
}

int fread_word(FILE *fp, uint8_t *buf, int maxlen)
{
	int c;
	int i;
	for (i = 0; i < maxlen; i++) {
		c = fgetc(fp);
		if (c == EOF) {
			break;
		}
		buf[i] = c;
		if (isdelim(buf[i])) {
			//fprintf(stderr, ".");
			//fflush(stderr);
			i += 1;
			break;
		}
	}
	return i;
}

void file_send(void)
{
	if (feof(forth_file)) {
		exit(EXIT_SUCCESS);
	}
	if (next_send_time == 0) {
		next_send_time = millis;
	}
	if (millis < next_send_time) {
		return;
	}
	uint8_t buf[64];
	int len;
	len = fread_word(forth_file, buf, sizeof(buf) - 1);
	int idx = 0;
	int ret;
	while (idx < len) {
		ret = write(txfd, &buf[idx], len - idx);
		if (ret < 0) {
			perror("write");
			exit(EXIT_FAILURE);
		}
		idx += ret;
	}
	next_send_time =
		millis +
		20; // for fast link or slow forth, you may need change this value
	
}

void main_loop(void)
{
	int ret;
	fd_set rfds;
	while (1) {
		file_send();
		FD_ZERO(&rfds);
		FD_SET(rxfd, &rfds);
		FD_SET(millis_timerfd, &rfds);
		ret = select(64, &rfds, NULL, NULL, NULL);
		if (ret < 0) {
			perror("select");
			exit(EXIT_FAILURE);
		}
		if (ret == 0) {
			continue;
		}
		if (FD_ISSET(millis_timerfd, &rfds)) {
			millis_timerfd_read();
		}
		if (FD_ISSET(rxfd, &rfds)) {
			rxfd_read();
		}
	}
}

int main(int argc, char *argv[])
{
	if (argc < 2) {
		fprintf(stderr, "USAGE: %s FILE\r\n", argv[0]);
		exit(EXIT_FAILURE);
	}
	timer_init();
	forth_file = fopen(argv[1], "r");
	if (forth_file == NULL) {
		perror("forth file fopen");
		exit(EXIT_FAILURE);
	}
	
	main_loop();
	return 0;
}
