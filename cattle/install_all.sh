#!/bin/bash
for file in $(cat brew.txt); do brew install ${file}; done