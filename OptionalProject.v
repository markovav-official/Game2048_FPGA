module OptionalProject (button_up, button_down, button_left, button_right, button_reset, clk, vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B);
input clk, button_up, button_down, button_left, button_right, button_reset;
output vga_h_sync, vga_v_sync;
output reg [3:0] vga_R, vga_G, vga_B;

wire inDisplayArea;
wire [9:0] CounterX;
wire [8:0] CounterY;
reg none, changed;

integer values[0:15];
integer previousCell;

initial
begin
	changed = 1'b0;
	previousCell = 0;
	values[0] = 0;
	values[1] = 0;
	values[2] = 0;
	values[3] = 0;
	values[4] = 0;
	values[5] = 0;
	values[6] = 0;
	values[7] = 0;
	values[8] = 0;
	values[9] = 0;
	values[10] = 0;
	values[11] = 0;
	values[12] = 0;
	values[13] = 0;
	values[14] = 0;
	values[15] = 0;
end

hvsync_generator syncgen(.clk(clk), .hsync (vga_h_sync), .vsync (vga_v_sync), .display_on(inDisplayArea), .hpos(CounterX), .vpos(CounterY));

wire button_reset_clk;
reg button_reset_click, button_reset_clicked;
button_debouncer debouncer_reset(.clk_i(clk), .rst_i(), .sw_i(button_reset), .sw_state_o(), .sw_down_o(button_reset_clk), .sw_up_o());

wire button_up_clk;
reg button_up_click, button_up_clicked;
button_debouncer debouncer_up(.clk_i(clk), .rst_i(), .sw_i(button_up), .sw_state_o(), .sw_down_o(button_up_clk), .sw_up_o());

wire button_down_clk;
reg button_down_click, button_down_clicked;
button_debouncer debouncer_down(.clk_i(clk), .rst_i(), .sw_i(button_down), .sw_state_o(), .sw_down_o(button_down_clk), .sw_up_o());

wire button_left_clk;
reg button_left_click, button_left_clicked;
button_debouncer debouncer_left(.clk_i(clk), .rst_i(), .sw_i(button_left), .sw_state_o(), .sw_down_o(button_left_clk), .sw_up_o());

wire button_right_clk;
reg button_right_click, button_right_clicked;
button_debouncer debouncer_right(.clk_i(clk), .rst_i(), .sw_i(button_right), .sw_state_o(), .sw_down_o(button_right_clk), .sw_up_o());

always @(posedge button_reset_clk) begin
	button_reset_click = ~button_reset_click;
end

always @(posedge button_up_clk) begin
	button_up_click = ~button_up_click;
end

always @(posedge button_down_clk) begin
	button_down_click = ~button_down_click;
end

always @(posedge button_left_clk) begin
	button_left_click = ~button_left_click;
end

always @(posedge button_right_clk) begin
	button_right_click = ~button_right_click;
end

always @(posedge clk) begin
	none = checkButtonReset(none);
	
	if (~checkGameLose(none) && ~checkGameWin(none))
	begin
		none = generateNew(none);
		
		none = checkButtonUp(none);
		none = checkButtonDown(none);
		none = checkButtonLeft(none);
		none = checkButtonRight(none);	
		
	end
	
	if (~inDisplayArea)
	begin
		vga_R <= 4'b0000;
		vga_G <= 4'b0000;
		vga_B <= 4'b0000;
	end
	else if (checkGameLose(none) && checkYouLoseText(CounterX, CounterY))
	begin
		vga_R <= 4'b1111;
		vga_G <= 4'b0000;
		vga_B <= 4'b0000;
	end
	else if (checkGameWin(none) && checkYouWinText(CounterX, CounterY))
	begin
		vga_R <= 4'b0000;
		vga_G <= 4'b1111;
		vga_B <= 4'b0000;
	end
	else if (checkIsGrid(CounterX, CounterY))
	begin
		vga_R <= 4'b0011;
		vga_G <= 4'b0011;
		vga_B <= 4'b0011;
	end
	else if (checkDigit(CounterX, CounterY) > 0)
	begin
		vga_R <= 4'b0000;
		vga_G <= 4'b0000;
		vga_B <= 4'b0000;
	end
	else if (checkIsInGrid(CounterX, CounterY))
	begin
		if (values[checkCell(CounterX, CounterY)] == 0)
		begin
			vga_R <= 4'b1100;
			vga_G <= 4'b1100;
			vga_B <= 4'b1100;
		end
		else if (values[checkCell(CounterX, CounterY)] == 2)
		begin
			vga_R <= 4'b1110;
			vga_G <= 4'b1110;
			vga_B <= 4'b1100;
		end
		else if (values[checkCell(CounterX, CounterY)] == 4)
		begin
			vga_R <= 4'b1101;
			vga_G <= 4'b1101;
			vga_B <= 4'b1011;
		end
		else if (values[checkCell(CounterX, CounterY)] == 8)
		begin
			vga_R <= 4'b1111;
			vga_G <= 4'b1011;
			vga_B <= 4'b0111;
		end
		else if (values[checkCell(CounterX, CounterY)] == 16)
		begin
			vga_R <= 4'b1111;
			vga_G <= 4'b1001;
			vga_B <= 4'b0110;
		end
		else if (values[checkCell(CounterX, CounterY)] == 32)
		begin
			vga_R <= 4'b1111;
			vga_G <= 4'b0111;
			vga_B <= 4'b0101;
		end
		else if (values[checkCell(CounterX, CounterY)] == 64)
		begin
			vga_R <= 4'b1111;
			vga_G <= 4'b0101;
			vga_B <= 4'b0011;
		end
		else if (values[checkCell(CounterX, CounterY)] == 128)
		begin
			vga_R <= 4'b1110;
			vga_G <= 4'b1100;
			vga_B <= 4'b1000;
		end
		else if (values[checkCell(CounterX, CounterY)] == 256)
		begin
			vga_R <= 4'b1110;
			vga_G <= 4'b1100;
			vga_B <= 4'b0111;
		end
		else if (values[checkCell(CounterX, CounterY)] == 512)
		begin
			vga_R <= 4'b1110;
			vga_G <= 4'b1100;
			vga_B <= 4'b0101;
		end
		else if (values[checkCell(CounterX, CounterY)] == 1024)
		begin
			vga_R <= 4'b1111;
			vga_G <= 4'b0011;
			vga_B <= 4'b0011;
		end
		else if (values[checkCell(CounterX, CounterY)] == 2048)
		begin
			vga_R <= 4'b1111;
			vga_G <= 4'b0001;
			vga_B <= 4'b0001;
		end
	end
	else
	begin
		vga_R <= 4'b1111;
		vga_G <= 4'b1111;
		vga_B <= 4'b1111;
	end
