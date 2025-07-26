`include "spi.v"
module tb;
parameter ADDR_WIDTH=8;
parameter DATA_WIDTH=8;
parameter NUM_TXS=8;

reg pclk_i,prst_i,pwrite_i,penable_i;
wire pready_o,perror_o;
reg [ADDR_WIDTH-1:0]paddr_i;
reg [DATA_WIDTH-1:0]pwdata_i;
wire [DATA_WIDTH-1:0]prdata_o;
reg miso;
wire sclk_o;
wire mosi;
wire [3:0]ssel;
//registers
reg [ADDR_WIDTH-1:0]addr_regA[NUM_TXS-1:0];  //0 to 7h
reg [DATA_WIDTH-1:0]data_regA[NUM_TXS-1:0];  //10 to 17h
reg [DATA_WIDTH-1:0]ctrl_reg;  //20h
integer i;

spi_ctrl #(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH),.NUM_TXS(NUM_TXS))dut(pclk_i,prst_i,paddr_i,pwrite_i,pwdata_i,penable_i,prdata_o,pready_o,perror_o,sclk_o,mosi,miso,ssel);


//clk generation
initial begin
	pclk_i=0;
	forever #5 pclk_i= ~pclk_i;
end

initial begin
	reset_dut();
	write_regA();
	read_regA(); //to confirm if the values are written properly
//	#100;
	$finish;
end

//reset condition
task reset_dut();
begin
	prst_i=1;
	paddr_i=0;
	pwrite_i=0;
	pwdata_i=0;
	penable_i=0;
	miso = 1;
	@(posedge pclk_i);
	prst_i=0;
end
endtask

//write condition
task write_regA();
begin
	//addr regA
	for(i=0;i<NUM_TXS; i=i+1) begin
		@(posedge pclk_i);
		paddr_i=i;
		pwdata_i=$random;
		pwrite_i=1;
		penable_i=1;
		wait (pready_o==1);
	end
		@(posedge pclk_i);
		paddr_i=0;          
		pwdata_i=0;
		pwrite_i=0;
		penable_i=0;

	//data regA
	for(i=0;i<NUM_TXS; i=i+1) begin
		@(posedge pclk_i);
		paddr_i=i + 8'h10;
		pwdata_i=$random;
		pwrite_i=1;
		penable_i=1;
		wait (pready_o==1);
	end
		@(posedge pclk_i);
		paddr_i=0;          
		pwdata_i=0;
		pwrite_i=0;
		penable_i=0;
	
	//ctrl reg
		@(posedge pclk_i);
		paddr_i= 8'h20;
		pwdata_i=$random;
		pwrite_i=1;
		penable_i=1;
		wait (pready_o==1);
		@(posedge pclk_i);
		paddr_i=0;          
		pwdata_i=0;
		pwrite_i=0;
		penable_i=0;

	
end
endtask

//read logic
task read_regA();
begin
		//addr regA
	for(i=0;i<NUM_TXS; i=i+1) begin
		@(posedge pclk_i);
		paddr_i=i;
		pwrite_i=0;
		penable_i=1;
		wait (pready_o==1);
	end
		@(posedge pclk_i);
		paddr_i=0;          
		penable_i=0;

	//data regA
	for(i=0;i<NUM_TXS; i=i+1) begin
		@(posedge pclk_i);
		paddr_i=i + 8'h10;
		pwrite_i=0;
		penable_i=1;
		wait (pready_o==1);
	end
		@(posedge pclk_i);
		paddr_i=0;          
		penable_i=0;
	
	//ctrl reg
		@(posedge pclk_i);
		paddr_i= 8'h20;
		pwrite_i=0;
		penable_i=1;
		wait (pready_o==1);
		@(posedge pclk_i);
		paddr_i=0;          
		penable_i=0;	
end
endtask
endmodule
