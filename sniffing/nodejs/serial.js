"use strict";

const SerialPort = require('serialport')

findFtdiPort( SerialPort, foundPortEvent )
//tests()

function findFtdiPort( SerialPort, callback ){
	// list serial ports:
	console.log('Listing serial ports:')
	SerialPort.list().then( 
		ports => {
			var foundPorts = []
			
			ports.forEach(function(port) {
				//console.log('Port:', port);
				
				if((port.vendorId=='0403') && (port.productId=='6001')){
					foundPorts.push( port )
				}
			});
			
			callback( null, foundPorts )
		},
		err => callback(err)
	);
}

function foundPortEvent( err, foundPorts ){

  //console.log('foundPortEvent')
	//console.log(err)
	//console.log('Ports:', foundPorts)

  if( foundPorts.length == 0 ) {
		console.error( 'No FTDI Ports Found' )
		process.exit()
	}
	
	const port = setupPort( foundPorts[0].path )
	
	findComputrainer( port, computrainerFoundEvent )
	
	return port
}

function setupPort( portPath ) {

  console.log('setupPort()')

	const port = new SerialPort(/*'COM5'*/  portPath, { baudRate: 2400 })

	// The open event is always emitted
	port.on('open', function() {
		console.log('Port Opened')
	})

	// Open errors will be emitted as an error event
	port.on('error', function(err) {
		console.log('Error: ', err.message)
	})

	// Open errors will be emitted as an error event
	port.on('close', function(err) {
		console.log('Port Closed')
		if( err ){
			console.log('Error: ' + err.message)
		}
	})
	
	return port
}

function findComputrainer( port, callback ) {
	const Ready = require('@serialport/parser-ready')
  
	const parser = port.pipe(new Ready({ delimiter: Response }))

	parser.on('data', parseRxData)

	port.write(Challenge, function(err) {
		if (err) {
			return console.log('Error on write: ', err.message)
		}
		console.log('Sent ' + Challenge)
	})

	parser.on('ready', () => {
		console.log('Received ' + Response)
		//parser.unpipe()

    callback( port );	
	})
}	

var rxbuf = Array()

function parseRxData( data ){
	//console.log('parseRxData:   ', data)
	
	rxbuf.push( ...data );
	
	//console.log('rxbuf:        ', rxbuf)
	
	while( rxbuf.length >= 7 ){
		if( rxbuf[6] & 0x80 ){
			
			var packet = rxbuf.slice( 0, 7 )
			
			rxbuf = rxbuf.slice( 7 )
			
			//console.log('rxbuf now:    ',rxbuf)

			parseRxPacket( packet )
			
		} else {
			
			rxbuf = rxbuf.slice( 1 )
			
		}
	}
}

function parseRxPacket( packet ){
	//console.log( 'parseRxPacket:', packet )
	
	decode( packet )
}

  var bufidx = 0
		
	var buffers = []
	buffers.push( Buffer.from([ 0x6D, 0x00, 0x00, 0x0A, 0x08, 0x00, 0xE0 ]) )
	buffers.push( Buffer.from([ 0x65, 0x00, 0x00, 0x0A, 0x10, 0x00, 0xE0 ]) )
	buffers.push( Buffer.from([ 0x00, 0x00, 0x00, 0x0A, 0x18, 0x5D, 0xC1 ]) )
	buffers.push( Buffer.from([ 0x33, 0x00, 0x00, 0x0A, 0x24, 0x1E, 0x0E ]) )
	buffers.push( Buffer.from([ 0x6A, 0x00, 0x00, 0x0A, 0x2C, 0x5F, 0xE0 ]) )
	buffers.push( Buffer.from([ 0x41, 0x00, 0x00, 0x0A, 0x34, 0x00, 0xE0 ]) )
	buffers.push( Buffer.from([ 0x2D, 0x00, 0x00, 0x0A, 0x38, 0x10, 0xC2 ]) )
	buffers.push( Buffer.from([ 0x03, 0x00, 0x00, 0x0A, 0x40, 0x32, 0xE0 ]) )
	
	

