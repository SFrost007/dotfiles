#!/bin/sh

branch=$(git symbolic-ref --short HEAD)
echo "Hook: Pushing branch ${branch}"
echo "Hook: Create pull request here:"
echo "Hook:     https://sales-i.visualstudio.com/_git/iOS-Mobile/pullrequestcreate?sourceRef=${branch}"
