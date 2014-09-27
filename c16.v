
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module c16(

	//////////// LED //////////
	LEDG,
	LEDR,

	//////////// KEY //////////
	CPU_RESET_n,
	KEY,

	//////////// SW //////////
	SW,

	//////////// SEG7 //////////
	HEX0,
	HEX1,
	HEX2,
	HEX3 
);

//=======================================================
//  PARAMETER declarations
//=======================================================
	 // Not sure if these should be 4'
	 parameter I = 3'h0;
    parameter F = 3'h1;
    parameter D = 3'h2;
    parameter X = 3'h3;
    parameter M = 3'h4;
    parameter W = 3'h5;

//=======================================================
//  PORT declarations
//=======================================================

//////////// LED //////////
output		     [7:0]		LEDG;
output		     [9:0]		LEDR;

//////////// KEY //////////
input 		          		CPU_RESET_n;
input 		     [3:0]		KEY;

//////////// SW //////////
input 		     [9:0]		SW;

//////////// SEG7 //////////
output		     [6:0]		HEX0;
output		     [6:0]		HEX1;
output		     [6:0]		HEX2;
output		     [6:0]		HEX3;


/////////////////////////
// The processor state //
/////////////////////////
	 
    reg [15:0]regs[7:0];     // register
    reg [15:0]pc;             // the pc
	 reg [2:0]cur_state = I;
	 reg [2:0]next_state;
	initial begin
		pc = 0;
		regs[0] = 0;
		regs[1] = 0;
		regs[2] = 0;
		regs[3] = 0;
		regs[4] = 0;
		regs[5] = 0;
		regs[6] = 0;
		regs[7] = 0;
	end
	 
///////////
// fetch //
///////////
	 
    reg [15:0]inst;           // the instruction
	 
    // hardwired program, need to start some where
    always @(*) begin
        case(pc)
            16'h0000: inst = 16'h00e5; // r0 = r7 + 5 (should be 5)
            16'h0001: inst = 16'h0800; // r0 = r0 + r0 (r0 = 10)
            16'h0002: inst = 16'h210f; // r1 = (r0 < 15) (r1 should be 1)
            16'h0003: inst = 16'hf0ff; // pc = r7 - 1 if r0 == 0 (should skip)
            16'h0004: inst = 16'h2901; // r1 = (r0 < r1) (r1 should now be 0)
            16'h0005: inst = 16'hf905; // pc = pc + 5 if r1 == 0 (should set pc to 0xa)
            16'h000a: inst = 16'hd2ef; // r2 = pc (0xa); pc = r7 + 15 (15 since r7 is always 0)
            16'h000f: inst = 16'hda0a; // r2 = pc (0xe); pc = pc + 10
            16'h0019: inst = 16'hc342; // r3 = r2 + 2 (r3 = 0x11)
            16'h001a: inst = 16'hcb01; // r3 = pc + 1 (r3 = 0x1b)
            16'h001b: inst = 16'h8464; // r4 = r3 << 4 (r4 = 0x1b0)
            16'h001c: inst = 16'h8d48; // r5 = r2 << 8 (r5 = 0xf00)
            16'h001d: inst = 16'h8f48; // r7 = r2 << 8 (r7 should remain 0 since it is the zero register)
            default: inst = 16'bxxxxxxxxxxxxxxxx;
        endcase
    end
	 
	///////////////////
	// decode & regs //
	///////////////////

    // Fields in the instruction
    wire [4:0] opcode = inst[15:11];
    wire [2:0] rd = inst[10:8];
    wire [2:0] ra = inst[7:5];
    wire [2:0] rb = inst[2:0];
    // Immediate values, sign extended using our custom module
    wire [15:0] imm5;
    wire [15:0] imm8;
    sign_extend_16 #(5) (inst[4:0], imm5);
    sign_extend_16 #(8) (inst[7:0], imm8);
    // Values loaded from registers
    wire [15:0] va = regs[ra];
    wire [15:0] vb = regs[rb];
    wire [15:0] vd = regs[rd];
 
/////////////
// execute //
/////////////
 
reg [15:0] nextpc;        // the next pc
reg rfen;                 // this instructions modifies a register
reg [15:0]rfdata;         // the register value
 
