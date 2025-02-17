#!/bin/bash

# Define output file
output_file="results.txt"
website=$1

if [ -z "$website" ]; then
    echo "Usage: $0 <website_url>"
    exit 1
fi

# Function to normalize URL
normalize_url() {
    local url="$1"
    if [[ ! "$url" =~ ^https?:// ]]; then
        url="https://$url"
    fi
    echo "$url"
}

# Normalize input URL
website=$(normalize_url "$website")
domain=$(echo "$website" | awk -F[/:] '{print $4}')

echo "🔍 Scanning $website..." | tee "$output_file"

# Extract external links
echo -e "\n🔗 Extracting external links..." | tee -a "$output_file"
links=$(curl -s -L "$website" | grep -oP '(?<=href=")[^"]*' | grep -E 'https?://' | sort -u)
echo "$links" | tee -a "$output_file"

# WHOIS Lookup
echo -e "\n🌍 WHOIS Lookup..." | tee -a "$output_file"
whois "$domain" | grep -E 'Registrar|Registrant|Organization|Country|Creation Date' | tee -a "$output_file"

# Fetch Server Headers
echo -e "\n🛰️ Fetching Server Headers..." | tee -a "$output_file"
curl -s -I "$website" | head -n 15 | tee -a "$output_file"

# Find Subdomains
echo -e "\n🔎 Finding Subdomains..." | tee -a "$output_file"

# Using crt.sh
crt_subdomains=$(curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value' | sort -u)

# Using subfinder (if installed)
if command -v subfinder &> /dev/null; then
    subfinder_subdomains=$(subfinder -d "$domain" -silent)
    all_subdomains=$(echo -e "$crt_subdomains\n$subfinder_subdomains" | sort -u)
else
    all_subdomains="$crt_subdomains"
fi

# Save and display subdomains
echo "$all_subdomains" | tee -a "$output_file"

echo -e "\n✅ Your Scan is Complete! Results saved in $output_file."
