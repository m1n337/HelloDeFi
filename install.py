#!/usr/bin/env python

import os
import sys
import json
import subprocess
from pathlib import Path
from string import Template

def _execute(cmd, cwd):
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=cwd, shell=True)
    output, error = process.communicate()
    
    return process.returncode, output.decode('utf-8'), error.decode('utf-8')

def execute_cmd(cmd, cwd=None):
    ret, output, err = _execute(cmd, cwd)

    if (ret == 0):
        print(output.strip())
    else:
        print(err)
        sys.exit(-1)


HOME = Path.home()
BASE_LIB_PATH = HOME / Path(".hello_defi/lib")
DEFAULT_LIB_PATH = BASE_LIB_PATH / Path('latest')

FOUNDRY_TOML_TEMPLATE = """
[profile.default]
src = "src"
out = "out"
libs = [${libs}]
${remappings_field}
ignored_error_codes = ["license", "code-size"]
${rpc_endpoints_field}
via_ir=true

# See more config options https://github.com/foundry-rs/foundry/blob/master/crates/config/README.md#all-options
"""

LIB_URLS = {
    "forge-std": "https://github.com/foundry-rs/forge-std",
    "openzeppelin-contracts": "https://github.com/openzeppelin/openzeppelin-contracts"
}

DEFAULT_REMAPPINGS_PREFIX = {
    "forge-std": "src",
    "evm-address": "src"
}

CHAIN_IDS = {
    "mainnet": 1,
    "bsc": 56,
    "polygon": 137,
    "polygon_zkevm": 1101,
    "avalance": 43114,
    "arbitrum": 42161,
    "arbitrum_nove": 42170,
    "optimism": 10,
    "fantom": 250,
    "moonriver": 1285,
    "gnosis": 100,
    "celo": 42220,
    "base": 8453,
    "metis": 1088,
    "harmony": 1666600000,
    "zksync_era": 324,
    "linea": 59144
}

# providers: alchemy' -> infra' -> ankr
ANKR_PUBLIC_RPC = {

}

def generate_rpc_endpoints():
    pass

def generate_foundry_toml_file(rpc_endpoints=None, remappings=None, libs=[]):
    ft = Template(FOUNDRY_TOML_TEMPLATE)
    rpc_endpoints_field = ""
    remappings_field = ""
    libs = [
        f"\"{DEFAULT_LIB_PATH}\""
    ]
    if rpc_endpoints:
        _rpc_endpoints = '\n'.join(rpc_endpoints)
        rpc_endpoints_field = f"\n[rpc_endpoints]\n{_rpc_endpoints}"
    if remappings:
        _remappings = ',\n'.join(f'"{item}"' for item in remappings)
        remappings_field = f"remappings = [\n{_remappings}\n]"
    libs = ', '.join(libs)
    return ft.substitute(libs=libs, rpc_endpoints_field=rpc_endpoints_field, remappings_field=remappings_field)

def generate_vscode_settings_file(remappings=None):
    settings_json = {}

    if remappings:
        settings_json["solidity.remappings"] = remappings_list
        
    return json.dumps(settings_json)

GITHUB_BASE_URL = "https://github.com/"

def _install_library(lib_url, version, lib_path):
    execute_cmd(f"git clone --recurse-submodules {lib_url} {lib_path}")
    if version != "latest":
        execute_cmd(cmd=f"git checkout {version}", cwd=lib_path)

def init_config(path):
    config_file_path = Path(path) / Path("config.json")
    remappings = {}
    with open(config_file_path, 'r') as f:
        cfg = json.load(f)
        for d in cfg["dependencies"]:            
            dep = d.split('@')
            if len(dep) == 2:
                [lib_name, version] = dep
            elif len(dep) == 3:
                [lib_name, _lib_url, version] = dep
            print(f"[Check] dependency: {lib_name}@{version}")
            if version == "latest":
                # check if the lib_name exist in the BASE_LIB_PATH
                lib_path = BASE_LIB_PATH / Path(f"latest/{lib_name}")
            else:
                lib_path = BASE_LIB_PATH / Path(f"{lib_name}/{version}")
            
            if not lib_path.exists():
                try:
                    lib_url = LIB_URLS[lib_name]
                    _install_library(lib_url, version, lib_path)
                except KeyError:
                    try:
                        # try fetch library from github.com
                        lib_url = GITHUB_BASE_URL + _lib_url + ".git"
                        _install_library(lib_url, version, lib_path)
                    except Exception as e:
                        print(f"Library {lib_name} not found: ", e)
            else:
                print(f"Library {lib_name} already installed...")
            
            try:
                prefix = DEFAULT_REMAPPINGS_PREFIX[lib_name]
                lib_path = lib_path / Path(prefix)
            except KeyError:
                pass
            remappings[lib_name] = lib_path

    return remappings

VSCODE_SETTINGS_DIR=Path('.vscode/')

if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(-1)
    repo_path = sys.argv[1]
    if not Path(repo_path).exists():
        print(f"[X] Repo {repo_path} not exist...")
        sys.exit(-1)

    remappings = init_config(repo_path)

    remappings_list = []
    for lib_name, lib_path in remappings.items():
        remappings_list.append(f"{lib_name}={lib_path}")
    
    # write into the {repo_path}/foundry.toml
    foundry_toml = generate_foundry_toml_file(rpc_endpoints=[], remappings=remappings_list)
    with open(repo_path / Path("foundry.toml"), 'w') as f:
        f.write(foundry_toml)
    
    # write into the .vscode/settings.json
    vscode_settings = generate_vscode_settings_file(remappings=remappings_list)
    if not VSCODE_SETTINGS_DIR.exists():
        VSCODE_SETTINGS_DIR.mkdir(parents=True)
    with open(VSCODE_SETTINGS_DIR / Path('settings.json'), 'w') as f:
        f.write(vscode_settings)