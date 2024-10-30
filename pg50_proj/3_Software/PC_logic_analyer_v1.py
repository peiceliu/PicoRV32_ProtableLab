import sys
from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QPushButton, QLineEdit, QVBoxLayout, QComboBox, QHBoxLayout, QGridLayout, QTextEdit,QFormLayout,QDialog
from PyQt5.QtGui import QPixmap
from PyQt5.QtCore import QThread, pyqtSignal, QTimer
import pyqtgraph as pg
import numpy as np
import socket
import serial
import time
pg.setConfigOptions(useOpenGL=True)

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
# ----------- 协议细节弹窗实现 -----------
class uart_dialog(QDialog):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("选择UART配置")
        layout = QFormLayout()
        self.channel_choose = QComboBox(self)
        self.channel_choose.addItems(["通道1", "通道2", "通道3", "通道4", "通道5", "通道6"])
        layout.addRow("选择通道:", self.channel_choose)
        self.baud_rate_combo = QComboBox(self)
        self.baud_rate_combo.addItems(["9600", "19200", "38400", "57600", "115200"])
        layout.addRow("波特率:", self.baud_rate_combo)
        self.data_num_combo = QComboBox(self)
        self.data_num_combo.addItems(["8位数据位(标准)", "9位数据位(扩展)"])
        layout.addRow("数据位:", self.data_num_combo)
        self.stop_bit_combo = QComboBox(self)
        self.stop_bit_combo.addItems(["1位停止位(标准)","1.5位停止位" "2位停止位"])
        layout.addRow("停止位:", self.stop_bit_combo)
        self.parity_combo = QComboBox(self)
        self.parity_combo.addItems(["无校验(标准)", "奇校验", "偶校验"])
        layout.addRow("校验位:", self.parity_combo)

        self.ok_button = QPushButton("确定",self)
        self.ok_button.clicked.connect(self.accept)
        layout.addRow(self.ok_button)
        self.setLayout(layout)
    def get_uart_cfg(self):
        baud_rate = int(self.baud_rate_combo.currentText())
        data_num = self.data_num_combo.currentIndex()
        stop_bit = self.stop_bit_combo.currentIndex()
        parity = self.parity_combo.currentIndex()
        return baud_rate, data_num, stop_bit, parity

class one_wire_dialog(QDialog):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("选择1-Wire配置")
        layout = QFormLayout()
        self.channel_choose = QComboBox(self)
        self.channel_choose.addItems(["通道1", "通道2", "通道3", "通道4", "通道5", "通道6"])
        layout.addRow("选择通道:", self.channel_choose)
        self.rate_combo = QComboBox(self)
        self.rate_combo.addItems(["标准模式(16.3kbps)", "高速模式(142kbps)"])
        layout.addRow("速率:", self.rate_combo)
        self.ok_button = QPushButton("确定",self)
        self.ok_button.clicked.connect(self.accept)
        layout.addRow(self.ok_button)
        self.setLayout(layout)
    def get_1_wire_cfg(self):
        rate = self.rate_combo.currentIndex()
        return rate

class i2c_dialog(QDialog):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("选择I2C配置")
        layout = QFormLayout()
        self.sda_channel_choose = QComboBox(self)
        self.sda_channel_choose.addItems(["通道1", "通道2", "通道3", "通道4", "通道5", "通道6"])
        layout.addRow("SDA通道:", self.sda_channel_choose)
        self.scl_channel_choose = QComboBox(self)
        self.scl_channel_choose.addItems(["通道2", "通道3", "通道4", "通道5", "通道6", "通道1"])
        layout.addRow("SCL通道:", self.scl_channel_choose)
        self.rate_combo = QComboBox(self)
        self.rate_combo.addItems(["标准模式(100kbps)", "快速模式(400kbps)","高速模式(3.4Mbps)"])
        layout.addRow("速率:", self.rate_combo)
        self.ok_button = QPushButton("确定",self)
        self.ok_button.clicked.connect(self.accept)
        layout.addRow(self.ok_button)
        self.setLayout(layout)
    def get_i2c_cfg(self):
        rate = self.rate_combo.currentIndex()
        return rate

class spi_dialog(QDialog):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("选择SPI配置")
        layout = QFormLayout()
        # MOSI, MISO, SCLK, SCS 通道选择
        self.mosi_channel_choose = QComboBox(self)
        self.mosi_channel_choose.addItems(["通道1", "通道1", "通道2", "通道3", "通道4", "通道5"])
        layout.addRow("MOSI:", self.mosi_channel_choose)
        self.miso_channel_choose = QComboBox(self)
        self.miso_channel_choose.addItems(["通道2", "通道1", "通道2", "通道3", "通道4", "通道5"])
        layout.addRow("MISO:", self.miso_channel_choose)
        self.sclk_channel_choose = QComboBox(self)
        self.sclk_channel_choose.addItems(["通道3", "通道1", "通道2", "通道3", "通道4", "通道5"])
        layout.addRow("SCLK:", self.sclk_channel_choose)
        self.scs_channel_choose = QComboBox(self)
        self.scs_channel_choose.addItems(["通道4", "通道1", "通道2", "通道3", "通道4", "通道5"])
        layout.addRow("SCS:", self.scs_channel_choose)
        # MSB/LSB 选择
        self.bit_order_combo = QComboBox(self)
        self.bit_order_combo.addItems(["高位(MSB)在前", "低位(LSB)在前"])
        layout.addRow("数据位顺序:", self.bit_order_combo)
        # 数据长度选择
        self.data_length_combo = QComboBox(self)
        self.data_length_combo.addItems(["8位单次传输长度", "16位单次传输长度"])
        layout.addRow("数据长度:", self.data_length_combo)
        # CPOL 和 CPHA 选择
        self.cpol_combo = QComboBox(self)
        self.cpol_combo.addItems(["时钟空闲时为低电平(CPOL=0)", "时钟空闲时为高电平(CPOL=1)"])
        layout.addRow("时钟极性:", self.cpol_combo)
        self.cpha_combo = QComboBox(self)
        self.cpha_combo.addItems(["数据在第一个时钟沿采样(CPHA=0)", "数据在第二个时钟沿采样(CPHA=1)"])
        layout.addRow("时钟相位:", self.cpha_combo)
        # Enable 低电平有效选择
        self.enable_low_combo = QComboBox(self)
        self.enable_low_combo.addItems(["Enable信号低电平有效", "Enable信号高电平有效"])
        layout.addRow("Enable 低电平有效:", self.enable_low_combo)
        # 确定按钮
        self.ok_button = QPushButton("确定", self)
        self.ok_button.clicked.connect(self.accept)
        layout.addRow(self.ok_button)
        self.setLayout(layout)
    def get_spi_cfg(self):
        return {
            "mosi_channel": self.mosi_channel_choose.currentText(),
            "miso_channel": self.miso_channel_choose.currentText(),
            "sclk_channel": self.sclk_channel_choose.currentText(),
            "scs_channel": self.scs_channel_choose.currentText(),
            "bit_order": self.bit_order_combo.currentText(),
            "data_length": self.data_length_combo.currentText(),
            "cpol": self.cpol_combo.currentText(),
            "cpha": self.cpha_combo.currentText(),
            "enable_low": self.enable_low_combo.currentText(),
        }