end

function checkButtonReset;
input n;
integer i;
begin
	if (button_reset_click != button_reset_clicked)
	begin
		button_reset_clicked = button_reset_click;
		changed = 1'b1;
		values[0] = 0;
		values[1] = 0;
		values[2] = 0;
		values[3] = 0;
		values[4] = 0;
		values[5] = 0;
		values[6] = 0;
		values[7] = 0;
		values[8] = 0;
		values[9] = 0;
		values[10] = 0;
		values[11] = 0;
		values[12] = 0;
		values[13] = 0;
		values[14] = 0;
		values[15] = 0;
	end
end
endfunction

function checkButtonUp;
input n;
begin
	if (button_up_click != button_up_clicked)
	begin
		button_up_clicked = button_up_click;
		n = moveUp(n);
	end
	checkButtonUp = n;
end
endfunction

function checkButtonDown;
input n;
begin
	if (button_down_click != button_down_clicked)
	begin
		button_down_clicked = button_down_click;
		n = moveDown(n);
	end
	checkButtonDown = n;
end
endfunction

function checkButtonLeft;
input n;
begin
	if (button_left_click != button_left_clicked)
	begin
		button_left_clicked = button_left_click;
		n = moveLeft(n);
	end
	checkButtonLeft = n;
end
endfunction

function checkButtonRight;
input n;
begin
	if (button_right_click != button_right_clicked)
	begin
		button_right_clicked = button_right_click;
		n = moveRight(n);
	end
	checkButtonRight = n;
end
endfunction

function generateNew;
input n;
integer i, newRandomTemp;
begin
	if (changed)
	begin
		changed = 1'b0;
		if (values[5] == 0 && previousCell != 5)
		begin
			 values[5] = 2;
			 previousCell = 5;
		end
		else if (values[6] == 0 && previousCell != 6)
		begin
			 values[6] = 4;
			 previousCell = 6;
		end
		else if (values[9] == 0 && previousCell != 9)
		begin
			 values[9] = 2;
			 previousCell = 9;
		end
		else if (values[10] == 0 && previousCell != 10)
		begin
			 values[10] = 2;
			 previousCell = 10;
		end
		else if (values[1] == 0 && previousCell != 1)
		begin
			 values[1] = 2;
			 previousCell = 1;
		end
		else if (values[2] == 0 && previousCell != 2)
		begin
			 values[2] = 4;
			 previousCell = 2;
		end
		else if (values[7] == 0 && previousCell != 7)
		begin
			 values[7] = 2;
			 previousCell = 7;
		end
		else if (values[11] == 0 && previousCell != 11)
		begin
			 values[11] = 2;
			 previousCell = 11;
		end
		else if (values[4] == 0 && previousCell != 4)
		begin
			 values[4] = 2;
			 previousCell = 4;
		end
		else if (values[8] == 0 && previousCell != 8)
		begin
			 values[8] = 4;
			 previousCell = 8;
		end
		else if (values[13] == 0 && previousCell != 13)
		begin
			 values[13] = 2;
			 previousCell = 13;
		end
		else if (values[14] == 0 && previousCell != 14)
		begin
			 values[14] = 2;
			 previousCell = 14;
		end
		else if (values[0] == 0 && previousCell != 0)
		begin
			 values[0] = 2;
			 previousCell = 0;
		end
		else if (values[3] == 0 && previousCell != 3)
		begin
			 values[3] = 2;
			 previousCell = 3;
		end
		else if (values[12] == 0 && previousCell != 12)
		begin
			 values[12] = 2;
			 previousCell = 12;
		end
		else if (values[15] == 0 && previousCell != 15)
		begin
			 values[15] = 4;
			 previousCell = 15;
		end
	end
	generateNew = n;
