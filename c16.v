
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
    16'h0000: inst = 16'h0005; //r0 = r0 + 5
    16'h0001: inst = 16'h0101; //r1 = r0 + 1 
    16'h0002: inst = 16'h0a01; //r2 = r0 + r1 //this should equal eleven
    16'h0003: inst = 16'h0000; //no op // program end
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
    wire [15:0] imm5;
    wire [15:0] imm8;
    sine_extenz #(5) (inst[4:0], imm5);
    sine_extenz #(8) (inst[7:0], imm8);
    // Computed values
    wire [15:0] va = regs[ra];
    wire [15:0] vb = regs[rb];
    wire [15:0] vd = regs[rd];
     /*
 wire [3:0]src = inst[7:4];
 wire [3:0]dest = inst[3:0];
 wire [15:0]v0 = regs[src];
 wire [15:0]v1 = regs[dest];
    */
 
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
            
            //brazos, f = 1
            5'b11111: begin
                if (vd == 0)
                    nextpc = pc + imm8;
            end
            
            //shell, f = 0
            5'b1000?: begin
                rfen = 1;
                rfdata = va << imm5;
            end
        endcase
    end
	 
	 wire clk = KEY[0];        // single step using key0
	 
	 ///////////////////
         // debug support //
	 ///////////////////
         reg [15:0]debug;
	 assign LEDG = inst[15:8];
	 assign LEDR = pc[9:0];
     display(debug[15:12], HEX3);
     display(debug[11:8], HEX2);
     display(debug[7:4], HEX1);
     display(debug[3:0], HEX0);

  	 // what do we display
	 always @(*) begin
	     if (SW[3]) debug = pc;
             else debug = regs[SW[2:0]];
	 end


	 
	 /////////////////////////
	 // The sequential part //
	 /////////////////////////
	 
	 always @(posedge clk) begin
             pc <= nextpc;
             if (rfen) regs[rd] <= rfdata;
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

module sine_extenz(IN, OUT);
    parameter SIZZ;
    input [SIZZ - 1:0]IN;
    output [15:0]OUT;
    
    reg [15:0] result;
    reg [15:0] all1 = 16'hffff;
    reg [15:0] all0 = 16'h0;
    
	 always @(*)
    if (IN[SIZZ - 1]) begin
        result[SIZZ - 1:0] = IN;
        result[15:SIZZ] = all1[15:SIZZ];
    end else begin
        result[SIZZ - 1:0] = IN;
        result[15:SIZZ] = all0[15:SIZZ];
    end
    
    assign OUT = result;
    
endmodule

