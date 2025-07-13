#!/bin/bash

# Interactive VM Assistant - Conversational VM Management
# Talk to your VMs like you're talking to an AI assistant

VM_CONFIG_DIR="$HOME/.vm-manager/vms"
VM_CONFIG_FILE="$VM_CONFIG_DIR/vms.conf"
VM_TEMPLATES_DIR="$VM_CONFIG_DIR/templates"
VM_ISOS_DIR="$VM_CONFIG_DIR/../isos"
SESSION_LOG="$VM_CONFIG_DIR/session.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Create directories
mkdir -p "$VM_CONFIG_DIR" "$VM_TEMPLATES_DIR" "$VM_ISOS_DIR"

# Initialize config
if [ ! -f "$VM_CONFIG_FILE" ]; then
    cat > "$VM_CONFIG_FILE" << EOF
# VM Configuration - Auto-managed by VM Assistant
# Format: vm_name:hypervisor:vm_path:memory:cpu_cores:iso_path:status:ip_address
ubuntu:qemu:/Users/$(whoami)/.vm-manager/vms/ubuntu/ubuntu.qcow2:2048:2::configured:
tail:qemu:/Users/$(whoami)/.vm-manager/vms/tail/tail.qcow2:2048:2::configured:
kali:qemu:/Users/$(whoami)/.vm-manager/vms/kali/kali.qcow2:2048:2::configured:
parrot:qemu:/Users/$(whoami)/.vm-manager/vms/parrot/parrot.qcow2:2048:2::configured:
qubes:qemu:/Users/$(whoami)/.vm-manager/vms/qubes/qubes.qcow2:2048:2::configured:
debian:qemu:/Users/$(whoami)/.vm-manager/vms/debian/debian.qcow2:2048:2::configured:
windows:qemu:/Users/$(whoami)/.vm-manager/vms/windows/windows.qcow2:2048:2::configured:
centos:qemu:/Users/$(whoami)/.vm-manager/vms/centos/centos.qcow2:2048:2::configured:
EOF
fi

# Detect platform for virtualization
detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Get appropriate acceleration for platform
get_acceleration() {
    local platform=$(detect_platform)
    case $platform in
        "macos")
            # Try different HVF syntax options
            if qemu-system-x86_64 -accel help 2>/dev/null | grep -q hvf; then
                echo "-accel hvf"
            elif qemu-system-x86_64 -machine help 2>/dev/null | grep -q hvf; then
                echo "-machine accel=hvf"
            else
                # Fallback - no acceleration
                echo ""
            fi
            ;;
        "linux")
            # Check if KVM is available
            if [[ -e /dev/kvm ]]; then
                echo "-enable-kvm"
            else
                echo ""
            fi
            ;;
        *)
            echo ""
            ;;
    esac
}

# Logging function
log_interaction() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$SESSION_LOG"
}