end
endfunction

function moveLeft;
input n;
reg n2;
begin
	if (compress(n)) changed = 1'b1;
	if (merge(n)) changed = 1'b1;
	n2 = compress(n);
	moveLeft = n;
end
endfunction

function moveRight;
input n;
begin
	n = reverse(n);
	n = moveLeft(n);
	n = reverse(n);
	moveRight = n;
end
endfunction

function moveUp;
input n;
begin
	n = transpose(n);
	n = moveLeft(n);
	n = transpose(n);
	moveUp = n;
end
endfunction

function moveDown;
input n;
begin
	n = transpose(n);
	n = moveRight(n);
	n = transpose(n);
	moveDown = n;
end
endfunction

function merge;
input n;
reg changedTemp;
integer i;
begin
	changedTemp = 1'b0;
	for (i = 0; i < 3; i = i + 1)
	begin
		if (values[i] == values[i + 1])
		begin
			values[i] = values[i] * 2;
			values[i + 1] = 0;
			changedTemp = 1'b1;
		end
	end
	for (i = 4; i < 7; i = i + 1)
	begin
		if (values[i] == values[i + 1])
		begin
			values[i] = values[i] * 2;
			values[i + 1] = 0;
			changedTemp = 1'b1;
		end
	end
	for (i = 8; i < 11; i = i + 1)
	begin
		if (values[i] == values[i + 1])
		begin
			values[i] = values[i] * 2;
			values[i + 1] = 0;
			changedTemp = 1'b1;
		end
	end
	for (i = 12; i < 15; i = i + 1)
	begin
		if (values[i] == values[i + 1])
		begin
			values[i] = values[i] * 2;
			values[i + 1] = 0;
			changedTemp = 1'b1;
		end
	end
	merge = changedTemp;
end
endfunction

function compress;
input n;
reg changedTemp;
integer i, j;
begin
	changedTemp = 1'b0;
	for (i = 0; i < 3; i = i + 1)
	begin
		if (values[i] == 0)
		begin
			for (j = i + 1; j < 4; j = j + 1)
			begin
				if (values[j] != 0 && values[i] == 0)
				begin
					values[i] = values[j];
					values[j] = 0;
					changedTemp = 1'b1;
				end
			end
		end
	end
	for (i = 4; i < 7; i = i + 1)
	begin
		if (values[i] == 0)
		begin
			for (j = i + 1; j < 8; j = j + 1)
			begin
				if (values[j] != 0 && values[i] == 0)
				begin
					values[i] = values[j];
					values[j] = 0;
					changedTemp = 1'b1;
				end
			end
		end
	end
	for (i = 8; i < 11; i = i + 1)
	begin
		if (values[i] == 0)
		begin
			for (j = i + 1; j < 12; j = j + 1)
			begin
				if (values[j] != 0 && values[i] == 0)
				begin
					values[i] = values[j];
					values[j] = 0;
					changedTemp = 1'b1;
				end
			end
		end
	end
	for (i = 12; i < 15; i = i + 1)
	begin
		if (values[i] == 0)
		begin
			for (j = i + 1; j < 16; j = j + 1)
			begin
				if (values[j] != 0 && values[i] == 0)
				begin
					values[i] = values[j];
					values[j] = 0;
					changedTemp = 1'b1;
				end
			end
		end
	end
	compress = changedTemp;
end
endfunction

function transpose;
input n;
integer i;
begin
	i = values[1];
	values[1] = values[4];
	values[4] = i;
	i = values[2];
	values[2] = values[8];
	values[8] = i;
	i = values[3];
	values[3] = values[12];
	values[12] = i;
	i = values[6];
	values[6] = values[9];
	values[9] = i;
	i = values[7];
	values[7] = values[13];
	values[13] = i;
	i = values[11];
	values[11] = values[14];
	values[14] = i;
	transpose = n;
end
endfunction

function reverse;
input n;
integer i;
begin
	i = values[0];
	values[0] = values[3];
	values[3] = i;
	i = values[1];
	values[1] = values[2];
	values[2] = i;
	i = values[4];
	values[4] = values[7];
	values[7] = i;
	i = values[5];
	values[5] = values[6];
	values[6] = i;
	i = values[8];
	values[8] = values[11];
	values[11] = i;
	i = values[9];
	values[9] = values[10];
	values[10] = i;
	i = values[12];
	values[12] = values[15];
	values[15] = i;
	i = values[13];
	values[13] = values[14];
	values[14] = i;
	reverse = n;
end
endfunction

function checkIsGrid;
input wire [9:0] x;
input wire [8:0] y;
integer cordX, cordY;
reg temp;
begin
	temp = 1'b0;
	cordX = x;
	cordY = y;
	if (cordX >= 121 && cordX <= 535 && cordY >= 41 && cordY <= 43 ||
		cordX >= 121 && cordX <= 535 && cordY >= 144 && cordY <= 146 ||
		cordX >= 121 && cordX <= 535 && cordY >= 247 && cordY <= 249 ||
		cordX >= 121 && cordX <= 535 && cordY >= 350 && cordY <= 352 ||
		cordX >= 121 && cordX <= 535 && cordY >= 453 && cordY <= 455)
		temp = 1'b1;
	if (cordX >= 121 && cordX <= 123 && cordY >= 41 && cordY <= 455 ||
		cordX >= 224 && cordX <= 226 && cordY >= 41 && cordY <= 455 ||
		cordX >= 327 && cordX <= 329 && cordY >= 41 && cordY <= 455 ||
		cordX >= 430 && cordX <= 432 && cordY >= 41 && cordY <= 455 ||
		cordX >= 533 && cordX <= 535 && cordY >= 41 && cordY <= 455)
		temp = 1'b1;
	checkIsGrid = temp;
