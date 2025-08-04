#!/bin/bash

# Declare associative array to store sizes
declare -A sizes

# Function to get binary size in kilobytes
get_size_kb() {
    local file=$1
    if [[ -f $file ]]; then
        du -k "$file" | cut -f1
    else
        echo "0"
    fi
}

# Function to convert size to human-readable format
convert_size() {
    local size_kb=$1
    local result=""
    
    if [[ $size_kb -lt 1024 ]]; then
        result="${size_kb}K"
    elif [[ $size_kb -lt 1048576 ]]; then
        # Use bc for floating-point division
        local mb=$(echo "scale=1; $size_kb/1024" | bc)
        # Manually format to avoid printf issues
        result=$(echo "$mb" | awk '{printf "%.1f", $1}')M
    else
        local gb=$(echo "scale=1; $size_kb/1048576" | bc)
        result=$(echo "$gb" | awk '{printf "%.1f", $1}')G
    fi
    
    printf "%7s" "$result"
}

# Function to clean up specific files
cleanup_files() {
    rm -f hello.o hello.ali b~*
}

# Function to compile and run a program
compile_and_run() {
    local lang=$1
    local file=$2
    local output=$3
    local compile_cmd=$4

    echo "Compiling $lang..."
    cleanup_files
    rm -f "$output"
    eval "$compile_cmd"
    
    # Store size in kilobytes for sorting
    sizes["$lang"]=$(get_size_kb "$output")
}

# Compile programs
compile_and_run "C" "hello.c" "hello_c" "gcc -o hello_c hello.c -Os"
compile_and_run "Go" "hello.go" "hello" "go build -ldflags=\"-s -w\" hello.go"
compile_and_run "Rust" "hello.rs" "hello" "rustc hello.rs"
compile_and_run "Ada" "hello.adb" "hello" "gnatmake hello.adb"
compile_and_run "Pascal" "hello.pa" "hello" "fpc hello.pa"
compile_and_run "D" "hello.d" "hello" "dmd hello.d"
compile_and_run "Nim" "hello.nim" "hello" "nim compile --run hello.nim"
compile_and_run "Zig" "hello.zig" "hello" "zig build-exe hello.zig"
compile_and_run "Crystal" "hello.cr" "hello" "crystal build hello.cr"
compile_and_run "Haskell" "hello.hs" "hello" "ghc hello.hs -o hello"

# Clean up
echo "Cleaning up..."
rm -f hello_c hello hello_d hello_nim hello_cr hello_haskell

# Print markdown table sorted by size
echo "All programs compiled and sizes printed."
echo ""
echo "| Programming Language | Binary Size |"
echo "|---------------------|-------------|"

# Sort and print languages by size
(
    for lang in "${!sizes[@]}"; do 
        printf "%d %s\n" "${sizes[$lang]}" "$lang"
    done | sort -n | while read -r size lang; do
        human_size=$(convert_size "$size")
        printf "| %-19s | %11s |\n" "$lang" "$human_size"
    done
)