# AI-like greeting
show_greeting() {
    clear
    echo -e "${BOLD}${BLUE}🤖 VM Assistant v2.0${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Hello! I'm your VM Assistant. I can help you manage virtual machines"
    echo -e "through natural conversation. Just tell me what you want to do!${NC}"
    echo ""
    echo -e "${YELLOW}Examples of what you can ask me:${NC}"
    echo -e "  • ${BLUE}\"Start my Ubuntu VM\"${NC}"
    echo -e "  • ${BLUE}\"Create a new VM for testing\"${NC}"
    echo -e "  • ${BLUE}\"Show me all my VMs\"${NC}"
    echo -e "  • ${BLUE}\"Install Ubuntu on a new VM\"${NC}"
    echo -e "  • ${BLUE}\"Stop all running VMs\"${NC}"
    echo -e "  • ${BLUE}\"Clone my development VM\"${NC}"
    echo ""
    echo -e "${CYAN}Type 'help' for more examples, or 'exit' to quit.${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Natural language processing (basic pattern matching)
process_command() {
    local input="$1"
    local input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    
    log_interaction "USER: $input"
    
    # Start VM commands
    if [[ "$input_lower" =~ (start|run|launch|boot).*(ubuntu|debian|windows|centos|kali|parrot|tails|qubes|vm) ]]; then
        if [[ "$input_lower" =~ ubuntu ]]; then
            ai_response "I'll start your Ubuntu VM for you!"
            start_vm_ai "ubuntu"
        elif [[ "$input_lower" =~ debian ]]; then
            ai_response "Starting Debian VM..."
            start_vm_ai "debian"
        elif [[ "$input_lower" =~ windows ]]; then
            ai_response "Launching Windows VM..."
            start_vm_ai "windows"
        elif [[ "$input_lower" =~ kali ]]; then
            ai_response "Starting Kali Linux VM..."
            start_vm_ai "kali"
        elif [[ "$input_lower" =~ parrot ]]; then
            ai_response "Launching Parrot Security VM..."
            start_vm_ai "parrot"
        elif [[ "$input_lower" =~ tails ]]; then
            ai_response "Starting Tails VM..."
            start_vm_ai "tails"
        elif [[ "$input_lower" =~ qubes ]]; then
            ai_response "Launching Qubes OS VM..."
            start_vm_ai "qubes"
        else
            ai_response "Which VM would you like me to start?"
            list_vms_ai
        fi
    
    # Stop VM commands
    elif [[ "$input_lower" =~ (stop|shutdown|halt|kill).*(ubuntu|debian|windows|kali|parrot|tails|qubes|all|vm) ]]; then
        if [[ "$input_lower" =~ ubuntu ]]; then
            ai_response "Stopping Ubuntu VM..."
            stop_vm_ai "ubuntu"
        elif [[ "$input_lower" =~ debian ]]; then
            ai_response "Stopping Debian VM..."
            stop_vm_ai "debian"
        elif [[ "$input_lower" =~ windows ]]; then
            ai_response "Stopping Windows VM..."
            stop_vm_ai "windows"
        elif [[ "$input_lower" =~ kali ]]; then
            ai_response "Stopping Kali Linux VM..."
            stop_vm_ai "kali"
        elif [[ "$input_lower" =~ parrot ]]; then
            ai_response "Stopping Parrot Security VM..."
            stop_vm_ai "parrot"
        elif [[ "$input_lower" =~ tails ]]; then
            ai_response "Stopping Tails VM..."
            stop_vm_ai "tails"
        elif [[ "$input_lower" =~ qubes ]]; then
            ai_response "Stopping Qubes OS VM..."
            stop_vm_ai "qubes"
        elif [[ "$input_lower" =~ all ]]; then
            ai_response "I'll stop all running VMs for you."
            stop_all_vms_ai
        else
            ai_response "Which VM should I stop?"
            list_running_vms_ai
        fi
    
    # List/Show commands
    elif [[ "$input_lower" =~ (list|show|display).*(vm|machine|all) ]] || [[ "$input_lower" =~ "what.*vm" ]]; then
        ai_response "Here are all your virtual machines:"
        list_vms_ai
    
    # Status commands
    elif [[ "$input_lower" =~ (status|running|check).*(vm|machine) ]]; then
        ai_response "Let me check the status of your VMs..."
        check_all_status_ai
    
    # Create/Install commands
    elif [[ "$input_lower" =~ (create|install|new|make).*(ubuntu|debian|windows|kali|parrot|tails|qubes|vm) ]]; then
        if [[ "$input_lower" =~ ubuntu ]]; then
            ai_response "I'll help you create a new Ubuntu VM!"
            create_ubuntu_vm_ai
        elif [[ "$input_lower" =~ debian ]]; then
            ai_response "Creating a Debian VM for you..."
            create_debian_vm_ai
        elif [[ "$input_lower" =~ kali ]]; then
            ai_response "I'll create a Kali Linux VM for you!"
            create_kali_vm_ai
        elif [[ "$input_lower" =~ parrot ]]; then
            ai_response "Setting up a Parrot Security VM..."
            create_parrot_vm_ai
        elif [[ "$input_lower" =~ tails ]]; then
            ai_response "Creating a Tails VM for you..."
            create_tails_vm_ai
        elif [[ "$input_lower" =~ qubes ]]; then
            ai_response "Setting up a Qubes OS VM..."
            create_qubes_vm_ai
        else
            ai_response "What type of VM would you like me to create?"
            show_vm_types_ai
        fi
    
    # Clone commands
    elif [[ "$input_lower" =~ (clone|copy|duplicate).*(vm|machine) ]]; then
        ai_response "I can help you clone a VM. Which one would you like to clone?"
        clone_vm_ai
    
    # Help commands
    elif [[ "$input_lower" =~ (help|what|how|can) ]]; then
        show_help_ai
    
    # System info
    elif [[ "$input_lower" =~ (system|info|hardware|specs) ]]; then
        ai_response "Let me check your system information..."
        show_system_info_ai
    
    # VM Command Builder commands
    elif [[ "$input_lower" =~ (build|help.*build|command.*build|help.*command) ]]; then
        ai_response "I'll help you build a command for your VM!"
        build_vm_command_ai "$input"
    
    # Show available VM commands
    elif [[ "$input_lower" =~ (show.*command|what.*command|list.*command|vm.*command) ]]; then
        ai_response "Here are some useful commands you can run in your VMs:"
        show_vm_commands_ai
    
    # Execute command on VM
    elif [[ "$input_lower" =~ (run.*on|execute.*on|command.*on).*(vm|ubuntu|debian|kali|parrot|tails|qubes) ]]; then
        ai_response "I'll help you execute a command on your VM!"
        execute_vm_command_ai "$input"
    
    # Boot troubleshooting commands
    elif [[ "$input_lower" =~ (no.*bootable|boot.*error|boot.*fail|no.*boot|bootable.*device|vm.*boot|troubleshoot.*boot) ]]; then
        ai_response "I see you're having boot issues! Let me help troubleshoot that."
        troubleshoot_vm_boot_ai
    
    # Exit commands
    elif [[ "$input_lower" =~ (exit|quit|bye|goodbye) ]]; then
        ai_response "Goodbye! Thanks for using VM Assistant. Have a great day! 👋"
        log_interaction "ASSISTANT: Session ended"
        exit 0
    
    # Unknown command
    else
        ai_response "I'm not sure what you want me to do. Here are some things I can help with:"
        show_help_ai
    fi
}

# AI-like response function
ai_response() {
    local message="$1"
    echo -e "${BOLD}${GREEN}🤖 Assistant:${NC} $message"
    log_interaction "ASSISTANT: $message"
}

# Enhanced VM operations with AI responses
start_vm_ai() {
    local vm_name="$1"
    local config=$(get_vm_config "$vm_name")
    
    if [ -z "$config" ]; then
        ai_response "I couldn't find a VM named '$vm_name'. Let me show you what's available:"
        list_vms_ai
        return 1
    fi
    
    ai_response "Starting $vm_name VM... This might take a moment."
    
    IFS=':' read -r name hypervisor vm_path memory cpu_cores iso_path status ip <<< "$config"
    
    case $hypervisor in
        "qemu")
            local platform=$(detect_platform)
            local acceleration=$(get_acceleration)
            
            ai_response "Using QEMU hypervisor with ${memory}MB RAM and $cpu_cores CPU cores on $platform."
            
            if [ ! -f "$vm_path" ]; then
                ai_response "VM disk not found. Let me create it for you..."
                create_vm_disk "$vm_name" "$vm_path"
            fi
            
            # Build QEMU command with platform-appropriate acceleration
            local qemu_cmd="qemu-system-x86_64 -hda \"$vm_path\" -m \"$memory\" -smp \"$cpu_cores\""
            
            # Add acceleration if available
            if [ -n "$acceleration" ]; then
                qemu_cmd="$qemu_cmd $acceleration"
                ai_response "Using hardware acceleration: $acceleration"
            else
                ai_response "Running without hardware acceleration (may be slower)"
            fi
            
            # Add display option based on platform
            if [[ "$platform" == "macos" ]]; then
                qemu_cmd="$qemu_cmd -display cocoa"
            else
                qemu_cmd="$qemu_cmd -display gtk"
            fi
            
            # Add network
            qemu_cmd="$qemu_cmd -netdev user,id=net0 -device rtl8139,netdev=net0"
            
            # Add ISO if available
            if [ -n "$iso_path" ] && [ -f "$iso_path" ]; then
                qemu_cmd="$qemu_cmd -cdrom \"$iso_path\""
                ai_response "Mounting ISO: $(basename "$iso_path")"
            else
                # Check if this is a new VM without an OS installed
                if [ ! -s "$vm_path" ] || [ $(stat -f%z "$vm_path" 2>/dev/null || stat -c%s "$vm_path" 2>/dev/null) -lt 1000000 ]; then
                    ai_response "⚠️  Warning: No ISO attached and VM disk appears empty."
                    ai_response "This may result in 'no bootable device' error."
                    echo -e "${YELLOW}Would you like me to download the Ubuntu ISO first? (y/n):${NC}"
                    read -r download_choice
                    if [[ "$download_choice" =~ ^[Yy]$ ]]; then
                        download_ubuntu_iso_ai "$vm_name"
                        return 0
                    fi
                fi
            fi
            
            ai_response "Executing: $qemu_cmd"
            eval "$qemu_cmd &"
            
            # Wait a moment and check if QEMU started successfully
            sleep 3
            if pgrep -f "$vm_path" >/dev/null; then
                ai_response "✅ $vm_name is now running! The VM window should appear shortly."
            else
                ai_response "❌ Failed to start $vm_name. Check the command output above for errors."
            fi
            ;;
        "virtualbox")
            ai_response "Using VirtualBox hypervisor..."
            if vboxmanage startvm "$vm_name" --type gui &>/dev/null; then
                ai_response "✅ $vm_name started successfully!"
            else
                ai_response "❌ Failed to start $vm_name. The VM might not exist in VirtualBox."
            fi
            ;;
        *)
            ai_response "❌ Unsupported hypervisor: $hypervisor"
            ;;
    esac
}

