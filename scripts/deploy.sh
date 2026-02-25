#!/usr/bin/env bash
# scripts/deploy.sh — NixOS 部署脚本
#
# 支持：
#   - 交互式菜单 (无参数运行)
#   - Live USB 安装 (disko)
#   - 远程部署 (nixos-anywhere)
#   - 日常重建 (nixos-rebuild/home-manager)
#
# Usage:
#   ./scripts/deploy.sh                    # 交互式菜单
#   ./scripts/deploy.sh --local <host>     # Live USB 安装
#   ./scripts/deploy.sh <host> <ip>        # 远程部署
#   ./scripts/deploy.sh rebuild <host>     # 重建当前系统
set -euo pipefail

# ==============================================================================
# 配置和工具函数
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$(dirname "$SCRIPT_DIR")"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
header() { echo -e "${BLUE}==>${NC} $1"; }

# 交互式选择菜单
select_option() {
  local prompt="$1"
  shift
  local options=("$@")

  echo "$prompt" >&2
  PS3="请选择 [1-${#options[@]}]: "
  select opt in "${options[@]}"; do
    if [[ -n $opt ]]; then
      echo "$opt"
      break
    else
      error "无效选项，请重试" >&2
    fi
  done
}

# 需要硬件检测的主机
FACTER_HOSTS=("nixos-desktop")

needs_facter() {
  local host="$1"
  for fh in "${FACTER_HOSTS[@]}"; do
    [[ "$host" == "$fh" ]] && return 0
  done
  return 1
}

# 获取可用主机列表
get_available_hosts() {
  nix flake show "$FLAKE_DIR" --json 2>/dev/null | \
    nix run nixpkgs#jq -- -r '.nixosConfigurations | keys[]' 2>/dev/null || \
    echo "nixos-wsl"
}

# 获取 Home Manager 主机列表
get_hm_hosts() {
  nix flake show "$FLAKE_DIR" --json 2>/dev/null | \
    nix run nixpkgs#jq -- -r '.homeConfigurations | keys[]' 2>/dev/null || \
    echo ""
}

# 检测环境
detect_environment() {
  local os=$(uname -s)

  if [[ "$os" == "Darwin" ]]; then
    echo "macos"
  elif [[ -f /proc/version ]]; then
    if grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
      echo "wsl"
    elif [[ -f /etc/os-release ]] && grep -q "ID=nixos" /etc/os-release; then
      echo "nixos"
    else
      echo "linux"
    fi
  else
    echo "unknown"
  fi
}

# ==============================================================================
# 交互式菜单模式
# ==============================================================================

interactive_mode() {
  clear
  header "NixOS 配置部署脚本"
  echo ""

  local env=$(detect_environment)
  local hosts=$(get_available_hosts)
  local hm_hosts=$(get_hm_hosts)

  info "检测到环境: $env"
  info "可用主机: $hosts"
  [[ -n "$hm_hosts" ]] && info "可用 HM 主机: $hm_hosts"
  echo ""

  # 根据环境显示菜单
  case "$env" in
    wsl)
      if [[ -f /etc/os-release ]] && grep -q "ID=nixos" /etc/os-release; then
        # NixOS-WSL
        local hostname=$(hostname)
        local default_host="nixos-wsl"
        echo "$hosts" | grep -q "$hostname" && default_host="$hostname"

        options=(
          "重建 NixOS-WSL 系统 ($default_host)"
          "仅重建 Home Manager"
          "退出"
        )
        choice=$(select_option "选择部署方式:" "${options[@]}")

        case "$choice" in
          "重建 NixOS-WSL 系统 ($default_host)")
            info "正在重建 NixOS-WSL..."
            sudo nixos-rebuild switch --flake "$FLAKE_DIR#$default_host"
            info "注意: Home Manager 已集成到系统配置中"
            ;;
          "仅重建 Home Manager")
            info "正在重建 Home Manager..."
            home-manager switch --flake "$FLAKE_DIR"
            ;;
          "退出")
            exit 0
            ;;
        esac
      else
        # 非 NixOS WSL (如 Fedora-WSL)
        options=(
          "重建 Home Manager"
          "退出"
        )
        choice=$(select_option "选择部署方式:" "${options[@]}")

        case "$choice" in
          "重建 Home Manager")
            info "正在重建 Home Manager..."
            home-manager switch --flake "$FLAKE_DIR"
            ;;
          "退出")
            exit 0
            ;;
        esac
      fi
      ;;

    nixos)
      # 原生 NixOS
      local hostname=$(hostname)
      local default_host=$(echo "$hosts" | head -n1)
      echo "$hosts" | grep -q "$hostname" && default_host="$hostname"

      options=(
        "重建 NixOS 系统 ($default_host)"
        "仅重建 Home Manager"
        "测试配置 (dry-run)"
        "退出"
      )
      choice=$(select_option "选择部署方式:" "${options[@]}")

      case "$choice" in
        "重建 NixOS 系统 ($default_host)")
          info "正在重建 NixOS..."
          sudo nixos-rebuild switch --flake "$FLAKE_DIR#$default_host"
          ;;
        "仅重建 Home Manager")
          info "正在重建 Home Manager..."
          home-manager switch --flake "$FLAKE_DIR"
          ;;
        "测试配置 (dry-run)")
          info "正在测试配置..."
          sudo nixos-rebuild dry-run --flake "$FLAKE_DIR#$default_host"
          ;;
        "退出")
          exit 0
          ;;
      esac
      ;;

    macos)
      options=(
        "重建 Home Manager (macOS)"
        "退出"
      )
      choice=$(select_option "选择部署方式:" "${options[@]}")

      case "$choice" in
        "重建 Home Manager (macOS)")
          info "正在重建 Home Manager..."
          home-manager switch --flake "$FLAKE_DIR"
          ;;
        "退出")
          exit 0
          ;;
      esac
      ;;

    linux)
      options=(
        "重建 Home Manager"
        "退出"
      )
      choice=$(select_option "选择部署方式:" "${options[@]}")

      case "$choice" in
        "重建 Home Manager")
          info "正在重建 Home Manager..."
          home-manager switch --flake "$FLAKE_DIR"
          ;;
        "退出")
          exit 0
          ;;
      esac
      ;;

    *)
      error "不支持的环境: $env"
      exit 1
      ;;
  esac

  echo ""
  info "部署完成！"
}

