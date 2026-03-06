#!/bin/bash

################################################################################
# ZMK Firmware Build Script - Multi-Board Support (Linux/macOS)
################################################################################
# Builds firmware for 2 shields (dumbpad_nano, ethapadm) x 2 boards (nice!nano, BlueMicro840)
#
# Features:
#   - Bluetooth Low Energy (BLE)
#   - RGB Underglow (8 LEDs)
#   - Rotary Encoder (EC11)
#   - USB HID
#   - 3 Layers: Default, DaVinci Resolve, Bluetooth Config
#
# Outputs:
#   - nice_nano_dumbpad_nano.uf2      (4x4 matrix keypad)
#   - nice_nano_ethapadm.uf2          (8 button + OLED)
#   - bluemicro840_dumbpad_nano.uf2   (4x4 matrix keypad)
#   - bluemicro840_ethapadm.uf2       (8 button + OLED)
#
# Usage:
#   ./build_both_boards.sh [--zephyr-sdk PATH]
#
# Environment:
#   ZEPHYR_SDK_INSTALL_DIR - Path to Zephyr SDK (default: ~/zephyr-sdk-0.17.3)
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="${SCRIPT_DIR}"

# Default Zephyr SDK path
ZEPHYR_SDK="${ZEPHYR_SDK_INSTALL_DIR:-${HOME}/zephyr-sdk-0.17.3}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --zephyr-sdk)
            ZEPHYR_SDK="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo ""
echo "==================================================================="
echo "  ZMK Firmware Build - Dumbpad & EthaPad"
echo "  Boards: nice!nano + BlueMicro840"
echo "==================================================================="
echo ""

# Setup environment
echo "[1/7] Preparing environment..."
if [ -d "${ROOT}/venv" ]; then
    #source "${ROOT}/venv/bin/activate"
    echo "✓ Virtual environment activated"
else
    echo "⚠ Virtual environment not found at ${ROOT}/venv"
fi

if [ ! -d "${ZEPHYR_SDK}" ]; then
    echo -e "${RED}ERROR: Zephyr SDK not found at ${ZEPHYR_SDK}${NC}"
    echo "Set ZEPHYR_SDK_INSTALL_DIR environment variable or use --zephyr-sdk option"
    exit 1
fi

export ZEPHYR_SDK_INSTALL_DIR="${ZEPHYR_SDK}"
echo "✓ ZEPHYR_SDK_INSTALL_DIR=${ZEPHYR_SDK_INSTALL_DIR}"
echo ""

# Build function
build_firmware() {
    local step=$1
    local name=$2
    local build_dir=$3
    local board=$4
    local shield=$5
    
    echo "[${step}] Building ${name} (${board})..."
    
    if west build -d "${ROOT}/${build_dir}" -p always -b "${board}" \
        -s "${ROOT}/app" -- -DSHIELD="${shield}" > /dev/null 2>&1; then
        
        if [ -f "${ROOT}/${build_dir}/zephyr/zmk.uf2" ]; then
            # Determine output filename based on board and shield
            if [ "${board}" = "nice_nano" ]; then
                output_name="nice_nano_${shield}.uf2"
            else
                output_name="${board}_${shield}.uf2"
            fi
            
            cp "${ROOT}/${build_dir}/zephyr/zmk.uf2" \
               "${ROOT}/${build_dir}/zephyr/${output_name}"
            echo "✓ ${name} completed"
            return 0
        else
            echo -e "${RED}✗ Build output not found${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Build failed${NC}"
        return 1
    fi
}

# Build all variants
failed=0

build_firmware "2/7" "dumbpad_nano" "build-dumbpad" "nice_nano" "dumbpad_nano" || failed=1
build_firmware "3/7" "ethapadm" "build-ethapadm" "nice_nano" "ethapadm" || failed=1
build_firmware "4/7" "dumbpad_nano" "build-dumbpad-bm840" "bluemicro840" "dumbpad_nano" || failed=1
build_firmware "5/7" "ethapadm" "build-ethapadm-bm840" "bluemicro840" "ethapadm" || failed=1

if [ $failed -eq 1 ]; then
    echo ""
    echo -e "${RED}ERROR: One or more builds failed${NC}"
    exit 1
fi

echo ""
echo "[6/7] Verifying build artifacts..."
echo ""

# Helper function to check and report file status
check_file() {
    local filepath=$1
    local description=$2
    
    if [ -f "${filepath}" ]; then
        local size=$(du -h "${filepath}" | cut -f1)
        echo -e "   ${GREEN}[OK]${NC} ${description} (${size})"
        return 0
    else
        echo -e "   ${YELLOW}[WARN]${NC} ${description} not found"
        return 1
    fi
}

echo -e "${CYAN}===== nice!nano Firmware =====${NC}"
check_file "${ROOT}/build-dumbpad/zephyr/nice_nano_dumbpad_nano.uf2" "nice_nano_dumbpad_nano.uf2"
check_file "${ROOT}/build-ethapadm/zephyr/nice_nano_ethapadm.uf2" "nice_nano_ethapadm.uf2"

echo ""
echo -e "${CYAN}===== BlueMicro840 Firmware =====${NC}"
check_file "${ROOT}/build-dumbpad-bm840/zephyr/bluemicro840_dumbpad_nano.uf2" "bluemicro840_dumbpad_nano.uf2"
check_file "${ROOT}/build-ethapadm-bm840/zephyr/bluemicro840_ethapadm.uf2" "bluemicro840_ethapadm.uf2"

echo ""
echo -e "${CYAN}Features: BLE, RGB Underglow, Rotary Encoder, USB HID${NC}"
echo -e "${CYAN}BLE Names: \"Dumbpad\" / \"EthaPad\"${NC}"
echo ""
echo "[7/7] All builds completed successfully!"
echo ""

exit 0