stop_vm_ai() {
    local vm_name="$1"
    local config=$(get_vm_config "$vm_name")
    
    if [ -z "$config" ]; then
        ai_response "I couldn't find a VM named '$vm_name'."
        return 1
    fi
    
    ai_response "Stopping $vm_name VM gracefully..."
    
    IFS=':' read -r name hypervisor vm_path memory cpu_cores iso_path status ip <<< "$config"
    
    case $hypervisor in
        "qemu")
            if pkill -f "$vm_path"; then
                ai_response "✅ $vm_name has been stopped."
            else
                ai_response "⚠️  $vm_name might not be running, or it stopped on its own."
            fi
            ;;
        "virtualbox")
            if vboxmanage controlvm "$vm_name" acpipowerbutton &>/dev/null; then
                ai_response "✅ Sent shutdown signal to $vm_name."
            else
                ai_response "⚠️  Couldn't stop $vm_name. It might not be running."
            fi
            ;;
    esac
}

stop_all_vms_ai() {
    ai_response "Stopping all running VMs..."
    
    while IFS=':' read -r name hypervisor vm_path memory cpu_cores iso_path status ip; do
        if [[ ! "$name" =~ ^# ]] && [ -n "$name" ]; then
            case $hypervisor in
                "qemu")
                    if pgrep -f "$vm_path" >/dev/null; then
                        ai_response "Stopping $name..."
                        pkill -f "$vm_path"
                    fi
                    ;;
                "virtualbox")
                    if vboxmanage showvminfo "$name" --machinereadable 2>/dev/null | grep -q 'VMState="running"'; then
                        ai_response "Stopping $name..."
                        vboxmanage controlvm "$name" acpipowerbutton &>/dev/null
                    fi
                    ;;
            esac
        fi
    done < "$VM_CONFIG_FILE"
    
    ai_response "✅ All VMs have been stopped."
}

list_vms_ai() {
    echo -e "${BLUE}📋 Your Virtual Machines:${NC}"
    echo ""
    
    if [ ! -s "$VM_CONFIG_FILE" ] || ! grep -q "^[^#]" "$VM_CONFIG_FILE"; then
        ai_response "You don't have any VMs configured yet. Would you like me to create one?"
        return
    fi
    
    local count=0
    while IFS=':' read -r name hypervisor vm_path memory cpu_cores iso_path status ip; do
        if [[ ! "$name" =~ ^# ]] && [ -n "$name" ]; then
            ((count++))
            
            # Check if VM is running
            local running_status="⏹️  Stopped"
            case $hypervisor in
                "qemu")
                    if pgrep -f "$vm_path" >/dev/null; then
                        running_status="▶️  Running"
                    fi
                    ;;
                "virtualbox")
                    if vboxmanage showvminfo "$name" --machinereadable 2>/dev/null | grep -q 'VMState="running"'; then
                        running_status="▶️  Running"
                    fi
                    ;;
            esac
            
            echo -e "  ${BOLD}$count. $name${NC} $running_status"
            echo -e "     💾 Memory: ${memory}MB | 🖥️  CPU: $cpu_cores cores"
            echo -e "     ⚙️  Engine: $hypervisor"
            echo ""
        fi
    done < "$VM_CONFIG_FILE"
    
    if [ $count -eq 0 ]; then
        ai_response "No VMs found. Would you like me to create one for you?"
    fi
}

