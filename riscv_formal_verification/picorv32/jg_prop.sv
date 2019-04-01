
//`include "rtl/serv_params.vh"
`include "jg_define.sv"

module serv_top_verif(
    input wire 	      clk,
    input wire 	      i_rst,
    input wire 	      i_timer_irq,
    `RVFI_OUTPUTS
);

    wire [31:0] o_ibus_adr;
    wire 	      o_ibus_cyc;
    reg [31:0]  i_ibus_rdt;
    reg 	      i_ibus_ack;
    wire [31:0] o_dbus_adr;
    wire [31:0] o_dbus_dat;
    wire [3:0]  o_dbus_sel;
    wire 	      o_dbus_we;
    wire 	      o_dbus_cyc;
    reg [31:0]  i_dbus_rdt;
    reg 	      i_dbus_ack;
    // R-type instruction format
    wire valid                                    = !i_rst && rvfi_valid;
    wire [`RISCV_FORMAL_ILEN   - 1 : 0] insn      = rvfi_insn     [`RISCV_FORMAL_ILEN -1  : 0];
    wire                                trap      = rvfi_trap  ;  
    wire                                halt      = rvfi_halt  ;  
    wire                                intr      = rvfi_intr  ;  
    wire [                       4 : 0] rs1_addr  = rvfi_rs1_addr [4 :  0];
    wire [                       4 : 0] rs2_addr  = rvfi_rs2_addr [4  :  0];
    wire [`RISCV_FORMAL_XLEN   - 1 : 0] rs1_rdata = rvfi_rs1_rdata[`RISCV_FORMAL_XLEN - 1  : 0];
    wire [`RISCV_FORMAL_XLEN   - 1 : 0] rs2_rdata = rvfi_rs2_rdata[`RISCV_FORMAL_XLEN - 1  : 0];
    wire [                       4 : 0] rd_addr   = rvfi_rd_addr  [4  :  0];
    wire [`RISCV_FORMAL_XLEN   - 1 : 0] rd_wdata  = rvfi_rd_wdata [`RISCV_FORMAL_XLEN   - 1 : 0];
    wire [`RISCV_FORMAL_XLEN   - 1 : 0] pc_rdata  = rvfi_pc_rdata [`RISCV_FORMAL_XLEN   - 1 : 0];
    wire [`RISCV_FORMAL_XLEN   - 1 : 0] pc_wdata  = rvfi_pc_wdata [`RISCV_FORMAL_XLEN   - 1 : 0];
    wire [`RISCV_FORMAL_XLEN   - 1 : 0] mem_addr  = rvfi_mem_addr [`RISCV_FORMAL_XLEN   - 1 : 0];
    wire [`RISCV_FORMAL_XLEN/8 - 1 : 0] mem_rmask = rvfi_mem_rmask[`RISCV_FORMAL_XLEN/8 - 1 : 0];
    wire [`RISCV_FORMAL_XLEN/8 - 1 : 0] mem_wmask = rvfi_mem_wmask[`RISCV_FORMAL_XLEN/8 - 1 : 0];
    wire [`RISCV_FORMAL_XLEN   - 1 : 0] mem_rdata = rvfi_mem_rdata[`RISCV_FORMAL_XLEN   - 1 : 0];
    wire [`RISCV_FORMAL_XLEN   - 1 : 0] mem_wdata = rvfi_mem_wdata[`RISCV_FORMAL_XLEN   - 1 : 0];
    
    wire                                spec_valid;
    wire                                spec_trap;
    wire [                       4 : 0] spec_rs1_addr;
    wire [                       4 : 0] spec_rs2_addr;
    wire [                       4 : 0] spec_rd_addr;
    wire [`RISCV_FORMAL_XLEN   - 1 : 0] spec_rd_wdata;
    wire [`RISCV_FORMAL_XLEN   - 1 : 0] spec_pc_wdata;
    wire [`RISCV_FORMAL_XLEN   - 1 : 0] spec_mem_addr;
    wire [`RISCV_FORMAL_XLEN/8 - 1 : 0] spec_mem_rmask;
    wire [`RISCV_FORMAL_XLEN/8 - 1 : 0] spec_mem_wmask;
    wire [`RISCV_FORMAL_XLEN   - 1 : 0] spec_mem_wdat;
    

    reg [6:0] cycle_reg = 0;
	// wire [6:0] cycle;
	// assign cycle = cycle_reg;

	always @(posedge clk) begin
		if(i_rst) 
			cycle_reg <= 0;
		else 
			cycle_reg <= cycle_reg + (cycle_reg != `RISCV_FORMAL_CHECK_CYCLE);
    end
    wire check;
    assign check = (cycle_reg == `RISCV_FORMAL_CHECK_CYCLE);

    //add
    rvfi_insn_add insn_spec (
        .rvfi_valid          (valid              ),
        .rvfi_insn           (insn               ),
        .rvfi_pc_rdata       (pc_rdata           ),
        .rvfi_rs1_rdata      (rs1_rdata  		 ),
        .rvfi_rs2_rdata      (rs2_rdata  		 ),
        .rvfi_mem_rdata      (mem_rdata          ),
        .spec_valid          (spec_valid         ),
        .spec_trap           (spec_trap          ),
        .spec_rs1_addr       (spec_rs1_addr      ),
        .spec_rs2_addr       (spec_rs2_addr      ),
        .spec_rd_addr        (spec_rd_addr       ),
        .spec_rd_wdata       (spec_rd_wdata      ),
        .spec_pc_wdata       (spec_pc_wdata      ),
        .spec_mem_addr       (spec_mem_addr      ),
        .spec_mem_rmask      (spec_mem_rmask     ),
        .spec_mem_wmask      (spec_mem_wmask     ),
        .spec_mem_wdata      (spec_mem_wdata     )
    );
    
    //for pma_map, useless for add
    wire insn_pma_x, mem_pma_r, mem_pma_w;
    assign insn_pma_x = 1;
	assign mem_pma_r = 1;
    assign mem_pma_w = 1;
    
    wire mem_access_fault = (spec_mem_rmask && !mem_pma_r) || (spec_mem_wmask && !mem_pma_w) ||
				((spec_mem_rmask || spec_mem_wmask) && !`rvformal_addr_valid(spec_mem_addr));
    integer i;

    
    always @* begin
        if(!i_rst) begin
            cover(spec_valid);
            cover(spec_valid && !trap);
            cover(check && spec_valid);
			cover(check && spec_valid && !trap);
        end
        if(!i_rst && check) begin
            assume(spec_valid);
            if (!spec_trap) begin
                if (spec_rs1_addr != 0)
                    assert(spec_rs1_addr == rvfi_rs1_addr);
                if (spec_rs2_addr != 0)
                    assert(spec_rs2_addr == rvfi_rs2_addr);
                assert(spec_rd_addr == rvfi_rd_addr);
                assert(spec_rd_wdata == rvfi_rd_wdata);
                assert(`rvformal_addr_eq(spec_pc_wdata, rvfi_pc_wdata));
            end
            assert(spec_trap == rvfi_trap);
        end
    end

    /*

    reg flag_insn_same;
    reg [5:0] insn_cnt;
    reg [31:0] last_insn;
    always @ (posedge clk) begin
        if(i_rst) begin
            insn_cnt <= 0;
            flag_insn_same <= 1'b0;
        end
        else begin
            insn_cnt <= insn_cnt + 1'b1;
            last_insn <= rvfi_insn;
            
        end
    end

    assume property (
        @(posedge clk) disable iff(i_rst) insn_cnt |-> (rvfi_insn == last_insn)
    );
    assume property(
        @(posedge clk) disable iff(i_rst) 
        insn_funct7 == 7'b0000000 && insn_funct3 == 3'b000 && insn_opcode == 7'b0110011
    );
    assert property(
        @(posedge clk) disable iff (i_rst) 
        (insn_funct7 == 7'b0000000 && insn_funct3 == 3'b000 && insn_opcode == 7'b0110011)
        |-> ##20 (rvfi_rd_wdata == spec_rd_wdata )
    );
*/
    //AUX code from rvfi 
    // I-MEM
	always @(posedge clk) begin
		if (i_rst) begin
			assume (!i_ibus_ack);
		end
		if (!o_ibus_cyc) begin
			assume (!i_ibus_ack);
		end
	end
	// D-MEM
	always @(posedge clk) begin
		if (i_rst) begin
			assume (!i_dbus_ack);
		end
		if (!o_dbus_cyc) begin
			assume (!i_dbus_ack);
		end
    end
    
