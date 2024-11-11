
module hdmi_fft_display(
    input                lcd_pclk,       //ʱ��
    input                rst_n,          //��λ���͵�ƽ��Ч
    input        [10:0]  pixel_xpos,     //��ǰ���ص������
    input        [10:0]  pixel_ypos,     //��ǰ���ص�������  
    input        [10:0]  h_disp,         //LCD��ˮƽ�ֱ��� ��800x480���� 
    input        [10:0]  v_disp,         //LCD����ֱ�ֱ��� 
    input        [15:0]  lcd_id,      //LCD��ID  //��ӦΪ800x480 ������ֵΪ16'h7084����
    output      reg      vs_out        , //��
    output      reg      hs_out        , //��
    output      reg      de_out        ,
    output     [7:0]  r_out         , 
    output     [7:0]  g_out         , 
    output     [7:0]  b_out         ,
    input             fre_eq_diven  ,
    input      [23:0] pixel_data_div,               //���ص�����
    input                                vs_in, 
    input                                hs_in, 
    input                                de_in,
    input                                back_en,
    input      [23:0]                    pixel_data_back,
    input                                wave_en,
    input      [23:0]                    pixel_data_wave,
    input                                fre_en,
    input      [23:0]                    pixel_data_fre,
    //FFT��������ݽӿ�
    input        [7:0]   fft_point_cnt,  //FFTƵ��λ��
    input        [11:0]   fft_data,       //FFTƵ�ʷ�ֵ  ����ı���λ�� ��������Ƚ��õ���������չlcd_fft_data ��ʾҲ�漰  ������ʱû�иĴ���
                                          //�����ϰ��������Ҫ����һ�� ��..........................................................
    output reg           fft_point_done, //FFT��ǰƵ�׻������
    output                wave_done,
    output reg           data_req        //���������ź�

   );
//parameter define            
//localparam BLACK  = 24'b00000000_00000000_00000000;     //RGB888 ��ɫ ��ȷ
//localparam WHITE  = 24'b11111111_11111111_11111111;     //RGB888 ��ɫ
localparam BLACK  = 24'b11111111_11111111_11111111;     //RGB888 ��ɫ ��ʵ��Ӧ��ɫ
localparam BLUE   = 24'b00000000_00000000_11111111;     //RGB888 ��ɫ
localparam honse    = 24'b11111111_00000000_00000000;     //RGB888 ��ɫ
localparam RED    = 24'b00000000_00000000_00000000;  //��ɫ   FFFF00 ����û��Ӣ�����
localparam H_OFFSET  = 8'd64;    //������ԭ����ʾ�����Ǹ�ͼ�Ͷ��� 
localparam V_OFFSET  = 8'd44;    

reg  [23:0]  pixel_data;     //��������
assign r_out = pixel_data[23:16];
assign g_out = pixel_data[15:8];
assign b_out = pixel_data[7:0];


assign wave_done = ((pixel_xpos == h_disp - 1)&&(pixel_ypos == v_disp - 1)) ? 1'b0 : 1'b1;

//reg define
reg [7:0] 	fft_point_cnt_d0;
reg [7:0] 	fft_point_cnt_d1;   
reg 		data_req_d0;
reg 		data_req_d1; 
/*
reg [10:0] 	row_axle_addr;       //�з����rom��ַ
reg [10:0]	col_axle_addr;       //�з����rom��ַ
reg [7:0] 	rom_col_shift_data;  //�з������λ�Ĵ�����
reg [2:0] 	cnt_col_en;          //�з����ʹ�ܼ�����
reg [7:0] 	rom_row_shift_data;  //�з������λ�Ĵ�����
reg  		col_y_axle_en;       //�з����y�᷶Χʹ��
reg  		col_axle_en;         //�з���ķ�Χʹ��
reg  		row_y_axle_en;       //�з����y�᷶Χʹ��
reg  		row_x_axle_en;       //�з����x�᷶Χʹ��
reg [5:0] 	cnt_row_x_axle_en;   //�з����x�᷶Χʹ�ܼ�����
*/
//reg  		row_axle_en;         //�з���ķ�Χʹ��
//reg [2:0] 	cnt_row_en;          //�з����ʹ�ܼ�����
reg [23:0] 	x_frame_data;        //��ֱ�����ϵı߿�����
//reg  		col_x_axle_en;       //�з����x�᷶Χʹ��
reg [23:0] 	y_frame_data;        //ˮƽ�����ϵı߿�����
reg [3:0] 	fft_step;            //Ƶ�ײ���
reg [10:0] 	fft_y_frame_start;   //����Y�����ϵı߿����λ��
reg [10:0] 	fft_x_frame_start;   //����X�����ϵı߿����λ��
reg [10:0] 	fft_x_frame_end;     //����X�����ϵı߿����λ��
reg [10:0] 	fft_y_frame_end;     //����Y�����ϵı߿����λ��

