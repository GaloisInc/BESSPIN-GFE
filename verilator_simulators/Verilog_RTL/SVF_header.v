import "DPI-C"
function bluenoc_recv_tcp_beat( output bit[135:0] result_value
			       , input int unsigned  socket_descriptor
			       , byte         beat_size
			       , byte         bytes_already_received
			       , bit[127:0]   beat_value_so_far
			       );

import "DPI-C"
function byte bluenoc_send_tcp_beat( int unsigned  socket_descriptor
				    , byte          beat_size
				    , byte          bytes_to_send
				    , bit[127:0]    beat_value
				    );

import "DPI-C"
function int unsigned bluenoc_open_tcp_socket( int unsigned tcp_port );
