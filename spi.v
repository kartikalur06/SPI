module spi_ctrl(pclk_i,prst_i,paddr_i,pwrite_i,pwdata_i,penable_i,prdata_o,pready_o,perror_o,
//SPI interface
sclk_o,mosi,miso,ssel);
parameter ADDR_WIDTH=8;
parameter DATA_WIDTH=8;
parameter NUM_TXS=8;


input pclk_i,prst_i,pwrite_i,penable_i;
output reg pready_o,perror_o;
input [ADDR_WIDTH-1:0]paddr_i;
input [DATA_WIDTH-1:0]pwdata_i;
output reg [DATA_WIDTH-1:0]prdata_o;
integer i;
output reg sclk_o;
output reg mosi;
input miso;
output reg [3:0]ssel;

//registers
reg [ADDR_WIDTH-1:0]addr_regA[NUM_TXS-1:0];  //0 to 7h
reg [DATA_WIDTH-1:0]data_regA[NUM_TXS-1:0];  //10 to 17h
reg [DATA_WIDTH-1:0]ctrl_reg;  //20h

//rst applied
always @(posedge pclk_i) begin
if (prst_i==1) begin
	prdata_o=0;
	pready_o=0;
	perror_o=0;
	sclk_o = 1;
	mosi = 1;
	ssel = 4'b0000;
	for(i=0;i<NUM_TXS;i=i+1) begin
	addr_regA[i]=0;
	data_regA[i]=0;
	end
	ctrl_reg = 0;
end


else begin
	if(penable_i==1) begin
		pready_o=1;
		if(pwrite_i==1) begin
			if(paddr_i >=8'h0 && paddr_i <= 8'h7) begin
				addr_regA[paddr_i] = pwdata_i;
			end
			if(paddr_i >=8'h10 && paddr_i <= 8'h17) begin
				data_regA[paddr_i-8'h10] = pwdata_i;
			end
			if(paddr_i == 8'h20) begin
				ctrl_reg = pwdata_i;
			end
		end
		else begin
			if(paddr_i >=8'h0 && paddr_i <= 8'h7) begin
				prdata_o=addr_regA[paddr_i];
			end
			if(paddr_i >=8'h10 && paddr_i <= 8'h17) begin
				prdata_o=data_regA[paddr_i-8'h10];
			end
			if(paddr_i == 8'h20) begin
				prdata_o = ctrl_reg;
			end

		end
	end
	else begin
	pready_o=0;
	end
end
end
endmodule
