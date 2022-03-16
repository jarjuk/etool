EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Switch:SW_DIP_x04 SW1
U 1 1 6231C0B3
P 4700 2000
F 0 "SW1" H 4700 2467 50  0000 C CNN
F 1 "SW_DIP_x04" H 4700 2376 50  0000 C CNN
F 2 "Package_DIP:DIP-8_W7.62mm" H 4700 2000 50  0001 C CNN
F 3 "~" H 4700 2000 50  0001 C CNN
	1    4700 2000
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x04_Male J1
U 1 1 6231C8FF
P 3550 1900
F 0 "J1" H 3658 2181 50  0000 C CNN
F 1 "Conn_01x04_Male" H 3658 2090 50  0000 C CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x04_P1.27mm_Vertical" H 3550 1900 50  0001 C CNN
F 3 "~" H 3550 1900 50  0001 C CNN
	1    3550 1900
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x04_Male J2
U 1 1 6231D0B3
P 5650 2000
F 0 "J2" H 5622 1882 50  0000 R CNN
F 1 "Conn_01x04_Male" H 5622 1973 50  0000 R CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x04_P1.27mm_Vertical" H 5650 2000 50  0001 C CNN
F 3 "~" H 5650 2000 50  0001 C CNN
	1    5650 2000
	-1   0    0    1   
$EndComp
Wire Wire Line
	3750 1800 4400 1800
Wire Wire Line
	4400 1900 3750 1900
Wire Wire Line
	3750 2000 4400 2000
Wire Wire Line
	3750 2100 4400 2100
Wire Wire Line
	5000 1800 5450 1800
Wire Wire Line
	5000 1900 5450 1900
Wire Wire Line
	5000 2000 5450 2000
Wire Wire Line
	5000 2100 5450 2100
$Comp
L Mechanical:MountingHole H1
U 1 1 62321FAC
P 6100 1150
F 0 "H1" H 6200 1196 50  0000 L CNN
F 1 "MountingHole" H 6200 1105 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.5mm" H 6100 1150 50  0001 C CNN
F 3 "~" H 6100 1150 50  0001 C CNN
	1    6100 1150
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole H2
U 1 1 62322262
P 6100 1450
F 0 "H2" H 6200 1496 50  0000 L CNN
F 1 "MountingHole" H 6200 1405 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.5mm" H 6100 1450 50  0001 C CNN
F 3 "~" H 6100 1450 50  0001 C CNN
	1    6100 1450
	1    0    0    -1  
$EndComp
$EndSCHEMATC
