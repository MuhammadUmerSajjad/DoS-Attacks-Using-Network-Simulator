# Create a simulator object
set ns [new Simulator]

# Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

# open the trace file
set tracefile1 [open out.tr w]
$ns trace-all $tracefile1

# Open the NAM trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile

# Define a 'finish' procedure
proc finish {} {
	global ns tracefile1 namfile
	$ns flush-trace
	close $tracefile1
	close $namfile
	exec nam out.nam &
	exit 0
}

# Create 6 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

# Create links between nodes
$ns duplex-link $n0 $n2 0.2Mb 100ms DropTail
$ns duplex-link $n1 $n2 0.5Mb 100ms DropTail
$ns duplex-link $n2 $n3 0.2Mb 100ms DropTail
$ns duplex-link $n3 $n4 0.2Mb 100ms DropTail
$ns duplex-link $n3 $n5 0.2Mb 100ms DropTail
$ns duplex-link $n5 $n4 0.2Mb 100ms DropTail

# Set Queue Sizes
$ns queue-limit $n2 $n3 5
$ns queue-limit $n3 $n4 5
$ns queue-limit $n3 $n5 5
$ns queue-limit $n5 $n4 5

# Setting node positions
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down
$ns duplex-link-op $n5 $n4 orient up

# Defining a Random Uniform Generator
proc Random_Generator_Uniform {} {
	set MyRng4 [new RNG]
	$MyRng4 seed 0
	set r4 [new RandomVariable/Uniform]
	$r4 use-rng $MyRng4
	$r4 set min_ 0
	$r4 set max_ 4
	puts stdout "Testing Uniform Random Variable inside function"
	global x
	set x [$r4 value]
	return x
}

proc Random_Generator_Exponential {} {
	set MyRng5 [new RNG]
	$MyRng5 seed 0
	set r5 [new RandomVariable/Exponential]
	$r5 use-rng $MyRng5
	$r5 set avg_ 100
	puts stdout "Testing Exponantial Random Variable inside function"
	global y
	set y [$r5 value]
	return y
}

# Setup a TCP connection
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packetsize_ 552

#Setup a FTP over TCP connection
set pareto [new Application/Traffic/Pareto]
$pareto attach-agent $tcp
$pareto set PacketSize_ 1000
$pareto set burst_time 0.98
$pareto set idle_time 0.01
#$pareto set rate_ 1000
$pareto set shape_ 2

# Setup a UDP connection
set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n4 $sink1
$ns connect $tcp1 $sink1
$tcp1 set fid_ 2

set poisson [new Application/Traffic/Exponential]
$poisson attach-agent $tcp1
#$poisson set interval_ 0.005
#$poisson set PacketSize_ 100
$poisson set burst_time 0.0
#$poisson set idle_time 0.01
$poisson set rate_ 100000000
#$poisson set maxpkts_ 100

#$ns rtproto DV

# If a link stops working
#$ns rtmodel-at 0.4 down $n4 $n5
#$ns rtmodel-at 3.0 up $n4 $n5
#$ns rtmodel-at 3.0 down $n3 $n4
#$ns rtmodel-at 7.0 up $n3 $n4

#Schedule events for the CBR and FTP agents
$ns at 0.0 "$poisson start"
$ns at 0.0 "$pareto start"
$ns at 10.0 "$pareto stop"
$ns at 10.0 "$poisson stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 15.0 "finish"



#Run the simulation
$ns run



