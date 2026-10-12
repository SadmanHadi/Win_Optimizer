# 🌐 Network Latency & Esports Netcode Analysis

> **TCP Stack Tuning, Bufferbloat Elimination & Wi-Fi Ping Stabilization**  
> **Author:** [PumpkiN (Sadman Hadi)](https://github.com/SadmanHadi)  
> **Project:** [Win_Optimizer](https://github.com/SadmanHadi/Win_Optimizer)

---

## 📡 The Modern Gaming Network Problem

Multiplayer gaming netcode does not behave like web browsing or video streaming:
* **Web/Video:** Prefers large, buffered chunks for high throughput (bandwidth).
* **Esports Gaming:** Demands continuous, tiny, microsecond-accurate data packets (latency & jitter).

When Windows runs on its default network settings, it treats game packets with the same buffering and coalescing logic used for downloading files, creating artificial delays, bufferbloat, and hit registration discrepancies.

---

## 🛠️ The 5 Pillars of PumpkiN's Network Suite

### 1. Nagle's Algorithm (`TCPNoDelay = 1`)
* **How it works:** When a game sends a packet smaller than the Maximum Transmission Unit (MTU ~1500 bytes), Windows holds the packet in a buffer waiting to see if more data arrives.
* **The impact:** Small 40-byte game tick packets wait up to 40ms before being pushed to the wire.
* **The fix:** Disabling Nagle (`TCPNoDelay = 1`) forces immediate transmission without buffering.

### 2. Delayed Acknowledgments (`TcpAckFrequency = 1` & `TcpDelAckTicks = 0`)
* **How it works:** Windows delays sending TCP ACK responses to the server, waiting to bundle them with outgoing data or until a 200ms timer expires.
* **The impact:** Game servers waiting on client confirmations experience artificial round-trip time (RTT) spikes.
* **The fix:** Setting `TcpAckFrequency = 1` forces Windows to acknowledge every incoming packet immediately. Setting `TcpDelAckTicks = 0` terminates the timer.

### 3. Wi-Fi 60-Second AutoConfig Background Ping Spikes
* **How it works:** Windows WLAN AutoConfig (`WlanSvc`) periodically scans for surrounding Wi-Fi access points every 60 seconds.
* **The impact:** The Wi-Fi radio momentarily detaches from the active gaming channel to sweep all 2.4GHz and 5GHz channels, causing severe 100ms–300ms ping spikes and rubberbanding.
* **The fix:**
  ```cmd
  netsh wlan set autoconfig enabled=no interface="<AdapterName>"
  ```
  Freezing background scanning while gaming delivers a flat, jitter-free ping line comparable to wired Ethernet.

### 4. QoS 20% Reserved Bandwidth Uncap
* **How it works:** The Windows Packet Scheduler (`Psched`) reserves 20% of your network card's bandwidth for system QoS operations.
* **The impact:** Caps total game and download throughput.
* **The fix:** Setting `NonBestEffortLimit = 0` in `HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched` frees 100% of bandwidth for application traffic.

### 5. DNS ServiceProvider Resolution Hierarchy
* **How it works:** Windows queries multiple name resolution providers in an inefficient default sequence.
* **The fix:** In `HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider`:
  - `LocalPriority = 4` (Immediate local cache check)
  - `HostsPriority = 5` (Hosts file check)
  - `DnsPriority = 6` (Fast remote DNS resolution)
  - `NetbtPriority = 7` (Legacy NetBIOS pushed to lowest priority)
  Accelerates server connection establishment and lobby matchmaking handshakes.

---

## 📊 Live Network Benchmark (Current System)

```text
Target Gateway        : Cloudflare DNS (1.1.1.1) / Google DNS (8.8.8.8)
Adapter Type          : Realtek Gaming GbE Controller
Average Round-Trip    : 32.5 ms
Minimum Round-Trip    : 32.0 ms
Maximum Round-Trip    : 33.0 ms
Calculated Jitter     : 1.0 ms
Packet Loss           : 0.0%
Bufferbloat Status    : A+ Grade (Zero TCP queue congestion)
```
