{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # --- Network Analysis ---
    nmap
    wireshark
    tcpdump
    netcat-gnu

    # --- Enumeration & OSINT ---
    whois
    dnsutils
    ffuf
    gobuster

    # --- Web Attacks ---
    burpsuite
    nikto
    sqlmap

    # --- Endpoint Attacks ---
    metasploit
    exploitdb

    # --- Password & Crypto ---
    john
    hashcat
    hydra

    # --- Reverse Engineering & Malware Analysis ---
    radare2
    ghidra
    binwalk

    # --- Wi-Fi Security ---
    aircrack-ng

    # --- General Utilities ---
    curl
    wget
    socat
    openssl
    file
    p7zip
    xxd
  ];

  # Allow Wireshark packet capture without root
  programs.wireshark.enable = true;

  # Add user to wireshark group for non-root captures
  users.users."fractal".extraGroups = [ "wireshark" ];
}
