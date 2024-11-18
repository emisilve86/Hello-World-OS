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


#ifndef __IO_PORT_H__
#define __IO_PORT_H__


static inline __attribute__((always_inline))
unsigned char __io_port_1_byte_in(unsigned short port)
{
	unsigned char result;

	asm volatile (
		"inb %%dx, %%al" :
		"=a" (result) :
		"d" (port)
	);

	return result;
}

static inline __attribute__((always_inline))
void __io_port_1_byte_out(unsigned short port, unsigned char data)
{
	asm volatile (
		"outb %%al, %%dx" :
		:
		"a" (data), "d" (port)
	);
}


#endif