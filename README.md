# Framework 16 Input Module Control - Nix Flake

A Nix flake for the [Framework Laptop 16 input modules](https://github.com/FrameworkComputer/inputmodule-rs), providing both the `inputmodule-control` command-line tool and udev rules for proper device permissions.

## What's Included

This flake provides two packages:

1. **`inputmodule-control`** - Command-line tool to control Framework 16 input modules (LED Matrix, B1 Display, C1 Minimal)
2. **`udev`** - Udev rules to grant users access to the input module devices

## Installation

### NixOS Configuration (Recommended)

Add this flake to your NixOS configuration for system-wide installation with proper udev rules:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    framework-inputmodule = {
      url = "github:alisonjenkins/framework-16-inputmodule-rs-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, framework-inputmodule, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          # Install the control tool
          environment.systemPackages = [
            framework-inputmodule.packages.${system}.inputmodule-control
          ];

          # Install udev rules (required for non-root access)
          services.udev.packages = [
            framework-inputmodule.packages.${system}.udev
          ];
        }
        # ... your other modules
      ];
    };
  };
}
```

After adding to your configuration:

```bash
sudo nixos-rebuild switch
```

The udev rules will be automatically installed and loaded.

### Home Manager

#### Option 1: Home Manager Module with Systemd Services (Recommended)

Use the home manager module with type-safe options for automatic systemd service setup:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    framework-inputmodule.url = "github:alisonjenkins/framework-16-inputmodule-rs-flake";
  };

  outputs = { self, nixpkgs, home-manager, framework-inputmodule, ... }: {
    homeConfigurations.your-username = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        framework-inputmodule.homeManagerModules.default
        {
          services.inputmodule-control = {
            enable = true;
            package = framework-inputmodule.packages.x86_64-linux.inputmodule-control;
            
            # LED Matrix with typed options
            ledMatrix.clock = {
              clock = true;
              brightness = 128;
              breathing = true;
            };
            
            # Control multiple LED matrices independently
            # ledMatrix.left = {
            #   serialDevice = "/dev/ttyACM0";
            #   clock = true;
            # };
            # ledMatrix.right = {
            #   serialDevice = "/dev/ttyACM1";
            #   randomEq = true;
            # };
          };
        }
      ];
    };
  };
}
```

The module exposes all inputmodule-control options as typed Nix options organized by device type:
- `ledMatrix.<name>` - LED Matrix module configuration
- `b1Display.<name>` - B1 Display module configuration  
- `c1Minimal.<name>` - C1 Minimal module configuration

See [HOME-MANAGER.md](./HOME-MANAGER.md) for detailed configuration examples and complete API reference.

#### Option 2: Install Package Only

Install just the control tool in your user environment:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    framework-inputmodule.url = "github:alisonjenkins/framework-16-inputmodule-rs-flake";
  };

  outputs = { self, nixpkgs, home-manager, framework-inputmodule, ... }: {
    homeConfigurations.your-username = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        {
          home.packages = [
            framework-inputmodule.packages.x86_64-linux.inputmodule-control
          ];
        }
      ];
    };
  };
}
```

**Note:** When using Home Manager alone, you'll need to manually install the udev rules system-wide or add them to your NixOS configuration.

## Usage

### Basic Commands

List all connected input modules:

```bash
inputmodule-control list
```

Control LED Matrix module:

```bash
# Set brightness (0-255)
inputmodule-control led-matrix --brightness 128

# Display text (max 5 uppercase characters)
inputmodule-control led-matrix --string "HELLO"

# Run built-in animations
inputmodule-control led-matrix --animate
```

Control B1 Display module:

```bash
inputmodule-control b1-display --help
```

Control C1 Minimal module:

```bash
inputmodule-control c1-minimal --help
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This Nix flake is provided under the MIT license. The upstream `inputmodule-rs` project is also MIT licensed.

## See Also

- [Framework Laptop 16 Input Modules](https://github.com/FrameworkComputer/inputmodule-rs)
- [Framework Community](https://community.frame.work/)