list_running_vms_ai() {
    echo -e "${BLUE}🔄 Running VMs:${NC}"
    echo ""
    
    local running_count=0
    while IFS=':' read -r name hypervisor vm_path memory cpu_cores iso_path status ip; do
        if [[ ! "$name" =~ ^# ]] && [ -n "$name" ]; then
            local is_running=false
            case $hypervisor in
                "qemu")
                    if pgrep -f "$vm_path" >/dev/null; then
                        is_running=true
                    fi
                    ;;
                "virtualbox")
                    if vboxmanage showvminfo "$name" --machinereadable 2>/dev/null | grep -q 'VMState="running"'; then
                        is_running=true
                    fi
                    ;;
            esac
            
            if [ "$is_running" = true ]; then
                ((running_count++))
                echo -e "  ${GREEN}▶️  $name${NC} (${hypervisor})"
            fi
        fi
    done < "$VM_CONFIG_FILE"
    
    if [ $running_count -eq 0 ]; then
        ai_response "No VMs are currently running."
    fi
}

create_ubuntu_vm_ai() {
    ai_response "Great! I'll create a new Ubuntu VM for you. Let me ask a few questions:"
    
    echo -e "${YELLOW}What should I name this VM? (default: ubuntu):${NC}"
    read -r vm_name
    vm_name=${vm_name:-ubuntu}
    
    if get_vm_config "$vm_name" >/dev/null; then
        ai_response "A VM named '$vm_name' already exists. Please choose a different name."
        return 1
    fi
    
    echo -e "${YELLOW}How much memory (MB)? (default: 2048):${NC}"
    read -r memory
    memory=${memory:-2048}
    
    echo -e "${YELLOW}How many CPU cores? (default: 2):${NC}"
    read -r cpu_cores
    cpu_cores=${cpu_cores:-2}
    
    ai_response "Perfect! I'm creating your Ubuntu VM with:"
    echo -e "  • Name: $vm_name"
    echo -e "  • Memory: ${memory}MB"
    echo -e "  • CPU: $cpu_cores cores"
    echo -e "  • Storage: 20GB"
    
    # Create VM directory and disk
    local vm_dir="$VM_CONFIG_DIR/vms/$vm_name"
    local disk_path="$vm_dir/$vm_name.qcow2"
    
    mkdir -p "$vm_dir"
    
    ai_response "Creating virtual disk..."
    if command -v qemu-img >/dev/null; then
        qemu-img create -f qcow2 "$disk_path" 20G
        ai_response "✅ Virtual disk created successfully!"
    else
        ai_response "⚠️  QEMU not found. Please install it first: brew install qemu"
        return 1
    fi
    
    # Add to config
    echo "$vm_name:qemu:$disk_path:$memory:$cpu_cores::configured:" >> "$VM_CONFIG_FILE"
    
    ai_response "✅ VM '$vm_name' created successfully!"
    
    echo -e "${YELLOW}Would you like me to download Ubuntu ISO and start the installation? (y/n):${NC}"
    read -r download_iso
    
    if [[ "$download_iso" =~ ^[Yy]$ ]]; then
        download_ubuntu_iso_ai "$vm_name"
    else
        ai_response "VM is ready! You can start it anytime by saying 'start $vm_name'"
    fi
}

create_debian_vm_ai() {
    ai_response "I'll create a Debian VM for you!"
    # Similar to Ubuntu but with Debian-specific settings
    create_ubuntu_vm_ai  # For now, use same logic
}

create_kali_vm_ai() {
    ai_response "Great! I'll create a new Kali Linux VM for you. Let me ask a few questions:"
    
    echo -e "${YELLOW}What should I name this VM? (default: kali):${NC}"
    read -r vm_name
    vm_name=${vm_name:-kali}
    
    if get_vm_config "$vm_name" >/dev/null; then
        ai_response "A VM named '$vm_name' already exists. Please choose a different name."
        return 1
    fi
    
    echo -e "${YELLOW}How much memory (MB)? (default: 4096):${NC}"
    read -r memory
    memory=${memory:-4096}
    
    echo -e "${YELLOW}How many CPU cores? (default: 2):${NC}"
    read -r cpu_cores
    cpu_cores=${cpu_cores:-2}
    
    ai_response "Perfect! I'm creating your Kali Linux VM with:"
    echo -e "  • Name: $vm_name"
    echo -e "  • Memory: ${memory}MB"
    echo -e "  • CPU: $cpu_cores cores"
    echo -e "  • Storage: 25GB"
    
    # Create VM directory and disk
    local vm_dir="$VM_CONFIG_DIR/vms/$vm_name"
    local disk_path="$vm_dir/$vm_name.qcow2"
    
    mkdir -p "$vm_dir"
    
    ai_response "Creating virtual disk..."
    if command -v qemu-img >/dev/null; then
        qemu-img create -f qcow2 "$disk_path" 25G
        ai_response "✅ Virtual disk created successfully!"
    else
        ai_response "⚠️  QEMU not found. Please install it first: brew install qemu"
        return 1
    fi
    
    # Add to config
    echo "$vm_name:qemu:$disk_path:$memory:$cpu_cores::configured:" >> "$VM_CONFIG_FILE"
    
    ai_response "✅ VM '$vm_name' created successfully!"
    
    ai_response "🚀 Now downloading Kali Linux ISO and starting installation..."
    download_kali_iso_ai "$vm_name"
}

