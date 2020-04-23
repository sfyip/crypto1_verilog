/*  crypto1.v
    ***For educational use only***
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
    MA  02110-1301, US

    Copyright (C) 2018-2020 sfyip <yipxxx@gmail.com>
*/

module m1filter( 
	input [19:0] in,
	output wire out
);

wire [15:0] fan = 16'h9e98;
wire [15:0] fbn = 16'hb48e;
wire [31:0] fcn = 32'hec57e80a;

wire bit4 = fan >> in[19:16];
wire bit3 = fbn >> in[15:12];
wire bit2 = fan >> in[11:8];
wire bit1 = fan >> in[7:4];
wire bit0 = fbn >> in[3:0];

wire [4:0] sel = {bit4, bit3, bit2, bit1, bit0};

assign out = fcn >> sel;

endmodule

//-------------------------------------------------------

module m1crypto(
	input sysclk,
	input resetn,
	
	input [47:0] key,
	input load_key,
	
	input ser_in,
	input start,

	output reg tx
);

reg [47:0] lfsr;

wire  linear_feedback =	lfsr[0] ^ lfsr[5] ^ lfsr[9] ^ lfsr[10] ^ lfsr[12] ^
						lfsr[14] ^ lfsr[15] ^ lfsr[17] ^ lfsr[19] ^ lfsr[24] ^
						lfsr[25] ^ lfsr[27] ^ lfsr[29] ^ lfsr[35] ^ lfsr[39] ^
						lfsr[41] ^ lfsr[42] ^ lfsr[43];
 
always@(posedge sysclk or negedge resetn)
	if(~resetn) begin
		lfsr <= 0;
		tx <= 1'b0;
	end else begin
		if (start) begin
			lfsr <= { linear_feedback ^ ser_in ^ ks, lfsr[47:1]}; 
			tx <= ks;
		end	
		
		if(load_key) begin
			lfsr <= {key[7:0], key[15:8], key[23:16], key[31:24],key[39:32], key[47:40]};
		end
	end

	
wire [19:0] filter_in = {
							lfsr[47], lfsr[45], lfsr[43], lfsr[41],
							lfsr[39], lfsr[37], lfsr[35], lfsr[33],
							lfsr[31], lfsr[29], lfsr[27], lfsr[25],
							lfsr[23], lfsr[21], lfsr[19], lfsr[17],
							lfsr[15], lfsr[13], lfsr[11], lfsr[9]
						};	
						
m1filter filter0 (
	.in(filter_in),	
	.out(ks)
);
endmodule
