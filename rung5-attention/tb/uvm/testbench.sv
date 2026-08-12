// Code your testbench here
// or browse Examples
`timescale 1ns/1ns
import uvm_pkg::*;
`include "uvm_macros.svh"

// ─────────────────────────────────────────
// Interface
// ─────────────────────────────────────────
interface attention_if #(
    parameter int SEQ_LEN    = 8,
    parameter int D_K        = 16,
    parameter int DATA_WIDTH = 8
)(input logic clk);

    logic                      rst_n;

    // load bus (driver drives these during the 24-cycle load phase)
    logic [D_K*DATA_WIDTH-1:0] row_data;
    logic [2:0]                row_addr;
    logic [1:0]                matrix_sel;
    logic                      load_valid;
    logic                      start;

    // streamed output (DUT drives these during the 8-cycle output phase)
    logic signed [D_K*DATA_WIDTH-1:0] out_row_data;
    logic                             out_valid;
    logic                             out_tlast;

    // driver only ever writes the load bus and reads out_tlast (to know
    // when phase 3 is over) -- it never needs out_row_data, that's the
    // monitor's job
    clocking driver_cb @(posedge clk);
        default input #1step output #1;
        output row_data, row_addr, matrix_sel, load_valid, start, rst_n;
        input  out_tlast;
    endclocking

    // monitor needs everything -- the load bus (to reconstruct Q/K/V over
    // 24 cycles), start (to know when compute begins), and the full output
    // stream (to reconstruct the 8x16 result)
    clocking monitor_cb @(posedge clk);
        default input #1step;
        input row_data, row_addr, matrix_sel, load_valid, start,
              out_row_data, out_valid, out_tlast;
    endclocking

endinterface

