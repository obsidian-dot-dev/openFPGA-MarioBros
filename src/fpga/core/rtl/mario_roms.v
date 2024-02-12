//----------------------------------------------------------------------------
// Mario Bros Arcade
//
// Author: gaz68 (https://github.com/gaz68) June 2020
//
// ROM Modules
//----------------------------------------------------------------------------
//
// ROM / sample addresses:
//
// 0x00000 - 0x01FFF 7F PROGRAM ROM (8KB)
// 0x02000 - 0x03FFF 7E PROGRAM ROM (8KB)
// 0x04000 - 0x05FFF 7D PROGRAM ROM (8KB)
// 0x06000 - 0x06FFF 3F GFX ROM (4KB)
// 0x07000 - 0x07FFF 3J GFX ROM (4KB)
// 0x08000 - 0x08FFF 7C PROGRAM ROM (4KB)
// 0x09000 - 0x09FFF 7M GFX ROM (4KB) 
// 0x0A000 - 0x0AFFF 7N GFX ROM (4KB) 
// 0x0B000 - 0x0BFFF 7P GFX ROM (4KB) 
// 0x0C000 - 0x0CFFF 7S GFX ROM (4KB) 
// 0x0D000 - 0x0DFFF 7T GFX ROM (4KB) 
// 0x0E000 - 0x0EFFF 7U GFX ROM (4KB) 
// 0x0F000 - 0x0FFFF 6K SOUND ROM (4KB)
// 0x10000 - 0x101FF 4P PROM (512B) 512x8 CLUT PROM
// 0x10200 - 0x1021F 5P PROM (32B) 32x8 Address Decoder PROM
// 0x10220 - 0x10FFF EMPTY (3552B))
// 0x11000 - 0x11FFF Skid sound sample (4KB)
// 0x12000 - 0x12FFF Mario Run sound sample (4KB)
// 0x13000 - 0x13FFF Luigi Run sound sample (4KB)


module DLROM #(parameter AW,parameter DW)
(
   input                  CLK0,
   input        [(AW-1):0]AD0,
   output reg   [(DW-1):0]DO0,

   input                  CLK1,
   input        [(AW-1):0]AD1,
   input        [(DW-1):0]DI1,
   input                  WE1
);

reg [DW-1:0] core[0:((2**AW)-1)];

always @(posedge CLK0) DO0 <= core[AD0];
always @(posedge CLK1) if (WE1) core[AD1] <= DI1;

endmodule


module DLROMB #(parameter AW,parameter DW)
(
   input                  CLK0,
   input        [(AW-1):0]AD0,
   output reg   [(DW-1):0]DO0,

   input                  CLK1,
   input        [(AW-1):0]AD1,
   input        [(DW-1):0]DI1,
   input                  WE1
);

dpram #(AW, DW) dprom
(
   .clock_a(CLK1),
   .wren_a(WE1),
   .address_a(AD1),
   .data_a(DI1),

   .clock_b(CLK0),
   .address_b(AD0),
   .q_b(DO0)
);

endmodule

//--------------------------------
// Main CPU ROMS 7F,7E,7D and 7C.
//--------------------------------

module MAIN_ROM
(
   input         I_CLK,
   input   [15:0]I_ADDR,
   input    [3:0]I_CE,
   input         I_OE,
   output   [7:0]O_DATA,

   input         I_DLCLK,
   input   [16:0]I_DLADDR,
   input    [7:0]I_DLDATA,
   input         I_DLWR
);

wire  [7:0] dt7f, dt7e, dt7d, dt7c;

