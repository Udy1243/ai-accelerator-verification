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
 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire net7;
 wire net8;
 wire net9;
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
 wire net30;
 wire net31;
 wire net32;
 wire net33;
 wire net34;
 wire net35;
 wire net36;
 wire net37;
 wire clknet_0_clk;
 wire clknet_1_0__leaf_clk;
 wire clknet_1_1__leaf_clk;
 wire net38;
 wire net39;
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
 wire net50;

 sky130_fd_sc_hd__clkbuf_4 _219_ (.A(net22),
    .X(_168_));
 sky130_fd_sc_hd__inv_2 _220_ (.A(_168_),
    .Y(_169_));
 sky130_fd_sc_hd__buf_2 _221_ (.A(_169_),
    .X(_170_));
 sky130_fd_sc_hd__clkbuf_4 _222_ (.A(net3),
    .X(_171_));
 sky130_fd_sc_hd__clkbuf_4 _223_ (.A(net2),
    .X(_172_));
 sky130_fd_sc_hd__buf_2 _224_ (.A(net1),
    .X(_173_));
 sky130_fd_sc_hd__or4_1 _225_ (.A(net4),
    .B(_171_),
    .C(_172_),
    .D(_173_),
    .X(_174_));
 sky130_fd_sc_hd__or3_1 _226_ (.A(net6),
    .B(net5),
    .C(_174_),
    .X(_175_));
 sky130_fd_sc_hd__buf_2 _227_ (.A(net8),
    .X(_176_));
 sky130_fd_sc_hd__or3b_2 _228_ (.A(net7),
    .B(_175_),
    .C_N(_176_),
    .X(_177_));
 sky130_fd_sc_hd__nand2_1 _229_ (.A(_176_),
    .B(_175_),
    .Y(_178_));
 sky130_fd_sc_hd__xor2_1 _230_ (.A(net7),
    .B(_178_),
    .X(_179_));
 sky130_fd_sc_hd__and2_1 _231_ (.A(net20),
    .B(_179_),
    .X(_180_));
 sky130_fd_sc_hd__o21a_1 _232_ (.A1(net5),
    .A2(_174_),
    .B1(_176_),
    .X(_181_));
 sky130_fd_sc_hd__xnor2_1 _233_ (.A(net6),
    .B(_181_),
    .Y(_182_));
 sky130_fd_sc_hd__nand2_1 _234_ (.A(_176_),
    .B(_174_),
    .Y(_183_));
 sky130_fd_sc_hd__xor2_1 _235_ (.A(net5),
    .B(_183_),
    .X(_184_));
 sky130_fd_sc_hd__or2_1 _236_ (.A(net18),
    .B(_184_),
    .X(_185_));
 sky130_fd_sc_hd__o31a_1 _237_ (.A1(_171_),
    .A2(_172_),
    .A3(_173_),
    .B1(_176_),
    .X(_186_));
 sky130_fd_sc_hd__xnor2_1 _238_ (.A(net4),
    .B(_186_),
    .Y(_187_));
 sky130_fd_sc_hd__or2_1 _239_ (.A(net17),
    .B(_187_),
    .X(_188_));
 sky130_fd_sc_hd__o21a_1 _240_ (.A1(_172_),
    .A2(_173_),
    .B1(_176_),
    .X(_189_));
 sky130_fd_sc_hd__xnor2_1 _241_ (.A(_171_),
    .B(_189_),
    .Y(_190_));
 sky130_fd_sc_hd__or2_1 _242_ (.A(net16),
    .B(_190_),
    .X(_191_));
 sky130_fd_sc_hd__nand2_1 _243_ (.A(net8),
    .B(_173_),
    .Y(_192_));
 sky130_fd_sc_hd__xor2_1 _244_ (.A(_172_),
    .B(_192_),
    .X(_193_));
 sky130_fd_sc_hd__a21oi_1 _245_ (.A1(net15),
    .A2(_193_),
    .B1(net14),
    .Y(_194_));
 sky130_fd_sc_hd__o2bb2a_1 _246_ (.A1_N(_173_),
    .A2_N(_194_),
    .B1(_193_),
    .B2(net15),
    .X(_195_));
 sky130_fd_sc_hd__a21o_1 _247_ (.A1(net16),
    .A2(_190_),
    .B1(_195_),
    .X(_196_));
 sky130_fd_sc_hd__a22o_1 _248_ (.A1(net17),
    .A2(_187_),
    .B1(_191_),
    .B2(_196_),
    .X(_197_));
 sky130_fd_sc_hd__a22o_1 _249_ (.A1(net18),
    .A2(_184_),
    .B1(_188_),
    .B2(_197_),
    .X(_198_));
 sky130_fd_sc_hd__a22o_1 _250_ (.A1(net19),
    .A2(_182_),
    .B1(_185_),
    .B2(_198_),
    .X(_199_));
 sky130_fd_sc_hd__o221a_1 _251_ (.A1(net20),
    .A2(_179_),
    .B1(_182_),
    .B2(net19),
    .C1(_199_),
    .X(_200_));
 sky130_fd_sc_hd__o22a_1 _252_ (.A1(net21),
    .A2(_177_),
    .B1(_180_),
    .B2(_200_),
    .X(_201_));
 sky130_fd_sc_hd__a21oi_4 _253_ (.A1(net21),
    .A2(_177_),
    .B1(_201_),
    .Y(_202_));
 sky130_fd_sc_hd__nor2_1 _254_ (.A(_170_),
    .B(_202_),
    .Y(_203_));
 sky130_fd_sc_hd__o21ba_1 _255_ (.A1(net38),
    .A2(_168_),
    .B1_N(_203_),
    .X(_000_));
 sky130_fd_sc_hd__buf_2 _256_ (.A(net10),
    .X(_204_));
 sky130_fd_sc_hd__clkbuf_4 _257_ (.A(net13),
    .X(_205_));
 sky130_fd_sc_hd__buf_2 _258_ (.A(net12),
    .X(_206_));
 sky130_fd_sc_hd__nand4_1 _259_ (.A(_205_),
    .B(_206_),
    .C(net6),
    .D(net5),
    .Y(_207_));
 sky130_fd_sc_hd__buf_2 _260_ (.A(net11),
    .X(_208_));
 sky130_fd_sc_hd__a22o_1 _261_ (.A1(net12),
    .A2(net6),
    .B1(net5),
    .B2(_205_),
    .X(_209_));
 sky130_fd_sc_hd__nand4_1 _262_ (.A(_208_),
    .B(net7),
    .C(_207_),
    .D(_209_),
    .Y(_210_));
 sky130_fd_sc_hd__and2_1 _263_ (.A(_207_),
    .B(_210_),
    .X(_211_));
 sky130_fd_sc_hd__nand2_1 _264_ (.A(net8),
    .B(_208_),
    .Y(_212_));
 sky130_fd_sc_hd__and4_1 _265_ (.A(net13),
    .B(net12),
    .C(net7),
    .D(net6),
    .X(_213_));
 sky130_fd_sc_hd__a22o_1 _266_ (.A1(net12),
    .A2(net7),
    .B1(net6),
    .B2(net13),
    .X(_214_));
 sky130_fd_sc_hd__and2b_1 _267_ (.A_N(_213_),
    .B(_214_),
    .X(_215_));
 sky130_fd_sc_hd__xnor2_1 _268_ (.A(_212_),
    .B(_215_),
    .Y(_216_));
 sky130_fd_sc_hd__and2b_1 _269_ (.A_N(_211_),
    .B(_216_),
    .X(_217_));
 sky130_fd_sc_hd__xnor2_1 _270_ (.A(_216_),
    .B(_211_),
    .Y(_218_));
 sky130_fd_sc_hd__and3_1 _271_ (.A(_204_),
    .B(_176_),
    .C(_218_),
    .X(_013_));
 sky130_fd_sc_hd__nand2_2 _272_ (.A(net10),
    .B(net8),
    .Y(_014_));
 sky130_fd_sc_hd__a31o_1 _273_ (.A1(net8),
    .A2(_208_),
    .A3(_214_),
    .B1(_213_),
    .X(_015_));
 sky130_fd_sc_hd__nand2_1 _274_ (.A(_205_),
    .B(net7),
    .Y(_016_));
 sky130_fd_sc_hd__nand2_1 _275_ (.A(_206_),
    .B(_208_),
    .Y(_017_));
 sky130_fd_sc_hd__or2_1 _276_ (.A(_206_),
    .B(_208_),
    .X(_018_));
 sky130_fd_sc_hd__and3_1 _277_ (.A(net8),
    .B(_017_),
    .C(_018_),
    .X(_019_));
 sky130_fd_sc_hd__xnor2_1 _278_ (.A(_016_),
    .B(_019_),
    .Y(_020_));
 sky130_fd_sc_hd__and2_1 _279_ (.A(_015_),
    .B(_020_),
    .X(_021_));
 sky130_fd_sc_hd__nor2_1 _280_ (.A(_015_),
    .B(_020_),
    .Y(_022_));
 sky130_fd_sc_hd__nor2_1 _281_ (.A(_021_),
    .B(_022_),
    .Y(_023_));
 sky130_fd_sc_hd__xnor2_1 _282_ (.A(_014_),
    .B(_023_),
    .Y(_024_));
 sky130_fd_sc_hd__o21ai_2 _283_ (.A1(_217_),
    .A2(_013_),
    .B1(_024_),
    .Y(_025_));
 sky130_fd_sc_hd__or3_1 _284_ (.A(_024_),
    .B(_217_),
    .C(_013_),
    .X(_026_));
 sky130_fd_sc_hd__nand2_2 _285_ (.A(_025_),
    .B(_026_),
    .Y(_027_));
 sky130_fd_sc_hd__and2_1 _286_ (.A(net11),
    .B(net6),
    .X(_028_));
 sky130_fd_sc_hd__a22o_1 _287_ (.A1(_206_),
    .A2(net5),
    .B1(net4),
    .B2(_205_),
    .X(_029_));
 sky130_fd_sc_hd__nand4_2 _288_ (.A(_205_),
    .B(_206_),
    .C(net5),
    .D(net4),
    .Y(_030_));
 sky130_fd_sc_hd__a21bo_1 _289_ (.A1(_028_),
    .A2(_029_),
    .B1_N(_030_),
    .X(_031_));
 sky130_fd_sc_hd__a22o_1 _290_ (.A1(_208_),
    .A2(net7),
    .B1(_207_),
    .B2(_209_),
    .X(_032_));
 sky130_fd_sc_hd__nand3_1 _291_ (.A(_210_),
    .B(_031_),
    .C(_032_),
    .Y(_033_));
 sky130_fd_sc_hd__a21o_1 _292_ (.A1(_210_),
    .A2(_032_),
    .B1(_031_),
    .X(_034_));
 sky130_fd_sc_hd__nand3b_1 _293_ (.A_N(_014_),
    .B(_033_),
    .C(_034_),
    .Y(_035_));
 sky130_fd_sc_hd__and2_1 _294_ (.A(_033_),
    .B(_035_),
    .X(_036_));
 sky130_fd_sc_hd__a21oi_1 _295_ (.A1(_204_),
    .A2(_176_),
    .B1(_218_),
    .Y(_037_));
 sky130_fd_sc_hd__nor2_1 _296_ (.A(_013_),
    .B(_037_),
    .Y(_038_));
 sky130_fd_sc_hd__or2b_1 _297_ (.A(_036_),
    .B_N(_038_),
    .X(_039_));
 sky130_fd_sc_hd__xor2_1 _298_ (.A(_027_),
    .B(_039_),
    .X(_040_));
 sky130_fd_sc_hd__and2_1 _299_ (.A(net10),
    .B(net7),
    .X(_041_));
 sky130_fd_sc_hd__nand3_1 _300_ (.A(_028_),
    .B(_030_),
    .C(_029_),
    .Y(_042_));
 sky130_fd_sc_hd__a21o_1 _301_ (.A1(_030_),
    .A2(_029_),
    .B1(_028_),
    .X(_043_));
 sky130_fd_sc_hd__and2_1 _302_ (.A(net11),
    .B(net5),
    .X(_044_));
 sky130_fd_sc_hd__a22o_1 _303_ (.A1(_206_),
    .A2(net4),
    .B1(_171_),
    .B2(_205_),
    .X(_045_));
 sky130_fd_sc_hd__nand4_1 _304_ (.A(_205_),
    .B(_206_),
    .C(net4),
    .D(_171_),
    .Y(_046_));
 sky130_fd_sc_hd__a21bo_1 _305_ (.A1(_044_),
    .A2(_045_),
    .B1_N(_046_),
    .X(_047_));
 sky130_fd_sc_hd__a21o_1 _306_ (.A1(_042_),
    .A2(_043_),
    .B1(_047_),
    .X(_048_));
 sky130_fd_sc_hd__nand3_1 _307_ (.A(_047_),
    .B(_042_),
    .C(_043_),
    .Y(_049_));
 sky130_fd_sc_hd__a21bo_1 _308_ (.A1(_041_),
    .A2(_048_),
    .B1_N(_049_),
    .X(_050_));
 sky130_fd_sc_hd__a21bo_1 _309_ (.A1(_033_),
    .A2(_034_),
    .B1_N(_014_),
    .X(_051_));
 sky130_fd_sc_hd__and3_1 _310_ (.A(_050_),
    .B(_035_),
    .C(_051_),
    .X(_052_));
 sky130_fd_sc_hd__xnor2_1 _311_ (.A(_038_),
    .B(_036_),
    .Y(_053_));
 sky130_fd_sc_hd__or2_1 _312_ (.A(_052_),
    .B(_053_),
    .X(_054_));
 sky130_fd_sc_hd__nand3_1 _313_ (.A(_049_),
    .B(_041_),
    .C(_048_),
    .Y(_055_));
 sky130_fd_sc_hd__and2_1 _314_ (.A(net10),
    .B(net6),
    .X(_056_));
 sky130_fd_sc_hd__nand3_1 _315_ (.A(_046_),
    .B(_044_),
    .C(_045_),
    .Y(_057_));
 sky130_fd_sc_hd__a21o_1 _316_ (.A1(_046_),
    .A2(_045_),
    .B1(_044_),
    .X(_058_));
 sky130_fd_sc_hd__and2_1 _317_ (.A(net11),
    .B(net4),
    .X(_059_));
 sky130_fd_sc_hd__a22o_1 _318_ (.A1(net12),
    .A2(_171_),
    .B1(net2),
    .B2(net13),
    .X(_060_));
 sky130_fd_sc_hd__nand4_2 _319_ (.A(_205_),
    .B(_206_),
    .C(_171_),
    .D(_172_),
    .Y(_061_));
 sky130_fd_sc_hd__a21bo_1 _320_ (.A1(_059_),
    .A2(_060_),
    .B1_N(_061_),
    .X(_062_));
 sky130_fd_sc_hd__a21o_1 _321_ (.A1(_057_),
    .A2(_058_),
    .B1(_062_),
    .X(_063_));
 sky130_fd_sc_hd__nand3_1 _322_ (.A(_057_),
    .B(_062_),
    .C(_058_),
    .Y(_064_));
 sky130_fd_sc_hd__a21bo_1 _323_ (.A1(_056_),
    .A2(_063_),
    .B1_N(_064_),
    .X(_065_));
 sky130_fd_sc_hd__a21o_1 _324_ (.A1(_049_),
    .A2(_048_),
    .B1(_041_),
    .X(_066_));
 sky130_fd_sc_hd__and3_2 _325_ (.A(_055_),
    .B(_065_),
    .C(_066_),
    .X(_067_));
 sky130_fd_sc_hd__a21oi_1 _326_ (.A1(_055_),
    .A2(_066_),
    .B1(_065_),
    .Y(_068_));
 sky130_fd_sc_hd__nand3_1 _327_ (.A(_064_),
    .B(_056_),
    .C(_063_),
    .Y(_069_));
 sky130_fd_sc_hd__and2_1 _328_ (.A(net10),
    .B(net5),
    .X(_070_));
 sky130_fd_sc_hd__nand3_1 _329_ (.A(_061_),
    .B(_059_),
    .C(_060_),
    .Y(_071_));
 sky130_fd_sc_hd__a21o_1 _330_ (.A1(_061_),
    .A2(_060_),
    .B1(_059_),
    .X(_072_));
 sky130_fd_sc_hd__and2_1 _331_ (.A(net11),
    .B(net3),
    .X(_073_));
 sky130_fd_sc_hd__a22o_1 _332_ (.A1(net12),
    .A2(net2),
    .B1(net1),
    .B2(net13),
    .X(_074_));
 sky130_fd_sc_hd__nand4_2 _333_ (.A(net13),
    .B(net12),
    .C(net2),
    .D(net1),
    .Y(_075_));
 sky130_fd_sc_hd__a21bo_1 _334_ (.A1(_073_),
    .A2(_074_),
    .B1_N(_075_),
    .X(_076_));
 sky130_fd_sc_hd__a21o_1 _335_ (.A1(_071_),
    .A2(_072_),
    .B1(_076_),
    .X(_077_));
 sky130_fd_sc_hd__nand3_1 _336_ (.A(_071_),
    .B(_076_),
    .C(_072_),
    .Y(_078_));
 sky130_fd_sc_hd__a21bo_1 _337_ (.A1(_070_),
    .A2(_077_),
    .B1_N(_078_),
    .X(_079_));
 sky130_fd_sc_hd__a21o_1 _338_ (.A1(_064_),
    .A2(_063_),
    .B1(_056_),
    .X(_080_));
 sky130_fd_sc_hd__and3_1 _339_ (.A(_069_),
    .B(_079_),
    .C(_080_),
    .X(_081_));
 sky130_fd_sc_hd__nor3b_1 _340_ (.A(_067_),
    .B(_068_),
    .C_N(_081_),
    .Y(_082_));
 sky130_fd_sc_hd__o21ba_1 _341_ (.A1(_067_),
    .A2(_068_),
    .B1_N(_081_),
    .X(_083_));
 sky130_fd_sc_hd__nor2_1 _342_ (.A(_082_),
    .B(_083_),
    .Y(_084_));
 sky130_fd_sc_hd__a21oi_1 _343_ (.A1(_035_),
    .A2(_051_),
    .B1(_050_),
    .Y(_085_));
 sky130_fd_sc_hd__nor2_1 _344_ (.A(_052_),
    .B(_085_),
    .Y(_086_));
 sky130_fd_sc_hd__xor2_2 _345_ (.A(_067_),
    .B(_086_),
    .X(_087_));
 sky130_fd_sc_hd__nand3_1 _346_ (.A(_078_),
    .B(_070_),
    .C(_077_),
    .Y(_088_));
 sky130_fd_sc_hd__nand3_1 _347_ (.A(_075_),
    .B(_073_),
    .C(_074_),
    .Y(_089_));
 sky130_fd_sc_hd__a21o_1 _348_ (.A1(_075_),
    .A2(_074_),
    .B1(_073_),
    .X(_090_));
 sky130_fd_sc_hd__and4_1 _349_ (.A(_206_),
    .B(_208_),
    .C(_172_),
    .D(net1),
    .X(_091_));
 sky130_fd_sc_hd__a21o_1 _350_ (.A1(_089_),
    .A2(_090_),
    .B1(_091_),
    .X(_092_));
 sky130_fd_sc_hd__and3_1 _351_ (.A(_089_),
    .B(_090_),
    .C(_091_),
    .X(_093_));
 sky130_fd_sc_hd__a31o_1 _352_ (.A1(_204_),
    .A2(net4),
    .A3(_092_),
    .B1(_093_),
    .X(_094_));
 sky130_fd_sc_hd__a21o_1 _353_ (.A1(_078_),
    .A2(_077_),
    .B1(_070_),
    .X(_095_));
 sky130_fd_sc_hd__and3_1 _354_ (.A(_088_),
    .B(_094_),
    .C(_095_),
    .X(_096_));
 sky130_fd_sc_hd__a21oi_1 _355_ (.A1(_088_),
    .A2(_095_),
    .B1(_094_),
    .Y(_097_));
 sky130_fd_sc_hd__inv_2 _356_ (.A(_091_),
    .Y(_098_));
 sky130_fd_sc_hd__a22o_1 _357_ (.A1(_208_),
    .A2(_172_),
    .B1(_173_),
    .B2(_206_),
    .X(_099_));
 sky130_fd_sc_hd__and4_1 _358_ (.A(_204_),
    .B(_171_),
    .C(_098_),
    .D(_099_),
    .X(_100_));
 sky130_fd_sc_hd__nand2_1 _359_ (.A(_204_),
    .B(net4),
    .Y(_101_));
 sky130_fd_sc_hd__and2b_1 _360_ (.A_N(_093_),
    .B(_092_),
    .X(_102_));
 sky130_fd_sc_hd__xnor2_2 _361_ (.A(_101_),
    .B(_102_),
    .Y(_103_));
 sky130_fd_sc_hd__and4bb_1 _362_ (.A_N(_096_),
    .B_N(_097_),
    .C(_100_),
    .D(_103_),
    .X(_104_));
 sky130_fd_sc_hd__o2bb2a_1 _363_ (.A1_N(_100_),
    .A2_N(_103_),
    .B1(_096_),
    .B2(_097_),
    .X(_105_));
 sky130_fd_sc_hd__nor2_1 _364_ (.A(_104_),
    .B(_105_),
    .Y(_106_));
 sky130_fd_sc_hd__a21oi_1 _365_ (.A1(_069_),
    .A2(_080_),
    .B1(_079_),
    .Y(_107_));
 sky130_fd_sc_hd__nor2_1 _366_ (.A(_081_),
    .B(_107_),
    .Y(_108_));
 sky130_fd_sc_hd__xor2_2 _367_ (.A(_096_),
    .B(_108_),
    .X(_109_));
 sky130_fd_sc_hd__and4_1 _368_ (.A(_084_),
    .B(_087_),
    .C(_106_),
    .D(_109_),
    .X(_110_));
 sky130_fd_sc_hd__inv_2 _369_ (.A(_100_),
    .Y(_111_));
 sky130_fd_sc_hd__a22o_1 _370_ (.A1(_204_),
    .A2(_171_),
    .B1(_098_),
    .B2(_099_),
    .X(_112_));
 sky130_fd_sc_hd__and4_1 _371_ (.A(_204_),
    .B(_208_),
    .C(_172_),
    .D(_173_),
    .X(_113_));
 sky130_fd_sc_hd__and3_1 _372_ (.A(_111_),
    .B(_112_),
    .C(_113_),
    .X(_114_));
 sky130_fd_sc_hd__and2_1 _373_ (.A(_103_),
    .B(_114_),
    .X(_115_));
 sky130_fd_sc_hd__o21a_1 _374_ (.A1(_096_),
    .A2(_104_),
    .B1(_108_),
    .X(_116_));
 sky130_fd_sc_hd__o21a_1 _375_ (.A1(_067_),
    .A2(_082_),
    .B1(_086_),
    .X(_117_));
 sky130_fd_sc_hd__a31o_1 _376_ (.A1(_084_),
    .A2(_087_),
    .A3(_116_),
    .B1(_117_),
    .X(_118_));
 sky130_fd_sc_hd__a21o_1 _377_ (.A1(_110_),
    .A2(_115_),
    .B1(_118_),
    .X(_119_));
 sky130_fd_sc_hd__and2_1 _378_ (.A(_052_),
    .B(_053_),
    .X(_120_));
 sky130_fd_sc_hd__a21oi_1 _379_ (.A1(_054_),
    .A2(_119_),
    .B1(_120_),
    .Y(_121_));
 sky130_fd_sc_hd__mux2_1 _380_ (.A0(_027_),
    .A1(_040_),
    .S(_121_),
    .X(_122_));
 sky130_fd_sc_hd__nand2_1 _381_ (.A(net7),
    .B(_017_),
    .Y(_123_));
 sky130_fd_sc_hd__o21ai_1 _382_ (.A1(_205_),
    .A2(_018_),
    .B1(_176_),
    .Y(_124_));
 sky130_fd_sc_hd__a31o_1 _383_ (.A1(_205_),
    .A2(_018_),
    .A3(_123_),
    .B1(_124_),
    .X(_125_));
 sky130_fd_sc_hd__mux2_1 _384_ (.A0(_204_),
    .A1(_014_),
    .S(_125_),
    .X(_126_));
 sky130_fd_sc_hd__nand2_1 _385_ (.A(_015_),
    .B(_020_),
    .Y(_127_));
 sky130_fd_sc_hd__o21ai_1 _386_ (.A1(_014_),
    .A2(_022_),
    .B1(_127_),
    .Y(_128_));
 sky130_fd_sc_hd__mux2_1 _387_ (.A0(_127_),
    .A1(_128_),
    .S(_025_),
    .X(_129_));
 sky130_fd_sc_hd__nand2_1 _388_ (.A(_126_),
    .B(_129_),
    .Y(_130_));
 sky130_fd_sc_hd__o22a_1 _389_ (.A1(_027_),
    .A2(_039_),
    .B1(_126_),
    .B2(_129_),
    .X(_131_));
 sky130_fd_sc_hd__o211ai_2 _390_ (.A1(_027_),
    .A2(_121_),
    .B1(_130_),
    .C1(_131_),
    .Y(_132_));
 sky130_fd_sc_hd__or2b_1 _391_ (.A(_120_),
    .B_N(_054_),
    .X(_133_));
 sky130_fd_sc_hd__xnor2_1 _392_ (.A(_133_),
    .B(_119_),
    .Y(_134_));
 sky130_fd_sc_hd__nor2_1 _393_ (.A(_100_),
    .B(_114_),
    .Y(_135_));
 sky130_fd_sc_hd__xnor2_1 _394_ (.A(_103_),
    .B(_135_),
    .Y(_136_));
 sky130_fd_sc_hd__and3_1 _395_ (.A(_110_),
    .B(_134_),
    .C(_136_),
    .X(_137_));
 sky130_fd_sc_hd__and2_1 _396_ (.A(_014_),
    .B(_124_),
    .X(_138_));
 sky130_fd_sc_hd__a31o_1 _397_ (.A1(_122_),
    .A2(_132_),
    .A3(_137_),
    .B1(_138_),
    .X(_139_));
 sky130_fd_sc_hd__inv_2 _398_ (.A(_109_),
    .Y(_140_));
 sky130_fd_sc_hd__inv_2 _399_ (.A(_084_),
    .Y(_141_));
 sky130_fd_sc_hd__inv_2 _400_ (.A(_115_),
    .Y(_142_));
 sky130_fd_sc_hd__o221a_1 _401_ (.A1(_104_),
    .A2(_140_),
    .B1(_116_),
    .B2(_141_),
    .C1(_142_),
    .X(_143_));
 sky130_fd_sc_hd__nor2_1 _402_ (.A(_106_),
    .B(_143_),
    .Y(_144_));
 sky130_fd_sc_hd__and2b_1 _403_ (.A_N(_082_),
    .B(_087_),
    .X(_145_));
 sky130_fd_sc_hd__o21a_1 _404_ (.A1(_116_),
    .A2(_145_),
    .B1(_141_),
    .X(_146_));
 sky130_fd_sc_hd__o21ai_1 _405_ (.A1(_141_),
    .A2(_142_),
    .B1(_106_),
    .Y(_147_));
 sky130_fd_sc_hd__o21ba_1 _406_ (.A1(_083_),
    .A2(_087_),
    .B1_N(_136_),
    .X(_148_));
 sky130_fd_sc_hd__o211a_1 _407_ (.A1(_105_),
    .A2(_109_),
    .B1(_147_),
    .C1(_148_),
    .X(_149_));
 sky130_fd_sc_hd__or4b_1 _408_ (.A(_134_),
    .B(_144_),
    .C(_146_),
    .D_N(_149_),
    .X(_150_));
 sky130_fd_sc_hd__o31a_1 _409_ (.A1(_122_),
    .A2(_132_),
    .A3(_150_),
    .B1(_138_),
    .X(_151_));
 sky130_fd_sc_hd__a31o_1 _410_ (.A1(_204_),
    .A2(_173_),
    .A3(_139_),
    .B1(_151_),
    .X(_152_));
 sky130_fd_sc_hd__a22o_1 _411_ (.A1(_170_),
    .A2(net39),
    .B1(_203_),
    .B2(_152_),
    .X(_001_));
 sky130_fd_sc_hd__inv_2 _412_ (.A(_113_),
    .Y(_153_));
 sky130_fd_sc_hd__a22o_1 _413_ (.A1(_204_),
    .A2(_172_),
    .B1(_173_),
    .B2(_208_),
    .X(_154_));
 sky130_fd_sc_hd__a31o_1 _414_ (.A1(_153_),
    .A2(_139_),
    .A3(_154_),
    .B1(_151_),
    .X(_155_));
 sky130_fd_sc_hd__a22o_1 _415_ (.A1(_170_),
    .A2(net41),
    .B1(_203_),
    .B2(_155_),
    .X(_002_));
 sky130_fd_sc_hd__inv_2 _416_ (.A(_114_),
    .Y(_156_));
 sky130_fd_sc_hd__a21o_1 _417_ (.A1(_111_),
    .A2(_112_),
    .B1(_113_),
    .X(_157_));
 sky130_fd_sc_hd__a31o_1 _418_ (.A1(_156_),
    .A2(_139_),
    .A3(_157_),
    .B1(_151_),
    .X(_158_));
 sky130_fd_sc_hd__a22o_1 _419_ (.A1(_170_),
    .A2(net42),
    .B1(_203_),
    .B2(_158_),
    .X(_003_));
 sky130_fd_sc_hd__or3_1 _420_ (.A(_169_),
    .B(_202_),
    .C(_138_),
    .X(_159_));
 sky130_fd_sc_hd__a21bo_1 _421_ (.A1(_170_),
    .A2(net40),
    .B1_N(_159_),
    .X(_004_));
 sky130_fd_sc_hd__and2_1 _422_ (.A(_170_),
    .B(net45),
    .X(_160_));
 sky130_fd_sc_hd__a31o_1 _423_ (.A1(_173_),
    .A2(_168_),
    .A3(_202_),
    .B1(_160_),
    .X(_005_));
 sky130_fd_sc_hd__and2_1 _424_ (.A(_170_),
    .B(net43),
    .X(_161_));
 sky130_fd_sc_hd__a31o_1 _425_ (.A1(_172_),
    .A2(_168_),
    .A3(_202_),
    .B1(_161_),
    .X(_006_));
 sky130_fd_sc_hd__and2_1 _426_ (.A(_170_),
    .B(net48),
    .X(_162_));
 sky130_fd_sc_hd__a31o_1 _427_ (.A1(_171_),
    .A2(_168_),
    .A3(_202_),
    .B1(_162_),
    .X(_007_));
 sky130_fd_sc_hd__and2_1 _428_ (.A(_170_),
    .B(net50),
    .X(_163_));
 sky130_fd_sc_hd__a31o_1 _429_ (.A1(net4),
    .A2(_168_),
    .A3(_202_),
    .B1(_163_),
    .X(_008_));
 sky130_fd_sc_hd__and2_1 _430_ (.A(_170_),
    .B(net47),
    .X(_164_));
 sky130_fd_sc_hd__a31o_1 _431_ (.A1(net5),
    .A2(_168_),
    .A3(_202_),
    .B1(_164_),
    .X(_009_));
 sky130_fd_sc_hd__and2_1 _432_ (.A(_169_),
    .B(net49),
    .X(_165_));
 sky130_fd_sc_hd__a31o_1 _433_ (.A1(net6),
    .A2(_168_),
    .A3(_202_),
    .B1(_165_),
    .X(_010_));
 sky130_fd_sc_hd__and2_1 _434_ (.A(_169_),
    .B(net46),
    .X(_166_));
 sky130_fd_sc_hd__a31o_1 _435_ (.A1(net7),
    .A2(_168_),
    .A3(_202_),
    .B1(_166_),
    .X(_011_));
 sky130_fd_sc_hd__and2_1 _436_ (.A(_169_),
    .B(net44),
    .X(_167_));
 sky130_fd_sc_hd__a31o_1 _437_ (.A1(_176_),
    .A2(_168_),
    .A3(_202_),
    .B1(_167_),
    .X(_012_));
 sky130_fd_sc_hd__dfrtp_1 _438_ (.CLK(clknet_1_0__leaf_clk),
    .D(_000_),
    .RESET_B(net37),
    .Q(net27));
 sky130_fd_sc_hd__dfrtp_1 _439_ (.CLK(clknet_1_1__leaf_clk),
    .D(net22),
    .RESET_B(net37),
    .Q(net36));
 sky130_fd_sc_hd__dfrtp_1 _440_ (.CLK(clknet_1_0__leaf_clk),
    .D(_001_),
    .RESET_B(net37),
    .Q(net23));
 sky130_fd_sc_hd__dfrtp_1 _441_ (.CLK(clknet_1_1__leaf_clk),
    .D(_002_),
    .RESET_B(net37),
    .Q(net24));
 sky130_fd_sc_hd__dfrtp_1 _442_ (.CLK(clknet_1_0__leaf_clk),
    .D(_003_),
    .RESET_B(net37),
    .Q(net25));
 sky130_fd_sc_hd__dfrtp_1 _443_ (.CLK(clknet_1_0__leaf_clk),
    .D(_004_),
    .RESET_B(net37),
    .Q(net26));
 sky130_fd_sc_hd__dfrtp_1 _444_ (.CLK(clknet_1_0__leaf_clk),
    .D(_005_),
    .RESET_B(net37),
    .Q(net28));
 sky130_fd_sc_hd__dfrtp_1 _445_ (.CLK(clknet_1_1__leaf_clk),
    .D(_006_),
    .RESET_B(net9),
    .Q(net29));
 sky130_fd_sc_hd__dfrtp_1 _446_ (.CLK(clknet_1_1__leaf_clk),
    .D(_007_),
    .RESET_B(net9),
    .Q(net30));
 sky130_fd_sc_hd__dfrtp_1 _447_ (.CLK(clknet_1_1__leaf_clk),
    .D(_008_),
    .RESET_B(net9),
    .Q(net31));
 sky130_fd_sc_hd__dfrtp_1 _448_ (.CLK(clknet_1_1__leaf_clk),
    .D(_009_),
    .RESET_B(net9),
    .Q(net32));
 sky130_fd_sc_hd__dfrtp_1 _449_ (.CLK(clknet_1_0__leaf_clk),
    .D(_010_),
    .RESET_B(net37),
    .Q(net33));
 sky130_fd_sc_hd__dfrtp_1 _450_ (.CLK(clknet_1_0__leaf_clk),
    .D(_011_),
    .RESET_B(net37),
    .Q(net34));
 sky130_fd_sc_hd__dfrtp_1 _451_ (.CLK(clknet_1_0__leaf_clk),
    .D(_012_),
    .RESET_B(net37),
    .Q(net35));
 sky130_fd_sc_hd__decap_3 PHY_0 ();
 sky130_fd_sc_hd__decap_3 PHY_1 ();
 sky130_fd_sc_hd__decap_3 PHY_2 ();
 sky130_fd_sc_hd__decap_3 PHY_3 ();
 sky130_fd_sc_hd__decap_3 PHY_4 ();
 sky130_fd_sc_hd__decap_3 PHY_5 ();
 sky130_fd_sc_hd__decap_3 PHY_6 ();
 sky130_fd_sc_hd__decap_3 PHY_7 ();
 sky130_fd_sc_hd__decap_3 PHY_8 ();
 sky130_fd_sc_hd__decap_3 PHY_9 ();
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
 sky130_fd_sc_hd__decap_3 PHY_50 ();
 sky130_fd_sc_hd__decap_3 PHY_51 ();
 sky130_fd_sc_hd__decap_3 PHY_52 ();
 sky130_fd_sc_hd__decap_3 PHY_53 ();
 sky130_fd_sc_hd__decap_3 PHY_54 ();
 sky130_fd_sc_hd__decap_3 PHY_55 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_56 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_57 ();
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
 sky130_fd_sc_hd__clkbuf_2 input1 (.A(data_in[0]),
    .X(net1));
 sky130_fd_sc_hd__buf_1 input2 (.A(data_in[1]),
    .X(net2));
 sky130_fd_sc_hd__buf_1 input3 (.A(data_in[2]),
    .X(net3));
 sky130_fd_sc_hd__clkbuf_4 input4 (.A(data_in[3]),
    .X(net4));
 sky130_fd_sc_hd__clkbuf_4 input5 (.A(data_in[4]),
    .X(net5));
 sky130_fd_sc_hd__buf_2 input6 (.A(data_in[5]),
    .X(net6));
 sky130_fd_sc_hd__clkbuf_4 input7 (.A(data_in[6]),
    .X(net7));
 sky130_fd_sc_hd__clkbuf_2 input8 (.A(data_in[7]),
    .X(net8));
 sky130_fd_sc_hd__clkbuf_2 input9 (.A(rst_n),
    .X(net9));
 sky130_fd_sc_hd__clkbuf_2 input10 (.A(scale[0]),
    .X(net10));
 sky130_fd_sc_hd__dlymetal6s2s_1 input11 (.A(scale[1]),
    .X(net11));
 sky130_fd_sc_hd__clkbuf_2 input12 (.A(scale[2]),
    .X(net12));
 sky130_fd_sc_hd__clkbuf_2 input13 (.A(scale[3]),
    .X(net13));
 sky130_fd_sc_hd__clkbuf_1 input14 (.A(threshold[0]),
    .X(net14));
 sky130_fd_sc_hd__buf_1 input15 (.A(threshold[1]),
    .X(net15));
 sky130_fd_sc_hd__buf_1 input16 (.A(threshold[2]),
    .X(net16));
 sky130_fd_sc_hd__buf_1 input17 (.A(threshold[3]),
    .X(net17));
 sky130_fd_sc_hd__buf_1 input18 (.A(threshold[4]),
    .X(net18));
 sky130_fd_sc_hd__buf_1 input19 (.A(threshold[5]),
    .X(net19));
 sky130_fd_sc_hd__clkbuf_1 input20 (.A(threshold[6]),
    .X(net20));
 sky130_fd_sc_hd__dlymetal6s2s_1 input21 (.A(threshold[7]),
    .X(net21));
 sky130_fd_sc_hd__buf_1 input22 (.A(valid_in),
    .X(net22));
 sky130_fd_sc_hd__clkbuf_4 output23 (.A(net23),
    .X(int4_out[0]));
 sky130_fd_sc_hd__clkbuf_4 output24 (.A(net24),
    .X(int4_out[1]));
 sky130_fd_sc_hd__clkbuf_4 output25 (.A(net25),
    .X(int4_out[2]));
 sky130_fd_sc_hd__clkbuf_4 output26 (.A(net26),
    .X(int4_out[3]));
 sky130_fd_sc_hd__clkbuf_4 output27 (.A(net27),
    .X(is_outlier));
 sky130_fd_sc_hd__clkbuf_4 output28 (.A(net28),
    .X(sideband_out[0]));
 sky130_fd_sc_hd__buf_2 output29 (.A(net29),
    .X(sideband_out[1]));
 sky130_fd_sc_hd__clkbuf_4 output30 (.A(net30),
    .X(sideband_out[2]));
 sky130_fd_sc_hd__buf_2 output31 (.A(net31),
    .X(sideband_out[3]));
 sky130_fd_sc_hd__buf_2 output32 (.A(net32),
    .X(sideband_out[4]));
 sky130_fd_sc_hd__clkbuf_4 output33 (.A(net33),
    .X(sideband_out[5]));
 sky130_fd_sc_hd__clkbuf_4 output34 (.A(net34),
    .X(sideband_out[6]));
 sky130_fd_sc_hd__clkbuf_4 output35 (.A(net35),
    .X(sideband_out[7]));
 sky130_fd_sc_hd__clkbuf_4 output36 (.A(net36),
    .X(valid_out));
 sky130_fd_sc_hd__buf_4 fanout37 (.A(net9),
    .X(net37));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_0_clk (.A(clk),
    .X(clknet_0_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_1_0__f_clk (.A(clknet_0_clk),
    .X(clknet_1_0__leaf_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_1_1__f_clk (.A(clknet_0_clk),
    .X(clknet_1_1__leaf_clk));
 sky130_fd_sc_hd__dlygate4sd3_1 hold1 (.A(net27),
    .X(net38));
 sky130_fd_sc_hd__dlygate4sd3_1 hold2 (.A(net23),
    .X(net39));
 sky130_fd_sc_hd__dlygate4sd3_1 hold3 (.A(net26),
    .X(net40));
 sky130_fd_sc_hd__dlygate4sd3_1 hold4 (.A(net24),
    .X(net41));
 sky130_fd_sc_hd__dlygate4sd3_1 hold5 (.A(net25),
    .X(net42));
 sky130_fd_sc_hd__dlygate4sd3_1 hold6 (.A(net29),
    .X(net43));
 sky130_fd_sc_hd__dlygate4sd3_1 hold7 (.A(net35),
    .X(net44));
 sky130_fd_sc_hd__dlygate4sd3_1 hold8 (.A(net28),
    .X(net45));
 sky130_fd_sc_hd__dlygate4sd3_1 hold9 (.A(net34),
    .X(net46));
 sky130_fd_sc_hd__dlygate4sd3_1 hold10 (.A(net32),
    .X(net47));
 sky130_fd_sc_hd__dlygate4sd3_1 hold11 (.A(net30),
    .X(net48));
 sky130_fd_sc_hd__dlygate4sd3_1 hold12 (.A(net33),
    .X(net49));
 sky130_fd_sc_hd__dlygate4sd3_1 hold13 (.A(net31),
    .X(net50));
endmodule