// ─────────────────────────────────────────
// Sequence Item
// ─────────────────────────────────────────
class attention_seq_item extends uvm_sequence_item;
    `uvm_object_utils(attention_seq_item)

    parameter int SEQ_LEN     = 8;
    parameter int D_K         = 16;
    parameter int DATA_WIDTH  = 8;
    parameter int WEIGHT_WIDTH = 8;
    parameter int SCORE_WIDTH  = 18;  // ACCUM_WIDTH(20) - 2, matches attention.sv

    rand logic signed [DATA_WIDTH-1:0] q [SEQ_LEN-1:0][D_K-1:0];
    rand logic signed [DATA_WIDTH-1:0] k [SEQ_LEN-1:0][D_K-1:0];
    rand logic signed [DATA_WIDTH-1:0] v [SEQ_LEN-1:0][D_K-1:0];

    // biased so a meaningful fraction of transactions guarantee a
    // non-degenerate softmax (k[1]==k[0] ties Q[i].K[0] with Q[i].K[1]
    // for every Q row at once, regardless of what Q or the rest of K are)
    // instead of leaving the ~64% hard-argmax collapse rate (see CLAUDE.md)
    // as the only outcome constrained-random ever explores
    rand bit force_tie;
    constraint c_force_tie_dist { force_tie dist {1'b1 :/ 20, 1'b0 :/ 80}; }
    constraint c_force_tie       { if (force_tie) k[1] == k[0]; }

    // outputs captured for checking
    logic signed [DATA_WIDTH-1:0] exp_out [SEQ_LEN-1:0][D_K-1:0];
    logic signed [DATA_WIDTH-1:0] act_out [SEQ_LEN-1:0][D_K-1:0];

    // exposed (not just a compute_expected() local) so the coverage
    // collector can inspect what the golden model actually computed --
    // e.g. whether any row's softmax stayed smooth (>1 nonzero weight)
    // vs collapsed to hard argmax (one weight=255, rest 0)
    logic [WEIGHT_WIDTH-1:0] exp_weights [SEQ_LEN-1:0][SEQ_LEN-1:0];

    // behavioral coverage flags -- computed facts about what this
    // transaction's golden model actually produced, not stimulus knobs
    // (same "applied vs not_applied" shape as Rung 4's round_applied)
    logic softmax_smooth;  // any row had >1 nonzero weight (not hard argmax)
    logic weight_clipped;  // any row's normalization pre-clip value exceeded 255
    logic out_rail_hit;    // any output element hit OUT_MIN or OUT_MAX

    function new(string name = "attention_seq_item");
        super.new(name);
    endfunction

    localparam int RECIP_SHIFT = 27;
    localparam int RECIP_WIDTH = 20;

    // get_exp_val/get_recip mirror softmax.sv's own functions exactly --
    // regenerated from tb/gen_exp_lut.py / tb/gen_recip_lut.py (the same
    // scripts that generated softmax.sv's tables) rather than hand-copied,
    // so there is one source of truth for the LUT formula, not two
    function automatic logic [WEIGHT_WIDTH-1:0] get_exp_val(input logic signed [SCORE_WIDTH:0] shift_val);
        logic signed [SCORE_WIDTH:0] idx;
        idx = (-shift_val) >>> 4;
        case (idx)
            0: get_exp_val = 8'd255;
            1: get_exp_val = 8'd240;
            2: get_exp_val = 8'd225;
            3: get_exp_val = 8'd211;
            4: get_exp_val = 8'd199;
            5: get_exp_val = 8'd187;
            6: get_exp_val = 8'd175;
            7: get_exp_val = 8'd165;
            8: get_exp_val = 8'd155;
            9: get_exp_val = 8'd145;
            10: get_exp_val = 8'd136;
            11: get_exp_val = 8'd128;
            12: get_exp_val = 8'd120;
            13: get_exp_val = 8'd113;
            14: get_exp_val = 8'd106;
            15: get_exp_val = 8'd100;
            16: get_exp_val = 8'd94;
            17: get_exp_val = 8'd88;
            18: get_exp_val = 8'd83;
            19: get_exp_val = 8'd78;
            20: get_exp_val = 8'd73;
            21: get_exp_val = 8'd69;
            22: get_exp_val = 8'd64;
            23: get_exp_val = 8'd61;
            24: get_exp_val = 8'd57;
            25: get_exp_val = 8'd53;
            26: get_exp_val = 8'd50;
            27: get_exp_val = 8'd47;
            28: get_exp_val = 8'd44;
            29: get_exp_val = 8'd42;
            30: get_exp_val = 8'd39;
            31: get_exp_val = 8'd37;
            32: get_exp_val = 8'd35;
            33: get_exp_val = 8'd32;
            34: get_exp_val = 8'd30;
            35: get_exp_val = 8'd29;
            36: get_exp_val = 8'd27;
            37: get_exp_val = 8'd25;
            38: get_exp_val = 8'd24;
            39: get_exp_val = 8'd22;
            40: get_exp_val = 8'd21;
            41: get_exp_val = 8'd20;
            42: get_exp_val = 8'd18;
            43: get_exp_val = 8'd17;
            44: get_exp_val = 8'd16;
            45: get_exp_val = 8'd15;
            46: get_exp_val = 8'd14;
            47: get_exp_val = 8'd14;
            48: get_exp_val = 8'd13;
            49: get_exp_val = 8'd12;
            50: get_exp_val = 8'd11;
            51: get_exp_val = 8'd11;
            52: get_exp_val = 8'd10;
            53: get_exp_val = 8'd9;
            54: get_exp_val = 8'd9;
            55: get_exp_val = 8'd8;
            56: get_exp_val = 8'd8;
            57: get_exp_val = 8'd7;
            58: get_exp_val = 8'd7;
            59: get_exp_val = 8'd6;
            60: get_exp_val = 8'd6;
            61: get_exp_val = 8'd6;
            62: get_exp_val = 8'd5;
            63: get_exp_val = 8'd5;
            64: get_exp_val = 8'd5;
            65: get_exp_val = 8'd4;
            66: get_exp_val = 8'd4;
            67: get_exp_val = 8'd4;
            68: get_exp_val = 8'd4;
            69: get_exp_val = 8'd3;
            70: get_exp_val = 8'd3;
            71: get_exp_val = 8'd3;
            72: get_exp_val = 8'd3;
            73: get_exp_val = 8'd3;
            74: get_exp_val = 8'd2;
            75: get_exp_val = 8'd2;
            76: get_exp_val = 8'd2;
            77: get_exp_val = 8'd2;
            78: get_exp_val = 8'd2;
            79: get_exp_val = 8'd2;
            80: get_exp_val = 8'd2;
            81: get_exp_val = 8'd2;
            82: get_exp_val = 8'd2;
            83: get_exp_val = 8'd1;
            84: get_exp_val = 8'd1;
            85: get_exp_val = 8'd1;
            86: get_exp_val = 8'd1;
            87: get_exp_val = 8'd1;
            88: get_exp_val = 8'd1;
            89: get_exp_val = 8'd1;
            90: get_exp_val = 8'd1;
            91: get_exp_val = 8'd1;
            92: get_exp_val = 8'd1;
            93: get_exp_val = 8'd1;
            94: get_exp_val = 8'd1;
            95: get_exp_val = 8'd1;
            96: get_exp_val = 8'd1;
            97: get_exp_val = 8'd1;
            98: get_exp_val = 8'd1;
            99: get_exp_val = 8'd1;
            default: get_exp_val = 8'd0;
        endcase
    endfunction

    function automatic logic [RECIP_WIDTH-1:0] get_recip(input logic [10:0] sum);
        case (sum)
            255: get_recip = 20'd526345;
            256: get_recip = 20'd524288;
            257: get_recip = 20'd522248;
            258: get_recip = 20'd520224;
            259: get_recip = 20'd518216;
            260: get_recip = 20'd516223;
            261: get_recip = 20'd514245;
            262: get_recip = 20'd512282;
            263: get_recip = 20'd510334;
            264: get_recip = 20'd508401;
            265: get_recip = 20'd506482;
            266: get_recip = 20'd504578;
            267: get_recip = 20'd502689;
            268: get_recip = 20'd500813;
            269: get_recip = 20'd498951;
            270: get_recip = 20'd497103;
            271: get_recip = 20'd495269;
            272: get_recip = 20'd493448;
            273: get_recip = 20'd491641;
            274: get_recip = 20'd489846;
            275: get_recip = 20'd488065;
            276: get_recip = 20'd486297;
            277: get_recip = 20'd484541;
            278: get_recip = 20'd482798;
            279: get_recip = 20'd481068;
            280: get_recip = 20'd479350;
            281: get_recip = 20'd477644;
            282: get_recip = 20'd475950;
            283: get_recip = 20'd474268;
            284: get_recip = 20'd472598;
            285: get_recip = 20'd470940;
            286: get_recip = 20'd469293;
            287: get_recip = 20'd467658;
            288: get_recip = 20'd466034;
            289: get_recip = 20'd464422;
            290: get_recip = 20'd462820;
            291: get_recip = 20'd461230;
            292: get_recip = 20'd459650;
            293: get_recip = 20'd458081;
            294: get_recip = 20'd456523;
            295: get_recip = 20'd454976;
            296: get_recip = 20'd453439;
            297: get_recip = 20'd451912;
            298: get_recip = 20'd450396;
            299: get_recip = 20'd448889;
            300: get_recip = 20'd447393;
            301: get_recip = 20'd445907;
            302: get_recip = 20'd444430;
            303: get_recip = 20'd442963;
            304: get_recip = 20'd441506;
            305: get_recip = 20'd440059;
            306: get_recip = 20'd438621;
            307: get_recip = 20'd437192;
            308: get_recip = 20'd435772;
            309: get_recip = 20'd434362;
            310: get_recip = 20'd432961;
            311: get_recip = 20'd431569;
            312: get_recip = 20'd430186;
            313: get_recip = 20'd428811;
            314: get_recip = 20'd427445;
            315: get_recip = 20'd426089;
            316: get_recip = 20'd424740;
            317: get_recip = 20'd423400;
            318: get_recip = 20'd422069;
            319: get_recip = 20'd420746;
            320: get_recip = 20'd419431;
            321: get_recip = 20'd418124;
            322: get_recip = 20'd416826;
            323: get_recip = 20'd415535;
            324: get_recip = 20'd414253;
            325: get_recip = 20'd412978;
            326: get_recip = 20'd411711;
            327: get_recip = 20'd410452;
            328: get_recip = 20'd409201;
            329: get_recip = 20'd407957;
            330: get_recip = 20'd406721;
            331: get_recip = 20'd405492;
            332: get_recip = 20'd404271;
            333: get_recip = 20'd403057;
            334: get_recip = 20'd401850;
            335: get_recip = 20'd400650;
            336: get_recip = 20'd399458;
            337: get_recip = 20'd398273;
            338: get_recip = 20'd397094;
            339: get_recip = 20'd395923;
            340: get_recip = 20'd394759;
            341: get_recip = 20'd393601;
            342: get_recip = 20'd392450;
            343: get_recip = 20'd391306;
            344: get_recip = 20'd390168;
            345: get_recip = 20'd389037;
            346: get_recip = 20'd387913;
            347: get_recip = 20'd386795;
            348: get_recip = 20'd385684;
            349: get_recip = 20'd384579;
            350: get_recip = 20'd383480;
            351: get_recip = 20'd382387;
            352: get_recip = 20'd381301;
            353: get_recip = 20'd380221;
            354: get_recip = 20'd379147;
            355: get_recip = 20'd378079;
            356: get_recip = 20'd377017;
            357: get_recip = 20'd375961;
            358: get_recip = 20'd374910;
            359: get_recip = 20'd373866;
            360: get_recip = 20'd372828;
            361: get_recip = 20'd371795;
            362: get_recip = 20'd370768;
            363: get_recip = 20'd369746;
            364: get_recip = 20'd368731;
            365: get_recip = 20'd367720;
            366: get_recip = 20'd366716;
            367: get_recip = 20'd365716;
            368: get_recip = 20'd364723;
            369: get_recip = 20'd363734;
            370: get_recip = 20'd362751;
            371: get_recip = 20'd361773;
            372: get_recip = 20'd360801;
            373: get_recip = 20'd359834;
            374: get_recip = 20'd358871;
            375: get_recip = 20'd357914;
            376: get_recip = 20'd356963;
            377: get_recip = 20'd356016;
            378: get_recip = 20'd355074;
            379: get_recip = 20'd354137;
            380: get_recip = 20'd353205;
            381: get_recip = 20'd352278;
            382: get_recip = 20'd351356;
            383: get_recip = 20'd350438;
            384: get_recip = 20'd349526;
            385: get_recip = 20'd348618;
            386: get_recip = 20'd347715;
            387: get_recip = 20'd346816;
            388: get_recip = 20'd345922;
            389: get_recip = 20'd345033;
            390: get_recip = 20'd344149;
            391: get_recip = 20'd343268;
            392: get_recip = 20'd342393;
            393: get_recip = 20'd341521;
            394: get_recip = 20'd340655;
            395: get_recip = 20'd339792;
            396: get_recip = 20'd338934;
            397: get_recip = 20'd338080;
            398: get_recip = 20'd337231;
            399: get_recip = 20'd336386;
            400: get_recip = 20'd335545;
            401: get_recip = 20'd334708;
            402: get_recip = 20'd333875;
            403: get_recip = 20'd333047;
            404: get_recip = 20'd332223;
            405: get_recip = 20'd331402;
            406: get_recip = 20'd330586;
            407: get_recip = 20'd329774;
            408: get_recip = 20'd328966;
            409: get_recip = 20'd328161;
            410: get_recip = 20'd327361;
            411: get_recip = 20'd326564;
            412: get_recip = 20'd325772;
            413: get_recip = 20'd324983;
            414: get_recip = 20'd324198;
            415: get_recip = 20'd323417;
            416: get_recip = 20'd322639;
            417: get_recip = 20'd321866;
            418: get_recip = 20'd321096;
            419: get_recip = 20'd320329;
            420: get_recip = 20'd319567;
            421: get_recip = 20'd318807;
            422: get_recip = 20'd318052;
            423: get_recip = 20'd317300;
            424: get_recip = 20'd316552;
            425: get_recip = 20'd315807;
            426: get_recip = 20'd315066;
            427: get_recip = 20'd314328;
            428: get_recip = 20'd313593;
            429: get_recip = 20'd312862;
            430: get_recip = 20'd312135;
            431: get_recip = 20'd311411;
            432: get_recip = 20'd310690;
            433: get_recip = 20'd309972;
            434: get_recip = 20'd309258;
            435: get_recip = 20'd308547;
            436: get_recip = 20'd307839;
            437: get_recip = 20'd307135;
            438: get_recip = 20'd306434;
            439: get_recip = 20'd305736;
            440: get_recip = 20'd305041;
            441: get_recip = 20'd304349;
            442: get_recip = 20'd303661;
            443: get_recip = 20'd302975;
            444: get_recip = 20'd302293;
            445: get_recip = 20'd301613;
            446: get_recip = 20'd300937;
            447: get_recip = 20'd300264;
            448: get_recip = 20'd299594;
            449: get_recip = 20'd298926;
            450: get_recip = 20'd298262;
            451: get_recip = 20'd297601;
            452: get_recip = 20'd296942;
            453: get_recip = 20'd296287;
            454: get_recip = 20'd295634;
            455: get_recip = 20'd294985;
            456: get_recip = 20'd294338;
            457: get_recip = 20'd293694;
            458: get_recip = 20'd293052;
            459: get_recip = 20'd292414;
            460: get_recip = 20'd291778;
            461: get_recip = 20'd291145;
            462: get_recip = 20'd290515;
            463: get_recip = 20'd289888;
            464: get_recip = 20'd289263;
            465: get_recip = 20'd288641;
            466: get_recip = 20'd288021;
            467: get_recip = 20'd287405;
            468: get_recip = 20'd286791;
            469: get_recip = 20'd286179;
            470: get_recip = 20'd285570;
            471: get_recip = 20'd284964;
            472: get_recip = 20'd284360;
            473: get_recip = 20'd283759;
            474: get_recip = 20'd283160;
            475: get_recip = 20'd282564;
            476: get_recip = 20'd281971;
            477: get_recip = 20'd281379;
            478: get_recip = 20'd280791;
            479: get_recip = 20'd280205;
            480: get_recip = 20'd279621;
            481: get_recip = 20'd279039;
            482: get_recip = 20'd278461;
            483: get_recip = 20'd277884;
            484: get_recip = 20'd277310;
            485: get_recip = 20'd276738;
            486: get_recip = 20'd276169;
            487: get_recip = 20'd275602;
            488: get_recip = 20'd275037;
            489: get_recip = 20'd274474;
            490: get_recip = 20'd273914;
            491: get_recip = 20'd273356;
            492: get_recip = 20'd272801;
            493: get_recip = 20'd272247;
            494: get_recip = 20'd271696;
            495: get_recip = 20'd271147;
            496: get_recip = 20'd270601;
            497: get_recip = 20'd270056;
            498: get_recip = 20'd269514;
            499: get_recip = 20'd268974;
            500: get_recip = 20'd268436;
            501: get_recip = 20'd267900;
            502: get_recip = 20'd267366;
            503: get_recip = 20'd266835;
            504: get_recip = 20'd266306;
            505: get_recip = 20'd265778;
            506: get_recip = 20'd265253;
            507: get_recip = 20'd264730;
            508: get_recip = 20'd264209;
            509: get_recip = 20'd263690;
            510: get_recip = 20'd263173;
            511: get_recip = 20'd262658;
            512: get_recip = 20'd262144;
            513: get_recip = 20'd261633;
            514: get_recip = 20'd261124;
            515: get_recip = 20'd260617;
            516: get_recip = 20'd260112;
            517: get_recip = 20'd259609;
            518: get_recip = 20'd259108;
            519: get_recip = 20'd258609;
            520: get_recip = 20'd258112;
            521: get_recip = 20'd257616;
            522: get_recip = 20'd257123;
            523: get_recip = 20'd256631;
            524: get_recip = 20'd256141;
            525: get_recip = 20'd255653;
            526: get_recip = 20'd255167;
            527: get_recip = 20'd254683;
            528: get_recip = 20'd254201;
            529: get_recip = 20'd253720;
            530: get_recip = 20'd253241;
            531: get_recip = 20'd252765;
            532: get_recip = 20'd252289;
            533: get_recip = 20'd251816;
            534: get_recip = 20'd251345;
            535: get_recip = 20'd250875;
            536: get_recip = 20'd250407;
            537: get_recip = 20'd249940;
            538: get_recip = 20'd249476;
            539: get_recip = 20'd249013;
            540: get_recip = 20'd248552;
            541: get_recip = 20'd248092;
            542: get_recip = 20'd247635;
            543: get_recip = 20'd247179;
            544: get_recip = 20'd246724;
            545: get_recip = 20'd246272;
            546: get_recip = 20'd245821;
            547: get_recip = 20'd245371;
            548: get_recip = 20'd244923;
            549: get_recip = 20'd244477;
            550: get_recip = 20'd244033;
            551: get_recip = 20'd243590;
            552: get_recip = 20'd243149;
            553: get_recip = 20'd242709;
            554: get_recip = 20'd242271;
            555: get_recip = 20'd241834;
            556: get_recip = 20'd241399;
            557: get_recip = 20'd240966;
            558: get_recip = 20'd240534;
            559: get_recip = 20'd240104;
            560: get_recip = 20'd239675;
            561: get_recip = 20'd239248;
            562: get_recip = 20'd238822;
            563: get_recip = 20'd238398;
            564: get_recip = 20'd237975;
            565: get_recip = 20'd237554;
            566: get_recip = 20'd237134;
            567: get_recip = 20'd236716;
            568: get_recip = 20'd236299;
            569: get_recip = 20'd235884;
            570: get_recip = 20'd235470;
            571: get_recip = 20'd235058;
            572: get_recip = 20'd234647;
            573: get_recip = 20'd234237;
            574: get_recip = 20'd233829;
            575: get_recip = 20'd233423;
            576: get_recip = 20'd233017;
            577: get_recip = 20'd232614;
            578: get_recip = 20'd232211;
            579: get_recip = 20'd231810;
            580: get_recip = 20'd231410;
            581: get_recip = 20'd231012;
            582: get_recip = 20'd230615;
            583: get_recip = 20'd230220;
            584: get_recip = 20'd229825;
            585: get_recip = 20'd229433;
            586: get_recip = 20'd229041;
            587: get_recip = 20'd228651;
            588: get_recip = 20'd228262;
            589: get_recip = 20'd227874;
            590: get_recip = 20'd227488;
            591: get_recip = 20'd227103;
            592: get_recip = 20'd226720;
            593: get_recip = 20'd226337;
            594: get_recip = 20'd225956;
            595: get_recip = 20'd225577;
            596: get_recip = 20'd225198;
            597: get_recip = 20'd224821;
            598: get_recip = 20'd224445;
            599: get_recip = 20'd224070;
            600: get_recip = 20'd223697;
            601: get_recip = 20'd223325;
            602: get_recip = 20'd222954;
            603: get_recip = 20'd222584;
            604: get_recip = 20'd222215;
            605: get_recip = 20'd221848;
            606: get_recip = 20'd221482;
            607: get_recip = 20'd221117;
            608: get_recip = 20'd220753;
            609: get_recip = 20'd220391;
            610: get_recip = 20'd220030;
            611: get_recip = 20'd219669;
            612: get_recip = 20'd219311;
            613: get_recip = 20'd218953;
            614: get_recip = 20'd218596;
            615: get_recip = 20'd218241;
            616: get_recip = 20'd217886;
            617: get_recip = 20'd217533;
            618: get_recip = 20'd217181;
            619: get_recip = 20'd216830;
            620: get_recip = 20'd216481;
            621: get_recip = 20'd216132;
            622: get_recip = 20'd215785;
            623: get_recip = 20'd215438;
            624: get_recip = 20'd215093;
            625: get_recip = 20'd214749;
            626: get_recip = 20'd214406;
            627: get_recip = 20'd214064;
            628: get_recip = 20'd213723;
            629: get_recip = 20'd213383;
            630: get_recip = 20'd213045;
            631: get_recip = 20'd212707;
            632: get_recip = 20'd212370;
            633: get_recip = 20'd212035;
            634: get_recip = 20'd211700;
            635: get_recip = 20'd211367;
            636: get_recip = 20'd211035;
            637: get_recip = 20'd210703;
            638: get_recip = 20'd210373;
            639: get_recip = 20'd210044;
            640: get_recip = 20'd209716;
            641: get_recip = 20'd209389;
            642: get_recip = 20'd209062;
            643: get_recip = 20'd208737;
            644: get_recip = 20'd208413;
            645: get_recip = 20'd208090;
            646: get_recip = 20'd207768;
            647: get_recip = 20'd207447;
            648: get_recip = 20'd207127;
            649: get_recip = 20'd206807;
            650: get_recip = 20'd206489;
            651: get_recip = 20'd206172;
            652: get_recip = 20'd205856;
            653: get_recip = 20'd205541;
            654: get_recip = 20'd205226;
            655: get_recip = 20'd204913;
            656: get_recip = 20'd204601;
            657: get_recip = 20'd204289;
            658: get_recip = 20'd203979;
            659: get_recip = 20'd203669;
            660: get_recip = 20'd203361;
            661: get_recip = 20'd203053;
            662: get_recip = 20'd202746;
            663: get_recip = 20'd202441;
            664: get_recip = 20'd202136;
            665: get_recip = 20'd201832;
            666: get_recip = 20'd201529;
            667: get_recip = 20'd201226;
            668: get_recip = 20'd200925;
            669: get_recip = 20'd200625;
            670: get_recip = 20'd200325;
            671: get_recip = 20'd200027;
            672: get_recip = 20'd199729;
            673: get_recip = 20'd199432;
            674: get_recip = 20'd199137;
            675: get_recip = 20'd198842;
            676: get_recip = 20'd198547;
            677: get_recip = 20'd198254;
            678: get_recip = 20'd197962;
            679: get_recip = 20'd197670;
            680: get_recip = 20'd197380;
            681: get_recip = 20'd197090;
            682: get_recip = 20'd196801;
            683: get_recip = 20'd196513;
            684: get_recip = 20'd196225;
            685: get_recip = 20'd195939;
            686: get_recip = 20'd195653;
            687: get_recip = 20'd195368;
            688: get_recip = 20'd195084;
            689: get_recip = 20'd194801;
            690: get_recip = 20'd194519;
            691: get_recip = 20'd194237;
            692: get_recip = 20'd193957;
            693: get_recip = 20'd193677;
            694: get_recip = 20'd193398;
            695: get_recip = 20'd193120;
            696: get_recip = 20'd192842;
            697: get_recip = 20'd192565;
            698: get_recip = 20'd192290;
            699: get_recip = 20'd192014;
            700: get_recip = 20'd191740;
            701: get_recip = 20'd191467;
            702: get_recip = 20'd191194;
            703: get_recip = 20'd190922;
            704: get_recip = 20'd190651;
            705: get_recip = 20'd190380;
            706: get_recip = 20'd190111;
            707: get_recip = 20'd189842;
            708: get_recip = 20'd189574;
            709: get_recip = 20'd189306;
            710: get_recip = 20'd189040;
            711: get_recip = 20'd188774;
            712: get_recip = 20'd188509;
            713: get_recip = 20'd188244;
            714: get_recip = 20'd187981;
            715: get_recip = 20'd187718;
            716: get_recip = 20'd187455;
            717: get_recip = 20'd187194;
            718: get_recip = 20'd186933;
            719: get_recip = 20'd186673;
            720: get_recip = 20'd186414;
            721: get_recip = 20'd186155;
            722: get_recip = 20'd185898;
            723: get_recip = 20'd185641;
            724: get_recip = 20'd185384;
            725: get_recip = 20'd185128;
            726: get_recip = 20'd184873;
            727: get_recip = 20'd184619;
            728: get_recip = 20'd184366;
            729: get_recip = 20'd184113;
            730: get_recip = 20'd183860;
            731: get_recip = 20'd183609;
            732: get_recip = 20'd183358;
            733: get_recip = 20'd183108;
            734: get_recip = 20'd182858;
            735: get_recip = 20'd182610;
            736: get_recip = 20'd182362;
            737: get_recip = 20'd182114;
            738: get_recip = 20'd181867;
            739: get_recip = 20'd181621;
            740: get_recip = 20'd181376;
            741: get_recip = 20'd181131;
            742: get_recip = 20'd180887;
            743: get_recip = 20'd180643;
            744: get_recip = 20'd180401;
            745: get_recip = 20'd180159;
            746: get_recip = 20'd179917;
            747: get_recip = 20'd179676;
            748: get_recip = 20'd179436;
            749: get_recip = 20'd179196;
            750: get_recip = 20'd178957;
            751: get_recip = 20'd178719;
            752: get_recip = 20'd178482;
            753: get_recip = 20'd178244;
            754: get_recip = 20'd178008;
            755: get_recip = 20'd177772;
            756: get_recip = 20'd177537;
            757: get_recip = 20'd177303;
            758: get_recip = 20'd177069;
            759: get_recip = 20'd176835;
            760: get_recip = 20'd176603;
            761: get_recip = 20'd176371;
            762: get_recip = 20'd176139;
            763: get_recip = 20'd175908;
            764: get_recip = 20'd175678;
            765: get_recip = 20'd175449;
            766: get_recip = 20'd175219;
            767: get_recip = 20'd174991;
            768: get_recip = 20'd174763;
            769: get_recip = 20'd174536;
            770: get_recip = 20'd174309;
            771: get_recip = 20'd174083;
            772: get_recip = 20'd173858;
            773: get_recip = 20'd173633;
            774: get_recip = 20'd173408;
            775: get_recip = 20'd173185;
            776: get_recip = 20'd172961;
            777: get_recip = 20'd172739;
            778: get_recip = 20'd172517;
            779: get_recip = 20'd172295;
            780: get_recip = 20'd172075;
            781: get_recip = 20'd171854;
            782: get_recip = 20'd171634;
            783: get_recip = 20'd171415;
            784: get_recip = 20'd171197;
            785: get_recip = 20'd170978;
            786: get_recip = 20'd170761;
            787: get_recip = 20'd170544;
            788: get_recip = 20'd170328;
            789: get_recip = 20'd170112;
            790: get_recip = 20'd169896;
            791: get_recip = 20'd169682;
            792: get_recip = 20'd169467;
            793: get_recip = 20'd169254;
            794: get_recip = 20'd169040;
            795: get_recip = 20'd168828;
            796: get_recip = 20'd168616;
            797: get_recip = 20'd168404;
            798: get_recip = 20'd168193;
            799: get_recip = 20'd167983;
            800: get_recip = 20'd167773;
            801: get_recip = 20'd167563;
            802: get_recip = 20'd167354;
            803: get_recip = 20'd167146;
            804: get_recip = 20'd166938;
            805: get_recip = 20'd166731;
            806: get_recip = 20'd166524;
            807: get_recip = 20'd166317;
            808: get_recip = 20'd166112;
            809: get_recip = 20'd165906;
            810: get_recip = 20'd165701;
            811: get_recip = 20'd165497;
            812: get_recip = 20'd165293;
            813: get_recip = 20'd165090;
            814: get_recip = 20'd164887;
            815: get_recip = 20'd164685;
            816: get_recip = 20'd164483;
            817: get_recip = 20'd164282;
            818: get_recip = 20'd164081;
            819: get_recip = 20'd163881;
            820: get_recip = 20'd163681;
            821: get_recip = 20'd163481;
            822: get_recip = 20'd163282;
            823: get_recip = 20'd163084;
            824: get_recip = 20'd162886;
            825: get_recip = 20'd162689;
            826: get_recip = 20'd162492;
            827: get_recip = 20'd162295;
            828: get_recip = 20'd162099;
            829: get_recip = 20'd161904;
            830: get_recip = 20'd161709;
            831: get_recip = 20'd161514;
            832: get_recip = 20'd161320;
            833: get_recip = 20'd161126;
            834: get_recip = 20'd160933;
            835: get_recip = 20'd160740;
            836: get_recip = 20'd160548;
            837: get_recip = 20'd160356;
            838: get_recip = 20'd160165;
            839: get_recip = 20'd159974;
            840: get_recip = 20'd159784;
            841: get_recip = 20'd159594;
            842: get_recip = 20'd159404;
            843: get_recip = 20'd159215;
            844: get_recip = 20'd159026;
            845: get_recip = 20'd158838;
            846: get_recip = 20'd158650;
            847: get_recip = 20'd158463;
            848: get_recip = 20'd158276;
            849: get_recip = 20'd158090;
            850: get_recip = 20'd157904;
            851: get_recip = 20'd157718;
            852: get_recip = 20'd157533;
            853: get_recip = 20'd157348;
            854: get_recip = 20'd157164;
            855: get_recip = 20'd156980;
            856: get_recip = 20'd156797;
            857: get_recip = 20'd156614;
            858: get_recip = 20'd156431;
            859: get_recip = 20'd156249;
            860: get_recip = 20'd156068;
            861: get_recip = 20'd155886;
            862: get_recip = 20'd155706;
            863: get_recip = 20'd155525;
            864: get_recip = 20'd155345;
            865: get_recip = 20'd155166;
            866: get_recip = 20'd154986;
            867: get_recip = 20'd154808;
            868: get_recip = 20'd154629;
            869: get_recip = 20'd154451;
            870: get_recip = 20'd154274;
            871: get_recip = 20'd154097;
            872: get_recip = 20'd153920;
            873: get_recip = 20'd153744;
            874: get_recip = 20'd153568;
            875: get_recip = 20'd153392;
            876: get_recip = 20'd153217;
            877: get_recip = 20'd153042;
            878: get_recip = 20'd152868;
            879: get_recip = 20'd152694;
            880: get_recip = 20'd152521;
            881: get_recip = 20'd152348;
            882: get_recip = 20'd152175;
            883: get_recip = 20'd152002;
            884: get_recip = 20'd151831;
            885: get_recip = 20'd151659;
            886: get_recip = 20'd151488;
            887: get_recip = 20'd151317;
            888: get_recip = 20'd151147;
            889: get_recip = 20'd150977;
            890: get_recip = 20'd150807;
            891: get_recip = 20'd150638;
            892: get_recip = 20'd150469;
            893: get_recip = 20'd150300;
            894: get_recip = 20'd150132;
            895: get_recip = 20'd149964;
            896: get_recip = 20'd149797;
            897: get_recip = 20'd149630;
            898: get_recip = 20'd149463;
            899: get_recip = 20'd149297;
            900: get_recip = 20'd149131;
            901: get_recip = 20'd148966;
            902: get_recip = 20'd148801;
            903: get_recip = 20'd148636;
            904: get_recip = 20'd148471;
            905: get_recip = 20'd148307;
            906: get_recip = 20'd148144;
            907: get_recip = 20'd147980;
            908: get_recip = 20'd147817;
            909: get_recip = 20'd147655;
            910: get_recip = 20'd147493;
            911: get_recip = 20'd147331;
            912: get_recip = 20'd147169;
            913: get_recip = 20'd147008;
            914: get_recip = 20'd146847;
            915: get_recip = 20'd146687;
            916: get_recip = 20'd146526;
            917: get_recip = 20'd146367;
            918: get_recip = 20'd146207;
            919: get_recip = 20'd146048;
            920: get_recip = 20'd145889;
            921: get_recip = 20'd145731;
            922: get_recip = 20'd145573;
            923: get_recip = 20'd145415;
            924: get_recip = 20'd145258;
            925: get_recip = 20'd145101;
            926: get_recip = 20'd144944;
            927: get_recip = 20'd144788;
            928: get_recip = 20'd144632;
            929: get_recip = 20'd144476;
            930: get_recip = 20'd144321;
            931: get_recip = 20'd144166;
            932: get_recip = 20'd144011;
            933: get_recip = 20'd143857;
            934: get_recip = 20'd143703;
            935: get_recip = 20'd143549;
            936: get_recip = 20'd143396;
            937: get_recip = 20'd143242;
            938: get_recip = 20'd143090;
            939: get_recip = 20'd142937;
            940: get_recip = 20'd142785;
            941: get_recip = 20'd142634;
            942: get_recip = 20'd142482;
            943: get_recip = 20'd142331;
            944: get_recip = 20'd142180;
            945: get_recip = 20'd142030;
            946: get_recip = 20'd141880;
            947: get_recip = 20'd141730;
            948: get_recip = 20'd141580;
            949: get_recip = 20'd141431;
            950: get_recip = 20'd141282;
            951: get_recip = 20'd141134;
            952: get_recip = 20'd140986;
            953: get_recip = 20'd140838;
            954: get_recip = 20'd140690;
            955: get_recip = 20'd140543;
            956: get_recip = 20'd140396;
            957: get_recip = 20'd140249;
            958: get_recip = 20'd140103;
            959: get_recip = 20'd139956;
            960: get_recip = 20'd139811;
            961: get_recip = 20'd139665;
            962: get_recip = 20'd139520;
            963: get_recip = 20'd139375;
            964: get_recip = 20'd139231;
            965: get_recip = 20'd139086;
            966: get_recip = 20'd138942;
            967: get_recip = 20'd138799;
            968: get_recip = 20'd138655;
            969: get_recip = 20'd138512;
            970: get_recip = 20'd138369;
            971: get_recip = 20'd138227;
            972: get_recip = 20'd138085;
            973: get_recip = 20'd137943;
            974: get_recip = 20'd137801;
            975: get_recip = 20'd137660;
            976: get_recip = 20'd137519;
            977: get_recip = 20'd137378;
            978: get_recip = 20'd137237;
            979: get_recip = 20'd137097;
            980: get_recip = 20'd136957;
            981: get_recip = 20'd136818;
            982: get_recip = 20'd136678;
            983: get_recip = 20'd136539;
            984: get_recip = 20'd136401;
            985: get_recip = 20'd136262;
            986: get_recip = 20'd136124;
            987: get_recip = 20'd135986;
            988: get_recip = 20'd135848;
            989: get_recip = 20'd135711;
            990: get_recip = 20'd135574;
            991: get_recip = 20'd135437;
            992: get_recip = 20'd135301;
            993: get_recip = 20'd135164;
            994: get_recip = 20'd135028;
            995: get_recip = 20'd134893;
            996: get_recip = 20'd134757;
            997: get_recip = 20'd134622;
            998: get_recip = 20'd134487;
            999: get_recip = 20'd134353;
            1000: get_recip = 20'd134218;
            1001: get_recip = 20'd134084;
            1002: get_recip = 20'd133950;
            1003: get_recip = 20'd133817;
            1004: get_recip = 20'd133683;
            1005: get_recip = 20'd133550;
            1006: get_recip = 20'd133418;
            1007: get_recip = 20'd133285;
            1008: get_recip = 20'd133153;
            1009: get_recip = 20'd133021;
            1010: get_recip = 20'd132889;
            1011: get_recip = 20'd132758;
            1012: get_recip = 20'd132627;
            1013: get_recip = 20'd132496;
            1014: get_recip = 20'd132365;
            1015: get_recip = 20'd132235;
            1016: get_recip = 20'd132105;
            1017: get_recip = 20'd131975;
            1018: get_recip = 20'd131845;
            1019: get_recip = 20'd131716;
            1020: get_recip = 20'd131587;
            1021: get_recip = 20'd131458;
            1022: get_recip = 20'd131329;
            1023: get_recip = 20'd131201;
            1024: get_recip = 20'd131072;
            1025: get_recip = 20'd130945;
            1026: get_recip = 20'd130817;
            1027: get_recip = 20'd130690;
            1028: get_recip = 20'd130562;
            1029: get_recip = 20'd130436;
            1030: get_recip = 20'd130309;
            1031: get_recip = 20'd130183;
            1032: get_recip = 20'd130056;
            1033: get_recip = 20'd129931;
            1034: get_recip = 20'd129805;
            1035: get_recip = 20'd129679;
            1036: get_recip = 20'd129554;
            1037: get_recip = 20'd129429;
            1038: get_recip = 20'd129305;
            1039: get_recip = 20'd129180;
            1040: get_recip = 20'd129056;
            1041: get_recip = 20'd128932;
            1042: get_recip = 20'd128808;
            1043: get_recip = 20'd128685;
            1044: get_recip = 20'd128562;
            1045: get_recip = 20'd128439;
            1046: get_recip = 20'd128316;
            1047: get_recip = 20'd128193;
            1048: get_recip = 20'd128071;
            1049: get_recip = 20'd127949;
            1050: get_recip = 20'd127827;
            1051: get_recip = 20'd127705;
            1052: get_recip = 20'd127584;
            1053: get_recip = 20'd127463;
            1054: get_recip = 20'd127342;
            1055: get_recip = 20'd127221;
            1056: get_recip = 20'd127101;
            1057: get_recip = 20'd126980;
            1058: get_recip = 20'd126860;
            1059: get_recip = 20'd126741;
            1060: get_recip = 20'd126621;
            1061: get_recip = 20'd126502;
            1062: get_recip = 20'd126383;
            1063: get_recip = 20'd126264;
            1064: get_recip = 20'd126145;
            1065: get_recip = 20'd126027;
            1066: get_recip = 20'd125908;
            1067: get_recip = 20'd125790;
            1068: get_recip = 20'd125673;
            1069: get_recip = 20'd125555;
            1070: get_recip = 20'd125438;
            1071: get_recip = 20'd125321;
            1072: get_recip = 20'd125204;
            1073: get_recip = 20'd125087;
            1074: get_recip = 20'd124970;
            1075: get_recip = 20'd124854;
            1076: get_recip = 20'd124738;
            1077: get_recip = 20'd124622;
            1078: get_recip = 20'd124507;
            1079: get_recip = 20'd124391;
            1080: get_recip = 20'd124276;
            1081: get_recip = 20'd124161;
            1082: get_recip = 20'd124046;
            1083: get_recip = 20'd123932;
            1084: get_recip = 20'd123818;
            1085: get_recip = 20'd123703;
            1086: get_recip = 20'd123590;
            1087: get_recip = 20'd123476;
            1088: get_recip = 20'd123362;
            1089: get_recip = 20'd123249;
            1090: get_recip = 20'd123136;
            1091: get_recip = 20'd123023;
            1092: get_recip = 20'd122911;
            1093: get_recip = 20'd122798;
            1094: get_recip = 20'd122686;
            1095: get_recip = 20'd122574;
            1096: get_recip = 20'd122462;
            1097: get_recip = 20'd122350;
            1098: get_recip = 20'd122239;
            1099: get_recip = 20'd122128;
            1100: get_recip = 20'd122017;
            1101: get_recip = 20'd121906;
            1102: get_recip = 20'd121795;
            1103: get_recip = 20'd121685;
            1104: get_recip = 20'd121575;
            1105: get_recip = 20'd121465;
            1106: get_recip = 20'd121355;
            1107: get_recip = 20'd121245;
            1108: get_recip = 20'd121136;
            1109: get_recip = 20'd121026;
            1110: get_recip = 20'd120917;
            1111: get_recip = 20'd120809;
            1112: get_recip = 20'd120700;
            1113: get_recip = 20'd120591;
            1114: get_recip = 20'd120483;
            1115: get_recip = 20'd120375;
            1116: get_recip = 20'd120267;
            1117: get_recip = 20'd120160;
            1118: get_recip = 20'd120052;
            1119: get_recip = 20'd119945;
            1120: get_recip = 20'd119838;
            1121: get_recip = 20'd119731;
            1122: get_recip = 20'd119624;
            1123: get_recip = 20'd119518;
            1124: get_recip = 20'd119411;
            1125: get_recip = 20'd119305;
            1126: get_recip = 20'd119199;
            1127: get_recip = 20'd119093;
            1128: get_recip = 20'd118988;
            1129: get_recip = 20'd118882;
            1130: get_recip = 20'd118777;
            1131: get_recip = 20'd118672;
            1132: get_recip = 20'd118567;
            1133: get_recip = 20'd118463;
            1134: get_recip = 20'd118358;
            1135: get_recip = 20'd118254;
            1136: get_recip = 20'd118150;
            1137: get_recip = 20'd118046;
            1138: get_recip = 20'd117942;
            1139: get_recip = 20'd117839;
            1140: get_recip = 20'd117735;
            1141: get_recip = 20'd117632;
            1142: get_recip = 20'd117529;
            1143: get_recip = 20'd117426;
            1144: get_recip = 20'd117324;
            1145: get_recip = 20'd117221;
            1146: get_recip = 20'd117119;
            1147: get_recip = 20'd117017;
            1148: get_recip = 20'd116915;
            1149: get_recip = 20'd116813;
            1150: get_recip = 20'd116712;
            1151: get_recip = 20'd116610;
            1152: get_recip = 20'd116509;
            1153: get_recip = 20'd116408;
            1154: get_recip = 20'd116307;
            1155: get_recip = 20'd116206;
            1156: get_recip = 20'd116106;
            1157: get_recip = 20'd116005;
            1158: get_recip = 20'd115905;
            1159: get_recip = 20'd115805;
            1160: get_recip = 20'd115705;
            1161: get_recip = 20'd115606;
            1162: get_recip = 20'd115506;
            1163: get_recip = 20'd115407;
            1164: get_recip = 20'd115308;
            1165: get_recip = 20'd115209;
            1166: get_recip = 20'd115110;
            1167: get_recip = 20'd115011;
            1168: get_recip = 20'd114913;
            1169: get_recip = 20'd114815;
            1170: get_recip = 20'd114717;
            1171: get_recip = 20'd114619;
            1172: get_recip = 20'd114521;
            1173: get_recip = 20'd114423;
            1174: get_recip = 20'd114326;
            1175: get_recip = 20'd114228;
            1176: get_recip = 20'd114131;
            1177: get_recip = 20'd114034;
            1178: get_recip = 20'd113937;
            1179: get_recip = 20'd113841;
            1180: get_recip = 20'd113744;
            1181: get_recip = 20'd113648;
            1182: get_recip = 20'd113552;
            1183: get_recip = 20'd113456;
            1184: get_recip = 20'd113360;
            1185: get_recip = 20'd113264;
            1186: get_recip = 20'd113169;
            1187: get_recip = 20'd113074;
            1188: get_recip = 20'd112978;
            1189: get_recip = 20'd112883;
            1190: get_recip = 20'd112789;
            1191: get_recip = 20'd112694;
            1192: get_recip = 20'd112599;
            1193: get_recip = 20'd112505;
            1194: get_recip = 20'd112411;
            1195: get_recip = 20'd112317;
            1196: get_recip = 20'd112223;
            1197: get_recip = 20'd112129;
            1198: get_recip = 20'd112035;
            1199: get_recip = 20'd111942;
            1200: get_recip = 20'd111849;
            1201: get_recip = 20'd111755;
            1202: get_recip = 20'd111663;
            1203: get_recip = 20'd111570;
            1204: get_recip = 20'd111477;
            1205: get_recip = 20'd111385;
            1206: get_recip = 20'd111292;
            1207: get_recip = 20'd111200;
            1208: get_recip = 20'd111108;
            1209: get_recip = 20'd111016;
            1210: get_recip = 20'd110924;
            1211: get_recip = 20'd110833;
            1212: get_recip = 20'd110741;
            1213: get_recip = 20'd110650;
            1214: get_recip = 20'd110559;
            1215: get_recip = 20'd110468;
            1216: get_recip = 20'd110377;
            1217: get_recip = 20'd110286;
            1218: get_recip = 20'd110196;
            1219: get_recip = 20'd110105;
            1220: get_recip = 20'd110015;
            1221: get_recip = 20'd109925;
            1222: get_recip = 20'd109835;
            1223: get_recip = 20'd109745;
            1224: get_recip = 20'd109656;
            1225: get_recip = 20'd109566;
            1226: get_recip = 20'd109477;
            1227: get_recip = 20'd109387;
            1228: get_recip = 20'd109298;
            1229: get_recip = 20'd109209;
            1230: get_recip = 20'd109121;
            1231: get_recip = 20'd109032;
            1232: get_recip = 20'd108943;
            1233: get_recip = 20'd108855;
            1234: get_recip = 20'd108767;
            1235: get_recip = 20'd108679;
            1236: get_recip = 20'd108591;
            1237: get_recip = 20'd108503;
            1238: get_recip = 20'd108415;
            1239: get_recip = 20'd108328;
            1240: get_recip = 20'd108241;
            1241: get_recip = 20'd108153;
            1242: get_recip = 20'd108066;
            1243: get_recip = 20'd107979;
            1244: get_recip = 20'd107893;
            1245: get_recip = 20'd107806;
            1246: get_recip = 20'd107719;
            1247: get_recip = 20'd107633;
            1248: get_recip = 20'd107547;
            1249: get_recip = 20'd107461;
            1250: get_recip = 20'd107375;
            1251: get_recip = 20'd107289;
            1252: get_recip = 20'd107203;
            1253: get_recip = 20'd107118;
            1254: get_recip = 20'd107032;
            1255: get_recip = 20'd106947;
            1256: get_recip = 20'd106862;
            1257: get_recip = 20'd106777;
            1258: get_recip = 20'd106692;
            1259: get_recip = 20'd106607;
            1260: get_recip = 20'd106523;
            1261: get_recip = 20'd106438;
            1262: get_recip = 20'd106354;
            1263: get_recip = 20'd106269;
            1264: get_recip = 20'd106185;
            1265: get_recip = 20'd106101;
            1266: get_recip = 20'd106018;
            1267: get_recip = 20'd105934;
            1268: get_recip = 20'd105850;
            1269: get_recip = 20'd105767;
            1270: get_recip = 20'd105684;
            1271: get_recip = 20'd105601;
            1272: get_recip = 20'd105518;
            1273: get_recip = 20'd105435;
            1274: get_recip = 20'd105352;
            1275: get_recip = 20'd105269;
            1276: get_recip = 20'd105187;
            1277: get_recip = 20'd105104;
            1278: get_recip = 20'd105022;
            1279: get_recip = 20'd104940;
            1280: get_recip = 20'd104858;
            1281: get_recip = 20'd104776;
            1282: get_recip = 20'd104695;
            1283: get_recip = 20'd104613;
            1284: get_recip = 20'd104531;
            1285: get_recip = 20'd104450;
            1286: get_recip = 20'd104369;
            1287: get_recip = 20'd104288;
            1288: get_recip = 20'd104207;
            1289: get_recip = 20'd104126;
            1290: get_recip = 20'd104045;
            1291: get_recip = 20'd103965;
            1292: get_recip = 20'd103884;
            1293: get_recip = 20'd103804;
            1294: get_recip = 20'd103724;
            1295: get_recip = 20'd103644;
            1296: get_recip = 20'd103564;
            1297: get_recip = 20'd103484;
            1298: get_recip = 20'd103404;
            1299: get_recip = 20'd103324;
            1300: get_recip = 20'd103245;
            1301: get_recip = 20'd103166;
            1302: get_recip = 20'd103086;
            1303: get_recip = 20'd103007;
            1304: get_recip = 20'd102928;
            1305: get_recip = 20'd102849;
            1306: get_recip = 20'd102771;
            1307: get_recip = 20'd102692;
            1308: get_recip = 20'd102613;
            1309: get_recip = 20'd102535;
            1310: get_recip = 20'd102457;
            1311: get_recip = 20'd102379;
            1312: get_recip = 20'd102301;
            1313: get_recip = 20'd102223;
            1314: get_recip = 20'd102145;
            1315: get_recip = 20'd102067;
            1316: get_recip = 20'd101990;
            1317: get_recip = 20'd101912;
            1318: get_recip = 20'd101835;
            1319: get_recip = 20'd101758;
            1320: get_recip = 20'd101681;
            1321: get_recip = 20'd101604;
            1322: get_recip = 20'd101527;
            1323: get_recip = 20'd101450;
            1324: get_recip = 20'd101373;
            1325: get_recip = 20'd101297;
            1326: get_recip = 20'd101221;
            1327: get_recip = 20'd101144;
            1328: get_recip = 20'd101068;
            1329: get_recip = 20'd100992;
            1330: get_recip = 20'd100916;
            1331: get_recip = 20'd100840;
            1332: get_recip = 20'd100765;
            1333: get_recip = 20'd100689;
            1334: get_recip = 20'd100613;
            1335: get_recip = 20'd100538;
            1336: get_recip = 20'd100463;
            1337: get_recip = 20'd100388;
            1338: get_recip = 20'd100313;
            1339: get_recip = 20'd100238;
            1340: get_recip = 20'd100163;
            1341: get_recip = 20'd100088;
            1342: get_recip = 20'd100014;
            1343: get_recip = 20'd99939;
            1344: get_recip = 20'd99865;
            1345: get_recip = 20'd99791;
            1346: get_recip = 20'd99716;
            1347: get_recip = 20'd99642;
            1348: get_recip = 20'd99569;
            1349: get_recip = 20'd99495;
            1350: get_recip = 20'd99421;
            1351: get_recip = 20'd99347;
            1352: get_recip = 20'd99274;
            1353: get_recip = 20'd99201;
            1354: get_recip = 20'd99127;
            1355: get_recip = 20'd99054;
            1356: get_recip = 20'd98981;
            1357: get_recip = 20'd98908;
            1358: get_recip = 20'd98835;
            1359: get_recip = 20'd98763;
            1360: get_recip = 20'd98690;
            1361: get_recip = 20'd98617;
            1362: get_recip = 20'd98545;
            1363: get_recip = 20'd98473;
            1364: get_recip = 20'd98401;
            1365: get_recip = 20'd98329;
            1366: get_recip = 20'd98257;
            1367: get_recip = 20'd98185;
            1368: get_recip = 20'd98113;
            1369: get_recip = 20'd98041;
            1370: get_recip = 20'd97970;
            1371: get_recip = 20'd97898;
            1372: get_recip = 20'd97827;
            1373: get_recip = 20'd97756;
            1374: get_recip = 20'd97684;
            1375: get_recip = 20'd97613;
            1376: get_recip = 20'd97542;
            1377: get_recip = 20'd97472;
            1378: get_recip = 20'd97401;
            1379: get_recip = 20'd97330;
            1380: get_recip = 20'd97260;
            1381: get_recip = 20'd97189;
            1382: get_recip = 20'd97119;
            1383: get_recip = 20'd97049;
            1384: get_recip = 20'd96979;
            1385: get_recip = 20'd96909;
            1386: get_recip = 20'd96839;
            1387: get_recip = 20'd96769;
            1388: get_recip = 20'd96699;
            1389: get_recip = 20'd96630;
            1390: get_recip = 20'd96560;
            1391: get_recip = 20'd96491;
            1392: get_recip = 20'd96421;
            1393: get_recip = 20'd96352;
            1394: get_recip = 20'd96283;
            1395: get_recip = 20'd96214;
            1396: get_recip = 20'd96145;
            1397: get_recip = 20'd96076;
            1398: get_recip = 20'd96007;
            1399: get_recip = 20'd95939;
            1400: get_recip = 20'd95870;
            1401: get_recip = 20'd95802;
            1402: get_recip = 20'd95734;
            1403: get_recip = 20'd95665;
            1404: get_recip = 20'd95597;
            1405: get_recip = 20'd95529;
            1406: get_recip = 20'd95461;
            1407: get_recip = 20'd95393;
            1408: get_recip = 20'd95326;
            1409: get_recip = 20'd95258;
            1410: get_recip = 20'd95190;
            1411: get_recip = 20'd95123;
            1412: get_recip = 20'd95056;
            1413: get_recip = 20'd94988;
            1414: get_recip = 20'd94921;
            1415: get_recip = 20'd94854;
            1416: get_recip = 20'd94787;
            1417: get_recip = 20'd94720;
            1418: get_recip = 20'd94653;
            1419: get_recip = 20'd94587;
            1420: get_recip = 20'd94520;
            1421: get_recip = 20'd94454;
            1422: get_recip = 20'd94387;
            1423: get_recip = 20'd94321;
            1424: get_recip = 20'd94255;
            1425: get_recip = 20'd94188;
            1426: get_recip = 20'd94122;
            1427: get_recip = 20'd94056;
            1428: get_recip = 20'd93991;
            1429: get_recip = 20'd93925;
            1430: get_recip = 20'd93859;
            1431: get_recip = 20'd93793;
            1432: get_recip = 20'd93728;
            1433: get_recip = 20'd93663;
            1434: get_recip = 20'd93597;
            1435: get_recip = 20'd93532;
            1436: get_recip = 20'd93467;
            1437: get_recip = 20'd93402;
            1438: get_recip = 20'd93337;
            1439: get_recip = 20'd93272;
            1440: get_recip = 20'd93207;
            1441: get_recip = 20'd93143;
            1442: get_recip = 20'd93078;
            1443: get_recip = 20'd93013;
            1444: get_recip = 20'd92949;
            1445: get_recip = 20'd92885;
            1446: get_recip = 20'd92821;
            1447: get_recip = 20'd92756;
            1448: get_recip = 20'd92692;
            1449: get_recip = 20'd92628;
            1450: get_recip = 20'd92564;
            1451: get_recip = 20'd92501;
            1452: get_recip = 20'd92437;
            1453: get_recip = 20'd92373;
            1454: get_recip = 20'd92310;
            1455: get_recip = 20'd92246;
            1456: get_recip = 20'd92183;
            1457: get_recip = 20'd92120;
            1458: get_recip = 20'd92057;
            1459: get_recip = 20'd91993;
            1460: get_recip = 20'd91930;
            1461: get_recip = 20'd91868;
            1462: get_recip = 20'd91805;
            1463: get_recip = 20'd91742;
            1464: get_recip = 20'd91679;
            1465: get_recip = 20'd91617;
            1466: get_recip = 20'd91554;
            1467: get_recip = 20'd91492;
            1468: get_recip = 20'd91429;
            1469: get_recip = 20'd91367;
            1470: get_recip = 20'd91305;
            1471: get_recip = 20'd91243;
            1472: get_recip = 20'd91181;
            1473: get_recip = 20'd91119;
            1474: get_recip = 20'd91057;
            1475: get_recip = 20'd90996;
            1476: get_recip = 20'd90934;
            1477: get_recip = 20'd90872;
            1478: get_recip = 20'd90811;
            1479: get_recip = 20'd90749;
            1480: get_recip = 20'd90688;
            1481: get_recip = 20'd90627;
            1482: get_recip = 20'd90566;
            1483: get_recip = 20'd90505;
            1484: get_recip = 20'd90444;
            1485: get_recip = 20'd90383;
            1486: get_recip = 20'd90322;
            1487: get_recip = 20'd90261;
            1488: get_recip = 20'd90201;
            1489: get_recip = 20'd90140;
            1490: get_recip = 20'd90080;
            1491: get_recip = 20'd90019;
            1492: get_recip = 20'd89959;
            1493: get_recip = 20'd89899;
            1494: get_recip = 20'd89838;
            1495: get_recip = 20'd89778;
            1496: get_recip = 20'd89718;
            1497: get_recip = 20'd89658;
            1498: get_recip = 20'd89598;
            1499: get_recip = 20'd89539;
            1500: get_recip = 20'd89479;
            1501: get_recip = 20'd89419;
            1502: get_recip = 20'd89360;
            1503: get_recip = 20'd89300;
            1504: get_recip = 20'd89241;
            1505: get_recip = 20'd89182;
            1506: get_recip = 20'd89122;
            1507: get_recip = 20'd89063;
            1508: get_recip = 20'd89004;
            1509: get_recip = 20'd88945;
            1510: get_recip = 20'd88886;
            1511: get_recip = 20'd88828;
            1512: get_recip = 20'd88769;
            1513: get_recip = 20'd88710;
            1514: get_recip = 20'd88652;
            1515: get_recip = 20'd88593;
            1516: get_recip = 20'd88535;
            1517: get_recip = 20'd88476;
            1518: get_recip = 20'd88418;
            1519: get_recip = 20'd88360;
            1520: get_recip = 20'd88302;
            1521: get_recip = 20'd88244;
            1522: get_recip = 20'd88186;
            1523: get_recip = 20'd88128;
            1524: get_recip = 20'd88070;
            1525: get_recip = 20'd88012;
            1526: get_recip = 20'd87954;
            1527: get_recip = 20'd87897;
            1528: get_recip = 20'd87839;
            1529: get_recip = 20'd87782;
            1530: get_recip = 20'd87725;
            1531: get_recip = 20'd87667;
            1532: get_recip = 20'd87610;
            1533: get_recip = 20'd87553;
            1534: get_recip = 20'd87496;
            1535: get_recip = 20'd87439;
            1536: get_recip = 20'd87382;
            1537: get_recip = 20'd87325;
            1538: get_recip = 20'd87268;
            1539: get_recip = 20'd87211;
            1540: get_recip = 20'd87155;
            1541: get_recip = 20'd87098;
            1542: get_recip = 20'd87042;
            1543: get_recip = 20'd86985;
            1544: get_recip = 20'd86929;
            1545: get_recip = 20'd86873;
            1546: get_recip = 20'd86817;
            1547: get_recip = 20'd86761;
            1548: get_recip = 20'd86704;
            1549: get_recip = 20'd86648;
            1550: get_recip = 20'd86593;
            1551: get_recip = 20'd86537;
            1552: get_recip = 20'd86481;
            1553: get_recip = 20'd86425;
            1554: get_recip = 20'd86370;
            1555: get_recip = 20'd86314;
            1556: get_recip = 20'd86259;
            1557: get_recip = 20'd86203;
            1558: get_recip = 20'd86148;
            1559: get_recip = 20'd86093;
            1560: get_recip = 20'd86038;
            1561: get_recip = 20'd85982;
            1562: get_recip = 20'd85927;
            1563: get_recip = 20'd85872;
            1564: get_recip = 20'd85817;
            1565: get_recip = 20'd85763;
            1566: get_recip = 20'd85708;
            1567: get_recip = 20'd85653;
            1568: get_recip = 20'd85599;
            1569: get_recip = 20'd85544;
            1570: get_recip = 20'd85489;
            1571: get_recip = 20'd85435;
            1572: get_recip = 20'd85381;
            1573: get_recip = 20'd85326;
            1574: get_recip = 20'd85272;
            1575: get_recip = 20'd85218;
            1576: get_recip = 20'd85164;
            1577: get_recip = 20'd85110;
            1578: get_recip = 20'd85056;
            1579: get_recip = 20'd85002;
            1580: get_recip = 20'd84948;
            1581: get_recip = 20'd84895;
            1582: get_recip = 20'd84841;
            1583: get_recip = 20'd84787;
            1584: get_recip = 20'd84734;
            1585: get_recip = 20'd84680;
            1586: get_recip = 20'd84627;
            1587: get_recip = 20'd84574;
            1588: get_recip = 20'd84520;
            1589: get_recip = 20'd84467;
            1590: get_recip = 20'd84414;
            1591: get_recip = 20'd84361;
            1592: get_recip = 20'd84308;
            1593: get_recip = 20'd84255;
            1594: get_recip = 20'd84202;
            1595: get_recip = 20'd84150;
            1596: get_recip = 20'd84097;
            1597: get_recip = 20'd84044;
            1598: get_recip = 20'd83992;
            1599: get_recip = 20'd83939;
            1600: get_recip = 20'd83887;
            1601: get_recip = 20'd83834;
            1602: get_recip = 20'd83782;
            1603: get_recip = 20'd83730;
            1604: get_recip = 20'd83677;
            1605: get_recip = 20'd83625;
            1606: get_recip = 20'd83573;
            1607: get_recip = 20'd83521;
            1608: get_recip = 20'd83469;
            1609: get_recip = 20'd83417;
            1610: get_recip = 20'd83366;
            1611: get_recip = 20'd83314;
            1612: get_recip = 20'd83262;
            1613: get_recip = 20'd83210;
            1614: get_recip = 20'd83159;
            1615: get_recip = 20'd83107;
            1616: get_recip = 20'd83056;
            1617: get_recip = 20'd83005;
            1618: get_recip = 20'd82953;
            1619: get_recip = 20'd82902;
            1620: get_recip = 20'd82851;
            1621: get_recip = 20'd82800;
            1622: get_recip = 20'd82749;
            1623: get_recip = 20'd82698;
            1624: get_recip = 20'd82647;
            1625: get_recip = 20'd82596;
            1626: get_recip = 20'd82545;
            1627: get_recip = 20'd82494;
            1628: get_recip = 20'd82444;
            1629: get_recip = 20'd82393;
            1630: get_recip = 20'd82343;
            1631: get_recip = 20'd82292;
            1632: get_recip = 20'd82242;
            1633: get_recip = 20'd82191;
            1634: get_recip = 20'd82141;
            1635: get_recip = 20'd82091;
            1636: get_recip = 20'd82041;
            1637: get_recip = 20'd81991;
            1638: get_recip = 20'd81941;
            1639: get_recip = 20'd81891;
            1640: get_recip = 20'd81841;
            1641: get_recip = 20'd81791;
            1642: get_recip = 20'd81741;
            1643: get_recip = 20'd81691;
            1644: get_recip = 20'd81641;
            1645: get_recip = 20'd81592;
            1646: get_recip = 20'd81542;
            1647: get_recip = 20'd81493;
            1648: get_recip = 20'd81443;
            1649: get_recip = 20'd81394;
            1650: get_recip = 20'd81345;
            1651: get_recip = 20'd81295;
            1652: get_recip = 20'd81246;
            1653: get_recip = 20'd81197;
            1654: get_recip = 20'd81148;
            1655: get_recip = 20'd81099;
            1656: get_recip = 20'd81050;
            1657: get_recip = 20'd81001;
            1658: get_recip = 20'd80952;
            1659: get_recip = 20'd80903;
            1660: get_recip = 20'd80855;
            1661: get_recip = 20'd80806;
            1662: get_recip = 20'd80757;
            1663: get_recip = 20'd80709;
            1664: get_recip = 20'd80660;
            1665: get_recip = 20'd80612;
            1666: get_recip = 20'd80563;
            1667: get_recip = 20'd80515;
            1668: get_recip = 20'd80467;
            1669: get_recip = 20'd80419;
            1670: get_recip = 20'd80370;
            1671: get_recip = 20'd80322;
            1672: get_recip = 20'd80274;
            1673: get_recip = 20'd80226;
            1674: get_recip = 20'd80178;
            1675: get_recip = 20'd80130;
            1676: get_recip = 20'd80083;
            1677: get_recip = 20'd80035;
            1678: get_recip = 20'd79987;
            1679: get_recip = 20'd79940;
            1680: get_recip = 20'd79892;
            1681: get_recip = 20'd79844;
            1682: get_recip = 20'd79797;
            1683: get_recip = 20'd79750;
            1684: get_recip = 20'd79702;
            1685: get_recip = 20'd79655;
            1686: get_recip = 20'd79608;
            1687: get_recip = 20'd79561;
            1688: get_recip = 20'd79513;
            1689: get_recip = 20'd79466;
            1690: get_recip = 20'd79419;
            1691: get_recip = 20'd79372;
            1692: get_recip = 20'd79325;
            1693: get_recip = 20'd79279;
            1694: get_recip = 20'd79232;
            1695: get_recip = 20'd79185;
            1696: get_recip = 20'd79138;
            1697: get_recip = 20'd79092;
            1698: get_recip = 20'd79045;
            1699: get_recip = 20'd78999;
            1700: get_recip = 20'd78952;
            1701: get_recip = 20'd78906;
            1702: get_recip = 20'd78859;
            1703: get_recip = 20'd78813;
            1704: get_recip = 20'd78767;
            1705: get_recip = 20'd78721;
            1706: get_recip = 20'd78674;
            1707: get_recip = 20'd78628;
            1708: get_recip = 20'd78582;
            1709: get_recip = 20'd78536;
            1710: get_recip = 20'd78490;
            1711: get_recip = 20'd78445;
            1712: get_recip = 20'd78399;
            1713: get_recip = 20'd78353;
            1714: get_recip = 20'd78307;
            1715: get_recip = 20'd78262;
            1716: get_recip = 20'd78216;
            1717: get_recip = 20'd78170;
            1718: get_recip = 20'd78125;
            1719: get_recip = 20'd78079;
            1720: get_recip = 20'd78034;
            1721: get_recip = 20'd77989;
            1722: get_recip = 20'd77943;
            1723: get_recip = 20'd77898;
            1724: get_recip = 20'd77853;
            1725: get_recip = 20'd77808;
            1726: get_recip = 20'd77763;
            1727: get_recip = 20'd77718;
            1728: get_recip = 20'd77673;
            1729: get_recip = 20'd77628;
            1730: get_recip = 20'd77583;
            1731: get_recip = 20'd77538;
            1732: get_recip = 20'd77493;
            1733: get_recip = 20'd77449;
            1734: get_recip = 20'd77404;
            1735: get_recip = 20'd77359;
            1736: get_recip = 20'd77315;
            1737: get_recip = 20'd77270;
            1738: get_recip = 20'd77226;
            1739: get_recip = 20'd77181;
            1740: get_recip = 20'd77137;
            1741: get_recip = 20'd77093;
            1742: get_recip = 20'd77049;
            1743: get_recip = 20'd77004;
            1744: get_recip = 20'd76960;
            1745: get_recip = 20'd76916;
            1746: get_recip = 20'd76872;
            1747: get_recip = 20'd76828;
            1748: get_recip = 20'd76784;
            1749: get_recip = 20'd76740;
            1750: get_recip = 20'd76696;
            1751: get_recip = 20'd76653;
            1752: get_recip = 20'd76609;
            1753: get_recip = 20'd76565;
            1754: get_recip = 20'd76521;
            1755: get_recip = 20'd76478;
            1756: get_recip = 20'd76434;
            1757: get_recip = 20'd76391;
            1758: get_recip = 20'd76347;
            1759: get_recip = 20'd76304;
            1760: get_recip = 20'd76261;
            1761: get_recip = 20'd76217;
            1762: get_recip = 20'd76174;
            1763: get_recip = 20'd76131;
            1764: get_recip = 20'd76088;
            1765: get_recip = 20'd76045;
            1766: get_recip = 20'd76001;
            1767: get_recip = 20'd75958;
            1768: get_recip = 20'd75916;
            1769: get_recip = 20'd75873;
            1770: get_recip = 20'd75830;
            1771: get_recip = 20'd75787;
            1772: get_recip = 20'd75744;
            1773: get_recip = 20'd75701;
            1774: get_recip = 20'd75659;
            1775: get_recip = 20'd75616;
            1776: get_recip = 20'd75574;
            1777: get_recip = 20'd75531;
            1778: get_recip = 20'd75489;
            1779: get_recip = 20'd75446;
            1780: get_recip = 20'd75404;
            1781: get_recip = 20'd75361;
            1782: get_recip = 20'd75319;
            1783: get_recip = 20'd75277;
            1784: get_recip = 20'd75235;
            1785: get_recip = 20'd75193;
            1786: get_recip = 20'd75150;
            1787: get_recip = 20'd75108;
            1788: get_recip = 20'd75066;
            1789: get_recip = 20'd75024;
            1790: get_recip = 20'd74982;
            1791: get_recip = 20'd74941;
            1792: get_recip = 20'd74899;
            1793: get_recip = 20'd74857;
            1794: get_recip = 20'd74815;
            1795: get_recip = 20'd74774;
            1796: get_recip = 20'd74732;
            1797: get_recip = 20'd74690;
            1798: get_recip = 20'd74649;
            1799: get_recip = 20'd74607;
            1800: get_recip = 20'd74566;
            1801: get_recip = 20'd74525;
            1802: get_recip = 20'd74483;
            1803: get_recip = 20'd74442;
            1804: get_recip = 20'd74401;
            1805: get_recip = 20'd74359;
            1806: get_recip = 20'd74318;
            1807: get_recip = 20'd74277;
            1808: get_recip = 20'd74236;
            1809: get_recip = 20'd74195;
            1810: get_recip = 20'd74154;
            1811: get_recip = 20'd74113;
            1812: get_recip = 20'd74072;
            1813: get_recip = 20'd74031;
            1814: get_recip = 20'd73990;
            1815: get_recip = 20'd73950;
            1816: get_recip = 20'd73909;
            1817: get_recip = 20'd73868;
            1818: get_recip = 20'd73828;
            1819: get_recip = 20'd73787;
            1820: get_recip = 20'd73747;
            1821: get_recip = 20'd73706;
            1822: get_recip = 20'd73666;
            1823: get_recip = 20'd73625;
            1824: get_recip = 20'd73585;
            1825: get_recip = 20'd73544;
            1826: get_recip = 20'd73504;
            1827: get_recip = 20'd73464;
            1828: get_recip = 20'd73424;
            1829: get_recip = 20'd73384;
            1830: get_recip = 20'd73344;
            1831: get_recip = 20'd73303;
            1832: get_recip = 20'd73263;
            1833: get_recip = 20'd73223;
            1834: get_recip = 20'd73184;
            1835: get_recip = 20'd73144;
            1836: get_recip = 20'd73104;
            1837: get_recip = 20'd73064;
            1838: get_recip = 20'd73024;
            1839: get_recip = 20'd72985;
            1840: get_recip = 20'd72945;
            1841: get_recip = 20'd72905;
            1842: get_recip = 20'd72866;
            1843: get_recip = 20'd72826;
            1844: get_recip = 20'd72787;
            1845: get_recip = 20'd72747;
            1846: get_recip = 20'd72708;
            1847: get_recip = 20'd72668;
            1848: get_recip = 20'd72629;
            1849: get_recip = 20'd72590;
            1850: get_recip = 20'd72551;
            1851: get_recip = 20'd72511;
            1852: get_recip = 20'd72472;
            1853: get_recip = 20'd72433;
            1854: get_recip = 20'd72394;
            1855: get_recip = 20'd72355;
            1856: get_recip = 20'd72316;
            1857: get_recip = 20'd72277;
            1858: get_recip = 20'd72238;
            1859: get_recip = 20'd72199;
            1860: get_recip = 20'd72161;
            1861: get_recip = 20'd72122;
            1862: get_recip = 20'd72083;
            1863: get_recip = 20'd72044;
            1864: get_recip = 20'd72006;
            1865: get_recip = 20'd71967;
            1866: get_recip = 20'd71929;
            1867: get_recip = 20'd71890;
            1868: get_recip = 20'd71852;
            1869: get_recip = 20'd71813;
            1870: get_recip = 20'd71775;
            1871: get_recip = 20'd71736;
            1872: get_recip = 20'd71698;
            1873: get_recip = 20'd71660;
            1874: get_recip = 20'd71621;
            1875: get_recip = 20'd71583;
            1876: get_recip = 20'd71545;
            1877: get_recip = 20'd71507;
            1878: get_recip = 20'd71469;
            1879: get_recip = 20'd71431;
            1880: get_recip = 20'd71393;
            1881: get_recip = 20'd71355;
            1882: get_recip = 20'd71317;
            1883: get_recip = 20'd71279;
            1884: get_recip = 20'd71241;
            1885: get_recip = 20'd71204;
            1886: get_recip = 20'd71166;
            1887: get_recip = 20'd71128;
            1888: get_recip = 20'd71090;
            1889: get_recip = 20'd71053;
            1890: get_recip = 20'd71015;
            1891: get_recip = 20'd70978;
            1892: get_recip = 20'd70940;
            1893: get_recip = 20'd70903;
            1894: get_recip = 20'd70865;
            1895: get_recip = 20'd70828;
            1896: get_recip = 20'd70790;
            1897: get_recip = 20'd70753;
            1898: get_recip = 20'd70716;
            1899: get_recip = 20'd70679;
            1900: get_recip = 20'd70641;
            1901: get_recip = 20'd70604;
            1902: get_recip = 20'd70567;
            1903: get_recip = 20'd70530;
            1904: get_recip = 20'd70493;
            1905: get_recip = 20'd70456;
            1906: get_recip = 20'd70419;
            1907: get_recip = 20'd70382;
            1908: get_recip = 20'd70345;
            1909: get_recip = 20'd70308;
            1910: get_recip = 20'd70272;
            1911: get_recip = 20'd70235;
            1912: get_recip = 20'd70198;
            1913: get_recip = 20'd70161;
            1914: get_recip = 20'd70125;
            1915: get_recip = 20'd70088;
            1916: get_recip = 20'd70052;
            1917: get_recip = 20'd70015;
            1918: get_recip = 20'd69978;
            1919: get_recip = 20'd69942;
            1920: get_recip = 20'd69906;
            1921: get_recip = 20'd69869;
            1922: get_recip = 20'd69833;
            1923: get_recip = 20'd69797;
            1924: get_recip = 20'd69760;
            1925: get_recip = 20'd69724;
            1926: get_recip = 20'd69688;
            1927: get_recip = 20'd69652;
            1928: get_recip = 20'd69616;
            1929: get_recip = 20'd69579;
            1930: get_recip = 20'd69543;
            1931: get_recip = 20'd69507;
            1932: get_recip = 20'd69471;
            1933: get_recip = 20'd69435;
            1934: get_recip = 20'd69400;
            1935: get_recip = 20'd69364;
            1936: get_recip = 20'd69328;
            1937: get_recip = 20'd69292;
            1938: get_recip = 20'd69256;
            1939: get_recip = 20'd69221;
            1940: get_recip = 20'd69185;
            1941: get_recip = 20'd69149;
            1942: get_recip = 20'd69114;
            1943: get_recip = 20'd69078;
            1944: get_recip = 20'd69043;
            1945: get_recip = 20'd69007;
            1946: get_recip = 20'd68972;
            1947: get_recip = 20'd68936;
            1948: get_recip = 20'd68901;
            1949: get_recip = 20'd68865;
            1950: get_recip = 20'd68830;
            1951: get_recip = 20'd68795;
            1952: get_recip = 20'd68760;
            1953: get_recip = 20'd68724;
            1954: get_recip = 20'd68689;
            1955: get_recip = 20'd68654;
            1956: get_recip = 20'd68619;
            1957: get_recip = 20'd68584;
            1958: get_recip = 20'd68549;
            1959: get_recip = 20'd68514;
            1960: get_recip = 20'd68479;
            1961: get_recip = 20'd68444;
            1962: get_recip = 20'd68409;
            1963: get_recip = 20'd68374;
            1964: get_recip = 20'd68339;
            1965: get_recip = 20'd68305;
            1966: get_recip = 20'd68270;
            1967: get_recip = 20'd68235;
            1968: get_recip = 20'd68201;
            1969: get_recip = 20'd68166;
            1970: get_recip = 20'd68131;
            1971: get_recip = 20'd68097;
            1972: get_recip = 20'd68062;
            1973: get_recip = 20'd68028;
            1974: get_recip = 20'd67993;
            1975: get_recip = 20'd67959;
            1976: get_recip = 20'd67924;
            1977: get_recip = 20'd67890;
            1978: get_recip = 20'd67856;
            1979: get_recip = 20'd67821;
            1980: get_recip = 20'd67787;
            1981: get_recip = 20'd67753;
            1982: get_recip = 20'd67719;
            1983: get_recip = 20'd67685;
            1984: get_recip = 20'd67651;
            1985: get_recip = 20'd67616;
            1986: get_recip = 20'd67582;
            1987: get_recip = 20'd67548;
            1988: get_recip = 20'd67514;
            1989: get_recip = 20'd67481;
            1990: get_recip = 20'd67447;
            1991: get_recip = 20'd67413;
            1992: get_recip = 20'd67379;
            1993: get_recip = 20'd67345;
            1994: get_recip = 20'd67311;
            1995: get_recip = 20'd67278;
            1996: get_recip = 20'd67244;
            1997: get_recip = 20'd67210;
            1998: get_recip = 20'd67177;
            1999: get_recip = 20'd67143;
            2000: get_recip = 20'd67109;
            2001: get_recip = 20'd67076;
            2002: get_recip = 20'd67042;
            2003: get_recip = 20'd67009;
            2004: get_recip = 20'd66975;
            2005: get_recip = 20'd66942;
            2006: get_recip = 20'd66909;
            2007: get_recip = 20'd66875;
            2008: get_recip = 20'd66842;
            2009: get_recip = 20'd66809;
            2010: get_recip = 20'd66775;
            2011: get_recip = 20'd66742;
            2012: get_recip = 20'd66709;
            2013: get_recip = 20'd66676;
            2014: get_recip = 20'd66643;
            2015: get_recip = 20'd66610;
            2016: get_recip = 20'd66577;
            2017: get_recip = 20'd66544;
            2018: get_recip = 20'd66511;
            2019: get_recip = 20'd66478;
            2020: get_recip = 20'd66445;
            2021: get_recip = 20'd66412;
            2022: get_recip = 20'd66379;
            2023: get_recip = 20'd66346;
            2024: get_recip = 20'd66314;
            2025: get_recip = 20'd66281;
            2026: get_recip = 20'd66248;
            2027: get_recip = 20'd66215;
            2028: get_recip = 20'd66183;
            2029: get_recip = 20'd66150;
            2030: get_recip = 20'd66118;
            2031: get_recip = 20'd66085;
            2032: get_recip = 20'd66053;
            2033: get_recip = 20'd66020;
            2034: get_recip = 20'd65988;
            2035: get_recip = 20'd65955;
            2036: get_recip = 20'd65923;
            2037: get_recip = 20'd65890;
            2038: get_recip = 20'd65858;
            2039: get_recip = 20'd65826;
            2040: get_recip = 20'd65794;
            default: get_recip = 20'd0;
        endcase
    endfunction

    // golden model — mirrors attention.sv's SCORE/SCALE/SOFTMAX_ST/
    // WEIGHTED_SUM/OUTPUT_ST pipeline exactly, stage by stage
    function void compute_expected();
        logic signed [19:0] raw_scores   [SEQ_LEN-1:0][SEQ_LEN-1:0]; // ACCUM_WIDTH=20
        logic signed [SCORE_WIDTH-1:0] scaled_scores [SEQ_LEN-1:0][SEQ_LEN-1:0];

        softmax_smooth = 1'b0;
        weight_clipped = 1'b0;
        out_rail_hit   = 1'b0;

        // Stage 1 (SCORE): raw_scores[i][j] = Q[i] . K[j]
        for (int i = 0; i < SEQ_LEN; i++) begin
            for (int j = 0; j < SEQ_LEN; j++) begin
                automatic logic signed [19:0] acc = '0;
                for (int m = 0; m < D_K; m++)
                    acc += q[i][m] * k[j][m];
                raw_scores[i][j] = acc;
            end
        end

        // Stage 2 (SCALE): divide by sqrt(d_k)=4 via arithmetic right-shift
        for (int i = 0; i < SEQ_LEN; i++)
            for (int j = 0; j < SEQ_LEN; j++)
                scaled_scores[i][j] = raw_scores[i][j] >>> 2;

        // Stage 3 (SOFTMAX_ST): independent per-row softmax, using the
        // exact same LUT functions as softmax.sv itself
        for (int i = 0; i < SEQ_LEN; i++) begin
            automatic logic signed [SCORE_WIDTH-1:0] max_val;
            automatic logic signed [SCORE_WIDTH:0]   shifted [SEQ_LEN-1:0];
            automatic logic [WEIGHT_WIDTH-1:0]        exp_val [SEQ_LEN-1:0];
            automatic logic [10:0]                    exp_sum;
            automatic longint unsigned                 recip_prod;
            automatic longint unsigned                 raw_weight;

            max_val = scaled_scores[i][0];
            for (int j = 1; j < SEQ_LEN; j++)
                if (scaled_scores[i][j] > max_val) max_val = scaled_scores[i][j];

            exp_sum = '0;
            for (int j = 0; j < SEQ_LEN; j++) begin
                shifted[j] = scaled_scores[i][j] - max_val;
                exp_val[j] = get_exp_val(shifted[j]);
                exp_sum   += exp_val[j];
            end

            begin
                automatic int nonzero_count = 0;
                for (int j = 0; j < SEQ_LEN; j++) begin
                    recip_prod = get_recip(exp_sum);
                    raw_weight = (longint'(exp_val[j]) * 256 * recip_prod) >> RECIP_SHIFT;
                    if (raw_weight > 255) weight_clipped = 1'b1;
                    exp_weights[i][j] = (raw_weight > 255) ? 8'd255 : raw_weight[WEIGHT_WIDTH-1:0];
                    if (exp_weights[i][j] != 0) nonzero_count++;
                end
                if (nonzero_count > 1) softmax_smooth = 1'b1;
            end
        end

        // Stage 4 (WEIGHTED_SUM + OUTPUT_ST): weights(8x8) x V(8x16) -> out(8x16),
        // undo the Q0.8 scale (>>>8), then clip to DATA_WIDTH range
        for (int i = 0; i < SEQ_LEN; i++) begin
            for (int c = 0; c < D_K; c++) begin
                automatic logic signed [18:0] acc; // WEIGHTED_ACCUM_WIDTH=19
                automatic logic signed [18:0] rescaled;
                localparam signed [DATA_WIDTH-1:0] OUT_MAX = (1 <<< (DATA_WIDTH-1)) - 1;
                localparam signed [DATA_WIDTH-1:0] OUT_MIN = -(1 <<< (DATA_WIDTH-1));

                acc = '0;
                for (int j = 0; j < SEQ_LEN; j++)
                    acc += $signed({1'b0, exp_weights[i][j]}) * v[j][c];
                rescaled = acc >>> 8;

                if (rescaled > OUT_MAX || rescaled < OUT_MIN) out_rail_hit = 1'b1;
                exp_out[i][c] = (rescaled > OUT_MAX) ? OUT_MAX :
                                 (rescaled < OUT_MIN) ? OUT_MIN : rescaled[DATA_WIDTH-1:0];
            end
        end
    endfunction

    function void post_randomize();
        compute_expected();
    endfunction

endclass

// ─────────────────────────────────────────
// Sequence
// ─────────────────────────────────────────
class attention_sequence extends uvm_sequence #(attention_seq_item);
    `uvm_object_utils(attention_sequence)

    int unsigned num_transactions;

    function new(string name = "attention_sequence");
        super.new(name);
        num_transactions = 50;
    endfunction

    task body();
        attention_seq_item item;
        repeat (num_transactions) begin
            item = attention_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_fatal("RAND_FAIL", "Randomization failed");
            finish_item(item);
        end
    endtask

