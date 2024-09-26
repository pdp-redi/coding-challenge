#!/bin/bash

# Set variables
SOURCE_DIR="/home/domain/member/mail"     #"/home/pdpredi/practice"
REMOTE_SERVER="remote_imap_server"        #"my-ec2"
REMOTE_USER="remote_user"                 #"ubuntu"
REMOTE_DIR="/home/domain/member/mail"     #"/home/ubuntu/pdpredi"
START_DATE="2023-08-01 09:00:00"          #"2024-08-21 19:14:28" 
END_DATE="2023-08-02 08:00:00"            #"2024-09-25 23:46:53"


# Find files modified within the specified date range
find "$SOURCE_DIR" -type f -newermt "$START_DATE" ! -newermt "$END_DATE" | while read -r file; do
    # Get the relative path of the file
    rel_path="${file#$SOURCE_DIR/}"
    
    # Create the directory structure on the remote server
    ssh "$REMOTE_USER@$REMOTE_SERVER" "mkdir -p \"$REMOTE_DIR/$(dirname "$rel_path")\""
    
    # Copy the file to the remote server
    scp "$file" "$REMOTE_USER@$REMOTE_SERVER:$REMOTE_DIR/$rel_path"
done

echo "Backup completed successfully."