create_parrot_vm_ai() {
    ai_response "Great! I'll create a new Parrot Security VM for you. Let me ask a few questions:"
    
    echo -e "${YELLOW}What should I name this VM? (default: parrot):${NC}"
    read -r vm_name
    vm_name=${vm_name:-parrot}
    
    if get_vm_config "$vm_name" >/dev/null; then
        ai_response "A VM named '$vm_name' already exists. Please choose a different name."
        return 1
    fi
    
    echo -e "${YELLOW}How much memory (MB)? (default: 4096):${NC}"
    read -r memory
    memory=${memory:-4096}
    
    echo -e "${YELLOW}How many CPU cores? (default: 2):${NC}"
    read -r cpu_cores
    cpu_cores=${cpu_cores:-2}
    
    ai_response "Perfect! I'm creating your Parrot Security VM with:"
    echo -e "  • Name: $vm_name"
    echo -e "  • Memory: ${memory}MB"
    echo -e "  • CPU: $cpu_cores cores"
    echo -e "  • Storage: 25GB"
    
    # Create VM directory and disk
    local vm_dir="$VM_CONFIG_DIR/vms/$vm_name"
    local disk_path="$vm_dir/$vm_name.qcow2"
    
    mkdir -p "$vm_dir"
    
    ai_response "Creating virtual disk..."
    if command -v qemu-img >/dev/null; then
        qemu-img create -f qcow2 "$disk_path" 25G
        ai_response "✅ Virtual disk created successfully!"
    else
        ai_response "⚠️  QEMU not found. Please install it first: brew install qemu"
        return 1
    fi
    
    # Add to config
    echo "$vm_name:qemu:$disk_path:$memory:$cpu_cores::configured:" >> "$VM_CONFIG_FILE"
    
    ai_response "✅ VM '$vm_name' created successfully!"
    
    ai_response "🚀 Now downloading Parrot Security ISO and starting installation..."
    download_parrot_iso_ai "$vm_name"
}

create_tails_vm_ai() {
    ai_response "Great! I'll create a new Tails VM for you. Let me ask a few questions:"
    
    echo -e "${YELLOW}What should I name this VM? (default: tails):${NC}"
    read -r vm_name
    vm_name=${vm_name:-tails}
    
    if get_vm_config "$vm_name" >/dev/null; then
        ai_response "A VM named '$vm_name' already exists. Please choose a different name."
        return 1
    fi
    
    echo -e "${YELLOW}How much memory (MB)? (default: 2048):${NC}"
    read -r memory
    memory=${memory:-2048}
    
    echo -e "${YELLOW}How many CPU cores? (default: 2):${NC}"
    read -r cpu_cores
    cpu_cores=${cpu_cores:-2}
    
    ai_response "Perfect! I'm creating your Tails VM with:"
    echo -e "  • Name: $vm_name"
    echo -e "  • Memory: ${memory}MB"
    echo -e "  • CPU: $cpu_cores cores"
    echo -e "  • Storage: 8GB (Tails is typically run as a live system)"
    
    # Create VM directory and disk
    local vm_dir="$VM_CONFIG_DIR/vms/$vm_name"
    local disk_path="$vm_dir/$vm_name.qcow2"
    
    mkdir -p "$vm_dir"
    
    ai_response "Creating virtual disk..."
    if command -v qemu-img >/dev/null; then
        qemu-img create -f qcow2 "$disk_path" 8G
        ai_response "✅ Virtual disk created successfully!"
    else
        ai_response "⚠️  QEMU not found. Please install it first: brew install qemu"
        return 1
    fi
    
    # Add to config
    echo "$vm_name:qemu:$disk_path:$memory:$cpu_cores::configured:" >> "$VM_CONFIG_FILE"
    
    ai_response "✅ VM '$vm_name' created successfully!"
    
    ai_response "🚀 Now downloading Tails ISO and starting installation..."
    download_tails_iso_ai "$vm_name"
}

create_qubes_vm_ai() {
    ai_response "Great! I'll create a new Qubes OS VM for you. Let me ask a few questions:"
    
    echo -e "${YELLOW}What should I name this VM? (default: qubes):${NC}"
    read -r vm_name
    vm_name=${vm_name:-qubes}
    
    if get_vm_config "$vm_name" >/dev/null; then
        ai_response "A VM named '$vm_name' already exists. Please choose a different name."
        return 1
    fi
    
    echo -e "${YELLOW}How much memory (MB)? (default: 8192):${NC}"
    read -r memory
    memory=${memory:-8192}
    
    echo -e "${YELLOW}How many CPU cores? (default: 4):${NC}"
    read -r cpu_cores
    cpu_cores=${cpu_cores:-4}
    
    ai_response "Perfect! I'm creating your Qubes OS VM with:"
    echo -e "  • Name: $vm_name"
    echo -e "  • Memory: ${memory}MB"
    echo -e "  • CPU: $cpu_cores cores"
    echo -e "  • Storage: 50GB (Qubes requires substantial storage)"
    
    # Create VM directory and disk
    local vm_dir="$VM_CONFIG_DIR/vms/$vm_name"
    local disk_path="$vm_dir/$vm_name.qcow2"
    
    mkdir -p "$vm_dir"
    
    ai_response "Creating virtual disk..."
    if command -v qemu-img >/dev/null; then
        qemu-img create -f qcow2 "$disk_path" 50G
        ai_response "✅ Virtual disk created successfully!"
    else
        ai_response "⚠️  QEMU not found. Please install it first: brew install qemu"
        return 1
    fi
    
    # Add to config
    echo "$vm_name:qemu:$disk_path:$memory:$cpu_cores::configured:" >> "$VM_CONFIG_FILE"
    
    ai_response "✅ VM '$vm_name' created successfully!"
    
    ai_response "🚀 Now downloading Qubes OS ISO and starting installation..."
    download_qubes_iso_ai "$vm_name"
}