endclass

// ─────────────────────────────────────────
// Driver
// ─────────────────────────────────────────
class attention_driver extends uvm_driver #(attention_seq_item);
    `uvm_component_utils(attention_driver)

    virtual attention_if vif;
    localparam int SEQ_LEN    = 8;
    localparam int D_K        = 16;
    localparam int DATA_WIDTH = 8;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual attention_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Driver could not get virtual interface")
    endfunction

    // loads one row over the shared bus -- takes exactly one clock edge.
    // A single parameterized task is fine here (unlike the iverilog
    // directed testbench, which needed three separate load_q/k/v_row
    // tasks because iverilog rejects unpacked-array task arguments --
    // this testbench only ever runs on a real SV simulator, EDA
    // Playground's Aldec Riviera-PRO, which supports it directly).
    task automatic load_row(input logic [1:0] sel, input int row,
                             input logic signed [DATA_WIDTH-1:0] row_vals [D_K]);
        for (int m = 0; m < D_K; m++)
            vif.driver_cb.row_data[DATA_WIDTH*(m+1)-1 -: DATA_WIDTH] <= row_vals[m];
        vif.driver_cb.row_addr   <= row[2:0];
        vif.driver_cb.matrix_sel <= sel;
        vif.driver_cb.load_valid <= 1;
        @(vif.driver_cb);
    endtask

    task run_phase(uvm_phase phase);
        attention_seq_item item;
        vif.driver_cb.load_valid <= 0;
        vif.driver_cb.start      <= 0;
        vif.driver_cb.row_data   <= 0;
        vif.driver_cb.row_addr   <= 0;
        vif.driver_cb.matrix_sel <= 0;
        wait (vif.rst_n === 1'b1);
        @(vif.driver_cb);
        forever begin
            seq_item_port.get_next_item(item);

            for (int r = 0; r < SEQ_LEN; r++) load_row(2'b00, r, item.q[r]);
            for (int r = 0; r < SEQ_LEN; r++) load_row(2'b01, r, item.k[r]);
            for (int r = 0; r < SEQ_LEN; r++) load_row(2'b10, r, item.v[r]);

            // load_valid MUST drop before/with start -- attention.sv's
            // IDLE state checks load_valid with priority over start
            // (if/else if), so a still-high load_valid would silently
            // swallow the start pulse and hang the FSM
            vif.driver_cb.load_valid <= 0;
            vif.driver_cb.start      <= 1;
            @(vif.driver_cb);
            vif.driver_cb.start <= 0;

            // blind for ~400 cycles, no handshake back until out_tlast
            // fires on the 8th out_valid pulse (not the 1st -- see the
            // out_valid-vs-out_tlast discussion above)
            do @(vif.driver_cb); while (!vif.driver_cb.out_tlast);
            seq_item_port.item_done();
        end
    endtask

endclass

// ─────────────────────────────────────────
// Monitor
// ─────────────────────────────────────────
class attention_monitor extends uvm_monitor;
    `uvm_component_utils(attention_monitor)

    virtual attention_if vif;
    uvm_analysis_port #(attention_seq_item) ap;
    localparam int SEQ_LEN    = 8;
    localparam int D_K        = 16;
    localparam int DATA_WIDTH = 8;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual attention_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Monitor could not get virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
        attention_seq_item item;
        int row_idx;

        forever begin
            item = attention_seq_item::type_id::create("item");

            // Phase 1: watch the load bus until start fires. Decode
            // matrix_sel/row_addr off the wire each cycle, the same way
            // attention.sv's own IDLE-state case statement does -- an
            // independent read of what actually happened, not an
            // assumption about what the driver meant to send (see
            // discussion above).
            forever begin
                @(vif.monitor_cb);
                if (vif.monitor_cb.load_valid) begin
                    case (vif.monitor_cb.matrix_sel)
                        2'b00: for (int m = 0; m < D_K; m++)
                                   item.q[vif.monitor_cb.row_addr][m] =
                                       $signed(vif.monitor_cb.row_data[DATA_WIDTH*(m+1)-1 -: DATA_WIDTH]);
                        2'b01: for (int m = 0; m < D_K; m++)
                                   item.k[vif.monitor_cb.row_addr][m] =
                                       $signed(vif.monitor_cb.row_data[DATA_WIDTH*(m+1)-1 -: DATA_WIDTH]);
                        2'b10: for (int m = 0; m < D_K; m++)
                                   item.v[vif.monitor_cb.row_addr][m] =
                                       $signed(vif.monitor_cb.row_data[DATA_WIDTH*(m+1)-1 -: DATA_WIDTH]);
                        default: ; // matrix_sel == 2'b11 unused
                    endcase
                end
                // relies on the same driver/DUT contract as attention.sv's
                // own IDLE priority mux: load_valid and start are never
                // both high the same cycle
                if (vif.monitor_cb.start) break;
            end

            // Phase 2/3: blind until the first out_valid, then capture all
            // 8 streamed rows -- no separate "phase 2" loop needed, the
            // wait-for-out_valid behavior falls out of this loop's own
            // if-check
            row_idx = 0;
            while (row_idx < SEQ_LEN) begin
                @(vif.monitor_cb);
                if (vif.monitor_cb.out_valid) begin
                    for (int m = 0; m < D_K; m++)
                        item.act_out[row_idx][m] =
                            $signed(vif.monitor_cb.out_row_data[DATA_WIDTH*(m+1)-1 -: DATA_WIDTH]);
                    row_idx++;
                end
            end

            ap.write(item);
        end
    endtask

