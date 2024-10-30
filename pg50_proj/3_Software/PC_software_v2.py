import sys
from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QPushButton, QLineEdit, QVBoxLayout, QComboBox, QHBoxLayout, QGridLayout,QTextEdit
from PyQt5.QtGui import QPixmap
from PyQt5.QtCore import QThread, pyqtSignal,QTimer
import serial
import time


class SerialProtocol(QThread):
    received_data = pyqtSignal(str)  # 自定义信号，用于更新GUI显示

    def __init__(self,port,baudrate):
        super().__init__()
        self.ser = serial.Serial(port, baudrate, timeout=1)#初始化串口
        self.start_frame = 0x0A #起始帧
        self.end_frame = 0x0B #结束帧
        self.is_running = True
    
    def run(self):
        while  self.is_running:
            if self.ser.in_waiting:
                data = self.ser.read().decode('utf-8')  # 读取串口数据
                self.received_data.emit(data)  # 发射信号，通知主线程更新数据

    def send_packet(self,data):
        if len(data) != 5:
            raise ValueError("data length must be 5")
        start_frame = format(self.start_frame, '02x')
        end_frame = format(self.end_frame, '02x')
        packet_data = [start_frame, data[0],data[1],data[2],data[3],data[4], end_frame]
        for data_i in packet_data:
            self.ser.write(bytes([int(data_i,16)]))  # 发送数据
        

    def close(self):
        self.ser.close()