function computrainerFoundEvent( port ){
		
		console.log('!!! COMPUTRAINER FOUND !!!')
		
		setInterval( ()=> {
			console.log( 'buffer[' + bufidx + ']: ' + buffers[bufidx] )
			port.write( buffers[bufidx] )
			bufidx = ( bufidx +1 ) % 8
		}, 100 )
		
		/*
		var buffer 
		
		buffer = Buffer.from([ 0x6D, 0x00, 0x00, 0x0A, 0x08, 0x00, 0xE0 ])
		port.write( buffer )
		
		buffer = Buffer.from([ 0x65, 0x00, 0x00, 0x0A, 0x10, 0x00, 0xE0 ])
		port.write( buffer )
		
		buffer = Buffer.from([ 0x00, 0x00, 0x00, 0x0A, 0x18, 0x5D, 0xC1 ])
		port.write( buffer )
		
		buffer = Buffer.from([ 0x33, 0x00, 0x00, 0x0A, 0x24, 0x1E, 0x0E ])
		port.write( buffer )
		
		buffer = Buffer.from([ 0x6A, 0x00, 0x00, 0x0A, 0x2C, 0x5F, 0xE0 ])
		port.write( buffer )
		
		buffer = Buffer.from([ 0x41, 0x00, 0x00, 0x0A, 0x34, 0x00, 0xE0 ])
		port.write( buffer )
		
		buffer = Buffer.from([ 0x2D, 0x00, 0x00, 0x0A, 0x38, 0x10, 0xC2 ])
		port.write( buffer )
		
		buffer = Buffer.from([ 0x03, 0x00, 0x00, 0x0A, 0x40, 0x32, 0xE0 ])
		port.write( buffer )


		buffer = Buffer.from([ 0x6D, 0x00, 0x00, 0x0A, 0x08, 0x00, 0xE0 ])
		port.write( buffer )
		
		buffer = Buffer.from([ 0x65, 0x00, 0x00, 0x0A, 0x10, 0x00, 0xE0 ])
		port.write( buffer )
		
		buffer = Buffer.from([ 0x00, 0x00, 0x00, 0x0A, 0x18, 0x5D, 0xC1 ])
		port.write( buffer )
		//port.close()
		*/
}

function tests(){
	console.log('Tests')
	
	var buffers = []
	buffers.push( Buffer.from([ 0x6D, 0x00, 0x00, 0x0A, 0x08, 0x00, 0xE0 ]) )
	
	buffers.push( Buffer.from([ 0x65, 0x00, 0x00, 0x0A, 0x10, 0x00, 0xE0 ]) )
	buffers.push( Buffer.from([ 0x00, 0x00, 0x00, 0x0A, 0x18, 0x5D, 0xC1 ]) )
	buffers.push( Buffer.from([ 0x33, 0x00, 0x00, 0x0A, 0x24, 0x1E, 0x0E ]) )
	buffers.push( Buffer.from([ 0x6A, 0x00, 0x00, 0x0A, 0x2C, 0x5F, 0xE0 ]) )
	buffers.push( Buffer.from([ 0x41, 0x00, 0x00, 0x0A, 0x34, 0x00, 0xE0 ]) )
	buffers.push( Buffer.from([ 0x2D, 0x00, 0x00, 0x0A, 0x38, 0x10, 0xC2 ]) )
	buffers.push( Buffer.from([ 0x03, 0x00, 0x00, 0x0A, 0x40, 0x32, 0xE0 ]) )

	buffers.push( Buffer.from([ 0x00, 0x00, 0x00, 0x40, 0x49, 0x00, 0x80 ]) )
	buffers.push( Buffer.from([ 0x00, 0x00, 0x00, 0x40, 0x50, 0x00, 0x80 ]) )
	buffers.push( Buffer.from([ 0x00, 0x00, 0x00, 0x40, 0x5f, 0x00, 0xc1 ]) )
	buffers.push( Buffer.from([ 0x00, 0x00, 0x00, 0x40, 0x67, 0x7f, 0x83 ]) )
	
	
	buffers.forEach( function( buffer ) {	
		decode( buffer )
	})
}

function hex( b ){
	return ('0' + (b &  0xFF).toString(16)).slice(-2)
}

function hex3( w ){
	return ('00' + (w & 0xFFF).toString(16)).slice(-3)
}

function dec4( n ){
	return ('   ' + (n & 0xFFF).toString(10)).slice(-4)
}

function button( state, name ){
	if( state )
		return '###' + name.toUpperCase() + '###'
	else
		return '   ' + name.toLowerCase() + '   '
}

