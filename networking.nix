{
  config,
  pkgs,
  ...
}:
{
  # Networking
  networking.hostName = "ric-nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        set l4d2_cns {
          type ipv4_addr
          flags interval
          elements = {
            185.187.155.10, 45.67.85.139, 202.186.164.240, 103.131.188.71,
            202.186.47.138, 155.138.194.251, 46.174.52.5, 157.20.105.71,
            190.2.141.8, 178.239.171.97, 2.58.201.55, 45.11.230.10,
            175.140.7.65, 202.186.160.125, 43.230.163.166, 94.72.141.139,
            185.121.26.7, 60.50.29.31, 188.127.241.206, 202.186.162.161, 45.134.110.25,
            45.11.231.30, 93.190.139.252, 5.189.124.206, 188.127.244.198, 202.186.102.95,
            18.180.172.93, 175.137.203.55, 2.58.200.5, 108.181.54.69,
            212.8.248.124, 85.214.110.16, 175.141.9.200, 219.95.53.226, 148.251.130.211,
            118.100.98.186, 172.93.102.9, 8.12.16.195, 45.67.86.40, 2.58.201.66, 151.158.198.49,
            202.184.101.60, 43.143.87.158, 104.149.151.170, 202.186.169.46, 110.42.9.24,
            180.188.24.50, 210.16.171.17, 202.189.15.5, 43.249.194.250, 160.202.231.31,
            113.68.24.38, 124.222.49.178, 74.91.124.246, 164.132.201.202, 159.75.77.193,
            58.153.161.130, 46.174.51.126, 202.184.47.51, 202.184.47.139, 120.77.206.2, 103.40.13.58,
            203.27.106.49
          }
        }

        chain input {
          type filter hook input priority 0; policy accept;
          ip saddr @l4d2_cns drop
        }

        chain output {
          type filter hook output priority 0; policy accept;
          ip daddr @l4d2_cns drop
        }
      }
    '';
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPortRanges = [
      {
        from = 4000;
        to = 4007;
      }
      {
        from = 8000;
        to = 8010;
      }
      {
        from = 27005;
        to = 27030;
      }
    ];
    trustedInterfaces = [ "virbr0" ];
    extraPackages = with pkgs; [
      ipset
    ];
  };
}
