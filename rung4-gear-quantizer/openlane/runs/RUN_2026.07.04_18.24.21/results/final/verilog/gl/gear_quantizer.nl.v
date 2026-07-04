// This is the unpowered netlist.
module gear_quantizer (clk,
    is_outlier,
    round_mode,
    rst_n,
    valid_in,
    valid_out,
    data_in,
    int4_out,
    scale,
    sideband_out,
    threshold);
 input clk;
 output is_outlier;
 input round_mode;
 input rst_n;
 input valid_in;
 output valid_out;
 input [7:0] data_in;
 output [3:0] int4_out;
 input [3:0] scale;
 output [7:0] sideband_out;
 input [7:0] threshold;

 wire _000_;
 wire _001_;
 wire _002_;
 wire _003_;
 wire _004_;
 wire _005_;
 wire _006_;
 wire _007_;
 wire _008_;
 wire _009_;
 wire _010_;
 wire _011_;
 wire _012_;
 wire _013_;
 wire _014_;
 wire _015_;
 wire _016_;
 wire _017_;
 wire _018_;
 wire _019_;
 wire _020_;
 wire _021_;
 wire _022_;
 wire _023_;
 wire _024_;
 wire _025_;
 wire _026_;
 wire _027_;
 wire _028_;
 wire _029_;
 wire _030_;
 wire _031_;
 wire _032_;
 wire _033_;
 wire _034_;
 wire _035_;
 wire _036_;
 wire _037_;
 wire _038_;
 wire _039_;
 wire _040_;
 wire _041_;
 wire _042_;
 wire _043_;
 wire _044_;
 wire _045_;
 wire _046_;
 wire _047_;
 wire _048_;
 wire _049_;
 wire _050_;
 wire _051_;
 wire _052_;
 wire _053_;
 wire _054_;
 wire _055_;
 wire _056_;
 wire _057_;
 wire _058_;
 wire _059_;
 wire _060_;
 wire _061_;
 wire _062_;
 wire _063_;
 wire _064_;
 wire _065_;
 wire _066_;
 wire _067_;
 wire _068_;
 wire _069_;
 wire _070_;
 wire _071_;
 wire _072_;
 wire _073_;
 wire _074_;
 wire _075_;
 wire _076_;
 wire _077_;
 wire _078_;
 wire _079_;
 wire _080_;
 wire _081_;
 wire _082_;
 wire _083_;
 wire _084_;
 wire _085_;
 wire _086_;
 wire _087_;
 wire _088_;
 wire _089_;
 wire _090_;
 wire _091_;
 wire _092_;
 wire _093_;
 wire _094_;
 wire _095_;
 wire _096_;
 wire _097_;
 wire _098_;
 wire _099_;
 wire _100_;
 wire _101_;
 wire _102_;
 wire _103_;
 wire _104_;
 wire _105_;
 wire _106_;
 wire _107_;
 wire _108_;
 wire _109_;
 wire _110_;
 wire _111_;
 wire _112_;
 wire _113_;
 wire _114_;
 wire _115_;
 wire _116_;
 wire _117_;
 wire _118_;
 wire _119_;
 wire _120_;
 wire _121_;
 wire _122_;
 wire _123_;
 wire _124_;
 wire _125_;
 wire _126_;
 wire _127_;
 wire _128_;
 wire _129_;
 wire _130_;
 wire _131_;
 wire _132_;
 wire _133_;
 wire _134_;
 wire _135_;
 wire _136_;
 wire _137_;
 wire _138_;
 wire _139_;
 wire _140_;
 wire _141_;
 wire _142_;
 wire _143_;
 wire _144_;
 wire _145_;
 wire _146_;
 wire _147_;
 wire _148_;
 wire _149_;
 wire _150_;
 wire _151_;
 wire _152_;
 wire _153_;
 wire _154_;
 wire _155_;
 wire _156_;
 wire _157_;
 wire _158_;
 wire _159_;
 wire _160_;
 wire _161_;
 wire _162_;
 wire _163_;
 wire _164_;
 wire _165_;
 wire _166_;
 wire _167_;
 wire _168_;
 wire _169_;
 wire _170_;
 wire _171_;
 wire _172_;
 wire _173_;
 wire _174_;
 wire _175_;
 wire _176_;
 wire _177_;
 wire _178_;
 wire _179_;
 wire _180_;
 wire _181_;
 wire _182_;
 wire _183_;
 wire _184_;
 wire _185_;
 wire _186_;
 wire _187_;
 wire _188_;
 wire _189_;
 wire _190_;
 wire _191_;
 wire _192_;
 wire _193_;
 wire _194_;
 wire _195_;
 wire _196_;
 wire _197_;
 wire _198_;
 wire _199_;
 wire _200_;
 wire _201_;
 wire _202_;
 wire _203_;
 wire _204_;
 wire _205_;
 wire _206_;
 wire _207_;
 wire _208_;
 wire _209_;
 wire _210_;
 wire _211_;
 wire _212_;
 wire _213_;
 wire _214_;
 wire _215_;
 wire _216_;
 wire _217_;
 wire _218_;
 wire _219_;
 wire _220_;
 wire _221_;
 wire _222_;
 wire _223_;
 wire _224_;
 wire _225_;
 wire _226_;
 wire _227_;
 wire _228_;
 wire _229_;
 wire _230_;
 wire _231_;
 wire _232_;
 wire _233_;
 wire _234_;
 wire _235_;
 wire _236_;
 wire _237_;
 wire _238_;
 wire clknet_0_clk;
 wire clknet_1_0__leaf_clk;
 wire clknet_1_1__leaf_clk;
 wire net1;
 wire net10;
 wire net11;
 wire net12;
 wire net13;
 wire net14;
 wire net15;
 wire net16;
 wire net17;
 wire net18;
 wire net19;
 wire net2;
 wire net20;
 wire net21;
 wire net22;
 wire net23;
 wire net24;
 wire net25;
 wire net26;
 wire net27;
 wire net28;
 wire net29;
 wire net3;
 wire net30;
 wire net31;
 wire net32;
 wire net33;
 wire net34;
 wire net35;
 wire net36;
 wire net37;
 wire net38;
 wire net39;
 wire net4;
 wire net40;
 wire net41;
 wire net42;
 wire net43;
 wire net44;
 wire net45;
 wire net46;
 wire net47;
 wire net48;
 wire net49;
 wire net5;
 wire net50;
 wire net51;
 wire net6;
 wire net7;
 wire net8;
 wire net9;

 sky130_fd_sc_hd__decap_3 FILLER_0_0_109 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_0_113 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_0_118 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_0_130 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_0_138 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_0_14 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_0_147 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_0_155 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_0_161 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_0_169 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_0_26 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_0_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_0_47 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_0_57 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_0_69 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_0_7 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_0_76 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_0_85 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_0_97 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_10_119 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_10_131 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_10_139 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_10_141 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_10_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_10_153 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_10_165 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_10_27 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_10_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_10_3 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_10_42 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_10_58 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_10_66 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_10_75 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_11_108 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_11_13 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_11_131 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_11_143 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_11_155 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_11_167 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_11_169 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_11_25 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_11_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_11_42 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_11_54 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_11_57 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_11_65 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_11_75 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_11_81 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_11_89 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_11_96 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_12_107 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_12_115 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_12_121 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_12_133 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_12_139 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_12_141 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_12_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_12_153 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_12_165 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_12_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_12_41 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_12_66 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_12_74 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_12_85 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_12_89 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_13_103 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_13_111 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_13_129 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_13_141 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_13_153 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_13_165 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_13_169 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_13_3 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_13_30 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_13_54 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_13_61 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_13_69 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_13_91 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_14_106 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_14_114 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_14_141 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_14_153 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_14_25 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_14_3 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_14_34 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_14_42 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_14_65 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_14_90 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_15_113 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_15_137 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_15_149 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_15_161 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_15_167 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_15_169 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_15_17 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_15_25 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_15_38 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_15_44 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_15_50 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_15_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_15_73 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_15_84 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_15_9 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_16_110 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_16_130 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_16_138 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_16_141 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_16_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_16_153 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_16_165 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_16_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_16_3 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_16_67 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_16_74 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_16_82 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_16_88 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_16_96 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_17_104 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_17_125 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_17_137 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_17_149 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_17_15 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_17_161 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_17_169 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_17_3 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_17_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_17_43 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_17_57 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_17_68 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_17_76 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_17_86 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_17_94 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_18_105 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_18_124 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_18_136 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_18_141 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_18_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_18_153 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_18_165 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_18_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_18_3 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_18_42 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_18_48 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_18_59 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_18_64 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_18_68 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_18_81 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_18_85 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_18_89 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_19_104 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_19_113 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_19_127 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_19_139 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_19_151 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_19_163 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_19_167 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_19_169 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_19_48 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_19_62 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_19_76 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_19_9 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_19_91 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_1_105 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_1_111 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_1_113 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_1_125 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_1_137 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_1_149 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_1_161 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_1_167 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_1_169 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_1_19 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_1_31 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_1_43 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_1_55 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_1_57 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_1_69 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_1_7 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_1_81 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_1_93 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_20_101 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_20_141 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_20_153 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_20_165 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_20_27 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_20_3 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_20_34 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_20_43 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_20_64 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_20_76 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_20_90 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_21_103 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_21_111 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_21_113 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_21_128 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_21_13 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_21_132 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_21_147 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_21_159 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_21_169 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_21_25 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_21_29 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_21_48 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_21_57 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_21_65 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_21_74 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_21_86 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_21_93 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_22_107 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_22_127 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_22_139 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_22_141 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_22_153 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_22_165 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_22_29 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_22_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_22_41 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_22_53 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_22_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_22_81 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_22_99 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_23_134 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_23_146 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_23_158 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_23_166 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_23_169 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_23_18 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_23_3 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_23_54 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_23_60 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_23_68 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_23_81 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_23_9 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_24_11 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_24_128 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_24_141 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_24_153 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_24_165 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_24_20 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_24_29 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_24_3 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_24_37 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_24_54 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_24_67 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_24_85 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_24_91 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_25_110 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_25_120 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_25_132 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_25_144 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_25_15 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_25_156 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_25_169 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_25_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_25_3 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_25_39 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_25_47 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_25_57 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_25_63 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_25_75 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_25_87 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_25_93 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_25_98 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_26_100 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_26_114 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_26_126 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_26_138 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_26_141 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_26_153 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_26_165 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_26_21 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_26_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_26_29 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_26_41 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_26_51 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_26_59 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_26_78 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_26_9 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_27_120 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_27_132 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_27_144 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_27_15 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_27_156 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_27_164 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_27_169 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_27_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_27_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_27_39 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_27_51 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_27_55 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_27_57 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_27_73 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_28_107 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_28_111 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_28_113 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_28_121 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_28_125 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_28_137 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_28_141 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_28_147 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_28_169 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_28_20 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_28_29 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_28_37 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_28_44 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_28_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_28_62 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_28_72 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_28_76 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_28_83 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_28_85 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_28_9 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_28_93 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_2_109 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_2_121 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_2_133 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_2_139 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_2_141 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_2_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_2_153 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_2_165 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_2_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_2_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_2_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_2_41 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_2_53 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_2_65 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_2_77 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_2_83 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_2_85 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_2_97 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_3_111 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_3_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_3_121 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_3_129 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_3_138 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_3_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_3_150 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_3_162 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_3_169 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_3_3 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_3_43 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_3_54 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_3_63 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_3_75 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_3_87 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_3_99 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_4_109 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_4_113 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_4_134 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_4_141 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_4_153 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_4_165 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_4_74 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_4_82 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_4_85 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_4_9 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_4_97 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_5_113 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_5_131 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_5_143 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_5_155 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_5_167 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_5_169 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_5_26 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_5_3 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_5_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_5_57 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_5_70 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_5_80 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_5_93 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_6_112 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_6_135 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_6_139 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_6_141 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_6_153 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_6_165 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_6_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_6_36 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_6_65 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_6_97 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_7_104 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_7_118 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_7_124 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_7_130 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_7_139 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_7_151 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_7_163 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_7_167 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_7_169 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_7_39 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_7_47 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_7_55 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_7_6 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_7_60 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_7_82 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_7_90 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_7_98 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_8_109 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_8_117 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_8_130 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_8_138 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_8_141 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_8_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_8_153 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_8_165 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_8_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_8_3 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_8_37 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_8_49 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_8_61 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_8_68 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_8_80 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_8_85 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_8_93 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_9_107 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_9_111 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_9_113 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_9_145 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_9_15 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_9_157 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_9_165 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_9_169 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_9_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_9_3 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_9_39 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_9_45 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_9_53 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_9_57 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_9_67 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_9_78 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_9_95 ();
 sky130_fd_sc_hd__decap_3 PHY_0 ();
 sky130_fd_sc_hd__decap_3 PHY_1 ();
 sky130_fd_sc_hd__decap_3 PHY_10 ();
 sky130_fd_sc_hd__decap_3 PHY_11 ();
 sky130_fd_sc_hd__decap_3 PHY_12 ();
 sky130_fd_sc_hd__decap_3 PHY_13 ();
 sky130_fd_sc_hd__decap_3 PHY_14 ();
 sky130_fd_sc_hd__decap_3 PHY_15 ();
 sky130_fd_sc_hd__decap_3 PHY_16 ();
 sky130_fd_sc_hd__decap_3 PHY_17 ();
 sky130_fd_sc_hd__decap_3 PHY_18 ();
 sky130_fd_sc_hd__decap_3 PHY_19 ();
 sky130_fd_sc_hd__decap_3 PHY_2 ();
 sky130_fd_sc_hd__decap_3 PHY_20 ();
 sky130_fd_sc_hd__decap_3 PHY_21 ();
 sky130_fd_sc_hd__decap_3 PHY_22 ();
 sky130_fd_sc_hd__decap_3 PHY_23 ();
 sky130_fd_sc_hd__decap_3 PHY_24 ();
 sky130_fd_sc_hd__decap_3 PHY_25 ();
 sky130_fd_sc_hd__decap_3 PHY_26 ();
 sky130_fd_sc_hd__decap_3 PHY_27 ();
 sky130_fd_sc_hd__decap_3 PHY_28 ();
 sky130_fd_sc_hd__decap_3 PHY_29 ();
 sky130_fd_sc_hd__decap_3 PHY_3 ();
 sky130_fd_sc_hd__decap_3 PHY_30 ();
 sky130_fd_sc_hd__decap_3 PHY_31 ();
 sky130_fd_sc_hd__decap_3 PHY_32 ();
 sky130_fd_sc_hd__decap_3 PHY_33 ();
 sky130_fd_sc_hd__decap_3 PHY_34 ();
 sky130_fd_sc_hd__decap_3 PHY_35 ();
 sky130_fd_sc_hd__decap_3 PHY_36 ();
 sky130_fd_sc_hd__decap_3 PHY_37 ();
 sky130_fd_sc_hd__decap_3 PHY_38 ();
 sky130_fd_sc_hd__decap_3 PHY_39 ();
 sky130_fd_sc_hd__decap_3 PHY_4 ();
 sky130_fd_sc_hd__decap_3 PHY_40 ();
 sky130_fd_sc_hd__decap_3 PHY_41 ();
 sky130_fd_sc_hd__decap_3 PHY_42 ();
 sky130_fd_sc_hd__decap_3 PHY_43 ();
 sky130_fd_sc_hd__decap_3 PHY_44 ();
 sky130_fd_sc_hd__decap_3 PHY_45 ();
 sky130_fd_sc_hd__decap_3 PHY_46 ();
 sky130_fd_sc_hd__decap_3 PHY_47 ();
 sky130_fd_sc_hd__decap_3 PHY_48 ();
 sky130_fd_sc_hd__decap_3 PHY_49 ();
 sky130_fd_sc_hd__decap_3 PHY_5 ();
 sky130_fd_sc_hd__decap_3 PHY_50 ();
 sky130_fd_sc_hd__decap_3 PHY_51 ();
 sky130_fd_sc_hd__decap_3 PHY_52 ();
 sky130_fd_sc_hd__decap_3 PHY_53 ();
 sky130_fd_sc_hd__decap_3 PHY_54 ();
 sky130_fd_sc_hd__decap_3 PHY_55 ();
 sky130_fd_sc_hd__decap_3 PHY_56 ();
 sky130_fd_sc_hd__decap_3 PHY_57 ();
 sky130_fd_sc_hd__decap_3 PHY_6 ();
 sky130_fd_sc_hd__decap_3 PHY_7 ();
 sky130_fd_sc_hd__decap_3 PHY_8 ();
 sky130_fd_sc_hd__decap_3 PHY_9 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_100 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_101 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_102 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_103 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_104 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_105 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_106 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_107 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_108 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_109 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_110 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_111 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_112 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_113 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_114 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_115 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_116 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_117 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_118 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_119 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_120 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_121 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_122 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_123 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_124 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_125 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_126 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_127 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_128 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_129 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_130 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_131 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_132 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_133 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_134 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_135 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_136 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_137 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_138 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_139 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_140 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_141 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_142 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_143 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_144 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_145 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_146 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_147 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_148 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_149 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_150 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_58 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_59 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_60 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_61 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_62 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_63 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_64 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_65 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_66 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_67 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_68 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_69 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_70 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_71 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_72 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_73 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_74 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_75 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_76 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_77 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_78 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_79 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_80 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_81 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_82 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_83 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_84 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_85 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_86 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_87 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_88 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_89 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_90 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_91 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_92 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_93 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_94 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_95 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_96 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_97 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_98 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_99 ();
 sky130_fd_sc_hd__clkbuf_4 _239_ (.A(net23),
    .X(_189_));
 sky130_fd_sc_hd__inv_2 _240_ (.A(_189_),
    .Y(_190_));
 sky130_fd_sc_hd__clkbuf_4 _241_ (.A(_190_),
    .X(_191_));
 sky130_fd_sc_hd__clkbuf_4 _242_ (.A(net7),
    .X(_192_));
 sky130_fd_sc_hd__clkbuf_4 _243_ (.A(net6),
    .X(_193_));
 sky130_fd_sc_hd__clkbuf_4 _244_ (.A(net5),
    .X(_194_));
 sky130_fd_sc_hd__clkbuf_4 _245_ (.A(net3),
    .X(_195_));
 sky130_fd_sc_hd__buf_2 _246_ (.A(net2),
    .X(_196_));
 sky130_fd_sc_hd__buf_2 _247_ (.A(net1),
    .X(_197_));
 sky130_fd_sc_hd__or4_1 _248_ (.A(net4),
    .B(_195_),
    .C(_196_),
    .D(_197_),
    .X(_198_));
 sky130_fd_sc_hd__or3_1 _249_ (.A(_193_),
    .B(_194_),
    .C(_198_),
    .X(_199_));
 sky130_fd_sc_hd__buf_2 _250_ (.A(net8),
    .X(_200_));
 sky130_fd_sc_hd__or3b_2 _251_ (.A(_192_),
    .B(_199_),
    .C_N(_200_),
    .X(_201_));
 sky130_fd_sc_hd__nand2_1 _252_ (.A(_200_),
    .B(_199_),
    .Y(_202_));
 sky130_fd_sc_hd__xor2_1 _253_ (.A(_192_),
    .B(_202_),
    .X(_203_));
 sky130_fd_sc_hd__and2_1 _254_ (.A(net21),
    .B(_203_),
    .X(_204_));
 sky130_fd_sc_hd__o21a_1 _255_ (.A1(_194_),
    .A2(_198_),
    .B1(_200_),
    .X(_205_));
 sky130_fd_sc_hd__xnor2_1 _256_ (.A(_193_),
    .B(_205_),
    .Y(_206_));
 sky130_fd_sc_hd__nand2_1 _257_ (.A(_200_),
    .B(_198_),
    .Y(_207_));
 sky130_fd_sc_hd__xor2_1 _258_ (.A(_194_),
    .B(_207_),
    .X(_208_));
 sky130_fd_sc_hd__or2_1 _259_ (.A(net19),
    .B(_208_),
    .X(_209_));
 sky130_fd_sc_hd__o31a_1 _260_ (.A1(_195_),
    .A2(_196_),
    .A3(_197_),
    .B1(_200_),
    .X(_210_));
 sky130_fd_sc_hd__xnor2_1 _261_ (.A(net4),
    .B(_210_),
    .Y(_211_));
 sky130_fd_sc_hd__or2_1 _262_ (.A(net18),
    .B(_211_),
    .X(_212_));
 sky130_fd_sc_hd__o21a_1 _263_ (.A1(_196_),
    .A2(_197_),
    .B1(_200_),
    .X(_213_));
 sky130_fd_sc_hd__xnor2_1 _264_ (.A(_195_),
    .B(_213_),
    .Y(_214_));
 sky130_fd_sc_hd__or2_1 _265_ (.A(net17),
    .B(_214_),
    .X(_215_));
 sky130_fd_sc_hd__nand2_1 _266_ (.A(net8),
    .B(_197_),
    .Y(_216_));
 sky130_fd_sc_hd__xor2_1 _267_ (.A(_196_),
    .B(_216_),
    .X(_217_));
 sky130_fd_sc_hd__inv_2 _268_ (.A(_197_),
    .Y(_218_));
 sky130_fd_sc_hd__a211o_1 _269_ (.A1(net16),
    .A2(_217_),
    .B1(net15),
    .C1(_218_),
    .X(_219_));
 sky130_fd_sc_hd__or2_1 _270_ (.A(net16),
    .B(_217_),
    .X(_220_));
 sky130_fd_sc_hd__a22o_1 _271_ (.A1(net17),
    .A2(_214_),
    .B1(_219_),
    .B2(_220_),
    .X(_221_));
 sky130_fd_sc_hd__a22o_1 _272_ (.A1(net18),
    .A2(_211_),
    .B1(_215_),
    .B2(_221_),
    .X(_222_));
 sky130_fd_sc_hd__a22o_1 _273_ (.A1(net19),
    .A2(_208_),
    .B1(_212_),
    .B2(_222_),
    .X(_223_));
 sky130_fd_sc_hd__a22o_1 _274_ (.A1(net20),
    .A2(_206_),
    .B1(_209_),
    .B2(_223_),
    .X(_224_));
 sky130_fd_sc_hd__o221a_1 _275_ (.A1(net21),
    .A2(_203_),
    .B1(_206_),
    .B2(net20),
    .C1(_224_),
    .X(_225_));
 sky130_fd_sc_hd__o22a_1 _276_ (.A1(net22),
    .A2(_201_),
    .B1(_204_),
    .B2(_225_),
    .X(_226_));
 sky130_fd_sc_hd__a21oi_4 _277_ (.A1(net22),
    .A2(_201_),
    .B1(_226_),
    .Y(_227_));
 sky130_fd_sc_hd__nor2_2 _278_ (.A(_191_),
    .B(_227_),
    .Y(_228_));
 sky130_fd_sc_hd__o21ba_1 _279_ (.A1(net41),
    .A2(_189_),
    .B1_N(_228_),
    .X(_000_));
 sky130_fd_sc_hd__nand2_2 _280_ (.A(net8),
    .B(net11),
    .Y(_229_));
 sky130_fd_sc_hd__buf_2 _281_ (.A(net14),
    .X(_230_));
 sky130_fd_sc_hd__clkbuf_4 _282_ (.A(net13),
    .X(_231_));
 sky130_fd_sc_hd__and4_1 _283_ (.A(_230_),
    .B(net8),
    .C(_231_),
    .D(_192_),
    .X(_232_));
 sky130_fd_sc_hd__and2_1 _284_ (.A(net8),
    .B(net12),
    .X(_233_));
 sky130_fd_sc_hd__a22o_1 _285_ (.A1(net8),
    .A2(_231_),
    .B1(_192_),
    .B2(_230_),
    .X(_234_));
 sky130_fd_sc_hd__nand4_1 _286_ (.A(_230_),
    .B(net8),
    .C(_231_),
    .D(_192_),
    .Y(_235_));
 sky130_fd_sc_hd__and3_1 _287_ (.A(_233_),
    .B(_234_),
    .C(_235_),
    .X(_236_));
 sky130_fd_sc_hd__and3_1 _288_ (.A(_230_),
    .B(net8),
    .C(_231_),
    .X(_237_));
 sky130_fd_sc_hd__o21ai_1 _289_ (.A1(_230_),
    .A2(_231_),
    .B1(net8),
    .Y(_238_));
 sky130_fd_sc_hd__o21a_1 _290_ (.A1(_237_),
    .A2(_238_),
    .B1(_233_),
    .X(_013_));
 sky130_fd_sc_hd__or3_1 _291_ (.A(_237_),
    .B(_233_),
    .C(_238_),
    .X(_014_));
 sky130_fd_sc_hd__or4b_1 _292_ (.A(_232_),
    .B(_236_),
    .C(_013_),
    .D_N(_014_),
    .X(_015_));
 sky130_fd_sc_hd__buf_2 _293_ (.A(net12),
    .X(_016_));
 sky130_fd_sc_hd__nand2_1 _294_ (.A(_200_),
    .B(_016_),
    .Y(_017_));
 sky130_fd_sc_hd__a22o_1 _295_ (.A1(_016_),
    .A2(_237_),
    .B1(_017_),
    .B2(_238_),
    .X(_018_));
 sky130_fd_sc_hd__nand4_2 _296_ (.A(_230_),
    .B(_231_),
    .C(_193_),
    .D(_194_),
    .Y(_019_));
 sky130_fd_sc_hd__buf_2 _297_ (.A(net13),
    .X(_020_));
 sky130_fd_sc_hd__a22o_1 _298_ (.A1(_020_),
    .A2(_193_),
    .B1(_194_),
    .B2(net14),
    .X(_021_));
 sky130_fd_sc_hd__nand4_2 _299_ (.A(_016_),
    .B(_192_),
    .C(_019_),
    .D(_021_),
    .Y(_022_));
 sky130_fd_sc_hd__and2_1 _300_ (.A(_019_),
    .B(_022_),
    .X(_023_));
 sky130_fd_sc_hd__nand4_2 _301_ (.A(_230_),
    .B(_020_),
    .C(_192_),
    .D(_193_),
    .Y(_024_));
 sky130_fd_sc_hd__a22o_1 _302_ (.A1(_020_),
    .A2(net7),
    .B1(_193_),
    .B2(net14),
    .X(_025_));
 sky130_fd_sc_hd__nand3_1 _303_ (.A(_233_),
    .B(_024_),
    .C(_025_),
    .Y(_026_));
 sky130_fd_sc_hd__a21o_1 _304_ (.A1(_024_),
    .A2(_025_),
    .B1(_233_),
    .X(_027_));
 sky130_fd_sc_hd__and2_1 _305_ (.A(_026_),
    .B(_027_),
    .X(_028_));
 sky130_fd_sc_hd__and2b_1 _306_ (.A_N(_023_),
    .B(_028_),
    .X(_029_));
 sky130_fd_sc_hd__buf_2 _307_ (.A(net11),
    .X(_030_));
 sky130_fd_sc_hd__xnor2_1 _308_ (.A(_028_),
    .B(_023_),
    .Y(_031_));
 sky130_fd_sc_hd__and3_1 _309_ (.A(_200_),
    .B(_030_),
    .C(_031_),
    .X(_032_));
 sky130_fd_sc_hd__a21oi_1 _310_ (.A1(_234_),
    .A2(_235_),
    .B1(_233_),
    .Y(_033_));
 sky130_fd_sc_hd__a211oi_1 _311_ (.A1(_024_),
    .A2(_026_),
    .B1(_236_),
    .C1(_033_),
    .Y(_034_));
 sky130_fd_sc_hd__o211a_1 _312_ (.A1(_236_),
    .A2(_033_),
    .B1(_024_),
    .C1(_026_),
    .X(_035_));
 sky130_fd_sc_hd__nor2_1 _313_ (.A(_034_),
    .B(_035_),
    .Y(_036_));
 sky130_fd_sc_hd__xnor2_1 _314_ (.A(_229_),
    .B(_036_),
    .Y(_037_));
 sky130_fd_sc_hd__o21ai_2 _315_ (.A1(_029_),
    .A2(_032_),
    .B1(_037_),
    .Y(_038_));
 sky130_fd_sc_hd__a31o_1 _316_ (.A1(_200_),
    .A2(_030_),
    .A3(_036_),
    .B1(_034_),
    .X(_039_));
 sky130_fd_sc_hd__a21bo_1 _317_ (.A1(_016_),
    .A2(_237_),
    .B1_N(_015_),
    .X(_040_));
 sky130_fd_sc_hd__xor2_1 _318_ (.A(_229_),
    .B(_040_),
    .X(_041_));
 sky130_fd_sc_hd__nand2_1 _319_ (.A(_039_),
    .B(_041_),
    .Y(_042_));
 sky130_fd_sc_hd__or2_1 _320_ (.A(_039_),
    .B(_041_),
    .X(_043_));
 sky130_fd_sc_hd__nand2_1 _321_ (.A(_042_),
    .B(_043_),
    .Y(_044_));
 sky130_fd_sc_hd__o21a_1 _322_ (.A1(_038_),
    .A2(_044_),
    .B1(_042_),
    .X(_045_));
 sky130_fd_sc_hd__xnor2_1 _323_ (.A(_018_),
    .B(_045_),
    .Y(_046_));
 sky130_fd_sc_hd__nand3_1 _324_ (.A(_016_),
    .B(_237_),
    .C(_229_),
    .Y(_047_));
 sky130_fd_sc_hd__o211a_1 _325_ (.A1(_229_),
    .A2(_015_),
    .B1(_046_),
    .C1(_047_),
    .X(_048_));
 sky130_fd_sc_hd__inv_2 _326_ (.A(_048_),
    .Y(_049_));
 sky130_fd_sc_hd__and2_1 _327_ (.A(net12),
    .B(net6),
    .X(_050_));
 sky130_fd_sc_hd__a22o_1 _328_ (.A1(_020_),
    .A2(net5),
    .B1(net4),
    .B2(net14),
    .X(_051_));
 sky130_fd_sc_hd__nand4_1 _329_ (.A(net14),
    .B(_020_),
    .C(_194_),
    .D(net4),
    .Y(_052_));
 sky130_fd_sc_hd__a21bo_1 _330_ (.A1(_050_),
    .A2(_051_),
    .B1_N(_052_),
    .X(_053_));
 sky130_fd_sc_hd__a22o_1 _331_ (.A1(_016_),
    .A2(_192_),
    .B1(_019_),
    .B2(_021_),
    .X(_054_));
 sky130_fd_sc_hd__nand3_1 _332_ (.A(_022_),
    .B(_053_),
    .C(_054_),
    .Y(_055_));
 sky130_fd_sc_hd__and3_1 _333_ (.A(_022_),
    .B(_053_),
    .C(_054_),
    .X(_056_));
 sky130_fd_sc_hd__a21o_1 _334_ (.A1(_022_),
    .A2(_054_),
    .B1(_053_),
    .X(_057_));
 sky130_fd_sc_hd__or3b_2 _335_ (.A(_229_),
    .B(_056_),
    .C_N(_057_),
    .X(_058_));
 sky130_fd_sc_hd__xnor2_1 _336_ (.A(_229_),
    .B(_031_),
    .Y(_059_));
 sky130_fd_sc_hd__a21boi_2 _337_ (.A1(_055_),
    .A2(_058_),
    .B1_N(_059_),
    .Y(_060_));
 sky130_fd_sc_hd__or3_1 _338_ (.A(_037_),
    .B(_029_),
    .C(_032_),
    .X(_061_));
 sky130_fd_sc_hd__and2_1 _339_ (.A(_038_),
    .B(_061_),
    .X(_062_));
 sky130_fd_sc_hd__xor2_1 _340_ (.A(_060_),
    .B(_062_),
    .X(_063_));
 sky130_fd_sc_hd__or3b_1 _341_ (.A(_059_),
    .B(_056_),
    .C_N(_058_),
    .X(_064_));
 sky130_fd_sc_hd__or2b_1 _342_ (.A(_060_),
    .B_N(_064_),
    .X(_065_));
 sky130_fd_sc_hd__nand2_1 _343_ (.A(net11),
    .B(_192_),
    .Y(_066_));
 sky130_fd_sc_hd__nand3_1 _344_ (.A(_052_),
    .B(_050_),
    .C(_051_),
    .Y(_067_));
 sky130_fd_sc_hd__a21o_1 _345_ (.A1(_052_),
    .A2(_051_),
    .B1(_050_),
    .X(_068_));
 sky130_fd_sc_hd__and2_1 _346_ (.A(net12),
    .B(_194_),
    .X(_069_));
 sky130_fd_sc_hd__a22o_1 _347_ (.A1(net13),
    .A2(net4),
    .B1(net3),
    .B2(net14),
    .X(_070_));
 sky130_fd_sc_hd__nand4_1 _348_ (.A(net14),
    .B(_020_),
    .C(net4),
    .D(net3),
    .Y(_071_));
 sky130_fd_sc_hd__a21bo_1 _349_ (.A1(_069_),
    .A2(_070_),
    .B1_N(_071_),
    .X(_072_));
 sky130_fd_sc_hd__a21oi_1 _350_ (.A1(_067_),
    .A2(_068_),
    .B1(_072_),
    .Y(_073_));
 sky130_fd_sc_hd__and3_1 _351_ (.A(_067_),
    .B(_072_),
    .C(_068_),
    .X(_074_));
 sky130_fd_sc_hd__o21bai_1 _352_ (.A1(_066_),
    .A2(_073_),
    .B1_N(_074_),
    .Y(_075_));
 sky130_fd_sc_hd__a21bo_1 _353_ (.A1(_055_),
    .A2(_057_),
    .B1_N(_229_),
    .X(_076_));
 sky130_fd_sc_hd__and3_2 _354_ (.A(_058_),
    .B(_075_),
    .C(_076_),
    .X(_077_));
 sky130_fd_sc_hd__xnor2_2 _355_ (.A(_065_),
    .B(_077_),
    .Y(_078_));
 sky130_fd_sc_hd__a22o_1 _356_ (.A1(_020_),
    .A2(net3),
    .B1(net2),
    .B2(net14),
    .X(_079_));
 sky130_fd_sc_hd__nand4_1 _357_ (.A(_230_),
    .B(_020_),
    .C(_195_),
    .D(_196_),
    .Y(_080_));
 sky130_fd_sc_hd__and2_1 _358_ (.A(net12),
    .B(net4),
    .X(_081_));
 sky130_fd_sc_hd__nand3_1 _359_ (.A(_079_),
    .B(_080_),
    .C(_081_),
    .Y(_082_));
 sky130_fd_sc_hd__a21o_1 _360_ (.A1(_079_),
    .A2(_080_),
    .B1(_081_),
    .X(_083_));
 sky130_fd_sc_hd__and4_1 _361_ (.A(_230_),
    .B(_231_),
    .C(_196_),
    .D(_197_),
    .X(_084_));
 sky130_fd_sc_hd__nand4_1 _362_ (.A(_230_),
    .B(_020_),
    .C(net2),
    .D(net1),
    .Y(_085_));
 sky130_fd_sc_hd__a22o_1 _363_ (.A1(_020_),
    .A2(net2),
    .B1(net1),
    .B2(net14),
    .X(_086_));
 sky130_fd_sc_hd__and4_1 _364_ (.A(_016_),
    .B(_195_),
    .C(_085_),
    .D(_086_),
    .X(_087_));
 sky130_fd_sc_hd__a211o_1 _365_ (.A1(_082_),
    .A2(_083_),
    .B1(_084_),
    .C1(_087_),
    .X(_088_));
 sky130_fd_sc_hd__o211a_1 _366_ (.A1(_084_),
    .A2(_087_),
    .B1(_082_),
    .C1(_083_),
    .X(_089_));
 sky130_fd_sc_hd__a31o_1 _367_ (.A1(_030_),
    .A2(_194_),
    .A3(_088_),
    .B1(_089_),
    .X(_090_));
 sky130_fd_sc_hd__nand3_1 _368_ (.A(_071_),
    .B(_069_),
    .C(_070_),
    .Y(_091_));
 sky130_fd_sc_hd__a21bo_1 _369_ (.A1(_079_),
    .A2(_081_),
    .B1_N(_080_),
    .X(_092_));
 sky130_fd_sc_hd__a21o_1 _370_ (.A1(_071_),
    .A2(_070_),
    .B1(_069_),
    .X(_093_));
 sky130_fd_sc_hd__nand3_1 _371_ (.A(_091_),
    .B(_092_),
    .C(_093_),
    .Y(_094_));
 sky130_fd_sc_hd__a21o_1 _372_ (.A1(_091_),
    .A2(_093_),
    .B1(_092_),
    .X(_095_));
 sky130_fd_sc_hd__nand4_1 _373_ (.A(_030_),
    .B(_193_),
    .C(_094_),
    .D(_095_),
    .Y(_096_));
 sky130_fd_sc_hd__a22o_1 _374_ (.A1(_030_),
    .A2(_193_),
    .B1(_094_),
    .B2(_095_),
    .X(_097_));
 sky130_fd_sc_hd__and3_2 _375_ (.A(_090_),
    .B(_096_),
    .C(_097_),
    .X(_098_));
 sky130_fd_sc_hd__a21oi_1 _376_ (.A1(_096_),
    .A2(_097_),
    .B1(_090_),
    .Y(_099_));
 sky130_fd_sc_hd__nor2_1 _377_ (.A(_098_),
    .B(_099_),
    .Y(_100_));
 sky130_fd_sc_hd__nand4_1 _378_ (.A(_016_),
    .B(_195_),
    .C(_085_),
    .D(_086_),
    .Y(_101_));
 sky130_fd_sc_hd__and4_1 _379_ (.A(_231_),
    .B(net12),
    .C(_196_),
    .D(_197_),
    .X(_102_));
 sky130_fd_sc_hd__a22o_1 _380_ (.A1(net12),
    .A2(_195_),
    .B1(_085_),
    .B2(_086_),
    .X(_103_));
 sky130_fd_sc_hd__and3_1 _381_ (.A(_101_),
    .B(_102_),
    .C(_103_),
    .X(_104_));
 sky130_fd_sc_hd__nand2_1 _382_ (.A(_030_),
    .B(net4),
    .Y(_105_));
 sky130_fd_sc_hd__a21oi_1 _383_ (.A1(_101_),
    .A2(_103_),
    .B1(_102_),
    .Y(_106_));
 sky130_fd_sc_hd__or3_1 _384_ (.A(_104_),
    .B(_105_),
    .C(_106_),
    .X(_107_));
 sky130_fd_sc_hd__or2b_1 _385_ (.A(_104_),
    .B_N(_107_),
    .X(_108_));
 sky130_fd_sc_hd__nand2_1 _386_ (.A(_030_),
    .B(_194_),
    .Y(_109_));
 sky130_fd_sc_hd__and2b_1 _387_ (.A_N(_089_),
    .B(_088_),
    .X(_110_));
 sky130_fd_sc_hd__xnor2_1 _388_ (.A(_109_),
    .B(_110_),
    .Y(_111_));
 sky130_fd_sc_hd__or2_1 _389_ (.A(_108_),
    .B(_111_),
    .X(_112_));
 sky130_fd_sc_hd__o21ai_1 _390_ (.A1(_104_),
    .A2(_106_),
    .B1(_105_),
    .Y(_113_));
 sky130_fd_sc_hd__a22o_1 _391_ (.A1(_016_),
    .A2(_196_),
    .B1(_197_),
    .B2(_231_),
    .X(_114_));
 sky130_fd_sc_hd__and4b_1 _392_ (.A_N(_102_),
    .B(_114_),
    .C(_030_),
    .D(_195_),
    .X(_115_));
 sky130_fd_sc_hd__a21oi_1 _393_ (.A1(_107_),
    .A2(_113_),
    .B1(_115_),
    .Y(_116_));
 sky130_fd_sc_hd__xnor2_1 _394_ (.A(_231_),
    .B(_195_),
    .Y(_117_));
 sky130_fd_sc_hd__and4_1 _395_ (.A(_016_),
    .B(_030_),
    .C(_196_),
    .D(_197_),
    .X(_118_));
 sky130_fd_sc_hd__nand2_1 _396_ (.A(_117_),
    .B(_118_),
    .Y(_119_));
 sky130_fd_sc_hd__and3_1 _397_ (.A(_107_),
    .B(_113_),
    .C(_115_),
    .X(_120_));
 sky130_fd_sc_hd__o21bai_1 _398_ (.A1(_116_),
    .A2(_119_),
    .B1_N(_120_),
    .Y(_121_));
 sky130_fd_sc_hd__and2_1 _399_ (.A(_108_),
    .B(_111_),
    .X(_122_));
 sky130_fd_sc_hd__a21o_1 _400_ (.A1(_112_),
    .A2(_121_),
    .B1(_122_),
    .X(_123_));
 sky130_fd_sc_hd__or3_1 _401_ (.A(_074_),
    .B(_066_),
    .C(_073_),
    .X(_124_));
 sky130_fd_sc_hd__and3_1 _402_ (.A(_091_),
    .B(_092_),
    .C(_093_),
    .X(_125_));
 sky130_fd_sc_hd__a31o_1 _403_ (.A1(_030_),
    .A2(_193_),
    .A3(_095_),
    .B1(_125_),
    .X(_126_));
 sky130_fd_sc_hd__o21ai_1 _404_ (.A1(_074_),
    .A2(_073_),
    .B1(_066_),
    .Y(_127_));
 sky130_fd_sc_hd__and3_2 _405_ (.A(_124_),
    .B(_126_),
    .C(_127_),
    .X(_128_));
 sky130_fd_sc_hd__a21o_1 _406_ (.A1(_124_),
    .A2(_127_),
    .B1(_126_),
    .X(_129_));
 sky130_fd_sc_hd__nor2b_2 _407_ (.A(_128_),
    .B_N(_129_),
    .Y(_130_));
 sky130_fd_sc_hd__xor2_2 _408_ (.A(_098_),
    .B(_130_),
    .X(_131_));
 sky130_fd_sc_hd__a21oi_1 _409_ (.A1(_058_),
    .A2(_076_),
    .B1(_075_),
    .Y(_132_));
 sky130_fd_sc_hd__nor2_2 _410_ (.A(_077_),
    .B(_132_),
    .Y(_133_));
 sky130_fd_sc_hd__xor2_1 _411_ (.A(_128_),
    .B(_133_),
    .X(_134_));
 sky130_fd_sc_hd__a21o_1 _412_ (.A1(_098_),
    .A2(_129_),
    .B1(_128_),
    .X(_135_));
 sky130_fd_sc_hd__and2_1 _413_ (.A(_133_),
    .B(_135_),
    .X(_136_));
 sky130_fd_sc_hd__a41o_1 _414_ (.A1(_100_),
    .A2(_123_),
    .A3(_131_),
    .A4(_134_),
    .B1(_136_),
    .X(_137_));
 sky130_fd_sc_hd__and2b_1 _415_ (.A_N(_065_),
    .B(_077_),
    .X(_138_));
 sky130_fd_sc_hd__a21oi_1 _416_ (.A1(_078_),
    .A2(_137_),
    .B1(_138_),
    .Y(_139_));
 sky130_fd_sc_hd__xnor2_2 _417_ (.A(_063_),
    .B(_139_),
    .Y(_140_));
 sky130_fd_sc_hd__inv_2 _418_ (.A(_131_),
    .Y(_141_));
 sky130_fd_sc_hd__xnor2_2 _419_ (.A(_128_),
    .B(_133_),
    .Y(_142_));
 sky130_fd_sc_hd__xnor2_1 _420_ (.A(_078_),
    .B(_137_),
    .Y(_143_));
 sky130_fd_sc_hd__xnor2_1 _421_ (.A(_108_),
    .B(_111_),
    .Y(_144_));
 sky130_fd_sc_hd__xnor2_1 _422_ (.A(_144_),
    .B(_121_),
    .Y(_145_));
 sky130_fd_sc_hd__or2_1 _423_ (.A(_120_),
    .B(_116_),
    .X(_146_));
 sky130_fd_sc_hd__nand2_1 _424_ (.A(_146_),
    .B(_119_),
    .Y(_147_));
 sky130_fd_sc_hd__o21a_1 _425_ (.A1(_146_),
    .A2(_119_),
    .B1(net9),
    .X(_148_));
 sky130_fd_sc_hd__and3_1 _426_ (.A(_145_),
    .B(_147_),
    .C(_148_),
    .X(_149_));
 sky130_fd_sc_hd__xor2_1 _427_ (.A(_100_),
    .B(_123_),
    .X(_150_));
 sky130_fd_sc_hd__nand2_2 _428_ (.A(_149_),
    .B(_150_),
    .Y(_151_));
 sky130_fd_sc_hd__nor4_1 _429_ (.A(_141_),
    .B(_142_),
    .C(_143_),
    .D(_151_),
    .Y(_152_));
 sky130_fd_sc_hd__or2_1 _430_ (.A(_038_),
    .B(_044_),
    .X(_153_));
 sky130_fd_sc_hd__nand2_1 _431_ (.A(_038_),
    .B(_044_),
    .Y(_154_));
 sky130_fd_sc_hd__o21a_1 _432_ (.A1(_060_),
    .A2(_138_),
    .B1(_062_),
    .X(_155_));
 sky130_fd_sc_hd__o211a_1 _433_ (.A1(_060_),
    .A2(_062_),
    .B1(_078_),
    .C1(_137_),
    .X(_156_));
 sky130_fd_sc_hd__a211o_1 _434_ (.A1(_153_),
    .A2(_154_),
    .B1(_155_),
    .C1(_156_),
    .X(_157_));
 sky130_fd_sc_hd__nand3_2 _435_ (.A(_140_),
    .B(net38),
    .C(_157_),
    .Y(_158_));
 sky130_fd_sc_hd__nand2_2 _436_ (.A(_049_),
    .B(_158_),
    .Y(_159_));
 sky130_fd_sc_hd__a21oi_2 _437_ (.A1(_140_),
    .A2(net38),
    .B1(_157_),
    .Y(_160_));
 sky130_fd_sc_hd__and2_1 _438_ (.A(_100_),
    .B(_123_),
    .X(_161_));
 sky130_fd_sc_hd__nor2_1 _439_ (.A(_161_),
    .B(_131_),
    .Y(_162_));
 sky130_fd_sc_hd__nand2_1 _440_ (.A(_161_),
    .B(_130_),
    .Y(_163_));
 sky130_fd_sc_hd__nand2_1 _441_ (.A(_098_),
    .B(_130_),
    .Y(_164_));
 sky130_fd_sc_hd__o211a_1 _442_ (.A1(_151_),
    .A2(_162_),
    .B1(_163_),
    .C1(_164_),
    .X(_165_));
 sky130_fd_sc_hd__xnor2_2 _443_ (.A(_142_),
    .B(_165_),
    .Y(_166_));
 sky130_fd_sc_hd__o31a_1 _444_ (.A1(_141_),
    .A2(_142_),
    .A3(_151_),
    .B1(_143_),
    .X(_167_));
 sky130_fd_sc_hd__mux2_1 _445_ (.A0(_167_),
    .A1(_152_),
    .S(_140_),
    .X(_168_));
 sky130_fd_sc_hd__o211ai_2 _446_ (.A1(_049_),
    .A2(_160_),
    .B1(_166_),
    .C1(_168_),
    .Y(_169_));
 sky130_fd_sc_hd__or3b_2 _447_ (.A(_152_),
    .B(_167_),
    .C_N(_140_),
    .X(_170_));
 sky130_fd_sc_hd__o311ai_4 _448_ (.A1(_160_),
    .A2(_166_),
    .A3(_170_),
    .B1(_158_),
    .C1(_049_),
    .Y(_171_));
 sky130_fd_sc_hd__a21oi_1 _449_ (.A1(_147_),
    .A2(_148_),
    .B1(_145_),
    .Y(_172_));
 sky130_fd_sc_hd__nor2_1 _450_ (.A(_149_),
    .B(_172_),
    .Y(_173_));
 sky130_fd_sc_hd__a22o_1 _451_ (.A1(_159_),
    .A2(_169_),
    .B1(_171_),
    .B2(_173_),
    .X(_174_));
 sky130_fd_sc_hd__a22o_1 _452_ (.A1(_191_),
    .A2(net40),
    .B1(_228_),
    .B2(_174_),
    .X(_001_));
 sky130_fd_sc_hd__or2_1 _453_ (.A(_149_),
    .B(_150_),
    .X(_175_));
 sky130_fd_sc_hd__a32o_1 _454_ (.A1(_151_),
    .A2(_171_),
    .A3(_175_),
    .B1(_159_),
    .B2(_169_),
    .X(_176_));
 sky130_fd_sc_hd__a22o_1 _455_ (.A1(_191_),
    .A2(net43),
    .B1(_228_),
    .B2(_176_),
    .X(_002_));
 sky130_fd_sc_hd__o21a_1 _456_ (.A1(_161_),
    .A2(_131_),
    .B1(_163_),
    .X(_177_));
 sky130_fd_sc_hd__xnor2_1 _457_ (.A(_151_),
    .B(_177_),
    .Y(_178_));
 sky130_fd_sc_hd__a22o_1 _458_ (.A1(_159_),
    .A2(_169_),
    .B1(_171_),
    .B2(_178_),
    .X(_179_));
 sky130_fd_sc_hd__a22o_1 _459_ (.A1(_191_),
    .A2(net44),
    .B1(_228_),
    .B2(_179_),
    .X(_003_));
 sky130_fd_sc_hd__inv_2 _460_ (.A(_159_),
    .Y(_180_));
 sky130_fd_sc_hd__a22o_1 _461_ (.A1(_191_),
    .A2(net42),
    .B1(_228_),
    .B2(_180_),
    .X(_004_));
 sky130_fd_sc_hd__and2_1 _462_ (.A(_191_),
    .B(net46),
    .X(_181_));
 sky130_fd_sc_hd__a31o_1 _463_ (.A1(_197_),
    .A2(_189_),
    .A3(_227_),
    .B1(_181_),
    .X(_005_));
 sky130_fd_sc_hd__and2_1 _464_ (.A(_191_),
    .B(net48),
    .X(_182_));
 sky130_fd_sc_hd__a31o_1 _465_ (.A1(_196_),
    .A2(_189_),
    .A3(_227_),
    .B1(_182_),
    .X(_006_));
 sky130_fd_sc_hd__and2_1 _466_ (.A(_191_),
    .B(net49),
    .X(_183_));
 sky130_fd_sc_hd__a31o_1 _467_ (.A1(_195_),
    .A2(_189_),
    .A3(_227_),
    .B1(_183_),
    .X(_007_));
 sky130_fd_sc_hd__and2_1 _468_ (.A(_191_),
    .B(net32),
    .X(_184_));
 sky130_fd_sc_hd__a31o_1 _469_ (.A1(net4),
    .A2(_189_),
    .A3(_227_),
    .B1(_184_),
    .X(_008_));
 sky130_fd_sc_hd__and2_1 _470_ (.A(_191_),
    .B(net50),
    .X(_185_));
 sky130_fd_sc_hd__a31o_1 _471_ (.A1(_194_),
    .A2(_189_),
    .A3(_227_),
    .B1(_185_),
    .X(_009_));
 sky130_fd_sc_hd__and2_1 _472_ (.A(_190_),
    .B(net51),
    .X(_186_));
 sky130_fd_sc_hd__a31o_1 _473_ (.A1(_193_),
    .A2(_189_),
    .A3(_227_),
    .B1(_186_),
    .X(_010_));
 sky130_fd_sc_hd__and2_1 _474_ (.A(_190_),
    .B(net47),
    .X(_187_));
 sky130_fd_sc_hd__a31o_1 _475_ (.A1(_192_),
    .A2(_189_),
    .A3(_227_),
    .B1(_187_),
    .X(_011_));
 sky130_fd_sc_hd__and2_1 _476_ (.A(_190_),
    .B(net45),
    .X(_188_));
 sky130_fd_sc_hd__a31o_1 _477_ (.A1(_200_),
    .A2(_189_),
    .A3(_227_),
    .B1(_188_),
    .X(_012_));
 sky130_fd_sc_hd__dfrtp_1 _478_ (.CLK(clknet_1_1__leaf_clk),
    .D(_000_),
    .RESET_B(net39),
    .Q(net28));
 sky130_fd_sc_hd__dfrtp_1 _479_ (.CLK(clknet_1_1__leaf_clk),
    .D(net23),
    .RESET_B(net39),
    .Q(net37));
 sky130_fd_sc_hd__dfrtp_1 _480_ (.CLK(clknet_1_1__leaf_clk),
    .D(_001_),
    .RESET_B(net39),
    .Q(net24));
 sky130_fd_sc_hd__dfrtp_1 _481_ (.CLK(clknet_1_1__leaf_clk),
    .D(_002_),
    .RESET_B(net39),
    .Q(net25));
 sky130_fd_sc_hd__dfrtp_1 _482_ (.CLK(clknet_1_1__leaf_clk),
    .D(_003_),
    .RESET_B(net39),
    .Q(net26));
 sky130_fd_sc_hd__dfrtp_1 _483_ (.CLK(clknet_1_1__leaf_clk),
    .D(_004_),
    .RESET_B(net39),
    .Q(net27));
 sky130_fd_sc_hd__dfrtp_1 _484_ (.CLK(clknet_1_0__leaf_clk),
    .D(_005_),
    .RESET_B(net39),
    .Q(net29));
 sky130_fd_sc_hd__dfrtp_1 _485_ (.CLK(clknet_1_0__leaf_clk),
    .D(_006_),
    .RESET_B(net10),
    .Q(net30));
 sky130_fd_sc_hd__dfrtp_1 _486_ (.CLK(clknet_1_0__leaf_clk),
    .D(_007_),
    .RESET_B(net10),
    .Q(net31));
 sky130_fd_sc_hd__dfrtp_1 _487_ (.CLK(clknet_1_1__leaf_clk),
    .D(_008_),
    .RESET_B(net10),
    .Q(net32));
 sky130_fd_sc_hd__dfrtp_1 _488_ (.CLK(clknet_1_0__leaf_clk),
    .D(_009_),
    .RESET_B(net10),
    .Q(net33));
 sky130_fd_sc_hd__dfrtp_1 _489_ (.CLK(clknet_1_0__leaf_clk),
    .D(_010_),
    .RESET_B(net39),
    .Q(net34));
 sky130_fd_sc_hd__dfrtp_1 _490_ (.CLK(clknet_1_0__leaf_clk),
    .D(_011_),
    .RESET_B(net39),
    .Q(net35));
 sky130_fd_sc_hd__dfrtp_1 _491_ (.CLK(clknet_1_0__leaf_clk),
    .D(_012_),
    .RESET_B(net39),
    .Q(net36));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_0_clk (.A(clk),
    .X(clknet_0_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_1_0__f_clk (.A(clknet_0_clk),
    .X(clknet_1_0__leaf_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_1_1__f_clk (.A(clknet_0_clk),
    .X(clknet_1_1__leaf_clk));
 sky130_fd_sc_hd__buf_4 fanout39 (.A(net10),
    .X(net39));
 sky130_fd_sc_hd__dlygate4sd3_1 hold1 (.A(net24),
    .X(net40));
 sky130_fd_sc_hd__dlygate4sd3_1 hold10 (.A(net31),
    .X(net49));
 sky130_fd_sc_hd__dlygate4sd3_1 hold11 (.A(net33),
    .X(net50));
 sky130_fd_sc_hd__dlygate4sd3_1 hold12 (.A(net34),
    .X(net51));
 sky130_fd_sc_hd__dlygate4sd3_1 hold2 (.A(net28),
    .X(net41));
 sky130_fd_sc_hd__dlygate4sd3_1 hold3 (.A(net27),
    .X(net42));
 sky130_fd_sc_hd__dlygate4sd3_1 hold4 (.A(net25),
    .X(net43));
 sky130_fd_sc_hd__dlygate4sd3_1 hold5 (.A(net26),
    .X(net44));
 sky130_fd_sc_hd__dlygate4sd3_1 hold6 (.A(net36),
    .X(net45));
 sky130_fd_sc_hd__dlygate4sd3_1 hold7 (.A(net29),
    .X(net46));
 sky130_fd_sc_hd__dlygate4sd3_1 hold8 (.A(net35),
    .X(net47));
 sky130_fd_sc_hd__dlygate4sd3_1 hold9 (.A(net30),
    .X(net48));
 sky130_fd_sc_hd__buf_1 input1 (.A(data_in[0]),
    .X(net1));
 sky130_fd_sc_hd__clkbuf_2 input10 (.A(rst_n),
    .X(net10));
 sky130_fd_sc_hd__dlymetal6s2s_1 input11 (.A(scale[0]),
    .X(net11));
 sky130_fd_sc_hd__clkbuf_2 input12 (.A(scale[1]),
    .X(net12));
 sky130_fd_sc_hd__buf_1 input13 (.A(scale[2]),
    .X(net13));
 sky130_fd_sc_hd__buf_2 input14 (.A(scale[3]),
    .X(net14));
 sky130_fd_sc_hd__buf_1 input15 (.A(threshold[0]),
    .X(net15));
 sky130_fd_sc_hd__buf_1 input16 (.A(threshold[1]),
    .X(net16));
 sky130_fd_sc_hd__buf_1 input17 (.A(threshold[2]),
    .X(net17));
 sky130_fd_sc_hd__buf_1 input18 (.A(threshold[3]),
    .X(net18));
 sky130_fd_sc_hd__buf_1 input19 (.A(threshold[4]),
    .X(net19));
 sky130_fd_sc_hd__dlymetal6s2s_1 input2 (.A(data_in[1]),
    .X(net2));
 sky130_fd_sc_hd__buf_1 input20 (.A(threshold[5]),
    .X(net20));
 sky130_fd_sc_hd__buf_1 input21 (.A(threshold[6]),
    .X(net21));
 sky130_fd_sc_hd__dlymetal6s2s_1 input22 (.A(threshold[7]),
    .X(net22));
 sky130_fd_sc_hd__buf_1 input23 (.A(valid_in),
    .X(net23));
 sky130_fd_sc_hd__clkbuf_2 input3 (.A(data_in[2]),
    .X(net3));
 sky130_fd_sc_hd__clkbuf_4 input4 (.A(data_in[3]),
    .X(net4));
 sky130_fd_sc_hd__buf_1 input5 (.A(data_in[4]),
    .X(net5));
 sky130_fd_sc_hd__clkbuf_1 input6 (.A(data_in[5]),
    .X(net6));
 sky130_fd_sc_hd__buf_1 input7 (.A(data_in[6]),
    .X(net7));
 sky130_fd_sc_hd__buf_2 input8 (.A(data_in[7]),
    .X(net8));
 sky130_fd_sc_hd__buf_1 input9 (.A(round_mode),
    .X(net9));
 sky130_fd_sc_hd__buf_1 max_cap38 (.A(_152_),
    .X(net38));
 sky130_fd_sc_hd__clkbuf_4 output24 (.A(net24),
    .X(int4_out[0]));
 sky130_fd_sc_hd__clkbuf_4 output25 (.A(net25),
    .X(int4_out[1]));
 sky130_fd_sc_hd__clkbuf_4 output26 (.A(net26),
    .X(int4_out[2]));
 sky130_fd_sc_hd__clkbuf_4 output27 (.A(net27),
    .X(int4_out[3]));
 sky130_fd_sc_hd__clkbuf_4 output28 (.A(net28),
    .X(is_outlier));
 sky130_fd_sc_hd__clkbuf_4 output29 (.A(net29),
    .X(sideband_out[0]));
 sky130_fd_sc_hd__buf_2 output30 (.A(net30),
    .X(sideband_out[1]));
 sky130_fd_sc_hd__clkbuf_4 output31 (.A(net31),
    .X(sideband_out[2]));
 sky130_fd_sc_hd__clkbuf_4 output32 (.A(net32),
    .X(sideband_out[3]));
 sky130_fd_sc_hd__buf_2 output33 (.A(net33),
    .X(sideband_out[4]));
 sky130_fd_sc_hd__clkbuf_4 output34 (.A(net34),
    .X(sideband_out[5]));
 sky130_fd_sc_hd__clkbuf_4 output35 (.A(net35),
    .X(sideband_out[6]));
 sky130_fd_sc_hd__clkbuf_4 output36 (.A(net36),
    .X(sideband_out[7]));
 sky130_fd_sc_hd__clkbuf_4 output37 (.A(net37),
    .X(valid_out));
endmodule