# -------------- GUI界面 -------------- #
class MyApp_GUI(QWidget):
    def __init__(self):
        super().__init__()
                
        self.DAC_uart = SerialProtocol(port = "COM10", baudrate = 9600)
        self.ADC_uart = SerialProtocol(port = "COM5", baudrate = 9600)

        self.setWindowTitle("紫光_基于Picorv32的便捷式多功能仪")
        self.setGeometry(100, 100, 500, 400)

        layout = QVBoxLayout()

        # 加载图片
        original_pixmap = QPixmap("C:\\Users\\lpc\\Desktop\\ziguang.jpg")
        scaled_pixmap = original_pixmap.scaled(50, 50)
        logo_label = QLabel()
        logo_label.setPixmap(scaled_pixmap)
        # 多功能仪功能
        self.label_function_DAC = QLabel("信号发生器：")
        self.label_function_ADC = QLabel("示波器：")

        # 选择信号发生器通道
        self.label_channel = QLabel("请选择通道：")
        self.combo_channel = QComboBox()
        self.combo_channel.addItems(["通道1", "通道2"])
        self.combo_channel.currentIndexChanged.connect(self.on_combo_change_channel)
        channel_layout = QHBoxLayout()
        channel_layout.addWidget(self.label_channel)
        channel_layout.addWidget(self.combo_channel)
        channel_layout.addStretch()
        # 选择上位机和本地的优先级
        self.label_priority = QLabel("请选择控制模式：")
        self.combo_priority = QComboBox()
        self.combo_priority.addItems(["上位机控制", "本地控制"])
        self.combo_priority.currentIndexChanged.connect(self.on_combo_change_priority)
        priority_layout = QHBoxLayout()
        priority_layout.addWidget(self.label_priority)
        priority_layout.addWidget(self.combo_priority)
        priority_layout.addStretch()
        # 输入波形频率
        self.label = QLabel("请输入波形频率：")
        self.input = QLineEdit()
        # 添加发送按钮
        self.button = QPushButton("发送")
        self.button.clicked.connect(self.on_click_freqence)
        # 创建水平布局，将标签和输入框放在同一行
        freq_layout = QHBoxLayout()
        freq_layout.addWidget(self.label)
        freq_layout.addWidget(self.input)
        freq_layout.addWidget(self.button)
        freq_layout.addStretch()

        # 输入波形相位
        self.label_phase = QLabel("请输入波形相位：")
        self.input_phase = QLineEdit()
        # 添加发送按钮
        self.button_phase = QPushButton("发送")
        self.button_phase.clicked.connect(self.on_click_phase)
        # 创建水平布局，将标签和输入框放在同一行
        phase_layout = QHBoxLayout()
        phase_layout.addWidget(self.label_phase)
        phase_layout.addWidget(self.input_phase)
        phase_layout.addWidget(self.button_phase)
        phase_layout.addStretch()

        # 波形类型选择
        self.label_wave_type = QLabel("请选择波形类型：")
        self.combo_wave_type = QComboBox()
        self.combo_wave_type.addItems(["正弦波", "三角波", "锯齿波", "方波","阶梯波","梯形波","白噪声","谐波"])
        self.combo_wave_type.currentIndexChanged.connect(self.on_combo_change_wave_type)
        wave_type_layout = QHBoxLayout()
        wave_type_layout.addWidget(self.label_wave_type)
        wave_type_layout.addWidget(self.combo_wave_type)
        wave_type_layout.addStretch()

        # 幅值参数
        self.label_fuzhi = QLabel("请输入波形幅值：")
        self.combo = QComboBox()
        self.combo.addItems(["1", "2", "3", "4", "5","1/2","1/4","1/8"])
        self.combo.currentIndexChanged.connect(self.on_combo_change)
        wave_fuzhi_layout = QHBoxLayout()
        wave_fuzhi_layout.addWidget(self.label_fuzhi)
        wave_fuzhi_layout.addWidget(self.combo)
        wave_fuzhi_layout.addStretch()
        # 电压偏置
        self.label_bias = QLabel("请输入波形电压偏置：")
        self.input_bias = QLineEdit()
        # 添加发送按钮
        self.button_bias = QPushButton("发送")
        self.button_bias.clicked.connect(self.on_click_bias)
        # 创建水平布局，将标签和输入框放在同一行
        bias_layout = QHBoxLayout()
        bias_layout.addWidget(self.label_bias)
        bias_layout.addWidget(self.input_bias)
        bias_layout.addWidget(self.button_bias)
        bias_layout.addStretch()

        # PWM波形占空比控制
        self.label_duty = QLabel("请输入PWM波形占空比:")
        self.input_duty = QLineEdit()
        # 添加发送按钮
        self.button_duty = QPushButton("发送")
        self.button_duty.clicked.connect(self.on_click_duty)
        # 创建水平布局，将标签和输入框放在同一行
        duty_layout = QHBoxLayout()
        duty_layout.addWidget(self.label_duty)
        duty_layout.addWidget(self.input_duty)
        duty_layout.addWidget(self.button_duty)
        duty_layout.addStretch()

        # PWM波形通道选择
        self.label_channel_pwm = QLabel("选择可调占空比方波通道：")
        self.combo_channel_pwm = QComboBox()
        self.combo_channel_pwm.addItems(["无","通道1", "通道2"])
        self.combo_channel_pwm.currentIndexChanged.connect(self.on_combo_change_channel_pwm)
        channel_layout_pwm = QHBoxLayout()
        channel_layout_pwm.addWidget(self.label_channel_pwm)
        channel_layout_pwm.addWidget(self.combo_channel_pwm)
        channel_layout_pwm.addStretch()

        # 示波器通道选择
        self.label_channel_ADC = QLabel("请选择示波器通道：")
        self.combo_channel_ADC = QComboBox()
        self.combo_channel_ADC.addItems(["通道1", "通道2"])
        self.combo_channel_ADC.currentIndexChanged.connect(self.on_combo_change_channel_ADC)
        channel_ADC_layout = QHBoxLayout()
        channel_ADC_layout.addWidget(self.label_channel_ADC)
        channel_ADC_layout.addWidget(self.combo_channel_ADC)
        channel_ADC_layout.addStretch()

        # 屏幕显示内容
        self.label_display_mode = QLabel("请选择屏幕显示内容：")
        self.combo_display_mode = QComboBox()
        self.combo_display_mode.addItems(["频谱仪","示波器通道1", "示波器通道2", "示波器双通道", "信号发生器"])
        self.combo_display_mode.currentIndexChanged.connect(self.on_combo_display_mode)
        display_mode_layout = QHBoxLayout()
        display_mode_layout.addWidget(self.label_display_mode)
        display_mode_layout.addWidget(self.combo_display_mode)
        display_mode_layout.addStretch()

        # 示波器时间分辨率
        self.label_deci_rate = QLabel("请选择时间分辨率：")
        self.combo_deci_rate = QComboBox()
        self.combo_deci_rate.addItems(["1us", "2us", "4us", "8us","20us","40us","100us","500us","1ms"])
        self.combo_deci_rate.currentIndexChanged.connect(self.on_combo_change_deci_rate)
        deci_rate_layout = QHBoxLayout()
        deci_rate_layout.addWidget(self.label_deci_rate)
        deci_rate_layout.addWidget(self.combo_deci_rate)
        deci_rate_layout.addStretch()

        # 示波器电压分辨率
        self.label_voltage = QLabel("请选择电压分辨率：")
        self.combo_voltage = QComboBox()
        self.combo_voltage.addItems(["500mv","1V", "2V", "4V", "250mv","100mv"])
        self.combo_voltage.currentIndexChanged.connect(self.on_combo_change_voltage)
        voltage_layout = QHBoxLayout()
        voltage_layout.addWidget(self.label_voltage)
        voltage_layout.addWidget(self.combo_voltage)
        voltage_layout.addStretch()

        
        # 触发电平
        self.label_trigger = QLabel("请输入触发电平：(0-4095);2048对应0V")
        self.input_trigger = QLineEdit()
        # 添加发送按钮
        self.button_trigger = QPushButton("发送")
        self.button_trigger.clicked.connect(self.on_click_trigger)
        # 创建水平布局，将标签和输入框放在同一行
        trigger_layout = QHBoxLayout()
        trigger_layout.addWidget(self.label_trigger)
        trigger_layout.addWidget(self.input_trigger)
        trigger_layout.addWidget(self.button_trigger)
        trigger_layout.addStretch()

        # 触发线
        self.label_trigger_line = QLabel("请输入触发线：(29-429);228对应0V位置")
        self.input_trigger_line = QLineEdit()
        # 添加发送按钮
        self.button_trigger_line = QPushButton("发送")
        self.button_trigger_line.clicked.connect(self.on_click_trigger_line)
        # 创建水平布局，将标签和输入框放在同一行
        trigger_line_layout = QHBoxLayout()
        trigger_line_layout.addWidget(self.label_trigger_line)
        trigger_line_layout.addWidget(self.input_trigger_line)
        trigger_line_layout.addWidget(self.button_trigger_line)
        trigger_line_layout.addStretch()

        # run or stop
        self.label_run_stop = QPushButton("run/stop")
        self.label_run_stop.clicked.connect(self.on_click_run_stop)

        # 触发边沿
        self.label_edge = QLabel("触发边沿：")
        self.button_edge = QPushButton("上升沿/下降沿")
        self.button_edge.clicked.connect(self.on_click_edge)
        trigger_edge_layout = QHBoxLayout()
        trigger_edge_layout.addWidget(self.label_edge)
        trigger_edge_layout.addWidget(self.button_edge)
        trigger_edge_layout.addStretch()

        self.label_up_down_left_right = QLabel("示波器波形位置调整：")



        self.received_buffer = ""
        # 串口接收数据
        self.label_receive = QLabel("串口接收数据：")
        self.receive_text = QTextEdit()
        self.receive_text.setReadOnly(True)
        receive_layout = QHBoxLayout()
        receive_layout.addWidget(self.label_receive)
 
        self.DAC_uart.received_data.connect(self.buffer_receive_data)
        self.DAC_uart.start()     
         
        self.ADC_uart.received_data.connect(self.buffer_receive_data)
        self.ADC_uart.start()   

        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_receive_data)
        self.timer.start(1000)
        self.received_buffer = ""
                                      
        receive_layout.addWidget(self.receive_text)
        receive_layout.addStretch()


        # 将控件添加到主布局
        layout.addWidget(logo_label)
        layout.addStretch()
        layout.addWidget(self.label_function_DAC)
        layout.addLayout(priority_layout)
        layout.addLayout(channel_layout)
        layout.addLayout(freq_layout)
        layout.addLayout(phase_layout)
        layout.addLayout(wave_type_layout)
        layout.addLayout(wave_fuzhi_layout)
        layout.addLayout(bias_layout)
        layout.addLayout(duty_layout)
        layout.addLayout(channel_layout_pwm)


        # 创建方向按钮并添加到主布局底部
        layout.addStretch()
        layout.addLayout(display_mode_layout)
        layout.addWidget(self.label_function_ADC)
        layout.addWidget(self.label_run_stop)
        layout.addLayout(channel_ADC_layout)
        layout.addLayout(trigger_edge_layout)
        layout.addLayout(deci_rate_layout)
        layout.addLayout(voltage_layout)
        layout.addLayout(trigger_layout)
        layout.addLayout(trigger_line_layout)
        layout.addWidget(self.label_up_down_left_right)
        self.create_direction_buttons(layout)
        layout.addLayout(receive_layout)

        self.setLayout(layout)


    def buffer_receive_data(self,data):
        self.received_buffer += data

    def update_receive_data(self):
        if self.received_buffer:
            if len(self.received_buffer) > 200:
                self.receive_text.clear()
            self.receive_text.insertPlainText(self.received_buffer)
            self.received_buffer = ""


    def create_direction_buttons(self, layout):
        # 创建一个网格布局来放置方向按钮
        grid_layout = QGridLayout()
        grid_layout.setSpacing(5)  # 设置按钮之间的间距为10像素

        # 创建方向按钮
        up_button = QPushButton("↑")
        down_button = QPushButton("↓")
        left_button = QPushButton("←")
        right_button = QPushButton("→")
        # 链接按钮的点击事件
        up_button.clicked.connect(self.on_click_up)
        down_button.clicked.connect(self.on_click_down)
        left_button.clicked.connect(self.on_click_left)
        right_button.clicked.connect(self.on_click_right)
        # 将按钮添加到网格布局中
        grid_layout.addWidget(up_button, 0, 1)
        grid_layout.addWidget(left_button, 1, 0)
        grid_layout.addWidget(right_button, 1, 2)
        grid_layout.addWidget(down_button, 1, 1)

        # 设置网格布局的边距
        grid_layout.setContentsMargins(0, 0, 0, 0)  # 去掉外边距

        # 添加网格布局到主布局
        layout.addLayout(grid_layout)







