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
L Analog:LF398_SOIC8 U1
U 1 1 6217633E
P 4350 2200
F 0 "U1" H 4694 2246 50  0000 L CNN
F 1 "LF398_SOIC8" H 4694 2155 50  0000 L CNN
F 2 "Package_SO:SOIC-8_3.9x4.9mm_P1.27mm" H 4350 2200 50  0001 C CNN
F 3 "https://www.analog.com/media/en/technical-documentation/data-sheets/lt0398s8.pdf" H 4350 2200 50  0001 C CNN
	1    4350 2200
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x04_Male J1
U 1 1 62176C3C
P 3250 2150
F 0 "J1" H 3358 2431 50  0000 C CNN
F 1 "Conn_01x04_Male" H 3358 2340 50  0000 C CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x04_P1.27mm_Vertical" H 3250 2150 50  0001 C CNN
F 3 "~" H 3250 2150 50  0001 C CNN
	1    3250 2150
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x04_Male J2
U 1 1 621776AF
P 5500 2200
F 0 "J2" H 5472 2082 50  0000 R CNN
F 1 "Conn_01x04_Male" H 5472 2173 50  0000 R CNN
F 2 "Connector_PinHeader_2.00mm:PinHeader_1x04_P2.00mm_Vertical" H 5500 2200 50  0001 C CNN
F 3 "~" H 5500 2200 50  0001 C CNN
	1    5500 2200
	-1   0    0    1   
$EndComp
Wire Wire Line
	4250 1900 4250 1800
Wire Wire Line
	4250 1800 3650 1800
Wire Wire Line
	3650 1800 3650 2050
Wire Wire Line
	3650 2050 3450 2050
Wire Wire Line
	3450 2150 3850 2150
Wire Wire Line
	3850 2150 3850 1650
Wire Wire Line
	3850 1650 4450 1650
Wire Wire Line
	4450 1650 4450 1900
Wire Wire Line
	3450 2250 3900 2250
Wire Wire Line
	3900 2250 3900 2100
Wire Wire Line
	3900 2100 4050 2100
Wire Wire Line
	3450 2350 4000 2350
Wire Wire Line
	4000 2350 4000 2650
Wire Wire Line
	4000 2650 4250 2650
Wire Wire Line
	4250 2650 4250 2500
Wire Wire Line
	4650 2200 5050 2200
Wire Wire Line
	5050 2200 5050 2300
Wire Wire Line
	5050 2300 5300 2300
Wire Wire Line
	4450 2500 5200 2500
Wire Wire Line
	5200 2500 5200 2200
Wire Wire Line
	5200 2200 5300 2200
Wire Wire Line
	5300 2100 4900 2100
Wire Wire Line
	4900 2100 4900 1350
Wire Wire Line
	4900 1350 4000 1350
Wire Wire Line
	4000 1350 4000 2300
Wire Wire Line
	4000 2300 4050 2300
Wire Wire Line
	5300 2000 5300 1300
Wire Wire Line
	5300 1300 3950 1300
Wire Wire Line
	3950 1300 3950 2200
Wire Wire Line
	3950 2200 4050 2200
$Comp
L Mechanical:MountingHole H1
U 1 1 621DC444
P 6900 1300
F 0 "H1" H 7000 1346 50  0000 L CNN
F 1 "MountingHole" H 7000 1255 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.5mm" H 6900 1300 50  0001 C CNN
F 3 "~" H 6900 1300 50  0001 C CNN
	1    6900 1300
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole H2
U 1 1 621DC814
P 6900 1650
F 0 "H2" H 7000 1696 50  0000 L CNN
F 1 "MountingHole" H 7000 1605 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.5mm" H 6900 1650 50  0001 C CNN
F 3 "~" H 6900 1650 50  0001 C CNN
	1    6900 1650
	1    0    0    -1  
$EndComp
Wire Wire Line
	4250 2650 5200 2650
Wire Wire Line
	5200 2650 5200 2500
Connection ~ 4250 2650
Connection ~ 5200 2500
$Comp
L Mechanical:MountingHole H3
U 1 1 6225ED9F
P 6900 2100
F 0 "H3" H 7000 2146 50  0000 L CNN
F 1 "MountingHole" H 7000 2055 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.1mm" H 6900 2100 50  0001 C CNN
F 3 "~" H 6900 2100 50  0001 C CNN
	1    6900 2100
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole H4
U 1 1 6225EF9E
P 6900 2350
F 0 "H4" H 7000 2396 50  0000 L CNN
F 1 "MountingHole" H 7000 2305 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.1mm" H 6900 2350 50  0001 C CNN
F 3 "~" H 6900 2350 50  0001 C CNN
	1    6900 2350
	1    0    0    -1  
$EndComp
$EndSCHEMATC