function decode( buffer ){
  //console.log( buffer )
	
	var crc = ((buffer[0] & 0x7F) << 1)
	        | ((buffer[6] & 0x20) >> 5)
	
	var mode = buffer[3] & 0xF8
	
	var sync = (buffer[6] & 0x80) >> 7;
	
	var z = (buffer[6] & 0x40) >> 6;
	
	var load = ((buffer[4] & 0x07) << 9)
  	       | ((buffer[5] & 0x7F) << 1)
  	       | ((buffer[6] & 0x02) << 8)
  	       | ((buffer[6] & 0x01)     )

  //console.log('CRC:', hex( crc ), 'Mode:', hex( mode ), 'Sync:', //sync, 'Z:', z, 'Load:', load )
	
	var a, b, c, f, m, t, z
	
	a = ((buffer[0] & 0x7F) << 1)
    | ((buffer[6] & 0x20) >> 5)

	b = ((buffer[1] & 0x7F) << 1)
    | ((buffer[6] & 0x10) >> 4)

	c = ((buffer[2] & 0x7F) << 1)
    | ((buffer[6] & 0x08) >> 3)
		
	f = ((buffer[3] & 0x7F) << 1)
    | ((buffer[6] & 0x04) >> 2)
		
	m = ((buffer[4] & 0x78) >> 3)
	
	t = ((buffer[4] & 0x07) << 9)
    | ((buffer[6] & 0x02) << 8)
    | ((buffer[5] & 0x7F) << 1)
    | ((buffer[6] & 0x01)     )
		
	z = ((buffer[6] & 0x40) >> 6)
		
  console.log('a', hex( a ), '  b', hex( b ), '  c', hex(c), '  f', hex(f), '  m', hex(m), '  t', hex3(t), dec4(t), '  z', z )

  console.log('Buttons:', 
	    button( f & 0x80, 'reset')
		+ button( f & 0x40, 'spinscan')
		+ button( f & 0x20, 'minus')
		+ button( f & 0x10, 'F2')
		+ button( f & 0x08, 'plus')
		+ button( f & 0x04, 'F3')
		+ button( f & 0x02, 'F1')
	)
	
	switch( m ){
		case 1:
		  console.log('Speed', t)
			break
		case 2:
		  console.log('Power', t)
			break
		case 3:
		  console.log('Heart Rate', t & 0xFF)
			break
		case 4:
		  console.log('4 - Unknown', t)
			break
		case 5:
		  console.log('5 - Unknown', t)
			break
		case 6:
		  console.log('Cadence', t & 0xFF)
			break
		case 7:
		  console.log('6 - Unknown', t)
			break
		case 8:
		  console.log('Constant', t)
			break
		case 9:
		  console.log('Push on pressure: ', (t & 0x7FF)/256 )
		  break
		case 10:
		  console.log('10 - Unknown', t)
			break
		case 11:
		  console.log('Sensor Status', t)
			console.log('  Cadence Sensor Present:    ', (t & 0x800)>>11)
			console.log('  Heart Rate Sensor Present: ', (t & 0x400)>>10)
			break
		case 12:
		  console.log('Message Sync', t)
			break
	}
}

const Challenge = 'RacerMate'
const Response  = 'LinkUp'

// message type
const CT_SPEED       = 0x01
const CT_POWER       = 0x02
const CT_HEARTRATE   = 0x03
const CT_CADENCE     = 0x06
const CT_RRC         = 0x09
const CT_SENSOR      = 0x0b

// buttons
const CT_RESET       = 0x01
const CT_F1          = 0x02
const CT_F3          = 0x04
const CT_PLUS        = 0x08
const CT_F2          = 0x10
const CT_MINUS       = 0x20
const CT_SSS         = 0x40    // spinscan sync is not a button!
const CT_NONE        = 0x80

/* Device operation mode */
const CT_ERGOMODE    = 0x01
const CT_SSMODE      = 0x02
const CT_CALIBRATE   = 0x04

/* default operation mode */
const DEFAULT_MODE     =   CT_ERGOMODE
const DEFAULT_LOAD     =   100.00
const DEFAULT_GRADIENT =   2.00

// thanks to Sean Rhea for working this one out!
function calcCRC(value)
{
    return (0xff & (107 - (value & 0xff) - (value >> 8)));
}