//wire define
//wire [7:0] 	rom_row_data;        //�з����rom����
//wire [7:0] 	rom_col_data;        //�з����rom����
wire [12:0] 	lcd_fft_data;        //ת�����fft����
//wire 		col_axle_data;       //�з����ϵ���������
//wire 		row_axle_data;       //�з����ϵ���������
wire [12:0] 	lcd_fft_data_1;

//*****************************************************
//**                    main code
//*****************************************************


//��idΪ7016��1018�����ϣ�1��fft��ֵ��2�����ص�����ʾ
assign lcd_fft_data = lcd_id[2] ? fft_data : {fft_data,1'b0};
assign lcd_fft_data_1 = ((lcd_fft_data >= 0) && (lcd_fft_data <= v_disp  - V_OFFSET)) ? lcd_fft_data : (v_disp  - V_OFFSET);
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n)begin
        vs_out <= 1'b0;
        hs_out <= 1'b0;
        de_out <= 1'b0;
    end
    else begin
        vs_out <=  vs_in;
        hs_out <=  hs_in;
        de_out <=  de_in;
    end
end 
//��rom�����������Ǹ�λ�ȳ���
//assign  row_axle_data = rom_row_shift_data[7];
//assign  col_axle_data = rom_col_shift_data[7];

//���źŴ���
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)begin 
        fft_point_cnt_d0 <= 8'd0;
        fft_point_cnt_d1 <= 8'd0;
        data_req_d0 <= 1'b0;
        data_req_d1 <= 1'b0;               
    end    
    else begin
        fft_point_cnt_d0 <= fft_point_cnt; 
        fft_point_cnt_d1 <= fft_point_cnt_d0; 
        data_req_d0 <= data_req;
        data_req_d1 <= data_req_d0;                          
    end
end

//����һ���������Ƶ�׿�ȣ����ε���ʾ�ĵ���128�������Բ��ø�4λ��Ϊ���   //�պö�Ӧ2��7�η�
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        fft_step <= 4'd0;
    else begin
        fft_step <= h_disp[10:7] - 1;         
    end
end

//����X�����ϵı߿����λ��
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        fft_x_frame_end <= 11'd0;
    else begin
        fft_x_frame_end <= H_OFFSET + fft_step * 120;         
    end
end

//����X�����ϵı߿���ʼλ��
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        fft_x_frame_start <= 11'd0;
    else begin
        fft_x_frame_start <= H_OFFSET ;         
    end
end

//����Y�����ϵı߿����λ��
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        fft_y_frame_end <= 11'd0;
    else begin
        fft_y_frame_end <= v_disp - V_OFFSET;             
    end
end