# ----------------------- 信号发生器配置 ------------------------ #
    def on_combo_change_priority(self):
        selected_option_priority = self.combo_priority.currentText()
        self.label_priority.setText(f"请选择控制模式：{selected_option_priority}")
        print(f"请选择控制模式：{selected_option_priority}")
        priority_id = format(0x06, '02x')
        if(selected_option_priority == "上位机控制"):
            priority_value = format(0x01, '08x')
        elif(selected_option_priority == "本地控制"):
            priority_value = format(0x00, '08x')
        data = [priority_id, priority_value[0:2], priority_value[2:4], priority_value[4:6], priority_value[6:8]]
        print(data)
        print(len(data))
        self.DAC_uart.send_packet(data)

    def on_click_freqence(self):
        parameter_value = self.input.text()

        if(int(parameter_value)/1000000 == int(int(parameter_value)/1000000)):
            self.label.setText(f"串口发送波形频率参数配置: {int(parameter_value)/1000000}MHz!")
        elif(int(parameter_value)/1000 == int(int(parameter_value)/1000)):
            self.label.setText(f"串口发送波形频率参数配置: {int(parameter_value)/1000}KHz!")
        else:
            self.label.setText(f"串口发送波形频率参数配置: {parameter_value}Hz!") 
        
        if self.combo_channel_pwm.currentText() == "无":
            fclk = 125e6
            fre_word = int(2**32 * int(parameter_value) / fclk)  
            fre_word_hex = format(fre_word, '08x')
            fre_id = format(0x01, '02x')
            data = [fre_id, fre_word_hex[0:2], fre_word_hex[2:4], fre_word_hex[4:6], fre_word_hex[6:8]]
            print(data)
            print(len(data))
            self.DAC_uart.send_packet(data)
        else:
            FCLK = 125e6
            DIV_CNT = int(int(FCLK)/int(parameter_value))
            DIV_CNT_HEX = format(DIV_CNT, '08x')
            div_id = format(0x09, '02x')
            data = [div_id, DIV_CNT_HEX[0:2], DIV_CNT_HEX[2:4], DIV_CNT_HEX[4:6], DIV_CNT_HEX[6:8]]
            print("PWM_mode")
            print(data)
            print(len(data))
            self.DAC_uart.send_packet(data)

    def on_click_phase(self):
        phase_value = self.input_phase.text()
        self.label_phase.setText(f"串口发送波形相位参数配置: {phase_value}°!")

        phase_word = int( 2**14 * (int(phase_value) / 360) )
        phase_word_hex = format(phase_word, '08x')
        phase_id = format(0x02, '02x')
        data = [phase_id, phase_word_hex[0:2], phase_word_hex[2:4], phase_word_hex[4:6], phase_word_hex[6:8]]
        print(data)
        print(len(data))
        self.DAC_uart.send_packet(data)

    def on_combo_change_wave_type(self, index):
        selected_option_wave_type = self.combo_wave_type.currentText()
        self.label_wave_type.setText(f"串口发送波形种类配置: {selected_option_wave_type}")
        print(f"串口发送波形种类配置: {selected_option_wave_type}")
        wave_id = format(0x03, '02x')
        if(selected_option_wave_type == "正弦波"):
            wave_value = format(0x00, '08x')
        elif(selected_option_wave_type == "三角波"):
            wave_value = format(0x01, '08x')
        elif(selected_option_wave_type == "锯齿波"):
            wave_value = format(0x02, '08x')
        elif(selected_option_wave_type == "方波"):
            wave_value = format(0x03, '08x')
        elif(selected_option_wave_type == "阶梯波"):
            wave_value = format(0x04, '08x')
        elif(selected_option_wave_type == "梯形波"):
            wave_value = format(0x05, '08x')
        elif(selected_option_wave_type == "白噪声"):
            wave_value = format(0x06, '08x')
        elif(selected_option_wave_type == "谐波"):
            wave_value = format(0x07, '08x')
        data = [wave_id, wave_value[0:2], wave_value[2:4], wave_value[4:6], wave_value[6:8]]
        print(data)
        print(len(data))
        self.DAC_uart.send_packet(data)

    def on_combo_change(self, index):
        selected_option = self.combo.currentText()
        self.label_fuzhi.setText(f"串口发送波形幅值配置: {selected_option}")
        print(f"串口发送波形幅值配置 {selected_option}") 
        fuzhi_id = format(0x04, '02x')
        if(selected_option == "1"):
            fuzhi_value = format(0x01, '08x')
        elif(selected_option == "2"):
            fuzhi_value = format(0x02, '08x')
        elif(selected_option == "3"):
            fuzhi_value = format(0x03, '08x')
        elif(selected_option == "4"):
            fuzhi_value = format(0x04, '08x')
        elif(selected_option == "5"):
            fuzhi_value = format(0x05, '08x')
        elif(selected_option == "1/2"):
            fuzhi_value = format(0x06, '08x')
        elif(selected_option == "1/4"):
            fuzhi_value = format(0x07, '08x')
        elif(selected_option == "1/8"):
            fuzhi_value = format(0x08, '08x')
        data = [fuzhi_id, fuzhi_value[0:2], fuzhi_value[2:4], fuzhi_value[4:6], fuzhi_value[6:8]]
        print(data)
        print(len(data))
        self.DAC_uart.send_packet(data)

    def on_click_bias(self):
        bias_value = self.input_bias.text()
        self.label_bias.setText(f"串口发送波形电压偏置(0-8191为负、8192-16383为正)每隔1电压偏置加0.6mv: {0.6*int(bias_value)}mv!")
        bias_id = format(0x07, '02x')
        bias_value_hex = format(int(bias_value), '08x')
        data = [bias_id, bias_value_hex[0:2], bias_value_hex[2:4], bias_value_hex[4:6], bias_value_hex[6:8]]
        print(data)
        print(len(data))
        self.DAC_uart.send_packet(data)

    def on_click_duty(self):
        duty_value = self.input_duty.text()
        self.label_duty.setText(f"串口发送PWM波形占空比配置: {duty_value}%!")
        duty_id = format(0x08, '02x')
        duty_value_hex = format(int(duty_value), '08x')
        data = [duty_id, duty_value_hex[0:2], duty_value_hex[2:4], duty_value_hex[4:6], duty_value_hex[6:8]]
        print(data)
        print(len(data))
        self.DAC_uart.send_packet(data)


    
    def on_combo_change_channel(self, index):
        selected_option_channel = self.combo_channel.currentText()
        self.label_channel.setText(f"串口发送通道配置: {selected_option_channel}")
        print(f"串口发送通道配置: {selected_option_channel}")
        channel_id = format(0x05, '02x')
        if(selected_option_channel == "通道1"):
            channel_value = format(0x00, '08x')
        elif(selected_option_channel == "通道2"):
            channel_value = format(0x01, '08x')
        data = [channel_id, channel_value[0:2], channel_value[2:4], channel_value[4:6], channel_value[6:8]]
        print(data)
        print(len(data))
        self.DAC_uart.send_packet(data)

    def on_combo_change_channel_pwm(self, index):
        selected_option_channel_pwm = self.combo_channel_pwm.currentText()
        self.label_channel_pwm.setText(f"串口发送PWM波形占空比通道配置: {selected_option_channel_pwm}")
        print(f"串口发送PWM波形占空比通道配置: {selected_option_channel_pwm}")
        channel_pwm_id = format(0x0a, '02x')
        if(selected_option_channel_pwm == "无"):
            channel_pwm_value = format(0x00, '08x')
        elif(selected_option_channel_pwm == "通道1"):
            channel_pwm_value = format(0x01, '08x')
        elif(selected_option_channel_pwm == "通道2"):
            channel_pwm_value = format(0x02, '08x')
        data = [channel_pwm_id, channel_pwm_value[0:2], channel_pwm_value[2:4], channel_pwm_value[4:6], channel_pwm_value[6:8]]
        print(data)
        print(len(data))
        self.DAC_uart.send_packet(data)

