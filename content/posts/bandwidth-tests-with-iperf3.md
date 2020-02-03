---
title: "Bandwidth tests with iperf3"
date: 2020-02-03T20:29:24+01:00
draft: false
---

If you ever come to the need of a simple bandwidth test for your server or client, you can setup a bandwidth test via iperf3.

For starting an iperf3, just use `iperf3 -s`:
```
❯ iperf3 -s
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
Accepted connection from 139.174.228.245, port 33133
[  5] local 78.46.124.83 port 5201 connected to 139.174.228.245 port 21516
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  12.1 MBytes   101 Mbits/sec  354    567 KBytes
[  5]   1.00-2.00   sec  10.0 MBytes  83.9 Mbits/sec  209    993 KBytes
[  5]   2.00-3.00   sec  8.75 MBytes  73.4 Mbits/sec   58    913 KBytes
[  5]   3.00-4.00   sec  7.50 MBytes  62.9 Mbits/sec  156   1.18 MBytes
[  5]   4.00-5.00   sec  11.2 MBytes  94.4 Mbits/sec  144    781 KBytes
[  5]   5.00-6.00   sec  7.50 MBytes  62.8 Mbits/sec   72    987 KBytes
[  5]   6.00-7.00   sec  7.50 MBytes  63.0 Mbits/sec   50    583 KBytes
[  5]   7.00-8.00   sec  3.75 MBytes  31.5 Mbits/sec    0    662 KBytes
[  5]   8.00-9.00   sec  3.75 MBytes  31.5 Mbits/sec    5    351 KBytes
[  5]   9.00-10.00  sec  6.25 MBytes  52.4 Mbits/sec   49    885 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.08  sec  78.3 MBytes  65.2 Mbits/sec  1097             sender
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
^Ciperf3: interrupt - the server has terminated
```

Now you can test your client against your server via `iperf3 -R -c <hostname>`,
where `-R` means reverse mode (the server sends data to your client). If you
want to test the opposite way, just use `iperf3 -c <hostname>` or `iperf3
--bidir -c <hostname>` for a bidirectional connection:
```
❯ iperf3 -R -c kurisu
Connecting to host kurisu, port 5201
Reverse mode, remote host kurisu is sending
[  5] local 192.168.0.103 port 55182 connected to 78.46.124.83 port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec  8.59 MBytes  72.0 Mbits/sec
[  5]   1.00-2.00   sec  11.0 MBytes  92.1 Mbits/sec
[  5]   2.00-3.00   sec  8.23 MBytes  69.0 Mbits/sec
[  5]   3.00-4.00   sec  8.23 MBytes  69.1 Mbits/sec
[  5]   4.00-5.00   sec  10.1 MBytes  84.5 Mbits/sec
[  5]   5.00-6.00   sec  7.65 MBytes  64.2 Mbits/sec
[  5]   6.00-7.00   sec  7.01 MBytes  58.8 Mbits/sec
[  5]   7.00-8.00   sec  4.60 MBytes  38.6 Mbits/sec
[  5]   8.00-9.00   sec  4.18 MBytes  35.1 Mbits/sec
[  5]   9.00-10.00  sec  5.96 MBytes  50.0 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.08  sec  78.3 MBytes  65.2 Mbits/sec  1097             sender
[  5]   0.00-10.00  sec  75.5 MBytes  63.3 Mbits/sec                  receiver

iperf Done.
```