end
endfunction

function checkIsInGrid;
input wire [9:0] x;
input wire [8:0] y;
integer cordX;
integer cordY;
reg temp;
begin
	temp = 1'b0;
	cordX = x;
	cordY = y;
	if (cordX >= 121 && cordX <= 535 && cordY >= 41 && cordY <= 455)
		temp = 1'b1;
	checkIsInGrid = temp;
end
endfunction

function automatic [4:0] checkCell;
input wire [9:0] x;
input wire [8:0] y;
integer temp;
integer cordX;
integer cordY;
begin
	temp = 16;
	cordX = x;
	cordY = y;
	if (cordX >= 124 && cordX <= 223 && cordY >= 44 && cordY <= 143)
		temp = 0;
	if (cordX >= 227 && cordX <= 326 && cordY >= 44 && cordY <= 143)
		temp = 1;
	if (cordX >= 330 && cordX <= 429 && cordY >= 44 && cordY <= 143)
		temp = 2;
	if (cordX >= 433 && cordX <= 532 && cordY >= 44 && cordY <= 143)
		temp = 3;
	if (cordX >= 124 && cordX <= 223 && cordY >= 147 && cordY <= 246)
		temp = 4;
	if (cordX >= 227 && cordX <= 326 && cordY >= 147 && cordY <= 246)
		temp = 5;
	if (cordX >= 330 && cordX <= 429 && cordY >= 147 && cordY <= 246)
		temp = 6;
	if (cordX >= 433 && cordX <= 532 && cordY >= 147 && cordY <= 246)
		temp = 7;
	if (cordX >= 124 && cordX <= 223 && cordY >= 250 && cordY <= 349)
		temp = 8;
	if (cordX >= 227 && cordX <= 326 && cordY >= 250 && cordY <= 349)
		temp = 9;
	if (cordX >= 330 && cordX <= 429 && cordY >= 250 && cordY <= 349)
		temp = 10;
	if (cordX >= 433 && cordX <= 532 && cordY >= 250 && cordY <= 349)
		temp = 11;
	if (cordX >= 124 && cordX <= 223 && cordY >= 353 && cordY <= 452)
		temp = 12;
	if (cordX >= 227 && cordX <= 326 && cordY >= 353 && cordY <= 452)
		temp = 13;
	if (cordX >= 330 && cordX <= 429 && cordY >= 353 && cordY <= 452)
		temp = 14;
	if (cordX >= 433 && cordX <= 532 && cordY >= 353 && cordY <= 452)
		temp = 15;
	checkCell = temp;
end
endfunction

