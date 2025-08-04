#!/bin/bash

set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

declare -A sizes

print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

get_size_kb() {
    local file=$1
    if [[ -f "$file" ]]; then
        stat -c%s "$file" 2>/dev/null | awk '{print int(($1+1023)/1024)}'
    else
        echo "0"
    fi
}

convert_size() {
    local size_kb=$1
    local result=""
    
    if [[ $size_kb -lt 1024 ]]; then
        result="${size_kb}K"
    elif [[ $size_kb -lt 1048576 ]]; then
        local mb=$(awk "BEGIN {printf \"%.1f\", $size_kb/1024}")
        result="${mb}M"
    else
        local gb=$(awk "BEGIN {printf \"%.1f\", $size_kb/1048576}")
        result="${gb}G"
    fi
    
    printf "%7s" "$result"
}

cleanup_files() {
    rm -f hello.o hello.ali b~* *.o *.ali *.hi *.dyn_hi *.dyn_o
    rm -f hello_c hello_cpp hello hello_d hello_nim hello_cr hello_haskell
    rm -f hello_ada hello_pascal hello_zig hello_crystal
}

compile_and_run() {
    local lang=$1
    local file=$2
    local output=$3
    local compile_cmd=$4

    if [[ ! -f "$file" ]]; then
        print_status "$RED" "Error: Source file $file not found for $lang"
        return 1
    fi

    print_status "$YELLOW" "Compiling $lang..."
    
    cleanup_files
    
    if eval "$compile_cmd" 2>/dev/null; then
        local size_kb=$(get_size_kb "$output")
        sizes["$lang"]=$size_kb
        print_status "$GREEN" "✓ $lang compiled successfully (${size_kb}KB)"
        
        # Clean up files after size comparison
        cleanup_files
    else
        print_status "$RED" "✗ Failed to compile $lang"
        sizes["$lang"]="0"
        
        # Clean up files even if compilation failed
        cleanup_files
    fi
}

main() {
    print_status "$GREEN" "Starting language comparison..."
    echo

    declare -A compile_commands=(
        ["C"]="gcc -o hello_c hello.c"
        ["C++"]="clang++ -o hello_cpp hello.cpp -lstdc++"
        ["Go"]="go build -ldflags=\"-s -w\" -o hello hello.go"
        ["Rust"]="rustc hello.rs -o hello"
        ["Ada"]="gnatmake hello.adb -o hello"
        ["Pascal"]="fpc hello.pa -ohello"
        ["D"]="dmd hello.d -ofhello"
        ["Nim"]="nim compile --run hello.nim"
        ["Zig"]="zig build-exe hello.zig"
        ["Crystal"]="crystal build hello.cr -o hello"
        ["Haskell"]="ghc hello.hs -o hello"
    )

    for lang in "${!compile_commands[@]}"; do
        local source_file="hello.${lang,,}"
        local output_file="hello"
        
        case $lang in
            "C") source_file="hello.c"; output_file="hello_c" ;;
            "C++") source_file="hello.cpp"; output_file="hello_cpp" ;;
            "Go") source_file="hello.go" ;;
            "Rust") source_file="hello.rs" ;;
            "Ada") source_file="hello.adb" ;;
            "Pascal") source_file="hello.pa" ;;
            "D") source_file="hello.d" ;;
            "Nim") source_file="hello.nim" ;;
            "Zig") source_file="hello.zig" ;;
            "Crystal") source_file="hello.cr" ;;
            "Haskell") source_file="hello.hs" ;;
        esac
        
        compile_and_run "$lang" "$source_file" "$output_file" "${compile_commands[$lang]}"
    done

    print_status "$YELLOW" "Cleaning up build artifacts..."
    cleanup_files

    echo
    print_status "$GREEN" "Compilation complete. Results:"
    echo
    echo "| Programming Language | Binary Size |"
    echo "|---------------------|-------------|"

    for lang in "${!sizes[@]}"; do 
        printf "%d %s\n" "${sizes[$lang]}" "$lang"
    done | sort -n | while read -r size lang; do
        human_size=$(convert_size "$size")
        printf "| %-19s | %11s |\n" "$lang" "$human_size"
    done
}

main "$@"

