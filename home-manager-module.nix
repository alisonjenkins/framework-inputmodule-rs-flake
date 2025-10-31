{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.inputmodule-control;
  inputmodule-control = config.services.inputmodule-control.package;

  # Helper function to build command line arguments from options
  buildLedMatrixArgs = opts: concatStringsSep " " (filter (x: x != "") [
    (optionalString (opts.brightness != null) "--brightness ${toString opts.brightness}")
    (optionalString (opts.sleeping != null) "--sleeping ${boolToString opts.sleeping}")
    (optionalString opts.bootloader "--bootloader")
    (optionalString (opts.percentage != null) "--percentage ${toString opts.percentage}")
    (optionalString (opts.animate != null) "--animate ${boolToString opts.animate}")
    (optionalString (opts.pattern != null) "--pattern ${opts.pattern}")
    (optionalString opts.allBrightnesses "--all-brightnesses")
    (optionalString opts.blinking "--blinking")
    (optionalString opts.breathing "--breathing")
    (optionalString (opts.imageBw != null) "--image-bw ${opts.imageBw}")
    (optionalString (opts.imageGray != null) "--image-gray ${opts.imageGray}")
    (optionalString opts.randomEq "--random-eq")
    (optionalString (opts.eq != null) "--eq ${concatStringsSep " " (map toString opts.eq)}")
    (optionalString opts.clock "--clock")
    (optionalString (opts.string != null) "--string ${opts.string}")
    (optionalString (opts.symbols != null) "--symbols ${concatStringsSep " " opts.symbols}")
    (optionalString (opts.startGame != null) "--start-game ${opts.startGame}")
    (optionalString (opts.gameParam != null) "--game-param ${opts.gameParam}")
    (optionalString opts.stopGame "--stop-game")
    (optionalString (opts.animationFps != null) "--animation-fps ${toString opts.animationFps}")
    (optionalString (opts.pwmFreq != null) "--pwm-freq ${toString opts.pwmFreq}")
    (optionalString (opts.debugMode != null) "--debug-mode ${boolToString opts.debugMode}")
  ]);

  buildB1DisplayArgs = opts: concatStringsSep " " (filter (x: x != "") [
    (optionalString (opts.sleeping != null) "--sleeping ${boolToString opts.sleeping}")
    (optionalString opts.bootloader "--bootloader")
    (optionalString (opts.displayOn != null) "--display-on ${boolToString opts.displayOn}")
    (optionalString (opts.pattern != null) "--pattern ${opts.pattern}")
    (optionalString (opts.invertScreen != null) "--invert-screen ${boolToString opts.invertScreen}")
    (optionalString (opts.screenSaver != null) "--screen-saver ${boolToString opts.screenSaver}")
    (optionalString (opts.fps != null) "--fps ${opts.fps}")
    (optionalString (opts.powerMode != null) "--power-mode ${opts.powerMode}")
    (optionalString (opts.animationFps != null) "--animation-fps ${toString opts.animationFps}")
    (optionalString (opts.image != null) "--image ${opts.image}")
    (optionalString (opts.animatedGif != null) "--animated-gif ${opts.animatedGif}")
    (optionalString opts.clearRam "--clear-ram")
  ]);

  buildC1MinimalArgs = opts: concatStringsSep " " (filter (x: x != "") [
    (optionalString (opts.sleeping != null) "--sleeping ${boolToString opts.sleeping}")
    (optionalString opts.bootloader "--bootloader")
    (optionalString (opts.setColor != null) "--set-color ${opts.setColor}")
  ]);

in
{
  options.services.inputmodule-control = {
    enable = mkEnableOption "Framework input module control services";

    package = mkOption {
      type = types.package;
      default = pkgs.inputmodule-control or (throw "inputmodule-control package not found in pkgs");
      defaultText = literalExpression "pkgs.inputmodule-control";
      description = "The inputmodule-control package to use.";
    };

    ledMatrix = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "this LED matrix service" // { default = true; };

          serialDevice = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "/dev/ttyACM0";
            description = "Specific serial device to target. Find with `inputmodule-control --list`.";
          };

          # Display modes (mutually exclusive in practice, but we let the user decide)
          clock = mkOption {
            type = types.bool;
            default = false;
            description = "Display a clock.";
          };

          randomEq = mkOption {
            type = types.bool;
            default = false;
            description = "Display random equalizer animation.";
          };

          string = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "HELLO";
            description = "Display a string (max 5 uppercase characters).";
          };

          symbols = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            example = [ "heart" "star" ];
            description = "Display symbols (max 5).";
          };

          percentage = mkOption {
            type = types.nullOr (types.ints.between 0 100);
            default = null;
            example = 75;
            description = "Display a percentage (0-100).";
          };

          pattern = mkOption {
            type = types.nullOr (types.enum [
              "percentage" "gradient" "double-gradient" "lotus-sideways"
              "zigzag" "all-on" "panic" "lotus-top-down"
            ]);
            default = null;
            example = "lotus-sideways";
            description = "Display a pattern.";
          };

          imageBw = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Display black & white image (9x34px).";
          };

          imageGray = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Display grayscale image.";
          };

          eq = mkOption {
            type = types.nullOr (types.listOf types.int);
            default = null;
            example = [ 1 2 3 4 5 6 7 8 9 ];
            description = "EQ with custom values (9 values).";
          };

          startGame = mkOption {
            type = types.nullOr (types.enum [ "snake" "pong" "tetris" "game-of-life" ]);
            default = null;
            description = "Start a game.";
          };

          gameParam = mkOption {
            type = types.nullOr (types.enum [
              "current-matrix" "pattern1" "blinker" "toad" "beacon" "glider" "beacon-toad-blinker"
            ]);
            default = null;
            description = "Parameter for starting the game.";
          };

          stopGame = mkOption {
            type = types.bool;
            default = false;
            description = "Stop the currently running game.";
          };

          # Settings
          brightness = mkOption {
            type = types.nullOr (types.ints.between 0 255);
            default = null;
            example = 128;
            description = "Set LED max brightness (0-255).";
          };

          sleeping = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Set sleep status.";
          };

          animate = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Start/stop animation.";
          };

          animationFps = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Set animation FPS.";
          };

          pwmFreq = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Set PWM frequency in Hz.";
          };

          # Effects
          allBrightnesses = mkOption {
            type = types.bool;
            default = false;
            description = "Show every brightness, one per pixel.";
          };

          blinking = mkOption {
            type = types.bool;
            default = false;
            description = "Blink the current pattern once a second.";
          };

          breathing = mkOption {
            type = types.bool;
            default = false;
            description = "Breathing brightness of the current pattern.";
          };

          # System
          bootloader = mkOption {
            type = types.bool;
            default = false;
            description = "Jump to the bootloader.";
          };

          debugMode = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Set debug mode.";
          };

          # Systemd options
          waitForDevice = mkOption {
            type = types.bool;
            default = true;
            description = "Wait for device to be available before starting.";
          };

          wantedBy = mkOption {
            type = types.listOf types.str;
            default = [ "graphical-session.target" ];
            description = "Systemd targets that should want this service.";
          };

          restartOnFailure = mkOption {
            type = types.bool;
            default = true;
            description = "Restart the service on failure.";
          };

          restartSec = mkOption {
            type = types.int;
            default = 5;
            description = "Time to wait before restarting (in seconds).";
          };
        };
      });
      default = {};
      example = literalExpression ''
        {
          clock-left = {
            serialDevice = "/dev/ttyACM0";
            clock = true;
            brightness = 128;
          };
          equalizer-right = {
            serialDevice = "/dev/ttyACM1";
            randomEq = true;
            breathing = true;
          };
        }
      '';
      description = "LED Matrix services to run.";
    };

    b1Display = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "this B1 display service" // { default = true; };

          serialDevice = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "/dev/ttyACM0";
            description = "Specific serial device to target.";
          };

          displayOn = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Turn display on/off.";
          };

          pattern = mkOption {
            type = types.nullOr (types.enum [ "white" "black" ]);
            default = null;
            description = "Display a simple pattern.";
          };

          invertScreen = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Invert screen on/off.";
          };

          screenSaver = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Screensaver on/off.";
          };

          fps = mkOption {
            type = types.nullOr (types.enum [
              "quarter" "half" "one" "two" "four" "eight" "sixteen" "thirty-two"
            ]);
            default = null;
            description = "Set FPS.";
          };

          powerMode = mkOption {
            type = types.nullOr (types.enum [ "low" "high" ]);
            default = null;
            description = "Set power mode.";
          };

          animationFps = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Set animation FPS.";
          };

          image = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Display a black & white image (300x400px).";
          };

          animatedGif = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Display an animated black & white GIF (300x400px).";
          };

          clearRam = mkOption {
            type = types.bool;
            default = false;
            description = "Clear display RAM.";
          };

          sleeping = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Set sleep status.";
          };

          bootloader = mkOption {
            type = types.bool;
            default = false;
            description = "Jump to the bootloader.";
          };

          waitForDevice = mkOption {
            type = types.bool;
            default = true;
            description = "Wait for device to be available before starting.";
          };

          wantedBy = mkOption {
            type = types.listOf types.str;
            default = [ "graphical-session.target" ];
            description = "Systemd targets that should want this service.";
          };

          restartOnFailure = mkOption {
            type = types.bool;
            default = true;
            description = "Restart the service on failure.";
          };

          restartSec = mkOption {
            type = types.int;
            default = 5;
            description = "Time to wait before restarting (in seconds).";
          };
        };
      });
      default = {};
      description = "B1 Display services to run.";
    };

    c1Minimal = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "this C1 minimal service" // { default = true; };

          serialDevice = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "/dev/ttyACM0";
            description = "Specific serial device to target.";
          };

          setColor = mkOption {
            type = types.nullOr (types.enum [
              "white" "black" "red" "green" "blue" "yellow" "cyan" "purple"
            ]);
            default = null;
            description = "Set LED color.";
          };

          sleeping = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Set sleep status.";
          };

          bootloader = mkOption {
            type = types.bool;
            default = false;
            description = "Jump to the bootloader.";
          };

          waitForDevice = mkOption {
            type = types.bool;
            default = true;
            description = "Wait for device to be available before starting.";
          };

          wantedBy = mkOption {
            type = types.listOf types.str;
            default = [ "graphical-session.target" ];
            description = "Systemd targets that should want this service.";
          };

          restartOnFailure = mkOption {
            type = types.bool;
            default = true;
            description = "Restart the service on failure.";
          };

          restartSec = mkOption {
            type = types.int;
            default = 5;
            description = "Time to wait before restarting (in seconds).";
          };
        };
      });
      default = {};
      description = "C1 Minimal services to run.";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services =
      # LED Matrix services
      (mapAttrs' (name: serviceCfg:
        nameValuePair "inputmodule-control-led-${name}" (mkIf serviceCfg.enable {
          unit = {
            Description = "Framework LED Matrix - ${name}";
            After = [ "graphical-session.target" ];
          };

          service = {
            Type = "simple";
            ExecStart =
              let
                serialDevArg = optionalString (serviceCfg.serialDevice != null) "--serial-dev ${serviceCfg.serialDevice} ";
                waitArg = optionalString serviceCfg.waitForDevice "--wait-for-device ";
                deviceArgs = buildLedMatrixArgs serviceCfg;
                commandStr = "${inputmodule-control}/bin/inputmodule-control ${serialDevArg}${waitArg}led-matrix ${deviceArgs}";
              in
                commandStr;
            Restart = if serviceCfg.restartOnFailure then "on-failure" else "no";
            RestartSec = serviceCfg.restartSec;
          };

          install = {
            WantedBy = serviceCfg.wantedBy;
          };
        })
      ) cfg.ledMatrix)
      //
      # B1 Display services
      (mapAttrs' (name: serviceCfg:
        nameValuePair "inputmodule-control-b1-${name}" (mkIf serviceCfg.enable {
          unit = {
            Description = "Framework B1 Display - ${name}";
            After = [ "graphical-session.target" ];
          };

          service = {
            Type = "simple";
            ExecStart =
              let
                serialDevArg = optionalString (serviceCfg.serialDevice != null) "--serial-dev ${serviceCfg.serialDevice} ";
                waitArg = optionalString serviceCfg.waitForDevice "--wait-for-device ";
                deviceArgs = buildB1DisplayArgs serviceCfg;
                commandStr = "${inputmodule-control}/bin/inputmodule-control ${serialDevArg}${waitArg}b1-display ${deviceArgs}";
              in
                commandStr;
            Restart = if serviceCfg.restartOnFailure then "on-failure" else "no";
            RestartSec = serviceCfg.restartSec;
          };

          install = {
            WantedBy = serviceCfg.wantedBy;
          };
        })
      ) cfg.b1Display)
      //
      # C1 Minimal services
      (mapAttrs' (name: serviceCfg:
        nameValuePair "inputmodule-control-c1-${name}" (mkIf serviceCfg.enable {
          unit = {
            Description = "Framework C1 Minimal - ${name}";
            After = [ "graphical-session.target" ];
          };

          service = {
            Type = "simple";
            ExecStart =
              let
                serialDevArg = optionalString (serviceCfg.serialDevice != null) "--serial-dev ${serviceCfg.serialDevice} ";
                waitArg = optionalString serviceCfg.waitForDevice "--wait-for-device ";
                deviceArgs = buildC1MinimalArgs serviceCfg;
                commandStr = "${inputmodule-control}/bin/inputmodule-control ${serialDevArg}${waitArg}c1-minimal ${deviceArgs}";
              in
                commandStr;
            Restart = if serviceCfg.restartOnFailure then "on-failure" else "no";
            RestartSec = serviceCfg.restartSec;
          };

          install = {
            WantedBy = serviceCfg.wantedBy;
          };
        })
      ) cfg.c1Minimal);
  };
}