DLROM #(13,8) mrom7f(I_CLK, I_ADDR[12:0], dt7f,
                     I_DLCLK, I_DLADDR[12:0], I_DLDATA,
                     I_DLWR & (I_DLADDR[16:13]==4'b0_000));

DLROM #(13,8) mrom7e(I_CLK, I_ADDR[12:0], dt7e,
                     I_DLCLK, I_DLADDR[12:0], I_DLDATA,
                     I_DLWR & (I_DLADDR[16:13]==4'b0_001));

DLROM #(13,8) mrom7d(I_CLK, I_ADDR[12:0], dt7d,
                     I_DLCLK, I_DLADDR[12:0], I_DLDATA, 
                     I_DLWR & (I_DLADDR[16:13]==4'b0_010));

DLROM #(12,8) mrom7c(I_CLK, I_ADDR[11:0], dt7c,
                     I_DLCLK, I_DLADDR[11:0], I_DLDATA,
                     I_DLWR & (I_DLADDR[16:12]==5'b0_1000));

assign O_DATA = (I_CE[0] == 1'b0 & I_OE == 1'b0) ? dt7f :
                (I_CE[1] == 1'b0 & I_OE == 1'b0) ? dt7e :
                (I_CE[2] == 1'b0 & I_OE == 1'b0) ? dt7d :
                (I_CE[3] == 1'b0 & I_OE == 1'b0) ? dt7c :
                8'h00;

endmodule

//----------------=----------------------
// Object/Sprite ROMs 7M,7N,7P,7S,7T,7U.
// OEn and CEn tied to ground.
// 48-bit output.
//---------------------------------------

module OBJ_ROM
(
   input          I_CLK,
   input    [11:0]I_ADDR,
   output   [47:0]O_DATA,

   input          I_DLCLK,
   input    [16:0]I_DLADDR,
   input     [7:0]I_DLDATA,
   input          I_DLWR
);

wire [7:0] dt7m, dt7n, dt7p, dt7s, dt7t, dt7u;

DLROM #(12,8) objrom7m(I_CLK, I_ADDR, dt7m,
                       I_DLCLK, I_DLADDR[11:0], I_DLDATA,
                       I_DLWR & (I_DLADDR[16:12]==5'b0_1001));

DLROM #(12,8) objrom7n(I_CLK, I_ADDR, dt7n,
                       I_DLCLK, I_DLADDR[11:0], I_DLDATA,
                       I_DLWR & (I_DLADDR[16:12]==5'b0_1010));

DLROM #(12,8) objrom7p(I_CLK, I_ADDR, dt7p,
                       I_DLCLK, I_DLADDR[11:0], I_DLDATA,
                       I_DLWR & (I_DLADDR[16:12]==5'b0_1011));

DLROM #(12,8) objrom7s(I_CLK, I_ADDR, dt7s,
                       I_DLCLK, I_DLADDR[11:0], I_DLDATA,
                       I_DLWR & (I_DLADDR[16:12]==5'b0_1100));

DLROM #(12,8) objrom7t(I_CLK, I_ADDR, dt7t,
                       I_DLCLK, I_DLADDR[11:0], I_DLDATA,
                       I_DLWR & (I_DLADDR[16:12]==5'b0_1101));

DLROM #(12,8) objrom7u(I_CLK, I_ADDR, dt7u,
                       I_DLCLK, I_DLADDR[11:0], I_DLDATA,
                       I_DLWR & (I_DLADDR[16:12]==5'b0_1110));

assign O_DATA = {dt7m,dt7n,dt7p,dt7s,dt7t,dt7u};

endmodule

//------------------------------------------
// Background character tiles ROM's 3F, 3J. 
// OEn and CEn tied to ground.
// 16-bit output.
//------------------------------------------

module VID_ROM
(
   input         I_CLK,
   input   [11:0]I_ADDR,
   input         I_CE,
   output  [15:0]O_DATA,

   input         I_DLCLK,
   input	  [16:0]I_DLADDR,
   input    [7:0]I_DLDATA,
   input         I_DLWR
);

wire [7:0] dt3f, dt3j;

DLROM #(12,8) vidrom3f(I_CLK, I_ADDR, dt3f,
                       I_DLCLK, I_DLADDR[11:0], I_DLDATA,
                       I_DLWR & (I_DLADDR[16:12]==5'b0_0110));

DLROM #(12,8) vidrom3j(I_CLK, I_ADDR, dt3j,
                       I_DLCLK, I_DLADDR[11:0], I_DLDATA,
                       I_DLWR & (I_DLADDR[16:12]==5'b0_0111));

assign O_DATA = {dt3f,dt3j};

endmodule

//-----------------------------------
// CLUT PROM 4P (512x8)
// Only 256 entries are used.
// 8-bit output.
//-----------------------------------

module CLUT_PROM_512_8
(
   input          I_CLK,
   input     [8:0]I_ADDR,
   output    [7:0]O_DATA,

   input          I_DLCLK,
   input    [16:0]I_DLADDR,
   input     [7:0]I_DLDATA,
   input          I_DLWR
);

wire [7:0] dt;

DLROM #(9,8) prom4p(I_CLK, I_ADDR, dt,
                    I_DLCLK, I_DLADDR[8:0], I_DLDATA,
                    I_DLWR & (I_DLADDR[16:9]==8'b1_0000_000));

assign O_DATA = dt;

endmodule

//-----------------------------------
// Address decoder PROM 5B (32x8)
//-----------------------------------

module ADEC_PROM
(
   input          I_CLK,
   input     [4:0]I_ADDR, //A15,A14,A13,A12,A11
   output    [7:0]O_DATA,

   input          I_DLCLK,
   input    [16:0]I_DLADDR,
   input     [7:0]I_DLDATA,
   input          I_DLWR
);

wire [7:0] dt;

DLROM #(5,8) prom5b(I_CLK, I_ADDR, dt,
                    I_DLCLK, I_DLADDR[4:0], I_DLDATA,
                    I_DLWR & (I_DLADDR[16:5]==12'b1_0000_0010_000));

assign O_DATA = dt;

endmodule

//----------------------------------
// Sub CPU (Sound) External ROM 5K.
//----------------------------------

module SUB_EXT_ROM
(
   input          I_CLK,
   input    [11:0]I_ADDR,
   input          I_CE,
   input          I_OE,
   output    [7:0]O_DATA,

   input          I_DLCLK,
   input    [16:0]I_DLADDR,
   input     [7:0]I_DLDATA,
   input          I_DLWR
);

wire [7:0] dt;

DLROM #(12,8) srom5k(I_CLK, I_ADDR, dt,
                     I_DLCLK, I_DLADDR[11:0], I_DLDATA,
                     I_DLWR & (I_DLADDR[16:12]==5'b0_1111));

assign O_DATA = (I_CE == 1'b0 & I_OE == 1'b0) ? 
                (I_ADDR == 12'h001 ? 8'h01 : dt) // 8039 hack
                : 8'h00;

endmodule

//--------------------------------------------------------------------------------
// Sub CPU (Sound) Internal ROM (2KB). *** NOT USED YET. Using 8039 hack.
//
// The M58715 sound CPU used by Mario Bros has an internal 2KB ROM.
// This only appears to be used for protection purposes.
// The external sound ROM contains all of the code required to create the sounds.
// With the boot ROM in place a call is eventually made to $101(mb0) which starts
// the CPU's inbuilt timer. Without the boot ROM in place, a call is made 
// to $100(mb0) and the 'strt t' instruction is missed resulting in no sound.
// The solution below was taken from MAME. It is not known if the internal
// ROM has been dumped.
//--------------------------------------------------------------------------------

module SUB_INT_ROM
(
   input              CLK,
   input        [10:0]AD,
   output reg    [7:0]DO
);

always @(posedge CLK) begin

   case(AD)
      11'h000 : DO <= 8'hF5; // 0000 F5      sel mb1
      11'h001 : DO <= 8'h04; // 0001 04 00   jmp $000
      default : DO <= 8'h00; 
   endcase

end

endmodule

//--------------------------------------------------
// Wave ROM
// 22KHz, 16-bit signed samples for analogue sounds
// Covers the 3 analogue sounds:
// Mario run, Luigi run and skidding sounds.
//--------------------------------------------------

module WAV_ROM
(
   input          I_CLK,
   input    [12:0]I_ADDR,
   output   [15:0]O_DATA,

   input          I_DLCLK,
   input    [16:0]I_DLADDR,
   input     [7:0]I_DLDATA,
   input          I_DLWR
);

// Write 8-bit download stream to wave ROM as 16-bit words.
reg   [15:0]WAV_ADDR = 0;
reg    [7:0]DA_L = 0;
reg   [15:0]DA16 = 0;

always @(posedge I_DLCLK) begin

   if (I_DLADDR[16] == 1'b1 && I_DLADDR[15:12] != 4'b0000) begin
      if (I_DLADDR[0] == 1'b0) begin
         DA_L <= I_DLDATA;
      end else begin	
         DA16 <= {I_DLDATA, DA_L};
         WAV_ADDR <= I_DLADDR[16:1] - 16'h08800;
      end
   end
end

dpram #(13, 16) wav_rom
(
   .clock_a(I_DLCLK),
   .wren_a(I_DLWR),
   .address_a(WAV_ADDR[12:0]),
   .data_a(DA16),

   .clock_b(I_CLK),
   .address_b(I_ADDR),
   .q_b(O_DATA)
);

endmodule