function automatic [12:0] checkDigit;
input wire [9:0] x;
input wire [8:0] y;
integer cordX;
integer cordY;
integer curCell;
integer tempX;
integer tempY;
integer result;
begin
	result = 0;
	cordX = x;
	cordY = y;
	curCell = checkCell(CounterX, CounterY);
	if (curCell < 16)
	begin
		if (curCell % 4 == 0) tempX = cordX - 124;
		else if (curCell % 4 == 1) tempX = cordX - 227;
		else if (curCell % 4 == 2) tempX = cordX - 330;
		else if (curCell % 4 == 3) tempX = cordX - 433;
		if (curCell < 4) tempY = cordY - 44;
		else if (curCell < 8) tempY = cordY - 147;
		else if (curCell < 12) tempY = cordY - 250;
		else if (curCell < 16) tempY = cordY - 353;
		if (values[curCell] == 2)
		begin
			if (tempY >= 8 && tempY <= 10 && tempX >= 23 && tempX <= 73)
				result = 2;
			if (tempY >= 48 && tempY <= 50 && tempX >= 23 && tempX <= 73)
				result = 2;
			if (tempY >= 88 && tempY <= 90 && tempX >= 23 && tempX <= 75)
				result = 2;
			if (tempY >= 8 && tempY <= 50 && tempX >= 73 && tempX <= 75)
				result = 2;
			if (tempY >= 48 && tempY <= 88 && tempX >= 23 && tempX <= 25)
				result = 2;
		end
		else if (values[curCell] == 4)
		begin
			if (tempY >= 48 && tempY <= 50 && tempX >= 23 && tempX <= 73)
				result = 4;
			if (tempY >= 8 && tempY <= 90 && tempX >= 73 && tempX <= 75)
				result = 4;
			if (tempY >= 8 && tempY <= 48 && tempX >= 23 && tempX <= 25)
				result = 4;
		end
		else if (values[curCell] == 8)
		begin
			if (tempY >= 8 && tempY <= 10 && tempX >= 23 && tempX <= 73)
				result = 8;
			if (tempY >= 48 && tempY <= 50 && tempX >= 23 && tempX <= 73)
				result = 8;
			if (tempY >= 88 && tempY <= 90 && tempX >= 23 && tempX <= 75)
				result = 8;
			if (tempY >= 8 && tempY <= 90 && tempX >= 73 && tempX <= 75)
				result = 8;
			if (tempY >= 8 && tempY <= 90 && tempX >= 23 && tempX <= 25)
				result = 8;
		end
		else if (values[curCell] == 16)
		begin
			if (tempY >= 16 && tempY <= 82 && tempX >= 30 && tempX <= 32)
				result = 16;
			if (tempY >= 16 && tempY <= 82 && tempX >= 40 && tempX <= 42)
				result = 16;
			if (tempY >= 48 && tempY <= 82 && tempX >= 70 && tempX <= 72)
				result = 16;
			if (tempY >= 16 && tempY <= 18 && tempX >= 40 && tempX <= 72)
				result = 16;
			if (tempY >= 48 && tempY <= 50 && tempX >= 40 && tempX <= 72)
				result = 16;
			if (tempY >= 80 && tempY <= 82 && tempX >= 40 && tempX <= 72)
				result = 16;
		end
		else if (values[curCell] == 32)
		begin
			if (tempY >= 16 && tempY <= 18 && tempX >= 15 && tempX <= 47)
				result = 32;
			if (tempY >= 48 && tempY <= 50 && tempX >= 15 && tempX <= 47)
				result = 32;
			if (tempY >= 80 && tempY <= 82 && tempX >= 15 && tempX <= 47)
				result = 32;
			if (tempY >= 16 && tempY <= 82 && tempX >= 45 && tempX <= 47)
				result = 32;
			if (tempY >= 16 && tempY <= 18 && tempX >= 55 && tempX <= 87)
				result = 32;
			if (tempY >= 48 && tempY <= 50 && tempX >= 55 && tempX <= 87)
				result = 32;
			if (tempY >= 80 && tempY <= 82 && tempX >= 55 && tempX <= 87)
				result = 32;
			if (tempY >= 16 && tempY <= 50 && tempX >= 85 && tempX <= 87)
				result = 32;
			if (tempY >= 48 && tempY <= 82 && tempX >= 55 && tempX <= 57)
				result = 32;
		end
		else if (values[curCell] == 64)
		begin
			if (tempY >= 16 && tempY <= 18 && tempX >= 15 && tempX <= 47)
				result = 64;
			if (tempY >= 48 && tempY <= 50 && tempX >= 15 && tempX <= 47)
				result = 64;
			if (tempY >= 80 && tempY <= 82 && tempX >= 15 && tempX <= 47)
				result = 64;
			if (tempY >= 16 && tempY <= 82 && tempX >= 15 && tempX <= 17)
				result = 64;
			if (tempY >= 48 && tempY <= 82 && tempX >= 45 && tempX <= 47)
				result = 64;
			if (tempY >= 48 && tempY <= 50 && tempX >= 55 && tempX <= 87)
				result = 64;
			if (tempY >= 16 && tempY <= 82 && tempX >= 85 && tempX <= 87)
				result = 64;
			if (tempY >= 16 && tempY <= 48 && tempX >= 55 && tempX <= 57)
				result = 64;
		end
		else if (values[curCell] == 128)
		begin
			if (tempY >= 25 && tempY <= 77 && tempX >= 16 && tempX <= 18)
				result = 128;
			if (tempY >= 25 && tempY <= 27 && tempX >= 26 && tempX <= 51)
				result = 128;
			if (tempY >= 48 && tempY <= 50 && tempX >= 26 && tempX <= 51)
				result = 128;
			if (tempY >= 75 && tempY <= 77 && tempX >= 26 && tempX <= 51)
				result = 128;
			if (tempY >= 25 && tempY <= 50 && tempX >= 49 && tempX <= 51)
				result = 128;
			if (tempY >= 48 && tempY <= 77 && tempX >= 26 && tempX <= 28)
				result = 128;
			if (tempY >= 25 && tempY <= 77 && tempX >= 59 && tempX <= 61)
				result = 128;
			if (tempY >= 25 && tempY <= 77 && tempX >= 82 && tempX <= 84)
				result = 128;
			if (tempY >= 25 && tempY <= 27 && tempX >= 59 && tempX <= 84)
				result = 128;
			if (tempY >= 48 && tempY <= 50 && tempX >= 59 && tempX <= 84)
				result = 128;
			if (tempY >= 75 && tempY <= 77 && tempX >= 59 && tempX <= 84)
				result = 128;
		end
		else if (values[curCell] == 256)
		begin
			if (tempY >= 25 && tempY <= 27 && tempX >= 4 && tempX <= 29)
				result = 256;
			if (tempY >= 48 && tempY <= 50 && tempX >= 4 && tempX <= 29)
				result = 256;
			if (tempY >= 75 && tempY <= 77 && tempX >= 4 && tempX <= 29)
				result = 256;
			if (tempY >= 25 && tempY <= 50 && tempX >= 27 && tempX <= 29)
				result = 256;
			if (tempY >= 48 && tempY <= 77 && tempX >= 4 && tempX <= 6)
				result = 256;
			if (tempY >= 25 && tempY <= 27 && tempX >= 37 && tempX <= 62)
				result = 256;
			if (tempY >= 48 && tempY <= 50 && tempX >= 37 && tempX <= 62)
				result = 256;
			if (tempY >= 75 && tempY <= 77 && tempX >= 37 && tempX <= 62)
				result = 256;
			if (tempY >= 25 && tempY <= 50 && tempX >= 37 && tempX <= 39)
				result = 256;
			if (tempY >= 48 && tempY <= 77 && tempX >= 60 && tempX <= 62)
				result = 256;
			if (tempY >= 25 && tempY <= 27 && tempX >= 70 && tempX <= 95)
				result = 256;
			if (tempY >= 48 && tempY <= 50 && tempX >= 70 && tempX <= 95)
				result = 256;
			if (tempY >= 75 && tempY <= 77 && tempX >= 70 && tempX <= 95)
				result = 256;
			if (tempY >= 25 && tempY <= 77 && tempX >= 70 && tempX <= 72)
				result = 256;
			if (tempY >= 48 && tempY <= 77 && tempX >= 93 && tempX <= 95)
				result = 256;
		end
		else if (values[curCell] == 512)
		begin
			if (tempY >= 25 && tempY <= 27 && tempX >= 16 && tempX <= 41)
				result = 512;
			if (tempY >= 48 && tempY <= 50 && tempX >= 16 && tempX <= 41)
				result = 512;
			if (tempY >= 75 && tempY <= 77 && tempX >= 16 && tempX <= 41)
				result = 512;
			if (tempY >= 25 && tempY <= 50 && tempX >= 16 && tempX <= 18)
				result = 512;
			if (tempY >= 48 && tempY <= 77 && tempX >= 39 && tempX <= 41)
				result = 512;
			if (tempY >= 25 && tempY <= 77 && tempX >= 49 && tempX <= 51)
				result = 512;
			if (tempY >= 25 && tempY <= 27 && tempX >= 59 && tempX <= 84)
				result = 512;
			if (tempY >= 48 && tempY <= 50 && tempX >= 59 && tempX <= 84)
				result = 512;
			if (tempY >= 75 && tempY <= 77 && tempX >= 59 && tempX <= 84)
				result = 512;
			if (tempY >= 25 && tempY <= 50 && tempX >= 82 && tempX <= 84)
				result = 512;
			if (tempY >= 48 && tempY <= 77 && tempX >= 59 && tempX <= 61)
				result = 512;
		end
		else if (values[curCell] == 1024)
		begin
			if (tempY >= 35 && tempY <= 67 && tempX >= 14 && tempX <= 16)
				result = 1024;
			if (tempY >= 35 && tempY <= 37 && tempX >= 20 && tempX <= 39)
				result = 1024;
			if (tempY >= 65 && tempY <= 67 && tempX >= 20 && tempX <= 39)
				result = 1024;
			if (tempY >= 35 && tempY <= 67 && tempX >= 20 && tempX <= 22)
				result = 1024;
			if (tempY >= 35 && tempY <= 67 && tempX >= 37 && tempX <= 39)
				result = 1024;
			if (tempY >= 35 && tempY <= 37 && tempX >= 43 && tempX <= 62)
				result = 1024;
			if (tempY >= 48 && tempY <= 50 && tempX >= 43 && tempX <= 62)
				result = 1024;
			if (tempY >= 65 && tempY <= 67 && tempX >= 43 && tempX <= 62)
				result = 1024;
			if (tempY >= 35 && tempY <= 50 && tempX >= 60 && tempX <= 62)
				result = 1024;
			if (tempY >= 48 && tempY <= 67 && tempX >= 43 && tempX <= 45)
				result = 1024;
			if (tempY >= 48 && tempY <= 50 && tempX >= 66 && tempX <= 85)
				result = 1024;
			if (tempY >= 35 && tempY <= 50 && tempX >= 66 && tempX <= 68)
				result = 1024;
			if (tempY >= 35 && tempY <= 67 && tempX >= 83 && tempX <= 85)
				result = 1024;
		end
		else if (values[curCell] == 2048)
		begin
			if (tempY >= 35 && tempY <= 37 && tempX >= 6 && tempX <= 25)
				result = 2048;
			if (tempY >= 48 && tempY <= 50 && tempX >= 6 && tempX <= 25)
				result = 2048;
			if (tempY >= 65 && tempY <= 67 && tempX >= 6 && tempX <= 25)
				result = 2048;
			if (tempY >= 35 && tempY <= 50 && tempX >= 23 && tempX <= 25)
				result = 2048;
			if (tempY >= 48 && tempY <= 67 && tempX >= 6 && tempX <= 8)
				result = 2048;
			if (tempY >= 35 && tempY <= 37 && tempX >= 29 && tempX <= 48)
				result = 2048;
			if (tempY >= 65 && tempY <= 67 && tempX >= 29 && tempX <= 48)
				result = 2048;
			if (tempY >= 35 && tempY <= 67 && tempX >= 29 && tempX <= 31)
				result = 2048;
			if (tempY >= 35 && tempY <= 67 && tempX >= 46 && tempX <= 48)
				result = 2048;
			if (tempY >= 48 && tempY <= 50 && tempX >= 52 && tempX <= 71)
				result = 2048;
			if (tempY >= 35 && tempY <= 50 && tempX >= 52 && tempX <= 54)
				result = 2048;
			if (tempY >= 35 && tempY <= 67 && tempX >= 69 && tempX <= 71)
				result = 2048;
			if (tempY >= 35 && tempY <= 37 && tempX >= 75 && tempX <= 94)
				result = 2048;
			if (tempY >= 48 && tempY <= 50 && tempX >= 75 && tempX <= 94)
				result = 2048;
			if (tempY >= 65 && tempY <= 67 && tempX >= 75 && tempX <= 94)
				result = 2048;
			if (tempY >= 35 && tempY <= 67 && tempX >= 75 && tempX <= 77)
				result = 2048;
			if (tempY >= 35 && tempY <= 67 && tempX >= 92 && tempX <= 94)
				result = 2048;
		end
	end
	checkDigit = result;
