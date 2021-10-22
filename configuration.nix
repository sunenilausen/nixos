# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ 
      <nixos-hardware/lenovo/thinkpad/t480s>
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "vm.swappiness" = 0; };

  networking.hostName = "sunix"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.extraHosts =
  ''
    127.0.0.1 schultzcampus.test
    127.0.0.1 advokurser.test
    127.0.0.1 revikurser.test
  '';  

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   wget vim
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  console.useXkbConfig = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";
  services = {
    xserver = {
      enable = true;
      layout = "us";
      displayManager.gdm.enable = true;
      displayManager.gdm.wayland = false;
      desktopManager.gnome.enable = true;
    };

    dbus.packages = [ pkgs.gnome3.dconf ];
    udev.packages = [ pkgs.gnome3.gnome-settings-daemon ];
  };
  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  
  fonts.fonts = with pkgs; [
    fira-code
    fira-code-symbols
    hermit
    emojione
  ];

  #CPU Throttling
  services.throttled.enable = true;
  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
	

  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sune = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker"]; # Enable ‘sudo’ for the user.
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

  # Disable power profile because we are using TLD  
  services.power-profiles-daemon.enable = false;
  
  # Custom thermal profile
  services.thermald = {
    enable = true;
    configFile = builtins.toFile "thermal-conf.xml" ''
      <?xml version="1.0"?>
      <ThermalConfiguration>
        <Platform>
          <Name>Keep CPU below 80C</Name>
          <ProductName>*</ProductName>
          <Preference>quiet</Preference>

          <ThermalZones>
            <ThermalZone>
              <Type>x86_pkg_temp</Type>
              <TripPoints>
                <TripPoint>
                  <SensorType>x86_pkg_temp</SensorType>
                  <Type>passive</Type>
                  <Temperature>80000</Temperature>

                  <CoolingDevice>
                    <Index>1</Index>
                    <Type>rapl_controller</Type>
                    <Influence>50</Influence>
                    <SamplingPeriod>10</SamplingPeriod>
                  </CoolingDevice>

                  <CoolingDevice>
                    <Index>2</Index>
                    <Type>intel_pstate</Type>
                    <Influence>40</Influence>
                    <SamplingPeriod>10</SamplingPeriod>
                  </CoolingDevice>

                  <CoolingDevice>
                    <Index>3</Index>
                    <Type>intel_powerclamp</Type>
                    <Influence>30</Influence>
                    <SamplingPeriod>10</SamplingPeriod>
                  </CoolingDevice>

                  <CoolingDevice>
                    <Index>4</Index>
                    <Type>cpufreq</Type>
                    <Influence>20</Influence>
                    <SamplingPeriod>8</SamplingPeriod>
                  </CoolingDevice>

                  <CoolingDevice>
                    <Index>5</Index>
                    <Type>Processor</Type>
                    <Influence>10</Influence>
                    <SamplingPeriod>5</SamplingPeriod>
                  </CoolingDevice>
                </TripPoint>
              </TripPoints>
            </ThermalZone>
          </ThermalZones>
        </Platform>
      </ThermalConfiguration>
    '';
  };

  # nixdirenv requires this to stop nix from garbage collecting its stuff
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
}
   
