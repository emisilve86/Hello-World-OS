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


.type gdt_start, @object
gdt_start:						/* address to where the GDT starts */

gdt_null:						/* mandatory NULL descriptor */
	.zero	0x08

gdt_code:						/* CODE segment descriptor */
	.short	0xffff				/* segment limit */
	.short	0x0000				/* segment base (0-15) */
	.byte	0x00				/* segment base (16-23) */
	.byte	0x9a				/* 1st flags, 10011010 */
	.byte	0xcf				/* 2nd flags, 11001111 */
	.byte	0x00				/* segment base (24-31) */

gdt_data:						/* DATA segment descriptor */
	.short	0xffff				/* segment limit */
	.short	0x0000				/* segment base (0-15) */
	.byte	0x00				/* segment base (16-23) */
	.byte	0x92				/* 1st flags, 10010010 */
	.byte	0xcf				/* 2nd flags, 11001111 */
	.byte	0x00				/* segment base (24-31) */

.type gdt_end, @object
gdt_end:						/* address to where the GDT ends */

gdt_descriptor:					/* size and address of the GDT */
	.short	gdt_end - gdt_start - 1
	.long	gdt_start

.equ	SEG_CODE,	gdt_code - gdt_start
.equ	SEG_DATA,	gdt_data - gdt_start