endclass

// ─────────────────────────────────────────
// Scoreboard
// ─────────────────────────────────────────
class attention_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(attention_scoreboard)

    uvm_analysis_imp #(attention_seq_item, attention_scoreboard) imp;
    localparam int SEQ_LEN = 8;
    localparam int D_K     = 16;

    int pass_count;
    int fail_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        pass_count = 0;
        fail_count = 0;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
    endfunction

    function void write(attention_seq_item item);
        int mismatches;
        item.compute_expected();
        mismatches = 0;
        for (int i = 0; i < SEQ_LEN; i++)
            for (int c = 0; c < D_K; c++)
                if (item.exp_out[i][c] !== item.act_out[i][c])
                    mismatches++;

        if (mismatches != 0) begin
            `uvm_error("SCOREBOARD", $sformatf(
                "FAIL: %0d/%0d output elements mismatched (softmax_smooth=%0b weight_clipped=%0b out_rail_hit=%0b)",
                mismatches, SEQ_LEN*D_K, item.softmax_smooth, item.weight_clipped, item.out_rail_hit))
            fail_count++;
        end else begin
            pass_count++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD",
            $sformatf("\nResults: %0d passed, %0d failed\n",
            pass_count, fail_count), UVM_LOW)
    endfunction

endclass

// ─────────────────────────────────────────
// Coverage Collector
// ─────────────────────────────────────────
class attention_coverage extends uvm_component;
    `uvm_component_utils(attention_coverage)

    uvm_analysis_imp #(attention_seq_item, attention_coverage) imp;

    logic cov_force_tie;
    logic cov_softmax_smooth;
    logic cov_weight_clipped;
    logic cov_out_rail_hit;

    covergroup cg;
        option.per_instance = 1;

        // stimulus knob: did we ask for a forced tie
        cp_force_tie: coverpoint cov_force_tie {
            bins not_forced = {0};
            bins forced     = {1};
        }

        // behavioral fact: did the golden model's softmax actually stay
        // smooth (>1 nonzero weight in some row) at least once, and did it
        // also actually collapse to hard argmax at least once -- proves
        // BOTH regimes documented in CLAUDE.md's "~64% collapse" finding
        // get genuinely exercised, not just that force_tie was driven
        cp_softmax_smooth: coverpoint cov_softmax_smooth {
            bins hard_argmax = {0};
            bins smooth      = {1};
        }

        // did the normalization clip (exp_val*256/sum -> clip to 255)
        // actually trigger, same "clip after rounding" class of case as
        // softmax_tb's dominant_score_clips_255 test
        cp_weight_clipped: coverpoint cov_weight_clipped {
            bins not_clipped = {0};
            bins clipped     = {1};
        }

        // did the final output clip (OUT_MIN/OUT_MAX) actually trigger
        cp_out_rail_hit: coverpoint cov_out_rail_hit {
            bins not_hit = {0};
            bins hit     = {1};
        }

        // cross: does a forced tie reliably correlate with a smooth
        // softmax outcome, or does the natural random 20%/80% split
        // already cover both independently
        cx_tie_vs_smooth: cross cp_force_tie, cp_softmax_smooth;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
    endfunction

    function void write(attention_seq_item item);
        // must call compute_expected() itself -- cannot rely on the
        // scoreboard's write() having already populated these fields,
        // same rule as Rung 4's cp_round_applied lesson
        item.compute_expected();

        cov_force_tie      = item.force_tie;
        cov_softmax_smooth = item.softmax_smooth;
        cov_weight_clipped = item.weight_clipped;
        cov_out_rail_hit   = item.out_rail_hit;
        cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("COVERAGE", $sformatf(
            "\nOverall covergroup coverage: %0.2f%%\n  cp_force_tie:      %0.2f%%\n  cp_softmax_smooth: %0.2f%%\n  cp_weight_clipped: %0.2f%%\n  cp_out_rail_hit:   %0.2f%%\n  cx_tie_vs_smooth:  %0.2f%%\n",
            cg.get_coverage(),
            cg.cp_force_tie.get_coverage(),
            cg.cp_softmax_smooth.get_coverage(),
            cg.cp_weight_clipped.get_coverage(),
            cg.cp_out_rail_hit.get_coverage(),
            cg.cx_tie_vs_smooth.get_coverage()), UVM_LOW)
    endfunction

