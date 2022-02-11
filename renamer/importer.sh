#!/bin/bash

A=$(find "$(pwd)" | grep ".*txt.*")

echo "$A" | while IFS= read -r line; 
    do mv "$line" "$(echo $line | sed 's/\.txt\.md/\.md/g')" 
done

