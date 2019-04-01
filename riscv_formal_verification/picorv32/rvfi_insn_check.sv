// Copyright Yuxin Wang (modified based on Clifford work)
// Copyright (C) 2017  Clifford Wolf <clifford@symbioticeda.com>
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
// ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
// ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
// OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.



//`include "rtl/serv_params.vh"
`include "jg_define.sv"

module rvfi_insn_check (
	input clock, reset, check,
	`RVFI_INPUTS
);

`ifdef RISCV_FORMAL_CSR_MISA
		wire [`RISCV_FORMAL_XLEN   - 1 : 0] csr_misa_rdata = rvfi_csr_misa_rdata[channel_idx*`RISCV_FORMAL_XLEN   +: `RISCV_FORMAL_XLEN];
		wire [`RISCV_FORMAL_XLEN   - 1 : 0] csr_misa_rmask = rvfi_csr_misa_rmask[channel_idx*`RISCV_FORMAL_XLEN   +: `RISCV_FORMAL_XLEN];
		wire [`RISCV_FORMAL_XLEN   - 1 : 0] spec_csr_misa_rmask;
`endif		
		
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
		wire [`RISCV_FORMAL_XLEN   - 1 : 0] spec_mem_wdata;
		wire [`RISCV_FORMAL_XLEN   - 1 : 0] rs1_rdata_or_zero = spec_rs1_addr != 0 ? rvfi_rs1_rdata : 0;
		wire [`RISCV_FORMAL_XLEN   - 1 : 0] rs2_rdata_or_zero = spec_rs2_addr != 0 ? rvfi_rs2_rdata : 0;
 
		wire valid  = !reset && rvfi_valid;
		`RISCV_FORMAL_INSN_MODEL  insn_spec (
			.rvfi_valid          (valid              ),
			.rvfi_insn           (rvfi_insn          ),
			.rvfi_pc_rdata       (rvfi_pc_rdata      ),
			.rvfi_rs1_rdata      (rvfi_rs1_rdata	 ),
			.rvfi_rs2_rdata      (rvfi_rs2_rdata     ),
			.rvfi_mem_rdata      (rvfi_mem_rdata     ),

`ifdef RISCV_FORMAL_CSR_MISA
			.rvfi_csr_misa_rdata (csr_misa_rdata     ),
			.spec_csr_misa_rmask (spec_csr_misa_rmask),
`endif

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

		wire insn_pma_x, mem_pma_r, mem_pma_w;

		wire [1:0] mem_log2len =
			((spec_mem_rmask | spec_mem_wmask) & 8'b 1111_0000) ? 3 :
			((spec_mem_rmask | spec_mem_wmask) & 8'b 0000_1100) ? 2 :
			((spec_mem_rmask | spec_mem_wmask) & 8'b 0000_0010) ? 1 : 0;

`ifdef RISCV_FORMAL_PMA_MAP
		`RISCV_FORMAL_PMA_MAP insn_pma (
			.address(rvfi_pc_rdata),
			.log2len(insn[1:0] == 2'b11 ? 2'd2 : 2'd1),
			.X(insn_pma_x)
		);

		`RISCV_FORMAL_PMA_MAP mem_pma (
			.address(spec_mem_addr),
			.log2len(mem_log2len),
			.R(mem_pma_r),
			.W(mem_pma_w)
		);
`else
		assign insn_pma_x = 1;
		assign mem_pma_r = 1;
		assign mem_pma_w = 1;
`endif

		wire mem_access_fault = (spec_mem_rmask && !mem_pma_r) || (spec_mem_wmask && !mem_pma_w) ||
				((spec_mem_rmask || spec_mem_wmask) && !`rvformal_addr_valid(spec_mem_addr));
		integer i;

		always @* begin
			valid_high: assert property ( @(posedge clock) !(rvfi_valid) );
			if (!reset) begin
			 	cover(spec_valid);
			 	cover(spec_valid && !rvfi_trap);
			 	cover(check && spec_valid);
			 	cover(check && spec_valid && !rvfi_trap);
			 end
			if (!reset && check) begin
				 assume(spec_valid);
				 if (!`rvformal_addr_valid(rvfi_pc_rdata) || !insn_pma_x || mem_access_fault) begin
				 	assert(rvfi_trap);
				 	assert(rvfi_rd_addr == 0);
				 	assert(rvfi_rd_wdata == 0);
				 	assert(rvfi_mem_wmask == 0);
				 end 
				 else begin
					
				 	if (!spec_trap) begin
				 		if (spec_rs1_addr != 0)
				 			assert property ( spec_rs1_addr == rvfi_rs1_addr);
				 		if (spec_rs2_addr != 0)
				 			assert property ( spec_rs2_addr == rvfi_rs2_addr);

						rd_addr_check: assert property (spec_rd_addr == rvfi_rd_addr);
						rd_wrdata_check: assert property (spec_rd_wdata == rvfi_rd_wdata);  //core property of addition
						PCcheck: assert property ( `rvformal_addr_eq( spec_pc_wdata, rvfi_pc_wdata) );  

				 		if (spec_mem_wmask || spec_mem_rmask) begin
				 		 	   assert(`rvformal_addr_eq(spec_mem_addr, rvfi_mem_addr));
				 		 end

				 		 for (i = 0; i < `RISCV_FORMAL_XLEN/8; i = i+1) begin
				 		 	   if (spec_mem_wmask[i]) begin
				 		 	   	  assert(rvfi_mem_wmask[i]);
				 		 	   	  assert(spec_mem_wdata[i*8 +: 8] == rvfi_mem_wdata[i*8 +: 8]);
				 		 	   end else if (rvfi_mem_wmask[i]) begin
				 		 	   	  assert(rvfi_mem_rmask[i]);
				 		 	   	  assert(rvfi_mem_rdata[i*8 +: 8] == rvfi_mem_wdata[i*8 +: 8]);
				 		 	   end
				 		 	   if (spec_mem_rmask[i]) begin
				 		 	   	  assert(rvfi_mem_rmask[i]);
				 		 	   end
				 		 end
				 	end
				 	trap_check: assert property ( spec_trap == rvfi_trap);
				 end
			end
		end
endmodule
