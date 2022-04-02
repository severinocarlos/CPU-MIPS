module CPU(

// Res & Clk

    input wire clk,
    input wire reset
);

// ------------------------- Flags da ULA ------------------------------ //
    
    wire Of;
    wire Ng;
    wire Zr;
    wire Eq;
    wire Gt;
    wire Lt;

//-----------------------------------------------------------------------//

// ----------------- Sinais de Controle dos mux's --------------------- //
    
    wire [1:0] M_selector_writereg;
    wire [2:0] M_selector_WDATA;
    wire M_selector_A;
    wire [1:0] M_selector_B;
    wire [2:0] M_selector_ALUOut;
    wire [2:0] M_selector_Memory;
    wire [4:0] M_WRREG_out;
    wire [31:0] mux_to_mem;
    wire [31:0] m_A_out;
    wire [31:0] m_B_out;
    wire [31:0] M_wdata_out;
    wire [31:0] M_ALU_out;

// --------------------------------------------------------------------- //


// ----------------- Sinais de controle de 1 bit ----------------------- //

    wire PC_w;
    wire ALU_w;
    wire MEM_w;
    wire IR_w;
    wire RB_w;
    wire AB_w; // escreve ao mesmo tempo em A e B

// ---------------------------------------------------------------------- //


// ------------------ sinais de controle com mais de 1 bit -------------- //
    wire [2:0] ULA_c;
// ---------------------------------------------------------------------- //

// IR
    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] IMEDIATO;

    
    wire [31:0] PC_out;
 


//-------------------- Fios que registradores ----------------------------- //
    
    wire [31:0] ULA_result;
    wire [31:0] MEM_to_IR;
    wire [31:0] RB_to_A;
    wire [31:0] RB_to_B;
    wire [31:0] A_out;
    wire [31:0] B_out;
    wire [31:0] MEM_in;
    wire [31:0] LSize_out;
    wire [31:0] Hi_out;
    wire [31:0] Lo_out;
    wire [31:0] Shift_out;
    wire [31:0] s_ext_1to32_out;
    wire [31:0] shift_ext_out;
    wire [31:0] signExt_out;
    wire [31:0] shift_2_out;
    wire [31:0] ALU_out;
    wire [31:0] ext_26_to_28_out;
    wire [31:0] EPCOut;

    Registrador          PC_(
        clk,
        reset,
        PC_w,
        ALU_out,
        PC_out
    );

    mux_Mem            Mux_M_(
        M_selector_Memory,
        PC_out,
        ALU_out,
        A_out,
        B_out,
        mux_to_mem
    );

    Memoria            Mem_(
        mux_to_mem,
        clk,
        MEM_w,
        MEM_in,
        MEM_to_IR
    );


    Instr_Reg          IR_(
        clk,
        reset,
        IR_w,
        MEM_to_IR,
        OPCODE,
        RS,
        RT,
        IMEDIATO
    );
   
    mux_writereg       M_WRREG_(
        M_selector_writereg,
        RT,
        IMEDIATO,
        M_WRREG_out // ver quais desses precisa instanciar la em cima
    );

    mux_writeData      M_WDATA_(
        M_selector_WDATA,
        ULA_out,
        LSize_out,
        Hi_out,
        Lo_out,
        Shift_out,
        s_ext_1to32_out, //obs
        shift_ext_out,
        M_wdata_out
    );

    Banco_reg        REG_BASE_(
        clk,
        reset,
        RB_w,
        RS,
        RT,
        M_WRREG_out,    // checar quais tem que ser instanciados la em cima
        M_wdata_out,
        RB_to_A,
        RB_to_B
    );

    Registrador      A_(
        clk,
        reset,
        AB_w,      // checar o que deve ser instanciado 
        RB_to_A,
        A_out
    );

    Registrador      B_(
        clk,
        reset,
        AB_w,      // checar o que deve ser instanciado 
        RB_to_B,
        B_out
    );

    
    mux_A            M_A(
        M_selector_A,
        PC_out,
        A_out,
        m_A_out
    );

    
    sign_extd         Sign_ext_(
        IMEDIATO,
        signExt_out
    );
    
    
    shift_lf_2        Shift_2(
        signExt_out,
        shift_2_out
    );

    
    mux_B             M_B(
        M_selector_B,
        B_out,
        signExt_out,
        shift_2_out,
        m_B_out
    );

    
    ula32           ULA_LA(
        m_A_out,
        m_B_out,
        ULA_c,
        ULA_result,
        Of,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt
    );

    
    Registrador     REG_ALUOut(
        clk,
        reset,
        ALU_w,
        ULA_result,
        ALU_out
    );

    
    mux_ALUOut     M_ALUOut(
        M_selector_ALUOut,
        ULA_result,
        ALU_out,
        ext_26_to_28_out, //OBS MUDAR ISSO AQ
        EPCOut,
        sign_ext_out,
        mux_to_mem,
        M_ALU_out
    );

    unid_control       UNI_CTRL(
        clk,
        reset,
        Of,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt,
        OPCODE,
        PC_w,
        M_selector_Memory,
        MEM_w,
        IR_w,
        M_selector_writereg,
        M_selector_WDATA,
        RB_w,
        AB_w,
        M_selector_A,
        M_selector_B,
        ULA_c,
        ALU_w,
        M_selector_ALUOut,
        reset
    );
endmodule