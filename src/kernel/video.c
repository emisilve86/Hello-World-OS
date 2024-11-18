/*****************************************************************************
 * Copyright  2024  Emisilve86                                               *
 *                                                                           *
 * This file is part of HelloWorldOS.                                        *
 *                                                                           *
 * HelloWorldOS is free software: you can redistribute it and/or modify      *
 * it under the terms of the GNU General Public License as published by      *
 * the Free Software Foundation, either version 3 of the License, or         *
 * (at your option) any later version.                                       *
 *                                                                           *
 * HelloWorldOS is distributed in the hope that it will be useful,           *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 * GNU General Public License for more details.                              *
 *                                                                           *
 * You should have received a copy of the GNU General Public License         *
 * along with Nome-Programma.  If not, see <http://www.gnu.org/licenses/>.   *
 *****************************************************************************/


#include "video.h"
#include "io_port.h"


static inline __attribute__((always_inline))
unsigned short __get_offset_from_row_col(unsigned short row, unsigned short col)
{
	if (row >= VGA_TXT_ROWS)
		row = VGA_TXT_ROWS - 1;

	if (col >= VGA_TXT_COLS)
		col = VGA_TXT_COLS - 1;

	return (((row * VGA_TXT_COLS) + col) * 2);
}

static inline __attribute__((always_inline))
unsigned short __get_row_from_offset(unsigned short off)
{
	if (off >= (VGA_TXT_ROWS * VGA_TXT_COLS * 2))
		return VGA_TXT_ROWS - 1;

	return (off / (VGA_TXT_COLS * 2));
}

static inline __attribute__((always_inline))
unsigned short __get_col_from_offset(unsigned short off)
{
	if (off >= (VGA_TXT_ROWS * VGA_TXT_COLS * 2))
		return VGA_TXT_COLS - 1;

	return (off % (VGA_TXT_COLS * 2)) / 2;
}

static unsigned short __get_cursor()
{
	unsigned short off;

	__io_port_1_byte_out(VGA_CTRL_REG, VGA_CUR_OFF_HIGH);
	off = ((unsigned short) __io_port_1_byte_in(VGA_DATA_REG)) << 8;

	__io_port_1_byte_out(VGA_CTRL_REG, VGA_CUR_OFF_LOW);
	off += (unsigned short) __io_port_1_byte_in(VGA_DATA_REG);

	return off * 2;
}

static void __set_cursor(unsigned short off)
{
	off /= 2;

	__io_port_1_byte_out(VGA_CTRL_REG, VGA_CUR_OFF_HIGH);
	__io_port_1_byte_out(VGA_DATA_REG, (unsigned char) (off >> 8));

	__io_port_1_byte_out(VGA_CTRL_REG, VGA_CUR_OFF_LOW);
	__io_port_1_byte_out(VGA_DATA_REG, (unsigned char) (off & 0xff));
}

static void __scroll_down()
{
	unsigned short row;
	unsigned short col;
	unsigned short off;
	unsigned char *mem = (unsigned char *) VGA_TXT_ADDR;

	for (row = 0; row < (VGA_TXT_ROWS - 1); row++)
		for (col = 0; col < VGA_TXT_COLS; col++)
			*((unsigned short *)&mem[__get_offset_from_row_col(row, col)]) = *((unsigned short *)&mem[__get_offset_from_row_col(row + 1, col)]);

	for (col = 0; col < VGA_TXT_COLS; col++)
		*((unsigned short *)&mem[__get_offset_from_row_col(VGA_TXT_ROWS - 1, col)]) = (((unsigned short) ' ') << 8) | ((unsigned short) WHITE_ON_BLACK);
}

static unsigned short __new_line_offset(unsigned short off)
{
	unsigned short row;

	if ((row = __get_row_from_offset(off)) < (VGA_TXT_ROWS - 1))
		return __get_offset_from_row_col(row + 1, 0);

	__scroll_down();

	return __get_offset_from_row_col(row, 0);
}


void print_char(unsigned char chr)
{
	unsigned short off;
	unsigned char *mem = (unsigned char *) VGA_TXT_ADDR;

	if ((off = __get_cursor()) >= (VGA_TXT_ROWS * VGA_TXT_COLS * 2))
		return;

	if (chr == '\n')
		off = __new_line_offset(off);
	else
	{
		mem[off++] = chr;
		mem[off++] = WHITE_ON_BLACK;
	}

	__set_cursor(off);
}

void print_string(unsigned char *str)
{
	unsigned short i;
	unsigned short off;
	unsigned char *mem = (unsigned char *) VGA_TXT_ADDR;

	if (str == 0x00)
		return;

	off = __get_cursor();

	for (i = 0; ; i++)
	{
		if (str[i] == '\0')
			break;

		if (off >= (VGA_TXT_ROWS * VGA_TXT_COLS * 2))
			break;

		if (str[i] == '\n')
			off = __new_line_offset(off);
		else
		{
			mem[off++] = str[i];
			mem[off++] = WHITE_ON_BLACK;
		}
	}

	__set_cursor(off);
}

void init_video()
{
	__set_cursor(0);

	print_string("        __  __     ____\n");
	print_string("       / / / /__  / / /___\n");
	print_string("      / /_/ / _ \\/ / / __ \\\n");
	print_string("     / __  /  __/ / / /_/ /\n");
	print_string("    /_/ /_/\\___/_/_/\\____( )\n");
	print_string("     _       __          |/_    ____\n");
	print_string("    | |     / /___  _____/ /___/ / /\n");
	print_string("    | | /| / / __ \\/ ___/ / __  / /\n");
	print_string("    | |/ |/ / /_/ / /  / / /_/ /_/\n");
	print_string("    |__/|__/\\____/_/  /_/\\__,_(_)\n");

	print_char('\n');
	print_char('>');
}