# ----------------------- 示波器通道配置 以及 屏幕显示内容 ------------------------ #

    def on_combo_change_channel_ADC(self,index):
        selected_option_channel_ADC = self.combo_channel_ADC.currentText()
        self.label_channel_ADC.setText(f"串口发送示波器通道配置: {selected_option_channel_ADC}")
        print(f"串口发送示波器通道配置: {selected_option_channel_ADC}")
        channel_ADC_id = format(0x18, '02x')
        if(selected_option_channel_ADC == "通道1"):
            channel_ADC_value = format(0x00, '08x')
        elif(selected_option_channel_ADC == "通道2"):
            channel_ADC_value = format(0x01, '08x')
        data = [channel_ADC_id, channel_ADC_value[0:2], channel_ADC_value[2:4], channel_ADC_value[4:6], channel_ADC_value[6:8]]
        print(data)
        print(len(data))
        self.ADC_uart.send_packet(data)

    def on_combo_display_mode(self,index):
        selected_option_display_mode = self.combo_display_mode.currentText()
        self.label_display_mode.setText(f"串口发送屏幕显示内容配置: {selected_option_display_mode}")
        print(f"串口发送屏幕显示内容配置: {selected_option_display_mode}")
        display_mode_id = format(0x19, '02x')
        if(selected_option_display_mode == "频谱仪"):
            display_mode_value = format(0x00, '08x')
        elif(selected_option_display_mode == "示波器通道1"):
            display_mode_value = format(0x01, '08x')
        elif(selected_option_display_mode == "示波器通道2"):
            display_mode_value = format(0x02, '08x')
        elif(selected_option_display_mode == "示波器双通道"):
            display_mode_value = format(0x03, '08x')
        elif(selected_option_display_mode == "信号发生器"):
            display_mode_value = format(0x04, '08x')
        data = [display_mode_id, display_mode_value[0:2], display_mode_value[2:4], display_mode_value[4:6], display_mode_value[6:8]]
        print(data)
        print(len(data))
        self.ADC_uart.send_packet(data)

