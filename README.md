# Implementation of Gossip Algorithm using Erlang

Gossip type algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Erlang. Since actors are fully asynchronous, the particular type of Gossip implemented is the so-called Asynchronous Gossip.

##Gossip Algorithm for information propagation The Gossip algorithm involves the following:

Starting: A participant(actor) told/sent a rumor (fact) by the main process
Step: Each actor selects a random neighbor and tells it the rumor.
Termination: Each actor keeps track of rumors and how many times he has heard the rumor. It stops transmitting once it has heard the rumor 10 times (10 is arbitrary, you can select other values).

##Push-Sum algorithm for sum computation

State: Each actor Ai maintains two quantities: s and w. Initially, s = xi = i (that is actor number i has value i, play with other distribution if you so desire) and w = 1
Starting: Ask one of the actors to start from the main process.
Receive: Messages sent and received are pairs of the form (s, w). Upon receiving, an actor should add the received pair to its own corresponding values. Upon receiving, each actor selects a random neighbor and sends it a message.
Send: When sending a message to another actor, half of s and w is kept by the sending actor, and half is placed in the message.
Sum Estimate: At any given moment of time, the sum estimate is s/w where s and w are the current values of an actor.
Termination: If an actor's ratio s/w did not change more than 10−10 in 3 consecutive rounds the actor terminates. WARNING: the values s and w independently never converge, only the ratio does.

##Topologies: The actual network topology plays a critical role in the dissemination speed of Gossip protocols.

As part of this project, you have to experiment with various topologies. The topology determines who is considered a neighbor in the above algorithms.

Full Network: Every actor is a neighbor of all other actors. That is, every actor can talk directly to any other actor.
2D Grid: Actors form a 2D grid. The actors can only talk to the grid neighbors
Line: Actors are arranged in a line. Each actor has only 2 neighbors (one left and one right, unless you are the first or last actor).
Imperfect 3D Grid: Grid arrangement but one random other neighbor is selected from the list of all actors (8+1 neighbors).


## What is working

Gossip and Push-sum protocols consistently achieve 100% convergence for full and imperfect 2D topologies. In the case of line and 2D topologies, 80% convergence is attained.
For both the protocols, line topology is slowest to converge while full topology converges the quickest.
In short, Gossip and Push-sum algorithms have been implemented for all four topologies.

## Sample Output

### Gossip Algorithm
Eshell V13.0.4  (abort with ^G)
1> c(project2).
{ok,project2}
2> project2:main(4,grid,gossip).
Node: (1,2) heard rumour 1 times.
ok
3> Node: (2,1) heard rumour 1 times.
3> Node: (1,1) heard rumour 1 times.
3> Node: (1,2) heard rumour 2 times.
3> Node: (1,1) heard rumour 2 times.
3> Node: (1,2) heard rumour 3 times.
3> Node: (2,2) heard rumour 1 times.
3> Node: (2,2) heard rumour 2 times.
3> Node: (1,2) heard rumour 4 times.
3> Node: (2,2) heard rumour 3 times.
3> Node: (2,2) heard rumour 4 times.
3> Node: (1,1) heard rumour 3 times.
3> Node: (1,2) heard rumour 5 times.
3> Node: (2,2) heard rumour 5 times.
3> Node: (2,1) heard rumour 2 times.
3> Node: (1,2) heard rumour 6 times.
3> Node: (2,2) heard rumour 6 times.
3> Node: (1,2) heard rumour 7 times.
3> Node: (1,2) heard rumour 8 times.
3> Node: (1,2) heard rumour 9 times.
3> Node: (1,1) heard rumour 4 times.
3> Node: (2,2) heard rumour 7 times.
3> Node: (1,2) heard rumour 10 times. *Node Teminated*
3> Node: (2,2) heard rumour 8 times.
3> Node: (1,1) heard rumour 5 times.
3> Node: (2,2) heard rumour 9 times.
3> Node: (1,1) heard rumour 6 times.
3> Node: (2,1) heard rumour 3 times.
3> Node: (1,1) heard rumour 7 times.
3> Node: (1,1) heard rumour 8 times.
3> Node: (2,2) heard rumour 10 times. *Node Teminated*
3> Node: (2,1) heard rumour 4 times.
3> Node: (2,1) heard rumour 5 times.
3> Node: (1,1) heard rumour 9 times.
3> Node: (1,1) heard rumour 10 times. *Node Teminated*
3> Node: (2,1) heard rumour 6 times.
3> Node : (2,1) heard the rumour 6 times. *Terminating since no neighbours are active*
3> Main Node Terminated
3> The nodes converged in 562 ms

