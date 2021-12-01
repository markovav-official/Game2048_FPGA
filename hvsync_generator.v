module hvsync_generator(clk, reset, hsync, vsync, display_on, hpos, vpos);

  input clk;
  input reset;
  output reg hsync, vsync;
  output reg display_on;
  output reg [9:0] hpos;
  output reg [9:0] vpos;

	// horizontal constants
	parameter H_DISPLAY = 640; // horizontal display width
	parameter H_FRONT = 16; // horizontal right border (front porch)
	parameter H_SYNC = 96; // horizontal sync width
	parameter H_BACK = 48; // horizontal left border (back porch)
	// vertical constants
	parameter V_DISPLAY = 480; // vertical display height
	parameter V_BOTTOM = 10; // vertical bottom border
	parameter V_SYNC = 2; // vertical sync # lines
	parameter V_TOP = 33; // vertical top border
	// derived constants

	parameter H_SYNC_START = H_DISPLAY + H_FRONT;
	parameter H_SYNC_END = H_DISPLAY + H_FRONT + H_SYNC - 1;
	parameter H_MAX = H_DISPLAY + H_FRONT + H_SYNC + H_BACK - 1;

	parameter V_SYNC_START = V_DISPLAY + V_BOTTOM;
	parameter V_SYNC_END = V_DISPLAY + V_BOTTOM + V_SYNC - 1;
	parameter V_MAX = V_DISPLAY + V_BOTTOM + V_SYNC + V_TOP - 1;

	// calculating next values of the counters

	reg [9:0] d_hpos;
	reg [9:0] d_vpos;

	always @*
		if (hpos == H_MAX)
		begin
			d_hpos = 0;
			if (vpos == V_MAX)
				d_vpos = 0;
			else
				d_vpos = vpos + 1;
		end
		else
		begin
			d_hpos = hpos + 1;
			d_vpos = vpos;
		end

	// enable to divide clock from 50 MHz to 25 MHZ

	reg clk_en;

	always @ (posedge clk or posedge reset)
		if (reset)
			clk_en <= 0;
		else
			clk_en <= ~ clk_en;

	// making all outputs registered

	always @ (posedge clk or posedge reset)
	if (reset)
	begin
		hsync <= 0;
		vsync <= 0;
		display_on <= 0;
		hpos <= 0;
		vpos <= 0;
	end
	else if (clk_en)
	begin
		hsync <= ~ ( d_hpos >= H_SYNC_START && d_hpos <= H_SYNC_END );
		vsync <= ~ ( d_vpos >= V_SYNC_START && d_vpos <= V_SYNC_END );

		display_on <= ( d_hpos < H_DISPLAY && d_vpos < V_DISPLAY );

		hpos <= d_hpos;
		vpos <= d_vpos;
	end
endmodule