`ifdef MEMIO_FAIRNESS
	reg [2:0] timeout_ibus = 0;
	reg [2:0] timeout_dbus = 0;

	always @(posedge clk) begin
		timeout_ibus <= 0;
		timeout_dbus <= 0;

		if (o_ibus_cyc && !i_ibus_ack)
			timeout_ibus <= timeout_ibus + 1;

		if (o_dbus_cyc && !i_dbus_ack)
			timeout_dbus <= timeout_dbus + 1;

		assume (!timeout_ibus[2]);
		assume (!timeout_dbus[2]);
	end
`endif

endmodule

module Wrapper;
bind serv_top serv_top_verif serv_top_verif_inst(
    .clk,
	.i_rst,
    .i_timer_irq(1'b0),
    `RVFI_CONN,
	.o_ibus_adr(o_ibus_adr),
	.o_ibus_cyc(o_ibus_cyc),
	.i_ibus_rdt(i_ibus_rdt),
	.i_ibus_ack(i_ibus_ack),
	.o_dbus_adr(o_dbus_adr),
	.o_dbus_dat(o_dbus_dat),
	.o_dbus_sel(o_dbus_sel),
	.o_dbus_we (o_dbus_we ),
	.o_dbus_cyc(o_dbus_cyc),
	.i_dbus_rdt(i_dbus_rdt),
	.i_dbus_ack(i_dbus_ack)
);

endmodule
