# Home Manager Module - Usage Guide

This home manager module provides type-safe, declarative configuration for Framework Laptop 16 input modules. All command-line options are exposed as typed Nix options.

## Multiple Input Module Support

The Framework Laptop 16 allows multiple input modules of the same type (e.g., two LED matrices side by side). Each service can target a specific device using `serialDevice`, or omit it to control the first available device.

Use `inputmodule-control --list` to find device paths for your installed modules.

## Enable/Disable Services

The module provides two levels of control:

1. **Master Enable** (`services.inputmodule-control.enable`): Must be `true` for any services to be created
2. **Individual Enable** (e.g., `ledMatrix.clock.enable`): Controls each specific service (default: `true`)

```nix
services.inputmodule-control = {
  enable = true;  # Master switch - must be true
  
  ledMatrix = {
    # This service is active (enable defaults to true)
    clock = {
      clock = true;
    };
    
    # This service is disabled
    pattern = {
      enable = false;  # Explicitly disabled
      pattern = "lotus-sideways";
    };
  };
};
```

This allows you to:
- Keep multiple configurations without deleting them
- Quickly switch between different setups
- Disable all services at once with the master switch
- Troubleshoot by selectively enabling services

## Basic Setup

Add the module to your home manager flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    framework-inputmodule = {
      url = "github:alisonjenkins/framework-16-inputmodule-rs-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, framework-inputmodule, ... }: {
    homeConfigurations.your-username = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        framework-inputmodule.homeManagerModules.default
        {
          # Your home manager configuration here
        }
      ];
    };
  };
}
```

## LED Matrix Examples

### Simple Clock

```nix
{
  services.inputmodule-control = {
    enable = true;  # Enable the module
    package = framework-inputmodule.packages.x86_64-linux.inputmodule-control;
    
    ledMatrix.clock = {
      # enable = true;  # Default: true (can set to false to disable this service)
      clock = true;
      brightness = 128;
    };
  };
}
```

### Dual LED Matrix Setup

Control two LED matrices independently:

```nix
{
  services.inputmodule-control = {
    enable = true;
    package = framework-inputmodule.packages.x86_64-linux.inputmodule-control;
    
    ledMatrix = {
      # Left matrix: clock with breathing effect
      clock-left = {
        enable = true;  # Can disable individual services
        serialDevice = "/dev/ttyACM0";
        clock = true;
        brightness = 150;
        breathing = true;
      };
      
      # Right matrix: random equalizer  
      eq-right = {
        enable = true;
        serialDevice = "/dev/ttyACM1";
        randomEq = true;
        brightness = 200;
      };
      
      # Disabled service example
      pattern-disabled = {
        enable = false;  # This service won't be created
        pattern = "lotus-sideways";
      };
    };
  };
}
```

### Display Text with Effects

```nix
{
  services.inputmodule-control.ledMatrix = {
    greeting = {
      string = "HELLO";
      brightness = 180;
      blinking = true;
    };
    
    percentage-display = {
      percentage = 75;
      breathing = true;
    };
  };
}
```

### Patterns and Animations

```nix
{
  services.inputmodule-control.ledMatrix = {
    pattern = {
      pattern = "lotus-sideways";
      brightness = 255;
      animate = true;
      animationFps = 30;
    };
    
    custom-eq = {
      eq = [ 10 20 30 40 50 40 30 20 10 ];
      breathing = true;
    };
  };
}
```

### Games

```nix
{
  services.inputmodule-control.ledMatrix = {
    snake = {
      startGame = "snake";
      brightness = 200;
    };
    
    game-of-life = {
      startGame = "game-of-life";
      gameParam = "glider";
      brightness = 150;
    };
  };
}
```

## B1 Display Examples

```nix
{
  services.inputmodule-control.b1Display = {
    main = {
      displayOn = true;
      fps = "thirty-two";
      powerMode = "high";
      screenSaver = false;
    };
    
    # Display an image
    wallpaper = {
      image = ./my-image.png;
      invertScreen = false;
    };
  };
}
```

## C1 Minimal Examples

```nix
{
  services.inputmodule-control.c1Minimal = {
    led = {
      setColor = "blue";
    };
  };
}
```

## Complete Example

```nix
{
  services.inputmodule-control = {
    enable = true;
    package = framework-inputmodule.packages.x86_64-linux.inputmodule-control;
    
    ledMatrix = {
      left = {
        serialDevice = "/dev/ttyACM0";
        clock = true;
        brightness = 128;
        breathing = true;
      };
      
      right = {
        serialDevice = "/dev/ttyACM1";
        randomEq = true;
        brightness = 200;
      };
    };
    
    b1Display.main = {
      displayOn = true;
      fps = "thirty-two";
      powerMode = "high";
    };
    
    c1Minimal.status = {
      setColor = "green";
    };
  };
}
```

## Managing Services

```bash
# List all inputmodule-control services
systemctl --user list-units 'inputmodule-control-*'

