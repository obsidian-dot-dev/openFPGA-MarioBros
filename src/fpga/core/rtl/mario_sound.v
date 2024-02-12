//----------------------------------------------------------------------------
// Mario Bros Arcade
//
// Author: gaz68 (https://github.com/gaz68) June 2020
//
// Top level sound module.
//----------------------------------------------------------------------------

module mario_sound
(
   input         I_CLK_48M,
   input         I_CEN_12M,
   input         I_CEN_11M,
   input         I_RESETn,
   input    [7:0]I_SND_DATA,
   input    [9:0]I_SND_CTRL,
   input    [3:0]I_ANLG_VOL,
   input         I_DS_FILTER,
   input    [3:0]I_H_CNT,
   input   [16:0]I_DLADDR,
   input    [7:0]I_DLDATA,
   input         I_DLWR,

   output signed  [15:0]O_SND_DAT
);

//------------------------------------------------
// Digital sound
// Background music and some of the sound effects
//------------------------------------------------

wire   [15:0]W_D_S_DATA;

mario_sound_digital digital_sound
(
   .I_CLK_48M(I_CLK_48M),
   .I_CEN_12M(I_CEN_12M),
   .I_CEN_11M(I_CEN_11M),
   .I_RST(I_RESETn),
   .I_DLADDR(I_DLADDR),
   .I_DLDATA(I_DLDATA),
   .I_DLWR(I_DLWR),
   .I_SND_DATA(I_SND_DATA),
   .I_SND_CTRL(I_SND_CTRL[6:0]),

   .O_SND_OUT(W_D_S_DATA)
);

//--------------------------------------
// Analogue Sounds (samples)
// Mario run, Luigi run and skid sounds
//--------------------------------------

wire signed [15:0]W_WAVROM_DS[0:2];

mario_sound_analog analog_sound
(
   .I_CLK_48M(I_CLK_48M),
   .I_RESETn(I_RESETn),

   .I_SND_CTRL(I_SND_CTRL[9:7]),
   .I_ANLG_VOL(I_ANLG_VOL),
   .I_H_CNT(I_H_CNT),

   .I_DLADDR(I_DLADDR),
   .I_DLDATA(I_DLDATA),
   .I_DLWR(I_DLWR),

   .O_WAVROM_DS0(W_WAVROM_DS[0]),
   .O_WAVROM_DS1(W_WAVROM_DS[1]),
   .O_WAVROM_DS2(W_WAVROM_DS[2])
);

//----------------------------------
// Sound Mixer (Analogue & Digital)
//----------------------------------

wire signed [15:0]W_SND_MIX;

mario_sound_mixer mixer
(
   .I_CLK_48M(I_CLK_48M),
   .I_SND1(W_WAVROM_DS[0]),
   .I_SND2(W_WAVROM_DS[1]),
   .I_SND3(W_WAVROM_DS[2]),
   .I_SND4(W_D_S_DATA),
   .O_SND_DAT(W_SND_MIX)
);

assign O_SND_DAT = W_SND_MIX;

endmodule
