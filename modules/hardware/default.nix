{
  imports = [
    ./hardware-pro.nix
    ./hardware-perso.nix
    ./hardware-perso-workstation.nix
  ];

  powerManagement.cpuFreqGovernor = "performance";

  # Aggressive CPU performance tuning for always-plugged-in workstation
  boot.kernelParams = [
    # Disable CPU idle states to prevent frequency drops
    "intel_idle.max_cstate=0"
    "processor.max_cstate=1"
    # Force Intel P-state to use performance mode
    "intel_pstate=active"
  ];

  # Set minimum CPU frequency to 80% of max to ensure responsiveness
  systemd.services.cpu-performance-tuning = {
    description = "Set aggressive CPU performance parameters";
    wantedBy = [ "multi-user.target" ];
    script = ''
      # Set energy performance preference to maximum performance
      for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        echo "performance" > "$cpu" 2>/dev/null || true
      done
      
      # Set minimum frequency to 3.0 GHz (80% of 4.0 GHz typical boost)
      for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq; do
        echo "3000000" > "$cpu" 2>/dev/null || true
      done
      
      # Ensure turbo boost is enabled
      echo "0" > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