# LED Matrix services are named: inputmodule-control-led-<name>
systemctl --user status inputmodule-control-led-clock-left
systemctl --user status inputmodule-control-led-eq-right

# B1 Display services: inputmodule-control-b1-<name>
systemctl --user status inputmodule-control-b1-main

# C1 Minimal services: inputmodule-control-c1-<name>
systemctl --user status inputmodule-control-c1-led

# Control services
systemctl --user start inputmodule-control-led-clock-left
systemctl --user stop inputmodule-control-led-clock-left
systemctl --user restart inputmodule-control-led-clock-left

# View logs
journalctl --user -u inputmodule-control-led-clock-left -f

# Find device paths
inputmodule-control --list
```

## Configuration Reference

### Common Options (all device types)

All device configurations support:

- **`enable`** (bool, default: `true`) - Enable/disable this specific service
  - Set to `false` to disable a service without removing its configuration
  - Useful for temporarily disabling services or having multiple configs you can switch between
- **`serialDevice`** (null or string) - Target specific device (e.g., "/dev/ttyACM0")
- **`waitForDevice`** (bool, default: `true`) - Wait for device before starting
- **`wantedBy`** (list of strings, default: `["graphical-session.target"]`) - Systemd targets
- **`restartOnFailure`** (bool, default: `true`) - Restart on failure
- **`restartSec`** (int, default: `5`) - Seconds to wait before restart

**Note**: The top-level `services.inputmodule-control.enable` must be `true` for any services to be created.

### LED Matrix Options (`ledMatrix.<name>`)

#### Display Modes (choose one or combine)

- **`clock`** (bool) - Display a clock
- **`randomEq`** (bool) - Random equalizer animation
- **`string`** (null or string) - Display text (max 5 uppercase chars)
- **`symbols`** (null or list of strings) - Display symbols (max 5)
- **`percentage`** (null or int 0-100) - Display a percentage
- **`pattern`** (null or enum) - Display a pattern
  - Values: `"percentage"`, `"gradient"`, `"double-gradient"`, `"lotus-sideways"`, `"zigzag"`, `"all-on"`, `"panic"`, `"lotus-top-down"`
- **`imageBw`** (null or path) - Black & white image (9x34px)
- **`imageGray`** (null or path) - Grayscale image
- **`eq`** (null or list of 9 ints) - Custom EQ values

#### Games

- **`startGame`** (null or enum) - Start a game: `"snake"`, `"pong"`, `"tetris"`, `"game-of-life"`
- **`gameParam`** (null or enum) - Game parameter: `"current-matrix"`, `"pattern1"`, `"blinker"`, `"toad"`, `"beacon"`, `"glider"`, `"beacon-toad-blinker"`
- **`stopGame`** (bool) - Stop the current game

#### Settings

- **`brightness`** (null or int 0-255) - LED brightness
- **`sleeping`** (null or bool) - Sleep status
- **`animate`** (null or bool) - Start/stop animation
- **`animationFps`** (null or int) - Animation FPS
- **`pwmFreq`** (null or int) - PWM frequency in Hz

#### Effects

- **`allBrightnesses`** (bool) - Show every brightness level
- **`blinking`** (bool) - Blink pattern once per second
- **`breathing`** (bool) - Breathing brightness effect

#### System

- **`bootloader`** (bool) - Jump to bootloader
- **`debugMode`** (null or bool) - Debug mode

### B1 Display Options (`b1Display.<name>`)

- **`displayOn`** (null or bool) - Turn display on/off
- **`pattern`** (null or enum) - Simple pattern: `"white"`, `"black"`
- **`invertScreen`** (null or bool) - Invert screen
- **`screenSaver`** (null or bool) - Screensaver on/off
- **`fps`** (null or enum) - Frame rate: `"quarter"`, `"half"`, `"one"`, `"two"`, `"four"`, `"eight"`, `"sixteen"`, `"thirty-two"`
- **`powerMode`** (null or enum) - Power mode: `"low"`, `"high"`
- **`animationFps`** (null or int) - Animation FPS
- **`image`** (null or path) - B&W image (300x400px)
- **`animatedGif`** (null or path) - Animated B&W GIF (300x400px)
- **`clearRam`** (bool) - Clear display RAM
- **`sleeping`** (null or bool) - Sleep status
- **`bootloader`** (bool) - Jump to bootloader

### C1 Minimal Options (`c1Minimal.<name>`)

- **`setColor`** (null or enum) - LED color: `"white"`, `"black"`, `"red"`, `"green"`, `"blue"`, `"yellow"`, `"cyan"`, `"purple"`
- **`sleeping`** (null or bool) - Sleep status
- **`bootloader`** (bool) - Jump to bootloader

## Notes

- The udev rules must be installed system-wide via NixOS configuration for proper device permissions
- Services start automatically when the graphical session target is reached
- Each service runs independently and can be managed separately
- The `--wait-for-device` flag is enabled by default to handle device hotplugging
- Multiple options can be combined (e.g., clock + breathing + brightness)
- Service names are prefixed by device type: `led-`, `b1-`, or `c1-`