show_vm_types_ai() {
    ai_response "I can help you create these types of VMs:"
    echo ""
    echo -e "${BLUE}Available VM Types:${NC}"
    echo -e "  • ${GREEN}Ubuntu${NC} - Popular Linux distribution"
    echo -e "  • ${GREEN}Debian${NC} - Stable Linux distribution"
    echo -e "  • ${GREEN}Kali Linux${NC} - Penetration testing and security auditing"
    echo -e "  • ${GREEN}Parrot Security${NC} - Security, privacy and development platform"
    echo -e "  • ${GREEN}Tails${NC} - Privacy-focused live operating system"
    echo -e "  • ${GREEN}Qubes OS${NC} - Security-focused operating system"
    echo -e "  • ${GREEN}Windows${NC} - Microsoft Windows (you'll need an ISO)"
    echo -e "  • ${GREEN}CentOS${NC} - Enterprise Linux distribution"
    echo ""
    echo -e "${YELLOW}Just tell me which one you'd like, for example: 'Create Kali VM' or 'Create Ubuntu VM'${NC}"
}

clone_vm_ai() {
    ai_response "VM cloning feature coming soon! For now, you can create a new VM with similar settings."
}

download_ubuntu_iso_ai() {
    local vm_name="$1"
    local iso_path="$VM_ISOS_DIR/ubuntu-22.04.3-desktop-amd64.iso"
    
    ai_response "I'll download the Ubuntu 22.04 ISO for you. This might take a while..."
    
    if [ ! -f "$iso_path" ]; then
        ai_response "Downloading Ubuntu ISO... ⏳"
        if command -v wget >/dev/null; then
            wget -O "$iso_path" "https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso"
        elif command -v curl >/dev/null; then
            curl -o "$iso_path" "https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso"
        else
            ai_response "❌ Neither wget nor curl found. Please install one of them."
            return 1
        fi
    fi
    
    # Update VM config with ISO path
    sed -i '' "s|^$vm_name:qemu:\([^:]*\):\([^:]*\):\([^:]*\):[^:]*:|$vm_name:qemu:\1:\2:\3:$iso_path:|" "$VM_CONFIG_FILE"
    
    ai_response "✅ Ubuntu ISO ready! Starting VM with installation media..."
    start_vm_ai "$vm_name"
}

download_kali_iso_ai() {
    local vm_name="$1"
    local iso_path="$VM_ISOS_DIR/kali-linux-2024.1-installer-amd64.iso"
    
    ai_response "I'll download the Kali Linux 2024.1 ISO for you. This might take a while..."
    
    if [ ! -f "$iso_path" ]; then
        ai_response "Downloading Kali Linux ISO... ⏳"
        if command -v wget >/dev/null; then
            wget -O "$iso_path" "https://cdimage.kali.org/kali-2024.1/kali-linux-2024.1-installer-amd64.iso"
        elif command -v curl >/dev/null; then
            curl -L -o "$iso_path" "https://cdimage.kali.org/kali-2024.1/kali-linux-2024.1-installer-amd64.iso"
        else
            ai_response "❌ Neither wget nor curl found. Please install one of them."
            return 1
        fi
    fi
    
    # Update VM config with ISO path
    sed -i '' "s|^$vm_name:qemu:\([^:]*\):\([^:]*\):\([^:]*\):[^:]*:|$vm_name:qemu:\1:\2:\3:$iso_path:|" "$VM_CONFIG_FILE"
    
    ai_response "✅ Kali Linux ISO ready! Starting VM with installation media..."
    start_vm_ai "$vm_name"
}

download_parrot_iso_ai() {
    local vm_name="$1"
    local iso_path="$VM_ISOS_DIR/Parrot-security-5.3_amd64.iso"
    
    ai_response "I'll download the Parrot Security 5.3 ISO for you. This might take a while..."
    
    if [ ! -f "$iso_path" ]; then
        ai_response "Downloading Parrot Security ISO... ⏳"
        if command -v wget >/dev/null; then
            wget -O "$iso_path" "https://deb.parrot.sh/parrot/iso/5.3/Parrot-security-5.3_amd64.iso"
        elif command -v curl >/dev/null; then
            curl -L -o "$iso_path" "https://deb.parrot.sh/parrot/iso/5.3/Parrot-security-5.3_amd64.iso"
        else
            ai_response "❌ Neither wget nor curl found. Please install one of them."
            return 1
        fi
    fi
    
    # Update VM config with ISO path
    sed -i '' "s|^$vm_name:qemu:\([^:]*\):\([^:]*\):\([^:]*\):[^:]*:|$vm_name:qemu:\1:\2:\3:$iso_path:|" "$VM_CONFIG_FILE"
    
    ai_response "✅ Parrot Security ISO ready! Starting VM with installation media..."
    start_vm_ai "$vm_name"
}