end
endfunction

function checkGameWin;
input n;
reg temp;
begin
	temp = 1'b0;
	if (values[0] == 2048 || values[1] == 2048 || 
		 values[2] == 2048 || values[3] == 2048 || 
		 values[4] == 2048 || values[5] == 2048 || 
		 values[6] == 2048 || values[7] == 2048 || 
		 values[8] == 2048 || values[9] == 2048 || 
		 values[10] == 2048 || values[11] == 2048 || 
		 values[12] == 2048 || values[13] == 2048 || 
		 values[14] == 2048 || values[15] == 2048)
		 temp = 1'b1;
	checkGameWin = temp;
end
endfunction

function checkGameLose;
input n;
reg temp;
begin
	temp = 1'b1;
	if (values[0] == 0 || values[1] == 0 || 
		 values[2] == 0 || values[3] == 0 || 
		 values[4] == 0 || values[5] == 0 || 
		 values[6] == 0 || values[7] == 0 || 
		 values[8] == 0 || values[9] == 0 || 
		 values[10] == 0 || values[11] == 0 || 
		 values[12] == 0 || values[13] == 0 || 
		 values[14] == 0 || values[15] == 0)
		 temp = 1'b0;
	if (values[0] == values[1] || values[0] == values[4])
		 temp = 1'b0;
	if (values[1] == values[2] || values[1] == values[5])
		 temp = 1'b0;
	if (values[2] == values[3] || values[2] == values[6])
		 temp = 1'b0;
	if (values[3] == values[7])
		 temp = 1'b0;
	if (values[4] == values[5] || values[4] == values[8])
		 temp = 1'b0;
	if (values[5] == values[6] || values[5] == values[9])
		 temp = 1'b0;
	if (values[6] == values[7] || values[6] == values[10])
		 temp = 1'b0;
	if (values[7] == values[11])
		 temp = 1'b0;
	if (values[8] == values[9] || values[8] == values[12])
		 temp = 1'b0;
	if (values[9] == values[10] || values[9] == values[13])
		 temp = 1'b0;
	if (values[10] == values[11] || values[10] == values[14])
		 temp = 1'b0;
	if (values[11] == values[15])
		 temp = 1'b0;
	if (values[12] == values[13])
		 temp = 1'b0;
	if (values[13] == values[14])
		 temp = 1'b0;
	if (values[14] == values[15])
		 temp = 1'b0;
	checkGameLose = temp;
