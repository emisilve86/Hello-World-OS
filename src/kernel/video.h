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


#ifndef __VIDEO_H__
#define __VIDEO_H__


#define	VGA_TXT_ADDR		0xb8000	/* VGA text mode memory address */

#define	VGA_TXT_ROWS		25		/* number of rows in VGA test mode */
#define	VGA_TXT_COLS		80		/* number of columns in VGA test mode */

#define	WHITE_ON_BLACK		0x0f	/* font byte */

#define	VGA_CTRL_REG		0x03d4	/* VGA control register */
#define	VGA_DATA_REG		0x03d5	/* VGA data register */

#define	VGA_CUR_OFF_LOW		15		/* low byte of the cursor's offset */
#define	VGA_CUR_OFF_HIGH	14		/* high byte of the cursor's offset */


void	print_char(unsigned char);
void	print_string(unsigned char *);
void	init_video(void);


#endif