download_tails_iso_ai() {
    local vm_name="$1"
    local iso_path="$VM_ISOS_DIR/tails-amd64-5.19.1.iso"
    
    ai_response "I'll download the Tails 5.19.1 ISO for you. This might take a while..."
    
    if [ ! -f "$iso_path" ]; then
        ai_response "Downloading Tails ISO... ⏳"
        if command -v wget >/dev/null; then
            wget -O "$iso_path" "https://download.tails.net/tails/stable/tails-amd64-5.19.1/tails-amd64-5.19.1.iso"
        elif command -v curl >/dev/null; then
            curl -L -o "$iso_path" "https://download.tails.net/tails/stable/tails-amd64-5.19.1/tails-amd64-5.19.1.iso"
        else
            ai_response "❌ Neither wget nor curl found. Please install one of them."
            return 1
        fi
    fi
    
    # Update VM config with ISO path
    sed -i '' "s|^$vm_name:qemu:\([^:]*\):\([^:]*\):\([^:]*\):[^:]*:|$vm_name:qemu:\1:\2:\3:$iso_path:|" "$VM_CONFIG_FILE"
    
    ai_response "✅ Tails ISO ready! Starting VM with installation media..."
    start_vm_ai "$vm_name"
}

download_qubes_iso_ai() {
    local vm_name="$1"
    local iso_path="$VM_ISOS_DIR/Qubes-R4.2.0-x86_64.iso"
    
    ai_response "I'll download the Qubes OS R4.2.0 ISO for you. This might take a while..."
    
    if [ ! -f "$iso_path" ]; then
        ai_response "Downloading Qubes OS ISO... ⏳"
        if command -v wget >/dev/null; then
            wget -O "$iso_path" "https://ftp.qubes-os.org/iso/Qubes-R4.2.0-x86_64.iso"
        elif command -v curl >/dev/null; then
            curl -L -o "$iso_path" "https://ftp.qubes-os.org/iso/Qubes-R4.2.0-x86_64.iso"
        else
            ai_response "❌ Neither wget nor curl found. Please install one of them."
            return 1
        fi
    fi
    
    # Update VM config with ISO path
    sed -i '' "s|^$vm_name:qemu:\([^:]*\):\([^:]*\):\([^:]*\):[^:]*:|$vm_name:qemu:\1:\2:\3:$iso_path:|" "$VM_CONFIG_FILE"
    
    ai_response "✅ Qubes OS ISO ready! Starting VM with installation media..."
    start_vm_ai "$vm_name"
}

show_help_ai() {
    ai_response "Here's what I can help you with:"
    echo ""
    echo -e "${BLUE}🚀 VM Management:${NC}"
    echo -e "  • ${GREEN}\"Start my Ubuntu VM\"${NC}"
    echo -e "  • ${GREEN}\"Stop all VMs\"${NC}"
    echo -e "  • ${GREEN}\"Show me my VMs\"${NC}"
    echo -e "  • ${GREEN}\"Check VM status\"${NC}"
    echo ""
    echo -e "${BLUE}🛠️  VM Creation:${NC}"
    echo -e "  • ${GREEN}\"Create a new Ubuntu VM\"${NC}"
    echo -e "  • ${GREEN}\"Install Debian\"${NC}"
    echo -e "  • ${GREEN}\"Make a Windows VM\"${NC}"
    echo -e "  • ${GREEN}\"Create Kali VM\"${NC}"
    echo -e "  • ${GREEN}\"Create Parrot VM\"${NC}"
    echo -e "  • ${GREEN}\"Create Tails VM\"${NC}"
    echo -e "  • ${GREEN}\"Create Qubes VM\"${NC}"
    echo ""
    echo -e "${BLUE}💻 VM Command Builder:${NC}"
    echo -e "  • ${GREEN}\"Help me build a command to...\"${NC}"
    echo -e "  • ${GREEN}\"Show VM commands\"${NC}"
    echo -e "  • ${GREEN}\"What commands can I run?\"${NC}"
    echo -e "  • ${GREEN}\"Build command for network scan\"${NC}"
    echo -e "  • ${GREEN}\"Help with file operations\"${NC}"
    echo ""
    echo -e "${BLUE}📋 Other Commands:${NC}"
    echo -e "  • ${GREEN}\"Clone my VM\"${NC}"
    echo -e "  • ${GREEN}\"System information\"${NC}"
    echo -e "  • ${GREEN}\"Help\"${NC}"
    echo -e "  • ${GREEN}\"Exit\"${NC}"
    echo ""
}

check_all_status_ai() {
    ai_response "Checking all VM statuses..."
    echo ""
    
    while IFS=':' read -r name hypervisor vm_path memory cpu_cores iso_path status ip; do
        if [[ ! "$name" =~ ^# ]] && [ -n "$name" ]; then
            case $hypervisor in
                "qemu")
                    if pgrep -f "$vm_path" >/dev/null; then
                        echo -e "  ${GREEN}✅ $name: Running${NC}"
                    else
                        echo -e "  ${YELLOW}⏹️  $name: Stopped${NC}"
                    fi
                    ;;
                "virtualbox")
                    local vbox_status=$(vboxmanage showvminfo "$name" --machinereadable 2>/dev/null | grep "VMState=" | cut -d'"' -f2)
                    if [ "$vbox_status" = "running" ]; then
                        echo -e "  ${GREEN}✅ $name: Running${NC}"
                    else
                        echo -e "  ${YELLOW}⏹️  $name: $vbox_status${NC}"
                    fi
                    ;;
            esac
        fi
    done < "$VM_CONFIG_FILE"
}

