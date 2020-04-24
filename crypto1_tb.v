/*  crypto1_tb.v
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

`define clk 1

module crypto1_tb;
    
    reg sysclk;
    reg resetn;
    
    reg start;
    
    reg load_key;
    reg load_rng;
    reg data_in;
    reg fb;
    
    reg [47:0] key;
    wire trx_ks;
    wire trx_fout;
    
    reg [31:0] data32;
    reg [31:0] out32;
    integer i;
    
    m1crypto crypto(
        .sysclk(sysclk),
        .resetn(resetn),
        
        .key(key),
        .load_key(load_key),
        
        .ser_in(data_in),
        .start(start),
        .fb(fb),

        .trx_ks(trx_ks),
        .trx_fout(trx_fout)
    );
    
    initial begin
        sysclk = 0;
        resetn = 0;
        start = 0;
        load_key = 0;
        load_rng = 0;
        data_in = 0;
        fb = 1;
        
    #10;
        resetn = 1'b0;
    #`clk;
        resetn = 1'b1;
    
    #1;    
    
    // Check the result for key = 000000000000
    #`clk;
        key = 48'h000000000000;
        load_key = 1'b1;
    
    #`clk;
        load_key = 1'b0;
    
    begin
        data32 = 32'hABCD1234;
        out32 = 0;
        
        for(i=0; i<32; i++) begin
        #`clk;
            data_in = data32[i];
            start = 1;
        #`clk;
            start = 0; 
            out32 |= trx_ks << i;
        end
        $display("out:%x", out32);
        
        if(out32 != 32'h2443c620) begin
            $error("mifare result is incorrect");
            $stop;
        end
    end

    begin
        data32 = 32'hABCD1234; 
        out32 = 0;
        
        for(i=0; i<32; i++) begin
        #`clk;
            data_in = data32[i];
            start = 1;
        #`clk;
        start = 0; 
        out32 |= trx_ks << i;
            
        end
        $display("out:%x", out32);
        
        if(out32 != 32'ha32901a6) begin
            $error("mifare result is incorrect");
            $stop;
        end
    end    
    
    //-----------------------------------------------------
    
    // Check the result for key = 12345678ABCD
    #`clk;
        key = 48'h12345678ABCD;
        load_key = 1'b1;
    
    #`clk;
        load_key = 1'b0;
    
    begin
        data32 = 32'hABCD1234; 
        out32 = 0;
        
        for(i=0; i<32; i++) begin
        #`clk;
            data_in = data32[i];
            start = 1;
        #`clk;
            start = 0; 
            out32 |= trx_ks << i;
        end
        $display("out:%x", out32);
        
        if(out32 != 32'h29bd350e) begin
            $error("mifare result is incorrect");
            $stop;
        end
    end
    
    begin
        data32 = 32'hABCD1234; 
        out32 = 0;
        
        for(i=0; i<32; i++) begin
        #`clk;
            data_in = data32[i];
            start = 1;
        #`clk;
        start = 0; 
        out32 |= trx_ks << i;
        
        end
        $display("out:%x", out32);
        
        if(out32 != 32'hbc9cf7f9) begin
            $error("mifare result is incorrect");
            $stop;
        end
    end    
    
    #10;
        $finish;
    end
    
    
    always begin
    #1 sysclk = ~sysclk;
    end
endmodule