//����Y�����ϵı߿���ʼλ��
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        fft_y_frame_start <= 11'd0;
    else begin
        if(lcd_id[7:0] == 8'h84 )  //�ֱ���Ϊ800x480����
            fft_y_frame_start <=  v_disp - 11'd250 -  V_OFFSET;
       else 
            fft_y_frame_start <=  v_disp - 11'd500 - V_OFFSET; 
                               
    end
end


//�������������ź�
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        data_req <= 1'b0;
    else begin
        if( (pixel_xpos  == (fft_point_cnt  + 1) * fft_step - 3 + H_OFFSET) 
		    && (pixel_ypos >= fft_y_frame_start) )
            data_req <= 1'b1;
       else
            data_req <= 1'b0;           
    end
end

//1�н���������done�źţ���ʾ�˴ε�Ƶ����ʾ�����
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        fft_point_done <= 1'b0;
    else begin
       if (pixel_xpos == h_disp - 1)
            fft_point_done <= 1'b1;
       else
            fft_point_done <= 1'b0;           
    end
end     

//������ֱ�����ϵı߿�����
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        x_frame_data <= BLACK;
    else begin
       if ( pixel_ypos >= fft_y_frame_start && pixel_ypos <= fft_y_frame_end) 
            if((pixel_xpos == fft_x_frame_start - 1) || pixel_xpos == fft_x_frame_start )
                x_frame_data <= RED;
            else if(data_req_d0 || data_req_d1)
                if(fft_point_cnt_d1 == 19)  
                    x_frame_data <= RED;  
                else if(fft_point_cnt_d1 == 39)  
                    x_frame_data <= RED; 
                else if(fft_point_cnt_d1 == 59)  
                    x_frame_data <= RED;  
                else if(fft_point_cnt_d1 == 79)  
                    x_frame_data <= RED; 
                else if(fft_point_cnt_d1 == 99)  
                    x_frame_data <= RED;
                else if(fft_point_cnt_d1 == 119)  
                    x_frame_data <= RED;                      
                else 
                    x_frame_data <= BLACK;                                                                                                                                             
            else 
                x_frame_data <= BLACK;                    
       else
            x_frame_data <= BLACK;                              
    end
end   

//����ˮƽ�����ϵı߿�����
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        y_frame_data <= BLACK;
    else begin
        if ( (pixel_xpos >= fft_x_frame_start - 1) 
            && (pixel_xpos <= fft_x_frame_end - 1) ) 
            if( pixel_ypos[10:1] == fft_y_frame_end[10:1] )
                y_frame_data <= RED; 
            else if(lcd_id[7:0] == 8'h84 )
                if(pixel_ypos[10:1] == fft_y_frame_end[10:1] - 25)  
                    y_frame_data <= RED;  
                else if(pixel_ypos[10:1] == fft_y_frame_end[10:1] - 50)
                    y_frame_data <= RED;  
                else if(pixel_ypos[10:1] == fft_y_frame_end[10:1] - 75)
                    y_frame_data <= RED; 
                else if(pixel_ypos[10:1] == fft_y_frame_end[10:1] - 100)
                    y_frame_data <= RED; 
                else if(pixel_ypos[10:1] == fft_y_frame_end[10:1] - 125)
                    y_frame_data <= RED;
                else
                    y_frame_data <= BLACK;                     
            else if(pixel_ypos[10:1] == (fft_y_frame_end[10:1] - 50)) 
                y_frame_data <= RED; 
            else if(pixel_ypos[10:1] == fft_y_frame_end[10:1] - 100) 
                y_frame_data <= RED; 
            else if(pixel_ypos[10:1] == fft_y_frame_end[10:1] - 150) 
                y_frame_data <= RED;   
            else if(pixel_ypos[10:1] == fft_y_frame_end[10:1] - 200) 
                y_frame_data <= RED;  
            else if(pixel_ypos[10:1] == fft_y_frame_end[10:1] - 250) 
                y_frame_data <= RED; 
            else
                y_frame_data <= BLACK;                                                                                                                     
        else
            y_frame_data <= BLACK;                              
    end
end 
/*
//�з����x�᷶Χʹ��
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        col_x_axle_en <= 1'b0;
    else begin
        if(lcd_id[7:0] == 8'h84 && (pixel_ypos >= fft_y_frame_end - 287) 
		   && (pixel_ypos < fft_y_frame_end - 255))  //x256
			if(pixel_xpos >=32 && pixel_xpos < 96)
				col_x_axle_en <= 1'b1;	
			else
				col_x_axle_en <= 1'b0;	
        else if((pixel_ypos >= fft_y_frame_end - 537) 
				&& (pixel_ypos < fft_y_frame_end - 505))   //x256
			if(pixel_xpos >=32 && pixel_xpos < 96)
				col_x_axle_en <= 1'b1;	
			else
				col_x_axle_en <= 1'b0;					
		else if(pixel_xpos >=6 && pixel_xpos < 54)		//50,100��150��200��Щ��	
            col_x_axle_en <= 1'b1;
		else
            col_x_axle_en <= 1'b0;           
    end
end 

//�з����y�᷶Χʹ��
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        col_y_axle_en <= 1'b0;
    else begin
        if ((pixel_ypos >= fft_y_frame_end - 32) && (pixel_ypos < fft_y_frame_end))  //0
            col_y_axle_en <= 1'b1;
        else if(lcd_id[7:0] == 8'h84 )
	        if((pixel_ypos >= fft_y_frame_end - 82) && 
				(pixel_ypos < fft_y_frame_end - 50))        //50
				col_y_axle_en <= 1'b1;
			else if((pixel_ypos >= fft_y_frame_end - 132) && 
				(pixel_ypos < fft_y_frame_end - 100)) //100
				col_y_axle_en <= 1'b1;  
			else if((pixel_ypos >= fft_y_frame_end - 182) && 
				(pixel_ypos < fft_y_frame_end - 150)) //150
				col_y_axle_en <= 1'b1;  
			else if((pixel_ypos >= fft_y_frame_end - 232) && 
				(pixel_ypos < fft_y_frame_end - 200)) //200
				col_y_axle_en <= 1'b1; 
  			else if((pixel_ypos >= fft_y_frame_end - 287) && 
				(pixel_ypos < fft_y_frame_end - 255)) //X256
				col_y_axle_en <= 1'b1; 
			else
				col_y_axle_en <= 1'b0; 
	    else if((pixel_ypos >= fft_y_frame_end - 132) && 
			(pixel_ypos < fft_y_frame_end - 100))  	//50
			col_y_axle_en <= 1'b1;	
		else if((pixel_ypos >= fft_y_frame_end - 232) && 
			(pixel_ypos < fft_y_frame_end - 200))  	//100
			col_y_axle_en <= 1'b1;  	
		else if((pixel_ypos >= fft_y_frame_end - 332) && 
			(pixel_ypos < fft_y_frame_end - 300))  	//150
			col_y_axle_en <= 1'b1;  	
		else if((pixel_ypos >= fft_y_frame_end - 432) && 
			(pixel_ypos < fft_y_frame_end - 400))  	//200
			col_y_axle_en <= 1'b1; 	
  		else if((pixel_ypos >= fft_y_frame_end - 537) && 
			(pixel_ypos < fft_y_frame_end - 505))  	//X256
			col_y_axle_en <= 1'b1; 
		else
			col_y_axle_en <= 1'b0; 
			
    end
end 

//�з���ķ�Χʹ��
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        col_axle_en <= 1'b0;
    else begin		
		if(col_x_axle_en && col_y_axle_en)			
            col_axle_en <= 1'b1;
		else
            col_axle_en <= 1'b0;           
    end
end 

//�з����y�᷶Χʹ��
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        row_y_axle_en <= 1'b0;
    else begin		
		if((pixel_ypos >= fft_y_frame_end + 6) && (pixel_ypos < fft_y_frame_end + 38))			
            row_y_axle_en <= 1'b1;
		else
            row_y_axle_en <= 1'b0;           
    end
end 

//�з����x�᷶Χʹ��
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        row_x_axle_en <= 1'b0;
    else begin
        if(cnt_row_x_axle_en >= 47)
            row_x_axle_en <= 1'b0;	
		else if(cnt_row_x_axle_en >= 31 && (pixel_xpos < fft_x_frame_end - 10))
            row_x_axle_en <= 1'b0;	
		else if(pixel_xpos == fft_x_frame_start - 16)
            row_x_axle_en <= 1'b1;	            		
		else if(data_req)
			if((fft_point_cnt_d0 == 17) || (fft_point_cnt_d0 == 37) || (fft_point_cnt_d0 == 57)	|| 		   			     
			   (fft_point_cnt_d0 == 77) || (fft_point_cnt_d0 == 97) || (fft_point_cnt_d0 == 117))
                row_x_axle_en <= 1'b1;
            else
                row_x_axle_en <= row_x_axle_en;			
		else
            row_x_axle_en <= row_x_axle_en;           
    end
end 

//���з����x�᷶Χʹ�ܽ��м���
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        cnt_row_x_axle_en <= 6'd0;
    else begin		
		if(row_x_axle_en)			
            cnt_row_x_axle_en <= cnt_row_x_axle_en + 1'b1;
		else
            cnt_row_x_axle_en <= 6'd0;           
    end
end 

//�з���ķ�Χʹ��
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        row_axle_en <= 1'b0;
    else begin		
		if(row_y_axle_en && row_x_axle_en)			
            row_axle_en <= 1'b1;
		else
            row_axle_en <= 1'b0;           
    end
end 

/////////////////////////////////////

//���з����ʹ�ܽ��м���
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        cnt_row_en <= 3'd0;
    else begin		
		if(row_axle_en)			
            cnt_row_en <= cnt_row_en + 1'b1;
		else
            cnt_row_en <= 3'd0;           
    end
end 

//�з����rom��ַ
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        row_axle_addr <= 11'd0;
    else begin
        if(pixel_ypos == v_disp)
            row_axle_addr <= 11'd0;         		
		else if(row_axle_en && cnt_row_en == 5)			
            row_axle_addr <= row_axle_addr + 1'b1;
		else
            row_axle_addr <= row_axle_addr;           
    end
end 

//�з������λ�Ĵ�����
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        rom_row_shift_data <= 8'd0;
    else begin
        if(cnt_row_en == 7)
            rom_row_shift_data <= rom_row_data;         		
		else if(row_axle_en)			
            rom_row_shift_data <= {rom_row_shift_data[6:0],1'b0};
		else
            rom_row_shift_data <= rom_row_shift_data;           
    end
end

//////////////////////////////////////////////////

//���з����ʹ�ܽ��м���
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        cnt_col_en <= 3'd0;
    else begin		
		if(col_axle_en)			
            cnt_col_en <= cnt_col_en + 1'b1;
		else
            cnt_col_en <= 3'd0;           
    end
end 

//�з����rom��ַ
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        col_axle_addr <= 11'd0;
    else begin
        if(pixel_ypos == v_disp)
            col_axle_addr <= 11'd0;         		
		else if(col_axle_en && cnt_col_en == 5)			
            col_axle_addr <= col_axle_addr + 1'b1;
		else
            col_axle_addr <= col_axle_addr;           
    end
end 

//�з������λ�Ĵ�����
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        rom_col_shift_data <= 8'd0;
    else begin
        if(cnt_col_en == 7)
            rom_col_shift_data <= rom_col_data;         		
		else if(col_axle_en)			
            rom_col_shift_data <= {rom_col_shift_data[6:0],1'b0};
		else
            rom_col_shift_data <= rom_col_shift_data;           
    end
end
*/
///////////////////////////////////////////////

//�������������ź�
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        pixel_data <= BLACK;
    else begin
          if(!x_frame_data[0])
                pixel_data <= x_frame_data;  
        else if(!y_frame_data[0]) 
                pixel_data <= y_frame_data;   
        //else if((row_axle_data && row_axle_en) || (col_axle_data && col_axle_en)) 
                //pixel_data <= BLUE;      
        else if(back_en)
                pixel_data <= pixel_data_back;
        else if(wave_en)
                pixel_data <= pixel_data_wave;
        else if(fre_en)
                pixel_data <= pixel_data_fre;
        else if(fre_eq_diven)
                pixel_data <= pixel_data_div;
        else   if( (pixel_xpos >= (fft_point_cnt_d0 * fft_step + H_OFFSET )) 
		         && (pixel_xpos < (fft_point_cnt_d0 + 1)  * fft_step + H_OFFSET) )begin
            if(lcd_fft_data == 0)    //���lcd_fft_dataΪ0����ʾ�ڵ�ǰ��FFT������û��Ƶ�ʳɷֻ��ֵΪ0���򽫵�ǰ���ص���������Ϊ��ɫ��WHITE��
                pixel_data <= BLACK;              
            else if( (pixel_ypos >= v_disp - lcd_fft_data - V_OFFSET) //���ܳ��ָ��� ����ô�޸��ж������� ����ֵ����˵�ȱȽϴ�С ����˵���ᳬ����
			       && (pixel_ypos <= v_disp  - V_OFFSET)) 
                pixel_data <= BLUE;
           else
                pixel_data <= BLACK;      
              end                  
       else
            pixel_data <= BLACK;          
    end
end
/*
//�����з��������rom
rom_row_axle u_rom_row_axle (
  .clka(lcd_pclk),    // input wire clka
  .addra(row_axle_addr),  // input wire [9 : 0] addra
  .douta(rom_row_data)  // output wire [7 : 0] douta
);

//�����з��������rom
rom_col_axle u_rom_col_axle (
  .clka(lcd_pclk),    // input wire clka
  .addra(col_axle_addr),  // input wire [9 : 0] addra
  .douta(rom_col_data)  // output wire [7 : 0] douta
);
 */
/*
row_rom row_rom_isnt(
  .addr(row_axle_addr),          // input [10:0]
  .clk(lcd_pclk),            // input
  .rst(~rst_n),            // input
  .rd_data(rom_row_data)     // output [7:0]
);

lie_rom lie_rom_isnt (
  .addr(col_axle_addr),          // input [10:0]
  .clk(lcd_pclk),            // input
  .rst(~rst_n),            // input
  .rd_data(rom_col_data)     // output [7:0]
);
    */         
endmodule 


