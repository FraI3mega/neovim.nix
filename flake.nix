# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license
# This is an empty nixCats config.
# you may import this template directly into your nvim folder
# and then add plugins to categories here,
# and call the plugins with their default functions
# within your lua, rather than through the nvim package manager's method.
# Use the help, and the example repository https://github.com/BirdeeHub/nixCats-nvim
# It allows for easy adoption of nix,
# while still providing all the extra nix features immediately.
# Configure in lua, check for a few categories, set a few settings,
# output packages with combinations of those categories and settings.
# All the same options you make here will be automatically exported in a form available
# in home manager and in nixosModules, as well as from other flakes.
# each section is tagged with its relevant help section.
{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    awesome-neovim-plugins.url = "github:m15a/flake-awesome-neovim-plugins";
    rustaceanvim.url = "github:mrcjkb/rustaceanvim";
    blink-cmp.url = "github:saghen/blink.cmp";
    "plugins-auto-save" = {
      url = "github:okuuva/auto-save.nvim";
      flake = false;
    };

    "plugins-large_file" = {
      url = "github:mireq/large_file";
      flake = false;
    };

    "plugins-cord-nvim" = {
      url = "github:vyfor/cord.nvim/client-server";
      flake = false;
    };

    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };

    # see :help nixCats.flake.inputs
    # If you want your plugin to be loaded by the standard overlay,
    # i.e. if it wasnt on nixpkgs, but doesnt have an extra build step.
    # Then you should name it "plugins-something"
    # If you wish to define a custom build step not handled by nixpkgs,
    # then you should name it in a different format, and deal with that in the
    # overlay defined for custom builds in the overlays directory.
    # for specific tags, branches and commits, see:
    # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#examples
  };

  # see :help nixCats.flake.outputs
  outputs = {
    self,
    nixpkgs,
    nixCats,
    blink-cmp,
    ...
  } @ inputs: let
    inherit (nixCats) utils;
    luaPath = "${./.}";
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    # the following extra_pkg_config contains any values
    # which you want to pass to the config set of nixpkgs
    # import nixpkgs { config = extra_pkg_config; inherit system; }
    # will not apply to module imports
    # as that will have your system values
    extra_pkg_config = {
      allowUnfree = true;
    };
    # management of the system variable is one of the harder parts of using flakes.

    # so I have done it here in an interesting way to keep it out of the way.
    # It gets resolved within the builder itself, and then passed to your
    # categoryDefinitions and packageDefinitions.

    # this allows you to use ${pkgs.system} whenever you want in those sections
    # without fear.

    # sometimes our overlays require a ${system} to access the overlay.
    # The default templates wrap the set we add them to with ${system}
    # because using them this way requires
    # least intervention when encountering malformed flakes.

    # Your dependencyOverlays can either be lists
    # in a set of ${system}, or simply a list.
    # the nixCats builder function will accept either.
    # see :help nixCats.flake.outputs.overlays
    inherit
      (forEachSystem (
        system: let
          dependencyOverlays =
            # (import ./overlays inputs) ++
            [
              # This overlay grabs all the inputs named in the format
              # `plugins-<pluginName>`
              # Once we add this overlay to our nixpkgs, we are able to
              # use `pkgs.neovimPlugins`, which is a set of our plugins.
              (utils.standardPluginOverlay inputs)
              # add any other flake overlays here.
              inputs.awesome-neovim-plugins.overlays.default
              inputs.rustaceanvim.overlays.default
            ];
        in {
          inherit dependencyOverlays;
        }
      ))
      dependencyOverlays
      ;

    # see :help nixCats.flake.outputs.categories
    # and
    # :help nixCats.flake.outputs.categoryDefinitions.scheme
    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      name,
      ...
    } @ packageDef: {
      # to define and use a new category, simply add a new list to a set here,
      # and later, you will include categoryname = true; in the set you
      # provide when you build the package using this builder function.
      # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

      # lspsAndRuntimeDeps:
      # this section is for dependencies that should be available
      # at RUN TIME for plugins. Will be available to PATH within neovim terminal
      # this includes LSPs
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          universal-ctags
          ripgrep
          fd
          ruff
          basedpyright
          imagemagick
          fish
          git-absorb
          curl
        ];
        lint = with pkgs; [
          statix
          actionlint
          fish
          markdownlint-cli2
          deadnix
        ];
        # but you can choose which ones you want
        # per nvim package you export
        debug = with pkgs; [
          vscode-extensions.vadimcn.vscode-lldb.adapter
        ];
        # and easily check if they are included in lua
        format = with pkgs; [
          stylua
          isort
          alejandra
          taplo
          yamlfmt
        ];
        neonixdev = {
          inherit
            (pkgs)
            nix-doc
            lua-language-server
            nixd
            ;
        };
      };

      # This is for plugins that will load at startup without using packadd:
      startupPlugins = {
        gitPlugins = with pkgs.neovimPlugins; [
        ];
        languages = {
          rust = with pkgs.vimPlugins; [
            rustaceanvim
            crates-nvim
          ];
        };

        general = with pkgs.vimPlugins; {
          always = [
            lze
            vim-repeat
            plenary-nvim
            dressing-nvim
            nvim-nio
            nvim-notify
            nvim-autopairs
            pkgs.neovimPlugins.large_file
            better-escape-nvim
            promise-async
            guess-indent-nvim
            nvim-unception
            mini-nvim
            dial-nvim
            sort-nvim
            sqlite-lua
            dropbar-nvim
          ];
          extra = [
            oil-nvim
            nvim-web-devicons
            smart-splits-nvim
            persisted-nvim
            otter-nvim
            vim-wakatime
          ];
          blink = with pkgs.vimPlugins; [
            blink-cmp.outputs.packages.${pkgs.system}.blink-cmp
            friendly-snippets
          ];

          awesome = with pkgs.awesomeNeovimPlugins; [
          ];
          themer = with pkgs.vimPlugins; (builtins.getAttr categories.colorscheme {
            # Theme switcher without creating a new category
            "onedark" = onedark-nvim;
            "catppuccin" = catppuccin-nvim;
            "catppuccin-mocha" = catppuccin-nvim;
            "tokyonight" = tokyonight-nvim;
            "tokyonight-day" = tokyonight-nvim;
          });
        };
      };

      # not loaded automatically at startup.
      # use with packadd and an autocommand in config to achieve lazy loading
      optionalPlugins = {
        debug = with pkgs.vimPlugins; [
          nvim-dap
          nvim-dap-ui
          nvim-dap-virtual-text
        ];
        lint = with pkgs.vimPlugins; [
          none-ls-nvim
        ];
        format = with pkgs.vimPlugins; [
          conform-nvim
        ];
        markdown = with pkgs.vimPlugins; [
          markdown-preview-nvim
          markview-nvim
        ];
        neonixdev = with pkgs.vimPlugins; [
          lazydev-nvim
        ];

        languages = {
          general = with pkgs.vimPlugins; [
            neotest
            neogen
          ];
          rust = with pkgs.vimPlugins; [
            crates-nvim
          ];
        };

        gitPlugins = with pkgs.neovimPlugins; [
        ];
        general = {
          treesitter = with pkgs.vimPlugins; [
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
          ];
          telescope = with pkgs.vimPlugins; [
            telescope-fzf-native-nvim
            telescope-ui-select-nvim
            telescope-nvim
          ];
          always = with pkgs.vimPlugins; [
            smart-open-nvim
            nvim-lspconfig
            lualine-nvim
            barbar-nvim
            gitsigns-nvim
            neogit
            diffview-nvim
            vim-fugitive
            heirline-nvim
            pkgs.awesomeNeovimPlugins.heirline-components-nvim
            vim-rhubarb
            nvim-surround
            flash-nvim
            pkgs.neovimPlugins.auto-save
            toggleterm-nvim
            noice-nvim
            nvim-ufo
          ];
          extra = with pkgs.vimPlugins; [
            # fidget-nvim
            which-key-nvim
            comment-nvim
            undotree
            indent-blankline-nvim
            vim-startuptime
            aerial-nvim
            trouble-nvim
            todo-comments-nvim
            nvim-bqf
            image-nvim
            img-clip-nvim
            pkgs.neovimPlugins.cord-nvim
            twilight-nvim
            zen-mode-nvim
            grug-far-nvim
            codesnap-nvim
          ];
          ai = with pkgs.vimPlugins; [
            pkgs.awesomeNeovimPlugins.codecompanion-nvim
            render-markdown-nvim
          ];
          fun = with pkgs.vimPlugins; [
            cellular-automaton-nvim
            pkgs.awesomeNeovimPlugins.nvim-tetris
            pkgs.awesomeNeovimPlugins.playtime-nvim
          ];
          awesome = with pkgs.awesomeNeovimPlugins; [
            hlsearch-nvim
            kitty-scrollback-nvim
          ];
        };
      };

      # variable available to nvim runtime
      sharedLibraries = {
        general = with pkgs; [
          # libgit2
          sqlite
        ];
      };

      # environmentVariables:
      # this section is for environmentVariables that should be available
      # at RUN TIME for plugins. Will be available to path within neovim terminal
      environmentVariables = {
      };

      # If you know what these are, you can provide custom ones by category here.
      # If you dont, check this link out:
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      extraWrapperArgs = {
      };

      # lists of the functions you would have passed to
      # python.withPackages or lua.withPackages

      # get the path to this python environment
      # in your lua config via
      # vim.g.python3_host_prog
      # or run from nvim terminal via :!<packagename>-python3
      extraPython3Packages = {
        test = _: [];
      };
      # populates $LUA_PATH and $LUA_CPATH
      extraLuaPackages = {
        general = [(lp: with lp; [magick])];
      };
    };

    # And then build a package with specific categories from above here:
    # All categories you wish to include must be marked true,
    # but false may be omitted.
    # This entire set is also passed to nixCats for querying within the lua.

    # see :help nixCats.flake.outputs.packageDefinitions
    packageDefinitions = {
      # These are the names of your packages
      # you can include as many as you wish.
      nvim = {pkgs, ...}: {
        # they contain a settings set defined above
        # see :help nixCats.flake.outputs.settings
        settings = {
          wrapRc = true;
          # IMPORTANT:
          # your alias may not conflict with your other packages.
          aliases = ["vim"];
          # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
        };
        # and a set of categories that you want
        # (and other information to pass to lua)
        categories = {
          languages = true;
          general = true;

          gitPlugins = true;
          customPlugins = true;
          markdown = true;
          lint = true;
          format = true;
          neonixdev = true;
          debug = true;
          themer = true;
          colorscheme = "catppuccin-mocha";
          nixdExtras = {
            nixpkgs = nixpkgs.outPath;
          };
          # sqlite_path = "${pkgs.sqlite.out}/lib/libsqlite3.so";
        };
      };
    };
    # In this section, the main thing you will need to do is change the default package name
    # to the name of the packageDefinitions entry you wish to use as the default.
    defaultPackageName = "nvim";
  in
    # see :help nixCats.flake.outputs.exports
    forEachSystem (
      system: let
        nixCatsBuilder =
          utils.baseBuilder luaPath {
            inherit
              nixpkgs
              system
              dependencyOverlays
              extra_pkg_config
              ;
          }
          categoryDefinitions
          packageDefinitions;
        defaultPackage = nixCatsBuilder defaultPackageName;
        # this is just for using utils such as pkgs.mkShell
        # The one used to build neovim is resolved inside the builder
        # and is passed to our categoryDefinitions and packageDefinitions
        pkgs = import nixpkgs {inherit system;};
      in {
        # these outputs will be wrapped with ${system} by utils.eachSystem

        # this will make a package out of each of the packageDefinitions defined above
        # and set the default package to the one passed in here.
        packages = utils.mkAllWithDefault defaultPackage;

        # choose your package for devShell
        # and add whatever else you want in it.
        devShells = {
          default = pkgs.mkShell {
            name = defaultPackageName;
            packages = [defaultPackage];
            inputsFrom = [];
            shellHook = '''';
          };
        };
      }
    )
    // {
      # these outputs will be NOT wrapped with ${system}

      # this will make an overlay out of each of the packageDefinitions defined above
      # and set the default overlay to the one named here.
      overlays =
        utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions
        defaultPackageName;

      # we also export a nixos module to allow reconfiguration from configuration.nix
      nixosModules.default = utils.mkNixosModules {
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
      # and the same for home manager
      homeModule = utils.mkHomeModules {
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

      inherit utils;
      inherit (utils) templates;
    };
}
