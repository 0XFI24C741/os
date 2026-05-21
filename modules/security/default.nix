{ pkgs, ... }:
let
  # nixpkgs d233902 has a stale fixed-output hash for this source archive.
  # Keep the package available until the pinned nixpkgs revision is bumped past
  # the upstream fix.
  johnFixed = pkgs.john.overrideAttrs (_old: {
    src = pkgs.fetchFromGitHub {
      owner = "openwall";
      repo = "john";
      rev = "f514ece8ec4ae5e38ad75aaa322eac86d73dcd76";
      hash = "sha256-zO1/KUJe3LvYCGlwVpNg5uDwPRD0ql/7anErb7tywC0=";
    };
  });
in
{
  environment.systemPackages = with pkgs; [
    # --- Network Analysis ---
    nmap
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
    johnFixed
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
}