show_system_info_ai() {
    local platform=$(detect_platform)
    local acceleration=$(get_acceleration)
    
    ai_response "Here's your system information:"
    echo ""
    echo -e "${BLUE}💻 System:${NC} $(uname -s) $(uname -m)"
    echo -e "${BLUE}🏗️  Platform:${NC} $platform"
    
    if [[ "$platform" == "macos" ]]; then
        echo -e "${BLUE}🖥️  Memory:${NC} $(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)"GB"}')"
        echo -e "${BLUE}⚙️  CPU:${NC} $(sysctl -n machdep.cpu.brand_string)"
    else
        echo -e "${BLUE}🖥️  Memory:${NC} $(free -h | grep '^Mem:' | awk '{print $2}')"
        echo -e "${BLUE}⚙️  CPU:${NC} $(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d: -f2 | sed 's/^ *//')"
    fi
    
    echo -e "${BLUE}🗂️  VM Storage:${NC} $VM_CONFIG_DIR"
    echo -e "${BLUE}⚡ Acceleration:${NC} $acceleration"
    echo ""
    
    if command -v qemu-system-x86_64 >/dev/null; then
        echo -e "${GREEN}✅ QEMU: Available${NC}"
    else
        echo -e "${RED}❌ QEMU: Not installed${NC}"
    fi
    
    if command -v vboxmanage >/dev/null; then
        echo -e "${GREEN}✅ VirtualBox: Available${NC}"
    else
        echo -e "${RED}❌ VirtualBox: Not installed${NC}"
    fi
}

# Troubleshoot VM boot issues
troubleshoot_vm_boot_ai() {
    local vm_name="$1"
    
    ai_response "Let me help you troubleshoot the 'no bootable device' error!"
    echo ""
    
    if [ -z "$vm_name" ]; then
        echo -e "${YELLOW}Which VM are you having trouble with?${NC}"
        read -r vm_name
    fi
    
    local vm_config=$(get_vm_config "$vm_name")
    
    if [ -z "$vm_config" ]; then
        ai_response "❌ VM '$vm_name' not found. Let me show you available VMs:"
        list_vms_ai
        return 1
    fi
    
    local vm_path=$(echo "$vm_config" | cut -d: -f3)
    local iso_path=$(echo "$vm_config" | cut -d: -f6)
    
    echo -e "${BLUE}🔍 Diagnostic Results:${NC}"
    echo ""
    
    # Check if VM disk exists
    if [ -f "$vm_path" ]; then
        local disk_size=$(ls -lh "$vm_path" | awk '{print $5}')
        echo -e "  ✅ VM disk found: $vm_path ($disk_size)"
    else
        echo -e "  ❌ VM disk missing: $vm_path"
    fi
    
    # Check for ISO file
    if [ -n "$iso_path" ] && [ -f "$iso_path" ]; then
        local iso_size=$(ls -lh "$iso_path" | awk '{print $5}')
        echo -e "  ✅ ISO file found: $iso_path ($iso_size)"
    else
        echo -e "  ❌ No ISO file attached or file missing"
        if [ -n "$iso_path" ]; then
            echo -e "      Expected: $iso_path"
        fi
    fi
    
    echo ""
    echo -e "${BLUE}💡 Solutions:${NC}"
    
    if [ -z "$iso_path" ] || [ ! -f "$iso_path" ]; then
        echo -e "  1. ${YELLOW}Download and attach an ISO file${NC}"
        echo -e "     Example: 'Download Ubuntu ISO for $vm_name'"
        echo ""
        echo -e "  2. ${YELLOW}Manual ISO attachment${NC}"
        echo -e "     Place your ISO in: $VM_ISOS_DIR/"
        echo -e "     Then update VM config to point to it"
    fi
    
    echo -e "  3. ${YELLOW}Start VM with ISO attached${NC}"
    echo -e "     I can modify the start command to boot from ISO"
    echo ""
    
    echo -e "${YELLOW}Would you like me to help you download an ISO for this VM? (y/n):${NC}"
    read -r download_iso
    
    if [[ "$download_iso" =~ ^[Yy]$ ]]; then
        case "$vm_name" in
            *ubuntu*) download_ubuntu_iso_ai "$vm_name" ;;
            *kali*) ai_response "I'll help you download Kali Linux ISO"; download_kali_iso_ai "$vm_name" ;;
            *parrot*) ai_response "I'll help you download Parrot Security ISO"; download_parrot_iso_ai "$vm_name" ;;
            *tails*) ai_response "I'll help you download Tails ISO"; download_tails_iso_ai "$vm_name" ;;
            *qubes*) ai_response "I'll help you download Qubes OS ISO"; download_qubes_iso_ai "$vm_name" ;;
            *) 
                ai_response "I'll need you to manually download the appropriate ISO for $vm_name"
                echo -e "Place it in: ${CYAN}$VM_ISOS_DIR/${NC}"
                ;;
        esac
    fi
}

# Helper functions
get_vm_config() {
    local vm_name=$1
    grep "^$vm_name:" "$VM_CONFIG_FILE" 2>/dev/null
}

create_vm_disk() {
    local vm_name="$1"
    local disk_path="$2"
    local vm_dir=$(dirname "$disk_path")
    
    mkdir -p "$vm_dir"
    qemu-img create -f qcow2 "$disk_path" 20G
}

# Main interactive loop
main_loop() {
    show_greeting
    
    while true; do
        echo -e "${BOLD}${CYAN}You:${NC} "
        read -r user_input
        
        if [ -z "$user_input" ]; then
            continue
        fi
        
        echo ""
        process_command "$user_input"
        echo ""
        echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
        echo ""
    done
}

# Start the interactive assistant
main_loop