# CAN 协议对话框
class can_dialog(QDialog):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("选择CAN配置")
        layout = QFormLayout()
        # CAN 数据通道选择
        self.dat_channel_choose = QComboBox(self)
        self.dat_channel_choose.addItems(["通道1", "通道2", "通道3", "通道4", "通道5", "通道6"])
        layout.addRow("DAT:", self.dat_channel_choose)
        # 波特率输入框
        self.baud_rate_input = QLineEdit(self)
        self.baud_rate_input.setText("200000")  # 默认波特率 200000bps
        layout.addRow("波特率(bps):", self.baud_rate_input)
        # 确定按钮
        self.ok_button = QPushButton("确定", self)
        self.ok_button.clicked.connect(self.accept)
        layout.addRow(self.ok_button)
        
        self.setLayout(layout)

    def get_can_cfg(self):
        return {
            "dat_channel": self.dat_channel_choose.currentText(),
            "baud_rate": self.baud_rate_input.text(),
        }
class DataAcquisitionThread(QThread):
    data_ready = pyqtSignal(list,list)  # 信号，用于通知主线程数据准备好了

    def __init__(self,sample_rate,sample_depth,channel_num,parent = None):
        super().__init__(parent)
        self.sample_rate_value = sample_rate
        self.sample_depth = sample_depth
        self.channel_num = channel_num
        self.running = True

    def receive_udp_packet(self):
        # 从以太网接收数据包
        self.UDP_IP="192.168.1.102"
        self.UDP_PORT=32896
        self.packet_count = int(self.sample_depth // 1000)
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.bind((self.UDP_IP, self.UDP_PORT))
        received_data = []
        print(f"listening for UDP packets on {self.UDP_IP}:{self.UDP_PORT}")
        try:
            print("try to receive data")
            for i in range(500): #self.packet_count
                data, _ = sock.recvfrom(1000000)
                print(f"received packet {i}")
                received_data.extend(np.frombuffer(data, dtype=np.uint8))
            print("received all packets")
            print(received_data)
            print(len(received_data))
        finally:
            sock.close()
        return received_data
    
    def run(self):
        while self.running:
            stride = 1e6 / self.sample_rate_value
            range_num = self.sample_depth * stride
            self.time = np.arange(0,range_num,stride) #时间轴范围以及步进值
            self.data = [[] for _ in range(6)]
            udp_data = self.receive_udp_packet()

            for byte in udp_data:
                for bit_index in range(6):
                    bit_value = (byte >> bit_index) & 0x01
                    self.data[bit_index].append(bit_value)

            # for i in range(self.channel_num):
            #     channel_data = np.random.randint(0, 2, int(range_num))
            #     self.data.append(channel_data)
            # print("ehternet_time:",len(self.time))
            # print("ehternet_range_num:",range_num)
            # print("ethernet_stride:",stride)
            self.data_ready.emit(self.data , self.time.tolist())  # 将采集的数据通过信号发送到主线程
            self.running = False

    def stop(self):
        self.running = False


class LogicAnalyzerApp(QWidget):  # 主线程
    def __init__(self):
        super().__init__()
        # self.ADC_uart = SerialProtocol("COM5",9600) #初始化串口
        self.setWindowTitle("紫光_基于Picorv32的便捷式多功能仪_逻辑分析仪")
        # 设置布局
        layout = QVBoxLayout()  
        self.setLayout(layout)  
        # 添加开始采样按钮
        controls_layout = QHBoxLayout()
        self.start_button = QPushButton("开始采样")
        self.start_button.clicked.connect(self.on_start_button_click)
        controls_layout.addWidget(self.start_button)
        # 添加采样深度下拉栏
        self.label_sample_depth = QLabel("采样深度:")
        self.combo_sample_depth = QComboBox()
        self.combo_sample_depth.addItems(["20Ksa", "200Ksa", "1Msa", "2Msa","5Msa","10Msa", "20Msa", "50Msa","100Msa","200Msa","500Msa","1Gsa"])
        self.combo_sample_depth.currentIndexChanged.connect(self.on_sample_depth_changed)
        sample_depth_layout = QHBoxLayout()
        sample_depth_layout.addWidget(self.label_sample_depth)
        sample_depth_layout.addWidget(self.combo_sample_depth)
        sample_depth_layout.addStretch()
        controls_layout.addLayout(sample_depth_layout)
        # 添加采样速率下拉栏
        self.label_sample_rate = QLabel("采样速率:")
        self.combo_sample_rate = QComboBox()
        self.combo_sample_rate.addItems(["20Khz", "50Khz", "100Khz", "200Khz","500Khz","1Mhz", "2Mhz", "5Mhz","10Mhz","20Mhz","50Mhz","100Mhz","200Mhz","500Mhz"])
        self.combo_sample_rate.currentIndexChanged.connect(self.on_sample_rate_changed)
        sample_rate_layout = QHBoxLayout()
        sample_rate_layout.addWidget(self.label_sample_rate)
        sample_rate_layout.addWidget(self.combo_sample_rate)
        sample_rate_layout.addStretch()
        controls_layout.addLayout(sample_rate_layout)
        # 添加触发条件下拉栏
        self.label_trigger = QLabel("触发条件:")
        self.combo_trigger = QComboBox()
        self.combo_trigger.addItems(["高电平触发", "低电平触发", "上升沿触发", "下降沿触发"])
        self.combo_trigger.currentIndexChanged.connect(self.on_trigger_changed)
        trigger_layout = QHBoxLayout()
        trigger_layout.addWidget(self.label_trigger)
        trigger_layout.addWidget(self.combo_trigger)
        trigger_layout.addStretch()
        controls_layout.addLayout(trigger_layout)
        # 添加触发通道下拉栏
        self.label_trigger_channel = QLabel("触发通道:")
        self.combo_trigger_channel = QComboBox()
        self.combo_trigger_channel.addItems(["通道1", "通道2", "通道3", "通道4", "通道5", "通道6"])
        self.combo_trigger_channel.currentIndexChanged.connect(self.on_trigger_channel_changed)
        trigger_channel_layout = QHBoxLayout()
        trigger_channel_layout.addWidget(self.label_trigger_channel)
        trigger_channel_layout.addWidget(self.combo_trigger_channel)
        trigger_channel_layout.addStretch()
        controls_layout.addLayout(trigger_channel_layout)
        # 添加通道数量下拉栏
        self.label_channel_num = QLabel("通道数量:")
        self.combo_channel_num = QComboBox()
        self.combo_channel_num.addItems(["6", "2", "3", "4", "5", "1"])
        self.combo_channel_num.currentIndexChanged.connect(self.on_channel_num_changed)
        channel_num_layout = QHBoxLayout()
        channel_num_layout.addWidget(self.label_channel_num)
        channel_num_layout.addWidget(self.combo_channel_num)
        channel_num_layout.addStretch()
        controls_layout.addLayout(channel_num_layout)
        # 添加协议选择下拉栏
        self.label_protocol = QLabel("协议选择:")
        self.combo_protocol = QComboBox()
        self.combo_protocol.addItems([ "I2C", "SPI", "UART/RS232/485","1-Wire","CAN"])
        self.combo_protocol.currentIndexChanged.connect(self.on_protocol_changed)
        protocol_layout = QHBoxLayout()
        protocol_layout.addWidget(self.label_protocol)
        protocol_layout.addWidget(self.combo_protocol)
        protocol_layout.addStretch()
        controls_layout.addLayout(protocol_layout)
        # 添加layout到主layout
        layout.addLayout(controls_layout)
        # 初始化图形窗口 相关逻辑分析仪波形显示
        self.win = pg.GraphicsLayoutWidget(show=True)
        self.sample_depth_value = 2e4
        self.sample_rate_value = 1e6
        self.stride = 1e6/self.sample_rate_value
        self.range_num = self.sample_depth_value *(self.stride)  
        self.channel_num = 6
        self.add_step = 1
        self.plots = []  
        self.curves = []  
        self.data = []  
        self.time = np.arange(0, self.range_num,self.stride) #时间轴范围以及步进值
        self.text_items = []  
        self.control_data = 0
        self.colors = ['#FF00FF', '#0000FF', '#00FF00', '#FF0000', '#FFFF00', '#00FFFF']
        # 遍历选择的通道数量
        for i in range(self.channel_num):
            plot = self.win.addPlot(row=i, col=0)  
            plot.setLabel('left', f'CH{i}')  
            plot.setLabel('bottom', 'Time (us)')  
            plot.showGrid(x=True, y=True)  
            plot.setYRange(0, 1)  
            plot.setMouseEnabled(x=True, y=False)  
            plot.setLimits(xMin=0, xMax=self.range_num)  
            plot.setXRange(0, 100)  
            plot.vb.sigXRangeChanged.connect(self.update_ticks)  
            curve = plot.plot(pen=pg.mkPen(color=self.colors[i], width=2))  
            self.plots.append(plot)  
            self.curves.append(curve)  
            # 初始化数据用随机数进行填充
            self.data.append(np.random.randint(0, 2, len(self.time)))

            #用来模拟I2C真实数据
            if i == 0:
                self.data[0] = np.random.choice([0, 1], len(self.time))
            elif i == 1:
                self.data[1] = np.tile([0, 1], len(self.time) // 2)

            # 画波形曲线 将x、y数据点扩大为2倍 使得显示方波
            step_time = np.repeat(self.time, 2)[:-1]
            step_data = np.repeat(self.data[i], 2)[1:]
            self.curves[i].setData(step_time, step_data)
            # self.curves[i].setData(self.time, self.data[i])
        # 添加到主layout
        layout.addWidget(self.win)
        # 添加 QTextEdit 控件来显示日志
        self.label_protocol = QLabel("协议解析:")
        self.log_protocol = QTextEdit()
        self.log_protocol.setReadOnly(True)  # 设置为只读模式
        layout.addWidget(self.log_protocol)  # 添加到布局中

        # 添加串口接收数据窗口
        self.received_buffer = ""
        self.label_received = QLabel("软核反馈数据:")
        self.received_text = QTextEdit()
        self.received_text.setReadOnly(True)
        received_layout = QHBoxLayout()
        received_layout.addWidget(self.label_received)
        # self.ADC_uart.received_data.connect(self.buffer_received_data)
        # self.ADC_uart.start()
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_received_data)
        self.timer.start(1000)
        self.received_buffer = ""

        received_layout.addWidget(self.received_text)
        received_layout.addStretch()
        layout.addLayout(received_layout)
        
    def buffer_received_data(self, data):
        self.received_buffer += data
    def update_received_data(self):
        if self.received_buffer:
            if len(self.received_buffer) > 200:
                self.received_text.clear()
            self.received_text.insertPlainText(self.received_buffer)
            self.received_buffer = ""

        # ----------------- -----------------
        timer = QTimer()
        timer.start(1000)
        timer.timeout.connect(self.update_waveform)
        # ----------------- -----------------

    def on_protocol_changed(self):
        protocol = self.combo_protocol.currentText()
        if protocol == "UART/RS232/485":
            UART_dialog = uart_dialog()
            if UART_dialog.exec_():
                baud_rate, data_num, stop_bit, parity = UART_dialog.get_uart_cfg()
                print(baud_rate, data_num, stop_bit, parity)

        elif protocol == "1-Wire":
            ONE_wire_dialog = one_wire_dialog()
            if ONE_wire_dialog.exec_():
                rate = ONE_wire_dialog.get_1_wire_cfg()
                print(rate)
        elif protocol == "I2C":
            I2C_dialog = i2c_dialog()
            if I2C_dialog.exec_():
                rate = I2C_dialog.get_i2c_cfg()
                print(rate)
        elif protocol == "SPI":
            SPI_dialog = spi_dialog()
            if SPI_dialog.exec_():
                spi_cfg = SPI_dialog.get_spi_cfg()
                print(spi_cfg)
        elif protocol == "CAN":
            CAN_dialog = can_dialog()
            if CAN_dialog.exec_():
                can_cfg = CAN_dialog.get_can_cfg()
                print(can_cfg)

    # 鼠标在通道0 进行缩放时 根据当前显示的坐标范围大小 更新坐标轴刻度
    def update_ticks(self):
        view_range = self.plots[0].vb.state['viewRange'][0]  
        range_size = view_range[1] - view_range[0]  
        for plot in self.plots:
            plot.setXRange(view_range[0], view_range[1], padding=0)

            if range_size > 1:
                unit = 'us'
                major_ticks_interval = 1
                minor_ticks_interval = 0.1
                if range_size > 10:
                    major_ticks_interval = 10
                    minor_ticks_interval = 1
                if range_size > 100:
                    major_ticks_interval = 100
                    minor_ticks_interval = 10
            else:
                unit = 'us+ns'
                major_ticks_interval = 0.1
                minor_ticks_interval = 0.01

            major_ticks_interval = np.arange(np.floor(view_range[0] / major_ticks_interval) * major_ticks_interval,
                                             np.ceil(view_range[1] / major_ticks_interval) * major_ticks_interval,
                                             major_ticks_interval)
            minor_ticks_interval = np.arange(np.floor(view_range[0] / minor_ticks_interval) * minor_ticks_interval,
                                             np.ceil(view_range[1] / minor_ticks_interval) * minor_ticks_interval,
                                             minor_ticks_interval)
            if unit == 'us+ns':
                def format_time_label(value):
                    us_part = int(value)
                    ns_part = int((value - us_part) * 1e3)
                    return f'{us_part} us + {ns_part} ns'
                axis = plot.getAxis('bottom')
                axis.setTicks([[(v, format_time_label(v)) for v in major_ticks_interval], [(v, '') for v in minor_ticks_interval]])
            else:
                axis = plot.getAxis('bottom')
                axis.setTicks([[(v, f'{int(v)} {unit}') for v in major_ticks_interval], [(v, '') for v in minor_ticks_interval]])

        # 以数据点为单位测试UART协议解析通过，未添加波特率
        self.state = "IDLE"
        self.bit_count = 0
        self.current_byte = 0
        
        self.stride = 1e6/self.sample_rate_value
        print("sample_rate:",self.sample_rate_value)
        print("stride:",self.stride)

        self.datainrange_num = int(view_range[1] / self.stride)
        self.data_fu_range_num = int(view_range[0] / self.stride)
        # for i in range(self.channel_num):  
        j = 0
        # self.bit_count = 0
        # self.current_byte = 0

        # self.time_per_sample = int (self.sample_rate_value / 115200)
        # while (j <= self.datainrange_num) and (j >= 0):
        #     bit = self.data[0][j]
        #     step_edge = 100
        #     bit_left = self.data[0][j-step_edge]
        #     bit_right = self.data[0][j+step_edge]
        #     if j == 0:
        #         bit_detect = self.data[0][step_edge]
        #     else:
        #         if bit_left == 1 and bit_right == 0:
        #             bit_detect = 0
        #         elif bit_left == 0 and bit_right == 1:
        #             bit_detect = 1
        #         else:
        #             bit_detect = bit

        #     if self.state == "IDLE":
        #         if bit_detect == 0:
        #             self.state = "RECEIVING"
        #             self.bit_count = 0
        #             self.current_byte = 0
        #         j = j +  self.time_per_sample

        #     elif self.state == "RECEIVING":
        #         if self.bit_count <8:
        #             self.current_byte |= bit_detect << self.bit_count 
        #             self.bit_count += 1
        #         else:
        #             if bit_detect ==1:
        #                     self.log_protocol.append(f"通道{0}:x_range = {(j-10*self.time_per_sample)*self.stride} : {(j)*self.stride}UART 数据 = {self.current_byte}, 二进制显示 :{format(self.current_byte,'08b')},十六进制显示 :{format(self.current_byte,'02x')},ASCII显示 :{format(self.current_byte,'c')}")
        #                     # self.log_protocol.append(f"二进制显示 :{format(self.current_byte,'08b')}")
        #                     # self.log_protocol.append(f"十六进制显示 :{format(self.current_byte,'02x')}")
        #                     # self.log_protocol.append(f"ASCII显示 :{format(self.current_byte,'c')}") 
        #                     self.current_byte = 0
        #                     self.bit_count = 0
        #             self.state = "IDLE"
        #         j +=  self.time_per_sample


    
        # I2C协议解析 默认为标准模式100Khz SCL上升沿时采样SDA上的数据 SDA数据在SCL为低电平时设置
        self.I2C_state = "IDLE"
        self.I2C_byte = 0
        self.I2C_bit_count = 0
        print("I2C begin to parse")
        while (j <= self.datainrange_num) and (j >= 0):
            SDA_I2C = self.data[0][j]
            SCL_I2C = self.data[1][j]
            step_edge_I2C = 100
            pre_SDA_I2C = self.data[0][j-1]
            pre_SCL_I2C = self.data[1][j-1]
            if self.I2C_state == "IDLE":
                if SCL_I2C == 1 and SDA_I2C == 0 and pre_SDA_I2C == 1:
                    self.I2C_state = "START"
                    self.I2C_bit_count = 0
                    self.I2C_byte = 0
                    self.log_protocol.append(f"通道{0}:x_range = {(j-1)*self.stride}: {(j)*self.stride} I2C START")
                j += 1
            elif self.I2C_state == "START":
                if SCL_I2C == 1 and SDA_I2C == 1 and pre_SDA_I2C ==0:
                    self.I2C_state = "IDLE"
                    self.I2C_bit_count = 0
                    self.I2C_byte = 0
                    self.log_protocol.append(f"通道{0}:x_range = {(j-1)*self.stride}:{j * self.stride} I2C STOP")
                elif SCL_I2C == 1:
                    if self.I2C_bit_count <7:
                        self.I2C_byte |= SDA_I2C << (6-self.I2C_bit_count) 
                        self.I2C_bit_count += 1
                    elif self.I2C_bit_count == 7:
                        if SDA_I2C == 0:
                            self.log_protocol.append(f"通道{0}:x_range = {(j-16)*self.stride} : {j * self.stride}  从设备地址 = {self.I2C_byte},二进制显示为{format(self.I2C_byte,'07b')},十六进制显示为{format(self.I2C_byte,'02x')},ASCII显示 :{format(self.I2C_byte,'c')}    I2C ACK")
                        else:
                            self.log_protocol.append(f"通道{0}:x_range = {(j-16)*self.stride} : {j * self.stride} 从设备地址 = {self.I2C_byte},二进制显示为{format(self.I2C_byte,'07b')},十六进制显示为{format(self.I2C_byte,'02x')},ASCII显示 :{format(self.I2C_byte,'c')}     I2C NACK")
                        self.I2C_bit_count = 0
                        self.I2C_byte = 0
                        self.I2C_state = "DATA"
                j += 1
            elif self.I2C_state == "DATA":
                # if SCL_I2C == 1 and SDA_I2C == 1 and pre_SDA_I2C == 0 :
                #     self.I2C_state = "IDLE"
                #     self.I2C_bit_count = 0
                #     self.I2C_byte = 0
                #     self.log_protocol.append(f"通道{0}:x_range = {(j-1)*self.stride}:{j * self.stride} I2C STOP")
                # elif SCL_I2C == 1:
                if SCL_I2C == 1:
                    if self.I2C_bit_count <8:
                        self.I2C_byte |= SDA_I2C << (7-self.I2C_bit_count)
                        self.I2C_bit_count += 1
                    elif self.I2C_bit_count == 8:
                        if SDA_I2C == 0:
                            self.log_protocol.append(f"通道{0}:x_range = {(j-18)*self.stride} : {j * self.stride} I2C 数据 = {self.I2C_byte} 二进制显示为{format(self.I2C_byte,'08b')},十六进制显示 :{format(self.I2C_byte,'02x')},ASCII显示 :{format(self.I2C_byte,'c')}   I2C ACK")
                        else:
                            self.log_protocol.append(f"通道{0}:x_range = {(j-18)*self.stride} : {j * self.stride} I2C 数据 = {self.I2C_byte} 二进制显示为{format(self.I2C_byte,'08b')},十六进制显示 :{format(self.I2C_byte,'02x')},ASCII显示 :{format(self.I2C_byte,'c')}   I2C NACK")
                        self.I2C_bit_count = 0
                        self.I2C_byte = 0
                j += 1









        # I2C协议解析 默认为标准模式100Khz SCL上升沿时采样SDA上的数据 SDA数据在SCL为低电平时设置
        # self.I2C_state = "IDLE"
        # self.I2C_byte = 0
        # self.I2C_bit_count = 0
        # print("I2C begin to parse")
        # while (j <= self.datainrange_num) and (j >= 0):
        #     SDA_I2C = self.data[0][j]
        #     SCL_I2C = self.data[1][j]
        #     step_edge_I2C = 100
        #     pre_SDA_I2C = self.data[0][j-1]
        #     pre_SCL_I2C = self.data[1][j-1]
        #     if self.I2C_state == "IDLE":
        #         if SCL_I2C == 1 and SDA_I2C == 0 and pre_SDA_I2C == 1:
        #             self.I2C_state = "START"
        #             self.I2C_bit_count = 0
        #             self.I2C_byte = 0
        #             self.log_protocol.append(f"通道{0}:x_range = {(j-1)*self.stride}: {(j)*self.stride} I2C START")
        #         j += 1
        #     elif self.I2C_state == "START":
        #         if SCL_I2C == 1 and SDA_I2C == 1 and pre_SDA_I2C ==0:
        #             self.I2C_state = "IDLE"
        #             self.I2C_bit_count = 0
        #             self.I2C_byte = 0
        #             self.log_protocol.append(f"通道{0}:x_range = {(j-1)*self.stride}:{j * self.stride} I2C STOP")
        #         elif SCL_I2C == 1: #and pre_SCL_I2C == 0:
        #             if self.I2C_bit_count <8:
        #                 self.I2C_byte |= SDA_I2C << (7-self.I2C_bit_count) 
        #                 self.I2C_bit_count += 1
        #             elif self.I2C_bit_count == 8:
        #                 if SDA_I2C == 0:
        #                     self.log_protocol.append(f"通道{0}:x_range = {(j-18)*self.stride} : {j * self.stride} I2C 数据 = {self.I2C_byte} 二进制显示为{format(self.I2C_byte,'08b')},I2C ACK")
        #                 else:
        #                     self.log_protocol.append(f"通道{0}:x_range = {(j-18)*self.stride} : {j * self.stride} I2C 数据 = {self.I2C_byte} 二进制显示为{format(self.I2C_byte,'08b')}, I2C NACK")
        #                 self.I2C_bit_count = 0
        #                 self.I2C_byte = 0
        #         j += 1



            # protocol = self.combo_protocol.currentText()
            # if protocol == "UART/RS232/485":
            #     self.parse_uart(self.data[0], 9600)
            # elif protocol == "1-Wire":
            #     self.parse_1wire(self.data[0])
            # elif protocol == "I2C":
            #     self.parse_i2c(self.data[0], self.data[1])
            # elif protocol == "SPI":
            #     self.parse_spi(self.data[0], self.data[1], self.data[2], 0, 0)
            # elif protocol == "CAN":
            #     self.parse_can(self.data[0])
            


    # ----------- 1-Wire 协议解析 -----------
    def parse_1wire(self, data):
        time_per_sample = 1 / self.sample_rate_value
        write_0_time_min = 60e-6
        write_0_time_max = 120e-6
        write_1_time_min = 1e-6
        write_1_time_max = 15e-6
        write_0_samples_min = int(write_0_time_min / time_per_sample)
        write_0_samples_max = int(write_0_time_max / time_per_sample)
        write_1_samples_min = int(write_1_time_min / time_per_sample)
        write_1_samples_max = int(write_1_time_max / time_per_sample)

        def find_bits(data):
            bit_values = []
            index = 0
            while index < len(data):
                if data[index] == 0:
                    start = index
                    while index < len(data) and data[index] == 0:
                        index += 1
                    low_duration_samples = index - start
                    if write_0_samples_min <= low_duration_samples <= write_0_samples_max:
                        bit_values.append(0)
                    elif write_1_samples_min <= low_duration_samples <= write_1_samples_max:
                        bit_values.append(1)
                    else:
                        bit_values.append(None)
                index += 1
            return bit_values

        bits = find_bits(data)
        for i, bit in enumerate(bits):
            if bit is not None:
                self.log_protocol.append(f"1-Wire协议数据位 {i}: {bit}")
        return bits

    # ----------- I2C 协议解析 -----------
    def parse_i2c(self, scl_data, sda_data):
        def detect_start_condition(scl_data, sda_data):
            for i in range(1, len(scl_data)):
                if sda_data[i - 1] == 1 and sda_data[i] == 0 and scl_data[i] == 1:
                    return i
            return None
        def parse_data(scl_data, sda_data):
            start_idx = detect_start_condition(scl_data, sda_data)
            if start_idx is None:
                return None
            data_bytes = []
            bit_counter = 0
            current_byte = 0
            for i in range(start_idx, len(scl_data)):
                if scl_data[i] == 1:
                    bit = sda_data[i]
                    current_byte = (current_byte << 1) | bit
                    bit_counter += 1
                    if bit_counter == 8:
                        data_bytes.append(current_byte)
                        self.log_protocol.append(f"I2C 协议解析数据: {current_byte} (十六进制: {format(current_byte, '02x')}, 二进制: {format(current_byte, '08b')}, ASCII: {chr(current_byte)})")
                        current_byte = 0
                        bit_counter = 0
            return data_bytes
        i2c_data = parse_data(scl_data, sda_data)
        return i2c_data
    # ----------- SPI 协议解析 -----------
    def parse_spi(self, sclk_data, mosi_data, miso_data, CPOL, CPHA):
        def find_clock_edges(sclk_data, CPOL, CPHA):
            edges = []
            for i in range(1, len(sclk_data)):
                if CPOL == 0:
                    if sclk_data[i - 1] == 0 and sclk_data[i] == 1:
                        if CPHA == 0:
                            edges.append(i)
                    elif sclk_data[i - 1] == 1 and sclk_data[i] == 0:
                        if CPHA == 1:
                            edges.append(i)
                else:
                    if sclk_data[i - 1] == 1 and sclk_data[i] == 0:
                        if CPHA == 0:
                            edges.append(i)
                    elif sclk_data[i - 1] == 0 and sclk_data[i] == 1:
                        if CPHA == 1:
                            edges.append(i)
            return edges
        edges = find_clock_edges(sclk_data, CPOL, CPHA)
        data_mosi = []
        data_miso = []
        current_byte_mosi = 0
        current_byte_miso = 0
        bit_counter = 0
        for edge in edges:
            bit_mosi = mosi_data[edge]
            bit_miso = miso_data[edge]
            current_byte_mosi = (current_byte_mosi << 1) | bit_mosi
            current_byte_miso = (current_byte_miso << 1) | bit_miso
            bit_counter += 1
            if bit_counter == 8:
                data_mosi.append(current_byte_mosi)
                data_miso.append(current_byte_miso)
                self.log_protocol.append(f"SPI MOSI 数据: {current_byte_mosi} (二进制: {format(current_byte_mosi, '08b')}, 十六进制: {format(current_byte_mosi, '02x')})")
                self.log_protocol.append(f"SPI MISO 数据: {current_byte_miso} (二进制: {format(current_byte_miso, '08b')}, 十六进制: {format(current_byte_miso, '02x')})")
                current_byte_mosi = 0
                current_byte_miso = 0
                bit_counter = 0
        return data_mosi, data_miso

    # ----------- UART 协议解析 -----------
    def parse_uart(self, uart_data, baud_rate):
        time_per_sample = 1 / self.sample_rate_value
        bit_time = 1 / baud_rate
        bit_samples = int(bit_time / time_per_sample)
        def extract_bits(data, bit_samples):
            bit_values = []
            index = 0
            while index < len(data):
                if data[index] == 0:  # Start bit
                    byte = 0
                    for i in range(8):
                        index += bit_samples  # 每个比特周期之后取一个值
                        byte = (byte >> 1) | (data[index] << 7)
                    bit_values.append(byte)
                    self.log_protocol.append(f"UART 数据: {byte} (二进制: {format(byte, '08b')}, 十六进制: {format(byte, '02x')}, ASCII: {chr(byte)})")
                index += bit_samples  # 跳过停止位
            return bit_values
        bits = extract_bits(uart_data, bit_samples)
        return bits
    # ----------- CAN 协议解析 -----------
    def parse_can(self, can_data):
        # 假设 can_data 是一个包含 CAN 帧数据的列表
        start_of_frame = can_data[0]
        identifier = 0
        for i in range(1, 12):  # 标准帧 11 位标识符
            identifier = (identifier << 1) | can_data[i]
        rtr = can_data[12]  # 远程传输请求位
        ide = can_data[13]  # 标识符扩展位，0 表示标准帧，1 表示扩展帧
        dlc = 0
        for i in range(14, 18):  # 数据长度代码（DLC），4 位
            dlc = (dlc << 1) | can_data[i]
        data_bytes = []
        for i in range(18, 18 + 8 * dlc, 8):  # 逐字节提取数据字段
            byte = 0
            for bit_index in range(8):
                byte = (byte << 1) | can_data[i + bit_index]
            data_bytes.append(byte)
        crc = 0
        for i in range(18 + 8 * dlc, 18 + 8 * dlc + 15):  # CRC 校验位，15 位
            crc = (crc << 1) | can_data[i]
        ack = can_data[33]  # ACK 位
        # 将结果记录在 log_protocol 中
        self.log_protocol.append(f"CAN 协议解析 - 标识符: {identifier} (十六进制: {format(identifier, '03x')})")
        self.log_protocol.append(f"RTR 位: {rtr}, IDE 位: {ide}, DLC: {dlc}")
        self.log_protocol.append(f"数据字段: {[f'{format(byte, '02x')}' for byte in data_bytes]}")
        self.log_protocol.append(f"CRC 校验值: {crc}, ACK 位: {ack}")
        return identifier, data_bytes, crc, ack
    



        # 以数据点为单位测试UART协议解析通过，未添加波特率
        # self.state = "IDLE"
        # self.bit_count = 0
        # self.current_byte = 0
 
        # self.datainrange_num = int(view_range[1] / self.stride)
        # self.data_fu_range_num = int(view_range[0] / self.stride)
        # for i in range(self.channel_num):
        #     j = 0
        #     self.bit_count = 0
        #     self.current_byte = 0

        #     while (j <= self.datainrange_num) and (j >= 0):
        #         bit = self.data[i][j]
        #         if self.state == "IDLE":
        #             if bit == 0:
        #                 self.state = "RECEIVING"
        #                 self.bit_count = 0
        #                 self.current_byte = 0
        #             j = j + 1
        #         elif self.state == "RECEIVING":
        #             if self.bit_count <8:
        #                 self.current_byte |= bit << self.bit_count 
        #                 self.bit_count += 1
        #             else:
        #                 if bit ==1:
        #                         self.log_protocol.append(f"通道{i}:x_range = {(j-10)*self.stride} : {(j)*self.stride}protocol_data = {self.current_byte}")
        #                         self.log_protocol.append(f"二进制显示 :{format(self.current_byte,'08b')}")
        #                         self.log_protocol.append(f"十六进制显示 :{format(self.current_byte,'02x')}")
        #                         self.log_protocol.append(f"ASCII显示 :{format(self.current_byte,'c')}") 
        #                         self.current_byte = 0
        #                         self.bit_count = 0
        #                 self.state = "IDLE"
        #             j += 1



      
    # 开始采样按钮点击事件
    sample_run_value = 0
    def on_start_button_click(self):
        # 串口发送开始采样命令
        if(self.sample_run_value == 0):
            self.sample_run_value = 1
        else:
            self.sample_run_value = 0
        sample_run_id = format(0x34,'02x')
        sample_run_value_hex = format(self.sample_run_value,'08x')
        data = [sample_run_id,sample_run_value_hex[0:2],sample_run_value_hex[2:4],sample_run_value_hex[4:6],sample_run_value_hex[6:8]]
        print(data)
        print(len(data))
        # self.ADC_uart.send_packet(data)

        time.sleep(0.1)
        self.sample_run_value = 0 # 采样开始后将采样状态置为0 这样使得下次点击按钮时可以开始新的采样
        print(f"sample_run_value = {self.sample_run_value}")
        sample_run_value_hex = format(self.sample_run_value,'08x')
        data = [sample_run_id,sample_run_value_hex[0:2],sample_run_value_hex[2:4],sample_run_value_hex[4:6],sample_run_value_hex[6:8]]
        print(data)
        print(len(data))
        # self.ADC_uart.send_packet(data)


        self.log_protocol.append("开始采样...")  # 在QTextEdit中显示日志
        self.start_data_acquisition_thread()
        # self.ethernet_receive()
        # self.analyze_protocol()
        # self.update_waveform()
    
    def start_data_acquisition_thread(self):
        self.data_thread = DataAcquisitionThread(self.sample_rate_value, self.sample_depth_value, self.channel_num)
        self.data_thread.data_ready.connect(self.update_waveform)
        self.data_thread.start()
        self.current_index = 0
        self.log_protocol.append("数据采集线程已启动")

    def update_waveform(self, data, time):
        self.log_protocol.append("更新波形数据...")
        self.time = np.array(time)
        self.data = data
        self.current_index = 0
        # 一次画图的步进值为100
        self.step_size = len(self.time) //100 # len(self.time) // 1000
        self.plot_next_segment()
        self.timer = QTimer()
        self.timer.timeout.connect(self.plot_next_segment)
        self.timer.start(20000)
    def plot_next_segment(self):
        print("lenoftime:", len(self.time))
        if self.current_index > 100 :#(len(self.time) // 1000)
            self.timer.stop()
            self.log_protocol.append("波形更新完成")
            return
        start_index = self.current_index * self.step_size
        end_index = (self.current_index + 1) * self.step_size if self.current_index < 100 else len(self.time)  # len(self.time) // 1000
        print("start_index:", start_index)
        print("end_index:", end_index)
        # 更新每个通道的数据
        for i in range(self.channel_num):
            # 提取当前时间段和数据段
            partial_time = self.time[start_index:end_index]
            partial_data = self.data[i][start_index:end_index]
            # 生成方波形式的数据
            step_time = np.repeat(partial_time, 2)[:-1]
            step_data = np.repeat(partial_data, 2)[1:]
            # 将部分数据添加到已经绘制的数据上
            if self.current_index == 0:
                # 第一次直接绘制
                self.curves[i].setData(step_time, step_data)
            else:
                # 追加数据
                current_data = self.curves[i].getData()
                new_time = np.concatenate([current_data[0], step_time])
                new_data = np.concatenate([current_data[1], step_data])
                self.curves[i].setData(new_time, new_data)
        self.current_index += 1  # 更新索引，准备绘制下一部分数据

    # def ethernet_receive(self):
    #     # 接收以太网数据包直到等于采样深度
    #     self.log_protocol.append("采样完成")  # 在QTextEdit中显示日志

    # def analyze_protocol(self):
    #     # 解析数据包
    #     self.log_protocol.append("协议解析完成")  # 在QTextEdit中显示日志

    # def update_waveform(self):
    #     # 更新波形
    #     for i in range(self.channel_num):
    #         self.data[i] = []
    #         print(self.sample_rate_value)
    #         self.stride = 1e6/self.sample_rate_value
    #         print(self.sample_depth_value)
    #         print(self.stride)
    #         self.range_num = self.sample_depth_value *(self.stride)
    #         self.time = np.arange(0, self.range_num,self.stride) #时间轴范围以及步进值

    #         self.data[i] = np.random.randint(0, 2, len(self.time))

    #         step_time = np.repeat(self.time, 2)[:-1]
    #         step_data = np.repeat(self.data[i], 2)[1:]
    #         self.curves[i].setData(step_time, step_data)
    #         # self.curves[i].setData(self.time, self.data[i])
    #     self.log_protocol.append("波形更新完成")


    def on_sample_depth_changed(self, index):
        self.selected_sample_depth = self.combo_sample_depth.currentText()
        self.log_protocol.append(f"采样深度改变为{self.combo_sample_depth.currentText()}")
        sample_depth_id = format(0x30,'02x')
        if(self.selected_sample_depth == "20Ksa"):
            sample_depth_value = format(int(2e4),'08x')
            self.sample_depth_value = 2e4
        elif(self.selected_sample_depth == "200Ksa"):
            sample_depth_value = format(int(2e5),'08x')
            self.sample_depth_value = 2e5
        elif(self.selected_sample_depth == "1Msa"):
            sample_depth_value = format(int(1e6),'08x')
            self.sample_depth_value = 1e6
        elif(self.selected_sample_depth == "2Msa"):
            sample_depth_value = format(int(2e6),'08x')
            self.sample_depth_value = 2e6
        elif(self.selected_sample_depth == "5Msa"):
            sample_depth_value = format(int(5e6),'08x')
            self.sample_depth_value = 5e6
        elif(self.selected_sample_depth == "10Msa"):
            sample_depth_value = format(int(1e7),'08x')
            self.sample_depth_value = 1e7
        elif(self.selected_sample_depth == "20Msa"):
            sample_depth_value = format(int(2e7),'08x')
            self.sample_depth_value = 2e7
        elif(self.selected_sample_depth == "50Msa"):
            sample_depth_value = format(int(5e7),'08x')
            self.sample_depth_value = 5e7
        elif(self.selected_sample_depth == "100Msa"):
            sample_depth_value = format(int(1e8),'08x')
            self.sample_depth_value = 1e8
        elif(self.selected_sample_depth == "200Msa"):
            sample_depth_value = format(int(2e8),'08x')
            self.sample_depth_value = 2e8
        elif(self.selected_sample_depth == "500Msa"):
            sample_depth_value = format(int(5e8),'08x')
            self.sample_depth_value = 5e8
        elif(self.selected_sample_depth == "1Gsa"):
            sample_depth_value = format(int(1e9),'08x')
            self.sample_depth_value = 1e9
        data = [sample_depth_id,sample_depth_value[0:2],sample_depth_value[2:4],sample_depth_value[4:6],sample_depth_value[6:8]]
        print(data)
        print(len(data))
        # self.ADC_uart.send_packet(data)

    def on_sample_rate_changed(self, index):
        self.selected_sample_rate = self.combo_sample_rate.currentText()
        self.log_protocol.append(f"采样速率改变为{self.combo_sample_rate.currentText()}")
        sample_rate_id = format(0x31,'02x')
        if(self.selected_sample_rate == "20Khz"):
            sample_rate_value = format(0x00,'08x')
            self.sample_rate_value = 2e4
        elif(self.selected_sample_rate == "50Khz"):
            sample_rate_value = format(0x01,'08x')
            self.sample_rate_value = 5e4
        elif(self.selected_sample_rate == "100Khz"):
            sample_rate_value = format(0x02,'08x')
            self.sample_rate_value = 1e5
        elif(self.selected_sample_rate == "200Khz"):
            sample_rate_value = format(0x03,'08x')
            self.sample_rate_value = 2e5
        elif(self.selected_sample_rate == "500Khz"):
            sample_rate_value = format(0x04,'08x')
            self.sample_rate_value = 5e5
        elif(self.selected_sample_rate == "1Mhz"):
            sample_rate_value = format(0x05,'08x')
            self.sample_rate_value = 1e6
        elif(self.selected_sample_rate == "2Mhz"):
            sample_rate_value = format(0x06,'08x')
            self.sample_rate_value = 2e6
        elif(self.selected_sample_rate == "5Mhz"):
            sample_rate_value = format(0x07,'08x')
            self.sample_rate_value = 5e6
        elif(self.selected_sample_rate == "10Mhz"):
            sample_rate_value = format(0x08,'08x')
            self.sample_rate_value = 1e7
        elif(self.selected_sample_rate == "20Mhz"):
            sample_rate_value = format(0x09,'08x')
            self.sample_rate_value = 2e7
        elif(self.selected_sample_rate == "50Mhz"):
            sample_rate_value = format(0x0a,'08x')
            self.sample_rate_value = 5e7
        elif(self.selected_sample_rate == "100Mhz"):
            sample_rate_value = format(0x0b,'08x')
            self.sample_rate_value = 1e8
        elif(self.selected_sample_rate == "200Mhz"):
            sample_rate_value = format(0x0c,'08x')
            self.sample_rate_value = 2e8
        elif(self.selected_sample_rate == "500Mhz"):
            sample_rate_value = format(0x0d,'08x')
            self.sample_rate_value = 5e8
        data = [sample_rate_id,sample_rate_value[0:2],sample_rate_value[2:4],sample_rate_value[4:6],sample_rate_value[6:8]]
        print(data)
        print(len(data))
        # self.ADC_uart.send_packet(data)

    def on_trigger_changed(self, index):
        self.selected_trigger = self.combo_trigger.currentText()
        self.log_protocol.append(f"触发条件改变为{self.combo_trigger.currentText()}")
        trigger_id = format(0x32,'02x')
        if(self.selected_trigger == "高电平触发"):
            trigger_value = format(0x00,'08x')
        elif(self.selected_trigger == "低电平触发"):
            trigger_value = format(0x01,'08x')
        elif(self.selected_trigger == "上升沿触发"):
            trigger_value = format(0x02,'08x')
        elif(self.selected_trigger == "下降沿触发"):
            trigger_value = format(0x03,'08x')
        data = [trigger_id,trigger_value[0:2],trigger_value[2:4],trigger_value[4:6],trigger_value[6:8]]
        print(data)
        print(len(data))
        # self.ADC_uart.send_packet(data)

    def on_trigger_channel_changed(self, index):
        self.selected_trigger_channel = self.combo_trigger_channel.currentText()
        self.log_protocol.append(f"触发通道改变为{self.combo_trigger_channel.currentText()}")
        trigger_channel_id = format(0x33,'02x')
        if(self.selected_trigger_channel == "通道1"):
            trigger_channel_value = format(0x00,'08x')
        elif(self.selected_trigger_channel == "通道2"):
            trigger_channel_value = format(0x01,'08x')
        elif(self.selected_trigger_channel == "通道3"):
            trigger_channel_value = format(0x02,'08x')
        elif(self.selected_trigger_channel == "通道4"):
            trigger_channel_value = format(0x03,'08x')
        elif(self.selected_trigger_channel == "通道5"):
            trigger_channel_value = format(0x04,'08x')
        elif(self.selected_trigger_channel == "通道6"):
            trigger_channel_value = format(0x05,'08x')
        data = [trigger_channel_id,trigger_channel_value[0:2],trigger_channel_value[2:4],trigger_channel_value[4:6],trigger_channel_value[6:8]]
        print(data)
        print(len(data))
        # self.ADC_uart.send_packet(data)

    def on_channel_num_changed(self, index):
        self.selected_channel_num = self.combo_channel_num.currentText()
        self.log_protocol.append(f"通道数量改变为{self.combo_channel_num.currentText()}")
        if(self.selected_channel_num == "1"):
            self.channel_num = 1
        elif(self.selected_channel_num == "2"):
            self.channel_num = 2
        elif(self.selected_channel_num == "3"):
            self.channel_num = 3
        elif(self.selected_channel_num == "4"):
            self.channel_num = 4
        elif(self.selected_channel_num == "5"):
            self.channel_num = 5
        elif(self.selected_channel_num == "6"):
            self.channel_num = 6

        for i in range(6 - self.channel_num):
            self.data[self.channel_num + i] = []
            step_time = np.repeat(self.time, 2)[:-1]
            step_data = np.repeat(self.data[self.channel_num + i], 2)[1:]
            self.curves[self.channel_num + i].setData(step_time, step_data)

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = LogicAnalyzerApp()  # 创建合并后的类的实例
    window.show()
    sys.exit(app.exec_())
    
