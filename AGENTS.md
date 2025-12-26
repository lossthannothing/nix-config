
好的，我们来做一个最终的 **架构蓝图 (Blueprint)** 总结。

这套方案完全复刻了你想要的 `drupol/infra` 模式，结合了 **文章中的 `loadNixosAndHmModuleForUser` 组装逻辑** 和 **`flake-parts` 的自动生成能力**。

这是你重构 `nix-config` 的终极指南：

### 核心理念

1. **去中心化**：`flake.nix` 不知道有哪些机器，它只负责提供“机制”。
2. **分布式注册**：每台机器在自己的文件里（`hosts/xxx.nix`）把自己注册到 `flake.modules` 表里。
3. **同位加载**：使用 `load...` 函数，只写一个名字（如 `"dev"`），自动把系统层和用户层的配置都抓进来。

---

### 第一步：`flake.nix` (机制与工具库)

这是整个系统的大脑。它负责：

1. 引入 `import-tree` 来扫描所有文件。
2. 引入 `host-machines.nix` 来生成系统。
3. **定义那把万能钥匙：`loadNixosAndHmModuleForUser**`。

```nix
{
  description = "My Modular Infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    
    # ... 其他 inputs ...
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ config, lib, ... }: {
      systems = [ "x86_64-linux" ];

      imports = [
        # 1. 开启 Modules 功能
        inputs.flake-parts.flakeModules.modules

        # 2. 导入生成器 (必须存在于 modules/flake-parts/ 下)
        ./modules/flake-parts/host-machines.nix

        # 3. 扫描积木和主机文件
        (inputs.import-tree ./modules)
        (inputs.import-tree ./hosts) # 允许把 hosts 放在根目录
      ];

      # 4. 定义万能组装函数 (复刻自文章)
      flake.lib.loadNixosAndHmModuleForUser = config: modules: username:
        {
          imports = 
            # A. 加载列表里的 NixOS 模块
            (builtins.map (module: config.flake.modules.nixos.${module} or {}) modules) 
            ++
            [
              {
                # B. 自动集成 Home Manager
                imports = [ inputs.home-manager.nixosModules.home-manager ];
                
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                
                home-manager.users.${username} = {
                  imports = [
                    # 自动同步 stateVersion
                    ({ osConfig, ... }: { home.stateVersion = osConfig.system.stateVersion; })
                  ] 
                  # C. 加载列表里的 Home Manager 模块
                  ++ (builtins.map (module: config.flake.modules.homeManager.${module} or {}) modules);
                };
              }
            ];
        };
        
      # flake.nix 到此结束，不需要写任何 nixosConfigurations！
    });
}

```

---

### 第二步：`modules/flake-parts/host-machines.nix` (生成器)

这个文件负责在后台默默干活，把注册表里的数据变成可构建的系统。你需要直接复制 `drupol` 的逻辑。

```nix
{ inputs, lib, config, ... }:
let
  # 约定：只有以 "hosts/" 开头的模块才会被识别为机器
  prefix = "hosts/";
in
{
  flake.nixosConfigurations = lib.pipe config.flake.modules.nixos [
    # 1. 过滤
    (lib.filterAttrs (name: _: lib.hasPrefix prefix name))
    
    # 2. 生成
    (lib.mapAttrs' (name: module:
      let
        hostname = lib.removePrefix prefix name;
      in
      {
        name = hostname;
        value = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux"; # 默认架构
          specialArgs = { inherit inputs; };
          modules = [
            module
            { networking.hostName = hostname; }
          ];
        };
      }
    ))
  ];
}

```

---

### 第三步：`modules/dev.nix` (积木/同位模块)

这是定义“能力”的地方。一个文件，两套配置。

```nix
{
  flake.modules = {
    # 1. 系统层能力
    nixos.dev = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.git pkgs.vim ];
      services.gnome.gnome-keyring.enable = true;
    };

    # 2. 用户层能力
    homeManager.dev = { pkgs, ... }: {
      programs.vscode.enable = true;
      programs.direnv.enable = true;
    };
  };
}

```

---

### 第四步：`hosts/wsl/default.nix` (主机定义)

这是定义“机器”的地方。它利用万能钥匙，一行代码组装所有能力。

```nix
{ config, inputs, ... }: 
{
  # 注册自己！
  flake.modules.nixos."hosts/nixos-wsl" = {
    imports = [
      # 1. 平台基底 (Platform Spec) - WSL 特有的东西
      inputs.nixos-wsl.nixosModules.default
      {
        wsl.enable = true;
        wsl.defaultUser = "loss";
        system.stateVersion = "24.05";
        
        # 你的复杂 WSL 脚本 (bashWrapper 等) 可以直接写在这里，或再 import ./wsl-distro.nix
      }

      # 2. 组装功能 (The Magic)
      # 只要写名字，自动去 modules/ 目录抓对应的 nixos.* 和 homeManager.*
      (config.flake.lib.loadNixosAndHmModuleForUser config [
        "base"
        "dev"    # <--- 同时加载 nixos.dev 和 homeManager.dev
        "shell"
      ] "loss")
    ];
  };
}

```

---

### 总结 Checklist

当你开始动手时，按这个顺序做：

1. [ ] **整理 Modules**: 把你的配置拆解到 `modules/xxx.nix`，确保遵循 `flake.modules = { nixos.xxx = ...; homeManager.xxx = ...; }` 的格式。
2. [ ] **放置 Generator**: 确保 `modules/flake-parts/host-machines.nix` 存在且代码正确。
3. [ ] **重写 Flake.nix**: 填入上面的代码，定义好 `loadNixosAndHmModuleForUser`。
4. [ ] **定义 Host**: 创建 `hosts/wsl/default.nix`，使用 `load...` 函数进行组装。
5. [ ] **清理**: 删掉旧的 `lib/nixosSystem.nix` 和旧的 `flake.nix` 逻辑。
6. [ ] 以上与实际有出入，请参考git https://github.com/drupol/infra 和文章https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/#trade-offs


