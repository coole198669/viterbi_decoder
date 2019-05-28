/*///////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Coole Chen                                         ////
////          chenjun198669@163.com                              ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2019                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
///////////////////////////////////////////////////////////////////*/
# viterbi_decoder
Hardware Viterbi Decoder in verilog

This Viterbi Decoder adopts a unified and mature HW architecture, which is parameter- configurable and supports the convolutional decoding used in LTE, NB-IOT and GSM/GPRS/EDGE.  The sliding window technique with forward trace back algorithm was implemented to reduce the Path Metric buffer. The configurable trellis based on the unified HW architecture can support different constraint lengths from 4 to 7, and the code rate from 1/2 to 1/6.    

The viterbi_core contains 64 BMU, 64 ACS, one PM normalize block, one traceback block and the control FSM in the top. The BMU is branch metric unit for branch metric calculation which is indexed by state. The ACS is Add-Compare-Select unit to generate the surviving path and the path metric of current time Tn. It’s also indexed by state. The surviving path bits of 64 states are combined to 64-bit width data and be stored to 64x64 PM buffer. The pm_normalize block can generate the max PM and its state index. It also do path metric normalizing. This block contains 64 PM registers to hold the PM values for next time ACS processing( as PM of time Tn-1), which are feed back to the corresponding ACS block, according to the trellis structure.  The traceback block reads the surviving path bits from PM buffer and extracts the correct decoding bits.  The traceback process starts from max PM state, or the state 0 at the end of tail-bit mode.