end
endfunction

function checkYouWinText;
input wire [9:0] x;
input wire [8:0] y;
integer tempX;
integer tempY;
reg temp;
begin
	temp = 1'b0;
	tempX = x;
	tempY = y;
	// Y
	if (tempY >= 205 && tempY <= 242 && tempX >= 40 && tempX <= 42)
		 temp = 1'b1;
	if (tempY >= 240 && tempY <= 242 && tempX >= 40 && tempX <= 112)
		 temp = 1'b1;
	if (tempY >= 205 && tempY <= 277 && tempX >= 110 && tempX <= 112)
		 temp = 1'b1;
	if (tempY >= 275 && tempY <= 277 && tempX >= 40 && tempX <= 112)
		 temp = 1'b1;
	// O
	if (tempY >= 205 && tempY <= 207 && tempX >= 120 && tempX <= 192)
		 temp = 1'b1;
	if (tempY >= 275 && tempY <= 277 && tempX >= 120 && tempX <= 192)
		 temp = 1'b1;
	if (tempY >= 205 && tempY <= 277 && tempX >= 120 && tempX <= 122)
		 temp = 1'b1;
	if (tempY >= 205 && tempY <= 277 && tempX >= 190 && tempX <= 192)
		 temp = 1'b1;
	// U
	if (tempY >= 275 && tempY <= 277 && tempX >= 200 && tempX <= 272)
		 temp = 1'b1;
	if (tempY >= 205 && tempY <= 277 && tempX >= 200 && tempX <= 202)
		 temp = 1'b1;
	if (tempY >= 205 && tempY <= 277 && tempX >= 270 && tempX <= 272)
		 temp = 1'b1;
	// W
	if (tempY >= 275 && tempY <= 277 && tempX >= 370 && tempX <= 442)
		 temp = 1'b1;
	if (tempY >= 205 && tempY <= 277 && tempX >= 370 && tempX <= 372)
		 temp = 1'b1;
	if (tempY >= 205 && tempY <= 277 && tempX >= 440 && tempX <= 442)
		 temp = 1'b1;
	if (tempY >= 240 && tempY <= 277 && tempX >= 405 && tempX <= 407)
		 temp = 1'b1;
	// I
	if (tempY >= 205 && tempY <= 207 && tempX >= 450 && tempX <= 522)
		 temp = 1'b1;
	if (tempY >= 275 && tempY <= 277 && tempX >= 450 && tempX <= 522)
		 temp = 1'b1;
	if (tempY >= 205 && tempY <= 277 && tempX >= 485 && tempX <= 487)
		 temp = 1'b1;
	// N
	if (tempY >= 205 && tempY <= 277 && tempX >= 530 && tempX <= 532)
		 temp = 1'b1;
	if (tempY >= 205 && tempY <= 277 && tempX >= 600 && tempX <= 602)
		 temp = 1'b1;
	if (tempX == tempY + 324 && tempY >= 205 && tempY <= 277 && tempX >= 530 && tempX <= 602)
		 temp = 1'b1;
	if (tempX == tempY + 325 && tempY >= 205 && tempY <= 277 && tempX >= 530 && tempX <= 602)
		temp = 1'b1;
	if (tempX == tempY + 326 && tempY >= 205 && tempY <= 277 && tempX >= 530 && tempX <= 602)
		temp = 1'b1;
	checkYouWinText = temp;