# ==============================================================================
# Live USB 安装模式 (disko)
# ==============================================================================

local_install_mode() {
  local HOST="${1:?Usage: $0 --local <host-name>}"

  [[ -d "$FLAKE_DIR/hosts/$HOST" ]] || {
    error "hosts/$HOST 不存在"
    exit 1
  }

  echo "=== 本地安装 (Live USB) ==="
  echo "主机: $HOST"
  echo ""
  warn "此操作将根据 disko 配置格式化磁盘并安装 NixOS！"
  read -rp "确认继续? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 1

  # 设置国内镜像源（解决 rebuild 前网络问题）
  export NIX_CONFIG="substituters = https://nix-community.org/cache https://cache.nixos.org https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"

  sudo nix run github:nix-community/disko/latest -- \
    --mode destroy,format,mount \
    --flake "$FLAKE_DIR#$HOST"
  sudo nixos-install --flake "$FLAKE_DIR#$HOST"

  info "安装完成！重启: reboot"
}

# ==============================================================================
# 远程部署模式 (nixos-anywhere)
# ==============================================================================

remote_deploy_mode() {
  local HOST="${1:?Usage: $0 <host-name> <target-ip>}"
  local TARGET="${2:?Usage: $0 <host-name> <target-ip>}"
  shift 2

  [[ -d "$FLAKE_DIR/hosts/$HOST" ]] || {
    error "hosts/$HOST 不存在"
    exit 1
  }

  echo "=== 远程部署 (nixos-anywhere) ==="
  echo "主机: $HOST → root@$TARGET"
  echo ""

  local EXTRA_ARGS=()
  if needs_facter "$HOST"; then
    local FACTER_PATH="$FLAKE_DIR/hosts/$HOST/facter.json"
    info "物理主机 — 将通过 nixos-facter 自动检测硬件"
    EXTRA_ARGS+=("--generate-hardware-config" "nixos-facter" "$FACTER_PATH")
  fi

  warn "此操作将格式化目标磁盘并安装 NixOS！"
  read -rp "确认继续? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 1

  # 设置国内镜像源（解决 rebuild 前网络问题）
  export NIX_CONFIG="substituters = https://nix-community.org/cache https://cache.nixos.org https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"

  nix run github:nix-community/nixos-anywhere -- \
    --flake "$FLAKE_DIR#$HOST" \
    --target-host "root@$TARGET" \
    "${EXTRA_ARGS[@]}" \
    "$@"

  echo ""
  info "部署完成！"
  [[ ${#EXTRA_ARGS[@]} -gt 0 ]] && echo "[POST] 提交 facter.json: git add hosts/$HOST/facter.json"
}

# ==============================================================================
# 重建模式
# ==============================================================================

rebuild_mode() {
  local HOST="${1:?Usage: $0 rebuild <host-name>}"
  local env=$(detect_environment)

  case "$env" in
    nixos)
      info "正在重建 NixOS: $HOST"
      sudo nixos-rebuild switch --flake "$FLAKE_DIR#$HOST"
      ;;
    wsl|macos|linux)
      info "正在重建 Home Manager: $HOST"
      home-manager switch --flake "$FLAKE_DIR#$HOST"
      ;;
    *)
      error "不支持的环境: $env"
      exit 1
      ;;
  esac
}

# ==============================================================================
# 主入口
# ==============================================================================

# 显示帮助信息
show_help() {
  cat <<EOF
用法: $0 [选项] [参数]

交互式模式:
  $0                      显示交互式菜单

本地安装 (Live USB):
  $0 --local <host>       使用 disko 进行本地安装

远程部署 (nixos-anywhere):
  $0 <host> <ip>          远程部署到指定主机

重建配置:
  $0 rebuild <host>       重建指定主机配置

示例:
  $0                      # 交互式菜单
  $0 --local nixos-desktop
  $0 nixos-vm 192.168.122.100
  $0 rebuild nixos-wsl

可用主机:
$(get_available_hosts | sed 's/^/  /')
EOF
}

# 解析参数
case "${1:-}" in
  ""|-h|--help)
    show_help
    exit 0
    ;;
  --local)
    local_install_mode "$2"
    ;;
  rebuild)
    rebuild_mode "$2"
    ;;
  *)
    # 检查是否是远程部署 (有两个参数)
    if [[ -n "${2:-}" ]]; then
      remote_deploy_mode "$@"
    else
      # 默认进入交互式模式
      interactive_mode
    fi
    ;;
esac
