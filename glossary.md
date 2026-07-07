# CCNA Glossary

| Istilah | | Deskripsi |
| :--- | :--- | :--- |
| **OSI Model** | | |
| OSI | Open Systems Interconnection | Model referensi jaringan 7 layer. |
| PDU | Protocol Data Unit | Nama data pada tiap layer OSI. |
| Data | Layer 5-7 | PDU pada Application, Presentation, Session. |
| Segment | Layer 4 | PDU pada Transport Layer. |
| Packet | Layer 3 | PDU pada Network Layer. |
| Frame | Layer 2 | PDU pada Data Link Layer. |
| Bits | Layer 1 | Data pada Physical Layer. |
| **Ethernet & Layer 2** | | |
| Ethernet | Teknologi LAN | Standar Layer 2 yang paling banyak digunakan. |
| MAC Address | Layer 2 Address | Alamat fisik NIC sepanjang 48 bit. |
| OUI | Organizationally Unique Identifier | 24 bit pertama MAC Address yang menunjukkan vendor. |
| BIA | Burned-In Address | MAC Address bawaan pabrik. |
| FCS | Frame Check Sequence | CRC untuk mendeteksi error pada frame. |
| Preamble | Sinkronisasi | Digunakan agar sender dan receiver sinkron. |
| EtherType | Protocol Identifier | Menentukan payload Layer 3 (IPv4, IPv6, ARP, dll). |
| ARP | Address Resolution Protocol | Protokol untuk memetakan alamat IP Layer 3 ke alamat MAC Layer 2 pada jaringan lokal. |
| ARP Cache / Table | Address Resolution Protocol Table | Tabel penyimpanan sementara pada RAM host/router yang menyimpan hasil pemetaan IP-ke-MAC. |
| Layer 2 Broadcast | Broadcast Frame | Frame data dengan MAC tujuan `FFFF.FFFF.FFFF` yang dikirimkan ke seluruh host di subnet lokal. |
| Layer 2 Unicast | Unicast Frame | Frame data yang dikirimkan secara spesifik ke satu alamat MAC tujuan tertentu. |
| CDP | Cisco Discovery Protocol | Protokol proprietary Cisco Layer 2 untuk mengumpulkan informasi perangkat Cisco tetangga yang terhubung langsung. |
| LLDP | Link Layer Discovery Protocol | Protokol standar terbuka (IEEE 802.1AB) Layer 2 untuk mendeteksi perangkat tetangga lintas vendor (termasuk server Linux). |
| **IP Addressing** | | |
| IPv4 | Network Layer | Alamat logis 32 bit. |
| IPv6 | Network Layer | Alamat logis 128 bit. |
| Network Address | Subnet | Alamat pertama subnet. |
| Broadcast Address | Subnet | Alamat terakhir subnet. |
| Host Address | Subnet | IP yang dapat diberikan ke perangkat. |
| Subnet Mask | Addressing | Menentukan Network dan Host bit. |
| CIDR | Addressing | Penggunaan prefix (/24, /30, dst). |
| VLSM | Addressing | Variable Length Subnet Mask. |
| Route Summarization | Routing | Menggabungkan beberapa network menjadi satu prefix. |
| Default Gateway | Gateway | Alamat IP interface router yang menjadi pintu keluar host untuk berkomunikasi dengan subnet lain. |
| **Private Address & NAT** | | |
| RFC1918 | Private IP | Standar alamat private. |
| NAT | Network Address Translation | Menerjemahkan Private IP menjadi Public IP. |
| PAT | NAT | Banyak host berbagi satu Public IP. |
| Static NAT | NAT | 1 Private IP ↔ 1 Public IP. |
| Dynamic NAT | NAT | Menggunakan pool Public IP. |
| **Routing** | | |
| Router | Layer 3 Device | Menghubungkan network berbeda. |
| Routing Table | Routing | Daftar jalur menuju network tujuan. |
| Static Route | Routing | Route yang dibuat manual. |
| Dynamic Routing | Routing | Route dipelajari otomatis. |
| Next Hop | Routing | Router tujuan berikutnya. |
| Metric | Routing | Nilai biaya suatu jalur. |
| Administrative Distance | Routing | Tingkat kepercayaan routing protocol. |
| MAC Rewriting | Hop-by-Hop Processing | Proses di mana router membongkar header L2 lama dan menulis ulang MAC address asal/tujuan baru di setiap hop routing. |
| Packet Buffering | Memory Queue | Proses menahan sementara paket data di memori antrean perangkat saat menunggu resolusi alamat (seperti ARP). |
| **Routing Protocol** | | |
| RIP | Distance Vector | Routing protocol sederhana. |
| OSPF | Link State | Routing protocol berbasis SPF. |
| EIGRP | Cisco | Advanced Distance Vector. |
| BGP | Exterior Gateway | Routing antar Autonomous System. |
| **VLAN & Switching** | | |
| VLAN | Virtual LAN | Memisahkan broadcast domain secara logis. |
| Access Port | VLAN | Port untuk satu VLAN. |
| Trunk Port | VLAN | Port yang membawa banyak VLAN. |
| Native VLAN | VLAN | VLAN tanpa tag pada trunk. |
| 802.1Q | VLAN | Standar VLAN Tagging. |
| SVI | Switched Virtual Interface | Interface virtual Layer 3 pada switch yang digunakan untuk manajemen jarak jauh (VLAN 1) atau inter-VLAN routing. |
| **STP** | | |
| STP | Spanning Tree Protocol | Mencegah Layer 2 Loop. |
| Root Bridge | STP | Switch utama STP. |
| Root Port | STP | Jalur terbaik menuju Root Bridge. |
| Designated Port | STP | Port forwarding pada segmen. |
| BPDU | STP | Pesan yang dipakai STP. |
| **DHCP & DNS** | | |
| DHCP | Dynamic Host Configuration Protocol | Memberikan IP otomatis. |
| Lease Time | DHCP | Lama peminjaman IP. |
| DNS | Domain Name System | Menerjemahkan nama domain menjadi IP. |
| FQDN | DNS | Fully Qualified Domain Name. |
| Authoritative DNS | DNS Server Role | Server DNS yang memegang database rekaman asli, valid, dan definitif untuk suatu zona domain tertentu. |
| DNS Forwarding | DNS Forwarder | Mekanisme meneruskan query DNS dari domain eksternal yang tidak diketahui ke server DNS publik di internet. |
| **Performance & Troubleshooting** | | |
| Ping | ICMP | Menguji konektivitas. |
| Traceroute | Troubleshooting | Menampilkan jalur paket. |
| RTT | Performance | Round Trip Time. |
| Latency | Performance | Waktu tempuh paket. |
| Jitter | Performance | Variasi latency. |
| Packet Loss | Performance | Paket yang hilang. |
| Throughput | Performance | Kecepatan transfer aktual. |
| Bottleneck | Performance | Titik pembatas performa. |
| ICMP | Internet Control Message Protocol | Protokol Layer 3 untuk mengirim pesan kendali dan error jaringan (digunakan oleh Ping & Traceroute). |
| Telnet | Diagnostic Tool / Protocol | Protokol remote access teks polos (L7) yang juga digunakan untuk menguji status keaktifan port TCP tertentu di tujuan. |
| Top-Down Approach | Troubleshooting | Metode analisis masalah jaringan dari Layer 7 (Application) turun ke Layer 1 (Physical). |
| Bottom-Up Approach | Troubleshooting | Metode analisis masalah jaringan dari Layer 1 (Physical) naik ke Layer 7 (Application). |
| Divide and Conquer | Troubleshooting | Metode analisis masalah dengan memulai pengujian di layer tengah (Layer 3), lalu bergerak naik atau turun sesuai hasil observasi. |
| Line Status | Interface State | Indikator kondisi fisik/Layer 1 dari interface perangkat (Up berarti mendeteksi sinyal/tegangan kabel). |
| Protocol Status | Interface State | Indikator kondisi logis/Layer 2 dari interface perangkat (Up berarti framing dan keepalive sinkron). |
| EMI | Electro-Magnetic Interference | Gangguan pada media transmisi tembaga akibat radiasi elektromagnetik luar seperti mesin besar atau microwave. |
| **Switching Fundamentals** | | |
| Hub | Layer 1 Device | Perangkat Layer 1 yang mengirim ulang sinyal ke semua port tanpa memahami MAC Address. |
| Switch | Layer 2 Device | Perangkat Layer 2 yang meneruskan frame berdasarkan MAC Address. |
| Full-Duplex | Ethernet | Mode komunikasi yang memungkinkan perangkat mengirim dan menerima data secara bersamaan. |
| Half-Duplex | Ethernet | Mode komunikasi di mana perangkat hanya dapat mengirim atau menerima pada satu waktu. |
| Collision Domain | Ethernet | Area jaringan tempat collision dapat terjadi. |
| CSMA/CD | Collision Detection | Mekanisme Ethernet half-duplex untuk mendeteksi dan menangani collision. |
| CAM Table | MAC Address Table | Nama lain dari MAC Address Table pada switch berbasis memori Content Addressable Memory. |
| Unknown Unicast | Switching | Frame dengan MAC tujuan yang belum ada di MAC Address Table sehingga akan diflood. |
| Known Unicast | Switching | Frame dengan MAC tujuan yang sudah diketahui sehingga hanya diteruskan ke port tujuan. |
| Flooding | Switching | Mengirim frame ke semua port kecuali port asal. |
| Inter-switch Link | Switching | Koneksi Ethernet antar switch untuk memperluas jaringan LAN. |
| Auto-Negotiation | Ethernet | Proses otomatis antar interface untuk menyepakati kecepatan (speed) dan duplex terbaik secara mandiri. |
| Duplex Mismatch | Ethernet Error | Kondisi kesalahan akibat perbedaan mode duplex di kedua ujung kabel, memicu kolisi konstan dan performa lambat. |
| **Layer 3 Switching & Routing** | | |
| Layer 3 Switch | Layer 3 Device | Switch yang mampu melakukan routing antar subnet atau VLAN. |
| Broadcast Domain | Networking | Sekelompok perangkat yang menerima frame broadcast yang sama. |
| WAN | Wide Area Network | Jaringan yang menghubungkan lokasi yang berjauhan secara geografis. |
| LAN | Local Area Network | Jaringan lokal dalam area terbatas seperti kantor atau kampus. |
| **Cisco Products & System Configuration** | | |
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
| TFTP | Trivial File Transfer Protocol | Protokol transfer file sederhana (UDP port 69) tanpa otentikasi untuk backup/restore IOS dan konfigurasi. |
| **Cisco Device Memory & Management** | | |
| ROM | Read Only Memory | Memori permanen untuk menyimpan kode dasar bootstrap dan instruksi Power-On Self Test (POST). |
| Flash Memory | Storage | Tempat penyimpanan persisten non-volatile untuk menyimpan file citra operating system Cisco IOS (`.bin`). |
| NVRAM | Non-Volatile RAM | Memori persisten kecil khusus untuk menyimpan file konfigurasi cadangan saat perangkat mati (`startup-config`). |
| RAM | Random Access Memory | Memori volatile tempat berjalannya sistem operasi IOS, tabel dinamis, dan konfigurasi aktif (`running-config`). |
| ROMMON | ROM Monitor Mode | Mode CLI darurat tingkat rendah yang aktif saat perangkat gagal mendeteksi citra operating system IOS yang valid di Flash. |
| POST | Power-On Self Test | Prosedur cek kesehatan hardware otomatis yang dijalankan oleh ROM begitu perangkat menerima daya listrik. |
| Bootstrap | Boot Loader | Kode mikro di ROM yang mendeteksi perangkat keras dan menuntun sistem untuk memuat Cisco IOS ke RAM. |
| startup-config | Configuration File | Berkas konfigurasi permanen tersimpan di NVRAM yang akan dimuat sistem setiap kali perangkat melakukan cold boot. |
| running-config | Configuration File | Berkas konfigurasi aktif yang berjalan di RAM; semua modifikasi perintah berdampak langsung di sini secara real-time. |
| Configuration Register | Hardware Control | Nilai register 16-bit di NVRAM yang mengontrol jalannya proses bootloader (seperti bypass config `0x2142`). |
| Break Sequence | CLI Interrupt | Kombinasi tombol interupsi (Ctrl+Break) saat booting untuk memaksa sistem masuk ke baris perintah ROMMON. |
| Configuration Merge | IOS Behavior | Karakteristik Cisco IOS yang mencampur (bukan menimpa) parameter berkas baru saat disalin langsung ke running-config. |
| Setup Wizard | Configuration Dialog | Menu interaktif pemandu konfigurasi awal berbasis teks yang muncul otomatis jika NVRAM kosong saat boot. |
| Enable Secret | Cisco Security | Metode enkripsi hash kuat (MD5/SHA) untuk memproteksi gerbang masuk menuju Privileged EXEC mode. |
| Enable Password | Cisco Security | Metode legacy otentikasi Privileged EXEC mode yang menyimpan kata sandi dalam teks polos tanpa enkripsi. |
| VTY | Virtual Teletype | Jalur interface logis internal IOS untuk mengendalikan sesi manajemen jarak jauh masuk (SSH atau Telnet). |