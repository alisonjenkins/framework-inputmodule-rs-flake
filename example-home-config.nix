# Example home manager configuration for the inputmodule-control module
# This shows how to control multiple LED matrix modules independently with typed options

{ pkgs, ... }:

{
  imports = [
    ./home-manager-module.nix
  ];

  # Enable the inputmodule-control services
  services.inputmodule-control = {
    enable = true;  # Master enable for all services
    package = pkgs.inputmodule-control;
    
    # LED Matrix configurations
    ledMatrix = {
      # Clock on the left LED matrix
      clock-left = {
        enable = true;  # Individual service enable (default: true)
        serialDevice = "/dev/ttyACM0";  # Find with: inputmodule-control --list
        clock = true;
        brightness = 128;
        breathing = true;
      };
      
      # Equalizer on the right LED matrix
      equalizer-right = {
        enable = true;
        serialDevice = "/dev/ttyACM1";
        randomEq = true;
        brightness = 200;
      };
      
      # Alternative: Display a string with effects (disabled by default)
      # greeting = {
      #   enable = false;  # Set to true to enable this service
      #   string = "HELLO";
      #   brightness = 150;
      #   blinking = true;
      # };
      
      # Alternative: Display a pattern
      # pattern = {
      #   pattern = "lotus-sideways";
      #   breathing = true;
      # };
    };
    
    # B1 Display configurations (if you have one)
    # b1Display = {
    #   display = {
    #     displayOn = true;
    #     fps = "thirty-two";
    #     powerMode = "high";
    #   };
    # };
    
    # C1 Minimal configurations (if you have one)
    # c1Minimal = {
    #   led = {
    #     setColor = "blue";
    #   };
    # };
  };
}