endclass

// ─────────────────────────────────────────
// Agent
// ─────────────────────────────────────────
class attention_agent extends uvm_agent;
    `uvm_component_utils(attention_agent)

    attention_driver                     driver;
    attention_monitor                    monitor;
    uvm_sequencer #(attention_seq_item)  sequencer;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver    = attention_driver::type_id::create("driver",    this);
        monitor   = attention_monitor::type_id::create("monitor", this);
        sequencer = uvm_sequencer #(attention_seq_item)::type_id::create(
                        "sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass

// ─────────────────────────────────────────
// Environment
// ─────────────────────────────────────────
class attention_env extends uvm_env;
    `uvm_component_utils(attention_env)

    attention_agent      agent;
    attention_scoreboard scoreboard;
    attention_coverage   coverage;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = attention_agent::type_id::create("agent", this);
        scoreboard = attention_scoreboard::type_id::create(
                         "scoreboard", this);
        coverage   = attention_coverage::type_id::create(
                         "coverage", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.monitor.ap.connect(scoreboard.imp);
        agent.monitor.ap.connect(coverage.imp);
    endfunction

endclass

// ─────────────────────────────────────────
// Test
// ─────────────────────────────────────────
class attention_test extends uvm_test;
    `uvm_component_utils(attention_test)

    attention_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = attention_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        attention_sequence seq;
        phase.raise_objection(this);
        seq = attention_sequence::type_id::create("seq");
        seq.num_transactions = 50;
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask

endclass

// ─────────────────────────────────────────
// Top module
// ─────────────────────────────────────────
module top;
    parameter int SEQ_LEN     = 8;
    parameter int D_K         = 16;
    parameter int DATA_WIDTH  = 8;
    parameter int ACCUM_WIDTH = 20;

    logic clk;

    initial clk = 0;
    always #5 clk = ~clk;

    attention_if #(
        .SEQ_LEN(SEQ_LEN),
        .D_K(D_K),
        .DATA_WIDTH(DATA_WIDTH)
    ) vif (.clk(clk));

    attention #(
        .SEQ_LEN(SEQ_LEN),
        .D_K(D_K),
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(vif.rst_n),
        .row_data(vif.row_data),
        .row_addr(vif.row_addr),
        .matrix_sel(vif.matrix_sel),
        .load_valid(vif.load_valid),
        .start(vif.start),
        .out_row_data(vif.out_row_data),
        .out_valid(vif.out_valid),
        .out_tlast(vif.out_tlast)
    );

    // run_test MUST be called at time 0
    initial begin
        uvm_config_db #(virtual attention_if)::set(
            null, "*", "vif", vif);
        run_test("attention_test");
    end

    // reset sequence runs in parallel
    initial begin
        vif.rst_n      = 0;
        vif.load_valid = 0;
        vif.start      = 0;
        vif.row_data   = 0;
        vif.row_addr   = 0;
        vif.matrix_sel = 0;
        repeat(3) @(posedge clk);
        vif.rst_n = 1;
    end
endmodule