end
endfunction

function checkYouLoseText;
input wire [9:0] x;
input wire [8:0] y;
integer tempX;
integer tempY;
reg temp;
begin
	temp = 1'b0;
	tempX = x;
	tempY = y;
	// Y
	if (tempY >= 210 && tempY <= 242 && tempX >= 40 && tempX <= 42)
		 temp = 1'b1;
	if (tempY >= 240 && tempY <= 242 && tempX >= 40 && tempX <= 102)
		 temp = 1'b1;
	if (tempY >= 210 && tempY <= 272 && tempX >= 100 && tempX <= 102)
		 temp = 1'b1;
	if (tempY >= 270 && tempY <= 272 && tempX >= 40 && tempX <= 102)
		 temp = 1'b1;
	// O
	if (tempY >= 210 && tempY <= 212 && tempX >= 110 && tempX <= 172)
		 temp = 1'b1;
	if (tempY >= 270 && tempY <= 272 && tempX >= 110 && tempX <= 172)
		 temp = 1'b1;
	if (tempY >= 210 && tempY <= 272 && tempX >= 110 && tempX <= 112)
		 temp = 1'b1;
	if (tempY >= 210 && tempY <= 272 && tempX >= 170 && tempX <= 172)
		 temp = 1'b1;
	// U
	if (tempY >= 270 && tempY <= 272 && tempX >= 180 && tempX <= 242)
		 temp = 1'b1;
	if (tempY >= 210 && tempY <= 272 && tempX >= 180 && tempX <= 182)
		 temp = 1'b1;
	if (tempY >= 210 && tempY <= 272 && tempX >= 240 && tempX <= 242)
		 temp = 1'b1;
	// L
	if (tempY >= 270 && tempY <= 272 && tempX >= 320 && tempX <= 382)
		 temp = 1'b1;
	if (tempY >= 210 && tempY <= 272 && tempX >= 320 && tempX <= 322)
		 temp = 1'b1;
	// O
	if (tempY >= 210 && tempY <= 212 && tempX >= 390 && tempX <= 452)
		 temp = 1'b1;
	if (tempY >= 270 && tempY <= 272 && tempX >= 390 && tempX <= 452)
		 temp = 1'b1;
	if (tempY >= 210 && tempY <= 272 && tempX >= 390 && tempX <= 392)
		 temp = 1'b1;
	if (tempY >= 210 && tempY <= 272 && tempX >= 450 && tempX <= 452)
		 temp = 1'b1;
	// S
	if (tempY >= 210 && tempY <= 212 && tempX >= 460 && tempX <= 522)
		 temp = 1'b1;
	if (tempY >= 240 && tempY <= 242 && tempX >= 460 && tempX <= 522)
		 temp = 1'b1;
	if (tempY >= 270 && tempY <= 272 && tempX >= 460 && tempX <= 522)
		 temp = 1'b1;
	if (tempY >= 210 && tempY <= 242 && tempX >= 460 && tempX <= 462)
		 temp = 1'b1;
	if (tempY >= 240 && tempY <= 272 && tempX >= 520 && tempX <= 522)
		 temp = 1'b1;
	// E
	if (tempY >= 210 && tempY <= 212 && tempX >= 530 && tempX <= 592)
		 temp = 1'b1;
	if (tempY >= 240 && tempY <= 242 && tempX >= 530 && tempX <= 592)
		 temp = 1'b1;
	if (tempY >= 270 && tempY <= 272 && tempX >= 530 && tempX <= 592)
		 temp = 1'b1;
	if (tempY >= 210 && tempY <= 272 && tempX >= 530 && tempX <= 532)
		 temp = 1'b1;
	checkYouLoseText = temp;
end
endfunction
endmodule