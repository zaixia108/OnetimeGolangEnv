#!/bin/bash
#
# Bulk VM Deployment Script for Proxmox VE
# This script creates multiple Windows VMs from a template for Golang development
#
# Usage: ./bulk-deploy.sh [options]
#

set -e

# Configuration
TEMPLATE_ID=${TEMPLATE_ID:-100}
START_ID=${START_ID:-101}
VM_COUNT=${VM_COUNT:-5}
NAME_PREFIX=${NAME_PREFIX:-"golang-dev"}
STORAGE=${STORAGE:-"local-lvm"}
BRIDGE=${BRIDGE:-"vmbr0"}
START_VMS=${START_VMS:-"yes"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to print usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Bulk deploy Windows VMs for Golang development from a Proxmox template.

OPTIONS:
    -t, --template ID       Template VM ID (default: 100)
    -s, --start-id ID       Starting VM ID for new VMs (default: 101)
    -c, --count NUMBER      Number of VMs to create (default: 5)
    -n, --name-prefix NAME  VM name prefix (default: golang-dev)
    -S, --storage NAME      Storage name (default: local-lvm)
    -b, --bridge NAME       Network bridge (default: vmbr0)
    -N, --no-start          Don't start VMs after creation
    -h, --help              Show this help message

EXAMPLES:
    # Create 5 VMs from template 100
    $0

    # Create 10 VMs with custom prefix
    $0 -c 10 -n "dev-env"

    # Create VMs but don't start them
    $0 -c 3 -N

ENVIRONMENT VARIABLES:
    TEMPLATE_ID     Template VM ID
    START_ID        Starting VM ID
    VM_COUNT        Number of VMs to create
    NAME_PREFIX     VM name prefix
    STORAGE         Storage name
    BRIDGE          Network bridge
    START_VMS       Start VMs after creation (yes/no)

EOF
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--template)
            TEMPLATE_ID="$2"
            shift 2
            ;;
        -s|--start-id)
            START_ID="$2"
            shift 2
            ;;
        -c|--count)
            VM_COUNT="$2"
            shift 2
            ;;
        -n|--name-prefix)
            NAME_PREFIX="$2"
            shift 2
            ;;
        -S|--storage)
            STORAGE="$2"
            shift 2
            ;;
        -b|--bridge)
            BRIDGE="$2"
            shift 2
            ;;
        -N|--no-start)
            START_VMS="no"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate inputs
if ! [[ "$TEMPLATE_ID" =~ ^[0-9]+$ ]]; then
    print_error "Template ID must be a number"
    exit 1
fi

if ! [[ "$START_ID" =~ ^[0-9]+$ ]]; then
    print_error "Start ID must be a number"
    exit 1
fi

if ! [[ "$VM_COUNT" =~ ^[0-9]+$ ]] || [ "$VM_COUNT" -lt 1 ]; then
    print_error "VM count must be a positive number"
    exit 1
fi

# Check if template exists
if ! qm status "$TEMPLATE_ID" &>/dev/null; then
    print_error "Template VM $TEMPLATE_ID does not exist"
    exit 1
fi

# Check if template is actually a template
if ! qm config "$TEMPLATE_ID" | grep -q "template: 1"; then
    print_warning "VM $TEMPLATE_ID is not marked as a template"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Print configuration
print_info "=== Bulk VM Deployment Configuration ==="
echo "Template ID:      $TEMPLATE_ID"
echo "Starting VM ID:   $START_ID"
echo "Number of VMs:    $VM_COUNT"
echo "Name Prefix:      $NAME_PREFIX"
echo "Storage:          $STORAGE"
echo "Network Bridge:   $BRIDGE"
echo "Auto-start VMs:   $START_VMS"
echo ""

# Confirm before proceeding
read -p "Proceed with deployment? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Deployment cancelled"
    exit 0
fi

# Array to store created VM IDs
CREATED_VMS=()
FAILED_VMS=()

# Create VMs
print_info "Starting VM deployment..."
for i in $(seq 1 "$VM_COUNT"); do
    VM_ID=$((START_ID + i - 1))
    VM_NAME="${NAME_PREFIX}-$(printf "%02d" $i)"
    
    print_info "Creating VM: $VM_NAME (ID: $VM_ID)"
    
    # Check if VM ID already exists
    if qm status "$VM_ID" &>/dev/null; then
        print_warning "VM ID $VM_ID already exists, skipping..."
        FAILED_VMS+=("$VM_ID")
        continue
    fi
    
    # Clone the template
    if qm clone "$TEMPLATE_ID" "$VM_ID" --name "$VM_NAME" --full; then
        print_info "VM $VM_NAME created successfully"
        CREATED_VMS+=("$VM_ID")
        
        # Optional: Customize VM configuration
        # Uncomment and modify as needed
        # qm set "$VM_ID" --memory 16384  # Set RAM to 16GB
        # qm set "$VM_ID" --cores 8       # Set CPU cores to 8
        # qm resize "$VM_ID" scsi0 +50G   # Increase disk by 50GB
        
        # Start VM if requested
        if [ "$START_VMS" = "yes" ]; then
            print_info "Starting VM $VM_NAME..."
            if qm start "$VM_ID"; then
                print_info "VM $VM_NAME started successfully"
            else
                print_warning "Failed to start VM $VM_NAME"
            fi
        fi
        
        # Small delay between VMs to avoid overload
        sleep 2
    else
        print_error "Failed to create VM $VM_NAME"
        FAILED_VMS+=("$VM_ID")
    fi
done

# Summary
echo ""
print_info "=== Deployment Summary ==="
echo "Total VMs requested:  $VM_COUNT"
echo "Successfully created: ${#CREATED_VMS[@]}"
echo "Failed:               ${#FAILED_VMS[@]}"

if [ ${#CREATED_VMS[@]} -gt 0 ]; then
    echo ""
    print_info "Created VM IDs: ${CREATED_VMS[*]}"
fi

if [ ${#FAILED_VMS[@]} -gt 0 ]; then
    echo ""
    print_warning "Failed VM IDs: ${FAILED_VMS[*]}"
fi

echo ""
print_info "Deployment complete!"

# Print next steps
cat << EOF

Next Steps:
-----------
1. Wait for VMs to boot (if auto-started)
2. Connect to each VM via RDP
3. Check setup logs at C:\setup-log.txt
4. Verify environment at C:\EnvironmentInfo.txt

To get IP addresses of created VMs:
$(for vm_id in "${CREATED_VMS[@]}"; do
    echo "  qm guest cmd $vm_id network-get-interfaces"
done)

To stop all created VMs:
$(for vm_id in "${CREATED_VMS[@]}"; do
    echo "  qm stop $vm_id"
done | tr '\n' ' ' && echo)

To remove all created VMs:
$(for vm_id in "${CREATED_VMS[@]}"; do
    echo "  qm destroy $vm_id"
done | tr '\n' ' ' && echo)

EOF