always @(*) begin
    rfen = 0;
    rfdata = 0;
    nextpc = pc + 1;
    case (opcode)
        // Add, f = 0
        5'b00000: begin
            rfen = 1;
            rfdata = imm5 + va;
        end
        
        // Add, f = 1
        5'b00001: begin
            rfen = 1;
            rfdata = va + vb;
    	end
             
        // Slt, f = 0
        5'b00100: begin
            rfen = 1;
            rfdata = (va < imm5);
        end
         
        // Slt, f = 1
        5'b00101: begin
            rfen = 1;
            rfdata = (va < vb);
        end
            
        // Lea, f = 0
        5'b11000: begin
            rfen = 1;
            rfdata = va + imm5;
        end
            
        // Lea, f = 1
        5'b11001: begin
            rfen = 1;
            rfdata = pc + imm8;
        end
            
         // Call, f = 0
        5'b11010: begin
            rfen = 1;
            rfdata = pc;
            nextpc = va + imm5;
        end
            
        // Call, f = 1
        5'b11011: begin
            rfen = 1;
            rfdata = pc;
            nextpc = pc + imm8;
        end
            
        // brz, f = 0
        5'b11110: begin
            if (vd == 0)
                nextpc = va + imm5;
        end
            
        // brz, f = 1
        5'b11111: begin
            if (vd == 0)
                nextpc = pc + imm8;
        end
		  
		  // ld, f = 0
		  5'b10100: begin
		  
		  end
		  
		  // ld, f = 1
		  5'b10101: begin
		  
		  end
		  
		  // st, f = 0
		  5'b10110: begin
		  
		  end
		  
		  // st, f = 1
		  5'b10111: begin
		  
		  end
    endcase
end
	 
wire clk = KEY[0];        // single step using key0
	 
///////////////////
// debug support //
///////////////////
reg [15:0]debug;
assign LEDG[0] = cur_state == I;
assign LEDG[1] = cur_state == F;
assign LEDG[2] = cur_state == D;
assign LEDG[3] = cur_state == X;
assign LEDG[4] = cur_state == M;
assign LEDG[5] = cur_state == W;
assign LEDR = pc[9:0];
display(debug[15:12], HEX3);
display(debug[11:8], HEX2);
display(debug[7:4], HEX1);
display(debug[3:0], HEX0);

// what do we display
always @(*) begin
    if (SW[3]) debug = inst;
    else debug = regs[SW[2:0]];
end

/////////////////////////
// The sequential part //
/////////////////////////
	 
always @(posedge clk) begin
    pc <= nextpc;
    // If the target is R7, don't write out the value
    if (rfen && rd != 7) regs[rd] <= rfdata;
end

endmodule

module display(NUM, HEX);
	input[3:0] NUM;
	
	output[6:0] HEX;
	reg[6:0] HEX;

	always @(*)
	case (NUM)
		4'h0 : HEX = 7'b1000000;
		4'h1 : HEX = 7'b1111001;
		4'h2 : HEX = 7'b0100100;
		4'h3 : HEX = 7'b0110000;
		4'h4 : HEX = 7'b0011001;
		4'h5 : HEX = 7'b0010010;
		4'h6 : HEX = 7'b0000010;
		4'h7 : HEX = 7'b1111000;
		4'h8 : HEX = 7'b0000000;
		4'h9 : HEX = 7'b0010000;
		4'hA : HEX = 7'b0001000;
		4'hB : HEX = 7'b0000011;
		4'hC : HEX = 7'b0100111;
		4'hD : HEX = 7'b0100001;
		4'hE : HEX = 7'b0000110;
		4'hF : HEX = 7'b0001110;
	endcase
endmodule

// Sign extension module
module sign_extend_16(IN, OUT);
    // The width of the input value in bits
    parameter INPUT_WIDTH;
    input [INPUT_WIDTH - 1:0]IN;
    output [15:0]OUT;
    
    reg [15:0] result;
    reg [15:0] all1 = 16'hffff;
    reg [15:0] all0 = 16'h0;
    
    always @(*)
        if (IN[INPUT_WIDTH - 1]) begin
            result[INPUT_WIDTH - 1:0] = IN;
            result[15:INPUT_WIDTH] = all1[15:INPUT_WIDTH];
        end else begin
            result[INPUT_WIDTH - 1:0] = IN;
            result[15:INPUT_WIDTH] = all0[15:INPUT_WIDTH];
        end
    
    assign OUT = result;
    
endmodule