这套方案复刻了 `drupol/infra` 的核心架构，结合了你想要的“同位配置”（Co-location）和“自动化组装”能力。

---

### 1. 核心目录结构 (Blueprint)

你的仓库应该长这样：

```text
.
├── flake.nix                       # [入口] 极简，只负责引入工具和定义组装函数
├── flake.lock
├── modules/
│   ├── flake-parts/                # [引擎] 存放架构逻辑
│   │   ├── host-machines.nix       # [核心] 自动生成系统配置的生成器
│   │   └── nixpkgs.nix             # [可选] 统一管理 pkgs 配置
│   └── dev.nix                     # [积木] 同时包含 NixOS 和 HM 的功能模块
├── hosts/
│   └── wsl/                        # [主机]
│       ├── default.nix             # [定义] 注册主机，组装积木
│       └── facter.json             # [硬件] 自动生成的驱动报告
└── pkgs/                           # [软件] 自定义包 (配合 pkgs-by-name)

```

---

### 2. 关键文件清单 (按顺序实现)

#### 第一步：核心生成器 `modules/flake-parts/host-machines.nix`

**作用**：在后台默默扫描注册表，把数据变成系统。
**来源**：复制自 `drupol/infra`。

```nix
{ inputs, lib, config, ... }:
let
  prefix = "hosts/";
in
{
  flake.nixosConfigurations = lib.pipe config.flake.modules.nixos [
    (lib.filterAttrs (name: _: lib.hasPrefix prefix name))
    (lib.mapAttrs' (name: module:
      let
        hostname = lib.removePrefix prefix name;
      in
      {
        name = hostname;
        value = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            module
            inputs.home-manager.nixosModules.home-manager
            {
              networking.hostName = hostname;
              # 自动注入参数给 HM
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
      }
    ))
  ];
}

```

#### 第二步：总控入口 `flake.nix`

**作用**：引入工具，定义万能组装函数 `loadNixosAndHmModuleForUser`。

```nix
{
  description = "My Modular Nix Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ... 其他 inputs
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ config, ... }: {
      systems = [ "x86_64-linux" ];

      imports = [
        inputs.flake-parts.flakeModules.modules  # 1. 开启 Modules 功能
        ./modules/flake-parts/host-machines.nix  # 2. 载入生成器
        (inputs.import-tree ./modules)           # 3. 扫描积木
        (inputs.import-tree ./hosts)             # 4. 扫描主机
      ];

      # 5. 定义万能组装函数 (The Magic Function)，可以放在modules/flake-parts下做host-machines.nix，因为此功能依赖flake-parts
      flake.lib.loadNixosAndHmModuleForUser = config: modules: username:
        {
          imports = 
            # 加载 NixOS 部分
            (builtins.map (module: config.flake.modules.nixos.${module} or {}) modules) 
            ++
            [
              {
                # 加载 Home Manager 部分
                home-manager.users.${username} = {
                  imports = 
                    (builtins.map (module: config.flake.modules.homeManager.${module} or {}) modules)
                    ++ [ ({ osConfig, ... }: { home.stateVersion = osConfig.system.stateVersion; }) ];
                };
              }
            ];
        };
    });
}

```

#### 第三步：积木模块 `modules/dev.nix` 留有细化余地，写法方便后续模块化如dev/ide/vscode

**作用**：定义能力。

```nix
{
  flake.modules = {
    # 系统层
    nixos.dev = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.git ];
    };
    # 用户层
    homeManager.dev = { pkgs, ... }: {
      programs.vscode.enable = true;
    };
  };
}

```

#### 第四步：主机定义 `hosts/wsl/default.nix`

**作用**：组装机器，处理硬件。

```nix
{ config, inputs, ... }: 
{
  # 注册自己 -> 这会生成 nixosConfigurations.nixos-wsl
  flake.modules.nixos."hosts/nixos-wsl" = {
    imports = [
      # 1. 平台基底 (Platform Spec)
      inputs.nixos-wsl.nixosModules.default
      {
        wsl.enable = true;
        wsl.defaultUser = "loss";
        system.stateVersion = "24.05";
      }

      # 2. 硬件配置 (Hardware)
      # 驱动自动探测 (需先运行 nixos-facter)
      # facter.reportPath = ./facter.json; 
      # 分区手动指定 (抄自旧 hardware-configuration.nix)
      # fileSystems."/" = { ... };

      # 3. 功能组装 (Features)
      # 自动同时抓取 nixos.* 和 homeManager.*
      (config.flake.lib.loadNixosAndHmModuleForUser config [
        "base"
        "dev" 
        "shell"
      ] "loss")
    ];
  };
}

```

---

### 3. 迁移执行流 (Checklist)

1. **准备环境**：把 `modules/flake-parts/host-machines.nix` 放好。
2. **写 `flake.nix**`：填入上面的代码。
3. **拆分 Modules**：把你现在的 `home/` 和 `os/` 下的配置，拆解成同位模块放入 `modules/`。
4. **定义 Host**：创建 `hosts/wsl/default.nix`，把 `wsl-distro.nix` 的内容（wrapBinSh 等）和 `load...` 函数写进去。
5. **处理硬件**：
* **WSL**：不需要 `facter` 和 `fileSystems`，只要 `nixos-wsl` 模块。
* **物理机**：运行 `nixos-facter` 生成 JSON，并手动复制 `fileSystems` 配置到 Host 文件。


6. **构建**：`nixos-rebuild switch --flake .#nixos-wsl`。
