# CCNA Glossary

| Istilah |  | Deskripsi |
|----------|----------|-----------|
| **OSI Model** |
| OSI | Open Systems Interconnection | Model referensi jaringan 7 layer. |
| PDU | Protocol Data Unit | Nama data pada tiap layer OSI. |
| Data | Layer 5-7 | PDU pada Application, Presentation, Session. |
| Segment | Layer 4 | PDU pada Transport Layer. |
| Packet | Layer 3 | PDU pada Network Layer. |
| Frame | Layer 2 | PDU pada Data Link Layer. |
| Bits | Layer 1 | Data pada Physical Layer. |
| Ethernet & Layer 2 |
| Ethernet | Teknologi LAN | Standar Layer 2 yang paling banyak digunakan. |
| MAC Address | Layer 2 Address | Alamat fisik NIC sepanjang 48 bit. |
| OUI | Organizationally Unique Identifier | 24 bit pertama MAC Address yang menunjukkan vendor. |
| BIA | Burned-In Address | MAC Address bawaan pabrik. |
| FCS | Frame Check Sequence | CRC untuk mendeteksi error pada frame. |
| Preamble | Sinkronisasi | Digunakan agar sender dan receiver sinkron. |
| EtherType | Protocol Identifier | Menentukan payload Layer 3 (IPv4, IPv6, ARP, dll). |
| **IP Addressing** |
| IPv4 | Network Layer | Alamat logis 32 bit. |
| IPv6 | Network Layer | Alamat logis 128 bit. |
| Network Address | Subnet | Alamat pertama subnet. |
| Broadcast Address | Subnet | Alamat terakhir subnet. |
| Host Address | Subnet | IP yang dapat diberikan ke perangkat. |
| Subnet Mask | Addressing | Menentukan Network dan Host bit. |
| CIDR | Addressing | Penggunaan prefix (/24, /30, dst). |
| VLSM | Addressing | Variable Length Subnet Mask. |
| Route Summarization | Routing | Menggabungkan beberapa network menjadi satu prefix. |
| **Private Address & NAT** |
| RFC1918 | Private IP | Standar alamat private. |
| NAT | Network Address Translation | Menerjemahkan Private IP menjadi Public IP. |
| PAT | NAT | Banyak host berbagi satu Public IP. |
| Static NAT | NAT | 1 Private IP ↔ 1 Public IP. |
| Dynamic NAT | NAT | Menggunakan pool Public IP. |
| **Routing** |
| Router | Layer 3 Device | Menghubungkan network berbeda. |
| Routing Table | Routing | Daftar jalur menuju network tujuan. |
| Static Route | Routing | Route yang dibuat manual. |
| Dynamic Routing | Routing | Route dipelajari otomatis. |
| Next Hop | Routing | Router tujuan berikutnya. |
| Metric | Routing | Nilai biaya suatu jalur. |
| Administrative Distance | Routing | Tingkat kepercayaan routing protocol. |
| **Routing Protocol** |
| RIP | Distance Vector | Routing protocol sederhana. |
| OSPF | Link State | Routing protocol berbasis SPF. |
| EIGRP | Cisco | Advanced Distance Vector. |
| BGP | Exterior Gateway | Routing antar Autonomous System. |
| **VLAN & Switching** |
| VLAN | Virtual LAN | Memisahkan broadcast domain secara logis. |
| Access Port | VLAN | Port untuk satu VLAN. |
| Trunk Port | VLAN | Port yang membawa banyak VLAN. |
| Native VLAN | VLAN | VLAN tanpa tag pada trunk. |
| 802.1Q | VLAN | Standar VLAN Tagging. |
| **STP** |
| STP | Spanning Tree Protocol | Mencegah Layer 2 Loop. |
| Root Bridge | STP | Switch utama STP. |
| Root Port | STP | Jalur terbaik menuju Root Bridge. |
| Designated Port | STP | Port forwarding pada segmen. |
| BPDU | STP | Pesan yang dipakai STP. |
| **DHCP & DNS** |
| DHCP | Dynamic Host Configuration Protocol | Memberikan IP otomatis. |
| Lease Time | DHCP | Lama peminjaman IP. |
| DNS | Domain Name System | Menerjemahkan nama domain menjadi IP. |
| FQDN | DNS | Fully Qualified Domain Name. |
| **Performance & Troubleshooting** |
| Ping | ICMP | Menguji konektivitas. |
| Traceroute | Troubleshooting | Menampilkan jalur paket. |
| RTT | Performance | Round Trip Time. |
| Latency | Performance | Waktu tempuh paket. |
| Jitter | Performance | Variasi latency. |
| Packet Loss | Performance | Paket yang hilang. |
| Throughput | Performance | Kecepatan transfer aktual. |
| Bottleneck | Performance | Titik pembatas performa. |
| **Switching Fundamentals** |
| Hub | Layer 1 Device | Perangkat Layer 1 yang mengirim ulang sinyal ke semua port tanpa memahami MAC Address. |
| Switch | Layer 2 Device | Perangkat Layer 2 yang meneruskan frame berdasarkan MAC Address. |
| Full-Duplex | Ethernet | Mode komunikasi yang memungkinkan perangkat mengirim dan menerima data secara bersamaan. |
| Half-Duplex | Ethernet | Mode komunikasi di mana perangkat hanya dapat mengirim atau menerima pada satu waktu. |
| Collision Domain | Ethernet | Area jaringan tempat collision dapat terjadi. |
| CSMA/CD | Carrier Sense Multiple Access with Collision Detection | Mekanisme Ethernet half-duplex untuk mendeteksi dan menangani collision. |
| CAM Table | Content Addressable Memory Table | Nama lain dari MAC Address Table pada switch. |
| Unknown Unicast | Switching | Frame dengan MAC tujuan yang belum ada di MAC Address Table sehingga akan diflood. |
| Known Unicast | Switching | Frame dengan MAC tujuan yang sudah diketahui sehingga hanya diteruskan ke port tujuan. |
| Flooding | Switching | Mengirim frame ke semua port kecuali port asal. |
| Inter-switch Link | Switching | Koneksi Ethernet antar switch untuk memperluas jaringan LAN. |
| **Layer 3 Switching & Routing** |
| Layer 3 Switch | Layer 3 Device | Switch yang mampu melakukan routing antar subnet atau VLAN. |
| Broadcast Domain | Networking | Sekelompok perangkat yang menerima frame broadcast yang sama. |
| WAN | Wide Area Network | Jaringan yang menghubungkan lokasi yang berjauhan secara geografis. |
| LAN | Local Area Network | Jaringan lokal dalam area terbatas seperti kantor atau kampus. |
| **Cisco Products** |
| ASA | Adaptive Security Appliance | Firewall enterprise buatan Cisco. |
| FirePower | Intrusion Prevention System | Sistem IPS Cisco untuk mendeteksi dan mencegah serangan jaringan. |
| IPS | Intrusion Prevention System | Sistem keamanan yang mendeteksi sekaligus memblokir serangan jaringan. |
| WLC | Wireless LAN Controller | Perangkat yang mengelola banyak Wireless Access Point secara terpusat. |
| AP | Access Point | Perangkat yang menyediakan akses jaringan Wi-Fi kepada klien nirkabel. |
| CUCM | Cisco Unified Communications Manager | IP PBX Cisco untuk mengelola sistem VoIP perusahaan. |
| PBX | Private Branch Exchange | Sistem telepon internal organisasi. |
| VoIP | Voice over Internet Protocol | Teknologi komunikasi suara melalui jaringan IP. |
| TelePresence | Cisco Collaboration | Solusi video conference berkualitas tinggi dari Cisco. |
| Webex | Cisco Collaboration | Platform meeting dan kolaborasi online dari Cisco. |
| UCS | Unified Computing System | Platform server enterprise Cisco untuk data center. |
| Blade Server | Server Hardware | Server modular yang dipasang dalam chassis bersama. |
| Rack Server | Server Hardware | Server berbentuk rack yang dipasang pada rack data center. |
| Nexus Switch | Data Center Switch | Seri switch Cisco untuk data center yang menjalankan NX-OS. |
| NX-OS | Cisco Operating System | Sistem operasi yang digunakan pada Cisco Nexus Switch. |
| Cisco IOS | Cisco Operating System | Sistem operasi yang digunakan pada router dan Catalyst Switch Cisco. |