### Push Sum Algorithm

4> project2:main(4,grid,pushsum).
Node: (2,2) heard rumour 1 times.
ok
5> Node: (1,1) heard rumour 1 times.
5> Node: (1,2) heard rumour 1 times.
5> Node: (1,2) heard rumour 2 times.
5> Node: (1,1) heard rumour 2 times.
5> Node: (1,2) heard rumour 3 times.
5> Node: (2,1) heard rumour 1 times.
5> Node: (2,1) heard rumour 2 times.
5> Node: (2,2) heard rumour 2 times.
5> Node: (1,1) heard rumour 3 times.
5> Node: (1,2) heard rumour 4 times.
5> Node: (1,1) heard rumour 4 times.
5> Node: (1,2) heard rumour 5 times.
5> Node: (1,1) heard rumour 5 times.
5> Node: (1,1) heard rumour 6 times.
5> Node: (1,1) heard rumour 7 times.
5> Node: (2,2) heard rumour 3 times.
5> Node: (1,1) heard rumour 8 times.
5> Node: (1,1) heard rumour 9 times.
5> Node: (1,2) heard rumour 6 times.
5> Node: (2,1) heard rumour 3 times.
5> Node: (1,2) heard rumour 7 times.
5> Node: (2,1) heard rumour 4 times.
5> Node: (1,1) heard rumour 10 times.
5> Node: (2,1) heard rumour 5 times.
5> Node: (1,1) heard rumour 11 times.
5> Node: (2,1) heard rumour 6 times.
5> Node: (1,1) heard rumour 12 times.
5> Node: (2,1) heard rumour 7 times.
5> Node: (1,2) heard rumour 8 times.
5> Node: (2,1) heard rumour 8 times.
5> Node: (1,2) heard rumour 9 times.
5> Node: (2,1) heard rumour 9 times.
5> Node: (2,2) heard rumour 4 times.
5> Node: (1,1) heard rumour 13 times.
5> Node: (2,2) heard rumour 5 times.
5> Node: (2,1) heard rumour 10 times.
5> Node: (2,2) heard rumour 6 times.
5> Node: (2,2) heard rumour 7 times.
5> Node : (2,2) heard the rumour 7 times. *Node Terminated*
5> Node: (1,1) heard rumour 14 times.
5> Node: (2,1) heard rumour 11 times.
5> Node: (1,1) heard rumour 15 times.
5> Node: (1,1) heard rumour 16 times.
5> Node: (1,2) heard rumour 10 times.
5> Node : (1,1) heard the rumour 16 times. *Node Terminated*
5> Node: (1,2) heard rumour 11 times.
5> Node: (1,2) heard rumour 12 times.
5> Node: (2,1) heard rumour 12 times.
5> Node : (1,2) heard the rumour 12 times. *Node Terminated*
5> Node : (2,1) heard the rumour 12 times. *Node Terminated*
5> Main Node Terminated
5> The nodes converged in 7073 ms


# Getting Started/Prerequisites

Follow these instructions to get the implementation up and running.

## Erlang

Please use Erlang >= 20.0, available at <https://www.erlang.org/downloads>.

## Initiate the program

saijayanthchidirala@darth ~ % cd Desktop
saijayanthchidirala@darth Desktop % erl -name master@192.168.0.138 -setcookie dospsj
Erlang/OTP 25 [erts-13.0.4] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit] [dtrace]

Eshell V13.0.4 (abort with ^G)
(master@some-IP)1> c(miner).
{ok,miner}
(master@some-IP)2> miner:start().

The master node asks for a user input through the command line 'Enter the number of leading zeroes :'. This is the only user input needed in the entire system including for the worker nodes. This input needs to be an integer. On successful entry, the master hashes random strings using SHA256 and prints the hashes with the number of leading zeroes as entered by the user. The master also spawns the handshake server, counter server and the collector server before registering them.

## Built With

- [Erlang](https://www.erlang.org) - Erlang is a dynamic, functional language designed for building scalable and efficient distributed applications.
- [Visual Studio Code](https://code.visualstudio.com/) - Code Editor
- [Github](https://github.com/jayant_0010/DistributedBitcoinMiner) - Dependency Management
