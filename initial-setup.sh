#!/bin/bash

# # Prompt user for their full name and read input
# echo -n "Please enter your full name: "
# read -r full_name

# # Extract the first name from the full name
# first_name=$(echo "$full_name" | awk '{print $1}')

# # Function to print text gradually
# print_gradually() {
#     text=$1
#     delay=${2:-0.03} # Default delay is 0.03
#     for (( i=0; i<${#text}; i++ )); do
#         echo -n "${text:$i:1}"
#         sleep "$delay"
#     done
# }

# # Function to print text gradually fast
# print_gradually_fast() {
#     text=$1
#     print_gradually "$text" 0.005
# }

# # Prompt the user with options
# prompt_with_options() {
#     message=$1
#     options=("${@:2}") # Get all arguments starting from the second
#     print_gradually "$message\n"
#     for i in "${!options[@]}"; do
#         echo "$((i+1)). ${options[i]}"
#     done

#     while true; do
#         echo -n "Enter your choice: "
#         read -r choice
#         if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
#             echo "${options[choice-1]}"
#             return
#         else
#             echo "Invalid input. Please enter the number corresponding to your choice."
#         fi
#     done
# }

# # Define the message and options
# message="Thank you, $first_name! Welcome to Automate All The Things! Are you excited?"
# options=("Yes" "YEEEAAAAHHHHHH!!!!!")

# # Prompt the user and get their choice
# user_choice=$(prompt_with_options "$message" "${options[@]}")

# # Process the user's choice
# if [[ $user_choice == "Yes" ]]; then
#     print_gradually "That's great!\n"
# else
#     print_gradually "WOOOOHOOOOOOOO!!!! DAMN RIGHT!!\n"
# fi

# # Function to check that input is only alphanumeric + "-" + "_"
# check_if_valid() {
#     input_string=$1
#     while ! [[ $input_string =~ ^[a-zA-Z0-9_-]+$ ]]; do
#         print_gradually "This value can only contain alphanumeric characters, hyphens(-) and underscores(_).\nPlease provide a valid name: "
#         read -r input_string
#     done
#     echo "$input_string"
# }

# # Get app name
# echo -n "Alright, let's get the necessary details. What will be the name of your app?: "
# read -r app_name
# app_name=$(check_if_valid "$app_name")

# Get GitHub username
echo -n "What's your GitHub username?: "
read -r github_username

# # Get AWS region
# echo -n "Got it! In what AWS region will you be deploying your resources? (e.g., 'us-east-2'): "
# read -r aws_region

# Get DockerHub username
echo -n "What's your DockerHub username?: "
read -r dockerhub_username

# # Get user email
# echo -n "Perfect! Last thing... You'll receive just one pipeline notification through email. Please provide me with the email you used for your Azure DevOps account: "
# read -r user_email

# print_gradually "Give me a sec... "

# Function that looks for strings AATT_GITHUB_USERNAME and AATT_DOCKERHUB_USERNAME in a files /backstage/my-backstage/app-config.yaml and /k8s-manifests/my-app/backend/deployment and replaces them with the value of github_username and dockerhub_username
replace_string_in_file() {
    file_path=$1
    github_username=$2
    dockerhub_username=$3
    sed -i "s/AATT_GITHUB_USERNAME/$github_username/g" "$file_path"
    sed -i "s/AATT_DOCKERHUB_USERNAME/$dockerhub_username/g" "$file_path"
}

# Call function to replace the strings
replace_string_in_file "application-code/my-app/backend/catalog-info.yaml" "$github_username" "$dockerhub_username"
replace_string_in_file "application-code/my-app/frontend/catalog-info.yaml" "$github_username" "$dockerhub_username"
replace_string_in_file "application-code/my-app/redis/catalog-info.yaml" "$github_username" "$dockerhub_username"
replace_string_in_file "backstage/helm-chart/values-custom.yaml" "$github_username" "$dockerhub_username"
replace_string_in_file "backstage/my-backstage/app-config.yaml" "$github_username" "$dockerhub_username"
replace_string_in_file "backstage/my-backstage/app-config.production.yaml" "$github_username" "$dockerhub_username"

echo -n "That's it! All necessary files were updated with the info you provided.\nYou can go back to the README and carry on with the guide.\n\n"
