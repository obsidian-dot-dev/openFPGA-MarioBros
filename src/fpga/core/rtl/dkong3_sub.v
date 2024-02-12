
module dkong3_sub
(
   //input        I_CLK_24M,
   input        I_CLK_12M,
   input        I_SUBCLKx2,
   input        I_SUB_RESETn,
   input        I_SUB_NMIn,
   input   [7:0]I_SUB_DBI,
   input        I_CPU_CE,
   input        I_ODD_OR_EVEN,

   //input  [16:0]I_DLADDR,
   //input   [7:0]I_DLDATA,
   //input        I_DLWR,
   
   output [15:0]O_SUB_ADDR,
   output  [7:0]O_SUB_DB0,
   output       O_SUB_RNW,
   //output       O_SUB_INP0n,
   //output       O_SUB_INP1n,
   output [15:0]O_SAMPLE
);


//-----
// CPU
//-----

wire [7:0] from_data_bus;
wire [7:0] cpu_dout;

wire [15:0] cpu_addr;
wire cpu_rnw;
//wire pause_cpu;
wire nmi;
wire mapper_irq;
wire apu_irq;

T65 cpu(
   .mode   (0), //
   .BCD_en (0), //

   .res_n  (I_SUB_RESETn), //
   .clk    (I_SUBCLKx2),
   .enable (I_CPU_CE),
   //.rdy    (~pause_cpu),
   .rdy    (1'b1),

   .IRQ_n  (~apu_irq),
   .NMI_n  (I_SUB_NMIn), //
   .R_W_n  (cpu_rnw),

   .A      (cpu_addr),
   .DI     (cpu_rnw ? W_CPU_DBUS : cpu_dout),
   .DO     (cpu_dout)
);

assign O_SUB_ADDR = cpu_addr;
assign O_SUB_DB0  = cpu_dout;
assign O_SUB_RNW  = cpu_rnw;

// CPU Data Bus (Data In)
//wire   [7:0]W_CPU_DBUS = I_SUB_DBI | APU_DO; // I SUB_DI

//-----
// ROM
//-----

//wire  [7:0]W_SUB1ROM_DO;
//wire       W_SUBROM_OEn = (cpu_addr[15] == 1'b0);

//SUB1_ROM sub1rom(I_CLK_12M, cpu_addr[12:0], ~I_CPU_CE, W_SUBROM_OEn, W_SUB1ROM_DO, 
//                 I_CLK_24M, I_DLADDR, I_DLDATA, I_DLWR);


//-----
// RAM
//-----

//wire       W_SUBRAM_OEn = (cpu_addr[15:14] == 3'b00);

//reg   [7:0]SUB1RAM_DO;
//wire  [7:0]W_RAM1_DO;

//ram_2048_8 U_5K
//(
//   .I_CLK(I_CLK_12M),
//   .I_ADDR(cpu_addr[10:0]),
//   .I_D(cpu_dout),
//   .I_CE(~I_CPU_CE),
//   .I_WE(~cpu_rnw & (cpu_addr[15:14] == 2'b0)),
//   .O_D(W_RAM1_DO)
//);

wire   [7:0]W_CPU_DBUS = (cpu_addr == 16'h4015 & mr_int) ? apu_dout : I_SUB_DBI;

//always@(posedge I_CLK_12M)
//begin
//   SUB1RAM_DO <= (cpu_addr[15:14] == 2'b0 & I_CPU_CE == 1'b1 & cpu_rnw == 1'b1) ? W_RAM1_DO : 0;
//   APU_DO     <= (inport_cs == 1'b1) ? I_SUB_DI : (apu_cs == 1'b1) ? apu_dout : 0;
//end


//-----
// APU
//-----

wire apu_cs = cpu_addr >= 'h4000 && cpu_addr < 'h4018;
//wire apu_cs2 = cpu_addr >= 'h4000 && cpu_addr < 'h4016;
wire [7:0]apu_dout;
//reg  [7:0]APU_DO;
wire [15:0] sample_apu;

wire mr_int = cpu_rnw;
wire mw_int = !cpu_rnw;

APU apu(
   .MMC5           (1'b0), //
   .clk            (I_SUBCLKx2), //
   .PAL            (1'b0), //
   .ce             (I_CPU_CE), //
   .reset          (~I_SUB_RESETn), //
   .ADDR           (cpu_addr[4:0]), //
   .DIN            (cpu_dout), //
   .DOUT           (apu_dout), //
   .MW             (mw_int && apu_cs), //
   .MR             (mr_int && apu_cs), //
   .audio_channels (5'b11111), // not used?
   .Sample         (sample_apu), //
   .DmaReq         (/*apu_dma_request*/),
   .DmaAck         (/*apu_dma_ack*/),
   .DmaAddr        (/*apu_dma_addr*/),
   .DmaData        (/*from_data_bus*/),
   .odd_or_even    (I_ODD_OR_EVEN), //
   .IRQ            (apu_irq) //
);

//assign sample = sample_a;
assign O_SAMPLE = sample_inverted;
//reg [15:0] sample_a;

//always @* begin
//   case (audio_en)
//      0: sample_a = 16'd0;
//      1: sample_a = sample_ext;
//      2: sample_a = sample_inverted;
//      3: sample_a = sample_ext;
//   endcase
//end

wire [15:0] sample_inverted = 16'hFFFF - sample_apu;
//wire [1:0]  audio_en = {int_audio, ext_audio};
//wire [15:0] audio_mappers = (audio_en == 2'd1) ? 16'd0 : sample_inverted;


// Input ports are mapped into the APU's range.
//wire inport0_cs = (cpu_addr == 'h4016);
//wire inport1_cs = (cpu_addr == 'h4017);
//wire inport_cs = inport0_cs | inport1_cs;

//reg inp_strobe;

//always @(posedge clk) begin
//   if (inport1_cs && mw_int)
//      inp_strobe <= cpu_dout[0];
//end

//assign inport_strobe = inp_strobe;
//assign O_SUB_INP0n = ~(inport0_cs && mr_int);
//assign O_SUB_INP1n = ~(inport1_cs && mr_int);

endmodule
