function clean_history_password
    echo -n "Enter the password to remove from history: "
    read -s user_password
    echo "" # Move to a new line after entering the password
    history delete --contain "$user_password"
    echo "History entries containing the password have been deleted."
end