# ----------------------- 示波器配置 ------------------------ #
    up_id = format(0x10, '02x')
    down_id = format(0x10, '02x')
    left_id = format(0x11, '02x')
    right_id = format(0x11, '02x')

    up_value = format(0x00, '10b')
    down_value = format(0x00, '10b')
    left_value = format(0x00, '10b')
    right_value = format(0x00, '10b')
    up_value_part = int(up_value[1:10],2)
    down_value_part = int(down_value[1:10],2)
    left_value_part = int(left_value[1:10],2)
    right_value_part = int(right_value[1:10],2)

    def on_click_up(self):
        print("↑")
        self.down_value_part = 0 # 重置向下移动的位移
        self.up_value_part += 16
        if self.up_value_part >= 512:
            self.up_value_part = 0
        up_value_part_bin = format(self.up_value_part, '09b')
        up_value_hex = format((self.up_value_part ), '08x')
        data = [self.up_id, up_value_hex[0:2], up_value_hex[2:4], up_value_hex[4:6], up_value_hex[6:8]]
        print(data)
        print(len(data))  
        self.ADC_uart.send_packet(data)     

    def on_click_down(self):
        print("↓")
        self.up_value_part = 0 # 重置向上移动的位移
        self.down_value_part += 16
        if self.down_value_part >= 512:
            self.down_value_part = 0
        down_value_part_bin = format(self.down_value_part, '09b')
        down_value_hex = format((self.down_value_part + 512), '08x')
        data = [self.down_id, down_value_hex[0:2], down_value_hex[2:4], down_value_hex[4:6], down_value_hex[6:8]]
        print(data)
        print(len(data))
        self.ADC_uart.send_packet(data)
    
    def on_click_left(self):
        print("←")
        self.right_value_part = 0 # 重置向右移动的位移
        self.left_value_part += 4
        if self.left_value_part >= 512:
            self.left_value_part = 0
        left_value_part_bin = format(self.left_value_part, '09b')
        left_value_hex = format((self.left_value_part ), '08x')
        data = [self.left_id, left_value_hex[0:2], left_value_hex[2:4], left_value_hex[4:6], left_value_hex[6:8]]
        print(data)
        print(len(data))
        self.ADC_uart.send_packet(data)

    def on_click_right(self):
        print("→")
        self.left_value_part = 0 # 重置向左移动的位移
        self.right_value_part += 4
        if self.right_value_part >= 512:
            self.right_value_part = 0
        right_value_part_bin = format(self.right_value_part, '09b')
        right_value_hex = format((self.right_value_part + 512), '08x')
        data = [self.right_id, right_value_hex[0:2], right_value_hex[2:4], right_value_hex[4:6], right_value_hex[6:8]]
        print(data)
        print(len(data))
        self.ADC_uart.send_packet(data)

    run_stop_value = 1
    def on_click_run_stop(self):
        if(self.run_stop_value == 1):
           self.run_stop_value = 0
        else:
            self.run_stop_value = 1
        run_stop_id = format(0x12, '02x')
        run_stop_value_hex = format(self.run_stop_value, '08x')
        data = [run_stop_id, run_stop_value_hex[0:2], run_stop_value_hex[2:4], run_stop_value_hex[4:6], run_stop_value_hex[6:8]]
        print(data)
        print(len(data))
        self.ADC_uart.send_packet(data)

    edge_value = 0
    def on_click_edge(self):
        if(self.edge_value == 0):
            self.edge_value = 1
        else:
            self.edge_value = 0
        edge_id = format(0x13, '02x')
        edge_value_hex = format(self.edge_value, '08x')
        data = [edge_id, edge_value_hex[0:2], edge_value_hex[2:4], edge_value_hex[4:6], edge_value_hex[6:8]]
        print(data)
        print(len(data))
        self.ADC_uart.send_packet(data)





    def on_combo_change_deci_rate(self, index):
        selected_option_deci_rate = self.combo_deci_rate.currentText()
        self.label_deci_rate.setText(f"串口发送时间分辨率配置: {selected_option_deci_rate}")
        print(f"串口发送时间分辨率配置: {selected_option_deci_rate}")
        deci_rate_id = format(0x14, '02x')
        if(selected_option_deci_rate == "1us"):
            deci_rate_value = format(3, '08x')
        elif(selected_option_deci_rate == "2us"):
            deci_rate_value = format(6, '08x')
        elif(selected_option_deci_rate == "4us"):
            deci_rate_value = format(13, '08x')
        elif(selected_option_deci_rate == "8us"):
            deci_rate_value = format(26, '08x')
        elif(selected_option_deci_rate == "20us"):
            deci_rate_value = format(65, '08x')
        elif(selected_option_deci_rate == "40us"):
            deci_rate_value = format(130, '08x')
        elif(selected_option_deci_rate == "100us"):
            deci_rate_value = format(325, '08x')
        elif(selected_option_deci_rate == "200us"):
            deci_rate_value = format(650, '08x')
        elif(selected_option_deci_rate == "500us"):
            deci_rate_value = format(1625, '08x')#1625
        elif(selected_option_deci_rate == "1ms"):
            deci_rate_value = format(3250, '08x')#3250

        data = [deci_rate_id, deci_rate_value[0:2], deci_rate_value[2:4], deci_rate_value[4:6], deci_rate_value[6:8]]
        print(data)
        print(len(data))
        self.ADC_uart.send_packet(data)
        
    def on_combo_change_voltage(self, index):
        selected_option_voltage = self.combo_voltage.currentText()
        self.label_voltage.setText(f"串口发送电压分辨率配置: {selected_option_voltage}")
        print(f"串口发送电压分辨率配置: {selected_option_voltage}")
        voltage_id = format(0x15, '02x')
        if(selected_option_voltage == "500mv"):
            voltage_value = format(0b00000, '08x')
        elif(selected_option_voltage == "1V"):
            voltage_value = format(0b00010, '08x')
        elif(selected_option_voltage == "2V"):
            voltage_value = format(0b00100, '08x')
        elif(selected_option_voltage == "4V"):
            voltage_value = format(0b00110, '08x')
        elif(selected_option_voltage == "250mv"):
            voltage_value = format(0b10010, '08x')
        elif(selected_option_voltage == "100mv"):
            voltage_value = format(0b10101, '08x')
        data = [voltage_id, voltage_value[0:2], voltage_value[2:4], voltage_value[4:6], voltage_value[6:8]]
        print(data)
        print(len(data))
        self.ADC_uart.send_packet(data)


    def on_click_trigger(self):
        trigger_value = self.input_trigger.text()
        self.label_trigger.setText(f"串口发送触发电平配置: {trigger_value}取值范围:0-4095;2048对应0V")
        print(f"串口发送触发电平配置: {trigger_value}")
        trigger_id = format(0x16, '02x')
        trigger_value_hex = format(int(trigger_value), '08x')
        data = [trigger_id, trigger_value_hex[0:2], trigger_value_hex[2:4], trigger_value_hex[4:6], trigger_value_hex[6:8]]
        print(data)
        print(len(data))
        self.ADC_uart.send_packet(data)

    def on_click_trigger_line(self):
        trigger_line_value = self.input_trigger_line.text()
        self.label_trigger_line.setText(f"串口发送触发线配置: {trigger_line_value}取值范围:29-429;228对应0V位置")
        print(f"串口发送触发线配置: {trigger_line_value}")
        trigger_line_id = format(0x17, '02x')
        trigger_line_value_hex = format(int(trigger_line_value), '08x')
        data = [trigger_line_id, trigger_line_value_hex[0:2], trigger_line_value_hex[2:4], trigger_line_value_hex[4:6], trigger_line_value_hex[6:8]]
        print(data)
        print(len(data))
        self.ADC_uart.send_packet(data)

    

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MyApp_GUI()
    window.show()
    sys.exit(app.exec_())
